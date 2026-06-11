package com.wms.service.warehouse;

import com.wms.dao.InventoryDAO;
import com.wms.dao.OutboundDAO;
import com.wms.model.OutboundOrder;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

public class OutboundService {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMdd");

    private final OutboundDAO outboundDAO = new OutboundDAO();

    public List<OutboundOrder> findAll() {
        return outboundDAO.findAll();
    }

    public List<OutboundOrder> findByStatus(String status) {
        return outboundDAO.findByStatus(status.trim().toUpperCase());
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

    public StatusUpdateResult updateStatus(int outboundId, String newStatus) {
        if (!isValidStatus(newStatus)) {
            return StatusUpdateResult.failure("Trạng thái '" + newStatus + "' không hợp lệ hoặc không thể chuyển đổi.");
        }
        boolean updated = outboundDAO.updateStatus(outboundId, newStatus.trim().toUpperCase());
        if (!updated) {
            return StatusUpdateResult.failure("Không thể cập nhật trạng thái. Phiếu xuất có thể không tồn tại.");
        }
        return StatusUpdateResult.success("Cập nhật trạng thái phiếu xuất thành '" + newStatus + "' thành công!");
    }

    public CancelResult cancel(int outboundId) {
        OutboundOrder existing = outboundDAO.findById(outboundId);
        if (existing == null) {
            return CancelResult.failure("Phiếu xuất không tồn tại.");
        }
        if (OutboundOrder.STATUS_SHIPPED.equals(existing.getStatus())
            || OutboundOrder.STATUS_CANCELLED.equals(existing.getStatus())) {
            return CancelResult.failure("Không thể hủy phiếu ở trạng thái '" + existing.getStatus() + "'.");
        }
        boolean cancelled = outboundDAO.updateStatus(outboundId, OutboundOrder.STATUS_CANCELLED);
        if (!cancelled) {
            return CancelResult.failure("Không thể hủy phiếu xuất. Vui lòng thử lại.");
        }
        return CancelResult.success("Đã hủy phiếu xuất " + existing.getOutboundCode() + " thành công.");
    }

    public boolean isValidStatus(String status) {
        return OutboundOrder.STATUS_PENDING.equals(status)
            || OutboundOrder.STATUS_PICKING.equals(status)
            || OutboundOrder.STATUS_PACKED.equals(status)
            || OutboundOrder.STATUS_SHIPPED.equals(status)
            || OutboundOrder.STATUS_CANCELLED.equals(status);
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
