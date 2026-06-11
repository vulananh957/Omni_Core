package com.wms.service.product;

import com.wms.dao.CategoryDAO;
import com.wms.model.Category;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.SQLException;
import java.util.List;

public class CategoryService {

    private static final Logger log = LoggerFactory.getLogger(CategoryService.class);

    private final CategoryDAO categoryDAO = new CategoryDAO();

    public List<Category> findAll() throws SQLException {
        return categoryDAO.findAll();
    }

    public Category findById(int categoryId) throws SQLException {
        return categoryDAO.findById(categoryId);
    }

    public boolean createCategory(String name, Integer parentId) throws SQLException {
        Category category = new Category();
        category.setCategoryName(name.trim());
        category.setParentId(parentId);
        return categoryDAO.insert(category);
    }

    public boolean updateCategory(Category category) throws SQLException {
        return categoryDAO.update(category);
    }

    public ValidationResult validateCategoryData(String name, Integer categoryId, Integer parentId) {
        if (name == null || name.trim().isEmpty()) {
            return ValidationResult.failure("Tên danh mục không được bỏ trống.");
        }
        if (parentId != null && parentId.equals(categoryId)) {
            return ValidationResult.failure("Danh mục không thể là danh mục cha của chính nó.");
        }
        return ValidationResult.success();
    }

    public boolean deleteCategory(int categoryId) throws SQLException {
        return categoryDAO.delete(categoryId);
    }

    public static class ValidationResult {
        private final boolean success;
        private final String message;

        private ValidationResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public static ValidationResult success() {
            return new ValidationResult(true, null);
        }

        public static ValidationResult failure(String message) {
            return new ValidationResult(false, message);
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }
}
