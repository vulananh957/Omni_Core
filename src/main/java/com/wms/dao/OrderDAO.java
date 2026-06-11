package com.wms.dao;

import com.wms.model.Order;
import com.wms.model.OrderItem;
import com.wms.model.Product;
import com.wms.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * OrderDAO — Data Access Object for handling order records from MySQL.
 */
public class OrderDAO {

    private static final Logger LOGGER = Logger.getLogger(OrderDAO.class.getName());

    /**
     * Retrieves the top 100 latest orders ordered by created_at descending.
     * Uses try-with-resources to ensure proper connection and resource closing.
     *
     * @return List of Order objects.
     */
    public List<Order> getAllOrders() {
        List<Order> list = new ArrayList<>();
        String sqlOrders = "SELECT o.order_id, o.order_code, o.customer_id, o.warehouse_id, w.warehouse_name, o.channel, o.status, o.total_amount, o.note, o.created_by, o.created_at, o.updated_at, "
                           + "o.tracking_no, o.review_note, o.rma_reason, o.rma_physical_status, o.rma_platform_status, o.dispute_evidence_video, o.dispute_note, "
                           + "sd.recipient_name, sd.shipping_address, u.phone AS customer_phone, u.full_name AS customer_name "
                           + "FROM orders o "
                           + "LEFT JOIN warehouses w ON o.warehouse_id = w.warehouse_id "
                           + "LEFT JOIN order_shipping_details sd ON o.order_id = sd.order_id "
                           + "LEFT JOIN users u ON o.customer_id = u.user_id "
                           + "ORDER BY o.created_at DESC LIMIT 100";
        String sqlItems = "SELECT p.product_id, p.sku_code, p.product_name, oi.qty, oi.unit_price " +
                          "FROM order_items oi " +
                          "JOIN products p ON oi.sku_id = p.product_id " +
                          "WHERE oi.order_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement psOrders = conn.prepareStatement(sqlOrders);
             ResultSet rsOrders = psOrders.executeQuery()) {

            try (PreparedStatement psItems = conn.prepareStatement(sqlItems)) {
                while (rsOrders.next()) {
                    Order order = new Order();
                    int orderId = rsOrders.getInt("order_id");
                    order.setOrderId(orderId);
                    order.setOrderCode(rsOrders.getString("order_code"));
                    
                    int customerId = rsOrders.getInt("customer_id");
                    order.setCustomerId(rsOrders.wasNull() ? null : customerId);
                    
                    order.setWarehouseId(rsOrders.getInt("warehouse_id"));
                    order.setWarehouseName(rsOrders.getString("warehouse_name"));
                    
                    String rawChannel = rsOrders.getString("channel");
                    String note = rsOrders.getString("note");
                    String trackingNo = rsOrders.getString("tracking_no");
                    order.setNote(note);
                    order.setChannel(detectChannel(rawChannel, note, trackingNo));
                    
                    order.setStatus(rsOrders.getString("status"));
                    order.setTotalAmount(rsOrders.getDouble("total_amount"));
                    
                    int createdBy = rsOrders.getInt("created_by");
                    order.setCreatedBy(rsOrders.wasNull() ? null : createdBy);

                    Timestamp ca = rsOrders.getTimestamp("created_at");
                    if (ca != null) {
                        order.setCreatedAt(ca.toLocalDateTime());
                    }
                    
                    Timestamp ua = rsOrders.getTimestamp("updated_at");
                    if (ua != null) {
                        order.setUpdatedAt(ua.toLocalDateTime());
                    }

                    // Custom WMS fields
                    order.setTrackingNo(rsOrders.getString("tracking_no"));
                    order.setReviewNote(rsOrders.getString("review_note"));
                    order.setRmaReason(rsOrders.getString("rma_reason"));
                    order.setRmaPhysicalStatus(rsOrders.getString("rma_physical_status"));
                    order.setRmaPlatformStatus(rsOrders.getString("rma_platform_status"));
                    order.setDisputeEvidenceVideo(rsOrders.getString("dispute_evidence_video"));
                    order.setDisputeNote(rsOrders.getString("dispute_note"));

                    // Customer & recipient details
                    String recipientName = rsOrders.getString("recipient_name");
                    String userFullName = rsOrders.getString("customer_name");
                    String finalCustomerName = (recipientName != null && !recipientName.trim().isEmpty())
                            ? recipientName
                            : ((userFullName != null && !userFullName.trim().isEmpty()) ? userFullName : "Khách hàng #" + (order.getCustomerId() != null ? order.getCustomerId() : "N/A"));
                    order.setCustomerName(finalCustomerName);

                    String customerPhone = rsOrders.getString("customer_phone");
                    order.setCustomerPhone(customerPhone != null ? customerPhone : "Chưa có SĐT");

                    String shippingAddress = rsOrders.getString("shipping_address");
                    order.setCustomerAddress(shippingAddress != null ? shippingAddress : "Chưa có địa chỉ");

                    // Query and set items
                    psItems.setInt(1, orderId);
                    try (ResultSet rsItems = psItems.executeQuery()) {
                        List<OrderItem> items = new ArrayList<>();
                        while (rsItems.next()) {
                            OrderItem item = new OrderItem();
                            item.setProductId(rsItems.getInt("product_id"));
                            item.setSkuCode(rsItems.getString("sku_code"));
                            item.setProductName(rsItems.getString("product_name"));
                            item.setQuantity(rsItems.getInt("qty"));
                            item.setUnitPrice(rsItems.getDouble("unit_price"));
                            items.add(item);
                        }
                        order.setItems(items);
                    }

                    list.add(order);
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "OrderDAO: Failed to retrieve orders", e);
        }
        return list;
    }

