package com.wms.dao;

import com.wms.model.Product;
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
 * ProductDAO — Data Access Object for managing master SKU product records.
 */
public class ProductDAO {

    private static final Logger LOGGER = Logger.getLogger(ProductDAO.class.getName());

    public ProductDAO() {
    }

    /**
     * Retrieves all products ordered by product_id descending.
     *
     * @return A list of all products.
     */
    public List<Product> findAll() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.category_name, u.full_name AS creator_name, u2.full_name AS approver_name, "
                   + "(SELECT COALESCE(SUM(qty_on_hand), 0) FROM inventory WHERE product_id = p.product_id) AS qty_on_hand "
                   + "FROM products p "
                   + "LEFT JOIN categories c ON p.category_id = c.category_id "
                   + "LEFT JOIN users u ON p.created_by = u.user_id "
                   + "LEFT JOIN users u2 ON p.approved_by = u2.user_id "
                   + "ORDER BY p.product_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToProduct(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to find all products", e);
        }
        return list;
    }

    /**
     * Finds a single product by its primary key.
     *
     * @param productId The product ID to look up.
     * @return The Product object, or null if not found.
     */
    public Product findById(int productId) {
        String sql = "SELECT p.*, c.category_name, u.full_name AS creator_name, u2.full_name AS approver_name, "
                   + "(SELECT COALESCE(SUM(qty_on_hand), 0) FROM inventory WHERE product_id = p.product_id) AS qty_on_hand "
                   + "FROM products p "
                   + "LEFT JOIN categories c ON p.category_id = c.category_id "
                   + "LEFT JOIN users u ON p.created_by = u.user_id "
                   + "LEFT JOIN users u2 ON p.approved_by = u2.user_id "
                   + "WHERE p.product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToProduct(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to find product by ID " + productId, e);
        }
        return null;
    }

    /**
     * Finds all products belonging to a specific category.
     *
     * @param categoryId The category ID to filter by.
     * @return A list of matching products.
     */
    public List<Product> findByCategory(Integer categoryId) {
        List<Product> list = new ArrayList<>();
        String sql;
        PreparedStatement ps;
        try (Connection conn = DBConnection.getConnection()) {
            if (categoryId == null) {
                sql = "SELECT p.*, c.category_name, u.full_name AS creator_name, u2.full_name AS approver_name, "
                    + "(SELECT COALESCE(SUM(qty_on_hand), 0) FROM inventory WHERE product_id = p.product_id) AS qty_on_hand "
                    + "FROM products p "
                    + "LEFT JOIN categories c ON p.category_id = c.category_id "
                    + "LEFT JOIN users u ON p.created_by = u.user_id "
                    + "LEFT JOIN users u2 ON p.approved_by = u2.user_id "
                    + "WHERE p.category_id IS NULL ORDER BY p.product_id DESC";
                ps = conn.prepareStatement(sql);
            } else {
                sql = "SELECT p.*, c.category_name, u.full_name AS creator_name, u2.full_name AS approver_name, "
                    + "(SELECT COALESCE(SUM(qty_on_hand), 0) FROM inventory WHERE product_id = p.product_id) AS qty_on_hand "
                    + "FROM products p "
                    + "LEFT JOIN categories c ON p.category_id = c.category_id "
                    + "LEFT JOIN users u ON p.created_by = u.user_id "
                    + "LEFT JOIN users u2 ON p.approved_by = u2.user_id "
                    + "WHERE p.category_id = ? ORDER BY p.product_id DESC";
                ps = conn.prepareStatement(sql);
                ps.setInt(1, categoryId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to find products by category " + categoryId, e);
        }
        return list;
    }

    /**
     * Finds all products with status = PENDING (pending approval).
     *
     * @return A list of pending products.
     */
    public List<Product> findPendingApproval() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.category_name, u.full_name AS creator_name, u2.full_name AS approver_name, "
                   + "(SELECT COALESCE(SUM(qty_on_hand), 0) FROM inventory WHERE product_id = p.product_id) AS qty_on_hand "
                   + "FROM products p "
                   + "LEFT JOIN categories c ON p.category_id = c.category_id "
                   + "LEFT JOIN users u ON p.created_by = u.user_id "
                   + "LEFT JOIN users u2 ON p.approved_by = u2.user_id "
                   + "WHERE p.status = ? ORDER BY p.product_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, Product.STATUS_PENDING);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to find pending approval products", e);
        }
        return list;
    }

    /**
     * Finds all approved products.
     *
     * @return A list of approved products.
     */
    public List<Product> findApproved() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.category_name, u.full_name AS creator_name, u2.full_name AS approver_name, "
                   + "(SELECT COALESCE(SUM(qty_on_hand), 0) FROM inventory WHERE product_id = p.product_id) AS qty_on_hand "
                   + "FROM products p "
                   + "LEFT JOIN categories c ON p.category_id = c.category_id "
                   + "LEFT JOIN users u ON p.created_by = u.user_id "
                   + "LEFT JOIN users u2 ON p.approved_by = u2.user_id "
                   + "WHERE p.status = ? ORDER BY p.product_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, Product.STATUS_APPROVED);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to find approved products", e);
        }
        return list;
    }

    /**
     * Inserts a new product into the database.
     *
     * @param product The product model instance to insert.
     * @return true if successful, false otherwise.
     */
    public boolean insert(Product product) {
        String sql = "INSERT INTO products (sku_code, product_name, category_id, barcode, unit, "
                + "min_stock, max_stock, status, attributes_text, weight_kg, created_by) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, product.getSkuCode());
            ps.setString(2, product.getProductName());
            if (product.getCategoryId() != null) {
                ps.setInt(3, product.getCategoryId());
            } else {
                ps.setNull(3, java.sql.Types.INTEGER);
            }
            ps.setString(4, product.getBarcode());
            ps.setString(5, product.getUnit());
            ps.setDouble(6, product.getMinStock() != null ? product.getMinStock() : 0.0);
            ps.setDouble(7, product.getMaxStock() != null ? product.getMaxStock() : 0.0);
            ps.setString(8, product.getStatus() != null ? product.getStatus() : Product.STATUS_PENDING);
            ps.setString(9, product.getAttributesText());
            if (product.getWeightKg() != null) {
                ps.setDouble(10, product.getWeightKg());
            } else {
                ps.setNull(10, java.sql.Types.DECIMAL);
            }
            if (product.getCreatedBy() != null) {
                ps.setInt(11, product.getCreatedBy());
            } else {
                ps.setNull(11, java.sql.Types.INTEGER);
            }

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to insert product " + product.getSkuCode(), e);
            return false;
        }
    }

    /**
     * Updates an existing product.
     *
     * @param product The product with updated field values.
     * @return true if the update succeeded, false otherwise.
     */
    public boolean update(Product product) {
        String sql = "UPDATE products SET "
                + "sku_code = ?, product_name = ?, category_id = ?, barcode = ?, unit = ?, "
                + "min_stock = ?, max_stock = ?, status = ?, attributes_text = ?, weight_kg = ?, "
                + "updated_at = CURRENT_TIMESTAMP "
                + "WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, product.getSkuCode());
            ps.setString(2, product.getProductName());
            if (product.getCategoryId() != null) {
                ps.setInt(3, product.getCategoryId());
            } else {
                ps.setNull(3, java.sql.Types.INTEGER);
            }
            ps.setString(4, product.getBarcode());
            ps.setString(5, product.getUnit());
            ps.setDouble(6, product.getMinStock() != null ? product.getMinStock() : 0.0);
            ps.setDouble(7, product.getMaxStock() != null ? product.getMaxStock() : 0.0);
            ps.setString(8, product.getStatus());
            ps.setString(9, product.getAttributesText());
            if (product.getWeightKg() != null) {
                ps.setDouble(10, product.getWeightKg());
            } else {
                ps.setNull(10, java.sql.Types.DECIMAL);
            }
            ps.setInt(11, product.getProductId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to update product " + product.getProductId(), e);
            return false;
        }
    }

    /**
     * Approves a product — sets status to APPROVED and records approver + timestamp.
     *
     * @param productId  The product ID to approve.
     * @param approvedBy The user ID of the approver.
     * @return true if the update succeeded, false otherwise.
     */
    public boolean approve(int productId, int approvedBy) {
        String sql = "UPDATE products SET "
                + "status = ?, approved_at = CURRENT_TIMESTAMP, approved_by = ?, updated_at = CURRENT_TIMESTAMP "
                + "WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, Product.STATUS_APPROVED);
            ps.setInt(2, approvedBy);
            ps.setInt(3, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to approve product " + productId, e);
            return false;
        }
    }

    /**
     * Rejects a product — sets status to REJECTED.
     *
     * @param productId The product ID to reject.
     * @param reviewNote The reason for rejection.
     * @return true if the update succeeded, false otherwise.
     */
    public boolean reject(int productId, String reviewNote) {
        String sql = "UPDATE products SET "
                + "status = ?, review_note = ?, updated_at = CURRENT_TIMESTAMP "
                + "WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, Product.STATUS_REJECTED);
            ps.setString(2, reviewNote);
            ps.setInt(3, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to reject product " + productId, e);
            return false;
        }
    }

    public boolean reject(int productId) {
        return reject(productId, null);
    }

    public List<Product.LocationConfig> findDefaultZonesByProductId(int productId) {
        List<Product.LocationConfig> list = new ArrayList<>();
        String sql = "SELECT warehouse_id, zone_id FROM product_default_zones WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String locId = String.valueOf(rs.getInt("warehouse_id"));
                    String zoneId = String.valueOf(rs.getInt("zone_id"));
                    list.add(new Product.LocationConfig(locId, zoneId));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to find default zones for product " + productId, e);
        }
        return list;
    }

    public boolean approveProductWithZones(int productId, int approvedBy, List<Product.LocationConfig> configs) {
        Connection conn = null;
        PreparedStatement psApprove = null;
        PreparedStatement psDelete = null;
        PreparedStatement psInsert = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Approve product
            String approveSql = "UPDATE products SET status = ?, approved_at = CURRENT_TIMESTAMP, approved_by = ?, updated_at = CURRENT_TIMESTAMP WHERE product_id = ?";
            psApprove = conn.prepareStatement(approveSql);
            psApprove.setString(1, Product.STATUS_APPROVED);
            psApprove.setInt(2, approvedBy);
            psApprove.setInt(3, productId);
            psApprove.executeUpdate();

            // 2. Clear old default zones
            String deleteSql = "DELETE FROM product_default_zones WHERE product_id = ?";
            psDelete = conn.prepareStatement(deleteSql);
            psDelete.setInt(1, productId);
            psDelete.executeUpdate();

            // 3. Insert new default zones
            if (configs != null && !configs.isEmpty()) {
                String insertSql = "INSERT INTO product_default_zones (product_id, warehouse_id, zone_id) VALUES (?, ?, ?)";
                psInsert = conn.prepareStatement(insertSql);
                for (Product.LocationConfig cfg : configs) {
                    psInsert.setInt(1, productId);
                    psInsert.setInt(2, Integer.parseInt(cfg.getLocationId()));
                    psInsert.setInt(3, Integer.parseInt(cfg.getZoneId()));
                    psInsert.addBatch();
                }
                psInsert.executeBatch();
            }

            conn.commit();
            return true;
        } catch (SQLException | NumberFormatException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to approve product with zones for ID " + productId, e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback failed", ex); }
            }
            return false;
        } finally {
            DBConnection.closeQuietly(psApprove, psDelete, psInsert);
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "Failed to close Connection", e);
                }
            }
        }
    }

    /**
     * Maps a ResultSet row to a Product object.
     */
    private Product mapResultSetToProduct(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setProductId(rs.getInt("product_id"));
        product.setSkuCode(rs.getString("sku_code"));
        product.setProductName(rs.getString("product_name"));
        int categoryId = rs.getInt("category_id");
        product.setCategoryId(rs.wasNull() ? null : categoryId);
        product.setBarcode(rs.getString("barcode"));
        product.setUnit(rs.getString("unit"));
        product.setMinStock(rs.getDouble("min_stock"));
        product.setMaxStock(rs.getDouble("max_stock"));
        product.setStatus(rs.getString("status"));
        Timestamp approvedAt = rs.getTimestamp("approved_at");
        if (approvedAt != null) {
            product.setApprovedAt(approvedAt.toLocalDateTime());
        }
        int approvedBy = rs.getInt("approved_by");
        if (!rs.wasNull()) {
            product.setApprovedBy(approvedBy);
        }
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            product.setCreatedAt(createdAt.toLocalDateTime());
        }
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            product.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        // Populate joined and transient fields
        try {
            product.setCategoryName(rs.getString("category_name"));
        } catch (SQLException e) {
            // column not present
        }
        try {
            int createdBy = rs.getInt("created_by");
            product.setCreatedBy(rs.wasNull() ? null : createdBy);
        } catch (SQLException e) {
            // column not present
        }
        try {
            product.setCreatorName(rs.getString("creator_name"));
        } catch (SQLException e) {
            // column not present
        }
        try {
            product.setAttributesText(rs.getString("attributes_text"));
        } catch (SQLException e) {
            // column not present
        }
        try {
            double w = rs.getDouble("weight_kg");
            product.setWeightKg(rs.wasNull() ? null : w);
        } catch (SQLException e) {
            // column not present
        }
        try {
            product.setReviewNote(rs.getString("review_note"));
        } catch (SQLException e) {
            // column not present
        }
        try {
            product.setQtyOnHand(rs.getDouble("qty_on_hand"));
        } catch (SQLException e) {
            // column not present
        }
        try {
            product.setApproverName(rs.getString("approver_name"));
        } catch (SQLException e) {
            // column not present
        }

        // Load default zones for SKU
        product.setLocationConfigs(findDefaultZonesByProductId(product.getProductId()));

        return product;
    }
}
