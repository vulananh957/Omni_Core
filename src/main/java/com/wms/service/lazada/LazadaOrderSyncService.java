package com.wms.service.lazada;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.dao.SkuMappingDAO;
import com.wms.model.Channel;
import com.wms.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LazadaOrderSyncService — extracted from LazadaSyncScheduler.
 *
 * <p>Contains all order-persistence logic that was previously inlined in the scheduler:
 * upsert orders, shipping details, order items (with SKU mapping), and soft-allocation.
 *
 * <p>This is a stateful service: caller must call {@link #setChannel(Channel)} before
 * each sync cycle, or pass the channel explicitly on each call.
 *
 * <p>All DB operations accept an external {@link Connection} so the caller controls
 * the transaction boundary. On error, the caller is responsible for rollback.
 */
public class LazadaOrderSyncService {

    private static final Logger LOGGER = Logger.getLogger(LazadaOrderSyncService.class.getName());
    private static final ObjectMapper MAPPER = new ObjectMapper();

    /** The channel being synced — set once per sync cycle via {@link #setChannel}. */
    private Channel currentChannel;

    public LazadaOrderSyncService() {}

    public void setChannel(Channel channel) {
        this.currentChannel = channel;
    }

    public Channel getChannel() {
        return currentChannel;
    }

    // ── Order upsert ──────────────────────────────────────────────

    /**
     * Persists one Lazada order: orders + order_shipping_details + order_items.
     * Returns NEW if the order was inserted, UPDATED if it was already known,
     * or SKIPPED if the order_id is invalid.
     */
    public SyncResult saveOneOrder(Connection conn, JsonNode orderNode, String detailJson) throws SQLException {
        if (currentChannel == null) {
            throw new IllegalStateException("LazadaOrderSyncService: channel not set — call setChannel() first");
        }
        long lazadaOrderId = orderNode.path("order_id").asLong();
        if (lazadaOrderId <= 0) {
            return SyncResult.SKIPPED;
        }
        String orderCode = String.valueOf(lazadaOrderId);

        JsonNode detailRoot = (detailJson != null) ? safeParse(detailJson) : null;
        JsonNode detailData = detailRoot != null ? detailRoot.path("data") : orderNode;

        // Ensure dummy product/inventory exist for unmapped items
        int dummyProductId = ensureDummyProduct(conn);
        ensureDummyInventory(conn, dummyProductId);
        int channelId = currentChannel.getChannelId();

        BigDecimal totalAmount = parseTotalAmount(detailData, orderNode);
        Timestamp createdAt = parseTimestamp(
                firstNonEmpty(detailData.path("created_at").asText(""),
                        orderNode.path("created_at").asText(""), ""));
        String feeBreakdown = buildFeeBreakdownJson(detailData);

        int generatedId = upsertOrder(conn, orderCode, channelId, totalAmount, feeBreakdown, createdAt);
        if (generatedId <= 0) {
            return SyncResult.SKIPPED;
        }

        upsertShippingDetails(conn, generatedId, detailData, orderCode);
        int itemCount = upsertOrderItems(conn, generatedId, detailData, orderCode, dummyProductId);
        if (itemCount == 0) {
            insertFallbackItem(conn, generatedId, dummyProductId, totalAmount);
        }

        return SyncResult.NEW;
    }

    private int upsertOrder(Connection conn, String orderCode, int channelId,
                            BigDecimal totalAmount, String feeBreakdown, Timestamp createdAt) throws SQLException {
        String sql = "INSERT INTO orders "
                + "(order_code, channel_id, channel_order_id, warehouse_id, channel, status, "
                + " total_amount, fee_breakdown_json, sync_status, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'SYNCED', ?) "
                + "ON DUPLICATE KEY UPDATE "
                + "  channel_id = VALUES(channel_id), "
                + "  channel_order_id = VALUES(channel_order_id), "
                + "  status = VALUES(status), "
                + "  total_amount = VALUES(total_amount), "
                + "  fee_breakdown_json = VALUES(fee_breakdown_json), "
                + "  sync_status = 'SYNCED', "
                + "  updated_at = CURRENT_TIMESTAMP";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, orderCode);
            ps.setInt(2, channelId);
            ps.setString(3, orderCode);
            ps.setInt(4, 0); // warehouse_id=0 until Sales approves
            ps.setString(5, "LAZADA");
            ps.setString(6, "PENDING");
            ps.setBigDecimal(7, totalAmount);
            ps.setString(8, feeBreakdown);
            ps.setTimestamp(9, createdAt);
            int affected = ps.executeUpdate();

            if (affected == 1) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
            return findOrderIdByCode(conn, orderCode);
        }
    }

    private void upsertShippingDetails(Connection conn, int orderId, JsonNode detail, String orderCode)
            throws SQLException {
        JsonNode addr = detail.path("address_shipping");
        String recipientName = firstNonEmpty(
                addr.path("first_name").asText(""),
                detail.path("recipient_name").asText(""),
                "Lazada Buyer " + orderCode);
        String phone = firstNonEmpty(
                addr.path("phone").asText(""),
                addr.path("phone2").asText(""),
                detail.path("phone").asText(""));
        String address = firstNonEmpty(
                addr.path("address1").asText(""),
                detail.path("shipping_address").asText(""),
                "(địa chỉ chưa rõ)");
        String city = addr.path("city").asText("");
        String postcode = addr.path("postcode").asText("");
        if (!city.isEmpty()) address += ", " + city;
        if (!postcode.isEmpty()) address += " " + postcode;
        String courier = firstNonEmpty(
                detail.path("shipping_provider").asText(""),
                detail.path("shipment_provider").asText(""),
                "Lazada");
        String waybill = stripNull(detail.path("tracking_number").asText(""));
        String shippingStatus = mapLazadaShippingStatus(detail);

        String sql = "INSERT INTO order_shipping_details "
                + "(order_id, recipient_name, shipping_address, courier_name, waybill_code, shipping_status) "
                + "VALUES (?, ?, ?, ?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE "
                + "  recipient_name = VALUES(recipient_name), "
                + "  shipping_address = VALUES(shipping_address), "
                + "  courier_name = VALUES(courier_name), "
                + "  waybill_code = COALESCE(NULLIF(VALUES(waybill_code), ''), waybill_code), "
                + "  shipping_status = VALUES(shipping_status)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setString(2, recipientName);
            ps.setString(3, address);
            ps.setString(4, courier);
            if (waybill.isEmpty()) ps.setNull(5, Types.VARCHAR); else ps.setString(5, waybill);
            ps.setString(6, shippingStatus);
            ps.executeUpdate();
        }
    }

    private int upsertOrderItems(Connection conn, int orderId, JsonNode detail, String orderCode,
                                 int dummyProductId) throws SQLException {
        JsonNode items = detail.path("order_items");
        if (!items.isArray() || items.isEmpty()) {
            items = detail.path("order_items");
        }
        if ((!items.isArray() || items.isEmpty()) && detail.path("data").isArray()) {
            items = detail.path("data");
        }
        if (!items.isArray() || items.isEmpty()) {
            return 0;
        }

        SkuMappingDAO mappingDAO = new SkuMappingDAO();
        int channelId = currentChannel.getChannelId();
        int count = 0;

        String sql = "INSERT IGNORE INTO order_items (order_id, product_id, qty, unit_price, actual_price) "
                + "VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (JsonNode itemNode : items) {
                String externalSku = stripNull(itemNode.path("sku").asText(""));
                double qty = itemNode.path("quantity").asDouble(1);
                if (qty <= 0) qty = 1;
                double unitPrice = itemNode.path("item_price").asDouble(0);
                if (unitPrice == 0) unitPrice = itemNode.path("price").asDouble(0);

                int productId = dummyProductId;
                if (!externalSku.isEmpty()) {
                    var mapping = mappingDAO.findActiveMapping(channelId, externalSku);
                    if (mapping != null && mapping.getSkuId() > 0) {
                        productId = mapping.getSkuId();
                    } else {
                        mappingDAO.logMappingException(channelId, externalSku, orderCode,
                                "No active SKU mapping for Lazada order item");
                        LOGGER.warning("LazadaOrderSyncService: unmapped SKU externalSku="
                                + externalSku + " orderCode=" + orderCode);
                    }
                }

                ps.setInt(1, orderId);
                ps.setInt(2, productId);
                ps.setDouble(3, qty);
                ps.setDouble(4, unitPrice);
                ps.setDouble(5, qty * unitPrice);
                ps.executeUpdate();
                count++;
            }
        }
        return count;
    }

    private void insertFallbackItem(Connection conn, int orderId, int dummyProductId,
                                    BigDecimal totalAmount) throws SQLException {
        String sql = "INSERT IGNORE INTO order_items (order_id, product_id, qty, unit_price, actual_price) "
                + "VALUES (?, ?, 1, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, dummyProductId);
            ps.setBigDecimal(3, totalAmount);
            ps.setBigDecimal(4, totalAmount);
            ps.executeUpdate();
        }
    }

    // ── Dummy product helpers ─────────────────────────────────────

    private int ensureDummyProduct(Connection conn) throws SQLException {
        try (Statement st = conn.createStatement()) {
            st.executeUpdate("INSERT IGNORE INTO products "
                    + "(sku_code, product_name, category, active, base_price) "
                    + "VALUES ('DUMMY-LAZADA', 'Lazada Product Placeholder', 'Lazada', 1, 0)");
        }
        return findDummyProductId(conn);
    }

    private int findDummyProductId(Connection conn) throws SQLException {
        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(
                     "SELECT product_id FROM products WHERE sku_code = 'DUMMY-LAZADA'")) {
            if (rs.next()) return rs.getInt("product_id");
        }
        return 1;
    }

    private void ensureDummyInventory(Connection conn, int productId) throws SQLException {
        String sql = "INSERT IGNORE INTO inventory "
                + "(product_id, warehouse_id, qty_on_hand, holding, qty_available) "
                + "VALUES (?, 1, 100000, 0, 100000)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.executeUpdate();
        }
    }

    private int findOrderIdByCode(Connection conn, String orderCode) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT order_id FROM orders WHERE order_code = ?")) {
            ps.setString(1, orderCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("order_id");
            }
        }
        return -1;
    }

    // ── Helpers ────────────────────────────────────────────────────

    private BigDecimal parseTotalAmount(JsonNode detail, JsonNode orderNode) {
        String t1 = detail.path("price").asText("");
        String t2 = detail.path("total_amount").asText("");
        String t3 = orderNode.path("total_amount").asText("0");
        String chosen = firstNonEmpty(t1, t2, t3, "0");
        try {
            return new BigDecimal(chosen.trim());
        } catch (NumberFormatException e) {
            return BigDecimal.ZERO;
        }
    }

    private String mapLazadaShippingStatus(JsonNode detail) {
        // Fallback: derive from order status if no explicit shipping status
        String orderStatus = detail.path("status").asText("");
        return orderStatus.isEmpty() ? "PENDING" : orderStatus;
    }

    private JsonNode safeParse(String s) {
        if (s == null || s.isEmpty()) return null;
        try {
            return MAPPER.readTree(s);
        } catch (Exception e) {
            LOGGER.log(Level.FINE, "safeParse failed", e);
            return null;
        }
    }

    private static String stripNull(String s) {
        return s == null ? "" : s;
    }

    private static String firstNonEmpty(String... candidates) {
        for (String c : candidates) {
            if (c != null && !c.trim().isEmpty()) return c;
        }
        return "";
    }

    private static Timestamp parseTimestamp(String dateStr) {
        if (dateStr == null || dateStr.isEmpty()) {
            return new Timestamp(System.currentTimeMillis());
        }
        String[] patterns = {
                "yyyy-MM-dd HH:mm:ss Z",
                "yyyy-MM-dd'T'HH:mm:ssXXX",
                "yyyy-MM-dd'T'HH:mm:ss'Z'",
                "yyyy-MM-dd HH:mm:ss"
        };
        for (String p : patterns) {
            try {
                java.time.format.DateTimeFormatter fmt =
                        java.time.format.DateTimeFormatter.ofPattern(p);
                if (p.contains("XXX") || p.contains("Z") && !p.endsWith("'Z'")) {
                    java.time.ZonedDateTime zdt = java.time.ZonedDateTime.parse(dateStr, fmt);
                    return Timestamp.from(zdt.toInstant());
                } else {
                    java.time.LocalDateTime ldt = java.time.LocalDateTime.parse(dateStr, fmt);
                    return Timestamp.valueOf(ldt);
                }
            } catch (Exception ignore) {}
        }
        return new Timestamp(System.currentTimeMillis());
    }

    private static String buildFeeBreakdownJson(JsonNode detail) {
        try {
            com.fasterxml.jackson.databind.node.ObjectNode node = MAPPER.createObjectNode();
            node.put("shipping_fee", detail.path("shipping_fee").asText("0"));
            node.put("voucher_amount", detail.path("voucher_amount").asText("0"));
            node.put("payment_method", detail.path("payment_method").asText(""));
            node.put("gift_option", detail.path("gift_option").asText(""));
            return MAPPER.writeValueAsString(node);
        } catch (Exception e) {
            return null;
        }
    }

    // ── Result type ────────────────────────────────────────────────

    public enum SyncResult { NEW, UPDATED, SKIPPED }
}
