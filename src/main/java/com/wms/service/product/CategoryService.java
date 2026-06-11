package com.wms.service.product;

import com.wms.dao.CategoryDAO;
import com.wms.model.Category;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.SQLException;
import java.util.List;
import java.util.regex.Pattern;

public class CategoryService {

    private static final Logger log = LoggerFactory.getLogger(CategoryService.class);
    private static final Pattern CATEGORY_CODE_PATTERN = Pattern.compile("^[A-Z0-9]{3,4}$");

    private final CategoryDAO categoryDAO = new CategoryDAO();

    public List<Category> findAll() throws SQLException {
        return categoryDAO.findAll();
    }

    public List<Category> findActiveOnly() throws SQLException {
        return categoryDAO.findActiveOnly();
    }

    public Category findById(int categoryId) throws SQLException {
        return categoryDAO.findById(categoryId);
    }

    /**
     * Creates a new category with required category code.
     *
     * @param name Category display name.
     * @param categoryCode Category code (3-4 uppercase chars).
     * @param parentId Parent category ID (null for root).
     * @return true if successful.
     */
    public boolean createCategory(String name, String categoryCode, Integer parentId) throws SQLException {
        // Validate code format
        if (categoryCode == null || categoryCode.trim().isEmpty()) {
            throw new IllegalArgumentException("Ma dinh danh khong duoc trong.");
        }
        categoryCode = categoryCode.trim().toUpperCase();
        if (!CATEGORY_CODE_PATTERN.matcher(categoryCode).matches()) {
            throw new IllegalArgumentException("Ma dinh danh phai la 3-4 ky tu, chi gom chu hoa va so.");
        }
        if (categoryDAO.existsByCategoryCode(categoryCode, null)) {
            throw new IllegalArgumentException("Ma dinh danh da ton tai.");
        }

        Category category = new Category();
        category.setCategoryName(name.trim());
        category.setCategoryCode(categoryCode);
        category.setParentId(parentId);
        category.setActive(true);
        category.setImmutable(false);

        return categoryDAO.insert(category);
    }

    /**
     * Updates a category. Only categoryCode can be updated if not immutable.
     *
     * @param category The category with updated values.
     * @param newCategoryCode New category code (null to keep existing).
     * @return true if successful.
     */
    public boolean updateCategory(Category category, String newCategoryCode) throws SQLException {
        Category existing = categoryDAO.findById(category.getCategoryId());
        if (existing == null) {
            return false;
        }

        // Check if code is immutable
        boolean codeIsLocked = existing.isImmutable() || categoryDAO.hasProducts(category.getCategoryId());

        if (codeIsLocked && newCategoryCode != null && !newCategoryCode.isEmpty()) {
            throw new IllegalArgumentException("Ma dinh danh da bi khoa, khong the sua.");
        }

        // Validate new code if provided
        if (newCategoryCode != null && !newCategoryCode.trim().isEmpty()) {
            newCategoryCode = newCategoryCode.trim().toUpperCase();
            if (!CATEGORY_CODE_PATTERN.matcher(newCategoryCode).matches()) {
                throw new IllegalArgumentException("Ma dinh danh phai la 3-4 ky tu, chi gom chu hoa va so.");
            }
            if (categoryDAO.existsByCategoryCode(newCategoryCode, category.getCategoryId())) {
                throw new IllegalArgumentException("Ma dinh danh da ton tai.");
            }
            category.setCategoryCode(newCategoryCode);
            boolean updated = categoryDAO.update(category, true);
            // Lock code after first update if not already locked
            if (updated && !categoryDAO.hasProducts(category.getCategoryId())) {
                categoryDAO.setImmutable(category.getCategoryId(), true);
            }
            return updated;
        } else {
            return categoryDAO.update(category, false);
        }
    }

    public ValidationResult validateCategoryData(String name, Integer categoryId, Integer parentId) {
        if (name == null || name.trim().isEmpty()) {
            return ValidationResult.failure("Ten danh muc khong duoc bo trong.");
        }
        if (parentId != null && parentId.equals(categoryId)) {
            return ValidationResult.failure("Danh muc khong the la danh muc cha cua chinh no.");
        }
        return ValidationResult.success();
    }

    /**
     * Validates category code format.
     *
     * @param code The code to validate.
     * @return ValidationResult with success/failure.
     */
    public ValidationResult validateCategoryCode(String code) {
        if (code == null || code.trim().isEmpty()) {
            return ValidationResult.failure("Ma dinh danh khong duoc bo trong.");
        }
        String normalized = code.trim().toUpperCase();
        if (!CATEGORY_CODE_PATTERN.matcher(normalized).matches()) {
            return ValidationResult.failure("Ma dinh danh phai la 3-4 ky tu, chi gom chu hoa va so (VD: EYE, SUN).");
        }
        return ValidationResult.success();
    }

    /**
     * Checks if a category can be hard-deleted (no products).
     *
     * @param categoryId The category ID to check.
     * @return true if can hard delete, false if only deactivate available.
     */
    public boolean canHardDelete(int categoryId) throws SQLException {
        return !categoryDAO.hasProducts(categoryId);
    }

    /**
     * Deletes or deactivates a category based on product presence.
     *
     * @param categoryId The category ID.
     * @return Result indicating success and action taken.
     */
    public DeleteResult deleteCategory(int categoryId) throws SQLException {
        if (categoryDAO.hasProducts(categoryId)) {
            // Soft delete - just deactivate
            boolean deactivated = categoryDAO.deactivate(categoryId);
            return new DeleteResult(deactivated, true, "Danh muc da co san pham. Da ngung hoat dong.");
        } else {
            // Hard delete
            boolean deleted = categoryDAO.delete(categoryId);
            return new DeleteResult(deleted, false, deleted ? "Xoa danh muc thanh cong." : "Xoa danh muc that bai.");
        }
    }

    /**
     * Deactivates a category (soft delete).
     *
     * @param categoryId The category ID.
     * @return true if successful.
     */
    public boolean deactivateCategory(int categoryId) throws SQLException {
        return categoryDAO.deactivate(categoryId);
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

    public static class DeleteResult {
        private final boolean success;
        private final boolean wasSoftDelete;
        private final String message;

        public DeleteResult(boolean success, boolean wasSoftDelete, String message) {
            this.success = success;
            this.wasSoftDelete = wasSoftDelete;
            this.message = message;
        }

        public boolean isSuccess() { return success; }
        public boolean isWasSoftDelete() { return wasSoftDelete; }
        public String getMessage() { return message; }
    }
}
