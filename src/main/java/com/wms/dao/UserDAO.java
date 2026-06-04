package com.wms.dao;

import com.wms.model.User;
import com.wms.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * UserDAO — Data Access Object for the `users` table.
 *
 * Handles CRUD operations for user accounts. Schema initialisation (phone,
 * otp_preference, role_id columns) is performed once by {@link com.wms.listener.SchemaInitListener}.
 */
public class UserDAO {

    /**
     * Default constructor. Schema setup is handled by SchemaInitListener.
     */
    public UserDAO() {
    }

    // ── Queries (no roles table JOIN — role is an ENUM column in schema) ──

    private static final String SQL_FIND_BY_USERNAME =
        "SELECT * FROM users "
        + "WHERE (username = ? OR email = ? OR phone = ?) AND active = 1";

    private static final String SQL_FIND_BY_EMAIL =
        "SELECT * FROM users "
        + "WHERE email = ? AND active = 1";

    private static final String SQL_FIND_BY_ID =
        "SELECT * FROM users WHERE user_id = ?";

    private static final String SQL_FIND_ALL =
        "SELECT * FROM users ORDER BY created_at DESC, user_id DESC";

    private static final String SQL_FIND_BY_ROLES =
        "SELECT * FROM users "
        + "WHERE role IN (%s) "
        + "ORDER BY created_at DESC, user_id DESC";

    // ── Public methods ────────────────────────────────────────

    public Optional<User> findByUsername(String username) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_FIND_BY_USERNAME)) {
            ps.setString(1, username);
            ps.setString(2, username);
            ps.setString(3, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        }
        return Optional.empty();
    }

    public Optional<User> findByEmail(String email) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_FIND_BY_EMAIL)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        }
        return Optional.empty();
    }

    public Optional<User> findById(int userId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_FIND_BY_ID)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        }
        return Optional.empty();
    }

    public List<User> findAll() throws SQLException {
        List<User> users = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_FIND_ALL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                users.add(mapRow(rs));
            }
        }
        return users;
    }

    public List<User> findByRoles(String... roles) throws SQLException {
        List<User> users = new ArrayList<>();
        if (roles == null || roles.length == 0) {
            return users;
        }

        String placeholders = String.join(",", java.util.Collections.nCopies(roles.length, "?"));
        String sql = String.format(SQL_FIND_BY_ROLES, placeholders);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < roles.length; i++) {
                ps.setString(i + 1, roles[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapRow(rs));
                }
            }
        }
        return users;
    }

    public boolean insert(User user) throws SQLException {
        String sql = "INSERT INTO users (username, password_hash, full_name, email, phone, role, active, otp_preference, warehouse_id) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPasswordHash());
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getRole() != null ? user.getRole() : "WAREHOUSE_STAFF");
            ps.setInt(7, user.isActive() ? 1 : 0);
            ps.setString(8, user.getOtpPreference() != null ? user.getOtpPreference() : "EMAIL");
            ps.setInt(9, user.getWarehouseId() > 0 ? user.getWarehouseId() : 1);

            return ps.executeUpdate() > 0;
        }
    }

    public boolean update(User user) throws SQLException {
        String sql = "UPDATE users SET full_name = ?, email = ?, phone = ?, role = ?, active = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getRole() != null ? user.getRole() : "WAREHOUSE_STAFF");
            ps.setInt(5, user.isActive() ? 1 : 0);
            ps.setInt(6, user.getUserId());

            return ps.executeUpdate() > 0;
        }
    }

    public boolean toggleStatus(int userId, boolean active) throws SQLException {
        String sql = "UPDATE users SET active = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, active ? 1 : 0);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public void updateProfile(User user) throws SQLException {
        String sql = "UPDATE users SET full_name = ?, email = ?, phone = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setInt(4, user.getUserId());
            ps.executeUpdate();
        }
    }

    public void updatePassword(int userId, String passwordHash) throws SQLException {
        String sql = "UPDATE users SET password_hash = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, passwordHash);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    public void updateOtpPreference(int userId, String otpPreference) throws SQLException {
        String sql = "UPDATE users SET otp_preference = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, otpPreference);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    public boolean isUsernameTaken(String username, int excludeUserId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ? AND user_id != ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setInt(2, excludeUserId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    public void updateUsername(int userId, String newUsername) throws SQLException {
        String sql = "UPDATE users SET username = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newUsername);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    // ── Row mapper ────────────────────────────────────────────

    private User mapRow(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setUsername(rs.getString("username"));

        try { user.setPasswordHash(rs.getString("password_hash")); } catch (SQLException ignored) {}
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        try { user.setPhone(rs.getString("phone")); } catch (SQLException ignored) {}
        try { user.setOtpPreference(rs.getString("otp_preference")); } catch (SQLException ignored) {}

        // Role is the ENUM column in schema — no JOIN needed
        user.setRole(rs.getString("role"));

        try { user.setRoleId(rs.getInt("role_id")); } catch (SQLException ignored) {}

        user.setWarehouseId(rs.getInt("warehouse_id"));
        user.setActive(rs.getBoolean("active"));

        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) user.setCreatedAt(ca.toLocalDateTime());

        return user;
    }
}
