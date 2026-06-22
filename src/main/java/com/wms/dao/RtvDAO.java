package com.wms.dao;

import com.wms.model.RtvOrder;
import com.wms.model.RtvItem;
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

public class RtvDAO {
    private static final Logger LOGGER = Logger.getLogger(RtvDAO.class.getName());

    public RtvDAO() {
        ensureTablesExist();
    }

    private void ensureTablesExist() {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS rtv_orders ("
                    + "rtv_id INT AUTO_INCREMENT PRIMARY KEY,"
                    + "rtv_code VARCHAR(50) NOT NULL UNIQUE,"
                    + "inbound_id INT NOT NULL,"
                    + "warehouse_id INT NOT NULL,"
                    + "supplier_name VARCHAR(100),"
                    + "status ENUM('PENDING','APPROVED','COMPLETED','CANCELLED') NOT NULL DEFAULT 'PENDING',"
                    + "reason VARCHAR(255),"
                    + "note VARCHAR(255),"
                    + "created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,"
                    + "created_by INT"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS rtv_items ("
                    + "rtv_item_id INT AUTO_INCREMENT PRIMARY KEY,"
                    + "rtv_id INT NOT NULL,"
                    + "product_id INT NOT NULL,"
                    + "qty_return DECIMAL(12,3) NOT NULL,"
                    + "unit_cost DECIMAL(12,3) NOT NULL,"
                    + "FOREIGN KEY (rtv_id) REFERENCES rtv_orders(rtv_id) ON DELETE CASCADE"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to initialize RTV tables", e);
        }
    }

    public List<RtvOrder> findByWarehouse(int warehouseId) {
        List<RtvOrder> list = new ArrayList<>();
        String sql = "SELECT r.rtv_id, r.rtv_code, r.inbound_id, io.inbound_code, r.warehouse_id, w.warehouse_name,"
                + " r.supplier_name, r.status, r.reason, r.note, r.created_at,"
                + " ri.product_id, p.sku_code, p.product_name, ri.qty_return, ri.unit_cost"
                + " FROM rtv_orders r"
                + " LEFT JOIN inbound_orders io ON r.inbound_id = io.inbound_id"
                + " LEFT JOIN warehouses w ON r.warehouse_id = w.warehouse_id"
                + " LEFT JOIN rtv_items ri ON r.rtv_id = ri.rtv_id"
                + " LEFT JOIN products p ON ri.product_id = p.product_id"
                + " WHERE r.warehouse_id = ?"
                + " ORDER BY r.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                RtvOrder current = null;
                while (rs.next()) {
                    int rtvId = rs.getInt("rtv_id");
                    if (current == null || current.getId() != rtvId) {
                        if (current != null) {
                            list.add(current);
                        }
                        current = new RtvOrder();
                        current.setId(rtvId);
                        current.setCode(rs.getString("rtv_code"));
                        current.setInboundId(rs.getInt("inbound_id"));
                        current.setInboundCode(rs.getString("inbound_code"));
                        current.setWarehouseId(rs.getInt("warehouse_id"));
                        current.setWarehouseName(rs.getString("warehouse_name"));
                        current.setSupplier(rs.getString("supplier_name"));
                        current.setStatus(rs.getString("status"));
                        current.setReason(rs.getString("reason"));
                        current.setNote(rs.getString("note"));
                        
                        Timestamp ca = rs.getTimestamp("created_at");
                        if (ca != null) {
                            current.setCreatedAt(ca.toString());
                        }
                        current.setItems(new ArrayList<>());
                    }
                    
                    int productId = rs.getInt("product_id");
                    if (productId > 0) {
                        RtvItem item = new RtvItem();
                        item.setProductId(productId);
                        item.setSku(rs.getString("sku_code"));
                        item.setName(rs.getString("product_name"));
                        item.setQtyReturn(rs.getBigDecimal("qty_return"));
                        item.setUnitCost(rs.getBigDecimal("unit_cost"));
                        current.getItems().add(item);
                    }
                }
                if (current != null) {
                    list.add(current);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to find RTV orders by warehouseId=" + warehouseId, e);
        }
        return list;
    }

    public RtvOrder findById(int rtvId) {
        String sql = "SELECT r.rtv_id, r.rtv_code, r.inbound_id, io.inbound_code, r.warehouse_id, w.warehouse_name,"
                + " r.supplier_name, r.status, r.reason, r.note, r.created_at,"
                + " ri.product_id, p.sku_code, p.product_name, ri.qty_return, ri.unit_cost"
                + " FROM rtv_orders r"
                + " LEFT JOIN inbound_orders io ON r.inbound_id = io.inbound_id"
                + " LEFT JOIN warehouses w ON r.warehouse_id = w.warehouse_id"
                + " LEFT JOIN rtv_items ri ON r.rtv_id = ri.rtv_id"
                + " LEFT JOIN products p ON ri.product_id = p.product_id"
                + " WHERE r.rtv_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rtvId);
            try (ResultSet rs = ps.executeQuery()) {
                RtvOrder current = null;
                while (rs.next()) {
                    if (current == null) {
                        current = new RtvOrder();
                        current.setId(rtvId);
                        current.setCode(rs.getString("rtv_code"));
                        current.setInboundId(rs.getInt("inbound_id"));
                        current.setInboundCode(rs.getString("inbound_code"));
                        current.setWarehouseId(rs.getInt("warehouse_id"));
                        current.setWarehouseName(rs.getString("warehouse_name"));
                        current.setSupplier(rs.getString("supplier_name"));
                        current.setStatus(rs.getString("status"));
                        current.setReason(rs.getString("reason"));
                        current.setNote(rs.getString("note"));
                        
                        Timestamp ca = rs.getTimestamp("created_at");
                        if (ca != null) {
                            current.setCreatedAt(ca.toString());
                        }
                        current.setItems(new ArrayList<>());
                    }
                    
                    int productId = rs.getInt("product_id");
                    if (productId > 0) {
                        RtvItem item = new RtvItem();
                        item.setProductId(productId);
                        item.setSku(rs.getString("sku_code"));
                        item.setName(rs.getString("product_name"));
                        item.setQtyReturn(rs.getBigDecimal("qty_return"));
                        item.setUnitCost(rs.getBigDecimal("unit_cost"));
                        current.getItems().add(item);
                    }
                }
                return current;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to find RTV order by rtvId=" + rtvId, e);
        }
        return null;
    }

    public int insert(RtvOrder rtv) {
        String sqlOrder = "INSERT INTO rtv_orders (rtv_code, inbound_id, warehouse_id, supplier_name, status, reason, note, created_by) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String code = "RTV-" + System.currentTimeMillis();
                try (Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery("SELECT COUNT(*) + 1 FROM rtv_orders")) {
                    if (rs.next()) {
                        code = String.format("RTV-%05d", rs.getInt(1));
                    }
                } catch (SQLException e) {
                    LOGGER.fine("Failed to generate sequential RTV code: " + e.getMessage());
                }
                rtv.setCode(code);

                int rtvId = -1;
                try (PreparedStatement ps = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, rtv.getCode());
                    ps.setInt(2, rtv.getInboundId());
                    ps.setInt(3, rtv.getWarehouseId());
                    ps.setString(4, rtv.getSupplier());
                    ps.setString(5, rtv.getStatus());
                    ps.setString(6, rtv.getReason());
                    ps.setString(7, rtv.getNote());
                    ps.setInt(8, 1); // Default created_by
                    
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) {
                            rtvId = keys.getInt(1);
                        }
                    }
                }

                if (rtvId > 0) {
                    rtv.setId(rtvId);
                    String sqlItem = "INSERT INTO rtv_items (rtv_id, product_id, qty_return, unit_cost) VALUES (?, ?, ?, ?)";
                    try (PreparedStatement psItem = conn.prepareStatement(sqlItem)) {
                        for (RtvItem item : rtv.getItems()) {
                            psItem.setInt(1, rtvId);
                            psItem.setInt(2, item.getProductId());
                            psItem.setBigDecimal(3, item.getQtyReturn());
                            psItem.setBigDecimal(4, item.getUnitCost());
                            psItem.addBatch();
                        }
                        psItem.executeBatch();
                    }
                }
                conn.commit();
                return rtvId;
            } catch (SQLException e) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Transaction rolled back during RTV insert", e);
                return -1;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to insert RTV order", e);
        }
        return -1;
    }

    public boolean updateStatus(int rtvId, String status) {
        String sql = "UPDATE rtv_orders SET status = ? WHERE rtv_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, rtvId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to update RTV status: rtvId=" + rtvId + ", status=" + status, e);
        }
        return false;
    }
}
