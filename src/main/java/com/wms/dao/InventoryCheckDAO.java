package com.wms.dao;

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
 * InventoryCheckDAO — Data Access Object for physical_inventories (Kiểm kê kho).
 *
 * Schema: physical_inventories + physical_inventory_details
 */
public class InventoryCheckDAO {

    private static final Logger LOGGER = Logger.getLogger(InventoryCheckDAO.class.getName());

    private static final String SQL_FIND_ALL =
        "SELECT pi.inventory_check_id, pi.check_code, pi.warehouse_id, "
      + "       w.warehouse_name, w.warehouse_code, "
      + "       pi.created_by, u.full_name AS creator_name, "
      + "       pi.status, pi.note, pi.created_at, "
      + "       (SELECT COUNT(*) FROM physical_inventory_details d "
      + "        WHERE d.inventory_check_id = pi.inventory_check_id) AS total_items, "
      + "       (SELECT COUNT(*) FROM physical_inventory_details d "
      + "        WHERE d.inventory_check_id = pi.inventory_check_id "
      + "          AND d.actual_qty IS NOT NULL) AS counted_items, "
      + "       (SELECT COALESCE(SUM(d.delta_qty), 0) FROM physical_inventory_details d "
      + "        WHERE d.inventory_check_id = pi.inventory_check_id) AS total_delta "
      + "FROM physical_inventories pi "
      + "LEFT JOIN warehouses w ON pi.warehouse_id = w.warehouse_id "
      + "LEFT JOIN users u      ON pi.created_by   = u.user_id "
      + "ORDER BY pi.created_at DESC LIMIT 200";

    private static final String SQL_FIND_BY_WAREHOUSE =
        "SELECT pi.inventory_check_id, pi.check_code, pi.warehouse_id, "
      + "       w.warehouse_name, w.warehouse_code, "
      + "       pi.created_by, u.full_name AS creator_name, "
      + "       pi.status, pi.note, pi.created_at, "
      + "       (SELECT COUNT(*) FROM physical_inventory_details d "
      + "        WHERE d.inventory_check_id = pi.inventory_check_id) AS total_items, "
      + "       (SELECT COUNT(*) FROM physical_inventory_details d "
      + "        WHERE d.inventory_check_id = pi.inventory_check_id "
      + "          AND d.actual_qty IS NOT NULL) AS counted_items, "
      + "       (SELECT COALESCE(SUM(d.delta_qty), 0) FROM physical_inventory_details d "
      + "        WHERE d.inventory_check_id = pi.inventory_check_id) AS total_delta "
      + "FROM physical_inventories pi "
      + "LEFT JOIN warehouses w ON pi.warehouse_id = w.warehouse_id "
      + "LEFT JOIN users u      ON pi.created_by   = u.user_id "
      + "WHERE pi.warehouse_id = ? "
      + "ORDER BY pi.created_at DESC LIMIT 200";

    private static final String SQL_FIND_DETAILS_BY_CHECK =
        "SELECT d.check_detail_id, d.inventory_check_id, d.product_id, "
      + "       p.sku_code, p.product_name, "
      + "       d.system_qty, d.actual_qty, d.delta_qty, d.counted_by, d.counted_at "
      + "FROM physical_inventory_details d "
      + "LEFT JOIN products p ON d.product_id = p.product_id "
      + "WHERE d.inventory_check_id = ? "
      + "ORDER BY d.check_detail_id";

