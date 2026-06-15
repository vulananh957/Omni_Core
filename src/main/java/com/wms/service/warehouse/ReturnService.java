package com.wms.service.warehouse;

import com.wms.dao.ProductDAO;
import com.wms.dao.ReturnDAO;
import com.wms.model.Product;
import com.wms.model.ReturnItem;
import com.wms.model.ReturnOrder;

import java.util.List;

public class ReturnService {

    private final ReturnDAO returnDAO = new ReturnDAO();
    private final ProductDAO productDAO = new ProductDAO();

    public List<ReturnOrder> findAll() {
        return returnDAO.findAll();
    }

    public List<Product> findApprovedProducts() {
        return productDAO.findAll();
    }

    public ValidationResult validateForCreate(String soRef, String customer, String phone, List<ReturnItem> items) {
        if (soRef == null || soRef.trim().isEmpty()) {
            return ValidationResult.failure("Thiếu thông tin bắt đầu tạo phiếu hàng hoàn.");
        }
        if (customer == null || customer.trim().isEmpty()) {
            return ValidationResult.failure("Thiếu thông tin khách hàng.");
        }
        if (phone == null || phone.trim().isEmpty()) {
            return ValidationResult.failure("Thiếu số điện thoại khách hàng.");
        }
        if (items == null || items.isEmpty()) {
            return ValidationResult.failure("Danh sách sản phẩm hoàn trả trống.");
        }
        return ValidationResult.success();
    }

    public boolean createReturn(String soRef, String customer, String phone,
                                List<ReturnItem> items, int warehouseId) {
        ReturnOrder order = new ReturnOrder();
        order.setOrderCode(soRef.trim());
        order.setCustomerName(customer.trim());
        order.setCustomerPhone(phone.trim());
        order.setReason("Yêu cầu trả hàng hoàn tiền");
        order.setWarehouseId(warehouseId);
        order.setItems(items);
        return returnDAO.insert(order);
    }

    public boolean saveQC(int returnId, List<ReturnItem> items, int userId) {
        return returnDAO.saveQC(returnId, items, userId);
    }

    public boolean applyRestock(int returnId, int userId) {
        return returnDAO.applyRestock(returnId, userId);
    }

    /**
     * Checks whether all items in a return have been inspected (no pending items).
     * Used to gate the apply/restock action.
     */
    public boolean isQCComplete(int returnId) {
        return returnDAO.isQCComplete(returnId);
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
