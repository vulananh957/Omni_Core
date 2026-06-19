package com.wms.dao;

import com.wms.model.Product;
import com.wms.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * ProductDAO — Data Access Object for managing master SKU product records.
 *
 * Optimizations applied:
 * - All SELECTs share a single private builder method to eliminate code duplication.
 * - Default zones are fetched in a single batch query (instead of per-product),
 *   eliminating the N+1 query problem when loading product lists.
 */
public class ProductDAO {

    private static final Logger LOGGER = Logger.getLogger(ProductDAO.class.getName());

    private static final String SELECT_CORE =
        "SELECT p.product_id, p.sku_code, p.product_name, p.category_id, p.barcode, p.unit, "
        + "p.min_stock, p.max_stock, p.attributes_text, p.weight_kg, p.base_price, p.created_by, p.created_at, p.updated_at, "
        + "p.short_description, "
        + "c.category_name, u.full_name AS creator_name, "
        + "COALESCE(i.qty_on_hand, 0) AS qty_on_hand "
        + "FROM products p "
        + "LEFT JOIN categories c ON p.category_id = c.category_id "
        + "LEFT JOIN users u ON p.created_by = u.user_id "
        + "LEFT JOIN (SELECT product_id, SUM(qty_on_hand) AS qty_on_hand FROM inventory GROUP BY product_id) i ON p.product_id = i.product_id";

    public ProductDAO() {
    }

