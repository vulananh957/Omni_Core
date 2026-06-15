package com.wms.service.warehouse;

import com.wms.dao.InboundDAO;
import com.wms.dao.InventoryDAO;
import com.wms.model.InboundOrder;
import com.wms.model.ReceiptNote;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class InboundService {

    private static final Logger log = LoggerFactory.getLogger(InboundService.class);

    private final InboundDAO inboundDAO = new InboundDAO();
    private final InventoryDAO inventoryDAO = new InventoryDAO();

    public List<InboundOrder> findAll() {
        return inboundDAO.findAll();
    }

    public List<InboundOrder> findByStatus(String status) {
        return inboundDAO.findByStatus(status);
    }

    public InboundOrder findById(int inboundId) {
        return inboundDAO.findById(inboundId);
    }

    public ValidationResult validateForCreate(String supplierName, Integer warehouseId) {
        if (supplierName == null || supplierName.trim().isEmpty()) {
            return ValidationResult.failure("Vui lòng nhập tên nhà cung cấp.");
        }
        if (warehouseId == null || warehouseId <= 0) {
            return ValidationResult.failure("Vui lòng chọn kho hàng.");
        }
        return ValidationResult.success();
    }

    public int createInbound(String supplierName, int warehouseId, LocalDate expectedDate,
                             String notes, int createdBy) {
        InboundOrder order = new InboundOrder();
        order.setSupplierName(supplierName.trim());
        order.setWarehouseId(warehouseId);
        order.setStatus(InboundOrder.STATUS_PENDING);
        order.setCreatedBy(createdBy);
        order.setNotes(notes != null && !notes.trim().isEmpty() ? notes.trim() : null);
        if (expectedDate != null) {
            order.setExpectedDate(expectedDate);
        }
        return inboundDAO.insert(order);
    }

    public TransitionResult confirmInbound(int inboundId) {
        InboundOrder existing = inboundDAO.findById(inboundId);
        if (existing == null) {
            log.warn("Confirm inbound failed: order not found id={}", inboundId);
            return TransitionResult.failure("Phiếu nhập không tồn tại.");
        }
        if (!InboundOrder.STATUS_PENDING.equals(existing.getStatus())) {
            log.warn("Confirm inbound failed: wrong status id={} status={}", inboundId, existing.getStatus());
            return TransitionResult.failure("Phiếu nhập không ở trạng thái chờ xác nhận.");
        }
        boolean updated = inboundDAO.updateStatus(inboundId, InboundOrder.STATUS_IN_PROGRESS);
        if (!updated) {
            log.error("Confirm inbound failed: DAO update returned false id={}", inboundId);
            return TransitionResult.failure("Không thể xác nhận phiếu nhập.");
        }
        log.info("Inbound confirmed: id={} code={}", inboundId, existing.getInboundCode());
        return TransitionResult.success("Xác nhận phiếu " + existing.getInboundCode() + " thành công!");
    }

    public ReceiveResult receiveGoods(int inboundId, List<ReceiptItem> receiptItems, int userId) {
        InboundOrder existing = inboundDAO.findById(inboundId);
        if (existing == null) {
            log.warn("Receive goods failed: order not found id={}", inboundId);
            return ReceiveResult.failure("Phiếu nhập không tồn tại.");
        }
        if (!InboundOrder.STATUS_IN_PROGRESS.equals(existing.getStatus())) {
            log.warn("Receive goods failed: wrong status id={} status={}", inboundId, existing.getStatus());
            return ReceiveResult.failure("Chỉ phiếu đã xác nhận mới có thể nhập kho.");
        }

        LocalDateTime now = LocalDateTime.now();
        int successCount = 0;
        int failCount = 0;

        if (receiptItems != null) {
            for (ReceiptItem item : receiptItems) {
                try {
                    if (item.getReceivedQty().compareTo(BigDecimal.ZERO) <= 0) continue;

                    ReceiptNote receipt = new ReceiptNote();
                    receipt.setInboundId(inboundId);
                    receipt.setProductId(item.getProductId());
                    receipt.setExpectedQty(BigDecimal.ZERO);
                    receipt.setReceivedQty(item.getReceivedQty());
                    receipt.setAcceptedQty(item.getReceivedQty());
                    receipt.setRejectedQty(BigDecimal.ZERO);
                    receipt.setReceivedAt(now);

                    inboundDAO.insertReceipt(receipt);
                    inventoryDAO.addInventory(item.getProductId(), existing.getWarehouseId(), item.getReceivedQty(), userId);
                    successCount++;
                } catch (Exception e) {
                    failCount++;
                    log.error("Receive goods item error: inboundId={} productId={} qty={} error={}",
                            inboundId, item.getProductId(), item.getReceivedQty(), e.getMessage());
                }
            }
        }

        inboundDAO.updateStatus(inboundId, InboundOrder.STATUS_RECEIVED);
        log.info("Goods received: inboundId={} warehouseId={} userId={} success={} failed={}",
                inboundId, existing.getWarehouseId(), userId, successCount, failCount);

        String msg = (failCount == 0)
            ? "Nhập kho phiếu " + existing.getInboundCode() + " thành công! Tồn kho đã được cập nhật."
            : "Nhập kho phiếu " + existing.getInboundCode() + " hoàn tất (một số dòng có lỗi).";
        return ReceiveResult.success(msg);
    }

    public static class ReceiptItem {
        private int productId;
        private BigDecimal receivedQty;

        public int getProductId() { return productId; }
        public void setProductId(int productId) { this.productId = productId; }
        public BigDecimal getReceivedQty() { return receivedQty; }
        public void setReceivedQty(BigDecimal receivedQty) { this.receivedQty = receivedQty; }
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

    public static class TransitionResult {
        private final boolean success;
        private final String message;

        private TransitionResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public static TransitionResult success(String message) {
            return new TransitionResult(true, message);
        }

        public static TransitionResult failure(String message) {
            return new TransitionResult(false, message);
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }

    public static class ReceiveResult {
        private final boolean success;
        private final String message;

        private ReceiveResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public static ReceiveResult success(String message) {
            return new ReceiveResult(true, message);
        }

        public static ReceiveResult failure(String message) {
            return new ReceiveResult(false, message);
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }
}
