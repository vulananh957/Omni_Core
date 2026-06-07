package com.wms.dao;

import com.wms.model.OutboundItem;
import com.wms.model.OutboundOrder;
import com.wms.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * OutboundDAO — Data Access Object for outbound order and item operations.
 */
public class OutboundDAO {

    private static final Logger LOGGER = Logger.getLogger(OutboundDAO.class.getName());

    /**
     * Retrieves all outbound orders (top 100, newest first).
     */
    public List<OutboundOrder> findAll() {
        List<OutboundOrder> list = new ArrayList<>();
        String sql = "SELECT o.outbound_id, o.outbound_code, o.order_id, o.warehouse_id, "
                   + "w.warehouse_name, o.status, o.notes, o.created_at, o.picked_by, o.picked_at "
                   + "FROM outbound_orders o "
                   + "LEFT JOIN warehouses w ON o.warehouse_id = w.warehouse_id "
                   + "ORDER BY o.created_at DESC LIMIT 100";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "OutboundDAO: Failed to retrieve outbound orders", e);
        }
        return list;
    }

    /**
     * Finds a single outbound order by ID.
     */
    public OutboundOrder findById(int id) {
        String sql = "SELECT o.outbound_id, o.outbound_code, o.order_id, o.warehouse_id, "
                   + "w.warehouse_name, o.status, o.notes, o.created_at, o.picked_by, o.picked_at "
                   + "FROM outbound_orders o "
                   + "LEFT JOIN warehouses w ON o.warehouse_id = w.warehouse_id "
                   + "WHERE o.outbound_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "OutboundDAO: Failed to find outbound order by id=" + id, e);
        }
        return null;
    }

    /**
     * Finds outbound orders filtered by status.
     */
    public List<OutboundOrder> findByStatus(String status) {
        List<OutboundOrder> list = new ArrayList<>();
        String sql = "SELECT o.outbound_id, o.outbound_code, o.order_id, o.warehouse_id, "
                   + "w.warehouse_name, o.status, o.notes, o.created_at, o.picked_by, o.picked_at "
                   + "FROM outbound_orders o "
                   + "LEFT JOIN warehouses w ON o.warehouse_id = w.warehouse_id "
                   + "WHERE o.status = ? "
                   + "ORDER BY o.created_at DESC LIMIT 100";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "OutboundDAO: Failed to find outbound orders by status=" + status, e);
        }
        return list;
    }

    /**
     * Finds outbound orders filtered by warehouse.
     */
    public List<OutboundOrder> findByWarehouse(int warehouseId) {
        List<OutboundOrder> list = new ArrayList<>();
        String sql = "SELECT o.outbound_id, o.outbound_code, o.order_id, o.warehouse_id, "
                   + "w.warehouse_name, o.status, o.notes, o.created_at, o.picked_by, o.picked_at "
                   + "FROM outbound_orders o "
                   + "LEFT JOIN warehouses w ON o.warehouse_id = w.warehouse_id "
                   + "WHERE o.warehouse_id = ? "
                   + "ORDER BY o.created_at DESC LIMIT 100";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "OutboundDAO: Failed to find outbound orders by warehouse=" + warehouseId, e);
        }
        return list;
    }

    /**
     * Inserts a new outbound order and returns the generated outboundId.
     */
    public int insert(OutboundOrder order) {
        String sql = "INSERT INTO outbound_orders "
                   + "(outbound_code, order_id, warehouse_id, status, notes, created_at, picked_by, picked_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, order.getOutboundCode());
            ps.setInt(2, order.getOrderId());
            ps.setInt(3, order.getWarehouseId());
            ps.setString(4, order.getStatus() != null ? order.getStatus() : OutboundOrder.STATUS_PENDING);
            ps.setString(5, order.getNotes());
            ps.setTimestamp(6, order.getCreatedAt() != null ? Timestamp.valueOf(order.getCreatedAt()) : new Timestamp(System.currentTimeMillis()));
            if (order.getPickedBy() != null) {
                ps.setInt(7, order.getPickedBy());
            } else {
                ps.setNull(7, java.sql.Types.INTEGER);
            }
            ps.setTimestamp(8, order.getPickedAt() != null ? Timestamp.valueOf(order.getPickedAt()) : null);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "OutboundDAO: Failed to insert outbound order", e);
        }
        return -1;
    }

    /**
     * Updates an existing outbound order.
     */
    public boolean update(OutboundOrder order) {
        String sql = "UPDATE outbound_orders SET "
                   + "outbound_code = ?, order_id = ?, warehouse_id = ?, status = ?, "
                   + "notes = ?, picked_by = ?, picked_at = ? "
                   + "WHERE outbound_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, order.getOutboundCode());
            ps.setInt(2, order.getOrderId());
            ps.setInt(3, order.getWarehouseId());
            ps.setString(4, order.getStatus());
            ps.setString(5, order.getNotes());
            if (order.getPickedBy() != null) {
                ps.setInt(6, order.getPickedBy());
            } else {
                ps.setNull(6, java.sql.Types.INTEGER);
            }
            ps.setTimestamp(7, order.getPickedAt() != null ? Timestamp.valueOf(order.getPickedAt()) : null);
            ps.setInt(8, order.getOutboundId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "OutboundDAO: Failed to update outbound order id=" + order.getOutboundId(), e);
        }
        return false;
    }

    /**
     * Updates only the status of an outbound order.
     */
    public boolean updateStatus(int outboundId, String status) {
        String sql = "UPDATE outbound_orders SET status = ? WHERE outbound_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, outboundId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "OutboundDAO: Failed to update status for id=" + outboundId, e);
        }
        return false;
    }

    /**
     * Retrieves all line items for a given outbound order.
     */
    public List<OutboundItem> findItemsByOutboundId(int outboundId) {
        List<OutboundItem> list = new ArrayList<>();
        String sql = "SELECT i.outbound_item_id, i.outbound_id, i.product_id, i.qty, i.picked_qty, i.shelf_location, "
                   + "p.sku_code, p.product_name "
                   + "FROM outbound_items i "
                   + "LEFT JOIN products p ON i.product_id = p.product_id "
                   + "WHERE i.outbound_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, outboundId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OutboundItem item = new OutboundItem();
                    item.setOutboundItemId(rs.getInt("outbound_item_id"));
                    item.setOutboundId(rs.getInt("outbound_id"));
                    item.setProductId(rs.getInt("product_id"));
                    item.setQty(rs.getBigDecimal("qty"));
                    item.setPickedQty(rs.getBigDecimal("picked_qty"));
                    item.setShelfLocation(rs.getString("shelf_location"));
                    item.setSkuCode(rs.getString("sku_code"));
                    item.setSkuName(rs.getString("product_name"));
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "OutboundDAO: Failed to retrieve items for outboundId=" + outboundId, e);
        }
        return list;
    }

    /**
     * Inserts a single outbound line item.
     */
    public boolean insertItem(OutboundItem item) {
        String sql = "INSERT INTO outbound_items "
                   + "(outbound_id, product_id, qty, picked_qty, shelf_location) "
                   + "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, item.getOutboundId());
            ps.setInt(2, item.getProductId());
            ps.setBigDecimal(3, item.getQty());
            ps.setBigDecimal(4, item.getPickedQty() != null ? item.getPickedQty() : BigDecimal.ZERO);
            ps.setString(5, item.getShelfLocation());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "OutboundDAO: Failed to insert outbound item", e);
        }
        return false;
    }

    /**
     * Maps a ResultSet row to an OutboundOrder instance.
     */
    private OutboundOrder mapRow(ResultSet rs) throws SQLException {
        OutboundOrder o = new OutboundOrder();
        o.setOutboundId(rs.getInt("outbound_id"));
        o.setOutboundCode(rs.getString("outbound_code"));
        o.setOrderId(rs.getInt("order_id"));
        o.setWarehouseId(rs.getInt("warehouse_id"));
        o.setWarehouseName(rs.getString("warehouse_name"));
        o.setStatus(rs.getString("status"));
        o.setNotes(rs.getString("notes"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            o.setCreatedAt(createdAt.toLocalDateTime());
        }

        int pickedBy = rs.getInt("picked_by");
        o.setPickedBy(rs.wasNull() ? null : pickedBy);

        Timestamp pickedAt = rs.getTimestamp("picked_at");
        if (pickedAt != null) {
            o.setPickedAt(pickedAt.toLocalDateTime());
        }

        return o;
    }
}
