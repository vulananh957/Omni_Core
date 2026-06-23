package com.wms.service;

import com.wms.dao.NotificationDAO;
import com.wms.model.Notification;
import com.wms.model.User;
import com.wms.util.AppConstants;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * NotificationService — Business logic layer for creating and retrieving notifications.
 *
 * <p>Use the convenience broadcast methods to send alerts to all members of a role
 * (optionally scoped to a specific warehouse). Use the session-aware getters to
 * retrieve the right notifications for the currently logged-in user.</p>
 *
 * <p>All methods are safe to call even when notifications are disabled — they log
 * a warning and return gracefully without disrupting the caller's transaction.</p>
 */
public class NotificationService {

    private static final Logger LOGGER = Logger.getLogger(NotificationService.class.getName());
    private final NotificationDAO dao = new NotificationDAO();

    // ── Broadcast to Warehouse Staff ──────────────────────────────────

    /**
     * Notifies all warehouse staff of a specific warehouse.
     * Use for: defective goods, RMA arrivals, incoming transfers, inventory checks.
     */
    public void notifyWarehouseStaff(Integer warehouseId, String type, String title,
                                    String message, String refType, Long refId, String priority) {
        Notification tmpl = Notification.forRole(
                AppConstants.ROLE_WAREHOUSE_STAFF, warehouseId,
                type, title, message, refType, refId, priority);
        int count = dao.broadcastToWarehouseStaff(warehouseId, tmpl);
        if (count > 0) {
            LOGGER.log(Level.INFO, "Notified {0} WH staff (warehouse={1}): {2}",
                    new Object[]{count, warehouseId, title});
        }
    }

    /**
     * Shorthand for warehouse-staff notifications with normal priority.
     */
    public void notifyWarehouseStaff(Integer warehouseId, String type, String title,
                                    String message, String refType, Long refId) {
        notifyWarehouseStaff(warehouseId, type, title, message, refType, refId,
                Notification.PRIORITY_NORMAL);
    }

    // ── Broadcast to Manager ─────────────────────────────────────────

    /**
     * Notifies all managers — use for: pending approvals, revenue alerts.
     */
    public void notifyManagers(String title, String message,
                              String refType, Long refId, String priority) {
        Notification tmpl = Notification.forRole(
                AppConstants.ROLE_MANAGER, null,
                Notification.TYPE_APPROVAL, title, message, refType, refId, priority);
        int count = dao.broadcastToManagers(tmpl);
        if (count > 0) {
            LOGGER.log(Level.INFO, "Notified {0} managers: {1}", new Object[]{count, title});
        }
    }

    public void notifyManagers(String title, String message, String refType, Long refId) {
        notifyManagers(title, message, refType, refId, Notification.PRIORITY_NORMAL);
    }

    /**
     * Notifies managers of a specific warehouse — use for: GRN pending, GI pending.
     */
    public void notifyManagersForWarehouse(Integer warehouseId, String type, String title,
                                          String message, String refType, Long refId,
                                          String priority) {
        Notification tmpl = Notification.forRole(
                AppConstants.ROLE_MANAGER, warehouseId,
                type, title, message, refType, refId, priority);
        int count = dao.broadcastToRole(AppConstants.ROLE_MANAGER, warehouseId, tmpl);
        if (count > 0) {
            LOGGER.log(Level.INFO, "Notified {0} managers (warehouse={1}): {2}",
                    new Object[]{count, warehouseId, title});
        }
    }

    // ── Broadcast to Sales Staff ──────────────────────────────────────

    /**
     * Notifies all sales staff — use for: new orders from channels.
     */
    public void notifySalesStaff(String title, String message,
                                String refType, Long refId, String priority) {
        Notification tmpl = Notification.forRole(
                AppConstants.ROLE_SALES_STAFF, null,
                Notification.TYPE_ORDER, title, message, refType, refId, priority);
        int count = dao.broadcastToSalesStaff(tmpl);
        if (count > 0) {
            LOGGER.log(Level.INFO, "Notified {0} sales staff: {1}", new Object[]{count, title});
        }
    }

    public void notifySalesStaff(String title, String message, String refType, Long refId) {
        notifySalesStaff(title, message, refType, refId, Notification.PRIORITY_NORMAL);
    }

    // ── Broadcast to Admin ───────────────────────────────────────────

    public void notifyAdmins(String title, String message,
                             String refType, Long refId, String priority) {
        Notification tmpl = Notification.forRole(
                AppConstants.ROLE_ADMIN, null,
                Notification.TYPE_SYSTEM, title, message, refType, refId, priority);
        int count = dao.broadcastToAdmins(tmpl);
        if (count > 0) {
            LOGGER.log(Level.INFO, "Notified {0} admins: {1}", new Object[]{count, title});
        }
    }

    // ── User-specific notification ─────────────────────────────────────

