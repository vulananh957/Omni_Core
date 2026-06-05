package com.wms.dao;

import com.wms.model.InboundOrder;
import com.wms.model.ReceiptNote;
import com.wms.util.DBConnection;

import java.math.BigDecimal;
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
 * InboundDAO — Data Access Object for inbound order records from MySQL.
 * Handles CRUD operations for inbound orders and receipt notes.
 */
public class InboundDAO {

    private static final Logger LOGGER = Logger.getLogger(InboundDAO.class.getName());

    // ══ InboundOrder queries ════════════════════════════════════════

    private static final String SQL_FIND_ALL =
        "SELECT io.inbound_id, io.inbound_code, io.supplier, io.warehouse_id, "
      + "w.warehouse_name, io.status, io.received_by, io.note, io.created_at, io.received_at "
      + "FROM inbound_orders io "
      + "LEFT JOIN warehouses w ON io.warehouse_id = w.warehouse_id "
      + "ORDER BY io.created_at DESC LIMIT 200";

    private static final String SQL_FIND_BY_ID =
        "SELECT io.inbound_id, io.inbound_code, io.supplier, io.warehouse_id, "
      + "w.warehouse_name, io.status, io.received_by, io.note, io.created_at, io.received_at "
      + "FROM inbound_orders io "
      + "LEFT JOIN warehouses w ON io.warehouse_id = w.warehouse_id "
      + "WHERE io.inbound_id = ?";

    private static final String SQL_FIND_BY_STATUS =
        "SELECT io.inbound_id, io.inbound_code, io.supplier, io.warehouse_id, "
      + "w.warehouse_name, io.status, io.received_by, io.note, io.created_at, io.received_at "
      + "FROM inbound_orders io "
      + "LEFT JOIN warehouses w ON io.warehouse_id = w.warehouse_id "
      + "WHERE io.status = ? "
      + "ORDER BY io.created_at DESC LIMIT 200";

    private static final String SQL_FIND_BY_WAREHOUSE =
        "SELECT io.inbound_id, io.inbound_code, io.supplier, io.warehouse_id, "
      + "w.warehouse_name, io.status, io.received_by, io.note, io.created_at, io.received_at "
      + "FROM inbound_orders io "
      + "LEFT JOIN warehouses w ON io.warehouse_id = w.warehouse_id "
      + "WHERE io.warehouse_id = ? "
      + "ORDER BY io.created_at DESC LIMIT 200";

    private static final String SQL_INSERT =
        "INSERT INTO inbound_orders (inbound_code, warehouse_id, supplier, status, created_by, note) "
      + "VALUES (?, ?, ?, ?, ?, ?)";

    private static final String SQL_UPDATE =
        "UPDATE inbound_orders SET inbound_code=?, warehouse_id=?, supplier=?, "
      + "status=?, received_by=?, note=? "
      + "WHERE inbound_id=?";

    private static final String SQL_UPDATE_STATUS =
        "UPDATE inbound_orders SET status=?, received_at=? WHERE inbound_id=?";

    private static final String SQL_NEXT_SEQUENCE =
        "SELECT COALESCE(MAX(CAST(SUBSTRING(inbound_code, 10) AS UNSIGNED)), 0) + 1 AS next_seq "
      + "FROM inbound_orders WHERE inbound_code LIKE ?";

    // ══ ReceiptNote queries ════════════════════════════════════════

    private static final String SQL_FIND_RECEIPTS_BY_INBOUND_ID =
        "SELECT ii.inbound_item_id AS receipt_id, ii.inbound_id, ii.product_id, "
      + "p.sku_code, p.product_name, "
      + "ii.expected_qty, ii.received_qty, "
      + "ii.received_qty AS accepted_qty, 0 AS rejected_qty, "
      + "NULL AS note, NULL AS received_at "
      + "FROM inbound_items ii "
      + "LEFT JOIN products p ON ii.product_id = p.product_id "
      + "WHERE ii.inbound_id = ?";

    private static final String SQL_INSERT_RECEIPT =
        "INSERT INTO inbound_items (inbound_id, product_id, expected_qty, received_qty) "
      + "VALUES (?, ?, ?, ?)";

    private static final String SQL_UPDATE_RECEIPT =
        "UPDATE inbound_items SET product_id=?, expected_qty=?, received_qty=? "
      + "WHERE inbound_item_id=?";

