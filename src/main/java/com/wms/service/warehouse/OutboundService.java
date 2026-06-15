package com.wms.service.warehouse;

import com.wms.dao.InventoryDAO;
import com.wms.dao.OutboundDAO;
import com.wms.dao.OrderDAO;
import com.wms.dao.ProductDAO;
import com.wms.dao.WarehouseIssueDAO;
import com.wms.model.Product;
import com.wms.model.Order;
import com.wms.model.OutboundOrder;
import com.wms.model.OutboundItem;
import com.wms.model.OrderItem;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import com.wms.dao.LedgerDAO;
import com.wms.util.DBConnection;

public class OutboundService {

    private static final Logger log = LoggerFactory.getLogger(OutboundService.class);
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMdd");

    private final OutboundDAO outboundDAO = new OutboundDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final InventoryDAO inventoryDAO = new InventoryDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final WarehouseIssueDAO warehouseIssueDAO = new WarehouseIssueDAO();

    public List<OutboundOrder> findAll() {
        return outboundDAO.findAll();
    }

    public List<OutboundOrder> findByStatus(String status) {
        return outboundDAO.findByStatus(status.trim().toUpperCase());
    }

    /** Outbound orders for one warehouse (warehouse-scoped list). */
    public List<OutboundOrder> findByWarehouse(int warehouseId) {
        return outboundDAO.findByWarehouse(warehouseId);
    }

    /** Outbound orders for one warehouse filtered by status. */
    public List<OutboundOrder> findByWarehouseAndStatus(int warehouseId, String status) {
        return outboundDAO.findByWarehouseAndStatus(warehouseId, status.trim().toUpperCase());
    }

    public OutboundOrder findById(int outboundId) {
        return outboundDAO.findById(outboundId);
    }

    public String generateOutboundCode() {
        String today = LocalDate.now().format(DATE_FMT);
        int seq = (int)(Math.random() * 999);
        return "SOUT-" + today + "-" + String.format("%03d", seq);
    }

    public ValidationResult validateForCreate(Integer orderId, Integer warehouseId) {
        if (orderId == null || orderId <= 0) {
            return ValidationResult.failure("Thiếu thông tin bắt buộc: orderId.");
        }
        if (warehouseId == null || warehouseId <= 0) {
            return ValidationResult.failure("Thiếu thông tin bắt buộc: warehouseId.");
        }
        return ValidationResult.success();
    }

    public int createOutbound(int orderId, int warehouseId, String notes) {
        String outboundCode = generateOutboundCode();
        OutboundOrder order = new OutboundOrder();
        order.setOutboundCode(outboundCode);
        order.setOrderId(orderId);
        order.setWarehouseId(warehouseId);
        order.setStatus(OutboundOrder.STATUS_PENDING);
        order.setNotes(notes != null ? notes.trim() : null);
        order.setCreatedAt(LocalDateTime.now());
        return outboundDAO.insert(order);
    }

    /**
     * Creates a disposal (SCRAP) issue note. Saves the note only — no stock deduction
     * (deduction is deferred to BM approval).
     */
    public StatusUpdateResult createDisposal(String sku, java.math.BigDecimal qty, String reason,
                                             int warehouseId, Integer userId) {
        if (sku == null || sku.trim().isEmpty()) {
            return StatusUpdateResult.failure("Vui lòng chọn SKU cần xuất huỷ.");
        }
        if (qty == null || qty.compareTo(java.math.BigDecimal.ZERO) <= 0) {
            return StatusUpdateResult.failure("Số lượng tiêu huỷ phải lớn hơn 0.");
        }
        Product p = productDAO.findBySkuCode(sku.trim());
        if (p == null) {
            return StatusUpdateResult.failure("Không tìm thấy sản phẩm với SKU: " + sku);
        }
        int creator = (userId != null) ? userId : 1;
        String code = warehouseIssueDAO.createScrapIssue(warehouseId, creator, p.getProductId(), qty, reason);
        if (code == null) {
            return StatusUpdateResult.failure("Không thể lưu phiếu xuất huỷ. Vui lòng thử lại.");
        }
        return StatusUpdateResult.success("Đã lưu phiếu xuất huỷ " + code + " (chờ duyệt, chưa trừ tồn).");
    }

    public StatusUpdateResult updateStatus(int outboundId, String newStatus) {
        return updateStatus(outboundId, newStatus, null);
    }

    /** Persists a single line item's picked state. */
    public boolean updateItemPicked(int outboundId, int productId, boolean picked) {
        return outboundDAO.updateItemPicked(outboundId, productId, picked);
    }

