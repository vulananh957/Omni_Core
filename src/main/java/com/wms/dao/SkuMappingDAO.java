package com.wms.dao;

import com.wms.model.Product;
import com.wms.model.SkuMapping;
import com.wms.util.DBConnection;

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
 * SkuMappingDAO — Data Access Object for SKU-to-channel mapping records.
 */
public class SkuMappingDAO {

    private static final Logger LOGGER = Logger.getLogger(SkuMappingDAO.class.getName());

    /**
     * Retrieves all SKU mappings with enriched channel and product info.
     */
    public List<SkuMapping> findAll() {
        List<SkuMapping> list = new ArrayList<>();
        String sql = "SELECT sm.mapping_id, sm.sku_id, sm.channel_id, sm.external_sku, "
                   + "sm.seller_sku, sm.sync_status, sm.last_sync_at, sm.created_at, sm.updated_at, "
                   + "c.channel_name, c.platform, s.sku_code, s.product_name "
                   + "FROM sku_mappings sm "
                   + "LEFT JOIN channels c ON sm.channel_id = c.channel_id "
                   + "LEFT JOIN products s ON sm.sku_id = s.product_id "
                   + "ORDER BY sm.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToSkuMapping(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "SkuMappingDAO: Failed to retrieve all mappings", e);
        }
        return list;
    }

    /**
     * Finds a single SKU mapping by its primary key.
     */
    public SkuMapping findById(int mappingId) {
        String sql = "SELECT sm.mapping_id, sm.sku_id, sm.channel_id, sm.external_sku, "
                   + "sm.seller_sku, sm.sync_status, sm.last_sync_at, sm.created_at, sm.updated_at, "
                   + "c.channel_name, c.platform, s.sku_code, s.product_name "
                   + "FROM sku_mappings sm "
                   + "LEFT JOIN channels c ON sm.channel_id = c.channel_id "
                   + "LEFT JOIN products s ON sm.sku_id = s.product_id "
                   + "WHERE sm.mapping_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, mappingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSkuMapping(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "SkuMappingDAO: Failed to find mapping by ID " + mappingId, e);
        }
        return null;
    }

    /**
     * Retrieves all mappings for a given channel.
     */
    public List<SkuMapping> findByChannel(int channelId) {
        List<SkuMapping> list = new ArrayList<>();
        String sql = "SELECT sm.mapping_id, sm.sku_id, sm.channel_id, sm.external_sku, "
                   + "sm.seller_sku, sm.sync_status, sm.last_sync_at, sm.created_at, sm.updated_at, "
                   + "c.channel_name, c.platform, s.sku_code, s.product_name "
                   + "FROM sku_mappings sm "
                   + "LEFT JOIN channels c ON sm.channel_id = c.channel_id "
                   + "LEFT JOIN products s ON sm.sku_id = s.product_id "
                   + "WHERE sm.channel_id = ? "
                   + "ORDER BY sm.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, channelId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToSkuMapping(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "SkuMappingDAO: Failed to find mappings by channel " + channelId, e);
        }
        return list;
    }

    /**
     * Retrieves all mappings for a given product SKU.
     */
    public List<SkuMapping> findBySku(int skuId) {
        List<SkuMapping> list = new ArrayList<>();
        String sql = "SELECT sm.mapping_id, sm.sku_id, sm.channel_id, sm.external_sku, "
                   + "sm.seller_sku, sm.sync_status, sm.last_sync_at, sm.created_at, sm.updated_at, "
                   + "c.channel_name, c.platform, s.sku_code, s.product_name "
                   + "FROM sku_mappings sm "
                   + "LEFT JOIN channels c ON sm.channel_id = c.channel_id "
                   + "LEFT JOIN products s ON sm.sku_id = s.product_id "
                   + "WHERE sm.sku_id = ? "
                   + "ORDER BY sm.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, skuId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToSkuMapping(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "SkuMappingDAO: Failed to find mappings by SKU " + skuId, e);
        }
        return list;
    }

    /**
     * Retrieves all mappings filtered by sync status.
     */
    public List<SkuMapping> findByStatus(String syncStatus) {
        List<SkuMapping> list = new ArrayList<>();
        String sql = "SELECT sm.mapping_id, sm.sku_id, sm.channel_id, sm.external_sku, "
                   + "sm.seller_sku, sm.sync_status, sm.last_sync_at, sm.created_at, sm.updated_at, "
                   + "c.channel_name, c.platform, s.sku_code, s.product_name "
                   + "FROM sku_mappings sm "
                   + "LEFT JOIN channels c ON sm.channel_id = c.channel_id "
                   + "LEFT JOIN products s ON sm.sku_id = s.product_id "
                   + "WHERE sm.sync_status = ? "
                   + "ORDER BY sm.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, syncStatus);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToSkuMapping(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "SkuMappingDAO: Failed to find mappings by status " + syncStatus, e);
        }
        return list;
    }

    /**
     * Inserts a new SKU mapping record.
     */
    public boolean insert(SkuMapping mapping) {
        String sql = "INSERT INTO sku_mappings (sku_id, channel_id, external_sku, seller_sku, sync_status, last_sync_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, mapping.getSkuId());
            ps.setInt(2, mapping.getChannelId());
            ps.setString(3, mapping.getExternalSku());
            ps.setString(4, mapping.getSellerSku());
            ps.setString(5, mapping.getSyncStatus() != null ? mapping.getSyncStatus() : "PENDING");

            Timestamp lastSync = null;
            if (mapping.getLastSyncAt() != null) {
                lastSync = Timestamp.valueOf(mapping.getLastSyncAt());
            }
            ps.setTimestamp(6, lastSync);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "SkuMappingDAO: Failed to insert mapping", e);
            return false;
        }
    }

    /**
     * Updates an existing SKU mapping record.
     */
    public boolean update(SkuMapping mapping) {
        String sql = "UPDATE sku_mappings SET "
                   + "sku_id = ?, channel_id = ?, external_sku = ?, seller_sku = ?, "
                   + "sync_status = ?, last_sync_at = ?, updated_at = CURRENT_TIMESTAMP "
                   + "WHERE mapping_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, mapping.getSkuId());
            ps.setInt(2, mapping.getChannelId());
            ps.setString(3, mapping.getExternalSku());
            ps.setString(4, mapping.getSellerSku());
            ps.setString(5, mapping.getSyncStatus());
            ps.setTimestamp(6, mapping.getLastSyncAt() != null ? Timestamp.valueOf(mapping.getLastSyncAt()) : null);
            ps.setInt(7, mapping.getMappingId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "SkuMappingDAO: Failed to update mapping " + mapping.getMappingId(), e);
            return false;
        }
    }

    /**
     * Deletes a SKU mapping by its primary key.
     */
    public boolean delete(int mappingId) {
        String sql = "DELETE FROM sku_mappings WHERE mapping_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, mappingId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "SkuMappingDAO: Failed to delete mapping " + mappingId, e);
            return false;
        }
    }

    /**
     * Updates the sync status and last sync timestamp for a mapping.
     */
    public boolean updateSyncStatus(int mappingId, String syncStatus) {
        String sql = "UPDATE sku_mappings SET sync_status = ?, last_sync_at = CURRENT_TIMESTAMP, "
                   + "updated_at = CURRENT_TIMESTAMP WHERE mapping_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, syncStatus);
            ps.setInt(2, mappingId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "SkuMappingDAO: Failed to update sync status for " + mappingId, e);
            return false;
        }
    }

    private SkuMapping mapResultSetToSkuMapping(ResultSet rs) throws SQLException {
        SkuMapping m = new SkuMapping();
        m.setMappingId(rs.getInt("mapping_id"));
        m.setSkuId(rs.getInt("sku_id"));
        m.setChannelId(rs.getInt("channel_id"));
        m.setExternalSku(rs.getString("external_sku"));
        m.setSellerSku(rs.getString("seller_sku"));
        m.setSyncStatus(rs.getString("sync_status"));

        Timestamp lastSync = rs.getTimestamp("last_sync_at");
        if (lastSync != null) {
            m.setLastSyncAt(lastSync.toLocalDateTime());
        }

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            m.setCreatedAt(createdAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            m.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        m.setChannelName(rs.getString("channel_name"));
        m.setChannelPlatform(rs.getString("platform"));
        m.setSkuCode(rs.getString("sku_code"));
        m.setProductName(rs.getString("product_name"));

        return m;
    }

    /**
     * Lấy tất cả APPROVED Master SKU từ bảng products để hiển thị trên form mapping.
     */
    public List<Product> findAllSkus() {
        List<Product> list = new ArrayList<>();
        // Manager-created SKUs are immediately active (no PENDING/APPROVED workflow).
        // We still prefer ACTIVE rows when 'active' is 1; fallback to all rows for
        // safety in environments where the column has not been migrated yet.
        String sql = "SELECT product_id, sku_code, product_name FROM products "
                   + "ORDER BY sku_code ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Product p = new Product();
                p.setProductId(rs.getInt("product_id"));
                p.setSkuCode(rs.getString("sku_code"));
                p.setProductName(rs.getString("product_name"));
                list.add(p);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "SkuMappingDAO: Failed to retrieve all master SKUs", e);
        }
        return list;
    }

    /**
     * Looks up a SKU mapping by channel + external_sku (the marketplace SKU).
     * Returns the mapping only if sync_status = 'SYNCED' (approved for that channel).
     *
     * Replaces the previous behaviour where LazadaSyncScheduler hardcoded a
     * dummy product ID, leaving real internal SKUs disconnected from marketplace orders.
     *
     * @return The active mapping, or null if not found
     */
    public SkuMapping findActiveMapping(int channelId, String externalSku) {
        if (externalSku == null || externalSku.trim().isEmpty()) return null;
        String sql = "SELECT sm.mapping_id, sm.sku_id, sm.channel_id, sm.external_sku, "
                   + "sm.seller_sku, sm.sync_status, sm.last_sync_at, sm.created_at, sm.updated_at, "
                   + "c.channel_name, c.platform, s.sku_code, s.product_name "
                   + "FROM sku_mappings sm "
                   + "LEFT JOIN channels c ON sm.channel_id = c.channel_id "
                   + "LEFT JOIN products s ON sm.sku_id = s.product_id "
                   + "WHERE sm.channel_id = ? AND sm.external_sku = ? AND sm.sync_status = 'SYNCED' "
                   + "LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, channelId);
            ps.setString(2, externalSku.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSkuMapping(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING,
                "SkuMappingDAO.findActiveMapping: failed channelId=" + channelId
                    + " externalSku=" + externalSku, e);
        }
        return null;
    }

    /**
     * Finds all active (SYNCED) SKU mappings for a list of product IDs on a given channel,
     * enriched with Lazada identifiers from channel_products.
     *
     * Used by MarketplaceSyncService to resolve which SKUs need stock pushed to Lazada
     * after an inbound receipt is confirmed.
     *
     * @param productIds List of internal product IDs to look up.
     * @param channelId The marketplace channel to filter on.
     * @return List of matching SkuMapping objects with enriched Lazada fields.
     */
    public List<SkuMapping> findActiveMappingsByProductIds(List<Integer> productIds, int channelId) {
        List<SkuMapping> list = new ArrayList<>();
        if (productIds == null || productIds.isEmpty()) return list;

        String placeholders = String.join(",", java.util.Collections.nCopies(productIds.size(), "?"));
        String sql = "SELECT sm.mapping_id, sm.sku_id, sm.channel_id, sm.external_sku, "
                   + "sm.seller_sku, sm.sync_status, sm.last_sync_at, sm.created_at, sm.updated_at, "
                   + "c.channel_name, c.platform, s.sku_code, s.product_name, "
                   + "cp.channel_item_id, cp.lazada_sku_id "
                   + "FROM sku_mappings sm "
                   + "LEFT JOIN channels c ON sm.channel_id = c.channel_id "
                   + "LEFT JOIN products s ON sm.sku_id = s.product_id "
                   + "LEFT JOIN channel_products cp ON sm.sku_id = cp.product_id AND sm.channel_id = cp.channel_id "
                   + "WHERE sm.sku_id IN (" + placeholders + ") "
                   + "  AND sm.channel_id = ? "
                   + "  AND sm.sync_status = 'SYNCED' "
                   + "  AND cp.lazada_sku_id IS NOT NULL AND cp.lazada_sku_id != '' "
                   + "  AND cp.status = 'ACTIVE'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            for (Integer pid : productIds) {
                ps.setInt(idx++, pid);
            }
            ps.setInt(idx, channelId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SkuMapping m = mapResultSetToSkuMapping(rs);
                    m.setChannelItemId(rs.getString("channel_item_id"));
                    m.setLazadaSkuId(rs.getString("lazada_sku_id"));
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING,
                "SkuMappingDAO.findActiveMappingsByProductIds: failed channelId=" + channelId, e);
        }
        return list;
    }

    /**
     * Logs an exception when an SKU mapping is missing.
     * Feeds the "Mapping Exception Management" page used by Sales staff.
     */
    public void logMappingException(int channelId, String externalSku,
                                    String orderCode, String reason) {
        String sql = "INSERT INTO mapping_exceptions "
                   + "(channel_id, external_sku, order_code, reason, created_at) "
                   + "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, channelId);
            ps.setString(2, externalSku);
            ps.setString(3, orderCode);
            ps.setString(4, reason);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING,
                "SkuMappingDAO.logMappingException: failed to log", e);
        }
    }
}
