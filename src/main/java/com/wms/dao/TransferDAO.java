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
 * TransferDAO — Data Access Object for stock transfer records.
 */
public class TransferDAO {

    private static final Logger LOGGER = Logger.getLogger(TransferDAO.class.getName());

    private static final String SQL_FIND_ALL = "SELECT st.transfer_id, st.transfer_code, "
            + "st.from_warehouse_id, fw.warehouse_name AS from_warehouse_name, "
            + "st.to_warehouse_id,   tw.warehouse_name AS to_warehouse_name, "
            + "st.created_by, st.approved_by, st.status, st.note, st.created_at, st.completed_at "
            + "FROM stock_transfers st "
            + "LEFT JOIN warehouses fw ON st.from_warehouse_id = fw.warehouse_id "
            + "LEFT JOIN warehouses tw ON st.to_warehouse_id   = tw.warehouse_id "
            + "ORDER BY st.created_at DESC LIMIT 200";

    private static final String SQL_FIND_BY_ID = "SELECT st.transfer_id, st.transfer_code, "
            + "st.from_warehouse_id, fw.warehouse_name AS from_warehouse_name, "
            + "st.to_warehouse_id,   tw.warehouse_name AS to_warehouse_name, "
            + "st.created_by, st.approved_by, st.status, st.note, st.created_at, st.completed_at "
            + "FROM stock_transfers st "
            + "LEFT JOIN warehouses fw ON st.from_warehouse_id = fw.warehouse_id "
            + "LEFT JOIN warehouses tw ON st.to_warehouse_id   = tw.warehouse_id "
            + "WHERE st.transfer_id = ?";

