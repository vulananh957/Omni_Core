package com.wms.service.warehouse;

import com.wms.dao.InboundDAO;
import com.wms.dao.InventoryDAO;
import com.wms.dao.ProductDAO;
import com.wms.model.InboundOrder;
import com.wms.model.ReceiptNote;
import com.wms.service.marketplace.MarketplaceSyncService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;

public class InboundService {

    private static final Logger log = LoggerFactory.getLogger(InboundService.class);

    private final InboundDAO inboundDAO = new InboundDAO();
    private final InventoryDAO inventoryDAO = new InventoryDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final MarketplaceSyncService marketplaceSyncService = new MarketplaceSyncService();

    public List<InboundOrder> findAll() {
        return inboundDAO.findAll();
    }

    public List<InboundOrder> findByWarehouse(int warehouseId) {
        return inboundDAO.findByWarehouse(warehouseId);
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
                    BigDecimal received = item.getReceivedQty() != null ? item.getReceivedQty() : BigDecimal.ZERO;
                    BigDecimal accepted = item.getAcceptedQty() != null ? item.getAcceptedQty() : BigDecimal.ZERO;
                    BigDecimal rejected = received.subtract(accepted); // auto-calculate

                    if (received.compareTo(BigDecimal.ZERO) <= 0 && accepted.compareTo(BigDecimal.ZERO) <= 0) {
                        continue;
                    }

                    // Update all 4 fields in inbound_items (qty + unit_cost for MAC)
                    inboundDAO.updateReceivedQtys(inboundId, item.getProductId(), received, accepted, rejected,
                            item.getUnitCost() != null ? item.getUnitCost() : BigDecimal.ZERO);
                    // Only accepted qty goes into inventory
                    if (accepted.compareTo(BigDecimal.ZERO) > 0) {
                        // MAC: Moving Average Cost — read state BEFORE inventory changes,
                        // then recalculate after addInventory to include the new lot.
                        double currentOnHand = 0.0;
                        BigDecimal currentMac = BigDecimal.ZERO;
                        var prod = productDAO.findById(item.getProductId());
                        if (prod != null) {
                            currentOnHand = prod.getQtyOnHand() != null ? prod.getQtyOnHand() : 0.0;
                            currentMac = productDAO.findMacPrice(item.getProductId());
                        }
                        inventoryDAO.addInventory(item.getProductId(), existing.getWarehouseId(), accepted, userId);
                        // unitCost may be null if not provided by caller (e.g. legacy paths).
                        BigDecimal unitCost = item.getUnitCost() != null
                                ? item.getUnitCost()
                                : BigDecimal.ZERO;
                        productDAO.updateMacPrice(
                                item.getProductId(),
                                BigDecimal.valueOf(currentOnHand),
                                currentMac,
                                accepted,
                                unitCost);
                    }
                    if (rejected.compareTo(BigDecimal.ZERO) > 0) {
                        inventoryDAO.addDefectiveInventory(
                                item.getProductId(),
                                existing.getWarehouseId(),
                                rejected,
                                userId,
                                "Hàng lỗi từ phiếu nhập " + existing.getInboundCode());
                    }
                    successCount++;
                } catch (Exception e) {
                    failCount++;
                    log.error("Receive goods item error: inboundId={} productId={} error={}",
                            inboundId, item.getProductId(), e.getMessage());
                }
            }
        }

        inboundDAO.updateStatus(inboundId, InboundOrder.STATUS_RECEIVED);
        log.info("Goods received: inboundId={} warehouseId={} userId={} success={} failed={}",
                inboundId, existing.getWarehouseId(), userId, successCount, failCount);

        // Trigger real-time marketplace stock sync (async — does not block the HTTP response)
        // Push_Qty = SUM(qty_available all warehouses) - bufferStock, batched 20 SKU/call
        if (successCount > 0) {
            List<Integer> receivedProductIds = receiptItems.stream()
                    .filter(item -> item.getAcceptedQty() != null
                            && item.getAcceptedQty().compareTo(BigDecimal.ZERO) > 0)
                    .map(item -> item.getProductId())
                    .distinct()
                    .toList();
            if (!receivedProductIds.isEmpty()) {
                String finalInboundCode = existing.getInboundCode();
                CompletableFuture.runAsync(() -> {
                    try {
                        marketplaceSyncService.triggerStockSyncAfterInbound(receivedProductIds, finalInboundCode);
                    } catch (Exception e) {
                        log.error("Marketplace stock sync failed after inbound receive: inboundCode={}",
                                finalInboundCode, e);
                    }
                });
            }
        }

        String msg = (failCount == 0)
            ? "Nhập kho phiếu " + existing.getInboundCode() + " thành công! Tồn kho đã được cập nhật."
            : "Nhập kho phiếu " + existing.getInboundCode() + " hoàn tất (một số dòng có lỗi).";
        return ReceiveResult.success(msg);
    }

    public static class ReceiptItem {
        private int productId;
        private BigDecimal receivedQty;
        private BigDecimal acceptedQty;
        private BigDecimal rejectedQty;
        private BigDecimal unitCost;  // used for MAC recalculation

        public int getProductId() { return productId; }
        public void setProductId(int productId) { this.productId = productId; }
        public BigDecimal getReceivedQty() { return receivedQty; }
        public void setReceivedQty(BigDecimal receivedQty) { this.receivedQty = receivedQty; }
        public BigDecimal getAcceptedQty() { return acceptedQty; }
        public void setAcceptedQty(BigDecimal acceptedQty) { this.acceptedQty = acceptedQty; }
        public BigDecimal getRejectedQty() { return rejectedQty; }
        public void setRejectedQty(BigDecimal rejectedQty) { this.rejectedQty = rejectedQty; }
        public BigDecimal getUnitCost() { return unitCost; }
        public void setUnitCost(BigDecimal unitCost) { this.unitCost = unitCost; }
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