    /**
     * Sends a notification to a specific user.
     */
    public void notifyUser(int userId, String role, Integer warehouseId,
                           String type, String title, String message,
                           String refType, Long refId, String priority) {
        Notification n = Notification.forUser(
                userId, role, warehouseId,
                type, title, message, refType, refId, priority);
        long id = dao.insert(n);
        if (id > 0) {
            LOGGER.log(Level.FINE, "Notified user {0}: {1}", new Object[]{userId, title});
        }
    }

    // ── Session-aware retrieval ───────────────────────────────────────

    /**
     * Returns notifications for the currently logged-in user.
     */
    public List<Notification> getNotificationsForSession(HttpSession session, int limit) {
        User user = (User) session.getAttribute(AppConstants.SESSION_USER);
        if (user == null) return List.of();

        String role = user.getRole();
        Integer warehouseId = null;
        if (AppConstants.ROLE_WAREHOUSE_STAFF.equals(role)) {
            Object whObj = session.getAttribute(AppConstants.SESSION_WAREHOUSE);
            if (whObj instanceof Integer) {
                warehouseId = (Integer) whObj;
            }
        }
        return dao.findForUser(user.getUserId(), role, warehouseId, limit);
    }

    /**
     * Returns the unread notification count for the badge.
     */
    public int getUnreadCountForSession(HttpSession session) {
        User user = (User) session.getAttribute(AppConstants.SESSION_USER);
        if (user == null) return 0;

        String role = user.getRole();
        Integer warehouseId = null;
        if (AppConstants.ROLE_WAREHOUSE_STAFF.equals(role)) {
            Object whObj = session.getAttribute(AppConstants.SESSION_WAREHOUSE);
            if (whObj instanceof Integer) {
                warehouseId = (Integer) whObj;
            }
        }
        return dao.countUnread(user.getUserId(), role, warehouseId);
    }

    // ── Mark as read ─────────────────────────────────────────────────

    public boolean markAsRead(long notificationId) {
        return dao.markAsRead(notificationId);
    }

    public int markAllAsReadForSession(HttpSession session) {
        User user = (User) session.getAttribute(AppConstants.SESSION_USER);
        if (user == null) return 0;

        String role = user.getRole();
        Integer warehouseId = null;
        if (AppConstants.ROLE_WAREHOUSE_STAFF.equals(role)) {
            Object whObj = session.getAttribute(AppConstants.SESSION_WAREHOUSE);
            if (whObj instanceof Integer) {
                warehouseId = (Integer) whObj;
            }
        }
        return dao.markAllAsRead(user.getUserId(), role, warehouseId);
    }

    // ── Cleanup ──────────────────────────────────────────────────────

    /**
     * Removes notifications older than 30 days. Safe to call on a schedule.
     */
    public int deleteOldNotifications(int days) {
        return dao.deleteOlderThan(days);
    }

    // ── Convenience helpers for common warehouse events ───────────────

    /**
     * Defective stock alert — sent to WH staff of the warehouse.
     */
    public void notifyDefectiveStock(int warehouseId, String warehouseName,
                                     int defectiveCount, int totalUnits) {
        String title = "Hàng lỗi cần xử lý";
        String msg = "Kho " + warehouseName + " có " + defectiveCount +
                " SKU (" + totalUnits + " đơn vị) hàng lỗi chưa xử lý. " +
                "Cần kiểm tra và trả lại NCC kịp thời.";
        notifyWarehouseStaff(warehouseId, Notification.TYPE_DEFECTIVE,
                title, msg, "DEFECTIVE", null, Notification.PRIORITY_HIGH);
    }

    /**
     * New RMA/return order — sent to WH staff of destination warehouse.
     */
    public void notifyNewReturn(int warehouseId, String warehouseName,
                                long returnId, String returnCode) {
        String title = "Phiếu hoàn hàng mới";
        String msg = "Kho " + warehouseName + " có phiếu hoàn hàng " +
                returnCode + " cần tiếp nhận QC.";
        notifyWarehouseStaff(warehouseId, Notification.TYPE_RETURN,
                title, msg, "RMA", returnId, Notification.PRIORITY_HIGH);
    }

    /**
     * Incoming stock transfer — sent to WH staff of destination warehouse.
     */
    public void notifyIncomingTransfer(int warehouseId, String warehouseName,
                                      long transferId, String transferCode,
                                      int itemCount) {
        String title = "Phiếu chuyển kho đến";
        String msg = "Kho " + warehouseName + " sắp nhận " + itemCount +
                " mặt hàng từ phiếu chuyển " + transferCode + ".";
        notifyWarehouseStaff(warehouseId, Notification.TYPE_TRANSFER,
                title, msg, "TRANSFER", transferId, Notification.PRIORITY_NORMAL);
    }

