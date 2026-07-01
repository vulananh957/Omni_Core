package com.wms.service.warehouse;

import com.wms.dao.InboundDAO;
import com.wms.dao.InventoryDAO;
import com.wms.dao.ProductDAO;
import com.wms.model.InboundOrder;
import com.wms.service.marketplace.MarketplaceSyncService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.time.LocalDate;
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
        // Sau khi tối giản quy trình: phiếu mới vào thẳng trạng thái "Đang nhập kho"
        // (WH staff tạo phiếu → nhập hàng → hoàn thành, không còn bước duyệt Manager/QC)
        order.setStatus(InboundOrder.STATUS_IN_PROGRESS);
        order.setCreatedBy(createdBy);
        order.setNotes(notes != null && !notes.trim().isEmpty() ? notes.trim() : null);
        if (expectedDate != null) {
            order.setExpectedDate(expectedDate);
        }
        return inboundDAO.insert(order);
    }

    public ReceiveResult receiveGoods(int inboundId, List<ReceiptItem> receiptItems, int userId) {
        InboundOrder existing = inboundDAO.findById(inboundId);
        if (existing == null) {
            log.warn("Receive goods failed: order not found id={}", inboundId);
            return ReceiveResult.failure("Phiếu nhập không tồn tại.");
        }
        if (!InboundOrder.STATUS_IN_PROGRESS.equals(existing.getStatus())) {
            log.warn("Receive goods failed: wrong status id={} status={}", inboundId, existing.getStatus());
            return ReceiveResult.failure("Chỉ phiếu đang nhập kho mới có thể nhận hàng.");
        }

        int successCount = 0;
        int failCount = 0;

        if (receiptItems != null) {
            for (ReceiptItem item : receiptItems) {
                try {
                    BigDecimal received = item.getReceivedQty() != null ? item.getReceivedQty() : BigDecimal.ZERO;
                    if (received.compareTo(BigDecimal.ZERO) <= 0) {
                        continue;
                    }
                    BigDecimal unitCost = item.getUnitCost() != null ? item.getUnitCost() : BigDecimal.ZERO;

                    // Ghi nhận vào inbound_items (chỉ 1 cột qty thực nhận + đơn giá cho MAC).
                    // Hàng hỏng (PO.expectedQty - receivedQty) được trả lại NCC tại chỗ,
                    // KHÔNG lưu vào defective_inventory, KHÔNG tạo phiếu trả NCC.
                    inboundDAO.updateReceivedQtys(inboundId, item.getProductId(), received, unitCost);

                    // Cộng SL thực nhận vào tồn kho + cập nhật MAC.
                    double currentOnHand = 0.0;
                    BigDecimal currentMac = BigDecimal.ZERO;
                    var prod = productDAO.findById(item.getProductId());
                    if (prod != null) {
                        currentOnHand = prod.getQtyOnHand() != null ? prod.getQtyOnHand() : 0.0;
                        currentMac = productDAO.findMacPrice(item.getProductId());
                    }
                    inventoryDAO.addInventory(item.getProductId(), existing.getWarehouseId(), received, userId);
                    productDAO.updateMacPrice(
                            item.getProductId(),
                            BigDecimal.valueOf(currentOnHand),
                            currentMac,
                            received,
                            unitCost);
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
                    .filter(item -> item.getReceivedQty() != null
                            && item.getReceivedQty().compareTo(BigDecimal.ZERO) > 0)
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
        private BigDecimal receivedQty;  // SL thực nhận (đã trừ hàng hỏng trả NCC tại chỗ)
        private BigDecimal unitCost;     // đơn giá nhập, dùng để tính MAC

        public int getProductId() { return productId; }
        public void setProductId(int productId) { this.productId = productId; }
        public BigDecimal getReceivedQty() { return receivedQty; }
        public void setReceivedQty(BigDecimal receivedQty) { this.receivedQty = receivedQty; }
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
