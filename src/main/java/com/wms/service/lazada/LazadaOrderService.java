package com.wms.service.lazada;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.model.Channel;
import com.wms.util.AppConstants;

import java.util.TreeMap;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LazadaOrderService — Lazada Open Platform order operations.
 *
 * All HTTP calls are routed through {@link LazadaHttpClient}, which handles
 * HMAC-SHA256 signing, GET/POST, and automatic access-token refresh.
 *
 * Lazada endpoints used:
 *   GET  /orders/get           — list orders by status / updated_after
 *   GET  /order/get            — single order with shipping & payment detail
 *   GET  /order/items/get      — line items for an order
 */
public class LazadaOrderService {

    private static final Logger LOGGER = Logger.getLogger(LazadaOrderService.class.getName());

    private final LazadaHttpClient http = new LazadaHttpClient();
    private final ObjectMapper mapper = new ObjectMapper();

    // ── ORDER LISTING ───────────────────────────────────────────

    /**
     * Fetches pending orders from Lazada.
     */
    public String getPendingOrders(Channel channel) {
        return getOrders(channel, "pending", null, null);
    }

    /**
     * Fetches orders updated after a given timestamp (for incremental sync).
     *
     * @param channel       Channel credentials
     * @param updatedAfter  Unix timestamp in milliseconds; pass null to skip filter
     * @param status        Lazada status filter ("pending", "ready_to_ship", etc.)
     *                      pass null for "all" updated orders
     */
    public String getOrdersUpdatedAfter(Channel channel, Long updatedAfter, String status) {
        return getOrders(channel, status, updatedAfter, null);
    }

    /**
     * Fetches orders created in a given Lazada status, with optional filters.
     *
     * @param createdAfter  Unix timestamp ms
     * @param updatedAfter  Unix timestamp ms
     */
    public String getOrders(Channel channel, String status, Long createdAfter, Long updatedAfter) {
        TreeMap<String, String> params = new TreeMap<>();
        if (status != null && !status.isEmpty()) {
            params.put("status", status);
        }
        if (createdAfter != null) {
            params.put("created_after", String.valueOf(createdAfter));
        }
        if (updatedAfter != null) {
            params.put("updated_after", String.valueOf(updatedAfter));
        }
        params.put("sort_direction", "DESC");
        params.put("limit", "100");
        return http.executeGet("/orders/get", params, channel);
    }

    // ── ORDER DETAIL ────────────────────────────────────────────

    /**
     * Fetches a single order with full shipping & payment detail.
     *
     * Lazada /order/get response includes:
     *   - order_id, order_number, status, created_at, updated_at
     *   - shipping_fee, voucher_amount, payment_method, gift_option
     *   - address_shipping: recipient name, phone, address1/2, city, postcode
     *   - shipping_provider, shipping_speed
     *   - order_items (nested in many Lazada regions)
     *
     * @return Raw JSON response, or null on transport error
     */
    public String getOrderDetail(Channel channel, String orderId) {
        if (orderId == null || orderId.isBlank()) {
            throw new IllegalArgumentException("orderId must not be null or empty");
        }
        TreeMap<String, String> params = new TreeMap<>();
        params.put("order_id", orderId);
        return http.executeGet("/order/get", params, channel);
    }

    /**
     * Fetches the line items of a Lazada order.
     */
    public String getOrderItems(Channel channel, String orderId) {
        if (orderId == null || orderId.isBlank()) {
            throw new IllegalArgumentException("orderId must not be null or empty");
        }
        TreeMap<String, String> params = new TreeMap<>();
        params.put("order_id", orderId);
        return http.executeGet("/order/items/get", params, channel);
    }

    /**
     * Convenience helper that returns the parsed root JsonNode of an order
     * detail response, or null if the response is empty / invalid.
     */
    public JsonNode getOrderDetailJson(Channel channel, String orderId) {
        String body = getOrderDetail(channel, orderId);
        try {
            return mapper.readTree(body);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "getOrderDetailJson: invalid JSON for order " + orderId, e);
            return null;
        }
    }

    // ── STATUS MAPPING ──────────────────────────────────────────

    /**
     * Maps a Lazada order status string to the WMS internal status.
     */
    public String mapLazadaStatus(String lazadaStatus) {
        if (lazadaStatus == null || lazadaStatus.isEmpty()) {
            return "PENDING";
        }
        switch (lazadaStatus.toLowerCase()) {
            case "pending":
            case "unpaid":
                return "PENDING";
            case "ready_to_ship":
            case "confirmed":
                return "PACKED";
            case "shipped":
            case "picked_up":
            case "in_transit":
                return "SHIPPED";
            case "delivered":
            case "completed":
                return "DELIVERED";
            case "canceled":
            case "cancelled":
                return "CANCELLED";
            case "returned":
                return "RETURNED";
            default:
                return "PENDING";
        }
    }

    /**
     * Extracts the most relevant status from a Lazada order node.
     * Lazada returns statuses as an array in newer API versions.
     */
    public String extractStatus(JsonNode orderNode) {
        JsonNode statuses = orderNode.path("statuses");
        if (statuses.isArray() && statuses.size() > 0) {
            return statuses.get(0).asText();
        }
        return orderNode.path("status").asText("pending");
    }

    // ── CLI (kept for legacy / smoke-testing) ───────────────────

    public static void main(String[] args) {
        if (args.length < 4) {
            System.out.println("Usage: java LazadaOrderService <apiUrl> <appKey> <appSecret> <accessToken>");
            return;
        }
        Channel channel = new Channel();
        channel.setApiUrl(args[0]);
        channel.setApiKey(args[1]);
        channel.setAppSecret(args[2]);
        channel.setAccessToken(args[3]);

        LazadaOrderService service = new LazadaOrderService();
        try {
            String responseBody = service.getPendingOrders(channel);
            LOGGER.info("Fetched " + (responseBody != null ? responseBody.length() : 0)
                    + " bytes from Lazada API");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "LazadaOrderService: API call failed", e);
        }
    }
}
