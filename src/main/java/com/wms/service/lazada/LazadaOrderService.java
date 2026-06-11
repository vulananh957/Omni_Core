package com.wms.service.lazada;

import com.lazada.lazop.api.*;
import com.wms.model.Channel;
import com.wms.util.AppConstants;
import com.wms.util.DBConnection;
import com.wms.util.LazadaAPIUtil;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.Map;
import java.util.TreeMap;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LazadaOrderService — Service class for fetching orders and item details
 * from Lazada Open Platform API.
 *
 * All API calls are fully dynamic: credentials are read from the provided
 * Channel object (apiKey, appSecret, apiUrl, accessToken), enabling
 * multi-channel support without any hardcoded values.
 */
public class LazadaOrderService {

    private static final Logger LOGGER = Logger.getLogger(LazadaOrderService.class.getName());

    /**
     * Fetches pending orders from Lazada for the given channel.
     *
     * @param channel The Channel whose apiKey, appSecret, apiUrl, and accessToken
     *                are used to build and sign the request.
     * @return Raw JSON response containing pending orders.
     */
    public String getPendingOrders(Channel channel) {
        if (channel == null) {
            throw new IllegalArgumentException("channel must not be null");
        }
        if (channel.getAccessToken() == null || channel.getAccessToken().trim().isEmpty()) {
            throw new IllegalArgumentException("channel.accessToken must not be null or empty");
        }

        TreeMap<String, String> params = new TreeMap<>();
        params.put("app_key", channel.getApiKey());
        params.put("timestamp", String.valueOf(System.currentTimeMillis()));
        params.put("sign_method", AppConstants.SIGN_METHOD);
        params.put("access_token", channel.getAccessToken());
        params.put("status", "pending");
        params.put("sort_direction", "DESC");

        return executeGet("/orders/get", params, channel);
    }

    /**
     * Fetches order items detail for a specific Lazada order.
     *
     * @param channel The Channel whose apiKey, appSecret, apiUrl, and accessToken
     *                are used to build and sign the request.
     * @param orderId The Lazada Order ID.
     * @return Raw JSON response containing order items.
     */
    public String getOrderItems(Channel channel, String orderId) {
        if (channel == null) {
            throw new IllegalArgumentException("channel must not be null");
        }
        if (channel.getAccessToken() == null || channel.getAccessToken().trim().isEmpty()) {
            throw new IllegalArgumentException("channel.accessToken must not be null or empty");
        }
        if (orderId == null || orderId.trim().isEmpty()) {
            throw new IllegalArgumentException("orderId must not be null or empty");
        }

        TreeMap<String, String> params = new TreeMap<>();
        params.put("app_key", channel.getApiKey());
        params.put("timestamp", String.valueOf(System.currentTimeMillis()));
        params.put("sign_method", AppConstants.SIGN_METHOD);
        params.put("access_token", channel.getAccessToken());
        params.put("order_id", orderId);

        return executeGet("/order/items/get", params, channel);
    }

    /**
     * Helper method to perform HTTP GET requests to Lazada APIs using
     * per-channel credentials.
     */
    private String executeGet(String apiPath, TreeMap<String, String> params, Channel channel) {
        String signature = LazadaAPIUtil.generateSignature(apiPath, params, channel.getAppSecret());
        params.put("sign", signature);

        String queryStr = buildQueryString(params);
        String apiBaseUrl = channel.getApiUrl();
        if (apiBaseUrl == null || apiBaseUrl.trim().isEmpty()) {
            apiBaseUrl = AppConstants.LAZADA_API_URL;
        }
        String fullUrl = apiBaseUrl + apiPath + "?" + queryStr;

        HttpURLConnection conn = null;
        try {
            LOGGER.info("Sending GET request to Lazada API: " + apiBaseUrl + apiPath);
            URL url = new URL(fullUrl);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(15000);
            conn.setRequestProperty("Accept", "application/json");

            int responseCode = conn.getResponseCode();
            LOGGER.info("Lazada GET response status for [" + apiPath + "]: " + responseCode);

            StringBuilder response = new StringBuilder();
            try (BufferedReader br = new BufferedReader(
                    new InputStreamReader(
                            responseCode >= 200 && responseCode < 300
                                    ? conn.getInputStream()
                                    : conn.getErrorStream(),
                            StandardCharsets.UTF_8))) {
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line.trim());
                }
            }