    /**
     * Returns all stock transfers.
     */
    public List<Transfer> findAll() {
        List<Transfer> list = new ArrayList<>();
        String sql = SQL_FIND_ALL;

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Transfer t = new Transfer();
                t.setTransferId(rs.getInt("transfer_id"));
                t.setTransferCode(rs.getString("transfer_code"));
                t.setFromWarehouseId(rs.getInt("from_warehouse_id"));
                t.setFromWarehouseName(rs.getString("from_warehouse_name"));
                t.setToWarehouseId(rs.getInt("to_warehouse_id"));
                t.setToWarehouseName(rs.getString("to_warehouse_name"));
                t.setCreatedBy(rs.getInt("created_by"));
                t.setApprovedBy(rs.getObject("approved_by") != null ? rs.getInt("approved_by") : null);
                t.setStatus(rs.getString("status"));
                t.setNote(rs.getString("note"));
                java.sql.Timestamp ca = rs.getTimestamp("created_at");
                if (ca != null)
                    t.setCreatedAt(ca.toLocalDateTime());
                java.sql.Timestamp cma = rs.getTimestamp("completed_at");
                if (cma != null)
                    t.setCompletedAt(cma.toLocalDateTime());
                list.add(t);
            }

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "TransferDAO.findAll: failed", e);
        }
        return list;
    }

    /**
     * Returns a single transfer by ID.
     */
    public Transfer findById(int transferId) {
        String sql = SQL_FIND_BY_ID;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, transferId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Transfer t = new Transfer();
                    t.setTransferId(rs.getInt("transfer_id"));
                    t.setTransferCode(rs.getString("transfer_code"));
                    t.setFromWarehouseId(rs.getInt("from_warehouse_id"));
                    t.setFromWarehouseName(rs.getString("from_warehouse_name"));
                    t.setToWarehouseId(rs.getInt("to_warehouse_id"));
                    t.setToWarehouseName(rs.getString("to_warehouse_name"));
                    t.setCreatedBy(rs.getInt("created_by"));
                    t.setApprovedBy(rs.getObject("approved_by") != null ? rs.getInt("approved_by") : null);
                    t.setStatus(rs.getString("status"));
                    t.setNote(rs.getString("note"));
                    java.sql.Timestamp ca = rs.getTimestamp("created_at");
                    if (ca != null) t.setCreatedAt(ca.toLocalDateTime());
                    java.sql.Timestamp cma = rs.getTimestamp("completed_at");
                    if (cma != null) t.setCompletedAt(cma.toLocalDateTime());
                    return t;
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "TransferDAO.findById: failed for id=" + transferId, e);
        }
        return null;
    }

    /**
     * Maps user-facing status filter to database enum.
     */
    public String mapStatus(String status) {
        if (status == null) return null;
        switch (status.toUpperCase()) {
            case "PENDING":
            case "DRAFT":
                return "DRAFT";
            case "IN_TRANSIT":
            case "IN TRANSIT":
                return "IN_TRANSIT";
            case "COMPLETED":
            case "RECEIVED":
                return "RECEIVED";
            case "CANCELLED":
                return "CANCELLED";
            default:
                return null;
        }
    }

    /**
     * Returns a paginated list of stock transfers, optionally filtered by status and search query.
     */
    public List<Transfer> findTransfers(String status, String search, int offset, int limit) {
        List<Transfer> list = new ArrayList<>();
        String dbStatus = mapStatus(status);

        StringBuilder sql = new StringBuilder(
            "SELECT st.transfer_id, st.transfer_code, "
            + "st.from_warehouse_id, fw.warehouse_name AS from_warehouse_name, "
            + "st.to_warehouse_id,   tw.warehouse_name AS to_warehouse_name, "
            + "st.created_by, st.approved_by, st.status, st.note, st.created_at, st.completed_at "
            + "FROM stock_transfers st "
            + "LEFT JOIN warehouses fw ON st.from_warehouse_id = fw.warehouse_id "
            + "LEFT JOIN warehouses tw ON st.to_warehouse_id   = tw.warehouse_id "
        );

        boolean hasConditions = false;
        if (dbStatus != null || (search != null && !search.trim().isEmpty())) {
            sql.append("WHERE 1=1 ");
            if (dbStatus != null) {
                sql.append("AND st.status = ? ");
            }
            if (search != null && !search.trim().isEmpty()) {
                sql.append("AND (st.transfer_code LIKE ? OR fw.warehouse_name LIKE ? OR tw.warehouse_name LIKE ?) ");
            }
        }

        sql.append("ORDER BY st.created_at DESC LIMIT ? OFFSET ?");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIdx = 1;
            if (dbStatus != null) {
                ps.setString(paramIdx++, dbStatus);
            }
            if (search != null && !search.trim().isEmpty()) {
                String searchParam = "%" + search.trim() + "%";
                ps.setString(paramIdx++, searchParam);
                ps.setString(paramIdx++, searchParam);
                ps.setString(paramIdx++, searchParam);
            }
            ps.setInt(paramIdx++, limit);
            ps.setInt(paramIdx++, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Transfer t = new Transfer();
                    t.setTransferId(rs.getInt("transfer_id"));
                    t.setTransferCode(rs.getString("transfer_code"));
                    t.setFromWarehouseId(rs.getInt("from_warehouse_id"));
                    t.setFromWarehouseName(rs.getString("from_warehouse_name"));
                    t.setToWarehouseId(rs.getInt("to_warehouse_id"));
                    t.setToWarehouseName(rs.getString("to_warehouse_name"));
                    t.setCreatedBy(rs.getInt("created_by"));
                    t.setApprovedBy(rs.getObject("approved_by") != null ? rs.getInt("approved_by") : null);
                    t.setStatus(rs.getString("status"));
                    t.setNote(rs.getString("note"));
                    java.sql.Timestamp ca = rs.getTimestamp("created_at");
                    if (ca != null)
                        t.setCreatedAt(ca.toLocalDateTime());
                    java.sql.Timestamp cma = rs.getTimestamp("completed_at");
                    if (cma != null)
                        t.setCompletedAt(cma.toLocalDateTime());
                    list.add(t);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "TransferDAO.findTransfers failed", e);
        }
        return list;
    }

    /**
     * Counts the total number of stock transfers matching status and search query.
     */
    public int countTransfers(String status, String search) {
        String dbStatus = mapStatus(status);
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM stock_transfers st "
            + "LEFT JOIN warehouses fw ON st.from_warehouse_id = fw.warehouse_id "
            + "LEFT JOIN warehouses tw ON st.to_warehouse_id   = tw.warehouse_id "
        );

        if (dbStatus != null || (search != null && !search.trim().isEmpty())) {
            sql.append("WHERE 1=1 ");
            if (dbStatus != null) {
                sql.append("AND st.status = ? ");
            }
            if (search != null && !search.trim().isEmpty()) {
                sql.append("AND (st.transfer_code LIKE ? OR fw.warehouse_name LIKE ? OR tw.warehouse_name LIKE ?) ");
            }
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIdx = 1;
            if (dbStatus != null) {
                ps.setString(paramIdx++, dbStatus);
            }
            if (search != null && !search.trim().isEmpty()) {
                String searchParam = "%" + search.trim() + "%";
                ps.setString(paramIdx++, searchParam);
                ps.setString(paramIdx++, searchParam);
                ps.setString(paramIdx++, searchParam);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "TransferDAO.countTransfers failed", e);
        }
        return 0;
    }

    /**
     * Returns counts grouped by status.
     */
    public java.util.Map<String, Integer> getStatusCounts() {
        java.util.Map<String, Integer> counts = new java.util.HashMap<>();
        counts.put("all", 0);
        counts.put("DRAFT", 0);
        counts.put("IN_TRANSIT", 0);
        counts.put("RECEIVED", 0);
        counts.put("CANCELLED", 0);

        String sql = "SELECT status, COUNT(*) FROM stock_transfers GROUP BY status";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int total = 0;
            while (rs.next()) {
                String status = rs.getString("status");
                int count = rs.getInt(2);
                if (status != null) {
                    counts.put(status, count);
                    total += count;
                }
            }
            counts.put("all", total);
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "TransferDAO.getStatusCounts failed", e);
        }
        return counts;
    }

    public List<TransferItem> findItemsByTransferId(int transferId) {
        List<TransferItem> list = new ArrayList<>();
        String sql =
            "SELECT sti.transfer_item_id, sti.transfer_id, sti.product_id, "
          + "p.sku_code, p.product_name, sti.shipped_qty, sti.received_qty "
          + "FROM stock_transfer_items sti "
          + "LEFT JOIN products p ON sti.product_id = p.product_id "
          + "WHERE sti.transfer_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, transferId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TransferItem ti = new TransferItem();
                    ti.setTransferItemId(rs.getInt("transfer_item_id"));
                    ti.setTransferId(rs.getInt("transfer_id"));
                    ti.setProductId(rs.getInt("product_id"));
                    ti.setSkuCode(rs.getString("sku_code"));
                    ti.setProductName(rs.getString("product_name"));
                    ti.setShippedQty(rs.getBigDecimal("shipped_qty"));
                    ti.setReceivedQty(rs.getBigDecimal("received_qty"));
                    list.add(ti);
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "TransferDAO.findItemsByTransferId: failed for id=" + transferId, e);
        }
        return list;
    }

    /**
     * Simple domain object for StockTransfer.
     */
    public static class Transfer {
        public static final String STATUS_DRAFT     = "DRAFT";
        public static final String STATUS_IN_TRANSIT = "IN_TRANSIT";
        public static final String STATUS_RECEIVED  = "RECEIVED";
        public static final String STATUS_CANCELLED  = "CANCELLED";

        private int transferId;
        private String transferCode;
        private int fromWarehouseId;
        private String fromWarehouseName;
        private int toWarehouseId;
        private String toWarehouseName;
        private int createdBy;
        private Integer approvedBy;
        private String status;
        private String note;
        private java.time.LocalDateTime createdAt;
        private java.time.LocalDateTime completedAt;

        public int getTransferId() { return transferId; }
        public void setTransferId(int transferId) { this.transferId = transferId; }
        public String getTransferCode() { return transferCode; }
        public void setTransferCode(String transferCode) { this.transferCode = transferCode; }
        public int getFromWarehouseId() { return fromWarehouseId; }
        public void setFromWarehouseId(int fromWarehouseId) { this.fromWarehouseId = fromWarehouseId; }
        public String getFromWarehouseName() { return fromWarehouseName; }
        public void setFromWarehouseName(String fromWarehouseName) { this.fromWarehouseName = fromWarehouseName; }
        public int getToWarehouseId() { return toWarehouseId; }
        public void setToWarehouseId(int toWarehouseId) { this.toWarehouseId = toWarehouseId; }
        public String getToWarehouseName() { return toWarehouseName; }
        public void setToWarehouseName(String toWarehouseName) { this.toWarehouseName = toWarehouseName; }
        public int getCreatedBy() { return createdBy; }
        public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
        public Integer getApprovedBy() { return approvedBy; }
        public void setApprovedBy(Integer approvedBy) { this.approvedBy = approvedBy; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public String getNote() { return note; }
        public void setNote(String note) { this.note = note; }
        public java.time.LocalDateTime getCreatedAt() { return createdAt; }
        public void setCreatedAt(java.time.LocalDateTime createdAt) { this.createdAt = createdAt; }
        public java.time.LocalDateTime getCompletedAt() { return completedAt; }
        public void setCompletedAt(java.time.LocalDateTime completedAt) { this.completedAt = completedAt; }
    }

    /**
     * Simple domain object for TransferItem.
     */
    public static class TransferItem {
        private int transferItemId;
        private int transferId;
        private int productId;
        private String skuCode;
        private String productName;
        private java.math.BigDecimal shippedQty;
        private java.math.BigDecimal receivedQty;

        public int getTransferItemId() { return transferItemId; }
        public void setTransferItemId(int transferItemId) { this.transferItemId = transferItemId; }
        public int getTransferId() { return transferId; }
        public void setTransferId(int transferId) { this.transferId = transferId; }
        public int getProductId() { return productId; }
        public void setProductId(int productId) { this.productId = productId; }
        public String getSkuCode() { return skuCode; }
        public void setSkuCode(String skuCode) { this.skuCode = skuCode; }
        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }
        public java.math.BigDecimal getShippedQty() { return shippedQty; }
        public void setShippedQty(java.math.BigDecimal shippedQty) { this.shippedQty = shippedQty; }
        public java.math.BigDecimal getReceivedQty() { return receivedQty; }
        public void setReceivedQty(java.math.BigDecimal receivedQty) { this.receivedQty = receivedQty; }
    }
}
