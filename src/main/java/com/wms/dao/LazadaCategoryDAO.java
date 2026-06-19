package com.wms.dao;

import com.wms.model.LazadaCategory;
import com.wms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LazadaCategoryDAO — UC-B2C09: stores Lazada's category tree
 * (mirrored from /category/tree/get) for product-push lookups.
 */
public class LazadaCategoryDAO {
    private static final Logger LOGGER = Logger.getLogger(LazadaCategoryDAO.class.getName());

    /** Replaces all rows for a channel in one transaction. */
    public boolean replaceAll(int channelId, List<LazadaCategory> cats) {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement del = conn.prepareStatement(
                    "DELETE FROM lazada_categories WHERE channel_id = ?")) {
                del.setInt(1, channelId);
                del.executeUpdate();
            }
            try (PreparedStatement ins = conn.prepareStatement(
                    "INSERT INTO lazada_categories "
                    + "(channel_id, lazada_category_id, parent_id, name, is_leaf, has_variation, depth) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?)")) {
                for (LazadaCategory c : cats) {
                    ins.setInt(1, channelId);
                    ins.setLong(2, c.getLazadaCategoryId());
                    if (c.getParentId() == null) ins.setNull(3, Types.BIGINT);
                    else ins.setLong(3, c.getParentId());
                    ins.setString(4, c.getName());
                    ins.setInt(5, c.isLeaf() ? 1 : 0);
                    ins.setInt(6, c.isHasVariation() ? 1 : 0);
                    ins.setInt(7, c.getDepth());
                    ins.addBatch();
                }
                ins.executeBatch();
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "LazadaCategoryDAO.replaceAll failed", e);
            return false;
        }
    }

    public List<LazadaCategory> findLeaves(int channelId) {
        List<LazadaCategory> out = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "SELECT lazada_category_id, parent_id, name, is_leaf, has_variation, depth "
                + "FROM lazada_categories WHERE channel_id = ? AND is_leaf = 1 ORDER BY name")) {
            ps.setInt(1, channelId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "LazadaCategoryDAO.findLeaves failed", e);
        }
        return out;
    }

    public int count(int channelId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) FROM lazada_categories WHERE channel_id = ?")) {
            ps.setInt(1, channelId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "LazadaCategoryDAO.count failed", e);
        }
        return 0;
    }

    public LazadaCategory findLeafById(int channelId, long lazadaCategoryId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "SELECT lazada_category_id, parent_id, name, is_leaf, has_variation, depth "
                + "FROM lazada_categories WHERE channel_id = ? AND lazada_category_id = ? AND is_leaf = 1")) {
            ps.setInt(1, channelId);
            ps.setLong(2, lazadaCategoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "LazadaCategoryDAO.findLeafById failed", e);
        }
        return null;
    }

    private LazadaCategory mapRow(ResultSet rs) throws SQLException {
        LazadaCategory c = new LazadaCategory();
        c.setLazadaCategoryId(rs.getLong("lazada_category_id"));
        long p = rs.getLong("parent_id");
        c.setParentId(rs.wasNull() ? null : p);
        c.setName(rs.getString("name"));
        c.setLeaf(rs.getInt("is_leaf") == 1);
        c.setHasVariation(rs.getInt("has_variation") == 1);
        c.setDepth(rs.getInt("depth"));
        return c;
    }
}