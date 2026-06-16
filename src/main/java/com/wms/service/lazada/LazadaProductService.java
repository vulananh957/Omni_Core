package com.wms.service.lazada;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.dao.ChannelProductDAO;
import com.wms.dao.ProductDAO;
import com.wms.model.Channel;
import com.wms.model.ChannelProduct;
import com.wms.model.Product;
import com.wms.service.channel.ChannelRegistry;
import com.wms.service.channel.ChannelSyncAudit;
import com.wms.service.channel.ChannelGateway;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LazadaProductService — UC-B2C01 (Pull & Map) and UC-B2C02 (Push).
 *
 * Two main operations:
 *  - pullProducts(): GET /products/get, then upsert into channel_products
 *    and log unmapped SKUs to mapping_exceptions.
 *  - pushProduct():  POST /product/create for a new SKU.
 *
 * Higher-level code (LazadaProductSyncScheduler, SalesChannelProductsServlet)
 * calls these methods. The scheduler invokes pullProducts() on a cron;
 * the servlet uses pushProduct() from the UI form.
 */
public class LazadaProductService {

    private static final Logger LOGGER = Logger.getLogger(LazadaProductService.class.getName());
    private static final ObjectMapper MAPPER = new ObjectMapper();

    private final ChannelGateway gateway;
    private final ChannelProductDAO channelProductDAO = new ChannelProductDAO();
    private final ProductDAO productDAO = new ProductDAO();

    public LazadaProductService() {
        this.gateway = ChannelRegistry.get("Lazada");
        if (this.gateway == null) {
            throw new IllegalStateException(
                    "No ChannelGateway registered for platform 'Lazada'");
        }
    }

    // ── Pull & Map (UC-B2C01) ─────────────────────────────────

    /**
     * Pulls Lazada's product list and upserts every item into channel_products.
     * Lazada items whose seller_sku matches a known product.sku_code get the
     * mapping; everything else is left in PENDING and the seller_sku is logged
     * to mapping_exceptions so Sales can resolve it from the UI.
     *
     * @param channel the Lazada channel
     * @return sync summary
     */
    public PullResult pullProducts(Channel channel) {
        int pageNumber = 1;
        final int pageSize = 50;
        int totalPulled = 0;
        int totalUpserted = 0;
        int totalUnmapped = 0;
        String lastError = null;
        boolean ok = true;

        for (int page = 0; page < 20; page++) { // hard-cap at 20 pages = 1000 products
            long t0 = System.currentTimeMillis();
            String response = null;
            try {
                response = gateway.listProducts(channel, pageNumber, pageSize);
            } catch (Exception e) {
                lastError = e.getMessage();
                ok = false;
                ChannelSyncAudit.logFailure(channel.getChannelId(),
                        "PRODUCT_PULL", "page=" + pageNumber, null, null, lastError);
                break;
            }
            long dt = System.currentTimeMillis() - t0;
            ChannelSyncAudit.logSuccess(channel.getChannelId(), "PRODUCT_PULL",
                    "page=" + pageNumber, 200, null, response, dt);

            JsonNode root;
            try {
                root = MAPPER.readTree(response);
            } catch (Exception e) {
                lastError = "Invalid JSON from /products/get: " + e.getMessage();
                ok = false;
                break;
            }
            JsonNode data = root.path("data");
            JsonNode products = data.path("products");
            if (!products.isArray() || products.isEmpty()) {
                break;
            }
            int pageCount = products.size();
            totalPulled += pageCount;

            for (JsonNode product : products) {
                UpsertOutcome o = upsertOne(product, channel);
                if (o.upserted) totalUpserted++;
                if (o.unmapped)  totalUnmapped++;
            }
            // Lazada's response doesn't always include "total" or "has_next";
            // we use a conservative heuristic: if the page is short, stop.
            if (pageCount < pageSize) break;
            pageNumber++;
        }
        return new PullResult(ok, totalPulled, totalUpserted, totalUnmapped, lastError);
    }

    /** Upserts a single Lazada product into channel_products. */
    private UpsertOutcome upsertOne(JsonNode product, Channel channel) {
        String sellerSku = product.path("seller_sku").asText("").trim();
        String itemId    = product.path("item_id").asText("").trim();
        if (sellerSku.isEmpty() && itemId.isEmpty()) {
            return new UpsertOutcome(false, false);
        }
        if (sellerSku.isEmpty()) sellerSku = itemId;

        // Try to match seller_sku -> product.sku_code (master SKU on our side)
        Product matched = productDAO.findBySkuCode(sellerSku);
        if (matched == null) {
            // No match — log exception so Sales sees it on the mapping page
            new com.wms.dao.SkuMappingDAO().logMappingException(
                    channel.getChannelId(), sellerSku, null,
                    "Lazada product pulled but no master SKU match for seller_sku="
                            + sellerSku);
            return new UpsertOutcome(false, true);
        }

        BigDecimal price = new BigDecimal(
                product.path("price").asText(product.path("special_price").asText("0")));
        BigDecimal stock = new BigDecimal(
                product.path("quantity").asText(product.path("stock").asText("0")));
        if (stock.signum() < 0) stock = BigDecimal.ZERO;

        ChannelProduct existing = channelProductDAO.findByChannelSku(
                channel.getChannelId(), sellerSku);

        if (existing == null) {
            // Look up by product_id+channel (the UNIQUE KEY) in case channel_sku_code
            // was empty but the product is already there.
            existing = channelProductDAO.findByProductAndChannel(
                    matched.getProductId(), channel.getChannelId());
        }

        if (existing == null) {
            ChannelProduct cp = new ChannelProduct();
            cp.setChannelId(channel.getChannelId());
            cp.setProductId(matched.getProductId());
            cp.setChannelSkuCode(sellerSku);
            cp.setChannelPrice(price);
            cp.setChannelStock(stock);
            cp.setStatus("ACTIVE");
            cp.setListedAt(java.time.LocalDateTime.now());
            boolean inserted = channelProductDAO.insert(cp);
            if (inserted) {
                // Persist Lazada item_id so /product/update can target it later
                ChannelProduct fresh = channelProductDAO.findByChannelSku(
                        channel.getChannelId(), sellerSku);
                if (fresh != null) {
                    channelProductDAO.setChannelItemId(
                            fresh.getId(), itemId.isEmpty() ? null : itemId, sellerSku);
                }
            }
            return new UpsertOutcome(inserted, false);
        } else {
            // Update price + stock only; don't touch status / listed_at
            channelProductDAO.syncPrice(existing.getId(), price);
            channelProductDAO.syncStock(existing.getId(), stock);
            channelProductDAO.setChannelItemId(existing.getId(),
                    itemId.isEmpty() ? null : itemId, sellerSku);
            return new UpsertOutcome(true, false);
        }
    }

