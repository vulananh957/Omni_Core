package com.wms.service.sales;

import com.wms.dao.OrderDAO;
import com.wms.dao.WarehouseDAO;
import com.wms.model.Order;
import com.wms.model.Warehouse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

public class OrderService {

    private static final Logger log = LoggerFactory.getLogger(OrderService.class);

    private final OrderDAO orderDAO = new OrderDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();

    public List<Order> findAllOrders() {
        return orderDAO.getAllOrders();
    }

    public boolean updateOrderStatusAndWarehouse(String orderCode, String status,
                                                  int warehouseId, String reviewNote) {
        return orderDAO.updateOrderStatusAndWarehouse(orderCode, status, warehouseId, reviewNote);
    }

    public boolean updateOrderTrackingNo(String orderCode, String trackingNo) {
        return orderDAO.updateOrderTrackingNo(orderCode, trackingNo);
    }

    public boolean updateOrderStatus(String orderCode, String status) {
        return orderDAO.updateOrderStatus(orderCode, status);
    }

    public boolean updateOrderRMA(String orderCode, String status, String rmaReason,
                                   String rmaPhysicalStatus, String rmaPlatformStatus) {
        return orderDAO.updateOrderRMA(orderCode, status, rmaReason, rmaPhysicalStatus, rmaPlatformStatus);
    }

    public boolean updateOrderDispute(String orderCode, String status, String video,
                                      String note, String platformStatus) {
        return orderDAO.updateOrderDispute(orderCode, status, video, note, platformStatus);
    }

    public ActionResult handleAction(String action, String orderCode, String warehouseName,
                                      String note, String trackingNo, String video,
                                      String rmaReason, String rmaPhysicalStatus,
                                      String rmaPlatformStatus, String platformStatus,
                                      String disputeNote) {
        switch (action) {
            case "approve": {
                int warehouseId = resolveWarehouseNameToId(warehouseName);
                if (warehouseId <= 0) {
                    return ActionResult.failure("Không tìm thấy kho: " + warehouseName);
                }
                String defaultNote = (note == null || note.trim().isEmpty())
                    ? "Đơn hàng đã được duyệt và chuyển về kho." : note.trim();
                boolean ok = orderDAO.updateOrderStatusAndWarehouse(orderCode, "PICKING", warehouseId, defaultNote);
                return ok ? ActionResult.success("Duyệt đơn hàng thành công.")
                          : ActionResult.failure("Không thể duyệt đơn hàng.");
            }
            case "reject": {
                String defaultNote = (note == null || note.trim().isEmpty())
                    ? "Đơn hàng bị từ chối." : note.trim();
                boolean ok = orderDAO.updateOrderStatusAndWarehouse(orderCode, "REJECTED", 0, defaultNote);
                return ok ? ActionResult.success("Từ chối đơn hàng thành công.")
                          : ActionResult.failure("Không thể từ chối đơn hàng.");
            }
            case "generate_tracking": {
                if (trackingNo == null || trackingNo.trim().isEmpty()) {
                    return ActionResult.failure("Số tracking không được bỏ trống.");
                }
                boolean ok = orderDAO.updateOrderTrackingNo(orderCode, trackingNo.trim());
                return ok ? ActionResult.success("Cập nhật tracking thành công.")
                          : ActionResult.failure("Không thể cập nhật tracking.");
            }
            case "print_shipping": {
                boolean ok = orderDAO.updateOrderStatus(orderCode, "PACKED");
                return ok ? ActionResult.success("Cập nhật trạng thái đóng gói thành công.")
                          : ActionResult.failure("Không thể cập nhật trạng thái.");
            }
            case "webhook": {
                String status = determineWebhookStatus(platformStatus);
                if (status == null) {
                    return ActionResult.failure("Trạng thái webhook không xác định: " + platformStatus);
                }
                if ("PICKED_UP".equals(status) || "IN_TRANSIT".equals(status)) {
                    boolean ok = orderDAO.updateOrderStatus(orderCode, "SHIPPED");
                    return ok ? ActionResult.success("Cập nhật trạng thái vận chuyển thành công.")
                              : ActionResult.failure("Không thể cập nhật trạng thái.");
                } else if ("DELIVERED".equals(status)) {
                    boolean ok = orderDAO.updateOrderStatus(orderCode, "DELIVERED");
                    return ok ? ActionResult.success("Cập nhật trạng thái giao hàng thành công.")
                              : ActionResult.failure("Không thể cập nhật trạng thái.");
                } else if ("RETURNED".equals(status)) {
                    boolean ok = orderDAO.updateOrderRMA(orderCode, "RMA",
                        "Yêu cầu trả hàng qua webhook", "Chưa kiểm tra", "Đã hoàn trả");
                    return ok ? ActionResult.success("Xử lý RMA thành công.")
                              : ActionResult.failure("Không thể xử lý RMA.");
                } else if ("COMPLETED".equals(status)) {
                    boolean ok = orderDAO.updateOrderStatus(orderCode, "COMPLETED");
                    return ok ? ActionResult.success("Đơn hàng hoàn tất.")
                              : ActionResult.failure("Không thể cập nhật trạng thái.");
                }
                return ActionResult.failure("Không xử lý được trạng thái: " + status);
            }
            case "dispute": {
                String videoUrl = (video != null && !video.trim().isEmpty()) ? video.trim() : null;
                String disputeNoteStr = (disputeNote != null && !disputeNote.trim().isEmpty()) ? disputeNote.trim() : "Khiếu nại";
                boolean ok = orderDAO.updateOrderDispute(orderCode, "DISPUTE", videoUrl, disputeNoteStr, platformStatus);
                return ok ? ActionResult.success("Xử lý khiếu nại thành công.")
                          : ActionResult.failure("Không thể xử lý khiếu nại.");
            }
            default:
                return ActionResult.failure("Hành động không xác định: " + action);
        }
    }

    public int resolveWarehouseNameToId(String warehouseName) {
        if (warehouseName == null || warehouseName.trim().isEmpty()) {
            return 0;
        }
        List<Warehouse> warehouses = warehouseDAO.findAll();
        for (Warehouse w : warehouses) {
            if (w.getWarehouseName().equalsIgnoreCase(warehouseName.trim())) {
                return w.getWarehouseId();
            }
        }
        return 0;
    }

    private String determineWebhookStatus(String platformStatus) {
        if (platformStatus == null) return null;
        switch (platformStatus.toUpperCase()) {
            case "PICKED_UP": return "PICKED_UP";
            case "IN_TRANSIT": return "IN_TRANSIT";
            case "DELIVERED": return "DELIVERED";
            case "RETURNED": return "RETURNED";
            case "COMPLETED": return "COMPLETED";
            default: return null;
        }
    }

    public static class ActionResult {
        private final boolean success;
        private final String message;

        private ActionResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public static ActionResult success(String message) {
            return new ActionResult(true, message);
        }

        public static ActionResult failure(String message) {
            return new ActionResult(false, message);
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }
}
