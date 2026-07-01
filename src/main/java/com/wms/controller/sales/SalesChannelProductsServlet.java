package com.wms.controller.sales;

import com.wms.controller.BaseController;
import com.wms.dao.ChannelDAO;
import com.wms.dao.ProductImageDAO;
import com.wms.model.Channel;
import com.wms.model.Product;
import com.wms.service.lazada.LazadaProductService;
import com.wms.service.lazada.LazadaProductService.PushResult;
import com.wms.service.sales.ChannelService;
import com.wms.service.product.ProductService;
import com.wms.util.JsonUtil;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.NumberFormat;
import java.util.Base64;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

/**
 * SalesChannelProductsServlet — Handles the "Sản phẩm theo kênh" page for Sales Staff.
 * Maps to /sales/channel-products.
 */
public class SalesChannelProductsServlet extends BaseController {

    private static final java.util.logging.Logger LOGGER =
            java.util.logging.Logger.getLogger(SalesChannelProductsServlet.class.getName());

    private final ChannelService channelService = new ChannelService();
    private final ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            List<?> channels = channelService.findAll();
            req.setAttribute("channelsList", channels);
            req.setAttribute("channelsJson", JsonUtil.toJson(channels));

            List<?> products = productService.findAll();
            req.setAttribute("products", products);
            req.setAttribute("productsJson", JsonUtil.toJson(products));