    // ── Push (UC-B2C02) ───────────────────────────────────────

    /**
     * Pushes a new product from WMS to Lazada. Lazada returns a
     * {@code data.item_id} which we persist so future updates know
     * which item to call.
     *
     * @return PushResult with item_id and any error code Lazada returned
     */
    public PushResult pushProduct(Channel channel, int productId) {
        Product p = productDAO.findById(productId);
        if (p == null) {
            return PushResult.failure("NOT_FOUND", "Product not found: " + productId);
        }
        if (p.getSkuCode() == null || p.getSkuCode().trim().isEmpty()) {
            return PushResult.failure("INVALID", "Master SKU is empty");
        }

        Map<String, String> payload = new HashMap<>();
        payload.put("seller_sku", p.getSkuCode());
        payload.put("name", p.getProductName());
        // Product has no base_price field in this domain model; Lazada accepts
        // price = 0 and Sales can update from the channel-products page.
        payload.put("price", "0");
        payload.put("quantity", "0");
        payload.put("description", p.getProductName());
        payload.put("category_id", (p.getCategoryId() != null && p.getCategoryId() > 0)
                ? String.valueOf(p.getCategoryId()) : "0");

        long t0 = System.currentTimeMillis();
        String response;
        try {
            response = gateway.createProduct(channel, payload);
        } catch (Exception e) {
            ChannelSyncAudit.logFailure(channel.getChannelId(),
                    "PRODUCT_PUSH", p.getSkuCode(), null, payload.toString(), e.getMessage());
            return PushResult.failure("TRANSPORT", e.getMessage());
        }
        long dt = System.currentTimeMillis() - t0;
        ChannelSyncAudit.logSuccess(channel.getChannelId(),
                "PRODUCT_PUSH", p.getSkuCode(), 200, payload.toString(), response, dt);

        try {
            JsonNode root = MAPPER.readTree(response);
            String code = root.path("code").asText("0");
            if (!"0".equals(code) && !"Success".equalsIgnoreCase(code)) {
                String msg = root.path("message").asText("Lazada rejected the product");
                return PushResult.failure(code, msg);
            }
            String itemId = root.path("data").path("item_id").asText("");
            if (!itemId.isEmpty()) {
                // Persist mapping so future updates target this item_id
                ChannelProduct existing = channelProductDAO.findByProductAndChannel(
                        productId, channel.getChannelId());
                if (existing == null) {
                    ChannelProduct cp = new ChannelProduct();
                    cp.setChannelId(channel.getChannelId());
                    cp.setProductId(productId);
                    cp.setChannelSkuCode(p.getSkuCode());
                    cp.setChannelPrice(BigDecimal.ZERO);
                    cp.setChannelStock(BigDecimal.ZERO);
                    cp.setStatus("ACTIVE");
                    cp.setListedAt(java.time.LocalDateTime.now());
                    channelProductDAO.insert(cp);
                    existing = channelProductDAO.findByProductAndChannel(
                            productId, channel.getChannelId());
                }
                if (existing != null) {
                    channelProductDAO.setChannelItemId(existing.getId(), itemId, p.getSkuCode());
                }
            }
            return PushResult.success(itemId);
        } catch (Exception e) {
            return PushResult.failure("PARSE", "Lazada returned non-JSON: " + e.getMessage());
        }
    }

    // ── DTOs ──────────────────────────────────────────────────

    public static final class PullResult {
        public final boolean ok;
        public final int pulled;
        public final int upserted;
        public final int unmapped;
        public final String error;
        public PullResult(boolean ok, int pulled, int upserted, int unmapped, String error) {
            this.ok = ok; this.pulled = pulled;
            this.upserted = upserted; this.unmapped = unmapped;
            this.error = error;
        }
    }

    public static final class PushResult {
        public final boolean success;
        public final String code;        // "0" on success, otherwise Lazada error code
        public final String message;     // user-friendly message
        public final String itemId;      // Lazada item_id on success
        private PushResult(boolean s, String c, String m, String itemId) {
            this.success = s; this.code = c; this.message = m; this.itemId = itemId;
        }
        public static PushResult success(String itemId) {
            return new PushResult(true, "0", "Pushed successfully", itemId);
        }
        public static PushResult failure(String code, String message) {
            return new PushResult(false, code, message, null);
        }
    }

    private static final class UpsertOutcome {
        final boolean upserted;
        final boolean unmapped;
        UpsertOutcome(boolean u, boolean um) { this.upserted = u; this.unmapped = um; }
    }
}