            return response.toString();

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to communicate with Lazada API path: " + apiPath, e);
            throw new RuntimeException("Lazada API connection failed", e);
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }

    /**
     * Converts parameter map into application/x-www-form-urlencoded query string.
     */
    private String buildQueryString(Map<String, String> params) {
        StringBuilder query = new StringBuilder();
        for (Map.Entry<String, String> entry : params.entrySet()) {
            if (query.length() > 0) {
                query.append('&');
            }
            query.append(URLEncoder.encode(entry.getKey(), StandardCharsets.UTF_8));
            query.append('=');
            query.append(URLEncoder.encode(entry.getValue(), StandardCharsets.UTF_8));
        }
        return query.toString();
    }

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
            LOGGER.info("Fetched " + (responseBody != null ? responseBody.length() : 0) + " bytes from Lazada API");

            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode rootNode = objectMapper.readTree(responseBody);
            JsonNode ordersArray = rootNode.path("data").path("orders");

            if (ordersArray.isArray() && ordersArray.size() > 0) {
                LOGGER.info("Found " + ordersArray.size() + " orders, saving to DB...");
                saveOrdersToDb(ordersArray);
            } else {
                LOGGER.info("No orders found in API response.");
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "LazadaOrderService: API call failed", e);
        }
    }

    /**
     * Parses orders array and saves them into MySQL using JDBC.
     */
    private static void saveOrdersToDb(JsonNode ordersArray) {
        Connection conn = null;
        PreparedStatement psProduct = null;
        PreparedStatement psOrder = null;
        PreparedStatement psItem = null;
        Statement stmtProductSelect = null;
        PreparedStatement psOrderSelect = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Ensure DUMMY-LAZADA placeholder product exists
            int dummyProductId = 1;
            String insertProductSql = "INSERT IGNORE INTO products (sku_code, product_name, category, active, base_price) VALUES (?, ?, ?, ?, ?)";
            psProduct = conn.prepareStatement(insertProductSql, Statement.RETURN_GENERATED_KEYS);
            psProduct.setString(1, "DUMMY-LAZADA");
            psProduct.setString(2, "Lazada Product Placeholder");
            psProduct.setString(3, "Lazada");
            psProduct.setInt(4, 1);
            psProduct.setDouble(5, 0);
            psProduct.executeUpdate();

            try (ResultSet rsProduct = psProduct.getGeneratedKeys()) {
                if (rsProduct.next()) {
                    dummyProductId = rsProduct.getInt(1);
                } else {
                    String selectProductSql = "SELECT product_id FROM products WHERE sku_code = 'DUMMY-LAZADA'";
                    stmtProductSelect = conn.createStatement();
                    try (ResultSet rsSel = stmtProductSelect.executeQuery(selectProductSql)) {
                        if (rsSel.next()) {
                            dummyProductId = rsSel.getInt("product_id");
                        }
                    }
                }
            }

            // Ensure inventory record for DUMMY-LAZADA in warehouse 1
            String insertInvSql = "INSERT IGNORE INTO inventory (product_id, warehouse_id, qty_on_hand, holding, qty_available) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement psInv = conn.prepareStatement(insertInvSql)) {
                psInv.setInt(1, dummyProductId);
                psInv.setInt(2, 1);
                psInv.setDouble(3, 100000);
                psInv.setDouble(4, 0);
                psInv.setDouble(5, 100000);
                psInv.executeUpdate();
            }

            // 2. Prepared statements for orders and order items
            String insertOrderSql = "INSERT IGNORE INTO orders (order_code, warehouse_id, order_status, total_actual_paid, created_at) VALUES (?, ?, ?, ?, ?)";
            psOrder = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS);

            String selectOrderSql = "SELECT order_id FROM orders WHERE order_code = ?";
            psOrderSelect = conn.prepareStatement(selectOrderSql);

            String insertItemSql = "INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price, actual_price) VALUES (?, ?, ?, ?, ?)";
            psItem = conn.prepareStatement(insertItemSql);

            int savedCount = 0;
            for (JsonNode orderNode : ordersArray) {
                long orderId = orderNode.path("order_id").asLong();
                double price = orderNode.path("price").asDouble();
                String createdAt = orderNode.path("created_at").asText();

                String status = "PENDING";
                JsonNode statusesNode = orderNode.path("statuses");
                if (statusesNode.isArray() && statusesNode.size() > 0) {
                    status = statusesNode.get(0).asText();
                } else if (orderNode.has("status")) {
                    status = orderNode.path("status").asText();
                }

                psOrder.setString(1, String.valueOf(orderId));
                psOrder.setInt(2, 1);
                psOrder.setString(3, mapLazadaStatus(status));
                psOrder.setDouble(4, price);
                psOrder.setTimestamp(5, parseLazadaDate(createdAt));
                int affectedRows = psOrder.executeUpdate();
                boolean isNewOrder = (affectedRows > 0);

                int generatedOrderId = -1;
                if (isNewOrder) {
                    try (ResultSet rsOrder = psOrder.getGeneratedKeys()) {
                        if (rsOrder.next()) {
                            generatedOrderId = rsOrder.getInt(1);
                        }
                    }
                } else {
                    psOrderSelect.setString(1, String.valueOf(orderId));
                    try (ResultSet rsSel = psOrderSelect.executeQuery()) {
                        if (rsSel.next()) {
                            generatedOrderId = rsSel.getInt("order_id");
                        }
                    }
                }

                if (generatedOrderId != -1 && isNewOrder) {
                    psItem.setInt(1, generatedOrderId);
                    psItem.setInt(2, dummyProductId);
                    psItem.setDouble(3, 1);
                    psItem.setDouble(4, price);
                    psItem.setDouble(5, price);
                    psItem.executeUpdate();

                    allocateInventory(conn, generatedOrderId);
                    savedCount++;
                }
            }

            conn.commit();
            LOGGER.info("LazadaOrderService: Synced " + savedCount + " orders to database.");

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "LazadaOrderService: DB error during order sync", e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.WARNING, "LazadaOrderService: Rollback failed", ex);
                }
            }
        } finally {
            try {
                if (psProduct != null) psProduct.close();
                if (psOrder != null) psOrder.close();
                if (psOrderSelect != null) psOrderSelect.close();
                if (psItem != null) psItem.close();
                if (stmtProductSelect != null) stmtProductSelect.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "LazadaOrderService: Failed to close resources", e);
            }
        }
    }

    /**
     * Executes soft-allocation (Holding inventory) for a given order (Rule BR-04).
     */
    private static void allocateInventory(Connection conn, int orderId) throws SQLException {
        String queryItemsSql = "SELECT product_id, quantity FROM order_items WHERE order_id = ?";
        String updateInventorySql = "UPDATE inventory SET holding = holding + ?, qty_available = qty_available - ? "
                                  + "WHERE product_id = ? AND warehouse_id = 1";

        try (PreparedStatement psSelect = conn.prepareStatement(queryItemsSql);
             PreparedStatement psUpdate = conn.prepareStatement(updateInventorySql)) {

            psSelect.setInt(1, orderId);
            try (ResultSet rs = psSelect.executeQuery()) {
                while (rs.next()) {
                    int productId = rs.getInt("product_id");
                    double qty = rs.getDouble("quantity");

                    psUpdate.setDouble(1, qty);
                    psUpdate.setDouble(2, qty);
                    psUpdate.setInt(3, productId);
                    psUpdate.executeUpdate();
                }
            }
        }
        LOGGER.info("Soft-allocation completed for order ID: " + orderId);
    }

    /**
     * Maps Lazada order statuses to WMS order_status ENUM values.
     */
    private static String mapLazadaStatus(String lazadaStatus) {
        if (lazadaStatus == null) return "PENDING";
        switch (lazadaStatus.toLowerCase()) {
            case "pending":
            case "unpaid":
                return "PENDING";
            case "ready_to_ship":
            case "confirmed":
                return "PACKED";
            case "shipped":
                return "SHIPPED";
            case "delivered":
                return "DELIVERED";
            case "canceled":
            case "cancelled":
                return "CANCELLED";
            default:
                return "PENDING";
        }
    }

    /**
     * Parses Lazada API date string to SQL Timestamp.
     */
    private static java.sql.Timestamp parseLazadaDate(String dateStr) {
        try {
            if (dateStr == null || dateStr.isEmpty()) {
                return new java.sql.Timestamp(System.currentTimeMillis());
            }
            java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss Z");
            java.time.ZonedDateTime zonedDateTime = java.time.ZonedDateTime.parse(dateStr, formatter);
            return java.sql.Timestamp.from(zonedDateTime.toInstant());
        } catch (Exception e) {
            return new java.sql.Timestamp(System.currentTimeMillis());
        }
    }
}