    /**
     * Tự động nhận diện kênh bán hàng dựa vào tên kênh thô, ghi chú đơn hàng hoặc mã vận đơn.
     */
    private String detectChannel(String rawChannel, String note, String trackingNo) {
        if (note != null) {
            String noteLower = note.toLowerCase();
            if (noteLower.contains("shopee")) return "Shopee";
            if (noteLower.contains("lazada")) return "Lazada";
            if (noteLower.contains("tiktok")) return "TikTok";
            if (noteLower.contains("website") || noteLower.contains("web")) return "Website";
        }
        if (trackingNo != null) {
            String trackingLower = trackingNo.toLowerCase();
            if (trackingLower.startsWith("lze") || trackingLower.contains("lazada")) return "Lazada";
            if (trackingLower.startsWith("tkt") || trackingLower.contains("tiktok")) return "TikTok";
            if (trackingLower.startsWith("vtp") || trackingLower.contains("viettel")) return "Website";
            if (trackingLower.startsWith("spx") || trackingLower.contains("shopee")) return "Shopee";
        }
        if ("ONLINE".equalsIgnoreCase(rawChannel)) {
            return "Lazada"; // Mặc định là Lazada cho các đơn ONLINE khác nếu không phân tích được
        }
        return rawChannel;
    }

    public boolean updateOrderStatusAndWarehouse(String orderCode, String status, int warehouseId, String reviewNote) {
        String sql = "UPDATE orders SET status = ?, warehouse_id = ?, review_note = ?, updated_at = CURRENT_TIMESTAMP WHERE order_code = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, warehouseId);
            ps.setString(3, reviewNote);
            ps.setString(4, orderCode);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "OrderDAO: Failed to update order status and warehouse", e);
        }
        return false;
    }

    public boolean updateOrderTrackingNo(String orderCode, String trackingNo) {
        String sql = "UPDATE orders SET tracking_no = ?, status = 'PACKED', updated_at = CURRENT_TIMESTAMP WHERE order_code = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trackingNo);
            ps.setString(2, orderCode);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "OrderDAO: Failed to update tracking no", e);
        }
        return false;
    }

    public boolean updateOrderStatus(String orderCode, String status) {
        String sql = "UPDATE orders SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE order_code = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, orderCode);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "OrderDAO: Failed to update status", e);
        }
        return false;
    }

    public boolean updateOrderRMA(String orderCode, String status, String rmaReason, String rmaPhysicalStatus, String rmaPlatformStatus) {
        String sql = "UPDATE orders SET status = ?, rma_reason = ?, rma_physical_status = ?, rma_platform_status = ?, updated_at = CURRENT_TIMESTAMP WHERE order_code = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, rmaReason);
            ps.setString(3, rmaPhysicalStatus);
            ps.setString(4, rmaPlatformStatus);
            ps.setString(5, orderCode);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "OrderDAO: Failed to update order RMA", e);
        }
        return false;
    }

    public boolean updateOrderDispute(String orderCode, String status, String video, String note, String platformStatus) {
        String sql = "UPDATE orders SET status = ?, dispute_evidence_video = ?, dispute_note = ?, rma_platform_status = ?, updated_at = CURRENT_TIMESTAMP WHERE order_code = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, video);
            ps.setString(3, note);
            ps.setString(4, platformStatus);
            ps.setString(5, orderCode);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "OrderDAO: Failed to update order dispute", e);
        }
        return false;
    }

    /**
     * Returns top-selling products by total revenue for the dashboard.
     */
    public List<Product> getTopProducts(int limit) {
        List<Product> list = new ArrayList<>();
        String sql =
            "SELECT p.product_id, p.sku_code, p.product_name, SUM(oi.qty * oi.unit_price) AS total_revenue, COUNT(DISTINCT o.order_id) AS order_count " +
            "FROM order_items oi " +
            "JOIN products p ON oi.sku_id = p.product_id " +
            "JOIN orders o ON oi.order_id = o.order_id " +
            "WHERE o.status NOT IN ('CANCELLED','REJECTED') " +
            "GROUP BY p.product_id, p.sku_code, p.product_name " +
            "ORDER BY total_revenue DESC LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setProductId(rs.getInt("product_id"));
                    p.setSkuCode(rs.getString("sku_code"));
                    p.setProductName(rs.getString("product_name"));
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "OrderDAO.getTopProducts: failed", e);
        }
        return list;
    }

    public Order findByOrderCode(String orderCode) {
        String sql = "SELECT o.order_id, o.order_code, o.customer_id, o.warehouse_id, w.warehouse_name, "
                   + "o.channel, o.status, o.total_amount, o.note, o.created_by, o.created_at, "
                   + "o.tracking_no, o.review_note, "
                   + "sd.recipient_name, sd.shipping_address, u.phone AS customer_phone, u.full_name AS customer_name "
                   + "FROM orders o "
                   + "LEFT JOIN warehouses w ON o.warehouse_id = w.warehouse_id "
                   + "LEFT JOIN order_shipping_details sd ON o.order_id = sd.order_id "
                   + "LEFT JOIN users u ON o.customer_id = u.user_id "
                   + "WHERE o.order_code = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, orderCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getInt("order_id"));
                    order.setOrderCode(rs.getString("order_code"));
                    int customerId = rs.getInt("customer_id");
                    order.setCustomerId(rs.wasNull() ? null : customerId);
                    order.setWarehouseId(rs.getInt("warehouse_id"));
                    order.setWarehouseName(rs.getString("warehouse_name"));
                    order.setChannel(detectChannel(rs.getString("channel"), rs.getString("note"), rs.getString("tracking_no")));
                    order.setStatus(rs.getString("status"));
                    order.setTotalAmount(rs.getDouble("total_amount"));
                    int createdBy = rs.getInt("created_by");
                    order.setCreatedBy(rs.wasNull() ? null : createdBy);
                    Timestamp ca = rs.getTimestamp("created_at");
                    if (ca != null) order.setCreatedAt(ca.toLocalDateTime());
                    order.setTrackingNo(rs.getString("tracking_no"));
                    order.setReviewNote(rs.getString("review_note"));
                    String recipientName = rs.getString("recipient_name");
                    String userFullName = rs.getString("customer_name");
                    String finalCustomerName = (recipientName != null && !recipientName.trim().isEmpty())
                            ? recipientName
                            : ((userFullName != null && !userFullName.trim().isEmpty()) ? userFullName : "Khách hàng");
                    order.setCustomerName(finalCustomerName);
                    String customerPhone = rs.getString("customer_phone");
                    order.setCustomerPhone(customerPhone != null ? customerPhone : "Chưa có SĐT");
                    String shippingAddress = rs.getString("shipping_address");
                    order.setCustomerAddress(shippingAddress != null ? shippingAddress : "Chưa có địa chỉ");
                    return order;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "OrderDAO.findByOrderCode: failed for " + orderCode, e);
        }
        return null;
    }

    public List<OrderItem> findItemsByOrderId(int orderId) {
        List<OrderItem> items = new ArrayList<>();
        String sql = "SELECT p.product_id, p.sku_code, p.product_name, oi.qty, oi.unit_price "
                   + "FROM order_items oi "
                   + "JOIN products p ON oi.sku_id = p.product_id "
                   + "WHERE oi.order_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setProductId(rs.getInt("product_id"));
                    item.setSkuCode(rs.getString("sku_code"));
                    item.setProductName(rs.getString("product_name"));
                    item.setQuantity(rs.getInt("qty"));
                    item.setUnitPrice(rs.getDouble("unit_price"));
                    items.add(item);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "OrderDAO.findItemsByOrderId: failed for orderId=" + orderId, e);
        }
        return items;
    }
}