    public StatusUpdateResult updateStatus(int outboundId, String newStatus, Integer userId) {
        if (!isValidStatus(newStatus)) {
            log.warn("Outbound status update rejected: invalid status outboundId={} status={}", outboundId, newStatus);
            return StatusUpdateResult.failure("Trạng thái '" + newStatus + "' không hợp lệ hoặc không thể chuyển đổi.");
        }

        if ("SHIPPED".equalsIgnoreCase(newStatus)) {
            if (isOmnichannelOutbound(outboundId)) {
                OutboundOrder order = outboundDAO.findById(outboundId);
                if (order != null) {
                    String outboundCode = order.getOutboundCode();
                    if (outboundCode == null) {
                        outboundCode = "SOUT-OUT-" + outboundId;
                    }
                    boolean ok = new LedgerDAO().approveDocument(outboundCode, "Phiếu Xuất Kho", 1);
                    if (ok) {
                        outboundDAO.createDeliveryNote(outboundId, userId);
                        log.info("Omnichannel outbound auto-approved and processed: outboundId={} code={}", outboundId, outboundCode);
                        return StatusUpdateResult.success("Cập nhật trạng thái phiếu xuất thành '" + newStatus + "' thành công!");
                    } else {
                        log.error("Omnichannel outbound auto-approve failed: outboundId={} code={}", outboundId, outboundCode);
                        return StatusUpdateResult.failure("Không thể hoàn tất xuất kho tự động cho đơn bán lẻ.");
                    }
                }
            }
        }

        String normalized = newStatus.trim().toUpperCase();
        boolean updated = outboundDAO.updateStatus(outboundId, normalized);
        if (!updated) {
            log.error("Outbound status update failed: DAO returned false outboundId={} status={}", outboundId, newStatus);
            return StatusUpdateResult.failure("Không thể cập nhật trạng thái. Phiếu xuất có thể không tồn tại.");
        }

        // Picking-sheet lifecycle: start sheet + assign picker on PICKING; complete on PACKED.
        if (OutboundOrder.STATUS_PICKING.equals(normalized)) {
            if (userId != null) outboundDAO.assignPicker(outboundId, userId);
            outboundDAO.createPickingSheet(outboundId, userId);
        } else if (OutboundOrder.STATUS_PACKED.equals(normalized)) {
            outboundDAO.markAllPicked(outboundId);
            outboundDAO.completePickingSheet(outboundId);
            outboundDAO.createShippingLabel(outboundId);
        } else if (OutboundOrder.STATUS_SHIPPED.equals(normalized)) {
            // On SHIPPED, deduct actual on-hand stock.
            // Previously only the status was updated, so on_hand stayed inflated.
            OutboundOrder order = outboundDAO.findById(outboundId);
            if (order != null && order.getItems() != null) {
                for (OutboundItem item : order.getItems()) {
                    java.math.BigDecimal qty = item.getQty();
                    if (qty != null && qty.compareTo(java.math.BigDecimal.ZERO) > 0) {
                        boolean ok = inventoryDAO.deductShippedInventory(
                            item.getProductId(), order.getWarehouseId(), qty);
                        if (!ok) {
                            log.warn("SHIPPED: deduct thất bại cho productId={} qty={} (tồn không đủ)",
                                item.getProductId(), qty);
                        }
                    }
                }
            }
            outboundDAO.createDeliveryNote(outboundId, userId);
        }

        log.info("Outbound status updated: outboundId={} status={}", outboundId, newStatus);
        return StatusUpdateResult.success("Cập nhật trạng thái phiếu xuất thành '" + newStatus + "' thành công!");
    }

