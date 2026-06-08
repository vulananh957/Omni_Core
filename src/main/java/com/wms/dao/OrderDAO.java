package com.wms.dao;

import com.wms.model.Order;
import com.wms.model.OrderItem;
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
        String sqlOrders = "SELECT o.order_id, o.order_code, o.customer_id, o.warehouse_id, w.warehouse_name, o.channel, o.status, o.total_amount, o.created_by, o.created_at, o.updated_at, "
                           + "o.tracking_no, o.review_note, o.rma_reason, o.rma_physical_status, o.rma_platform_status, o.dispute_evidence_video, o.dispute_note "
                           + "FROM orders o "
                           + "LEFT JOIN warehouses w ON o.warehouse_id = w.warehouse_id "
                           + "ORDER BY o.created_at DESC LIMIT 100";
        String sqlItems = "SELECT s.sku_code, s.product_name, oi.qty, oi.unit_price " +
                          "FROM order_items oi " +
                          "JOIN skus s ON oi.sku_id = s.sku_id " +
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
                    order.setChannel(rsOrders.getString("channel"));
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

                    // Query and set items
                    psItems.setInt(1, orderId);
                    try (ResultSet rsItems = psItems.executeQuery()) {
                        List<OrderItem> items = new ArrayList<>();
                        while (rsItems.next()) {
                            OrderItem item = new OrderItem();
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
}
