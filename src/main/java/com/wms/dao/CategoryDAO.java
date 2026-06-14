package com.wms.dao;

import com.wms.model.Category;
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
 * CategoryDAO — Data Access Object for managing product category records.
 * 
 * Business rules:
 * - categoryCode: ma dinh danh 3-4 ky tu, UPPERCASE, bat bien sau khi co san pham
 * - isImmutable: true = da co san pham, khong cho sua categoryCode
 * - active: true = dang hoat dong, false = ngung hoat dong (khong xoa)
 */
public class CategoryDAO {

    private static final Logger LOGGER = Logger.getLogger(CategoryDAO.class.getName());

    public CategoryDAO() {
    }

    /**
     * Retrieves all categories ordered by category_id.
     *
     * @return A list of all categories.
     */
    public List<Category> findAll() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM categories ORDER BY category_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToCategory(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryDAO: Failed to find all categories", e);
        }
        return list;
    }

    /**
     * Finds all ACTIVE categories (active = 1).
     * Used by warehouse staff when creating new products.
     */
    public List<Category> findActiveOnly() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM categories WHERE active = 1 ORDER BY category_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToCategory(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryDAO: Failed to find active categories", e);
        }
        return list;
    }

    /**
     * Finds a single category by its primary key.
     *
     * @param categoryId The category ID to look up.
     * @return The Category object, or null if not found.
     */
    public Category findById(int categoryId) {
        String sql = "SELECT * FROM categories WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCategory(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryDAO: Failed to find category by ID " + categoryId, e);
        }
        return null;
    }

    /**
     * Finds a category with its parent info (for SKU generation).
     * Returns a Category with parentCode populated.
     *
     * @param categoryId The category ID to look up.
     * @return The Category object with parent info, or null if not found.
     */
    public Category findByIdWithParent(int categoryId) {
        String sql = "SELECT c.*, p.category_code AS parent_code " +
                     "FROM categories c " +
                     "LEFT JOIN categories p ON c.parent_id = p.category_id " +
                     "WHERE c.category_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Category cat = mapResultSetToCategory(rs);
                    cat.setParentCode(rs.getString("parent_code"));
                    return cat;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryDAO: Failed to find category by ID with parent " + categoryId, e);
        }
        return null;
    }

    /**
     * Finds all direct child categories of a given parent.
     *
     * @param parentId The parent category ID.
     * @param activeOnly If true, only return active categories.
     * @return A list of child categories.
     */
    public List<Category> findByParentId(Integer parentId, boolean activeOnly) {
        List<Category> list = new ArrayList<>();
        String sql;
        PreparedStatement ps;
        try (Connection conn = DBConnection.getConnection()) {
            if (parentId == null) {
                sql = activeOnly 
                    ? "SELECT * FROM categories WHERE parent_id IS NULL AND active = 1 ORDER BY category_id ASC"
                    : "SELECT * FROM categories WHERE parent_id IS NULL ORDER BY category_id ASC";
                ps = conn.prepareStatement(sql);
            } else {
                sql = activeOnly 
                    ? "SELECT * FROM categories WHERE parent_id = ? AND active = 1 ORDER BY category_id ASC"
                    : "SELECT * FROM categories WHERE parent_id = ? ORDER BY category_id ASC";
                ps = conn.prepareStatement(sql);
                ps.setInt(1, parentId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToCategory(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryDAO: Failed to find categories by parent ID " + parentId, e);
        }
        return list;
    }

    /**
     * Finds all direct child categories of a given parent (all, including inactive).
     */
    public List<Category> findByParentId(Integer parentId) {
        return findByParentId(parentId, false);
    }

    /**
     * Checks if a category code already exists.
     *
     * @param categoryCode The code to check.
     * @param excludeId Category ID to exclude from check (for update).
     * @return true if exists, false otherwise.
     */
    public boolean existsByCategoryCode(String categoryCode, Integer excludeId) {
        String sql;
        try (Connection conn = DBConnection.getConnection()) {
            if (excludeId != null) {
                sql = "SELECT COUNT(*) FROM categories WHERE category_code = ? AND category_id != ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, categoryCode.toUpperCase());
                    ps.setInt(2, excludeId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) return rs.getInt(1) > 0;
                    }
                }
            } else {
                sql = "SELECT COUNT(*) FROM categories WHERE category_code = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, categoryCode.toUpperCase());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) return rs.getInt(1) > 0;
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryDAO: Failed to check category code existence", e);
        }
        return false;
    }

    /**
     * Inserts a new category into the database.
     *
     * @param category The category model instance to insert.
     * @return true if successful, false otherwise.
     */
    public boolean insert(Category category) {
        String sql = "INSERT INTO categories (category_code, category_name, parent_id, description, level_depth, is_immutable, active) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String code = category.getCategoryCode() != null ? category.getCategoryCode().toUpperCase() : null;
            ps.setString(1, code);
            ps.setString(2, category.getCategoryName());
            if (category.getParentId() != null) {
                ps.setInt(3, category.getParentId());
            } else {
                ps.setNull(3, java.sql.Types.INTEGER);
            }
            ps.setString(4, category.getDescription());

            int levelDepth = 0;
            if (category.getParentId() != null) {
                Category parent = findById(category.getParentId());
                if (parent != null) {
                    levelDepth = parent.getLevelDepth() + 1;
                }
            }
            ps.setInt(5, levelDepth);
            ps.setInt(6, category.isImmutable() ? 1 : 0);
            ps.setInt(7, category.isActive() ? 1 : 0);

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryDAO: Failed to insert category " + category.getCategoryName(), e);
            return false;
        }
    }

    /**
     * Updates an existing category.
     *
     * @param category The category with updated field values.
     * @param updateCode If true, update category_code (only if not immutable).
     * @return true if the update succeeded, false otherwise.
     */
    public boolean update(Category category, boolean updateCode) {
        String sql;
        PreparedStatement ps;
        try (Connection conn = DBConnection.getConnection()) {
            if (updateCode) {
                sql = "UPDATE categories SET category_code = ?, category_name = ?, parent_id = ?, description = ?, level_depth = ? WHERE category_id = ?";
                ps = conn.prepareStatement(sql);
                String code = category.getCategoryCode() != null ? category.getCategoryCode().toUpperCase() : null;
                ps.setString(1, code);
                ps.setString(2, category.getCategoryName());
            } else {
                sql = "UPDATE categories SET category_name = ?, parent_id = ?, description = ?, level_depth = ? WHERE category_id = ?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, category.getCategoryName());
            }
            
            if (category.getParentId() != null) {
                ps.setInt(updateCode ? 3 : 2, category.getParentId());
            } else {
                ps.setNull(updateCode ? 3 : 2, java.sql.Types.INTEGER);
            }
            ps.setString(updateCode ? 4 : 3, category.getDescription());

            int levelDepth = 0;
            if (category.getParentId() != null) {
                Category parent = findById(category.getParentId());
                if (parent != null) {
                    levelDepth = parent.getLevelDepth() + 1;
                }
            }
            ps.setInt(updateCode ? 5 : 4, levelDepth);
            ps.setInt(updateCode ? 6 : 5, category.getCategoryId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryDAO: Failed to update category " + category.getCategoryId(), e);
            return false;
        }
    }

    /**
     * Updates an existing category without changing category_code.
     */
    public boolean update(Category category) {
        return update(category, false);
    }

    /**
     * Sets the immutable flag for a category (lock category_code).
     *
     * @param categoryId The category ID.
     * @param immutable true to lock, false to unlock.
     * @return true if successful.
     */
    public boolean setImmutable(int categoryId, boolean immutable) {
        String sql = "UPDATE categories SET is_immutable = ? WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, immutable ? 1 : 0);
            ps.setInt(2, categoryId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryDAO: Failed to set immutable for category " + categoryId, e);
            return false;
        }
    }

    /**
     * Checks if a category has any products.
     *
     * @param categoryId The category ID to check.
     * @return true if category has products, false otherwise.
     */
    public boolean hasProducts(int categoryId) {
        String sql = "SELECT COUNT(*) FROM products WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryDAO: Failed to check products for category " + categoryId, e);
        }
        return false;
    }

    /**
     * Deactivates a category (soft delete).
     * Sets active = 0, category will be hidden from warehouse staff.
     *
     * @param categoryId The category ID to deactivate.
     * @return true if successful, false otherwise.
     */
    public boolean deactivate(int categoryId) {
        String sql = "UPDATE categories SET active = 0 WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryDAO: Failed to deactivate category " + categoryId, e);
            return false;
        }
    }

    /**
     * Reactivates a previously deactivated category.
     * Sets active = 1.
     *
     * @param categoryId The category ID to reactivate.
     * @return true if successful, false otherwise.
     */
    public boolean activate(int categoryId) {
        String sql = "UPDATE categories SET active = 1 WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryDAO: Failed to activate category " + categoryId, e);
            return false;
        }
    }

    /**
     * Deactivates a category and all its descendants in the tree (cascade).
     * Uses a recursive BFS traversal in Java so the operation works on any DB
     * that supports the standard {@code categories} table layout.
     *
     * @param rootCategoryId The root category ID to deactivate (along with all descendants).
     * @return Number of categories that were deactivated.
     */
    public int deactivateWithDescendants(int rootCategoryId) {
        List<Integer> toDeactivate = new ArrayList<>();
        java.util.Deque<Integer> queue = new java.util.ArrayDeque<>();
        queue.add(rootCategoryId);
        while (!queue.isEmpty()) {
            int current = queue.poll();
            toDeactivate.add(current);
            List<Category> children = findByParentId(current);
            for (Category child : children) {
                queue.add(child.getCategoryId());
            }
        }

        if (toDeactivate.isEmpty()) {
            return 0;
        }

        StringBuilder sql = new StringBuilder("UPDATE categories SET active = 0 WHERE category_id IN (");
        for (int i = 0; i < toDeactivate.size(); i++) {
            if (i > 0) sql.append(",");
            sql.append("?");
        }
        sql.append(")");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < toDeactivate.size(); i++) {
                ps.setInt(i + 1, toDeactivate.get(i));
            }
            return ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING,
                "CategoryDAO: Failed to cascade-deactivate category " + rootCategoryId, e);
            return 0;
        }
    }

    /**
     * Deletes a category by its primary key.
     *
     * @param categoryId The category ID to delete.
     * @return true if a row was deleted, false otherwise.
     */
    public boolean delete(int categoryId) {
        String sql = "DELETE FROM categories WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryDAO: Failed to delete category " + categoryId, e);
            return false;
        }
    }

    /**
     * Maps a ResultSet row to a Category object.
     */
    private Category mapResultSetToCategory(ResultSet rs) throws SQLException {
        Category category = new Category();
        category.setCategoryId(rs.getInt("category_id"));
        category.setCategoryCode(rs.getString("category_code"));
        category.setCategoryName(rs.getString("category_name"));
        int parentId = rs.getInt("parent_id");
        category.setParentId(rs.wasNull() ? null : parentId);
        category.setDescription(rs.getString("description"));
        category.setLevelDepth(rs.getInt("level_depth"));
        category.setImmutable(rs.getInt("is_immutable") == 1);
        int active = rs.getInt("active");
        category.setActive(active == 1);
        return category;
    }
}
