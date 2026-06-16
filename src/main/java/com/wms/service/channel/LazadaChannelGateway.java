package com.wms.service.channel;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.model.Channel;
import com.wms.service.lazada.LazadaHttpClient;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * LazadaChannelGateway — Lazada implementation of {@link ChannelGateway}.
 * All actual HTTP work is delegated to {@link LazadaHttpClient}; this
 * class only builds the per-endpoint parameter payload.
 *
 * <p>NOTE: Lazada's public API requires certain params (e.g. item_id for
 * update, order_item_id list for pack) that vary by endpoint. We only
 * pass the data the caller supplied; if Lazada returns an error, the
 * caller maps it to a user-facing message.
 */
public class LazadaChannelGateway implements ChannelGateway {

    private final LazadaHttpClient http = new LazadaHttpClient();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    public String platformName() {
        return "Lazada";
    }

    // ── Catalog ──────────────────────────────────────────────

    @Override
    public String listProducts(Channel channel, int pageNumber, int pageSize) {
        Map<String, String> params = new HashMap<>();
        params.put("filter", "all");
        params.put("page_no", String.valueOf(Math.max(pageNumber, 1)));
        params.put("page_size", String.valueOf(Math.max(1, Math.min(pageSize, 50))));
        return http.executeGet("/products/get", params, channel);
    }

    @Override
    public String createProduct(Channel channel, Map<String, String> payload) {
        return http.executePost("/product/create", payload, channel);
    }

    @Override
    public String updateProduct(Channel channel, String channelItemId,
                                Map<String, String> payload) {
        Map<String, String> params = new HashMap<>(payload);
        params.put("item_id", channelItemId);
        return http.executePost("/product/update", params, channel);
    }

    // ── Stock & Price ────────────────────────────────────────

    @Override
    public String updateProductStock(Channel channel, String sellerSku, int qty) {
        Map<String, String> params = new HashMap<>();
        params.put("seller_sku", sellerSku);
        params.put("qty", String.valueOf(Math.max(qty, 0)));
        return http.executePost("/product/stock/sellable/update", params, channel);
    }

    @Override
    public String updateProductStockBatch(Channel channel, List<StockUpdate> updates) {
        // Lazada's batch endpoint expects a JSON body. We assemble it
        // as a serialized string and POST it. Lazada's sign is still
        // over the form params, not the JSON body.
        try {
            List<Map<String, Object>> items = updates.stream()
                    .map(u -> {
                        Map<String, Object> m = new HashMap<>();
                        m.put("seller_sku", u.sellerSku);
                        m.put("qty", Math.max(u.qty, 0));
                        return m;
                    })
                    .collect(Collectors.toList());
            Map<String, Object> body = new HashMap<>();
            body.put("products", items);
            String json = mapper.writeValueAsString(body);

            Map<String, String> params = new HashMap<>();
            params.put("payload", json);
            return http.executePost("/product/stock/sellable/batch/update",
                    params, channel);
        } catch (Exception e) {
            throw new RuntimeException("Failed to serialize stock batch", e);
        }
    }

    // ── Orders ───────────────────────────────────────────────

    @Override
    public String listOrders(Channel channel, String status, Long updatedAfterEpochSec) {
        Map<String, String> params = new HashMap<>();
        if (status != null && !status.isEmpty()) {
            params.put("status", status);
        }
        if (updatedAfterEpochSec != null) {
            params.put("updated_after", String.valueOf(updatedAfterEpochSec));
        }
        params.put("sort_direction", "DESC");
        params.put("limit", "100");
        return http.executeGet("/orders/get", params, channel);
    }

    @Override
    public String getOrder(Channel channel, String orderId) {
        Map<String, String> params = new HashMap<>();
        params.put("order_id", orderId);
        return http.executeGet("/order/get", params, channel);
    }

    @Override
    public String getOrderItems(Channel channel, String orderId) {
        Map<String, String> params = new HashMap<>();
        params.put("order_id", orderId);
        return http.executeGet("/order/items/get", params, channel);
    }

    // ── Fulfillment ──────────────────────────────────────────

    @Override
    public String packOrder(Channel channel, String orderId, String deliveryType) {
        Map<String, String> params = new HashMap<>();
        params.put("order_id", orderId);
        params.put("delivery_type", (deliveryType == null || deliveryType.isEmpty())
                ? "dropship" : deliveryType);
        params.put("order_item_list", "[]");
        // The caller is expected to override order_item_list with a JSON string
        // of order_item_ids before calling. If it didn't, Lazada will return
        // an error that the higher-level service surfaces to the user.
        return http.executePost("/order/fulfill/pack", params, channel);
    }

    /**
     * Variant of {@link #packOrder} that lets the caller pass a fully
     * pre-built parameter map (including the {@code order_item_list} JSON
     * array of order_item_ids that Lazada requires).
     */
    public String packOrderWithParams(Channel channel, Map<String, String> params) {
        return http.executePost("/order/fulfill/pack", params, channel);
    }

    @Override
    public String getShippingLabel(Channel channel, String packageId) {
        Map<String, String> params = new HashMap<>();
        params.put("package_id", packageId);
        params.put("doc_type", "shippingLabel");
        return http.executeGet("/order/package/document/get", params, channel);
    }

    @Override
    public String readyToShip(Channel channel, String packageId) {
        Map<String, String> params = new HashMap<>();
        params.put("package_id", packageId);
        return http.executePost("/order/package/rts", params, channel);
    }

    // ── Tracking ─────────────────────────────────────────────

    @Override
    public String getTrackingTrace(Channel channel, String orderNumber) {
        Map<String, String> params = new HashMap<>();
        params.put("order_id", orderNumber);
        return http.executeGet("/logistic/order/trace", params, channel);
    }

    // ── RMA / Reverse ────────────────────────────────────────

    @Override
    public String listReverseOrders(Channel channel, Long createdAfterEpochSec) {
        Map<String, String> params = new HashMap<>();
        if (createdAfterEpochSec != null) {
            params.put("created_after", String.valueOf(createdAfterEpochSec));
        }
        params.put("limit", "50");
        return http.executeGet("/reverse/getreverseordersforseller", params, channel);
    }

    @Override
    public String updateReverseOrder(Channel channel, String reverseOrderId, String action,
                                     Map<String, String> payload) {
        Map<String, String> params = new HashMap<>();
        if (payload != null) params.putAll(payload);
        params.put("reverse_order_id", reverseOrderId);
        params.put("action", action);
        return http.executePost("/order/reverse/return/update", params, channel);
    }
}
