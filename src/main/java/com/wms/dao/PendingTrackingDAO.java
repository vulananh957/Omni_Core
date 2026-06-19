package com.wms.dao;

import com.wms.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * PendingTrackingDAO — Danh sách đơn đã duyệt (PICKING) nhưng chưa có mã vận đơn,
 * filter theo kho mà Warehouse Staff phụ trách.
 * Trang web: /warehouse/pending-tracking
 */
public class PendingTrackingDAO {

    private static final Logger LOGGER = Logger.getLogger(PendingTrackingDAO.class.getName());

    /**
     * Lấy đơn PICKING + tracking_no IS NULL của 1 kho cụ thể.
     * @param warehouseId id kho; nếu <= 0 thì trả tất cả (cho admin)
     */
    public List<Map<String, Object>> findByWarehouse(int warehouseId) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder()
            .append("SELECT o.order_id, o.order_code, o.channel, o.status, o.tracking_no, ")
            .append("       o.total_amount, o.created_at, o.warehouse_id, ")
            .append("       c.channel_name, c.platform, ")
            .append("       w.warehouse_name, ")
            .append("       sd.courier_name, sd.shipping_address, sd.recipient_name, sd.waybill_code, ")
            .append("       u.full_name AS customer_name, u.phone AS customer_phone ")
            .append("FROM orders o ")
            .append("LEFT JOIN channels c        ON c.channel_name = o.channel ")
            .append("LEFT JOIN warehouses w      ON o.warehouse_id = w.warehouse_id ")
            .append("LEFT JOIN order_shipping_details sd ON o.order_id = sd.order_id ")
            .append("LEFT JOIN users u           ON o.customer_id = u.user_id ")
            .append("WHERE o.status = 'PICKING' ")
            .append("  AND (o.tracking_no IS NULL OR o.tracking_no = '') ");

        if (warehouseId > 0) {
            sql.append("AND o.warehouse_id = ? ");
        }
        sql.append("ORDER BY o.created_at ASC ");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            if (warehouseId > 0) {
                ps.setInt(1, warehouseId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("orderId",        rs.getInt("order_id"));
                    row.put("orderCode",      rs.getString("order_code"));
                    row.put("channel",        rs.getString("channel"));
                    row.put("channelName",    rs.getString("channel_name"));
                    row.put("platform",       rs.getString("platform"));
                    row.put("orderStatus",    rs.getString("status"));
                    row.put("warehouseId",    rs.getInt("warehouse_id"));
                    row.put("warehouseName",  rs.getString("warehouse_name"));
                    row.put("courierName",    rs.getString("courier_name"));
                    row.put("waybillCode",    rs.getString("waybill_code"));
                    row.put("trackingNo",     rs.getString("tracking_no"));
                    row.put("totalAmount",    rs.getDouble("total_amount"));
                    row.put("customerName",   rs.getString("customer_name"));
                    row.put("customerPhone",  rs.getString("customer_phone"));
                    row.put("shippingAddress",rs.getString("shipping_address"));
                    Timestamp ca = rs.getTimestamp("created_at");
                    if (ca != null) row.put("createdAt", ca.toLocalDateTime());
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "PendingTrackingDAO.findByWarehouse: failed", e);
        }
        return list;
    }

    /** Đếm số đơn chờ cấp tracking của 1 kho — dùng cho badge cảnh báo trên menu. */
    public int countByWarehouse(int warehouseId) {
        StringBuilder sql = new StringBuilder()
            .append("SELECT COUNT(*) FROM orders ")
            .append("WHERE status = 'PICKING' ")
            .append("  AND (tracking_no IS NULL OR tracking_no = '') ");
        if (warehouseId > 0) sql.append("AND warehouse_id = ? ");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (warehouseId > 0) ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "PendingTrackingDAO.countByWarehouse: failed", e);
        }
        return 0;
    }
}
