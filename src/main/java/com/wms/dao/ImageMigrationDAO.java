package com.wms.dao;

import com.wms.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * ImageMigrationDAO — Data Access Object for {@code product_image_migrations}.
 *
 * <p>UC-B2C09: Lazada requires image URLs to live on its CDN. Each external
 * URL is migrated via {@code POST /images/migrate}; the resulting Lazada
 * image URL/id is cached here so subsequent pushes of the same product can
 * skip the migration HTTP call entirely.</p>
 *
 * <p>Unique key: {@code (channel_id, source_url(255))}. One row per
 * (channel, source URL) pair.</p>
 */
public class ImageMigrationDAO {

    private static final Logger LOGGER = Logger.getLogger(ImageMigrationDAO.class.getName());

    /**
     * Look up cached migration by channel + URL. Returns null if not cached.
     */
    public MigrationRecord findByUrl(int channelId, String sourceUrl) {
        if (sourceUrl == null || sourceUrl.isBlank()) return null;
        String sql = "SELECT lazada_image_url, lazada_image_id "
                   + "FROM product_image_migrations "
                   + "WHERE channel_id = ? AND source_url = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, channelId);
            ps.setString(2, sourceUrl);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new MigrationRecord(rs.getString("lazada_image_url"),
                                               rs.getString("lazada_image_id"));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING,
                "ImageMigrationDAO.findByUrl failed channel=" + channelId, e);
        }
        return null;
    }

    /**
     * Batch lookup: for each source URL, returns map (url -> MigrationRecord)
     * for those that exist in cache. Missing URLs are simply not in the result.
     */
    public Map<String, MigrationRecord> findCachedUrls(int channelId, List<String> sourceUrls) {
        Map<String, MigrationRecord> out = new HashMap<>();
        if (sourceUrls == null || sourceUrls.isEmpty()) return out;
        StringBuilder sql = new StringBuilder(
            "SELECT source_url, lazada_image_url, lazada_image_id "
          + "FROM product_image_migrations WHERE channel_id = ? AND source_url IN (");
        for (int i = 0; i < sourceUrls.size(); i++) {
            sql.append(i == 0 ? "?" : ",?");
        }
        sql.append(")");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, channelId);
            for (int i = 0; i < sourceUrls.size(); i++) {
                ps.setString(i + 2, sourceUrls.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.put(rs.getString("source_url"),
                            new MigrationRecord(rs.getString("lazada_image_url"),
                                                rs.getString("lazada_image_id")));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING,
                "ImageMigrationDAO.findCachedUrls failed channel=" + channelId, e);
        }
        return out;
    }

    /**
     * Idempotent insert: if a row with the same (channel_id, source_url)
     * already exists, update its lazada fields. Returns true on success.
     */
    public boolean upsert(int channelId, String sourceUrl,
                          String lazadaImageUrl, String lazadaImageId) {
        String sql = "INSERT INTO product_image_migrations "
                   + "(channel_id, source_url, lazada_image_url, lazada_image_id, migrated_at) "
                   + "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP) "
                   + "ON DUPLICATE KEY UPDATE "
                   + "lazada_image_url = VALUES(lazada_image_url), "
                   + "lazada_image_id = VALUES(lazada_image_id), "
                   + "migrated_at = CURRENT_TIMESTAMP";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, channelId);
            ps.setString(2, sourceUrl);
            ps.setString(3, lazadaImageUrl);
            ps.setString(4, lazadaImageId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING,
                "ImageMigrationDAO.upsert failed channel=" + channelId + " url=" + sourceUrl, e);
            return false;
        }
    }

    /** Plain record: Lazada-side image URL + image id. */
    public static final class MigrationRecord {
        public final String lazadaImageUrl;
        public final String lazadaImageId;
        public MigrationRecord(String lazadaImageUrl, String lazadaImageId) {
            this.lazadaImageUrl = lazadaImageUrl;
            this.lazadaImageId = lazadaImageId;
        }
    }
}
