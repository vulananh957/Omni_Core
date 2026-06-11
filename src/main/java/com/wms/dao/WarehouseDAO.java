package com.wms.dao;

import com.wms.model.Warehouse;
import com.wms.model.Zone;
import com.wms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * WarehouseDAO — Data Access Object for warehouses and their storage zones.
 */
public class WarehouseDAO {

    private static final Logger LOGGER = Logger.getLogger(WarehouseDAO.class.getName());

    /**
     * Find all warehouses with their zones populated.
     */
    public List<Warehouse> findAll() {
        List<Warehouse> list = new ArrayList<>();
        String sql = "SELECT warehouse_id, warehouse_code, warehouse_name, address, phone, capacity, active, created_at "
                   + "FROM warehouses ORDER BY warehouse_id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Warehouse w = new Warehouse();
                w.setWarehouseId(rs.getInt("warehouse_id"));
                w.setWarehouseCode(rs.getString("warehouse_code"));
                w.setWarehouseName(rs.getString("warehouse_name"));
                w.setAddress(rs.getString("address"));
                w.setPhone(rs.getString("phone"));
                w.setCapacity(rs.getInt("capacity"));
                w.setActive(rs.getBoolean("active"));
                Timestamp ts = rs.getTimestamp("created_at");
                if (ts != null) {
                    w.setCreatedAt(ts.toLocalDateTime());
                }
                w.setZones(findZonesByWarehouseId(conn, w.getWarehouseId()));
                list.add(w);
            }

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "WarehouseDAO.findAll: failed", e);
        }
        return list;
    }

    /**
     * Find a warehouse by its ID.
     */
    public Warehouse findById(int id) {
        String sql = "SELECT warehouse_id, warehouse_code, warehouse_name, address, phone, capacity, active, created_at "
                   + "FROM warehouses WHERE warehouse_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Warehouse w = new Warehouse();
                    w.setWarehouseId(rs.getInt("warehouse_id"));
                    w.setWarehouseCode(rs.getString("warehouse_code"));
                    w.setWarehouseName(rs.getString("warehouse_name"));
                    w.setAddress(rs.getString("address"));
                    w.setPhone(rs.getString("phone"));
                    w.setCapacity(rs.getInt("capacity"));
                    w.setActive(rs.getBoolean("active"));
                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) {
                        w.setCreatedAt(ts.toLocalDateTime());
                    }
                    w.setZones(findZonesByWarehouseId(conn, id));
                    return w;
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "WarehouseDAO.findById: failed for id " + id, e);
        }
        return null;
    }

    /**
     * Helper to retrieve zones of a warehouse using an existing connection.
     */
    private List<Zone> findZonesByWarehouseId(Connection conn, int warehouseId) throws SQLException {
        List<Zone> zones = new ArrayList<>();
        String sql = "SELECT zone_id, warehouse_id, zone_code, zone_name, zone_type, description, active, is_default "
                   + "FROM zones WHERE warehouse_id = ? ORDER BY zone_id ASC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Zone z = new Zone();
                    z.setZoneId(rs.getInt("zone_id"));
                    z.setWarehouseId(rs.getInt("warehouse_id"));
                    z.setZoneCode(rs.getString("zone_code"));
                    z.setZoneName(rs.getString("zone_name"));
                    z.setZoneType(rs.getString("zone_type"));
                    z.setDescription(rs.getString("description"));
                    z.setActive(rs.getBoolean("active"));
                    z.setDefault(rs.getBoolean("is_default"));
                    zones.add(z);
                }
            }
        }
        return zones;
    }

    /**
     * Insert a new warehouse and its zones within a transaction.
     */
    public boolean insert(Warehouse w, List<Zone> zones) {
        Connection conn = null;
        PreparedStatement psWH = null;
        PreparedStatement psZone = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String sqlWH = "INSERT INTO warehouses (warehouse_code, warehouse_name, address, phone, capacity, active) "
                         + "VALUES (?, ?, ?, ?, ?, ?)";
            psWH = conn.prepareStatement(sqlWH, Statement.RETURN_GENERATED_KEYS);
            psWH.setString(1, w.getWarehouseCode());
            psWH.setString(2, w.getWarehouseName());
            psWH.setString(3, w.getAddress());
            psWH.setString(4, w.getPhone());
            psWH.setInt(5, w.getCapacity());
            psWH.setBoolean(6, w.isActive());

            int affectedRows = psWH.executeUpdate();
            if (affectedRows == 0) {
                conn.rollback();
                return false;
            }

            int warehouseId = -1;
            try (ResultSet generatedKeys = psWH.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    warehouseId = generatedKeys.getInt(1);
                }
            }

            if (warehouseId == -1) {
                conn.rollback();
                return false;
            }

            String sqlZone = "INSERT INTO zones (warehouse_id, zone_code, zone_name, zone_type, description, active, is_default) "
                           + "VALUES (?, ?, ?, ?, ?, ?, ?)";
            psZone = conn.prepareStatement(sqlZone);

            for (Zone z : zones) {
                psZone.setInt(1, warehouseId);
                psZone.setString(2, z.getZoneCode());
                psZone.setString(3, z.getZoneName());
                psZone.setString(4, z.getZoneType() != null ? z.getZoneType() : "NORMAL");
                psZone.setString(5, z.getDescription());
                psZone.setBoolean(6, z.isActive());
                psZone.setBoolean(7, z.isDefault());
                psZone.addBatch();
            }

            psZone.executeBatch();
            conn.commit();
            return true;

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "WarehouseDAO.insert: failed, rolling back", e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Rollback failed", ex);
                }
            }
            return false;
        } finally {
            DBConnection.closeQuietly(psWH, psZone);
            closeConnectionQuietly(conn);
        }
    }

    /**
     * Update warehouse details and reconcile zones (insert/update/delete) in a transaction.
     */
    public boolean update(Warehouse w, List<Zone> newZones) {
        Connection conn = null;
        PreparedStatement psWH = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Update warehouse basic details
            String sqlWH = "UPDATE warehouses SET warehouse_code = ?, warehouse_name = ?, address = ?, phone = ?, capacity = ?, active = ? "
                         + "WHERE warehouse_id = ?";
            psWH = conn.prepareStatement(sqlWH);
            psWH.setString(1, w.getWarehouseCode());
            psWH.setString(2, w.getWarehouseName());
            psWH.setString(3, w.getAddress());
            psWH.setString(4, w.getPhone());
            psWH.setInt(5, w.getCapacity());
            psWH.setBoolean(6, w.isActive());
            psWH.setInt(7, w.getWarehouseId());
            psWH.executeUpdate();

            // 2. Retrieve current zones
            List<Zone> currentZones = findZonesByWarehouseId(conn, w.getWarehouseId());
            Set<String> newZoneCodes = new HashSet<>();
            for (Zone z : newZones) {
                newZoneCodes.add(z.getZoneCode());
            }

            // 3. Delete or deactivate removed zones
            String sqlDeleteZone = "DELETE FROM zones WHERE zone_id = ?";
            String sqlDeactivateZone = "UPDATE zones SET active = 0 WHERE zone_id = ?";
            try (PreparedStatement psDel = conn.prepareStatement(sqlDeleteZone);
                 PreparedStatement psDeact = conn.prepareStatement(sqlDeactivateZone)) {
                for (Zone cz : currentZones) {
                    if (!newZoneCodes.contains(cz.getZoneCode())) {
                        // Attempt physical delete first
                        try {
                            psDel.setInt(1, cz.getZoneId());
                            psDel.executeUpdate();
                        } catch (SQLException ex) {
                            // If references exist, soft-deactivate instead
                            psDeact.setInt(1, cz.getZoneId());
                            psDeact.executeUpdate();
                        }
                    }
                }
            }

            // 4. Update existing zones or insert new ones
            String sqlInsertZone = "INSERT INTO zones (warehouse_id, zone_code, zone_name, zone_type, description, active, is_default) "
                                 + "VALUES (?, ?, ?, ?, ?, ?, ?)";
            String sqlUpdateZone = "UPDATE zones SET zone_name = ?, zone_type = ?, description = ?, active = ?, is_default = ? "
                                 + "WHERE warehouse_id = ? AND zone_code = ?";

            try (PreparedStatement psIns = conn.prepareStatement(sqlInsertZone);
                 PreparedStatement psUpd = conn.prepareStatement(sqlUpdateZone)) {

                for (Zone nz : newZones) {
                    boolean exists = false;
                    for (Zone cz : currentZones) {
                        if (cz.getZoneCode().equals(nz.getZoneCode())) {
                            exists = true;
                            break;
                        }
                    }

                    if (exists) {
                        psUpd.setString(1, nz.getZoneName());
                        psUpd.setString(2, nz.getZoneType() != null ? nz.getZoneType() : "NORMAL");
                        psUpd.setString(3, nz.getDescription());
                        psUpd.setBoolean(4, nz.isActive());
                        psUpd.setBoolean(5, nz.isDefault());
                        psUpd.setInt(6, w.getWarehouseId());
                        psUpd.setString(7, nz.getZoneCode());
                        psUpd.addBatch();
                    } else {
                        psIns.setInt(1, w.getWarehouseId());
                        psIns.setString(2, nz.getZoneCode());
                        psIns.setString(3, nz.getZoneName());
                        psIns.setString(4, nz.getZoneType() != null ? nz.getZoneType() : "NORMAL");
                        psIns.setString(5, nz.getDescription());
                        psIns.setBoolean(6, nz.isActive());
                        psIns.setBoolean(7, nz.isDefault());
                        psIns.addBatch();
                    }
                }
                psUpd.executeBatch();
                psIns.executeBatch();
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "WarehouseDAO.update: failed, rolling back", e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Rollback failed", ex);
                }
            }
            return false;
        } finally {
            DBConnection.closeQuietly(psWH);
            closeConnectionQuietly(conn);
        }
    }

    /**
     * Toggle the active status of a warehouse.
     */
    public boolean toggleStatus(int id, boolean active) {
        String sql = "UPDATE warehouses SET active = ? WHERE warehouse_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setBoolean(1, active);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "WarehouseDAO.toggleStatus: failed for id " + id, e);
            return false;
        }
    }

    private void closeConnectionQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Failed to close connection", e);
            }
        }
    }

    /**
     * Inserts a new physical inventory check record.
     */
    public void insertInventoryCheck(String checkCode, int warehouseId, int userId, String note) {
        String sql = "INSERT INTO physical_inventories (check_code, warehouse_id, created_by, status) VALUES (?, ?, ?, 'DRAFT')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, checkCode);
            ps.setInt(2, warehouseId);
            ps.setInt(3, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "insertInventoryCheck failed", e);
            throw new RuntimeException("insertInventoryCheck failed", e);
        }
    }

    /**
     * Parses items JSON and inserts physical inventory check line items.
     * Expected JSON format: [{productId: int, systemQty: double}, ...]
     */
    public void insertInventoryCheckItems(String checkCode, String itemsJson) {
        if (itemsJson == null || itemsJson.trim().isEmpty()) return;
        Connection conn = null;
        PreparedStatement psSel = null;
        PreparedStatement psIns = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Get the checkId from checkCode
            String sqlSel = "SELECT inventory_check_id FROM physical_inventories WHERE check_code = ?";
            psSel = conn.prepareStatement(sqlSel);
            psSel.setString(1, checkCode);
            int checkId = -1;
            try (ResultSet rs = psSel.executeQuery()) {
                if (rs.next()) checkId = rs.getInt("inventory_check_id");
            }

            if (checkId == -1) {
                conn.rollback();
                return;
            }

            // Parse JSON items and insert
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            List<?> items = mapper.readValue(itemsJson, List.class);

            String sqlIns = "INSERT INTO physical_inventory_details (inventory_check_id, product_id, system_qty) VALUES (?, ?, ?)";
            psIns = conn.prepareStatement(sqlIns);
            for (Object item : items) {
                java.util.Map<?, ?> m = (java.util.Map<?, ?>) item;
                int productId = ((Number) m.get("productId")).intValue();
                double systemQty = m.get("systemQty") != null ? ((Number) m.get("systemQty")).doubleValue() : 0;
                psIns.setInt(1, checkId);
                psIns.setInt(2, productId);
                psIns.setDouble(3, systemQty);
                psIns.addBatch();
            }
            psIns.executeBatch();
            conn.commit();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "insertInventoryCheckItems failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            throw new RuntimeException("insertInventoryCheckItems failed", e);
        } finally {
            DBConnection.closeQuietly(psSel, psIns);
            closeConnectionQuietly(conn);
        }
    }

    /**
     * Updates inventory check detail rows with actual count results.
     * Expected JSON format: [{checkDetailId: int, actualQty: double, countedBy: int}, ...]
     */
    public void updateInventoryCheckResults(int checkId, String resultsJson) {
        if (resultsJson == null || resultsJson.trim().isEmpty()) return;
        Connection conn = null;
        PreparedStatement psSel = null;
        PreparedStatement psUpd = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Update status to IN_PROGRESS
            String sqlStatus = "UPDATE physical_inventories SET status = 'IN_PROGRESS' WHERE inventory_check_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlStatus)) {
                ps.setInt(1, checkId);
                ps.executeUpdate();
            }

            // Get the check's warehouse_id
            String sqlWh = "SELECT warehouse_id FROM physical_inventories WHERE inventory_check_id = ?";
            psSel = conn.prepareStatement(sqlWh);
            psSel.setInt(1, checkId);
            int warehouseId = -1;
            try (ResultSet rs = psSel.executeQuery()) {
                if (rs.next()) warehouseId = rs.getInt("warehouse_id");
            }

            // Update detail items
            String sqlUpd = "UPDATE physical_inventory_details SET actual_qty = ?, delta_qty = ?, "
                + "counted_by = ?, counted_at = CURRENT_TIMESTAMP WHERE check_detail_id = ?";
            psUpd = conn.prepareStatement(sqlUpd);

            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            List<?> items = mapper.readValue(resultsJson, List.class);

            for (Object item : items) {
                java.util.Map<?, ?> m = (java.util.Map<?, ?>) item;
                int detailId = ((Number) m.get("checkDetailId")).intValue();
                double actualQty = m.get("actualQty") != null ? ((Number) m.get("actualQty")).doubleValue() : 0;
                double delta = actualQty; // delta = actual - system (system is already in DB)
                int countedBy = m.get("countedBy") != null ? ((Number) m.get("countedBy")).intValue() : 1;

                psUpd.setDouble(1, actualQty);
                psUpd.setDouble(2, delta);
                psUpd.setInt(3, countedBy);
                psUpd.setInt(4, detailId);
                psUpd.addBatch();
            }
            psUpd.executeBatch();
            conn.commit();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "updateInventoryCheckResults failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            throw new RuntimeException("updateInventoryCheckResults failed", e);
        } finally {
            DBConnection.closeQuietly(psSel, psUpd);
            closeConnectionQuietly(conn);
        }
    }

    /**
     * Applies inventory adjustments by updating the inventory table and ledger.
     * Called after manager approves the inventory check.
     * Expected JSON format: [{productId: int, delta: double}, ...]
     */
    public void applyInventoryAdjustments(int checkId, String adjustmentsJson, int userId) {
        if (adjustmentsJson == null || adjustmentsJson.trim().isEmpty()) return;
        Connection conn = null;
        PreparedStatement psWh = null;
        PreparedStatement psUpd = null;
        PreparedStatement psLedger = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Get the check's warehouse_id
            String sqlWh = "SELECT warehouse_id FROM physical_inventories WHERE inventory_check_id = ?";
            psWh = conn.prepareStatement(sqlWh);
            psWh.setInt(1, checkId);
            int warehouseId = -1;
            try (ResultSet rs = psWh.executeQuery()) {
                if (rs.next()) warehouseId = rs.getInt("warehouse_id");
            }
            if (warehouseId == -1) throw new RuntimeException("Inventory check not found");

            // Parse adjustments
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            List<?> items = mapper.readValue(adjustmentsJson, List.class);

            for (Object item : items) {
                java.util.Map<?, ?> m = (java.util.Map<?, ?>) item;
                int productId = ((Number) m.get("productId")).intValue();
                double delta = m.get("delta") != null ? ((Number) m.get("delta")).doubleValue() : 0;
                if (delta == 0) continue;

                // Upsert inventory
                String sqlUpsert = "INSERT INTO inventory (product_id, warehouse_id, qty_on_hand, holding, qty_available) "
                    + "VALUES (?, ?, ?, 0, ?) ON DUPLICATE KEY UPDATE qty_on_hand = qty_on_hand + ?, qty_available = qty_available + ?";
                psUpd = conn.prepareStatement(sqlUpsert);
                psUpd.setInt(1, productId);
                psUpd.setInt(2, warehouseId);
                psUpd.setDouble(3, delta);
                psUpd.setDouble(4, delta);
                psUpd.setDouble(5, delta);
                psUpd.setDouble(6, delta);
                psUpd.executeUpdate();
                psUpd.close();

                // Get inventory_id
                int invId = 0;
                String sqlGetId = "SELECT inventory_id FROM inventory WHERE product_id = ? AND warehouse_id = ?";
                try (PreparedStatement psG = conn.prepareStatement(sqlGetId)) {
                    psG.setInt(1, productId);
                    psG.setInt(2, warehouseId);
                    try (ResultSet rs = psG.executeQuery()) {
                        if (rs.next()) invId = rs.getInt("inventory_id");
                    }
                }

                // Insert ledger entry
                String sqlLedger = "INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, "
                    + "ref_document_id, qty_change, avail_change, created_by, note) VALUES (?, ?, ?, 'ADJUSTMENT', ?, ?, ?, ?, 'Kiểm kê cân đối tồn kho')";
                psLedger = conn.prepareStatement(sqlLedger);
                psLedger.setInt(1, invId);
                psLedger.setInt(2, productId);
                psLedger.setInt(3, warehouseId);
                psLedger.setInt(4, checkId);
                psLedger.setDouble(5, delta);
                psLedger.setDouble(6, delta);
                psLedger.setInt(7, userId);
                psLedger.executeUpdate();
                psLedger.close();
            }

            conn.commit();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "applyInventoryAdjustments failed", e);
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            throw new RuntimeException("applyInventoryAdjustments failed", e);
        } finally {
            DBConnection.closeQuietly(psWh, psUpd, psLedger);
            closeConnectionQuietly(conn);
        }
    }
}