    /**
     * Returns all physical inventory checks (newest first), with creator + summary stats.
     */
    public List<CheckHeader> findAll() {
        List<CheckHeader> out = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_FIND_ALL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(mapHeader(rs));
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "InventoryCheckDAO.findAll failed", e);
        }
        return out;
    }

    /**
     * Returns physical inventory checks for a specific warehouse.
     */
    public List<CheckHeader> findByWarehouse(int warehouseId) {
        List<CheckHeader> out = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_FIND_BY_WAREHOUSE)) {
            ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(mapHeader(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "InventoryCheckDAO.findByWarehouse failed", e);
        }
        return out;
    }

    /**
     * Returns the line items for a given inventory check, ordered by detail id.
     */
    public List<CheckDetail> findDetailsByCheckId(int checkId) {
        List<CheckDetail> out = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_FIND_DETAILS_BY_CHECK)) {
            ps.setInt(1, checkId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(mapDetail(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "InventoryCheckDAO.findDetailsByCheckId failed", e);
        }
        return out;
    }

    private CheckHeader mapHeader(ResultSet rs) throws SQLException {
        CheckHeader c = new CheckHeader();
        c.setCheckId(rs.getInt("inventory_check_id"));
        c.setCheckCode(rs.getString("check_code"));
        c.setWarehouseId(rs.getInt("warehouse_id"));
        c.setWarehouseName(rs.getString("warehouse_name"));
        c.setWarehouseCode(rs.getString("warehouse_code"));
        c.setCreatedBy(rs.getInt("created_by"));
        c.setCreatorName(rs.getString("creator_name"));
        c.setStatus(rs.getString("status"));
        c.setNote(rs.getString("note"));
        Timestamp ts = rs.getTimestamp("created_at");
        c.setCreatedAt(ts != null ? ts.toLocalDateTime() : null);
        c.setTotalItems(rs.getInt("total_items"));
        c.setCountedItems(rs.getInt("counted_items"));
        c.setTotalDelta(rs.getBigDecimal("total_delta"));
        return c;
    }

    private CheckDetail mapDetail(ResultSet rs) throws SQLException {
        CheckDetail d = new CheckDetail();
        d.setCheckDetailId(rs.getInt("check_detail_id"));
        d.setInventoryCheckId(rs.getInt("inventory_check_id"));
        d.setProductId(rs.getInt("product_id"));
        d.setSkuCode(rs.getString("sku_code"));
        d.setProductName(rs.getString("product_name"));
        d.setSystemQty(rs.getBigDecimal("system_qty"));
        d.setActualQty(rs.getBigDecimal("actual_qty"));
        d.setDeltaQty(rs.getBigDecimal("delta_qty"));
        d.setCountedBy(rs.getInt("counted_by"));
        Timestamp ts = rs.getTimestamp("counted_at");
        d.setCountedAt(ts != null ? ts.toLocalDateTime() : null);
        return d;
    }

    /* ── DTO classes ── */

    public static class CheckHeader {
        private int checkId;
        private String checkCode;
        private int warehouseId;
        private String warehouseName;
        private String warehouseCode;
        private int createdBy;
        private String creatorName;
        private String status;
        private String note;
        private java.time.LocalDateTime createdAt;
        private int totalItems;
        private int countedItems;
        private java.math.BigDecimal totalDelta;

        public int getCheckId() { return checkId; }
        public void setCheckId(int checkId) { this.checkId = checkId; }
        public String getCheckCode() { return checkCode; }
        public void setCheckCode(String checkCode) { this.checkCode = checkCode; }
        public int getWarehouseId() { return warehouseId; }
        public void setWarehouseId(int warehouseId) { this.warehouseId = warehouseId; }
        public String getWarehouseName() { return warehouseName; }
        public void setWarehouseName(String warehouseName) { this.warehouseName = warehouseName; }
        public String getWarehouseCode() { return warehouseCode; }
        public void setWarehouseCode(String warehouseCode) { this.warehouseCode = warehouseCode; }
        public int getCreatedBy() { return createdBy; }
        public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
        public String getCreatorName() { return creatorName; }
        public void setCreatorName(String creatorName) { this.creatorName = creatorName; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public String getNote() { return note; }
        public void setNote(String note) { this.note = note; }
        public java.time.LocalDateTime getCreatedAt() { return createdAt; }
        public void setCreatedAt(java.time.LocalDateTime createdAt) { this.createdAt = createdAt; }
        public int getTotalItems() { return totalItems; }
        public void setTotalItems(int totalItems) { this.totalItems = totalItems; }
        public int getCountedItems() { return countedItems; }
        public void setCountedItems(int countedItems) { this.countedItems = countedItems; }
        public java.math.BigDecimal getTotalDelta() { return totalDelta; }
        public void setTotalDelta(java.math.BigDecimal totalDelta) { this.totalDelta = totalDelta; }
    }

    public static class CheckDetail {
        private int checkDetailId;
        private int inventoryCheckId;
        private int productId;
        private String skuCode;
        private String productName;
        private java.math.BigDecimal systemQty;
        private java.math.BigDecimal actualQty;
        private java.math.BigDecimal deltaQty;
        private int countedBy;
        private java.time.LocalDateTime countedAt;

        public int getCheckDetailId() { return checkDetailId; }
        public void setCheckDetailId(int checkDetailId) { this.checkDetailId = checkDetailId; }
        public int getInventoryCheckId() { return inventoryCheckId; }
        public void setInventoryCheckId(int inventoryCheckId) { this.inventoryCheckId = inventoryCheckId; }
        public int getProductId() { return productId; }
        public void setProductId(int productId) { this.productId = productId; }
        public String getSkuCode() { return skuCode; }
        public void setSkuCode(String skuCode) { this.skuCode = skuCode; }
        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }
        public java.math.BigDecimal getSystemQty() { return systemQty; }
        public void setSystemQty(java.math.BigDecimal systemQty) { this.systemQty = systemQty; }
        public java.math.BigDecimal getActualQty() { return actualQty; }
        public void setActualQty(java.math.BigDecimal actualQty) { this.actualQty = actualQty; }
        public java.math.BigDecimal getDeltaQty() { return deltaQty; }
        public void setDeltaQty(java.math.BigDecimal deltaQty) { this.deltaQty = deltaQty; }
        public int getCountedBy() { return countedBy; }
        public void setCountedBy(int countedBy) { this.countedBy = countedBy; }
        public java.time.LocalDateTime getCountedAt() { return countedAt; }
        public void setCountedAt(java.time.LocalDateTime countedAt) { this.countedAt = countedAt; }
    }
}
