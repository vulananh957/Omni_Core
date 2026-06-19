package com.wms.service.lazada;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.dao.ChannelDAO;
import com.wms.dao.InventoryDAO;
import com.wms.dao.OrderDAO;
import com.wms.model.Channel;
import com.wms.model.Order;
import com.wms.model.OrderItem;
import com.wms.service.channel.ChannelGateway;
import com.wms.service.channel.ChannelRegistry;
import com.wms.service.channel.ChannelSyncAudit;
import com.wms.service.channel.LazadaChannelGateway;

import java.math.BigDecimal;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LazadaShipmentService — Lazada fulfillment workflow (UC-B2C04, UC-B2C06).
 *
 * Two-call pipeline triggered when Sales clicks "Generate tracking"
 * on a Lazada order:
 *   1. packAndAllocate(): POST /order/fulfill/pack — Lazada allocates a
 *      package_id + tracking_number. We persist the tracking_no on the
 *      order row and mark is_pack_requested=1.
 *   2. getShippingLabel(): GET /order/package/document/get — Lazada returns
 *      a Base64 PDF. We decode it to a byte[] the servlet streams back
 *      for the browser to print.
 *
 * {@link #readyToShip(Order)} is a separate call (UC-B2C06) invoked from
 * the warehouse "Ready To Ship" button after the box is sealed.
 */
public class LazadaShipmentService {

    private static final Logger LOGGER = Logger.getLogger(LazadaShipmentService.class.getName());
    private static final ObjectMapper MAPPER = new ObjectMapper();

    private final ChannelGateway gateway;
    private final ChannelDAO channelDAO = new ChannelDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final InventoryDAO inventoryDAO = new InventoryDAO();

    public LazadaShipmentService() {
        this.gateway = ChannelRegistry.get("Lazada");
    }

    /** Lazada-allocated waybill for an order. */
    public static final class ShipmentResult {
        public final boolean success;
        public final String trackingNo;
        public final String packageId;
        public final String errorMessage;
        private ShipmentResult(boolean s, String tracking, String pkg, String err) {
            this.success = s; this.trackingNo = tracking;
            this.packageId = pkg; this.errorMessage = err;
        }
        public static ShipmentResult ok(String tracking, String pkg) {
            return new ShipmentResult(true, tracking, pkg, null);
        }
        public static ShipmentResult fail(String error) {
            return new ShipmentResult(false, null, null, error);
        }
    }

    /**
     * Calls Lazada pack API. Lazada returns package_id and tracking_number
     * which we persist to the local order row.
     */
    public ShipmentResult packAndAllocate(Order order) {
        Channel ch = resolveChannel(order);
        if (ch == null) {
            return ShipmentResult.fail("Channel not found for order " + order.getOrderCode());
        }
        // Lazada requires order_item_id list. We pull it from the
        // getOrderItems call. If we have no items, fall back to an
        // empty list — Lazada will reject, but the error is useful.
        String itemsJson = "[]";
        try {
            String body = gateway.getOrderItems(ch, order.getOrderCode());
            JsonNode root = MAPPER.readTree(body);
            JsonNode data = root.path("data");
            JsonNode items = data.isArray() ? data : data.path("order_items");
            if (items.isArray() && items.size() > 0) {
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < items.size(); i++) {
                    if (i > 0) sb.append(',');
                    String oiid = items.get(i).path("order_item_id").asText("");
                    sb.append("\"").append(oiid).append("\"");
                }
                sb.append("]");
                itemsJson = sb.toString();
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING,
                    "packAndAllocate: failed to fetch order items for " + order.getOrderCode(), e);
        }
        Map<String, String> params = new HashMap<>();
        params.put("order_id", order.getOrderCode());
        params.put("delivery_type", "dropship");
        params.put("order_item_list", itemsJson);

        long t0 = System.currentTimeMillis();
        try {
            // Lazada's gateway.packOrder already adds the order_item_list param.
            // We pre-built it; we instead build our own pack call to control the param.
            if (!(gateway instanceof LazadaChannelGateway lazadaGateway)) {
                ChannelSyncAudit.logFailure(ch.getChannelId(), "PACK",
                        order.getOrderCode(), 500, params.toString(),
                        "Gateway is not LazadaChannelGateway — fulfillment not supported");
                return ShipmentResult.fail("Channel gateway is not Lazada — fulfillment not supported");
            }
            String body = lazadaGateway.packOrderWithParams(ch, params);
            long dt = System.currentTimeMillis() - t0;
            ChannelSyncAudit.logSuccess(ch.getChannelId(), "PACK",
                    order.getOrderCode(), 200, params.toString(), body, dt);

            JsonNode root = MAPPER.readTree(body);
            JsonNode data = root.path("data");
            String packageId   = data.path("package_id").asText("");
            String trackingNo  = data.path("tracking_number").asText("");
            if (packageId.isEmpty() || trackingNo.isEmpty()) {
                String err = root.path("message").asText("No package_id / tracking_number");
                return ShipmentResult.fail(err);
            }
            // Persist into the orders row + shipping details
            orderDAO.updateLazadaPackage(order.getOrderCode(), packageId, true, false);
            orderDAO.updateOrderTrackingNo(order.getOrderCode(), trackingNo);
            return ShipmentResult.ok(trackingNo, packageId);
        } catch (Exception e) {
            long dt = System.currentTimeMillis() - t0;
            ChannelSyncAudit.logFailure(ch.getChannelId(), "PACK",
                    order.getOrderCode(), 500, params.toString(), e.getMessage());
            return ShipmentResult.fail(e.getMessage());
        }
    }

    /**
     * Step 3 of the fulfillment pipeline: tell Lazada "carrier has been
     * notified, package is ready to be picked up" (UC-B2C06).
     */
    public ShipmentResult readyToShip(Order order) {
        Channel ch = resolveChannel(order);
        if (ch == null) return ShipmentResult.fail("Channel not found for order " + order.getOrderCode());
        String packageId = order.getLazadaPackageId();
        if (packageId == null || packageId.isEmpty()) {
            return ShipmentResult.fail(
                    "Order " + order.getOrderCode() + " has no Lazada package_id — call pack first");
        }
        long t0 = System.currentTimeMillis();
        try {
            String body = gateway.readyToShip(ch, packageId);
            long dt = System.currentTimeMillis() - t0;
            ChannelSyncAudit.logSuccess(ch.getChannelId(), "RTS",
                    order.getOrderCode(), 200, "package_id=" + packageId, body, dt);
            // Persist RTS flag + log
            orderDAO.updateLazadaPackage(order.getOrderCode(), packageId, true, true);
            logRts(ch.getChannelId(), order.getOrderId(), order.getOrderCode(), packageId,
                    "SUCCESS", body);
            // BR-04: deduct physical inventory now that the package is leaving the warehouse.
            // This runs AFTER Lazada confirms RTS, so qty_on_hand must be reduced.
            deductShippedInventoryForOrder(order);
            orderDAO.updateOrderStatus(order.getOrderCode(), "SHIPPED");
            return ShipmentResult.ok(order.getTrackingNo(), packageId);
        } catch (Exception e) {
            long dt = System.currentTimeMillis() - t0;
            ChannelSyncAudit.logFailure(ch.getChannelId(), "RTS",
                    order.getOrderCode(), 500, "package_id=" + packageId, e.getMessage());
            logRts(ch.getChannelId(), order.getOrderId(), order.getOrderCode(), packageId,
                    "FAILED", e.getMessage());
            return ShipmentResult.fail(e.getMessage());
        }
    }

    /** Decodes Lazada's Base64 shipping label into a PDF byte array. */
    public byte[] getShippingLabel(Order order) {
        Channel ch = resolveChannel(order);
        if (ch == null) return null;
        String packageId = order.getLazadaPackageId();
        if (packageId == null || packageId.isEmpty()) {
            throw new IllegalStateException("Order has no package_id; pack first");
        }
        try {
            String body = gateway.getShippingLabel(ch, packageId);
            ChannelSyncAudit.logSuccess(ch.getChannelId(), "LABEL",
                    order.getOrderCode(), 200, "package_id=" + packageId, body, 0L);
            JsonNode root = MAPPER.readTree(body);
            String fileBase64 = root.path("data").path("file").asText("");
            if (fileBase64.isEmpty()) return null;
            return Base64.getDecoder().decode(fileBase64);
        } catch (Exception e) {
            ChannelSyncAudit.logFailure(ch.getChannelId(), "LABEL",
                    order.getOrderCode(), 500, "package_id=" + packageId, e.getMessage());
            LOGGER.log(Level.WARNING, "getShippingLabel failed for " + order.getOrderCode(), e);
            return null;
        }
    }

    // ── Helpers ────────────────────────────────────────────────

    private Channel resolveChannel(Order order) {
        int channelId = order.getChannelId();
        if (channelId <= 0) return null;
        return channelDAO.findById(channelId);
    }

    private void logRts(int channelId, int orderId, String orderCode, String packageId,
                        String status, String response) {
        String sql = "INSERT INTO lazada_rts_log "
                + "(channel_id, order_id, lazada_order_id, package_id, status, response_excerpt) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (java.sql.Connection conn = com.wms.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, channelId);
            ps.setInt(2, orderId);
            ps.setString(3, orderCode);
            ps.setString(4, packageId);
            ps.setString(5, status);
            ps.setString(6, response == null ? null
                    : (response.length() > 3500 ? response.substring(0, 3500) : response));
            ps.executeUpdate();
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "logRts failed", e);
        }
    }

    /**
     * Deducts physical inventory for every item in the given order (BR-04 final step).
     * Called after Lazada confirms RTS, when the package leaves the warehouse.
     * We deduct from qty_on_hand (physical) and qty_available (after soft-alloc was done earlier).
     */
    private void deductShippedInventoryForOrder(Order order) {
        if (order.getWarehouseId() <= 0) {
            LOGGER.warning("deductShippedInventoryForOrder: order " + order.getOrderCode()
                    + " has no warehouse_id, cannot deduct inventory");
            return;
        }
        var items = orderDAO.findItemsByOrderId(order.getOrderId());
        if (items.isEmpty()) {
            LOGGER.warning("deductShippedInventoryForOrder: no items found for order " + order.getOrderCode());
            return;
        }
        int deducted = 0;
        int failed = 0;
        for (OrderItem item : items) {
            if (item.getProductId() <= 0 || item.getQuantity() <= 0) continue;
            try {
                boolean ok = inventoryDAO.deductShippedInventory(
                        item.getProductId(),
                        order.getWarehouseId(),
                        BigDecimal.valueOf(item.getQuantity()));
                if (ok) {
                    deducted++;
                } else {
                    LOGGER.warning("deductShippedInventoryForOrder: insufficient qty_on_hand for productId="
                            + item.getProductId() + " warehouseId=" + order.getWarehouseId()
                            + " qty=" + item.getQuantity());
                    failed++;
                }
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "deductShippedInventoryForOrder: exception for productId="
                        + item.getProductId(), e);
                failed++;
            }
        }
        LOGGER.info("deductShippedInventoryForOrder: order=" + order.getOrderCode()
                + " warehouseId=" + order.getWarehouseId()
                + " deducted=" + deducted + " failed=" + failed);
    }
}
