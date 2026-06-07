package com.wms.dao;

import com.wms.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * WarehouseDAO — Data Access Object for warehouse records.
 */
public class WarehouseDAO {

    private static final Logger LOGGER = Logger.getLogger(WarehouseDAO.class.getName());

    private static final String SQL_FIND_ALL =
        "SELECT warehouse_id, warehouse_code, warehouse_name, address, capacity, active "
      + "FROM warehouses ORDER BY warehouse_id ASC";

    /**
     * Returns all warehouses.
     */
    public List<Warehouse> findAll() {
        List<Warehouse> list = new ArrayList<>();
        String sql = SQL_FIND_ALL;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Warehouse w = new Warehouse();
                w.setWarehouseId(rs.getInt("warehouse_id"));
                w.setWarehouseCode(rs.getString("warehouse_code"));
                w.setWarehouseName(rs.getString("warehouse_name"));
                w.setAddress(rs.getString("address"));
                w.setCapacity(rs.getInt("capacity"));
                w.setActive(rs.getBoolean("active"));
                list.add(w);
            }

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "WarehouseDAO.findAll: failed", e);
        }
        return list;
    }

    /**
     * Simple domain object for Warehouse.
     */
    public static class Warehouse {
        private int warehouseId;
        private String warehouseCode;
        private String warehouseName;
        private String address;
        private int capacity;
        private boolean active;

        public int getWarehouseId() { return warehouseId; }
        public void setWarehouseId(int warehouseId) { this.warehouseId = warehouseId; }
        public String getWarehouseCode() { return warehouseCode; }
        public void setWarehouseCode(String warehouseCode) { this.warehouseCode = warehouseCode; }
        public String getWarehouseName() { return warehouseName; }
        public void setWarehouseName(String warehouseName) { this.warehouseName = warehouseName; }
        public String getAddress() { return address; }
        public void setAddress(String address) { this.address = address; }
        public int getCapacity() { return capacity; }
        public void setCapacity(int capacity) { this.capacity = capacity; }
        public boolean isActive() { return active; }
        public void setActive(boolean active) { this.active = active; }
    }
}