            List<?> categories = productService.findAllCategories();
            req.setAttribute("categories", categories);
            req.setAttribute("categoriesJson", JsonUtil.toJson(categories));
        } catch (Exception e) {
            req.setAttribute("channelsList", List.of());
            req.setAttribute("channelsJson", "[]");
            req.setAttribute("products", List.of());
            req.setAttribute("productsJson", "[]");
            req.setAttribute("categories", List.of());
            req.setAttribute("categoriesJson", "[]");
        }

        // Load channel products from DB so the page always shows real data
        // (previously relied on localStorage which is cleared on new browser/device)
        try {
            List<com.wms.model.ChannelProduct> channelProducts =
                    new com.wms.dao.ChannelProductDAO().findAll();
            req.setAttribute("channelProductsList", channelProducts);
            req.setAttribute("channelProductsJson", JsonUtil.toJson(channelProducts));
        } catch (Exception e) {
            req.setAttribute("channelProductsList", List.of());
            req.setAttribute("channelProductsJson", "[]");
        }

        req.setAttribute("pageTitle",    "Sản Phẩm Theo Kênh");
        req.setAttribute("pageSubtitle", "Quản lý sản phẩm kinh doanh trên các sàn thương mại điện tử");
        req.setAttribute("currentPage",  "sales-channel-products");

        req.setAttribute("contentPage", "/WEB-INF/views/sales/channel-products.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/sales-layout.jsp")
           .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("updateBufferStock".equals(action)) {
            String channelIdStr = req.getParameter("channelId");
            String bufferStockStr = req.getParameter("bufferStock");

            if (isNullOrEmpty(channelIdStr) || isNullOrEmpty(bufferStockStr)) {
                writeJson(resp, "{\"success\":false,\"message\":\"Missing parameters\"}");
                return;
            }

            try {
                int channelId = Integer.parseInt(channelIdStr);
                double bufferStock = Double.parseDouble(bufferStockStr);
                boolean updated = channelService.updateBufferStock(channelId, bufferStock);
                if (updated) {
                    writeJson(resp, "{\"success\":true}");
                } else {
                    writeJson(resp, "{\"success\":false,\"message\":\"Channel not found\"}");
                }
            } catch (Exception e) {
                writeJson(resp, "{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
            }
        } else if ("pull".equals(action)) {
            // Lazada end-to-end: pull marketplace products (synchronous for direct UI response)
            int channelId = Integer.parseInt(req.getParameter("channelId"));
            Channel ch = new ChannelDAO().findById(channelId);
            if (ch == null) {
                writeJson(resp, "{\"success\":false,\"message\":\"Channel not found\"}");
                return;
            }
            try {
                LazadaProductService.PullResult r = new LazadaProductService().pullProducts(ch);
                if (r.ok) {
                    writeJson(resp, "{\"success\":true,\"message\":\"Kéo sản phẩm thành công! Đã tải " + r.pulled + " sản phẩm từ sàn, phát hiện " + r.unmapped + " sản phẩm chưa ánh xạ.\"}");
                } else {
                    writeJson(resp, "{\"success\":false,\"message\":\"Kéo sản phẩm thất bại: " + esc(r.error) + "\"}");
                }
            } catch (Exception ex) {
                LOGGER.log(java.util.logging.Level.WARNING, "channel-products pull: failed", ex);
                writeJson(resp, "{\"success\":false,\"message\":\"Lỗi hệ thống: " + esc(ex.getMessage()) + "\"}");
            }

        } else if ("push".equals(action)) {
            // UC-B2C09 / UC-B2C02: push a single product with structured errors.
            // Wizard passes lazadaCategoryId (leaf category from /category/tree/get)
            // plus price/qty/desc/brand/weight/dimensions/images — we apply them
            // to the channel_products row so the payload builder uses the values
            // the user just typed in the wizard (not stale DB state).
            try {
            NumberFormat nf = NumberFormat.getInstance(Locale.forLanguageTag("vi"));
            int channelId = Integer.parseInt(req.getParameter("channelId"));
            int productId = Integer.parseInt(req.getParameter("productId"));
            Channel ch = new ChannelDAO().findById(channelId);
            if (ch == null) {
                writeJson(resp, "{\"success\":false,\"message\":\"Channel not found\"}");
                return;
            }
                com.wms.dao.ChannelProductDAO cpDao = new com.wms.dao.ChannelProductDAO();

                // 1) Lazada category from wizard
                String lzCatParam = req.getParameter("lazadaCategoryId");
                if (lzCatParam != null && !lzCatParam.isBlank()) {
                    long lzCatId = Long.parseLong(lzCatParam.trim());
                    cpDao.updateLazadaCategoryId(productId, channelId, lzCatId);
                }

                // 2) Wizard-supplied fields — apply to the channel_products row.
                //    This is what makes the price/quantity/etc. on Lazada match
                //    what the user typed in the wizard (was a known bug where
                //    wizard inputs were ignored and stale DB values were sent).
                com.wms.model.ChannelProduct cp = cpDao.findByProductAndChannel(productId, channelId);
                com.wms.model.Product prod = new com.wms.dao.ProductDAO().findById(productId);
                if (cp == null) {
                    cp = new com.wms.model.ChannelProduct();
                    cp.setChannelId(channelId);
                    cp.setProductId(productId);
                    if (prod != null) cp.setChannelSkuCode(prod.getSkuCode());
                }
                String priceParam = req.getParameter("price");
                BigDecimal channelPrice = null;
                if (priceParam != null && !priceParam.isBlank()) {
                    try {
                        channelPrice = new BigDecimal(priceParam);
                    } catch (NumberFormatException ignored) {}
                }

                // BR-PRICE-01: Giá bán trên sàn phải >= base_price * 1.30 (lãi tối thiểu 30%).
                // base_price là giá nhập (tồn kho) — lấy từ products.base_price.
                if (channelPrice != null && channelPrice.signum() > 0 && prod != null) {
                    double basePrice = prod.getBasePrice() != null ? prod.getBasePrice() : 0.0;
                    if (basePrice > 0) {
                        BigDecimal minPrice = BigDecimal.valueOf(basePrice * 1.30);
                        if (channelPrice.compareTo(minPrice) < 0) {
                            writeJson(resp, "{\"success\":false,\"code\":\"PRICE_TOO_LOW\","
                                + "\"message\":\"Giá bán phải từ \" + nf.format(minPrice) + \"đ trở lên (giá nhập × 1.30). Giá hiện tại: \" + nf.format(channelPrice) + \"đ.\","
                                + "\"minPrice\":\"" + nf.format(minPrice) + "\","
                                + "\"basePrice\":\"" + nf.format(BigDecimal.valueOf(basePrice)) + "\"}");
                            return;
                        }
                    }
                }

                if (priceParam != null && !priceParam.isBlank()) {
                    cp.setChannelPrice(channelPrice);
                }
                String qtyParam = req.getParameter("quantity");
                if (qtyParam != null && !qtyParam.isBlank()) {
                    cp.setChannelStock(new java.math.BigDecimal(qtyParam));
                }
                String descParam = req.getParameter("description");
                if (descParam != null) cp.setDescription(descParam);
                String shortDescParam = req.getParameter("shortDescription");
                if (shortDescParam != null) cp.setShortDescription(shortDescParam);
                String brandParam = req.getParameter("brand");
                if (brandParam != null && !brandParam.isBlank()) cp.setBrand(brandParam);
                String weightParam = req.getParameter("weight");
                if (weightParam != null && !weightParam.isBlank()) {
                    cp.setWeightKg(Double.parseDouble(weightParam));
                }
                String dimsParam = req.getParameter("dimensions");
                if (dimsParam != null && !dimsParam.isBlank()) cp.setDimensions(dimsParam);
                String skuParam = req.getParameter("sellerSku");
                if (skuParam != null && !skuParam.isBlank()) cp.setSellerSku(skuParam);

                // 3) Persist draft to DB so the service can read it back.
                // Preserve non-persistent staging/override fields which are not stored in DB table.
                String savedSellerSku = cp.getSellerSku();
                String savedShortDesc = cp.getShortDescription();
                java.math.BigDecimal savedSpecialPrice = cp.getSpecialPrice();
                Double savedWeight = cp.getWeightKg();
                String savedDims = cp.getDimensions();
                String savedBrand = cp.getBrand();
                String savedDesc = cp.getDescription();

                if (cp.getId() > 0) {
                    cpDao.update(cp);
                } else {
                    cpDao.insert(cp);
                    cp = cpDao.findByProductAndChannel(productId, channelId);
                }

                if (cp != null) {
                    cp.setSellerSku(savedSellerSku);
                    cp.setShortDescription(savedShortDesc);
                    cp.setSpecialPrice(savedSpecialPrice);
                    cp.setWeightKg(savedWeight);
                    cp.setDimensions(savedDims);
                    cp.setBrand(savedBrand);
                    cp.setDescription(savedDesc);
                }

                // 4) Wizard-uploaded images (pipe-separated). These override the
                //    WMS product_images set for this push only — they're passed
                //    straight to /image/migrate via the service, not persisted.
                //    base64 originals are sent as fallback when migration fails (e.g. E304 for internal URLs).
                List<String> customImageUrls = new java.util.ArrayList<>();
                List<String> customImageBase64s = new java.util.ArrayList<>();
                String imageUrlsParam = req.getParameter("imageUrls");
                String imageBase64sParam = req.getParameter("imageBase64s");
                if (imageUrlsParam != null && !imageUrlsParam.isBlank()) {
                    String[] urlParts = imageUrlsParam.split("\\|");
                    String[] b64Parts = (imageBase64sParam != null && !imageBase64sParam.isBlank())
                            ? imageBase64sParam.split("\\|") : new String[0];
                    for (int i = 0; i < urlParts.length; i++) {
                        String trimmed = urlParts[i].trim();
                        if (!trimmed.isEmpty()) {
                            // Convert relative /publish-images/... URLs to absolute for migration.
                            String absolute = toAbsoluteUrl(req, trimmed);
                            customImageUrls.add(absolute);
                            // Base64 fallback at same index (may be null if not provided)
                            String b64 = (i < b64Parts.length) ? b64Parts[i].trim() : null;
                            customImageBase64s.add((b64 != null && !b64.isEmpty()) ? b64 : null);
                        }
                    }
                }

                PushResult r = new LazadaProductService().pushProduct(
                        ch, productId, customImageUrls, customImageBase64s, cp);
                writeJson(resp, renderPushResultJson(r));
            } catch (NumberFormatException e) {
                LOGGER.warning("channel-products push: invalid channelId or productId: " + e.getMessage());
                writeJson(resp, "{\"success\":false,\"message\":\"Invalid channel or product: " + esc(e.getMessage()) + "\"}");
            } catch (Exception e) {
                LOGGER.log(java.util.logging.Level.WARNING,
                        "channel-products push: failed", e);
                writeJson(resp, "{\"success\":false,\"message\":\"" + esc(e.getMessage()) + "\"}");
            }
        } else if ("getProductDetail".equals(action)) {
            try {
                int productId = Integer.parseInt(req.getParameter("productId"));
                Product p = productService.findById(productId);
                if (p == null) {
                    writeJson(resp, "{\"success\":false,\"message\":\"Không tìm thấy Master SKU.\"}");
                    return;
                }
                List<com.wms.model.ProductImage> images = new ProductImageDAO().findByProductId(productId);
                List<String> imageUrls = new java.util.ArrayList<>();
                for (com.wms.model.ProductImage img : images) {
                    if (img.getImageUrl() != null && !img.getImageUrl().isBlank()) {
                        imageUrls.add(img.getImageUrl());
                    }
                }
                Map<String, Object> result = new java.util.HashMap<>();
                result.put("success", true);
                result.put("productId", productId);
                result.put("description", p.getShortDescription() != null ? p.getShortDescription() : "");
                result.put("images", imageUrls);
                writeJson(resp, JsonUtil.toJson(result));
            } catch (Exception e) {
                writeJson(resp, "{\"success\":false,\"message\":\"" + esc(e.getMessage()) + "\"}");
            }
        } else if ("delete".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                com.wms.model.ChannelProduct cp = new com.wms.dao.ChannelProductDAO().findById(id);
                if (cp == null) {
                    writeJson(resp, "{\"success\":false,\"message\":\"Sản phẩm kênh không tồn tại.\"}");
                    return;
                }
                Channel ch = new ChannelDAO().findById(cp.getChannelId());
                if (ch == null) {
                    writeJson(resp, "{\"success\":false,\"message\":\"Không tìm thấy kênh cấu hình.\"}");
                    return;
                }
                LazadaProductService.DeleteResult r = new LazadaProductService().deleteProduct(ch, id);
                if (r.success) {
                    writeJson(resp, "{\"success\":true,\"message\":\"" + esc(r.message) + "\"}");
                } else {
                    writeJson(resp, "{\"success\":false,\"message\":\"Xóa thất bại: " + esc(r.message) + "\"}");
                }
            } catch (Exception e) {
                LOGGER.log(java.util.logging.Level.WARNING, "channel-products delete failed", e);
                writeJson(resp, "{\"success\":false,\"message\":\"Lỗi: " + esc(e.getMessage()) + "\"}");
            }
        } else if ("edit".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                BigDecimal price = new BigDecimal(req.getParameter("price"));
                String description = req.getParameter("description");

                com.wms.model.ChannelProduct cp = new com.wms.dao.ChannelProductDAO().findById(id);
                if (cp == null) {
                    writeJson(resp, "{\"success\":false,\"message\":\"Sản phẩm kênh không tồn tại.\"}");
                    return;
                }
                Channel ch = new ChannelDAO().findById(cp.getChannelId());
                if (ch == null) {
                    writeJson(resp, "{\"success\":false,\"message\":\"Không tìm thấy kênh cấu hình.\"}");
                    return;
                }

                // Collect image URLs & base64 strings
                List<String> imageUrls = new java.util.ArrayList<>();
                List<String> imageBase64s = new java.util.ArrayList<>();
                String imageUrlsParam = req.getParameter("imageUrls");
                String imageBase64sParam = req.getParameter("imageBase64s");

                if (imageUrlsParam != null && !imageUrlsParam.isBlank()) {
                    String[] urlParts = imageUrlsParam.split("\\|");
                    String[] b64Parts = (imageBase64sParam != null && !imageBase64sParam.isBlank())
                            ? imageBase64sParam.split("\\|") : new String[0];
                    for (int i = 0; i < urlParts.length; i++) {
                        String trimmed = urlParts[i].trim();
                        if (!trimmed.isEmpty()) {
                            String absolute = toAbsoluteUrl(req, trimmed);
                            imageUrls.add(absolute);
                            String b64 = (i < b64Parts.length) ? b64Parts[i].trim() : null;
                            imageBase64s.add((b64 != null && !b64.isEmpty()) ? b64 : null);
                        }
                    }
                }

                PushResult r = new LazadaProductService().updateProduct(
                        ch, id, price, description, imageUrls, imageBase64s);
                writeJson(resp, renderPushResultJson(r));
            } catch (NumberFormatException e) {
                writeJson(resp, "{\"success\":false,\"message\":\"Định dạng số hoặc giá bán không hợp lệ.\"}");
            } catch (Exception e) {
                LOGGER.log(java.util.logging.Level.WARNING, "channel-products edit failed", e);
                writeJson(resp, "{\"success\":false,\"message\":\"Lỗi: " + esc(e.getMessage()) + "\"}");
            }
        } else if ("loadLazadaLeaves".equals(action)) {
            // GET — return cached leaves from lazada_categories (UC-B2C09)
            try {
                int channelId = Integer.parseInt(req.getParameter("channelId"));
                var leaves = new com.wms.dao.LazadaCategoryDAO().findLeaves(channelId);
                StringBuilder json = new StringBuilder("{\"success\":true,\"leaves\":[");
                for (int i = 0; i < leaves.size(); i++) {
                    var c = leaves.get(i);
                    if (i > 0) json.append(",");
                    json.append("{\"lazadaCategoryId\":").append(c.getLazadaCategoryId())
                        .append(",\"name\":\"").append(esc(c.getName())).append("\"}");
                }
                json.append("],\"total\":").append(leaves.size()).append("}");
                writeJson(resp, json.toString());
            } catch (Exception e) {
                LOGGER.log(java.util.logging.Level.WARNING, "loadLazadaLeaves failed", e);
                writeJson(resp, "{\"success\":false,\"message\":\"" + esc(e.getMessage()) + "\"}");
            }
        } else if ("uploadImageBase64".equals(action)) {
            // UC-B2C09: wizard uploads a base64 image, we save it to disk and
            // return the public server URL. This bypasses Lazada's E302 error
            // when /image/migrate receives data:image URIs directly.
            try {
                String base64Data = req.getParameter("base64");
                String filename = req.getParameter("filename");
                if (base64Data == null || base64Data.isBlank()) {
                    writeJson(resp, "{\"success\":false,\"message\":\"No base64 data\"}");
                    return;
                }
                // Strip data:image/...;base64, prefix if present
                String b64 = base64Data;
                int commaIdx = b64.indexOf(',');
                if (commaIdx >= 0) b64 = b64.substring(commaIdx + 1);
                byte[] imageBytes = Base64.getDecoder().decode(b64);

                // Determine extension from optional filename hint
                String ext = ".jpg";
                if (filename != null && !filename.isBlank()) {
                    String lower = filename.toLowerCase();
                    if (lower.endsWith(".png")) ext = ".png";
                    else if (lower.endsWith(".webp")) ext = ".webp";
                    else if (lower.endsWith(".gif")) ext = ".gif";
                }
                String name = UUID.randomUUID().toString().replace("-", "") + ext;
                Path uploadRoot = Paths.get(
                        System.getProperty("user.home"), "wms-uploads", "publish-images");
                Files.createDirectories(uploadRoot);
                Path target = uploadRoot.resolve(name);
                Files.write(target, imageBytes);
                String publicUrl = req.getContextPath() + "/publish-images/" + name;
                LOGGER.info("uploadImageBase64: saved " + target + " size=" + imageBytes.length);
                writeJson(resp, "{\"success\":true,\"url\":\"" + publicUrl + "\"}");
            } catch (java.lang.IllegalArgumentException e) {
                writeJson(resp, "{\"success\":false,\"message\":\"Invalid base64 data: " + esc(e.getMessage()) + "\"}");
            } catch (Exception e) {
                LOGGER.log(java.util.logging.Level.WARNING, "uploadImageBase64 failed", e);
                writeJson(resp, "{\"success\":false,\"message\":\"" + esc(e.getMessage()) + "\"}");
            }
        } else if ("getCategoryMapping".equals(action)) {
            // GET — find Lazada leaf mapped to a WMS category (UC-B2C09)
            try {
                int channelId = Integer.parseInt(req.getParameter("channelId"));
                int wmsCategoryId = Integer.parseInt(req.getParameter("wmsCategoryId"));
                var mappings = new com.wms.dao.CategoryMappingDAO().findPrimaryForWms(channelId, wmsCategoryId);
                if (mappings.isEmpty()) {
                    writeJson(resp, "{\"success\":true,\"found\":false,\"mappings\":[]}");
                    return;
                }
                StringBuilder json = new StringBuilder("{\"success\":true,\"found\":true,\"mappings\":[");
                for (int i = 0; i < mappings.size(); i++) {
                    var m = mappings.get(i);
                    if (i > 0) json.append(",");
                    json.append("{\"lazadaCategoryId\":").append(m.getLazadaCategoryId())
                        .append(",\"name\":\"").append(esc(m.getLazadaName())).append("\"}");
                }
                json.append("]}");
                writeJson(resp, json.toString());
            } catch (NumberFormatException e) {
                writeJson(resp, "{\"success\":false,\"message\":\"Invalid channelId or wmsCategoryId\"}");
            } catch (Exception e) {
                LOGGER.log(java.util.logging.Level.WARNING, "getCategoryMapping failed", e);
                writeJson(resp, "{\"success\":false,\"message\":\"" + esc(e.getMessage()) + "\"}");
            }
        } else if ("syncLazadaCategories".equals(action)) {
            // POST — pull /category/tree/get and store leaves (UC-B2C09)
            try {
                int channelId = Integer.parseInt(req.getParameter("channelId"));
                Channel ch = new ChannelDAO().findById(channelId);
                if (ch == null) {
                    writeJson(resp, "{\"success\":false,\"message\":\"Channel not found\"}");
                    return;
                }
                com.wms.service.lazada.LazadaCategorySyncService svc = new com.wms.service.lazada.LazadaCategorySyncService();
                com.wms.service.lazada.LazadaCategorySyncService.SyncResult r = svc.syncCategories(ch);
                writeJson(resp, "{\"success\":" + r.success
                        + ",\"count\":" + r.count
                        + ",\"message\":\"" + esc(r.message) + "\"}");
            } catch (Exception e) {
                LOGGER.log(java.util.logging.Level.WARNING, "syncLazadaCategories failed", e);
                writeJson(resp, "{\"success\":false,\"message\":\"" + esc(e.getMessage()) + "\"}");
            }
        } else if ("debugPush".equals(action)) {
            // TEMP: bypass wizard, call pushProduct directly, return raw Lazada response
            try {
                int channelId = Integer.parseInt(req.getParameter("channelId"));
                int productId = Integer.parseInt(req.getParameter("productId"));
                Channel ch = new ChannelDAO().findById(channelId);
                if (ch == null) {
                    writeJson(resp, "{\"success\":false,\"message\":\"Channel not found\"}");
                    return;
                }
                LOGGER.info("=== DEBUG PUSH START channel=" + channelId + " product=" + productId + " ===");
                PushResult r = new LazadaProductService().pushProduct(ch, productId);
                LOGGER.info("=== DEBUG PUSH END success=" + r.success + " code=" + r.code
                        + " msg=" + r.message + " ===");
                writeJson(resp, renderPushResultJson(r));
            } catch (Exception e) {
                LOGGER.log(java.util.logging.Level.SEVERE, "debugPush failed", e);
                writeJson(resp, "{\"success\":false,\"message\":\"" + esc(e.toString()) + "\"}");
            }
        } else {
            writeJson(resp, "{\"success\":false,\"message\":\"Unknown action\"}");
        }
    }

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", " ").replace("\r", " ");
    }

    /** Converts a relative URL (e.g. /publish-images/uuid.jpg) to an absolute one
     *  (e.g. http://localhost:8080/publish-images/uuid.jpg) using the request. */
    private static String toAbsoluteUrl(HttpServletRequest req, String url) {
        if (url == null || url.isBlank()) return url;
        if (url.startsWith("http://") || url.startsWith("https://")) return url;
        String scheme = req.getScheme();
        String host = req.getServerName();
        int port = req.getServerPort();
        String base = scheme + "://" + host + (port == 80 || port == 443 ? "" : ":" + port);
        String contextPath = req.getContextPath();
        if (url.startsWith("/")) {
            if (contextPath != null && !contextPath.isEmpty() && !"/".equals(contextPath) && url.startsWith(contextPath)) {
                return base + url;
            }
            return base + contextPath + url;
        }
        return base + contextPath + "/" + url;
    }

    /** Serializes a {@link PushResult} to JSON, including validation + field errors. */
    private static String renderPushResultJson(PushResult r) {
        StringBuilder sb = new StringBuilder(256);
        sb.append("{\"success\":").append(r.success)
          .append(",\"code\":\"").append(esc(r.code)).append("\"")
          .append(",\"message\":\"").append(esc(r.message)).append("\"")
          .append(",\"itemId\":\"").append(esc(r.itemId == null ? "" : r.itemId)).append("\"")
          .append(",\"skuId\":\"").append(esc(r.skuId == null ? "" : r.skuId)).append("\"");
        if (r.validationErrors != null && !r.validationErrors.isEmpty()) {
            sb.append(",\"validationErrors\":[");
            for (int i = 0; i < r.validationErrors.size(); i++) {
                if (i > 0) sb.append(",");
                var ve = r.validationErrors.get(i);
                sb.append("{\"field\":\"").append(esc(ve.field)).append("\"")
                  .append(",\"code\":\"").append(esc(ve.code)).append("\"")
                  .append(",\"message\":\"").append(esc(ve.viMessage)).append("\"}");
            }
            sb.append("]");
        }
        if (r.fieldErrors != null && !r.fieldErrors.isEmpty()) {
            sb.append(",\"fieldErrors\":[");
            for (int i = 0; i < r.fieldErrors.size(); i++) {
                if (i > 0) sb.append(",");
                var fe = r.fieldErrors.get(i);
                sb.append("{\"field\":\"").append(esc(fe.fieldHint == null ? fe.field : fe.fieldHint)).append("\"")
                  .append(",\"message\":\"").append(esc(fe.viMessage)).append("\"}");
            }
            sb.append("]");
        }
        sb.append("}");
        return sb.toString();
    }
}
