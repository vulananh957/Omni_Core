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
        String sql = "SELECT * FROM products ORDER BY product_id DESC";
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
        String sql = "SELECT * FROM products WHERE product_id = ?";
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
                sql = "SELECT * FROM products WHERE category_id IS NULL ORDER BY product_id DESC";
                ps = conn.prepareStatement(sql);
            } else {
                sql = "SELECT * FROM products WHERE category_id = ? ORDER BY product_id DESC";
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
        String sql = "SELECT * FROM products WHERE status = ? ORDER BY product_id DESC";
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
        String sql = "SELECT * FROM products WHERE status = ? ORDER BY product_id DESC";
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
                + "min_stock, max_stock, status, created_by) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
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
            ps.setNull(9, java.sql.Types.INTEGER);

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
                + "min_stock = ?, max_stock = ?, status = ?, updated_at = CURRENT_TIMESTAMP "
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
            ps.setInt(9, product.getProductId());

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
     * @return true if the update succeeded, false otherwise.
     */
    public boolean reject(int productId) {
        String sql = "UPDATE products SET "
                + "status = ?, updated_at = CURRENT_TIMESTAMP "
                + "WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, Product.STATUS_REJECTED);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to reject product " + productId, e);
            return false;
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
        return product;
    }
}
