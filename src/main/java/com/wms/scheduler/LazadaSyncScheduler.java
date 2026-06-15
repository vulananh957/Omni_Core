package com.wms.scheduler;

import com.wms.dao.ChannelDAO;
import com.wms.model.Channel;
import com.wms.service.lazada.LazadaOrderService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LazadaSyncScheduler — Background timer that periodically syncs pending orders
 * from Lazada for every active Lazada channel configured in the system.
 *
 * Runs on application startup ({@code contextInitialized}) and shuts down cleanly
 * on application stop ({@code contextDestroyed}). Sync interval is read from
 * {@code db.properties} so it is configurable without a restart.
 */
@WebListener
public class LazadaSyncScheduler implements ServletContextListener {

    private static final Logger LOGGER = Logger.getLogger(LazadaSyncScheduler.class.getName());

    private Timer timer;
    private ServletContext servletContext;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        servletContext = sce.getServletContext();
        String intervalProp = servletContext.getInitParameter("lazada.sync.interval.minutes");
        int intervalMinutes = parseInterval(intervalProp);

        String enabled = servletContext.getInitParameter("lazada.sync.enabled");
        if ("false".equalsIgnoreCase(enabled)) {
            LOGGER.info("LazadaSyncScheduler: Disabled by configuration. Skipping startup.");
            return;
        }