    /**
     * Retrieves all products ordered by product_id descending.
     * Zones are fetched in a single batch query — no N+1 problem.
     */
    public List<Product> findAll() {
        Map<Integer, List<Product.LocationConfig>> zonesMap = batchFindDefaultZones();
        List<Product> list = new ArrayList<>();
        String sql = SELECT_CORE + " ORDER BY p.product_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs, zonesMap.getOrDefault(getProductId(rs), List.of())));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to find all products", e);
        }
        return list;
    }

    /**
     * Finds a single product by its primary key.
     */
    public Product findById(int productId) {
        List<Product.LocationConfig> zones = findDefaultZonesByProductId(productId);
        String sql = SELECT_CORE + " WHERE p.product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs, zones);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to find product by ID " + productId, e);
        }
        return null;
    }

    /**
     * Finds all products belonging to a specific category.
     */
    public List<Product> findByCategory(Integer categoryId) {
        Map<Integer, List<Product.LocationConfig>> zonesMap = batchFindDefaultZones();
        List<Product> list = new ArrayList<>();
        String whereClause;
        if (categoryId == null) {
            whereClause = " WHERE p.category_id IS NULL";
        } else {
            whereClause = " WHERE p.category_id = ?";
        }
        String sql = SELECT_CORE + whereClause + " ORDER BY p.product_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (categoryId != null) {
                ps.setInt(1, categoryId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs, zonesMap.getOrDefault(getProductId(rs), List.of())));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to find products by category " + categoryId, e);
        }
        return list;
    }

    /**
     * Batch-fetches all product-to-zone mappings in a single query,
     * then builds a Map(productId -> zones list). This eliminates N queries
     * when loading N products — only 1 extra query is needed regardless of list size.
     */
    private Map<Integer, List<Product.LocationConfig>> batchFindDefaultZones() {
        Map<Integer, List<Product.LocationConfig>> map = new HashMap<>();
        String sql = "SELECT product_id, warehouse_id, zone_id FROM product_default_zones";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int pid = rs.getInt("product_id");
                String locId = String.valueOf(rs.getInt("warehouse_id"));
                String zoneId = String.valueOf(rs.getInt("zone_id"));
                map.computeIfAbsent(pid, k -> new ArrayList<>())
                   .add(new Product.LocationConfig(locId, zoneId));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: batchFindDefaultZones failed", e);
        }
        return map;
    }

    // ── Mutating operations ────────────────────────────────────────

    public boolean insert(Product product) {
        String sql = "INSERT INTO products (sku_code, product_name, category_id, barcode, unit, "
                + "min_stock, max_stock, attributes_text, weight_kg, base_price, created_by) "
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
            ps.setString(8, product.getAttributesText());
            if (product.getWeightKg() != null) {
                ps.setDouble(9, product.getWeightKg());
            } else {
                ps.setNull(9, java.sql.Types.DECIMAL);
            }
            ps.setDouble(10, product.getBasePrice() != null ? product.getBasePrice() : 0.0);
            if (product.getCreatedBy() != null) {
                ps.setInt(11, product.getCreatedBy());
            } else {
                ps.setNull(11, java.sql.Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to insert product " + product.getSkuCode(), e);
            return false;
        }
    }

    public boolean update(Product product) {
        String sql = "UPDATE products SET "
                + "sku_code = ?, product_name = ?, category_id = ?, barcode = ?, unit = ?, "
                + "min_stock = ?, max_stock = ?, attributes_text = ?, weight_kg = ?, base_price = ?, "
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
            ps.setString(8, product.getAttributesText());
            if (product.getWeightKg() != null) {
                ps.setDouble(9, product.getWeightKg());
            } else {
                ps.setNull(9, java.sql.Types.DECIMAL);
            }
            ps.setDouble(10, product.getBasePrice() != null ? product.getBasePrice() : 0.0);
            ps.setInt(11, product.getProductId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to update product " + product.getProductId(), e);
            return false;
        }
    }

    /**
     * Convenience method for single-product zone lookup.
     * Prefer {@link #batchFindDefaultZones()} when loading multiple products.
     */
    public List<Product.LocationConfig> findDefaultZonesByProductId(int productId) {
        List<Product.LocationConfig> list = new ArrayList<>();
        String sql = "SELECT warehouse_id, zone_id FROM product_default_zones WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Product.LocationConfig(
                        String.valueOf(rs.getInt("warehouse_id")),
                        String.valueOf(rs.getInt("zone_id"))));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to find default zones for product " + productId, e);
        }
        return list;
    }

    public boolean delete(int productId) {
        String sql = "DELETE FROM products WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO: Failed to delete product " + productId, e);
            return false;
        }
    }

    // ── Row mapping helpers ─────────────────────────────────────────

    /**
     * Isolated zone update for a single (product, warehouse) pair. Used by warehouse staff
     * to set/clear the default storage zone of their own warehouse without touching other
     * warehouses' zone rows. Toggles active=1 for the chosen row; all other rows for the
     * same product keep their state.
     */
    public boolean updateZoneForWarehouse(int productId, int warehouseId, Integer zoneId) {
        if (zoneId == null) {
            String sql = "UPDATE product_warehouse_zone SET active = 0 "
                       + "WHERE product_id = ? AND warehouse_id = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, productId);
                ps.setInt(2, warehouseId);
                return ps.executeUpdate() >= 0;
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "ProductDAO.updateZoneForWarehouse (clear) failed", e);
                return false;
            }
        }
        String upsert = "INSERT INTO product_warehouse_zone (product_id, warehouse_id, zone_id, active) "
                      + "VALUES (?, ?, ?, 1) "
                      + "ON DUPLICATE KEY UPDATE zone_id = VALUES(zone_id), active = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(upsert)) {
            ps.setInt(1, productId);
            ps.setInt(2, warehouseId);
            ps.setInt(3, zoneId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "ProductDAO.updateZoneForWarehouse failed", e);
            return false;
        }
    }

    private int getProductId(ResultSet rs) throws SQLException {
        return rs.getInt("product_id");
    }

    /**
     * Maps a ResultSet row to a Product. Default zones are injected from the
     * pre-built map (passed in) instead of being fetched per-row — eliminating N+1.
     */
    private Product mapRow(ResultSet rs, List<Product.LocationConfig> zones) throws SQLException {
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
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            product.setCreatedAt(createdAt.toLocalDateTime());
        }
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            product.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        // Joined and transient fields — use safe getters to avoid SQLException on missing columns
        product.setCategoryName(getString(rs, "category_name"));
        product.setCreatorName(getString(rs, "creator_name"));
        product.setAttributesText(getString(rs, "attributes_text"));
        product.setShortDescription(getString(rs, "short_description"));

        double w = rs.getDouble("weight_kg");
        product.setWeightKg(rs.wasNull() ? null : w);

        double qoh = rs.getDouble("qty_on_hand");
        product.setQtyOnHand(qoh);

        double bp = rs.getDouble("base_price");
        product.setBasePrice(rs.wasNull() ? 0.0 : bp);

        int createdBy = rs.getInt("created_by");
        product.setCreatedBy(rs.wasNull() ? null : createdBy);

        // Inject pre-fetched zones — no extra DB query here
        product.setLocationConfigs(zones);

        return product;
    }

    private String getString(ResultSet rs, String col) {
        try {
            return rs.getString(col);
        } catch (SQLException e) {
            return null;
        }
    }

    /**
     * Finds a product by its SKU code.
     */
    public Product findBySkuCode(String skuCode) {
        String sql = SELECT_CORE + " WHERE p.sku_code = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, skuCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs, null);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "ProductDAO.findBySkuCode: failed for " + skuCode, e);
        }
        return null;
    }

    /**
     * Gets the next sequence number for a category and prefix.
     * Searches for existing SKUs with format: {PREFIX}-{SEQ:03d}
     * E.g. EYE-CON-001 or EYE-001
     *
     * @param categoryId The category ID.
     * @param prefix The SKU prefix (MÃ CHA-MÃ CON or MÃ CON).
     * @return Next sequence number (1-based).
     */
    public int getNextSequence(int categoryId, String prefix) throws SQLException {
        String sql = "SELECT sku_code FROM products WHERE category_id = ?";
        int maxSeq = 0;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String sku = rs.getString("sku_code");
                    if (sku != null && sku.startsWith(prefix + "-")) {
                        String seqPart = sku.substring(prefix.length() + 1);
                        if (seqPart.matches("^\\d{3}$")) {
                            try {
                                int seq = Integer.parseInt(seqPart);
                                if (seq > maxSeq) {
                                    maxSeq = seq;
                                }
                            } catch (NumberFormatException ignored) {}
                        }
                    }
                }
            }
        }
        return maxSeq + 1;
    }
}
