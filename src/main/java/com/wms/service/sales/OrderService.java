package com.wms.service.sales;

import com.wms.dao.OrderDAO;
import com.wms.dao.WarehouseDAO;
import com.wms.model.Order;
import com.wms.model.Product;
import com.wms.model.Warehouse;
import com.wms.service.warehouse.OutboundService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class OrderService {

    private static final Logger log = LoggerFactory.getLogger(OrderService.class);

    private final OrderDAO orderDAO = new OrderDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final OutboundService outboundService = new OutboundService();

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
        log.info("Order action: action={} orderCode={}", action, orderCode);
        switch (action) {
            case "approve": {
                int warehouseId = resolveWarehouseNameToId(warehouseName);
                if (warehouseId <= 0) {
                    log.warn("Approve order failed: warehouse not found orderCode={} warehouse={}", orderCode, warehouseName);
                    return ActionResult.failure("Không tìm thấy kho: " + warehouseName);
                }
                String defaultNote = (note == null || note.trim().isEmpty())
                    ? "Đơn hàng đã được duyệt và chuyển về kho." : note.trim();
                boolean ok = orderDAO.updateOrderStatusAndWarehouse(orderCode, "PICKING", warehouseId, defaultNote);
                if (ok) {
                    log.info("Order approved: orderCode={} warehouseId={}", orderCode, warehouseId);
                    try {
                        outboundService.autoCreateFromOrder(orderCode, warehouseId, 1);
                    } catch (Exception ex) {
                        log.warn("Failed to auto-create outbound for order {}: {}", orderCode, ex.getMessage());
                    }
                    return ActionResult.success("Duyệt đơn hàng thành công.");
                } else {
                    log.error("Order approve DAO failed: orderCode={}", orderCode);
                    return ActionResult.failure("Không thể duyệt đơn hàng.");
                }
            }
            case "reject": {
                String defaultNote = (note == null || note.trim().isEmpty())
                    ? "Đơn hàng bị từ chối." : note.trim();
                boolean ok = orderDAO.updateOrderStatusAndWarehouse(orderCode, "REJECTED", 0, defaultNote);
                if (ok) {
                    log.info("Order rejected: orderCode={}", orderCode);
                    return ActionResult.success("Từ chối đơn hàng thành công.");
                } else {
                    log.error("Order reject DAO failed: orderCode={}", orderCode);
                    return ActionResult.failure("Không thể từ chối đơn hàng.");
                }
            }
            case "generate_tracking": {
                if (trackingNo == null || trackingNo.trim().isEmpty()) {
                    log.warn("Generate tracking failed: empty trackingNo orderCode={}", orderCode);
                    return ActionResult.failure("Số tracking không được bỏ trống.");
                }
                boolean ok = orderDAO.updateOrderTrackingNo(orderCode, trackingNo.trim());
                if (ok) {
                    log.info("Tracking generated: orderCode={} trackingNo={}", orderCode, trackingNo);
                    return ActionResult.success("Cập nhật tracking thành công.");
                } else {
                    log.error("Generate tracking DAO failed: orderCode={}", orderCode);
                    return ActionResult.failure("Không thể cập nhật tracking.");
                }
            }
            case "print_shipping": {
                boolean ok = orderDAO.updateOrderStatus(orderCode, "PACKED");
                if (ok) {
                    log.info("Shipping label printed: orderCode={}", orderCode);
                    return ActionResult.success("Cập nhật trạng thái đóng gói thành công.");
                } else {
                    log.error("Print shipping DAO failed: orderCode={}", orderCode);
                    return ActionResult.failure("Không thể cập nhật trạng thái.");
                }
            }
            case "webhook": {
                String status = determineWebhookStatus(platformStatus);
                if (status == null) {
                    log.warn("Webhook status unknown: orderCode={} platformStatus={}", orderCode, platformStatus);
                    return ActionResult.failure("Trạng thái webhook không xác định: " + platformStatus);
                }
                log.info("Webhook processing: orderCode={} platformStatus={} mappedStatus={}", orderCode, platformStatus, status);
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
            default:
                log.warn("Unknown order action: action={} orderCode={}", action, orderCode);
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

    // ── Dashboard KPI methods ──────────────────────────────────

    public BigDecimal getTotalRevenue(String period) {
        LocalDateRange range = parsePeriod(period);
        if (range == null) return BigDecimal.ZERO;
        String sql = "SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE created_at >= ? AND created_at < ?";
        try (Connection conn = com.wms.util.DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(range.start));
            ps.setTimestamp(2, Timestamp.valueOf(range.end));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            log.warn("getTotalRevenue failed for period={}", period, e);
        }
        return BigDecimal.ZERO;
    }

    public int getTotalOrders(String period) {
        LocalDateRange range = parsePeriod(period);
        if (range == null) return 0;
        String sql = "SELECT COUNT(*) FROM orders WHERE created_at >= ? AND created_at < ?";
        try (Connection conn = com.wms.util.DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(range.start));
            ps.setTimestamp(2, Timestamp.valueOf(range.end));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            log.warn("getTotalOrders failed for period={}", period, e);
        }
        return 0;
    }

    public BigDecimal getAvgOrderValue(String period) {
        BigDecimal total = getTotalRevenue(period);
        int count = getTotalOrders(period);
        if (count == 0) return BigDecimal.ZERO;
        return total.divide(BigDecimal.valueOf(count), 2, RoundingMode.HALF_UP);
    }

    public BigDecimal getReturnRate(String period) {
        LocalDateRange range = parsePeriod(period);
        if (range == null) return BigDecimal.ZERO;
        String sql = "SELECT COUNT(*) FROM orders WHERE created_at >= ? AND created_at < ? AND status IN ('RETURNED','RMA')";
        String totalSql = "SELECT COUNT(*) FROM orders WHERE created_at >= ? AND created_at < ?";
        try (Connection conn = com.wms.util.DBConnection.getConnection()) {
            int returned = 0, total = 0;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setTimestamp(1, Timestamp.valueOf(range.start));
                ps.setTimestamp(2, Timestamp.valueOf(range.end));
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) returned = rs.getInt(1); }
            }
            try (PreparedStatement ps = conn.prepareStatement(totalSql)) {
                ps.setTimestamp(1, Timestamp.valueOf(range.start));
                ps.setTimestamp(2, Timestamp.valueOf(range.end));
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) total = rs.getInt(1); }
            }
            if (total == 0) return BigDecimal.ZERO;
            return BigDecimal.valueOf(returned).multiply(BigDecimal.valueOf(100))
                    .divide(BigDecimal.valueOf(total), 2, RoundingMode.HALF_UP);
        } catch (SQLException e) {
            log.warn("getReturnRate failed for period={}", period, e);
        }
        return BigDecimal.ZERO;
    }

    public BigDecimal getRevenueGrowth() {
        LocalDate today = LocalDate.now();
        LocalDate weekAgo = today.minusDays(7);
        LocalDate twoWeeksAgo = today.minusDays(14);
        BigDecimal thisWeek = getTotalRevenueForRange(weekAgo, today);
        BigDecimal lastWeek = getTotalRevenueForRange(twoWeeksAgo, weekAgo);
        if (lastWeek.compareTo(BigDecimal.ZERO) == 0) return BigDecimal.ZERO;
        return thisWeek.subtract(lastWeek)
                .divide(lastWeek, 4, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(100))
                .setScale(2, RoundingMode.HALF_UP);
    }

    private BigDecimal getTotalRevenueForRange(LocalDate start, LocalDate end) {
        String sql = "SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE created_at >= ? AND created_at < ?";
        try (Connection conn = com.wms.util.DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(start.atStartOfDay()));
            ps.setTimestamp(2, Timestamp.valueOf(end.atStartOfDay()));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            log.warn("getTotalRevenueForRange failed", e);
        }
        return BigDecimal.ZERO;
    }

    public Map<String, BigDecimal> getDailyRevenueData(String period) {
        Map<String, BigDecimal> data = new LinkedHashMap<>();
        LocalDateRange range = parsePeriod(period);
        if (range == null) return data;
        String sql = "SELECT DATE(created_at) AS day, SUM(total_amount) AS revenue "
                   + "FROM orders WHERE created_at >= ? AND created_at < ? GROUP BY DATE(created_at) ORDER BY day";
        try (Connection conn = com.wms.util.DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(range.start));
            ps.setTimestamp(2, Timestamp.valueOf(range.end));
            DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Date d = rs.getDate("day");
                    if (d != null) {
                        data.put(d.toLocalDate().format(fmt), rs.getBigDecimal("revenue"));
                    }
                }
            }
        } catch (SQLException e) {
            log.warn("getDailyRevenueData failed for period={}", period, e);
        }
        return data;
    }

    public Map<String, BigDecimal> getChannelRevenueData(String period) {
        Map<String, BigDecimal> data = new LinkedHashMap<>();
        LocalDateRange range = parsePeriod(period);
        if (range == null) return data;
        String sql = "SELECT COALESCE(c.channel_name, 'Khác') AS channel, SUM(o.total_amount) AS revenue "
                   + "FROM orders o LEFT JOIN channels c ON o.channel_id = c.channel_id "
                   + "WHERE o.created_at >= ? AND o.created_at < ? GROUP BY c.channel_name ORDER BY revenue DESC";
        try (Connection conn = com.wms.util.DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(range.start));
            ps.setTimestamp(2, Timestamp.valueOf(range.end));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    data.put(rs.getString("channel"), rs.getBigDecimal("revenue"));
                }
            }
        } catch (SQLException e) {
            log.warn("getChannelRevenueData failed for period={}", period, e);
        }
        return data;
    }

    public Map<String, Integer> getOrderStatusCounts() {
        Map<String, Integer> data = new LinkedHashMap<>();
        String sql = "SELECT status, COUNT(*) AS cnt FROM orders GROUP BY status ORDER BY cnt DESC";
        try (Connection conn = com.wms.util.DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                data.put(rs.getString("status"), rs.getInt("cnt"));
            }
        } catch (SQLException e) {
            log.warn("getOrderStatusCounts failed", e);
        }
        return data;
    }

    public List<Product> getTopProducts(int limit) {
        return orderDAO.getTopProducts(limit);
    }

    private LocalDateRange parsePeriod(String period) {
        if (period == null) period = "week";
        LocalDate today = LocalDate.now();
        switch (period) {
            case "today":   return new LocalDateRange(today.atStartOfDay(), today.plusDays(1).atStartOfDay());
            case "week":    return new LocalDateRange(today.minusDays(7).atStartOfDay(), today.plusDays(1).atStartOfDay());
            case "month":   return new LocalDateRange(today.minusDays(30).atStartOfDay(), today.plusDays(1).atStartOfDay());
            case "quarter": return new LocalDateRange(today.minusDays(90).atStartOfDay(), today.plusDays(1).atStartOfDay());
            default:        return new LocalDateRange(today.minusDays(7).atStartOfDay(), today.plusDays(1).atStartOfDay());
        }
    }

    private static class LocalDateRange {
        final LocalDateTime start;
        final LocalDateTime end;
        LocalDateRange(LocalDateTime start, LocalDateTime end) { this.start = start; this.end = end; }
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
