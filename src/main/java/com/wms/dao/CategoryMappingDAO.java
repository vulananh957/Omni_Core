package com.wms.dao;

import com.wms.model.CategoryMapping;
import com.wms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * CategoryMappingDAO — UC-B2C09: CRUD for the WMS ↔ Lazada category
 * mapping table. Used by the "/sales/categories" page to curate
 * mappings and by the publish wizard to suggest Lazada leaves.
 */
public class CategoryMappingDAO {
    private static final Logger LOGGER = Logger.getLogger(CategoryMappingDAO.class.getName());

    public List<CategoryMapping> findByWmsCategory(int channelId, int wmsCategoryId) {
        List<CategoryMapping> out = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "SELECT mapping_id, channel_id, wms_category_id, lazada_category_id, "
                + "lazada_name, is_primary, created_by, created_at, updated_at "
                + "FROM category_mappings WHERE channel_id = ? AND wms_category_id = ? "
                + "ORDER BY is_primary DESC, lazada_name")) {
            ps.setInt(1, channelId);
            ps.setInt(2, wmsCategoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryMappingDAO.findByWmsCategory failed", e);
        }
        return out;
    }

    public List<CategoryMapping> findPrimaryForWms(int channelId, int wmsCategoryId) {
        List<CategoryMapping> out = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "SELECT mapping_id, channel_id, wms_category_id, lazada_category_id, "
                + "lazada_name, is_primary, created_by, created_at, updated_at "
                + "FROM category_mappings WHERE channel_id = ? AND wms_category_id = ? "
                + "AND is_primary = 1 ORDER BY lazada_name")) {
            ps.setInt(1, channelId);
            ps.setInt(2, wmsCategoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryMappingDAO.findPrimaryForWms failed", e);
        }
        return out;
    }

    public boolean insert(CategoryMapping m) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO category_mappings "
                + "(channel_id, wms_category_id, lazada_category_id, lazada_name, is_primary, created_by) "
                + "VALUES (?, ?, ?, ?, ?, ?)")) {
            ps.setInt(1, m.getChannelId());
            ps.setInt(2, m.getWmsCategoryId());
            ps.setLong(3, m.getLazadaCategoryId());
            ps.setString(4, m.getLazadaName());
            ps.setInt(5, m.isPrimary() ? 1 : 0);
            if (m.getCreatedBy() == null) ps.setNull(6, Types.INTEGER);
            else ps.setInt(6, m.getCreatedBy());
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            // Ignore dup-key (uk_mappings) — caller already created it
            if (e.getErrorCode() == 1062) return false;
            LOGGER.log(Level.WARNING, "CategoryMappingDAO.insert failed", e);
            return false;
        }
    }

    public boolean delete(int mappingId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM category_mappings WHERE mapping_id = ?")) {
            ps.setInt(1, mappingId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryMappingDAO.delete failed", e);
            return false;
        }
    }

    public boolean setPrimary(int mappingId, int channelId, int wmsCategoryId) {
        // Unset all primaries for the (channel, wms_category) tuple, then set the new one.
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement unset = conn.prepareStatement(
                    "UPDATE category_mappings SET is_primary = 0 "
                    + "WHERE channel_id = ? AND wms_category_id = ?")) {
                unset.setInt(1, channelId);
                unset.setInt(2, wmsCategoryId);
                unset.executeUpdate();
            }
            try (PreparedStatement setOne = conn.prepareStatement(
                    "UPDATE category_mappings SET is_primary = 1 WHERE mapping_id = ?")) {
                setOne.setInt(1, mappingId);
                setOne.executeUpdate();
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryMappingDAO.setPrimary failed", e);
            return false;
        }
    }

    public int countForWms(int channelId, int wmsCategoryId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) FROM category_mappings WHERE channel_id = ? AND wms_category_id = ?")) {
            ps.setInt(1, channelId);
            ps.setInt(2, wmsCategoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryMappingDAO.countForWms failed", e);
        }
        return 0;
    }

    private CategoryMapping mapRow(ResultSet rs) throws SQLException {
        CategoryMapping m = new CategoryMapping();
        m.setMappingId(rs.getInt("mapping_id"));
        m.setChannelId(rs.getInt("channel_id"));
        m.setWmsCategoryId(rs.getInt("wms_category_id"));
        m.setLazadaCategoryId(rs.getLong("lazada_category_id"));
        m.setLazadaName(rs.getString("lazada_name"));
        m.setPrimary(rs.getInt("is_primary") == 1);
        int cb = rs.getInt("created_by");
        m.setCreatedBy(rs.wasNull() ? null : cb);
        m.setCreatedAt(rs.getTimestamp("created_at"));
        m.setUpdatedAt(rs.getTimestamp("updated_at"));
        return m;
    }
}