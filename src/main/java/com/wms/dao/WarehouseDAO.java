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
}