    /**
     * GRN pending approval — sent to managers.
     */
    public void notifyGrnPending(int warehouseId, String warehouseName,
                                 long inboundId, String inboundCode) {
        String title = "Phiếu nhập kho chờ duyệt";
        String msg = "Kho " + warehouseName + " trình phiếu nhập " +
                inboundCode + " cần phê duyệt.";
        notifyManagersForWarehouse(warehouseId, Notification.TYPE_INBOUND,
                title, msg, "GRN", inboundId, Notification.PRIORITY_NORMAL);
    }

    /**
     * GRN approved — sent to the WH staff who created it.
     */
    public void notifyGrnApproved(int userId, long inboundId, String inboundCode) {
        String title = "Phiếu nhập kho đã được duyệt";
        String msg = "Phiếu nhập kho " + inboundCode + " đã được duyệt, tồn kho đã cập nhật.";
        notifyUser(userId, AppConstants.ROLE_WAREHOUSE_STAFF, null,
                Notification.TYPE_INBOUND, title, msg, "GRN", inboundId,
                Notification.PRIORITY_NORMAL);
    }

    /**
     * GI (outbound) pending approval — sent to managers.
     */
    public void notifyGiPending(int warehouseId, String warehouseName,
                                long outboundId, String outboundCode) {
        String title = "Phiếu xuất kho chờ duyệt";
        String msg = "Kho " + warehouseName + " trình phiếu xuất " +
                outboundCode + " cần phê duyệt.";
        notifyManagersForWarehouse(warehouseId, Notification.TYPE_OUTBOUND,
                title, msg, "GI", outboundId, Notification.PRIORITY_NORMAL);
    }

    /**
     * GI approved — sent to the WH staff who created it.
     */
    public void notifyGiApproved(int userId, long outboundId, String outboundCode) {
        String title = "Phiếu xuất kho đã được duyệt";
        String msg = "Phiếu xuất kho " + outboundCode + " đã được duyệt, hàng đã sẵn sàng giao.";
        notifyUser(userId, AppConstants.ROLE_WAREHOUSE_STAFF, null,
                Notification.TYPE_OUTBOUND, title, msg, "GI", outboundId,
                Notification.PRIORITY_NORMAL);
    }

    /**
     * Inventory check submitted — sent to managers.
     */
    public void notifyInventoryCheckPending(int warehouseId, String warehouseName,
                                            long checkId, String checkCode) {
        String title = "Phiếu kiểm kê chờ duyệt";
        String msg = "Kho " + warehouseName + " gửi phiếu kiểm kê " +
                checkCode + " cần phê duyệt điều chỉnh tồn kho.";
        notifyManagersForWarehouse(warehouseId, Notification.TYPE_INVENTORY,
                title, msg, "KK", checkId, Notification.PRIORITY_NORMAL);
    }

    /**
     * Return/RMA pending approval — sent to managers.
     */
    public void notifyReturnPending(int warehouseId, String warehouseName,
                                    long returnId, String returnCode) {
        String title = "Phiếu hoàn hàng chờ duyệt";
        String msg = "Kho " + warehouseName + " gửi kết quả QC " +
                returnCode + " cần phê duyệt.";
        notifyManagersForWarehouse(warehouseId, Notification.TYPE_RETURN,
                title, msg, "RMA", returnId, Notification.PRIORITY_NORMAL);
    }

    /**
     * Transfer pending confirmation — sent to managers.
     */
    public void notifyTransferPending(int fromWarehouseId, int toWarehouseId,
                                       String fromName, String toName,
                                       long transferId, String transferCode) {
        String title = "Phiếu chuyển kho cần xác nhận";
        String msg = "Cần xác nhận chuyển kho " + transferCode +
                " từ " + fromName + " đến " + toName + ".";
        notifyManagers(title, msg, "TRANSFER", transferId, Notification.PRIORITY_NORMAL);
    }

    /**
     * New order from channel — sent to sales staff.
     */
    public void notifyNewOrder(long orderId, String channelName) {
        String title = "Đơn hàng mới từ " + channelName;
        String msg = "Có đơn hàng mới #" + orderId + " từ " +
                channelName + " cần xác nhận và xử lý.";
        notifySalesStaff(title, msg, "ORDER", orderId, Notification.PRIORITY_HIGH);
    }

    /**
     * Order status update — sent to the sales staff who owns the order.
     */
    public void notifyOrderStatus(int createdByUserId, long orderId,
                                   String orderCode, String oldStatus, String newStatus) {
        String title = "Đơn hàng " + orderCode + " cập nhật trạng thái";
        String msg = "Đơn hàng " + orderCode + " đã chuyển từ '" + oldStatus +
                "' sang '" + newStatus + "'.";
        notifyUser(createdByUserId, AppConstants.ROLE_SALES_STAFF, null,
                Notification.TYPE_ORDER, title, msg, "ORDER", orderId,
                Notification.PRIORITY_NORMAL);
    }
}
