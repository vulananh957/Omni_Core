package com.wms.service.product;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.dao.CategoryDAO;
import com.wms.dao.ProductDAO;
import com.wms.model.Category;
import com.wms.model.Product;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

public class ProductService {

    private static final Logger log = LoggerFactory.getLogger(ProductService.class);

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

    public List<Category> findAllCategories() {
        return categoryDAO.findAll();
    }

    public Product findById(int productId) {
        return productDAO.findById(productId);
    }

    public boolean createProduct(Product product, Integer createdByUserId) {
        return createProductWithZones(product, createdByUserId, List.of());
    }

    public boolean createProductWithZones(Product product, Integer createdByUserId, List<Product.LocationConfig> zones) {
        if (product.getUnit() == null || product.getUnit().trim().isEmpty()) {
            product.setUnit("Cái");
        }
        product.setCreatedBy(createdByUserId);
        boolean success = productDAO.insertWithZones(product, createdByUserId, zones);
        if (success) {
            log.info("Product created: name={} sku={} userId={} zones={}",
                    product.getProductName(), product.getSkuCode(), createdByUserId, zones.size());
        } else {
            log.error("Product create failed: name={} sku={}", product.getProductName(), product.getSkuCode());
        }
        return success;
    }

    public UpdateResult updateProduct(int productId, Product updates) {
        return updateProduct(productId, updates, null);
    }

    public UpdateResult updateProduct(int productId, Product updates, List<Product.LocationConfig> zones) {
        Product existing = productDAO.findById(productId);
        if (existing == null) {
            log.warn("Update product failed: not found productId={}", productId);
            return UpdateResult.failure("Sản phẩm không tồn tại.");
        }

        if (updates.getProductName() != null && !updates.getProductName().trim().isEmpty()) {
            existing.setProductName(updates.getProductName().trim());
        }
        if (updates.getCategoryId() != null) {
            existing.setCategoryId(updates.getCategoryId());
        }
        if (updates.getAttributesText() != null) {
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
        if (updates.getBarcode() != null) {
            existing.setBarcode(updates.getBarcode().trim());
        }
        if (updates.getUnit() != null) {
            existing.setUnit(updates.getUnit().trim());
        }

        boolean success;
        if (zones == null) {
            // If zones list is null, retain the existing location configs
            success = productDAO.update(existing);
        } else {
            success = productDAO.updateWithZones(existing, zones);
        }

        if (!success) {
            log.error("Product update DAO failed: productId={}", productId);
            return UpdateResult.failure("Không thể cập nhật sản phẩm.");
        }
        log.info("Product updated: productId={}", productId);
        return UpdateResult.success();
    }

    public DeleteResult deleteProduct(int productId) {
        Product existing = productDAO.findById(productId);
        if (existing == null) {
            log.warn("Delete product failed: not found productId={}", productId);
            return DeleteResult.failure("Sản phẩm không tồn tại.");
        }
        boolean success = productDAO.delete(productId);
        if (!success) {
            log.error("Product delete DAO failed: productId={}", productId);
            return DeleteResult.failure("Không thể xóa sản phẩm.");
        }
        log.info("Product deleted: productId={}", productId);
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