    public boolean isOmnichannelOutbound(int outboundId) {
        String sql =
            "SELECT c.channel_name, o.channel, o.note, o.tracking_no " +
            "FROM outbound_orders oo " +
            "LEFT JOIN orders o ON oo.order_id = o.order_id " +
            "LEFT JOIN channels c ON o.channel_id = c.channel_id " +
            "WHERE oo.outbound_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, outboundId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String channelName = rs.getString("channel_name");
                    String rawChannel = rs.getString("channel");
                    String note = rs.getString("note");
                    String trackingNo = rs.getString("tracking_no");

                    if (channelName == null) {
                        channelName = "Khách mua lẻ";
                    }
                    String lowerName = channelName.toLowerCase();
                    if (lowerName.contains("shopee") || lowerName.contains("tiktok") ||
                        lowerName.contains("lazada") || lowerName.contains("website") ||
                        lowerName.contains("online") || lowerName.contains("khách mua lẻ") ||
                        lowerName.contains("retail")) {
                        return true;
                    }
                    if (rawChannel != null) {
                        String lowerRaw = rawChannel.toLowerCase();
                        if (lowerRaw.contains("shopee") || lowerRaw.contains("tiktok") ||
                            lowerRaw.contains("lazada") || lowerRaw.contains("website") ||
                            lowerRaw.contains("online") || lowerRaw.contains("retail")) {
                            return true;
                        }
                    }
                    if (note != null) {
                        String lowerNote = note.toLowerCase();
                        if (lowerNote.contains("shopee") || lowerNote.contains("tiktok") ||
                            lowerNote.contains("lazada") || lowerNote.contains("website")) {
                            return true;
                        }
                    }
                }
            }
        } catch (Exception e) {
            log.warn("Failed to check if outbound is omnichannel: {}", e.getMessage());
        }
        return false;
    }

    public CancelResult cancel(int outboundId) {
        OutboundOrder existing = outboundDAO.findById(outboundId);
        if (existing == null) {
            log.warn("Outbound cancel failed: not found outboundId={}", outboundId);
            return CancelResult.failure("Phiếu xuất không tồn tại.");
        }
        if (OutboundOrder.STATUS_SHIPPED.equals(existing.getStatus())
            || OutboundOrder.STATUS_CANCELLED.equals(existing.getStatus())) {
            log.warn("Outbound cancel rejected: bad status outboundId={} currentStatus={}", outboundId, existing.getStatus());
            return CancelResult.failure("Không thể hủy phiếu ở trạng thái '" + existing.getStatus() + "'.");
        }

        // Release soft-allocate for each item before cancelling.
        // Without this, qty_available stays decremented and stock appears "stuck".
        if (existing.getItems() != null) {
            for (OutboundItem item : existing.getItems()) {
                java.math.BigDecimal qty = item.getQty();
                if (qty != null && qty.compareTo(java.math.BigDecimal.ZERO) > 0) {
                    boolean released = inventoryDAO.releaseSoftAllocateInventory(
                        item.getProductId(), existing.getWarehouseId(), qty);
                    if (!released) {
                        log.warn("cancel: releaseSoftAllocate thất bại cho productId={} qty={}",
                            item.getProductId(), qty);
                        // Không fail cả cancel, chỉ log để staff kiểm tra tay
                    }
                }
            }
        }

        boolean cancelled = outboundDAO.updateStatus(outboundId, OutboundOrder.STATUS_CANCELLED);
        if (!cancelled) {
            log.error("Outbound cancel failed: DAO returned false outboundId={}", outboundId);
            return CancelResult.failure("Không thể hủy phiếu xuất. Vui lòng thử lại.");
        }
        log.info("Outbound cancelled: outboundId={} code={}", outboundId, existing.getOutboundCode());
        return CancelResult.success("Đã hủy phiếu xuất " + existing.getOutboundCode() + " thành công.");
    }

    public boolean isValidStatus(String status) {
        return OutboundOrder.STATUS_PENDING.equals(status)
            || OutboundOrder.STATUS_PICKING.equals(status)
            || OutboundOrder.STATUS_PACKED.equals(status)
            || OutboundOrder.STATUS_SHIPPED.equals(status)
            || OutboundOrder.STATUS_CANCELLED.equals(status);
    }

    /**
     * Auto-creates an outbound order from an approved sales order.
     * Called by OrderService when a sales order is approved.
     * Also soft-allocates inventory for each order item.
     */
    public void autoCreateFromOrder(String orderCode, int warehouseId, int userId) {
        Order order = orderDAO.findByOrderCode(orderCode);
        if (order == null) {
            log.warn("autoCreateFromOrder: order not found orderCode={}", orderCode);
            return;
        }

        OutboundOrder outbound = new OutboundOrder();
        outbound.setOutboundCode(generateOutboundCode());
        outbound.setOrderId(order.getOrderId());
        outbound.setWarehouseId(warehouseId);
        outbound.setStatus(OutboundOrder.STATUS_PENDING);
        outbound.setNotes("Tạo tự động từ đơn hàng " + orderCode);
        outbound.setCreatedAt(java.time.LocalDateTime.now());

        int outboundId = outboundDAO.insert(outbound);
        if (outboundId <= 0) {
            log.error("autoCreateFromOrder: failed to insert outbound for orderCode={}", orderCode);
            return;
        }

        List<OrderItem> items = orderDAO.findItemsByOrderId(order.getOrderId());
        for (OrderItem item : items) {
            OutboundItem oi = new OutboundItem();
            oi.setOutboundId(outboundId);
            oi.setProductId(item.getProductId());
            oi.setQty(java.math.BigDecimal.valueOf(item.getQuantity()));
            oi.setPickedQty(java.math.BigDecimal.ZERO);
            outboundDAO.insertItem(oi);

            // Soft-allocate inventory for this item
            if (warehouseId > 0) {
                inventoryDAO.softAllocateInventory(item.getProductId(), warehouseId, item.getQuantity());
            }
        }

        log.info("autoCreateFromOrder: created outboundId={} from orderCode={}", outboundId, orderCode);
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

    public static class StatusUpdateResult {
        private final boolean success;
        private final String message;

        private StatusUpdateResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public static StatusUpdateResult success(String message) {
            return new StatusUpdateResult(true, message);
        }

        public static StatusUpdateResult failure(String message) {
            return new StatusUpdateResult(false, message);
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }

    public static class CancelResult {
        private final boolean success;
        private final String message;

        private CancelResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public static CancelResult success(String message) {
            return new CancelResult(true, message);
        }

        public static CancelResult failure(String message) {
            return new CancelResult(false, message);
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }
}
