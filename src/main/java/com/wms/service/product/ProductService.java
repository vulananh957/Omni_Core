package com.wms.service.product;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.dao.CategoryDAO;
import com.wms.dao.ProductDAO;
import com.wms.model.Category;
import com.wms.model.Product;

import java.util.List;

public class ProductService {

    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public List<Product> findAll() {
        return productDAO.findAll();
    }

    public String toJson(List<Product> products) {
        try {
            return objectMapper.writeValueAsString(products);
        } catch (JsonProcessingException e) {
            return "[]";
        }
    }
    public List<Product> findPendingApproval() {
        return productDAO.findPendingApproval();
    }

    public List<Category> findAllCategories() {
        return categoryDAO.findAll();
    }

    public Product findById(int productId) {
        return productDAO.findById(productId);
    }

    public boolean createProduct(Product product, Integer createdByUserId) {
        if (product.getUnit() == null || product.getUnit().trim().isEmpty()) {
            product.setUnit("Cái");
        }
        product.setStatus(Product.STATUS_PENDING);
        product.setCreatedBy(createdByUserId);
        return productDAO.insert(product);
    }

    public UpdateResult updateProduct(int productId, Product updates) {
        Product existing = productDAO.findById(productId);
        if (existing == null) {
            return UpdateResult.failure("Sản phẩm không tồn tại.");
        }
        if (!Product.STATUS_PENDING.equals(existing.getStatus())) {
            return UpdateResult.failure("Chỉ sản phẩm ở trạng thái PENDING mới có thể chỉnh sửa.");
        }

        if (updates.getProductName() != null && !updates.getProductName().trim().isEmpty()) {
            existing.setProductName(updates.getProductName().trim());
        }
        if (updates.getCategoryId() != null) {
            existing.setCategoryId(updates.getCategoryId());
        }
        if (updates.getAttributesText() != null && !updates.getAttributesText().trim().isEmpty()) {
            existing.setAttributesText(updates.getAttributesText().trim());
        }
        if (updates.getWeightKg() != null) {
            existing.setWeightKg(updates.getWeightKg());
        }
        if (updates.getMinStock() != null) {
            existing.setMinStock(updates.getMinStock());
        }
        if (updates.getMaxStock() != null) {
            existing.setMaxStock(updates.getMaxStock());
        }

        boolean success = productDAO.update(existing);
        if (!success) {
            return UpdateResult.failure("Không thể cập nhật sản phẩm.");
        }
        return UpdateResult.success();
    }

    public DeleteResult deleteProduct(int productId) {
        Product existing = productDAO.findById(productId);
        if (existing == null) {
            return DeleteResult.failure("Sản phẩm không tồn tại.");
        }
        if (!Product.STATUS_PENDING.equals(existing.getStatus())) {
            return DeleteResult.failure("Chỉ sản phẩm ở trạng thái PENDING mới có thể xóa.");
        }
        boolean success = productDAO.delete(productId);
        if (!success) {
            return DeleteResult.failure("Không thể xóa sản phẩm.");
        }
        return DeleteResult.success();
    }

    public Integer resolveCategoryId(String categoryName) {
        if (categoryName == null || categoryName.trim().isEmpty()) {
            return null;
        }
        List<Category> all = categoryDAO.findAll();
        for (Category c : all) {
            if (c.getCategoryName().equalsIgnoreCase(categoryName.trim())) {
                return c.getCategoryId();
            }
        }
        return null;
    }

    public static class UpdateResult {
        private final boolean success;
        private final String message;

        private UpdateResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public static UpdateResult success() {
            return new UpdateResult(true, null);
        }

        public static UpdateResult failure(String message) {
            return new UpdateResult(false, message);
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }

    public static class DeleteResult {
        private final boolean success;
        private final String message;

        private DeleteResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public static DeleteResult success() {
            return new DeleteResult(true, null);
        }

        public static DeleteResult failure(String message) {
            return new DeleteResult(false, message);
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }
}
