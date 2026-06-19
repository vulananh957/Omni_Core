package com.wms.dao;

import com.wms.model.ProductImage;
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
 * ProductImageDAO — Data Access Object for {@code product_images}.
 *
 * <p>UC-B2C09: Lazada push pipeline reads product images to migrate them
 * to Lazada CDN via {@code /images/migrate} before pushing via
 * {@code /product/create}.</p>
 *
 * <p>Table schema (from {@code SchemaInitListener.ensureProductImagesTable()}):
 * <pre>
 * product_images(
 *   image_id INT PK,
 *   product_id INT NOT NULL,
 *   image_url VARCHAR(500) NOT NULL,
 *   is_primary TINYINT(1) NOT NULL DEFAULT 0,
 *   sort_order INT NOT NULL DEFAULT 0,
 *   created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
 * )
 * </pre></p>
 */
public class ProductImageDAO {

    private static final Logger LOGGER = Logger.getLogger(ProductImageDAO.class.getName());

    /**
     * Returns all images for a product, ordered by {@code sort_order} ASC,
     * then by {@code image_id} ASC (deterministic tie-break).
     */
    public List<ProductImage> findByProductId(int productId) {
        List<ProductImage> out = new ArrayList<>();
        String sql = "SELECT image_id, product_id, image_url, is_primary, sort_order, created_at "
                   + "FROM product_images WHERE product_id = ? "
                   + "ORDER BY sort_order ASC, image_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductImageDAO.findByProductId failed for productId=" + productId, e);
        }
        return out;
    }

    /**
     * Returns the primary image for a product, or {@code null} if none.
     * Lazada requires at least one image; the primary is the cover thumbnail.
     */
    public ProductImage findPrimary(int productId) {
        String sql = "SELECT image_id, product_id, image_url, is_primary, sort_order, created_at "
                   + "FROM product_images WHERE product_id = ? AND is_primary = 1 LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductImageDAO.findPrimary failed for productId=" + productId, e);
        }
        return null;
    }

    /** Inserts a new image row. Returns the generated image_id, or -1 on failure. */
    public int insert(ProductImage img) {
        String sql = "INSERT INTO product_images (product_id, image_url, is_primary, sort_order) "
                   + "VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, img.getProductId());
            ps.setString(2, img.getImageUrl());
            ps.setBoolean(3, img.isPrimary());
            ps.setInt(4, img.getSortOrder());
            if (ps.executeUpdate() == 0) return -1;
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
            return -1;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductImageDAO.insert failed", e);
            return -1;
        }
    }

    private ProductImage mapRow(ResultSet rs) throws SQLException {
        ProductImage img = new ProductImage();
        img.setImageId(rs.getInt("image_id"));
        img.setProductId(rs.getInt("product_id"));
        img.setImageUrl(rs.getString("image_url"));
        img.setPrimary(rs.getBoolean("is_primary"));
        img.setSortOrder(rs.getInt("sort_order"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) img.setCreatedAt(createdAt.toLocalDateTime());
        return img;
    }
}