        LOGGER.info("LazadaSyncScheduler: Starting with interval=" + intervalMinutes + " minutes.");
        timer = new Timer("LazadaSyncTimer", true);
        timer.scheduleAtFixedRate(new SyncTask(), 0L, intervalMinutes * 60 * 1000L);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (timer != null) {
            LOGGER.info("LazadaSyncScheduler: Cancelling timer...");
            timer.cancel();
            timer = null;
        }
    }

    private int parseInterval(String prop) {
        try {
            int val = Integer.parseInt(prop);
            return (val > 0) ? val : 5;
        } catch (Exception e) {
            return 5;
        }
    }

    /**
     * One sync cycle: fetches all active Lazada channels, then syncs orders for each.
     */
    private class SyncTask extends TimerTask {
        private final LazadaOrderService orderService = new LazadaOrderService();
        private final ChannelDAO channelDAO = new ChannelDAO();
        private final ObjectMapper objectMapper = new ObjectMapper();

        /** Carries channelId from syncChannel() down to saveOrdersToDb(). */
        private int currentChannelId;

        @Override
        public void run() {
            LOGGER.info("LazadaSyncScheduler: Sync cycle started.");
            int totalSynced = 0;

            try {
                List<Channel> channels = channelDAO.findAll();
                for (Channel channel : channels) {
                    if (!channel.isActive() || !"Lazada".equalsIgnoreCase(channel.getPlatform())) {
                        continue;
                    }
                    if (channel.getAccessToken() == null || channel.getAccessToken().trim().isEmpty()) {
                        LOGGER.fine("LazadaSyncScheduler: Channel '" + channel.getChannelName()
                                + "' has no access token, skipping.");
                        continue;
                    }

                    try {
                        int synced = syncChannel(channel);
                        totalSynced += synced;
                    } catch (Exception e) {
                        LOGGER.log(Level.WARNING, "LazadaSyncScheduler: Failed to sync channel '"
                                + channel.getChannelName() + "': " + e.getMessage(), e);
                        logSync(channel.getChannelId(), "ORDER_SYNC", "FAILED", null, null, e.getMessage());
                    }
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "LazadaSyncScheduler: Sync cycle failed: " + e.getMessage(), e);
            }

            LOGGER.info("LazadaSyncScheduler: Sync cycle completed. Total orders synced: " + totalSynced);
        }

        private int syncChannel(Channel channel) {
            currentChannelId = channel.getChannelId();
            String responseBody = orderService.getPendingOrders(channel);
            logSync(channel.getChannelId(), "ORDER_SYNC", "SUCCESS", null, responseBody, null);

            try {
                JsonNode rootNode = objectMapper.readTree(responseBody);
                JsonNode ordersArray = rootNode.path("data").path("orders");

                if (!ordersArray.isArray() || ordersArray.size() == 0) {
                    LOGGER.fine("LazadaSyncScheduler: No pending orders for channel '"
                            + channel.getChannelName() + "'.");
                    return 0;
                }

                int savedCount = 0;
                try (Connection conn = com.wms.util.DBConnection.getConnection()) {
                    conn.setAutoCommit(false);
                    savedCount = saveOrdersToDb(conn, ordersArray);
                    conn.commit();
                }

                LOGGER.info("LazadaSyncScheduler: Synced " + savedCount
                        + " orders for channel '" + channel.getChannelName() + "'.");
                return savedCount;

            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "LazadaSyncScheduler: Error parsing orders for channel '"
                        + channel.getChannelName() + "': " + e.getMessage(), e);
                throw new RuntimeException("Order parsing failed", e);
            }
        }

        private int saveOrdersToDb(Connection conn, JsonNode ordersArray) throws SQLException {
            // No more dummy product. Look up the SKU mapping; if not found, log
            // the exception into mapping_exceptions for Sales staff to handle.
            int dummyProductId = ensureDummyProduct(conn);
            ensureDummyInventory(conn, dummyProductId);

            String insertOrderSql = "INSERT IGNORE INTO orders "
                    + "(order_code, warehouse_id, channel, status, total_amount, created_at) "
                    + "VALUES (?, ?, ?, ?, ?, ?)";
            String selectOrderSql = "SELECT order_id FROM orders WHERE order_code = ?";
            String insertItemSql = "INSERT IGNORE INTO order_items (order_id, product_id, qty, unit_price) "
                    + "VALUES (?, ?, ?, ?)";

            com.wms.dao.SkuMappingDAO mappingDAO = new com.wms.dao.SkuMappingDAO();
            int channelId = currentChannelId; // set in syncChannel()

            try (PreparedStatement psOrder = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS);
                 PreparedStatement psOrderSel = conn.prepareStatement(selectOrderSql);
                 PreparedStatement psItem = conn.prepareStatement(insertItemSql)) {

                int savedCount = 0;
                for (JsonNode orderNode : ordersArray) {
                    long orderId = orderNode.path("order_id").asLong();
                    double price = orderNode.path("price").asDouble(0);
                    String createdAt = orderNode.path("created_at").asText();
                    String status = resolveStatus(orderNode);
                    String orderCode = String.valueOf(orderId);

                    psOrder.setString(1, orderCode);
                    psOrder.setInt(2, 1);
                    psOrder.setString(3, "LAZADA");
                    psOrder.setString(4, status);
                    psOrder.setDouble(5, price);
                    psOrder.setTimestamp(6, parseTimestamp(createdAt));
                    int affected = psOrder.executeUpdate();
                    boolean isNew = affected > 0;

                    int generatedId = -1;
                    if (isNew) {
                        try (ResultSet rs = psOrder.getGeneratedKeys()) {
                            if (rs.next()) generatedId = rs.getInt(1);
                        }
                    } else {
                        psOrderSel.setString(1, orderCode);
                        try (ResultSet rs = psOrderSel.executeQuery()) {
                            if (rs.next()) generatedId = rs.getInt("order_id");
                        }
                    }

                    if (generatedId != -1 && isNew) {
                        // Look up the SKU mapping for each item in the order.
                        // Lazada returns the order_items list under the "order_items" node.
                        int itemCount = 0;
                        JsonNode itemsNode = orderNode.path("order_items");
                        if (itemsNode.isArray() && itemsNode.size() > 0) {
                            for (JsonNode itemNode : itemsNode) {
                                String externalSku = itemNode.path("sku").asText("");
                                double qty = itemNode.path("quantity").asDouble(1);
                                double unitPrice = itemNode.path("price").asDouble(price);

                                com.wms.model.SkuMapping mapping =
                                    mappingDAO.findActiveMapping(channelId, externalSku);

                                int productId;
                                if (mapping != null && mapping.getSkuId() > 0) {
                                    // Real mapping → use actual product_id
                                    productId = mapping.getSkuId();
                                } else {
                                    // No mapping → log exception and fall back to dummy
                                    mappingDAO.logMappingException(channelId, externalSku,
                                        orderCode, "No SKU mapping found for Lazada product");
                                    LOGGER.warning("LazadaSyncScheduler: No mapping for externalSku="
                                        + externalSku + " orderCode=" + orderCode);
                                    productId = dummyProductId;
                                }

                                psItem.setInt(1, generatedId);
                                psItem.setInt(2, productId);
                                psItem.setDouble(3, qty);
                                psItem.setDouble(4, unitPrice);
                                psItem.executeUpdate();
                                itemCount++;
                            }
                        }

                        // Backward-compat: if the response has no order_items, create a dummy line
                        if (itemCount == 0) {
                            psItem.setInt(1, generatedId);
                            psItem.setInt(2, dummyProductId);
                            psItem.setDouble(3, 1);
                            psItem.setDouble(4, price);
                            psItem.executeUpdate();
                        }
                        allocateInventory(conn, generatedId);
                        savedCount++;
                    }
                }
                return savedCount;
            }
        }

        private int ensureDummyProduct(Connection conn) throws SQLException {
            String sql = "INSERT IGNORE INTO products "
                    + "(sku_code, product_name, category, active, base_price) "
                    + "VALUES ('DUMMY-LAZADA', 'Lazada Product Placeholder', 'Lazada', 1, 0)";
            try (Statement st = conn.createStatement()) {
                st.executeUpdate(sql);
            }
            int productId = 1;
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(
                         "SELECT product_id FROM products WHERE sku_code = 'DUMMY-LAZADA'")) {
                if (rs.next()) productId = rs.getInt("product_id");
            }
            return productId;
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

        private void allocateInventory(Connection conn, int orderId) throws SQLException {
            String selSql = "SELECT product_id, qty FROM order_items WHERE order_id = ?";
            String updSql = "UPDATE inventory SET holding = holding + ?, qty_available = qty_available - ? "
                    + "WHERE product_id = ? AND warehouse_id = 1";

            try (PreparedStatement psSel = conn.prepareStatement(selSql);
                 PreparedStatement psUpd = conn.prepareStatement(updSql)) {

                psSel.setInt(1, orderId);
                try (ResultSet rs = psSel.executeQuery()) {
                    while (rs.next()) {
                        int pid = rs.getInt("product_id");
                        double qty = rs.getDouble("qty");
                        psUpd.setDouble(1, qty);
                        psUpd.setDouble(2, qty);
                        psUpd.setInt(3, pid);
                        psUpd.executeUpdate();
                    }
                }
            }
        }

        private String resolveStatus(JsonNode orderNode) {
            JsonNode statuses = orderNode.path("statuses");
            if (statuses.isArray() && statuses.size() > 0) {
                return mapLazadaStatus(statuses.get(0).asText());
            }
            return mapLazadaStatus(orderNode.path("status").asText("pending"));
        }

        private String mapLazadaStatus(String lazadaStatus) {
            if (lazadaStatus == null) return "PENDING";
            switch (lazadaStatus.toLowerCase()) {
                case "pending": case "unpaid": return "PENDING";
                case "ready_to_ship": case "confirmed": return "PACKED";
                case "shipped": return "SHIPPED";
                case "delivered": return "DELIVERED";
                case "canceled": case "cancelled": return "CANCELLED";
                default: return "PENDING";
            }
        }

        private Timestamp parseTimestamp(String dateStr) {
            try {
                if (dateStr == null || dateStr.isEmpty()) {
                    return new Timestamp(System.currentTimeMillis());
                }
                java.time.format.DateTimeFormatter fmt =
                        java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss Z");
                java.time.ZonedDateTime zdt = java.time.ZonedDateTime.parse(dateStr, fmt);
                return Timestamp.from(zdt.toInstant());
            } catch (Exception e) {
                return new Timestamp(System.currentTimeMillis());
            }
        }

        private void logSync(int channelId, String syncType, String status,
                             String requestData, String responseData, String errorMsg) {
            String sql = "INSERT INTO lazada_sync_log "
                    + "(channel_id, sync_type, status, request_data, response_data, error_msg) "
                    + "VALUES (?, ?, ?, ?, ?, ?)";
            try (Connection conn = com.wms.util.DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, channelId);
                ps.setString(2, syncType);
                ps.setString(3, status);
                ps.setString(4, requestData);
                ps.setString(5, responseData);
                ps.setString(6, errorMsg);
                ps.executeUpdate();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "LazadaSyncScheduler: Failed to log sync result", e);
            }
        }
    }
}
