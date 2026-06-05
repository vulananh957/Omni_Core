package com.wms.dao;

import com.wms.model.ChannelProduct;
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
 * ChannelProductDAO — Data Access Object for channel-specific product listings.
 */
public class ChannelProductDAO {

    private static final Logger LOGGER = Logger.getLogger(ChannelProductDAO.class.getName());

    /**
     * Retrieves all channel products with enriched channel and product info.
     */
    public List<ChannelProduct> findAll() {
        List<ChannelProduct> list = new ArrayList<>();
        String sql = "SELECT cp.id, cp.channel_id, cp.product_id, cp.channel_sku_code, "
                   + "cp.channel_price, cp.channel_stock, cp.status, cp.listed_at, cp.updated_at, "
                   + "c.channel_name, c.platform, p.sku_code, p.product_name, cat.category_name "
                   + "FROM channel_products cp "
                   + "LEFT JOIN channels c ON cp.channel_id = c.channel_id "
                   + "LEFT JOIN products p ON cp.product_id = p.product_id "
                   + "LEFT JOIN categories cat ON p.category_id = cat.category_id "
                   + "ORDER BY cp.updated_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToChannelProduct(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ChannelProductDAO: Failed to retrieve all channel products", e);
        }
        return list;
    }

    /**
     * Finds a single channel product by its primary key.
     */
    public ChannelProduct findById(int id) {
        String sql = "SELECT cp.id, cp.channel_id, cp.product_id, cp.channel_sku_code, "
                   + "cp.channel_price, cp.channel_stock, cp.status, cp.listed_at, cp.updated_at, "
                   + "c.channel_name, c.platform, p.sku_code, p.product_name, cat.category_name "
                   + "FROM channel_products cp "
                   + "LEFT JOIN channels c ON cp.channel_id = c.channel_id "
                   + "LEFT JOIN products p ON cp.product_id = p.product_id "
                   + "LEFT JOIN categories cat ON p.category_id = cat.category_id "
                   + "WHERE cp.id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToChannelProduct(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ChannelProductDAO: Failed to find channel product by ID " + id, e);
        }
        return null;
    }

    /**
     * Retrieves all channel products for a given channel.
     */
    public List<ChannelProduct> findByChannel(int channelId) {
        List<ChannelProduct> list = new ArrayList<>();
        String sql = "SELECT cp.id, cp.channel_id, cp.product_id, cp.channel_sku_code, "
                   + "cp.channel_price, cp.channel_stock, cp.status, cp.listed_at, cp.updated_at, "
                   + "c.channel_name, c.platform, p.sku_code, p.product_name, cat.category_name "
                   + "FROM channel_products cp "
                   + "LEFT JOIN channels c ON cp.channel_id = c.channel_id "
                   + "LEFT JOIN products p ON cp.product_id = p.product_id "
                   + "LEFT JOIN categories cat ON p.category_id = cat.category_id "
                   + "WHERE cp.channel_id = ? "
                   + "ORDER BY cp.updated_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, channelId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToChannelProduct(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ChannelProductDAO: Failed to find channel products by channel " + channelId, e);
        }
        return list;
    }

    /**
     * Retrieves all channel products for a given product.
     */
    public List<ChannelProduct> findByProduct(int productId) {
        List<ChannelProduct> list = new ArrayList<>();
        String sql = "SELECT cp.id, cp.channel_id, cp.product_id, cp.channel_sku_code, "
                   + "cp.channel_price, cp.channel_stock, cp.status, cp.listed_at, cp.updated_at, "
                   + "c.channel_name, c.platform, p.sku_code, p.product_name, cat.category_name "
                   + "FROM channel_products cp "
                   + "LEFT JOIN channels c ON cp.channel_id = c.channel_id "
                   + "LEFT JOIN products p ON cp.product_id = p.product_id "
                   + "LEFT JOIN categories cat ON p.category_id = cat.category_id "
                   + "WHERE cp.product_id = ? "
                   + "ORDER BY cp.updated_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToChannelProduct(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ChannelProductDAO: Failed to find channel products by product " + productId, e);
        }
        return list;
    }

    /**
     * Retrieves all channel products filtered by status.
     */
    public List<ChannelProduct> findByStatus(String status) {
        List<ChannelProduct> list = new ArrayList<>();
        String sql = "SELECT cp.id, cp.channel_id, cp.product_id, cp.channel_sku_code, "
                   + "cp.channel_price, cp.channel_stock, cp.status, cp.listed_at, cp.updated_at, "
                   + "c.channel_name, c.platform, p.sku_code, p.product_name, cat.category_name "
                   + "FROM channel_products cp "
                   + "LEFT JOIN channels c ON cp.channel_id = c.channel_id "
                   + "LEFT JOIN products p ON cp.product_id = p.product_id "
                   + "LEFT JOIN categories cat ON p.category_id = cat.category_id "
                   + "WHERE cp.status = ? "
                   + "ORDER BY cp.updated_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToChannelProduct(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ChannelProductDAO: Failed to find channel products by status " + status, e);
        }
        return list;
    }

    /**
     * Inserts a new channel product record.
     */
    public boolean insert(ChannelProduct cp) {
        String sql = "INSERT INTO channel_products (channel_id, product_id, channel_sku_code, "
                   + "channel_price, channel_stock, status, listed_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cp.getChannelId());
            ps.setInt(2, cp.getProductId());
            ps.setString(3, cp.getChannelSkuCode());
            ps.setBigDecimal(4, cp.getChannelPrice());
            ps.setBigDecimal(5, cp.getChannelStock());
            ps.setString(6, cp.getStatus() != null ? cp.getStatus() : "ACTIVE");
            ps.setTimestamp(7, cp.getListedAt() != null ? Timestamp.valueOf(cp.getListedAt()) : null);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ChannelProductDAO: Failed to insert channel product", e);
            return false;
        }
    }

    /**
     * Updates an existing channel product record.
     */
    public boolean update(ChannelProduct cp) {
        String sql = "UPDATE channel_products SET "
                   + "channel_id = ?, product_id = ?, channel_sku_code = ?, "
                   + "channel_price = ?, channel_stock = ?, status = ?, updated_at = CURRENT_TIMESTAMP "
                   + "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cp.getChannelId());
            ps.setInt(2, cp.getProductId());
            ps.setString(3, cp.getChannelSkuCode());
            ps.setBigDecimal(4, cp.getChannelPrice());
            ps.setBigDecimal(5, cp.getChannelStock());
            ps.setString(6, cp.getStatus());
            ps.setInt(7, cp.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ChannelProductDAO: Failed to update channel product " + cp.getId(), e);
            return false;
        }
    }

    /**
     * Syncs the channel product price from WMS.
     */
    public boolean syncPrice(int channelProductId, BigDecimal newPrice) {
        String sql = "UPDATE channel_products SET "
                   + "channel_price = ?, status = 'ACTIVE', updated_at = CURRENT_TIMESTAMP "
                   + "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, newPrice);
            ps.setInt(2, channelProductId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ChannelProductDAO: Failed to sync price for " + channelProductId, e);
            return false;
        }
    }

    /**
     * Syncs the channel product stock from WMS.
     */
    public boolean syncStock(int channelProductId, BigDecimal newStock) {
        String sql = "UPDATE channel_products SET "
                   + "channel_stock = ?, status = 'ACTIVE', updated_at = CURRENT_TIMESTAMP "
                   + "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, newStock);
            ps.setInt(2, channelProductId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ChannelProductDAO: Failed to sync stock for " + channelProductId, e);
            return false;
        }
    }

    /**
     * Updates the last_synced timestamp for a channel product.
     */
    public boolean updateLastSynced(int channelProductId) {
        String sql = "UPDATE channel_products SET updated_at = CURRENT_TIMESTAMP WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, channelProductId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ChannelProductDAO: Failed to update last synced for " + channelProductId, e);
            return false;
        }
    }

    private ChannelProduct mapResultSetToChannelProduct(ResultSet rs) throws SQLException {
        ChannelProduct cp = new ChannelProduct();
        cp.setId(rs.getInt("id"));
        cp.setChannelId(rs.getInt("channel_id"));
        cp.setProductId(rs.getInt("product_id"));
        cp.setChannelSkuCode(rs.getString("channel_sku_code"));
        cp.setChannelPrice(rs.getBigDecimal("channel_price"));
        cp.setChannelStock(rs.getBigDecimal("channel_stock"));
        cp.setStatus(rs.getString("status"));

        Timestamp listedAt = rs.getTimestamp("listed_at");
        if (listedAt != null) {
            cp.setListedAt(listedAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            cp.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        cp.setChannelName(rs.getString("channel_name"));
        cp.setChannelPlatform(rs.getString("platform"));
        cp.setSkuCode(rs.getString("sku_code"));
        cp.setProductName(rs.getString("product_name"));
        cp.setCategoryName(rs.getString("category_name"));

        return cp;
    }
}
