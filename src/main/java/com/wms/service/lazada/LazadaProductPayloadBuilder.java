package com.wms.service.lazada;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.model.ChannelProduct;
import com.wms.model.Product;
import com.wms.model.ProductImage;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * LazadaProductPayloadBuilder — UC-B2C09 helper that validates a product
 * draft against Lazada's {@code /product/create} rules and assembles the
 * final payload string sent over the wire.
 *
 * <p>Wire format (per Lazada Open Platform docs):
 * <pre>
 *   payload = { "Request": { "Product": {
 *       "PrimaryCategory": "10002019",
 *       "Images": { "Image": [ "url1", "url2", ... ] },
 *       "Attributes": {
 *           "name": "...", "description": "...",
 *           "brand": "No brand", "short_description": "..."
 *       },
 *       "Skus": { "Sku": [{
 *           "SellerSku": "...", "quantity": "10", "price": "100",
 *           "special_price": "90", "special_from_date": "...",
 *           "special_to_date": "...",
 *           "package_height": "10", "package_length": "10",
 *           "package_width": "10", "package_weight": "0.5"
 *       }]}
 *   }}}
 * </pre>
 * The {@code payload} field is then sent as a single form-urlencoded param.
 *
 * <p>Hardcoded brand: WMS operates a non-LazMall shop, brand is
 * always {@value #BRAND}. LazMall-only rules (e.g. {@code C035}) skipped.
 */
public class LazadaProductPayloadBuilder {

    public static final double MAX_WEIGHT_KG = 40.0;
    public static final int MAX_DIMENSION_SUM_CM = 300;
    /**
     * Default brand when the seller has not picked one. Lazada rejects products
     * with empty brand on most categories, so we fall back to "No brand" only
     * as a last resort. Sellers should override this via the wizard.
     */
    public static final String BRAND = "No brand";

    private static final ObjectMapper MAPPER = new ObjectMapper();

    public List<ValidationError> validate(Product p, ChannelProduct cp,
                                           List<ProductImage> images) {
        List<ValidationError> errs = new ArrayList<>();
        if (p == null) {
            errs.add(new ValidationError("", "PRODUCT_NULL", "Không tìm thấy sản phẩm."));
            return errs;
        }
        if (p.getProductName() == null || p.getProductName().isBlank()) {
            errs.add(new ValidationError("name", "REQUIRED_NAME",
                "Tên sản phẩm không được để trống."));
        } else if (p.getProductName().length() > 255) {
            errs.add(new ValidationError("name", "NAME_TOO_LONG",
                "Tên sản phẩm phải ≤ 255 ký tự."));
        }
        String shortDesc = firstNonBlank(p.getShortDescription(),
                cp == null ? null : cp.getShortDescription());
        if (shortDesc == null) {
            errs.add(new ValidationError("short_description", "REQUIRED_SHORT_DESC",
                "Mô tả ngắn không được để trống."));
        } else if (shortDesc.length() > 255) {
            errs.add(new ValidationError("short_description", "SHORT_DESC_TOO_LONG",
                "Mô tả ngắn phải ≤ 255 ký tự."));
        }
        if (p.getCategoryId() == null) {
            errs.add(new ValidationError("category_id", "REQUIRED_CATEGORY",
                "Sản phẩm chưa có danh mục. Cập nhật danh mục trước khi đẩy."));
        }
        BigDecimal price = cp != null ? cp.getChannelPrice() : null;
        if (price == null || price.signum() <= 0) {
            errs.add(new ValidationError("price", "BIZ_CHECK_PRICE_IS_ZERO",
                "Giá bán phải lớn hơn 0."));
        }
        if (cp != null && cp.getSpecialPrice() != null) {
            if (cp.getSpecialPrice().signum() <= 0) {
                errs.add(new ValidationError("special_price",
                    "BIZ_CHECK_SPECIAL_PRICE_IS_ZERO",
                    "Giá khuyến mãi phải lớn hơn 0."));
            } else if (price != null && cp.getSpecialPrice().compareTo(price) >= 0) {
                errs.add(new ValidationError("special_price",
                    "BIZ_CHECK_SPECIAL_PRICE_GREATER_THAN_PRICE",
                    "Giá khuyến mãi phải nhỏ hơn giá gốc."));
            }
        }
        if (images == null || images.isEmpty()) {
            errs.add(new ValidationError("images", "BIZ_CHECK_MAIN_IMAGE_REQUIRE",
                "Sản phẩm phải có ít nhất 1 ảnh chính."));
        }
        Double weight = cp != null ? cp.getWeightKg() : null;
        if (weight == null) weight = p.getWeightKg();
        if (weight != null && weight > MAX_WEIGHT_KG) {
            errs.add(new ValidationError("weight_kg", "PACKAGE_WEIGHT_EXCEEDS_LIMIT",
                "Cân nặng gói hàng không được vượt quá 40kg."));
        }
        if (cp != null && cp.getDimensions() != null && !cp.getDimensions().isBlank()) {
            int[] dims = parseDimensions(cp.getDimensions());
            if (dims == null) {
                errs.add(new ValidationError("dimensions", "INVALID_DIMENSIONS_FORMAT",
                    "Kích thước không hợp lệ. Định dạng DxRxC (cm), ví dụ 30x20x10."));
            } else if (dims[0] + dims[1] + dims[2] > MAX_DIMENSION_SUM_CM) {
                errs.add(new ValidationError("dimensions",
                    "PACKAGE_DIMENSION_EXCEEDS_LIMIT",
                    "Tổng kích thước (Dài + Rộng + Cao) không quá 300cm."));
            }
        }
        String sellerSku = cp != null && cp.getSellerSku() != null && !cp.getSellerSku().isBlank()
                ? cp.getSellerSku().trim()
                : (cp != null ? cp.getChannelSkuCode() : null);
        if (sellerSku == null || sellerSku.isBlank()) {
            errs.add(new ValidationError("seller_sku", "REQUIRED_SELLER_SKU",
                "Seller SKU không được để trống."));
        } else if (sellerSku.length() > 50 || !sellerSku.matches("[A-Za-z0-9_-]+")) {
            errs.add(new ValidationError("seller_sku", "INVALID_SELLER_SKU",
                "Seller SKU chỉ chứa chữ, số, - hoặc _ (tối đa 50 ký tự)."));
        }
        return errs;
    }

    /**
     * Builds the Lazada-compliant payload JSON string for {@code /product/create}.
     * Result is serialized as:
     * {@code {"Request":{"Product":{...}}}}
     */
    public String buildJson(Product p, ChannelProduct cp, List<String> lazadaImageUrls) {
        // Lazada VN now accepts external HTTPS image URLs directly without /images/migrate
        List<String> finalImages = (lazadaImageUrls != null && !lazadaImageUrls.isEmpty())
                ? lazadaImageUrls : new ArrayList<>();
        Map<String, Object> sku = new LinkedHashMap<>();
        sku.put("SellerSku", firstNonBlank(cp == null ? null : cp.getSellerSku(),
                                           cp == null ? null : cp.getChannelSkuCode()));
        sku.put("quantity", String.valueOf(cp.getChannelStock() != null ? cp.getChannelStock() : 0));
        sku.put("price", cp.getChannelPrice().toPlainString());
        if (cp.getSpecialPrice() != null) {
            sku.put("special_price", cp.getSpecialPrice().toPlainString());
            // Lazada requires ISO dates; only send them when the seller actually
            // intends a promo window. We default to the next 30 days computed
            // from "now" so values never go stale.
            String fromDate = java.time.LocalDate.now().toString() + " 00:00:00";
            String toDate   = java.time.LocalDate.now().plusDays(30).toString() + " 23:59:59";
            sku.put("special_from_date", fromDate);
            sku.put("special_to_date", toDate);
        }
        // Package dimensions: trust the seller. If missing, the Lazada endpoint
        // will return a precise validation error instead of silently faking
        // values (the old "10x10x10 / 0.2kg" defaults masked real data gaps).
        Double weight = parseWeight(cp == null ? null : cp.getWeightKg(),
                                      p == null ? null : p.getWeightKg());
        if (weight != null) {
            sku.put("package_weight", String.valueOf(weight));
        }
        if (cp.getDimensions() != null && !cp.getDimensions().isBlank()) {
            int[] dims = parseDimensions(cp.getDimensions());
            if (dims != null) {
                sku.put("package_length", String.valueOf(dims[0]));
                sku.put("package_width", String.valueOf(dims[1]));
                sku.put("package_height", String.valueOf(dims[2]));
            }
        }

        Map<String, Object> skus = new LinkedHashMap<>();
        skus.put("Sku", new Object[]{ sku });

        Map<String, Object> attributes = new LinkedHashMap<>();
        attributes.put("name", trim(p.getProductName(), 255));
        // Brand: prefer ChannelProduct override (set via wizard/UI), fall back
        // to the constant. We no longer force "No brand" if the seller left it
        // empty — empty brand on Lazada-VN is allowed and lets the marketplace
        // pick the default for the category.
        String brandVal = firstNonBlank(cp == null ? null : cp.getBrand(), BRAND);
        attributes.put("brand", brandVal);
        // Lazada "description" accepts up to 5000 chars. Product model only has
        // shortDescription (≤255), so we use it for both fields. Previously this
        // was set to productName, which is a bug — Lazada then displays the
        // product name twice and never the actual description.
        String longDesc = firstNonBlank(p.getShortDescription(),
                cp == null ? null : cp.getShortDescription());
        attributes.put("description", trim(longDesc, 5000));
        attributes.put("short_description", trim(longDesc, 255));

        // Lazada category-specific mandatory attributes (hardcoded defaults for the
        // categories we support right now). Real flow would render a dynamic form
        // backed by /category/attributes/get and store the user's choices.
        if (cp != null && cp.getLazadaCategoryId() != null && cp.getLazadaCategoryId() == 62453404L) {
            // "Gọng kính" — mandatory attributes per /category/attributes/get
            attributes.put("recommended_gender", "Unisex");
            attributes.put("warranty_type", "No Warranty");
            // package dimensions are mandatory for this category at product level;
            // surface whatever the seller supplied (no fake defaults).
            if (cp.getDimensions() != null && !cp.getDimensions().isBlank()) {
                int[] dims = parseDimensions(cp.getDimensions());
                if (dims != null) {
                    attributes.put("package_length", String.valueOf(dims[0]));
                    attributes.put("package_width", String.valueOf(dims[1]));
                    attributes.put("package_height", String.valueOf(dims[2]));
                }
            }
        }

        Map<String, Object> images = new LinkedHashMap<>();
        images.put("Image", finalImages);

        Map<String, Object> product = new LinkedHashMap<>();
        // Lazada requires a LEAF category from its own tree. We prefer the
        // value chosen by the wizard (mirrored in channel_products.lazada_category_id).
        // Fall back to the WMS product's category only as a last resort.
        Long lazadaCatId = cp == null ? null : cp.getLazadaCategoryId();
        if (lazadaCatId != null) {
            product.put("PrimaryCategory", String.valueOf(lazadaCatId));
        } else if (p.getCategoryId() != null) {
            product.put("PrimaryCategory", String.valueOf(p.getCategoryId()));
        }
        product.put("Images", images);
        product.put("Attributes", attributes);
        product.put("Skus", skus);

        Map<String, Object> request = new LinkedHashMap<>();
        request.put("Product", product);

        Map<String, Object> payload = new HashMap<>();
        payload.put("Request", request);

        try {
            return MAPPER.writeValueAsString(payload);
        } catch (Exception e) {
            throw new RuntimeException("Failed to serialize Lazada payload", e);
        }
    }

    /**
     * Returns the form-urlencoded param name and value Lazada expects:
     * {@code payload=<JSON-string>}.
     */
    public Map<String, String> build(Product p, ChannelProduct cp,
                                     List<String> lazadaImageUrls) {
        Map<String, String> out = new LinkedHashMap<>();
        out.put("payload", buildJson(p, cp, lazadaImageUrls));
        return out;
    }

    /**
     * Builds the Lazada-compliant payload JSON string for {@code /product/update}.
     * Result is serialized as:
     * {@code {"Request":{"Product":{"ItemId": "...", "Skus":{"Sku":[{"SkuId":"...",...}]}}}}}
     */
    public String buildUpdateJson(Product p, ChannelProduct cp, List<String> lazadaImageUrls) {
        List<String> finalImages = (lazadaImageUrls != null && !lazadaImageUrls.isEmpty())
                ? lazadaImageUrls : new ArrayList<>();
        Map<String, Object> sku = new LinkedHashMap<>();
        sku.put("SellerSku", firstNonBlank(cp == null ? null : cp.getSellerSku(),
                                           cp == null ? null : cp.getChannelSkuCode()));
        if (cp != null && cp.getLazadaSkuId() != null && !cp.getLazadaSkuId().isEmpty()) {
            sku.put("SkuId", cp.getLazadaSkuId());
        }
        sku.put("quantity", String.valueOf(cp.getChannelStock() != null ? cp.getChannelStock() : 0));
        sku.put("price", cp.getChannelPrice().toPlainString());
        if (cp.getSpecialPrice() != null) {
            sku.put("special_price", cp.getSpecialPrice().toPlainString());
            String fromDate = java.time.LocalDate.now().toString() + " 00:00:00";
            String toDate   = java.time.LocalDate.now().plusDays(30).toString() + " 23:59:59";
            sku.put("special_from_date", fromDate);
            sku.put("special_to_date", toDate);
        }
        Double weight = parseWeight(cp == null ? null : cp.getWeightKg(),
                                      p == null ? null : p.getWeightKg());
        if (weight != null) {
            sku.put("package_weight", String.valueOf(weight));
        }
        if (cp.getDimensions() != null && !cp.getDimensions().isBlank()) {
            int[] dims = parseDimensions(cp.getDimensions());
            if (dims != null) {
                sku.put("package_length", String.valueOf(dims[0]));
                sku.put("package_width", String.valueOf(dims[1]));
                sku.put("package_height", String.valueOf(dims[2]));
            }
        }
        if (!finalImages.isEmpty()) {
            Map<String, Object> skuImages = new LinkedHashMap<>();
            skuImages.put("Image", finalImages);
            sku.put("Images", skuImages);
        }

        Map<String, Object> skus = new LinkedHashMap<>();
        skus.put("Sku", new Object[]{ sku });

        Map<String, Object> attributes = new LinkedHashMap<>();
        attributes.put("name", trim(p.getProductName(), 255));
        String brandVal = firstNonBlank(cp == null ? null : cp.getBrand(), BRAND);
        attributes.put("brand", brandVal);
        String longDesc = firstNonBlank(p.getShortDescription(),
                cp == null ? null : cp.getShortDescription());
        attributes.put("description", trim(longDesc, 5000));
        attributes.put("short_description", trim(longDesc, 255));

        if (cp != null && cp.getLazadaCategoryId() != null && cp.getLazadaCategoryId() == 62453404L) {
            attributes.put("recommended_gender", "Unisex");
            attributes.put("warranty_type", "No Warranty");
            if (cp.getDimensions() != null && !cp.getDimensions().isBlank()) {
                int[] dims = parseDimensions(cp.getDimensions());
                if (dims != null) {
                    attributes.put("package_length", String.valueOf(dims[0]));
                    attributes.put("package_width", String.valueOf(dims[1]));
                    attributes.put("package_height", String.valueOf(dims[2]));
                }
            }
        }

        Map<String, Object> product = new LinkedHashMap<>();
        if (cp != null && cp.getChannelItemId() != null && !cp.getChannelItemId().isEmpty()) {
            product.put("ItemId", cp.getChannelItemId());
        }
        Long lazadaCatId = cp == null ? null : cp.getLazadaCategoryId();
        if (lazadaCatId != null) {
            product.put("PrimaryCategory", String.valueOf(lazadaCatId));
        } else if (p.getCategoryId() != null) {
            product.put("PrimaryCategory", String.valueOf(p.getCategoryId()));
        }
        if (!finalImages.isEmpty()) {
            Map<String, Object> productImages = new LinkedHashMap<>();
            productImages.put("Image", finalImages);
            product.put("Images", productImages);
        }
        product.put("Attributes", attributes);
        product.put("Skus", skus);

        Map<String, Object> request = new LinkedHashMap<>();
        request.put("Product", product);

        Map<String, Object> payload = new HashMap<>();
        payload.put("Request", request);

        try {
            return MAPPER.writeValueAsString(payload);
        } catch (Exception e) {
            throw new RuntimeException("Failed to serialize Lazada update payload", e);
        }
    }

    public Map<String, String> buildUpdate(Product p, ChannelProduct cp,
                                           List<String> lazadaImageUrls) {
        Map<String, String> out = new LinkedHashMap<>();
        out.put("payload", buildUpdateJson(p, cp, lazadaImageUrls));
        return out;
    }

    static int[] parseDimensions(String s) {
        if (s == null) return null;
        String[] parts = s.split("\\s*[xX*\\u00d7\\u2715\\u2716\\uff58\\uff38]\\s*");
        if (parts.length != 3) return null;
        try {
            int[] out = new int[3];
            for (int i = 0; i < 3; i++) {
                double v = Double.parseDouble(parts[i].trim());
                out[i] = (int) Math.round(v);
                if (out[i] <= 0 || out[i] > 200) return null;
            }
            return out;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static String trim(String s, int max) {
        if (s == null) return "";
        return s.length() > max ? s.substring(0, max) : s;
    }

    private static Double parseWeight(Double explicit, Double fromProduct) {
        Double w = explicit != null ? explicit : fromProduct;
        if (w != null) return w;
        return null;
    }

    /**
     * Attempts to parse a numeric weight from a String that may contain a unit
     * suffix (e.g. "0.5 kg", "500g"). Returns null if unparseable.
     */
    public static Double parseWeightFromString(String s) {
        if (s == null || s.isBlank()) return null;
        try { return Double.parseDouble(s.trim()); } catch (NumberFormatException ignored) {}
        try {
            // strip non-numeric except dot/comma/minus
            String num = s.replaceAll("[^0-9.,\\-]", "").replace(',', '.');
            return Double.parseDouble(num);
        } catch (NumberFormatException ignored) {}
        return null;
    }

    private static String firstNonBlank(String... values) {
        for (String v : values) if (v != null && !v.isBlank()) return v;
        return null;
    }

    public static final class ValidationError {
        public final String field;
        public final String code;
        public final String viMessage;
        public ValidationError(String field, String code, String viMessage) {
            this.field = field;
            this.code = code;
            this.viMessage = viMessage;
        }
    }
}