    // ══ InboundOrder row mapper ════════════════════════════════════

    private InboundOrder mapInboundOrder(ResultSet rs) throws SQLException {
        InboundOrder o = new InboundOrder();
        o.setInboundId(rs.getInt("inbound_id"));
        o.setInboundCode(rs.getString("inbound_code"));
        // Schema uses "supplier"; model uses "supplierName"
        o.setSupplierName(rs.getString("supplier"));
        o.setWarehouseId(rs.getInt("warehouse_id"));
        o.setWarehouseName(rs.getString("warehouse_name"));

        String status = rs.getString("status");
        o.setStatus(status != null ? status : InboundOrder.STATUS_PENDING);

        o.setCreatedBy(rs.getInt("created_by"));
        o.setNotes(rs.getString("note"));

        java.sql.Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) o.setCreatedAt(ca.toLocalDateTime());

        java.sql.Timestamp ra = rs.getTimestamp("received_at");
        if (ra != null) o.setReceivedDate(ra.toLocalDateTime().toLocalDate());

        return o;
    }

    // ══ ReceiptNote row mapper ════════════════════════════════════

    private ReceiptNote mapReceiptNote(ResultSet rs) throws SQLException {
        ReceiptNote rn = new ReceiptNote();
        rn.setReceiptId(rs.getInt("receipt_id"));
        rn.setInboundId(rs.getInt("inbound_id"));
        rn.setProductId(rs.getInt("product_id"));
        rn.setSkuCode(rs.getString("sku_code"));
        rn.setProductName(rs.getString("product_name"));

        BigDecimal eq = rs.getBigDecimal("expected_qty");
        rn.setExpectedQty(eq != null ? eq : BigDecimal.ZERO);

        BigDecimal rq = rs.getBigDecimal("received_qty");
        rn.setReceivedQty(rq != null ? rq : BigDecimal.ZERO);

        BigDecimal aq = rs.getBigDecimal("accepted_qty");
        rn.setAcceptedQty(aq != null ? aq : BigDecimal.ZERO);

        BigDecimal djq = rs.getBigDecimal("rejected_qty");
        rn.setRejectedQty(djq != null ? djq : BigDecimal.ZERO);

        rn.setNote(rs.getString("note"));

        java.sql.Timestamp ra = rs.getTimestamp("received_at");
        if (ra != null) rn.setReceivedAt(ra.toLocalDateTime());

        return rn;
    }

    // ══ InboundOrder CRUD ══════════════════════════════════════════

    /**
     * Returns the latest 200 inbound orders.
     */
    public List<InboundOrder> findAll() {
        List<InboundOrder> list = new ArrayList<>();
        String sql = SQL_FIND_ALL;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapInboundOrder(rs));
            }

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "InboundDAO.findAll: failed to retrieve inbound orders", e);
        }
        return list;
    }

    /**
     * Returns a single inbound order by ID, or null if not found.
     */
    public InboundOrder findById(int inboundId) {
        String sql = SQL_FIND_BY_ID;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, inboundId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapInboundOrder(rs);
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "InboundDAO.findById: failed for inboundId=" + inboundId, e);
        }
        return null;
    }

    /**
     * Returns inbound orders filtered by status.
     */
    public List<InboundOrder> findByStatus(String status) {
        List<InboundOrder> list = new ArrayList<>();
        String sql = SQL_FIND_BY_STATUS;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapInboundOrder(rs));
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "InboundDAO.findByStatus: failed for status=" + status, e);
        }
        return list;
    }

    /**
     * Returns inbound orders for a specific warehouse.
     */
    public List<InboundOrder> findByWarehouse(int warehouseId) {
        List<InboundOrder> list = new ArrayList<>();
        String sql = SQL_FIND_BY_WAREHOUSE;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapInboundOrder(rs));
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "InboundDAO.findByWarehouse: failed for warehouseId=" + warehouseId, e);
        }
        return list;
    }

    /**
     * Generates the next inbound code in format IN-YYYYMMDD-XXX.
     * Thread-safe within a transaction.
     */
    public String generateNextInboundCode(Connection conn) throws SQLException {
        String today = java.time.LocalDate.now().toString().replace("-", "");
        String prefix = "IN-" + today + "-%";

        try (PreparedStatement ps = conn.prepareStatement(SQL_NEXT_SEQUENCE)) {
            ps.setString(1, prefix);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int nextSeq = rs.getInt("next_seq");
                    return String.format("IN-%s-%03d", today, nextSeq);
                }
            }
        }
        String fallbackToday = java.time.LocalDate.now().toString().replace("-", "");
        return String.format("IN-%s-001", fallbackToday);
    }

    /**
     * Inserts a new inbound order and returns the generated inboundId.
     */
    public int insert(InboundOrder order) {
        String sql = SQL_INSERT;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

            String inboundCode;
            try {
                inboundCode = generateNextInboundCode(conn);
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "InboundDAO.insert: failed to generate code", e);
                inboundCode = "IN-" + System.currentTimeMillis();
            }
            order.setInboundCode(inboundCode);

            ps.setString(1, order.getInboundCode());
            ps.setInt(2, order.getWarehouseId());
            ps.setString(3, order.getSupplierName());
            ps.setString(4, order.getStatus() != null ? order.getStatus() : InboundOrder.STATUS_PENDING);
            ps.setInt(5, order.getCreatedBy());
            ps.setString(6, order.getNotes());

            int rows = ps.executeUpdate();

            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        int id = keys.getInt(1);
                        order.setInboundId(id);
                        return id;
                    }
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "InboundDAO.insert: failed to insert inbound order", e);
        }
        return -1;
    }

    /**
     * Updates an existing inbound order.
     */
    public boolean update(InboundOrder order) {
        String sql = SQL_UPDATE;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, order.getInboundCode());
            ps.setInt(2, order.getWarehouseId());
            ps.setString(3, order.getSupplierName());
            ps.setString(4, order.getStatus());
            ps.setInt(5, order.getCreatedBy());
            ps.setString(6, order.getNotes());
            ps.setInt(7, order.getInboundId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "InboundDAO.update: failed to update inbound order id=" + order.getInboundId(), e);
            return false;
        }
    }

    /**
     * Updates only the status of an inbound order.
     */
    public boolean updateStatus(int inboundId, String status) {
        String sql = SQL_UPDATE_STATUS;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setObject(2, InboundOrder.STATUS_RECEIVED.equals(status)
                ? Timestamp.valueOf(java.time.LocalDateTime.now()) : null, java.sql.Types.TIMESTAMP);
            ps.setInt(3, inboundId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "InboundDAO.updateStatus: failed for inboundId=" + inboundId + ", status=" + status, e);
            return false;
        }
    }

    // ══ ReceiptNote CRUD ═══════════════════════════════════════════

    /**
     * Returns all receipt line items for a given inbound order.
     */
    public List<ReceiptNote> findReceiptsByInboundId(int inboundId) {
        List<ReceiptNote> list = new ArrayList<>();
        String sql = SQL_FIND_RECEIPTS_BY_INBOUND_ID;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, inboundId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapReceiptNote(rs));
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "InboundDAO.findReceiptsByInboundId: failed for inboundId=" + inboundId, e);
        }
        return list;
    }

    /**
     * Inserts a new receipt note line item.
     */
    public boolean insertReceipt(ReceiptNote receipt) {
        String sql = SQL_INSERT_RECEIPT;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, receipt.getInboundId());
            ps.setInt(2, receipt.getProductId());
            ps.setBigDecimal(3, receipt.getExpectedQty() != null ? receipt.getExpectedQty() : BigDecimal.ZERO);
            ps.setBigDecimal(4, receipt.getReceivedQty() != null ? receipt.getReceivedQty() : BigDecimal.ZERO);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        receipt.setReceiptId(keys.getInt(1));
                    }
                }
                return true;
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "InboundDAO.insertReceipt: failed to insert receipt for inboundId=" + receipt.getInboundId(), e);
        }
        return false;
    }

    /**
     * Updates an existing receipt note.
     */
    public boolean updateReceipt(ReceiptNote receipt) {
        String sql = SQL_UPDATE_RECEIPT;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, receipt.getProductId());
            ps.setBigDecimal(2, receipt.getExpectedQty() != null ? receipt.getExpectedQty() : BigDecimal.ZERO);
            ps.setBigDecimal(3, receipt.getReceivedQty() != null ? receipt.getReceivedQty() : BigDecimal.ZERO);
            ps.setInt(4, receipt.getReceiptId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "InboundDAO.updateReceipt: failed to update receiptId=" + receipt.getReceiptId(), e);
            return false;
        }
    }
}
