package com.wms.dao;

import com.wms.util.DBConnection;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LedgerDAO — Data Access Object for document approval workflows and global inventory ledger.
 */
public class LedgerDAO {

    private static final Logger LOGGER = Logger.getLogger(LedgerDAO.class.getName());
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    /**
     * DTO for representing a unified Warehouse Document.
     */
    public static class LedgerDocument {
        public String id;
        public String type; // "Phiếu Nhập Kho" | "Phiếu Xuất Kho" | "Phiếu Kiểm Kê" | "Phiếu Chuyển Kho" | "Phiếu Hoàn Hàng"
        public String date;
        public String warehouse;
        public int warehouseId;
        public String createdBy;
        public int createdById;
        public int items;
        public String status;
        public String statusColor;
        public String remarks;
        public String supplier;
        public String customer;
        public String poCode;
        public String supplierCode;
        public String contactPerson;
        public String proposal;
        public String inboundCode;
        public List<Map<String, Object>> itemsList = new ArrayList<>();
    }

    /**
     * DTO for Global Inventory Ledger Entry.
     */
    public static class GlobalLedgerEntry {
        public int ledgerId;
        public String sku;
        public String productName;
        public String warehouse;
        public String type; // "INBOUND" | "OUTBOUND" | "ADJUSTMENT" | "TRANSFER_IN" | "TRANSFER_OUT"
        public double qtyChange;
        public double availChange;
        public String createdBy;
        public String timestamp;
        public String note;
    }

    /**
     * Fetch all documents from all tables, mapping them to a unified format.
     * (Business Manager view — every warehouse.)
     */
    public List<LedgerDocument> findAllDocuments() {
        return findDocuments(null);
    }

    /**
     * Warehouse Staff view — documents scoped to ONE warehouse.
     * Stock transfers match when the warehouse is either the source OR the destination.
     */
    public List<LedgerDocument> findAllDocuments(int warehouseId) {
        return findDocuments(warehouseId);
    }

