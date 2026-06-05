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
     * Finds all direct child categories of a given parent.
     *
     * @param parentId The parent category ID.
     * @return A list of child categories.
     */
    public List<Category> findByParentId(Integer parentId) {
        List<Category> list = new ArrayList<>();
        String sql;
        PreparedStatement ps;
        try (Connection conn = DBConnection.getConnection()) {
            if (parentId == null) {
                sql = "SELECT * FROM categories WHERE parent_id IS NULL ORDER BY category_id ASC";
                ps = conn.prepareStatement(sql);
            } else {
                sql = "SELECT * FROM categories WHERE parent_id = ? ORDER BY category_id ASC";
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
     * Inserts a new category into the database.
     *
     * @param category The category model instance to insert.
     * @return true if successful, false otherwise.
     */
    public boolean insert(Category category) {
        String sql = "INSERT INTO categories (category_name, parent_id, description, level_depth) "
                + "VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category.getCategoryName());
            if (category.getParentId() != null) {
                ps.setInt(2, category.getParentId());
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setString(3, category.getDescription());

            int levelDepth = 0;
            if (category.getParentId() != null) {
                Category parent = findById(category.getParentId());
                if (parent != null) {
                    levelDepth = 1;
                }
            }
            ps.setInt(4, levelDepth);

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
     * @return true if the update succeeded, false otherwise.
     */
    public boolean update(Category category) {
        String sql = "UPDATE categories SET "
                + "category_name = ?, parent_id = ?, description = ?, level_depth = ? "
                + "WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category.getCategoryName());
            if (category.getParentId() != null) {
                ps.setInt(2, category.getParentId());
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setString(3, category.getDescription());

            int levelDepth = 0;
            if (category.getParentId() != null) {
                levelDepth = 1;
            }
            ps.setInt(4, levelDepth);
            ps.setInt(5, category.getCategoryId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "CategoryDAO: Failed to update category " + category.getCategoryId(), e);
            return false;
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
        category.setCategoryName(rs.getString("category_name"));
        int parentId = rs.getInt("parent_id");
        category.setParentId(rs.wasNull() ? null : parentId);
        category.setDescription(rs.getString("description"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            category.setCreatedAt(createdAt.toLocalDateTime());
        }
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            category.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        return category;
    }
}
