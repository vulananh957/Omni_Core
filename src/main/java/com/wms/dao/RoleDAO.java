package com.wms.dao;

import com.wms.model.Role;
import com.wms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * RoleDAO — Data Access Object for the `roles` table.
 */
public class RoleDAO {

    private static final Logger LOGGER = Logger.getLogger(RoleDAO.class.getName());

    public RoleDAO() {
        // Schema setup is now handled by SchemaInitListener.
    }

    /**
     * Retrieve all roles from the database.
     */
    public List<Role> findAll() {
        List<Role> list = new ArrayList<>();
        String sql = "SELECT * FROM roles ORDER BY role_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Role role = new Role();
                role.setRoleId(rs.getInt("role_id"));
                role.setRoleName(rs.getString("role_name"));
                role.setDescription(rs.getString("description"));
                list.add(role);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "RoleDAO: Failed to find all roles", e);
        }
        return list;
    }

    /**
     * Retrieve role by ID.
     */
    public Role findById(int roleId) {
        String sql = "SELECT * FROM roles WHERE role_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    role.setDescription(rs.getString("description"));
                    return role;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "RoleDAO: Failed to find role by ID " + roleId, e);
        }
        return null;
    }
}