    /**
     * Aggregates documents from all 6 sources. When {@code warehouseId} is null, returns
     * documents of every warehouse; otherwise scopes each source to that warehouse
     * (stock transfers match on either from_warehouse_id or to_warehouse_id).
     */
    private List<LedgerDocument> findDocuments(Integer warehouseId) {
        List<LedgerDocument> docs = new ArrayList<>();
        boolean byWh = warehouseId != null;

        // 1. Fetch Inbound Orders
        String sqlInbound =
            "SELECT io.inbound_id, io.inbound_code, io.supplier, io.status, io.note, io.created_at, " +
            "w.warehouse_id, w.warehouse_name, u.full_name AS creator_name " +
            "FROM inbound_orders io " +
            "LEFT JOIN warehouses w ON io.warehouse_id = w.warehouse_id " +
            "LEFT JOIN users u ON io.created_by = u.user_id " +
            (byWh ? "WHERE io.warehouse_id = ? " : "") +
            "ORDER BY io.created_at DESC LIMIT 100";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlInbound)) {
            if (byWh) ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LedgerDocument d = new LedgerDocument();
                d.id = rs.getString("inbound_code");
                d.type = "Phiếu Nhập Kho";
                
                Timestamp ca = rs.getTimestamp("created_at");
                d.date = (ca != null) ? ca.toLocalDateTime().format(DATE_FORMATTER) : "";
                d.warehouse = rs.getString("warehouse_name");
                d.warehouseId = rs.getInt("warehouse_id");
                
                String creator = rs.getString("creator_name");
                d.createdBy = (creator != null) ? creator : "Hệ thống";
                d.status = mapInboundStatus(rs.getString("status"));
                d.statusColor = getStatusColor(d.status);
                d.remarks = rs.getString("note");
                d.supplier = rs.getString("supplier");
                d.items = countInboundItems(conn, rs.getInt("inbound_id"));
                docs.add(d);
            }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "LedgerDAO: Failed to fetch inbound documents", e);
        }

        // 2. Fetch Outbound Orders
        String sqlOutbound =
            "SELECT oo.outbound_id, oo.outbound_code, oo.status, oo.note, oo.created_at, " +
            "w.warehouse_id, w.warehouse_name, u.full_name AS creator_name, o.channel " +
            "FROM outbound_orders oo " +
            "LEFT JOIN warehouses w ON oo.warehouse_id = w.warehouse_id " +
            "LEFT JOIN users u ON oo.picked_by = u.user_id " +
            "LEFT JOIN orders o ON oo.order_id = o.order_id " +
            (byWh ? "WHERE oo.warehouse_id = ? " : "") +
            "ORDER BY oo.created_at DESC LIMIT 100";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlOutbound)) {
            if (byWh) ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LedgerDocument d = new LedgerDocument();
                d.id = rs.getString("outbound_code");
                if (d.id == null) {
                    d.id = "SOUT-OUT-" + rs.getInt("outbound_id");
                }
                d.type = "Phiếu Xuất Kho";
                
                Timestamp ca = rs.getTimestamp("created_at");
                d.date = (ca != null) ? ca.toLocalDateTime().format(DATE_FORMATTER) : "";
                d.warehouse = rs.getString("warehouse_name");
                d.warehouseId = rs.getInt("warehouse_id");
                
                String creator = rs.getString("creator_name");
                d.createdBy = (creator != null) ? creator : "Hệ thống";
                d.remarks = rs.getString("note");
                d.customer = rs.getString("channel");
                if (d.customer == null) d.customer = "Khách mua lẻ";

                String dbStatus = rs.getString("status");
                if (isOmnichannelChannel(d.customer)) {
                    if ("PENDING".equals(dbStatus) || "PICKING".equals(dbStatus) || "PACKED".equals(dbStatus)) {
                        d.status = "Đã duyệt";
                    } else if ("SHIPPED".equals(dbStatus) || "DELIVERED".equals(dbStatus)) {
                        d.status = "Hoàn thành";
                    } else {
                        d.status = mapOutboundStatus(dbStatus);
                    }
                } else {
                    d.status = mapOutboundStatus(dbStatus);
                }

                d.statusColor = getStatusColor(d.status);
                d.items = countOutboundItems(conn, rs.getInt("outbound_id"));
                docs.add(d);
            }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "LedgerDAO: Failed to fetch outbound documents", e);
        }

        // 3. Fetch Stock Transfers
        String sqlTransfers =
            "SELECT st.transfer_id, st.transfer_code, st.status, st.note, st.created_at, " +
            "st.from_warehouse_id, w1.warehouse_name AS from_wh, w2.warehouse_name AS to_wh, u.full_name AS creator_name " +
            "FROM stock_transfers st " +
            "LEFT JOIN warehouses w1 ON st.from_warehouse_id = w1.warehouse_id " +
            "LEFT JOIN warehouses w2 ON st.to_warehouse_id = w2.warehouse_id " +
            "LEFT JOIN users u ON st.created_by = u.user_id " +
            (byWh ? "WHERE (st.from_warehouse_id = ? OR st.to_warehouse_id = ?) " : "") +
            "ORDER BY st.created_at DESC LIMIT 100";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlTransfers)) {
            if (byWh) { ps.setInt(1, warehouseId); ps.setInt(2, warehouseId); }
            try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LedgerDocument d = new LedgerDocument();
                d.id = rs.getString("transfer_code");
                d.type = "Phiếu Chuyển Kho";
                
                Timestamp ca = rs.getTimestamp("created_at");
                d.date = (ca != null) ? ca.toLocalDateTime().format(DATE_FORMATTER) : "";
                d.warehouse = rs.getString("from_wh") + " → " + rs.getString("to_wh");
                d.warehouseId = rs.getInt("from_warehouse_id");
                
                String creator = rs.getString("creator_name");
                d.createdBy = (creator != null) ? creator : "Hệ thống";
                d.status = mapTransferStatus(rs.getString("status"));
                d.statusColor = getStatusColor(d.status);
                d.remarks = rs.getString("note");
                d.items = countTransferItems(conn, rs.getInt("transfer_id"));
                docs.add(d);
            }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "LedgerDAO: Failed to fetch transfer documents", e);
        }

        // 4. Fetch Physical Inventories
        String sqlPhysical =
            "SELECT pi.inventory_check_id, pi.check_code, pi.status, pi.note, pi.created_at, " +
            "w.warehouse_id, w.warehouse_name, u.full_name AS creator_name " +
            "FROM physical_inventories pi " +
            "LEFT JOIN warehouses w ON pi.warehouse_id = w.warehouse_id " +
            "LEFT JOIN users u ON pi.created_by = u.user_id " +
            (byWh ? "WHERE pi.warehouse_id = ? " : "") +
            "ORDER BY pi.created_at DESC LIMIT 100";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlPhysical)) {
            if (byWh) ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LedgerDocument d = new LedgerDocument();
                d.id = rs.getString("check_code");
                d.type = "Phiếu Kiểm Kê";
                
                Timestamp ca = rs.getTimestamp("created_at");
                d.date = (ca != null) ? ca.toLocalDateTime().format(DATE_FORMATTER) : "";
                d.warehouse = rs.getString("warehouse_name");
                d.warehouseId = rs.getInt("warehouse_id");
                
                String creator = rs.getString("creator_name");
                d.createdBy = (creator != null) ? creator : "Hệ thống";
                d.status = mapPhysicalStatus(rs.getString("status"));
                d.statusColor = getStatusColor(d.status);
                d.remarks = rs.getString("note");
                d.items = countPhysicalItems(conn, rs.getInt("inventory_check_id"));
                docs.add(d);
            }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "LedgerDAO: Failed to fetch physical check documents", e);
        }

        // 5. Fetch RMA / Return Orders
        String sqlReturns =
            "SELECT ro.return_id, ro.customer_name, ro.reason, ro.status, ro.created_at, " +
            "w.warehouse_id, w.warehouse_name " +
            "FROM return_orders ro " +
            "LEFT JOIN warehouses w ON ro.warehouse_id = w.warehouse_id " +
            (byWh ? "WHERE ro.warehouse_id = ? " : "") +
            "ORDER BY ro.created_at DESC LIMIT 100";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlReturns)) {
            if (byWh) ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LedgerDocument d = new LedgerDocument();
                d.id = "RMA-" + String.format("%05d", rs.getInt("return_id"));
                d.type = "Phiếu Hoàn Hàng";
                
                Timestamp ca = rs.getTimestamp("created_at");
                d.date = (ca != null) ? ca.toLocalDateTime().format(DATE_FORMATTER) : "";
                d.warehouse = rs.getString("warehouse_name");
                d.warehouseId = rs.getInt("warehouse_id");
                d.createdBy = "Nhân viên tiếp nhận";
                
                d.status = mapReturnStatus(rs.getString("status"));
                d.statusColor = getStatusColor(d.status);
                d.remarks = rs.getString("reason");
                d.customer = rs.getString("customer_name");
                d.items = countReturnItems(conn, rs.getInt("return_id"));
                docs.add(d);
            }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "LedgerDAO: Failed to fetch return documents", e);
        }

        // 6. Fetch Scrap / Disposal Issues (warehouse_issues, issue_type = SCRAP)
        String sqlScrap =
            "SELECT wi.issue_id, wi.issue_code, wi.status, wi.created_at, " +
            "w.warehouse_id, w.warehouse_name, u.full_name AS creator_name " +
            "FROM warehouse_issues wi " +
            "LEFT JOIN warehouses w ON wi.warehouse_id = w.warehouse_id " +
            "LEFT JOIN users u ON wi.created_by = u.user_id " +
            "WHERE wi.issue_type = 'SCRAP' " +
            (byWh ? "AND wi.warehouse_id = ? " : "") +
            "ORDER BY wi.created_at DESC LIMIT 100";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlScrap)) {
            if (byWh) ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LedgerDocument d = new LedgerDocument();
                d.id = rs.getString("issue_code");
                d.type = "Phiếu Xuất Hủy";
                Timestamp ca = rs.getTimestamp("created_at");
                d.date = (ca != null) ? ca.toLocalDateTime().format(DATE_FORMATTER) : "";
                d.warehouse = rs.getString("warehouse_name");
                d.warehouseId = rs.getInt("warehouse_id");
                String creator = rs.getString("creator_name");
                d.createdBy = (creator != null) ? creator : "Hệ thống";
                String st = rs.getString("status");
                d.status = "APPROVED".equals(st) ? "Đã duyệt" : ("CANCELLED".equals(st) ? "Đã hủy" : "Nháp");
                d.statusColor = getStatusColor(d.status);
                int itemCount = 0;
                try (PreparedStatement cps = conn.prepareStatement(
                        "SELECT COUNT(*) FROM issue_details WHERE issue_id = ?")) {
                    cps.setInt(1, rs.getInt("issue_id"));
                    try (ResultSet crs = cps.executeQuery()) { if (crs.next()) itemCount = crs.getInt(1); }
                }
                d.items = itemCount;
                docs.add(d);
            }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "LedgerDAO: Failed to fetch scrap documents", e);
        }

        // 7. Fetch RTV Orders
        String sqlRtv =
            "SELECT r.rtv_id, r.rtv_code, r.supplier, r.status, r.reason, r.note, r.created_at, " +
            "r.po_code, r.supplier_code, r.contact_person, r.proposal, io.inbound_code, " +
            "w.warehouse_id, w.warehouse_name, u.full_name AS creator_name " +
            "FROM rtv_orders r " +
            "LEFT JOIN inbound_orders io ON r.inbound_id = io.inbound_id " +
            "LEFT JOIN warehouses w ON r.warehouse_id = w.warehouse_id " +
            "LEFT JOIN users u ON r.created_by = u.user_id " +
            (byWh ? "WHERE r.warehouse_id = ? " : "") +
            "ORDER BY r.created_at DESC LIMIT 100";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlRtv)) {
            if (byWh) ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LedgerDocument d = new LedgerDocument();
                    d.id = rs.getString("rtv_code");
                    d.type = "Phiếu Trả Hàng NCC";
                    
                    Timestamp ca = rs.getTimestamp("created_at");
                    d.date = (ca != null) ? ca.toLocalDateTime().format(DATE_FORMATTER) : "";
                    d.warehouse = rs.getString("warehouse_name");
                    d.warehouseId = rs.getInt("warehouse_id");
                    
                    String creator = rs.getString("creator_name");
                    d.createdBy = (creator != null) ? creator : "Hệ thống";
                    
                    String dbStatus = rs.getString("status");
                    d.status = mapRtvStatus(dbStatus);
                    d.statusColor = getStatusColor(d.status);
                    d.remarks = rs.getString("reason");
                    d.supplier = rs.getString("supplier");
                    d.poCode = rs.getString("po_code");
                    d.supplierCode = rs.getString("supplier_code");
                    d.contactPerson = rs.getString("contact_person");
                    d.proposal = rs.getString("proposal");
                    d.inboundCode = rs.getString("inbound_code");
                    d.items = countRtvItems(conn, rs.getInt("rtv_id"));
                    docs.add(d);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "LedgerDAO: Failed to fetch RTV documents", e);
        }

        // Sort overall list: newest first
        docs.sort((d1, d2) -> d2.date.compareTo(d1.date));
        return docs;
    }

    /**
     * Fetch all global ledger history records.
     */
    public List<GlobalLedgerEntry> findGlobalLedgerEntries() {
        List<GlobalLedgerEntry> entries = new ArrayList<>();
        String sql = 
            "SELECT il.ledger_id, il.transaction_type, il.qty_change, il.avail_change, il.timestamp, il.note, " +
            "p.sku_code, p.product_name, w.warehouse_name, u.full_name AS user_name " +
            "FROM inventory_ledger il " +
            "LEFT JOIN products p ON il.product_id = p.product_id " +
            "LEFT JOIN warehouses w ON il.warehouse_id = w.warehouse_id " +
            "LEFT JOIN users u ON il.created_by = u.user_id " +
            "ORDER BY il.timestamp DESC LIMIT 300";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                GlobalLedgerEntry e = new GlobalLedgerEntry();
                e.ledgerId = rs.getInt("ledger_id");
                e.sku = rs.getString("sku_code");
                e.productName = rs.getString("product_name");
                e.warehouse = rs.getString("warehouse_name");
                e.type = rs.getString("transaction_type");
                e.qtyChange = rs.getDouble("qty_change");
                e.availChange = rs.getDouble("avail_change");
                
                Timestamp ts = rs.getTimestamp("timestamp");
                e.timestamp = (ts != null) ? ts.toLocalDateTime().format(DATE_FORMATTER) : "";
                
                String user = rs.getString("user_name");
                e.createdBy = (user != null) ? user : "Hệ thống";
                e.note = rs.getString("note");
                entries.add(e);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "LedgerDAO: Failed to fetch global ledger entries", e);
        }
        return entries;
    }

    /**
     * Retrieve list items for a specific document.
     */
    public List<Map<String, Object>> findDocumentItems(String docId, String docType) {
        List<Map<String, Object>> items = new ArrayList<>();
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            if ("Phiếu Nhập Kho".equals(docType)) {
                String sql =
                    "SELECT ii.expected_qty, ii.received_qty, ii.accepted_qty, ii.rejected_qty, ii.unit_cost, p.sku_code, p.product_name, p.unit, p.base_price " +
                    "FROM inbound_items ii " +
                    "LEFT JOIN products p ON ii.product_id = p.product_id " +
                    "LEFT JOIN inbound_orders io ON ii.inbound_id = io.inbound_id " +
                    "WHERE io.inbound_code = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, docId);
                    try (ResultSet rs = ps.executeQuery()) {
                        int index = 1;
                        while (rs.next()) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("stt", index++);
                            map.put("sku", rs.getString("sku_code"));
                            map.put("name", rs.getString("product_name"));
                            map.put("uom", rs.getString("unit"));
                            map.put("lot", "LOT-AUTO-" + docId.hashCode() % 100);
                            map.put("hsd", "31/12/2026");
                            map.put("ordered", rs.getDouble("expected_qty"));
                            map.put("received", rs.getDouble("received_qty"));
                            map.put("accepted", rs.getDouble("accepted_qty"));
                            map.put("rejected", rs.getDouble("rejected_qty"));
                            map.put("remarks", "");
                            // Use unit_cost if available, fallback to base_price
                            double unitCost = rs.getDouble("unit_cost");
                            if (rs.wasNull()) unitCost = rs.getDouble("base_price");
                            map.put("price", unitCost);
                            items.add(map);
                        }
                    }
                }
            } else if ("Phiếu Xuất Kho".equals(docType)) {
                String sql = 
                    "SELECT oi.qty, oi.picked_qty, p.sku_code, p.product_name, p.unit, p.base_price " +
                    "FROM outbound_items oi " +
                    "LEFT JOIN products p ON oi.product_id = p.product_id " +
                    "LEFT JOIN outbound_orders oo ON oi.outbound_id = oo.outbound_id " +
                    "WHERE oo.outbound_code = ? OR (oo.outbound_code IS NULL AND CONCAT('SOUT-OUT-', oo.outbound_id) = ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, docId);
                    ps.setString(2, docId);
                    try (ResultSet rs = ps.executeQuery()) {
                        int index = 1;
                        while (rs.next()) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("stt", index++);
                            map.put("sku", rs.getString("sku_code"));
                            map.put("name", rs.getString("product_name"));
                            map.put("uom", rs.getString("unit"));
                            map.put("lot", "LOT-AUTO");
                            map.put("hsd", "30/06/2027");
                            map.put("qtyRequest", rs.getDouble("qty"));
                            map.put("qtyIssued", rs.getDouble("picked_qty"));
                            map.put("price", rs.getDouble("base_price"));
                            items.add(map);
                        }
                    }
                }
            } else if ("Phiếu Chuyển Kho".equals(docType)) {
                String sql = 
                    "SELECT sti.shipped_qty, sti.received_qty, p.sku_code, p.product_name, p.unit " +
                    "FROM stock_transfer_items sti " +
                    "LEFT JOIN products p ON sti.product_id = p.product_id " +
                    "LEFT JOIN stock_transfers st ON sti.transfer_id = st.transfer_id " +
                    "WHERE st.transfer_code = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, docId);
                    try (ResultSet rs = ps.executeQuery()) {
                        int index = 1;
                        while (rs.next()) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("stt", index++);
                            map.put("sku", rs.getString("sku_code"));
                            map.put("name", rs.getString("product_name"));
                            map.put("uom", rs.getString("unit"));
                            map.put("lot", "LOT-TRANS");
                            map.put("requested", rs.getDouble("shipped_qty"));
                            map.put("transferred", rs.getObject("received_qty") != null ? rs.getDouble("received_qty") : rs.getDouble("shipped_qty"));
                            map.put("remark", "");
                            items.add(map);
                        }
                    }
                }
            } else if ("Phiếu Kiểm Kê".equals(docType)) {
                String sql = 
                    "SELECT pid.system_qty, pid.actual_qty, pid.delta_qty, p.sku_code, p.product_name, p.unit " +
                    "FROM physical_inventory_details pid " +
                    "LEFT JOIN products p ON pid.product_id = p.product_id " +
                    "LEFT JOIN physical_inventories pi ON pid.inventory_check_id = pi.inventory_check_id " +
                    "WHERE pi.check_code = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, docId);
                    try (ResultSet rs = ps.executeQuery()) {
                        int index = 1;
                        while (rs.next()) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("stt", index++);
                            map.put("sku", rs.getString("sku_code"));
                            map.put("name", rs.getString("product_name"));
                            map.put("uom", rs.getString("unit"));
                            map.put("book", rs.getDouble("system_qty"));
                            map.put("actual", rs.getObject("actual_qty") != null ? rs.getDouble("actual_qty") : rs.getDouble("system_qty"));
                            map.put("diff", rs.getObject("delta_qty") != null ? rs.getDouble("delta_qty") : 0.0);
                            map.put("remark", "");
                            items.add(map);
                        }
                    }
                }
            } else if ("Phiếu Hoàn Hàng".equals(docType)) {
                // RMA: format id is RMA-XXXXX where XXXXX is return_id
                int returnId = Integer.parseInt(docId.replace("RMA-", ""));
                String sql = 
                    "SELECT ri.quantity, ri.return_reason, p.sku_code, p.product_name, p.unit, p.base_price " +
                    "FROM return_items ri " +
                    "LEFT JOIN products p ON ri.product_id = p.product_id " +
                    "WHERE ri.return_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, returnId);
                    try (ResultSet rs = ps.executeQuery()) {
                        int index = 1;
                        while (rs.next()) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("stt", index++);
                            map.put("sku", rs.getString("sku_code"));
                            map.put("name", rs.getString("product_name"));
                            map.put("uom", rs.getString("unit"));
                            map.put("returned", rs.getDouble("quantity"));
                            map.put("reuse", rs.getDouble("quantity"));
                            map.put("destroy", 0.0);
                            map.put("price", rs.getDouble("base_price"));
                            map.put("remark", rs.getString("return_reason"));
                            items.add(map);
                        }
                    }
                }
            } else if ("Phiếu Trả Hàng NCC".equals(docType)) {
                String sql = 
                    "SELECT ri.qty_return, ri.unit_cost, p.sku_code, p.product_name, p.unit, " +
                    "       (SELECT ii.received_qty FROM inbound_items ii WHERE ii.inbound_id = r.inbound_id AND ii.product_id = ri.product_id) AS qty_received " +
                    "FROM rtv_items ri " +
                    "LEFT JOIN products p ON ri.product_id = p.product_id " +
                    "LEFT JOIN rtv_orders r ON ri.rtv_id = r.rtv_id " +
                    "WHERE r.rtv_code = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, docId);
                    try (ResultSet rs = ps.executeQuery()) {
                        int index = 1;
                        while (rs.next()) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("stt", index++);
                            map.put("sku", rs.getString("sku_code"));
                            map.put("name", rs.getString("product_name"));
                            map.put("uom", rs.getString("unit"));
                            map.put("received", rs.getDouble("qty_received"));
                            map.put("returned", rs.getDouble("qty_return"));
                            map.put("price", rs.getDouble("unit_cost"));
                            items.add(map);
                        }
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "LedgerDAO: Failed to fetch document items for id=" + docId, e);
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException ex) {}
            }
        }
        return items;
    }

    /**
     * Approve a document by updating status, modifying physical stock levels, and logging to ledger.
     */
    public boolean approveDocument(String docId, String docType, int userId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            if ("Phiếu Nhập Kho".equals(docType)) {
                // Find order
                int inboundId = -1;
                String status = "";
                String sqlFind = "SELECT inbound_id, status FROM inbound_orders WHERE inbound_code = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlFind)) {
                    ps.setString(1, docId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            inboundId = rs.getInt("inbound_id");
                            status = rs.getString("status");
                        }
                    }
                }

                if (inboundId == -1) {
                    throw new SQLException("Inbound order not found.");
                }

                // Guard: already past approval
                if ("RECEIVED".equals(status) || "IN_PROGRESS".equals(status)) {
                    conn.rollback();
                    return true;
                }

                // BM approval: PENDING → IN_PROGRESS (authorises WH staff to receive goods).
                // Inventory is updated later when WH staff enters actual received quantities
                // via the "Nhập kho" receive modal (action=receive in WarehouseInboundServlet).
                String sqlUpdateStatus = "UPDATE inbound_orders SET status = 'IN_PROGRESS' WHERE inbound_id = ? AND status = 'PENDING'";
                try (PreparedStatement ps = conn.prepareStatement(sqlUpdateStatus)) {
                    ps.setInt(1, inboundId);
                    int rows = ps.executeUpdate();
                    if (rows == 0) {
                        conn.rollback();
                        LOGGER.warning("approveDocument: inbound order not in PENDING state, id=" + inboundId);
                        return false;
                    }
                }

            } else if ("Phiếu Xuất Kho".equals(docType)) {
                int outboundId = -1;
                int warehouseId = -1;
                String status = "";
                String sqlFind = "SELECT outbound_id, warehouse_id, status FROM outbound_orders WHERE outbound_code = ? OR (outbound_code IS NULL AND CONCAT('SOUT-OUT-', outbound_id) = ?)";
                try (PreparedStatement ps = conn.prepareStatement(sqlFind)) {
                    ps.setString(1, docId);
                    ps.setString(2, docId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            outboundId = rs.getInt("outbound_id");
                            warehouseId = rs.getInt("warehouse_id");
                            status = rs.getString("status");
                        }
                    }
                }

                if (outboundId == -1) {
                    throw new SQLException("Outbound order not found.");
                }

                if ("DELIVERED".equals(status) || "SHIPPED".equals(status)) {
                    conn.rollback();
                    return true;
                }

                // Retrieve outbound items
                String sqlItems = "SELECT product_id, qty, picked_qty FROM outbound_items WHERE outbound_id = ?";
                List<Map<String, Object>> issueItems = new ArrayList<>();
                try (PreparedStatement ps = conn.prepareStatement(sqlItems)) {
                    ps.setInt(1, outboundId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("productId", rs.getInt("product_id"));
                            BigDecimal pQty = rs.getBigDecimal("picked_qty");
                            BigDecimal reqQty = rs.getBigDecimal("qty");
                            BigDecimal finalQty = (pQty != null && pQty.compareTo(BigDecimal.ZERO) > 0) ? pQty : reqQty;
                            map.put("qty", finalQty);
                            issueItems.add(map);
                        }
                    }
                }

                // Deduct inventory
                for (Map<String, Object> item : issueItems) {
                    int prodId = (int) item.get("productId");
                    BigDecimal qty = (BigDecimal) item.get("qty");
                    if (qty == null || qty.compareTo(BigDecimal.ZERO) <= 0) continue;

                    BigDecimal negativeQty = qty.negate();
                    upsertInventory(conn, prodId, warehouseId, negativeQty, negativeQty);
                    int invId = getInventoryId(conn, prodId, warehouseId);
                    insertLedgerEntry(conn, invId, prodId, warehouseId, "OUTBOUND", outboundId, negativeQty, negativeQty, userId, "Xuất kho GI approved");
                }

                // Update status to SHIPPED
                String sqlUpdateStatus = "UPDATE outbound_orders SET status = 'SHIPPED', shipped_at = ? WHERE outbound_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlUpdateStatus)) {
                    ps.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
                    ps.setInt(2, outboundId);
                    ps.executeUpdate();
                }

            } else if ("Phiếu Chuyển Kho".equals(docType)) {
                int transferId = -1;
                int fromWhId = -1;
                int toWhId = -1;
                String status = "";
                String sqlFind = "SELECT transfer_id, from_warehouse_id, to_warehouse_id, status FROM stock_transfers WHERE transfer_code = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlFind)) {
                    ps.setString(1, docId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            transferId = rs.getInt("transfer_id");
                            fromWhId = rs.getInt("from_warehouse_id");
                            toWhId = rs.getInt("to_warehouse_id");
                            status = rs.getString("status");
                        }
                    }
                }

                if (transferId == -1) {
                    throw new SQLException("Stock transfer not found.");
                }

                if ("RECEIVED".equals(status)) {
                    conn.rollback();
                    return true;
                }

                // Retrieve transfer items
                String sqlItems = "SELECT product_id, shipped_qty, received_qty FROM stock_transfer_items WHERE transfer_id = ?";
                List<Map<String, Object>> xferItems = new ArrayList<>();
                try (PreparedStatement ps = conn.prepareStatement(sqlItems)) {
                    ps.setInt(1, transferId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("productId", rs.getInt("product_id"));
                            map.put("shipped", rs.getBigDecimal("shipped_qty"));
                            BigDecimal rec = rs.getBigDecimal("received_qty");
                            map.put("received", rec != null ? rec : rs.getBigDecimal("shipped_qty"));
                            xferItems.add(map);
                        }
                    }
                }

                // Deduct from source and add to destination
                for (Map<String, Object> item : xferItems) {
                    int prodId = (int) item.get("productId");
                    BigDecimal shipQty = (BigDecimal) item.get("shipped");
                    BigDecimal recQty = (BigDecimal) item.get("received");

                    // 1. Source deductions
                    upsertInventory(conn, prodId, fromWhId, shipQty.negate(), shipQty.negate());
                    int fromInvId = getInventoryId(conn, prodId, fromWhId);
                    insertLedgerEntry(conn, fromInvId, prodId, fromWhId, "TRANSFER_OUT", transferId, shipQty.negate(), shipQty.negate(), userId, "Chuyển kho ra đi");

                    // 2. Destination additions
                    upsertInventory(conn, prodId, toWhId, recQty, recQty);
                    int toInvId = getInventoryId(conn, prodId, toWhId);
                    insertLedgerEntry(conn, toInvId, prodId, toWhId, "TRANSFER_IN", transferId, recQty, recQty, userId, "Chuyển kho nhận về");
                }

                // Update status to RECEIVED
                String sqlUpdateStatus = "UPDATE stock_transfers SET status = 'RECEIVED', approved_by = ?, completed_at = ? WHERE transfer_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlUpdateStatus)) {
                    ps.setInt(1, userId);
                    ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
                    ps.setInt(3, transferId);
                    ps.executeUpdate();
                }

            } else if ("Phiếu Kiểm Kê".equals(docType)) {
                int checkId = -1;
                int warehouseId = -1;
                String status = "";
                String sqlFind = "SELECT inventory_check_id, warehouse_id, status FROM physical_inventories WHERE check_code = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlFind)) {
                    ps.setString(1, docId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            checkId = rs.getInt("inventory_check_id");
                            warehouseId = rs.getInt("warehouse_id");
                            status = rs.getString("status");
                        }
                    }
                }

                if (checkId == -1) {
                    throw new SQLException("Physical check not found.");
                }

                if ("APPROVED".equals(status)) {
                    conn.rollback();
                    return true;
                }

                // Retrieve adjustment items
                String sqlItems = "SELECT product_id, delta_qty FROM physical_inventory_details WHERE inventory_check_id = ?";
                List<Map<String, Object>> adjustItems = new ArrayList<>();
                try (PreparedStatement ps = conn.prepareStatement(sqlItems)) {
                    ps.setInt(1, checkId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Map<String, Object> map = new HashMap<>();
                            map.put("productId", rs.getInt("product_id"));
                            map.put("delta", rs.getBigDecimal("delta_qty"));
                            adjustItems.add(map);
                        }
                    }
                }

                // Apply delta adjustments
                for (Map<String, Object> item : adjustItems) {
                    int prodId = (int) item.get("productId");
                    BigDecimal delta = (BigDecimal) item.get("delta");
                    if (delta == null || delta.compareTo(BigDecimal.ZERO) == 0) continue;

                    upsertInventory(conn, prodId, warehouseId, delta, delta);
                    int invId = getInventoryId(conn, prodId, warehouseId);
                    insertLedgerEntry(conn, invId, prodId, warehouseId, "ADJUSTMENT", checkId, delta, delta, userId, "Kiểm kê cân đối tồn kho");
                }

                // Update status to APPROVED
                String sqlUpdateStatus = "UPDATE physical_inventories SET status = 'APPROVED' WHERE inventory_check_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlUpdateStatus)) {
                    ps.setInt(1, checkId);
                    ps.executeUpdate();
                }
            } else if ("Phiếu Trả Hàng NCC".equals(docType)) {
                String sqlUpdateStatus = "UPDATE rtv_orders SET status = 'APPROVED' WHERE rtv_code = ? AND status = 'PENDING'";
                try (PreparedStatement ps = conn.prepareStatement(sqlUpdateStatus)) {
                    ps.setString(1, docId);
                    int rows = ps.executeUpdate();
                    if (rows == 0) {
                        conn.rollback();
                        LOGGER.warning("approveDocument: RTV order not in PENDING state, code=" + docId);
                        return false;
                    }
                }
            }

            conn.commit();
            LOGGER.info("approveDocument: Success approving " + docId + " (" + docType + ")");
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "LedgerDAO: Exception approving document " + docId, e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException rollbackEx) {}
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException ex) {}
            }
        }
    }

    /**
     * Reject a document by updating its status to CANCELLED or Từ chối, and logging the reason.
     */
    public boolean rejectDocument(String docId, String docType, String reason, int userId) {
        String noteText = "Lý do từ chối: " + reason;
        String sql = "";
        
        if ("Phiếu Nhập Kho".equals(docType)) {
            sql = "UPDATE inbound_orders SET status = 'CANCELLED', note = ? WHERE inbound_code = ?";
        } else if ("Phiếu Xuất Kho".equals(docType)) {
            sql = "UPDATE outbound_orders SET status = 'CANCELLED', note = ? WHERE outbound_code = ? OR (outbound_code IS NULL AND CONCAT('SOUT-OUT-', outbound_id) = ?)";
        } else if ("Phiếu Chuyển Kho".equals(docType)) {
            sql = "UPDATE stock_transfers SET status = 'CANCELLED', note = ?, approved_by = ? WHERE transfer_code = ?";
        } else if ("Phiếu Kiểm Kê".equals(docType)) {
            sql = "UPDATE physical_inventories SET status = 'DRAFT', note = ? WHERE check_code = ?"; // Rejected stocktakes go back to DRAFT or set status custom
        } else if ("Phiếu Trả Hàng NCC".equals(docType)) {
            sql = "UPDATE rtv_orders SET status = 'CANCELLED', note = ? WHERE rtv_code = ?";
        } else {
            return false;
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if ("Phiếu Chuyển Kho".equals(docType)) {
                ps.setString(1, noteText);
                ps.setInt(2, userId);
                ps.setString(3, docId);
            } else if ("Phiếu Xuất Kho".equals(docType)) {
                ps.setString(1, noteText);
                ps.setString(2, docId);
                ps.setString(3, docId);
            } else {
                ps.setString(1, noteText);
                ps.setString(2, docId);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "LedgerDAO: Failed to reject document id=" + docId, e);
            return false;
        }
    }

    // ── Internal Helpers ──

    private int countInboundItems(Connection conn, int id) throws SQLException {
        String sql = "SELECT COUNT(*) FROM inbound_items WHERE inbound_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    private int countOutboundItems(Connection conn, int id) throws SQLException {
        String sql = "SELECT COUNT(*) FROM outbound_items WHERE outbound_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    private int countTransferItems(Connection conn, int id) throws SQLException {
        String sql = "SELECT COUNT(*) FROM stock_transfer_items WHERE transfer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    private int countPhysicalItems(Connection conn, int id) throws SQLException {
        String sql = "SELECT COUNT(*) FROM physical_inventory_details WHERE inventory_check_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    private int countReturnItems(Connection conn, int id) throws SQLException {
        String sql = "SELECT COUNT(*) FROM return_items WHERE return_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    private void upsertInventory(Connection conn, int productId, int warehouseId, BigDecimal qtyChange, BigDecimal availChange) throws SQLException {
        String sql = 
            "INSERT INTO inventory (product_id, warehouse_id, qty_on_hand, holding, qty_available) " +
            "VALUES (?, ?, ?, 0, ?) " +
            "ON DUPLICATE KEY UPDATE qty_on_hand = qty_on_hand + ?, qty_available = qty_available + ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, warehouseId);
            ps.setBigDecimal(3, qtyChange);
            ps.setBigDecimal(4, availChange);
            ps.setBigDecimal(5, qtyChange);
            ps.setBigDecimal(6, availChange);
            ps.executeUpdate();
        }
    }

    private int getInventoryId(Connection conn, int productId, int warehouseId) throws SQLException {
        String sql = "SELECT inventory_id FROM inventory WHERE product_id = ? AND warehouse_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("inventory_id");
            }
        }
        return 0;
    }

    /**
     * Public wrapper of getInventoryId(Connection,...) for InventoryCommandBus.
     * Opens a new connection since the bus runs outside a transaction.
     */
    public int getInventoryIdForUpdate(int productId, int warehouseId) {
        try (Connection conn = DBConnection.getConnection()) {
            return getInventoryId(conn, productId, warehouseId);
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "getInventoryIdForUpdate failed", e);
            return 0;
        }
    }

    /**
     * Inserts a simple ledger entry from a Map (used by InventoryCommandBus
     * when receiving an InventoryEvent). ref_document_id = 0 (not tied to
     * a specific document).
     */
    public void insertSimpleLedgerEntry(Map<String, Object> entry) {
        String sql = "INSERT INTO inventory_ledger "
                   + "(inventory_id, product_id, warehouse_id, transaction_type, "
                   + "ref_document_id, qty_change, avail_change, created_by, note) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, (Integer) entry.get("inventoryId"));
            ps.setInt(2, (Integer) entry.get("productId"));
            ps.setInt(3, (Integer) entry.get("warehouseId"));
            ps.setString(4, (String) entry.get("type"));
            ps.setInt(5, 0);  // ref_document_id = 0 cho event bus
            ps.setBigDecimal(6, (BigDecimal) entry.get("qtyChange"));
            ps.setBigDecimal(7, (BigDecimal) entry.get("availChange"));
            ps.setInt(8, (Integer) entry.get("userId"));
            ps.setString(9, (String) entry.get("note"));
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "insertSimpleLedgerEntry failed", e);
        }
    }

    private void insertLedgerEntry(Connection conn, int inventoryId, int productId, int warehouseId, 
                                   String xactType, int refDocId, BigDecimal qtyChange, BigDecimal availChange,
                                   int userId, String note) throws SQLException {
        String sql = 
            "INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, " +
            "ref_document_id, qty_change, avail_change, created_by, note) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, inventoryId);
            ps.setInt(2, productId);
            ps.setInt(3, warehouseId);
            ps.setString(4, xactType);
            ps.setInt(5, refDocId);
            ps.setBigDecimal(6, qtyChange);
            ps.setBigDecimal(7, availChange);
            ps.setInt(8, userId);
            ps.setString(9, note);
            ps.executeUpdate();
        }
    }

    private String mapInboundStatus(String dbStatus) {
        if ("PENDING".equals(dbStatus)) return "Chờ BM duyệt";
        if ("IN_PROGRESS".equals(dbStatus)) return "Đang xử lý";
        if ("RECEIVED".equals(dbStatus)) return "Hoàn thành";
        if ("CANCELLED".equals(dbStatus)) return "Từ chối";
        return dbStatus;
    }

    private String mapOutboundStatus(String dbStatus) {
        if ("PENDING".equals(dbStatus)) return "Chờ duyệt";
        if ("PICKING".equals(dbStatus)) return "Đang xử lý";
        if ("PACKED".equals(dbStatus)) return "Đang xử lý";
        if ("SHIPPED".equals(dbStatus)) return "Đang giao";
        if ("DELIVERED".equals(dbStatus)) return "Hoàn thành";
        if ("CANCELLED".equals(dbStatus)) return "Từ chối";
        return dbStatus;
    }

    private String mapTransferStatus(String dbStatus) {
        if ("DRAFT".equals(dbStatus)) return "Nháp";
        if ("IN_TRANSIT".equals(dbStatus)) return "Chờ duyệt";
        if ("RECEIVED".equals(dbStatus)) return "Hoàn thành";
        if ("CANCELLED".equals(dbStatus)) return "Từ chối";
        return dbStatus;
    }

    private String mapPhysicalStatus(String dbStatus) {
        if ("DRAFT".equals(dbStatus)) return "Nháp";
        if ("IN_PROGRESS".equals(dbStatus)) return "Chờ duyệt";
        if ("APPROVED".equals(dbStatus)) return "Hoàn thành";
        return dbStatus;
    }

    private String mapReturnStatus(String dbStatus) {
        if ("RECEIVED".equals(dbStatus)) return "Chờ xác nhận WH";
        if ("INSPECTING".equals(dbStatus)) return "Chờ xác nhận WH";
        if ("PASS".equals(dbStatus)) return "Đã xử lý";
        if ("FAIL".equals(dbStatus)) return "Đã xử lý";
        if ("RESTOCKED".equals(dbStatus)) return "Đã xử lý";
        if ("SCRAPPED".equals(dbStatus)) return "Đã xử lý";
        return dbStatus;
    }

    private String mapRtvStatus(String dbStatus) {
        if ("PENDING".equals(dbStatus)) return "Chờ duyệt";
        if ("APPROVED".equals(dbStatus)) return "Đã duyệt";
        if ("COMPLETED".equals(dbStatus)) return "Hoàn thành";
        if ("CANCELLED".equals(dbStatus)) return "Từ chối";
        return dbStatus;
    }

    private int countRtvItems(Connection conn, int id) throws SQLException {
        String sql = "SELECT COUNT(*) FROM rtv_items WHERE rtv_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    private String getStatusColor(String status) {
        if ("Chờ duyệt".equals(status) || "Chờ xác nhận WH".equals(status)) return "#d97706"; // amber
        if ("Đang xử lý".equals(status)) return "#2563eb"; // blue
        if ("Hoàn thành".equals(status) || "Đã duyệt".equals(status) || "Đã xử lý".equals(status)) return "#059669"; // green
        if ("Từ chối".equals(status)) return "#dc2626"; // red
        return "#6b7280"; // gray (Draft/Nháp)
    }

    private boolean isOmnichannelChannel(String channelName) {
        if (channelName == null) return true;
        String lower = channelName.trim().toLowerCase();
        return lower.contains("shopee") || 
               lower.contains("tiktok") || 
               lower.contains("lazada") || 
               lower.contains("website") || 
               lower.contains("online") || 
               lower.contains("khách mua lẻ") ||
               lower.contains("retail");
    }
}
