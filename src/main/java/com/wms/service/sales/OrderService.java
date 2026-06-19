package com.wms.service.sales;

import com.wms.dao.InventoryDAO;
import com.wms.dao.OrderDAO;
import com.wms.dao.WarehouseDAO;
import com.wms.model.Order;
import com.wms.model.OrderItem;
import com.wms.model.Product;
import com.wms.model.Warehouse;
import com.wms.service.lazada.LazadaShipmentService;
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
    private final InventoryDAO inventoryDAO = new InventoryDAO();

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
                // Validate tồn kho trước khi duyệt (fix bug "hết hàng vẫn chỉ định kho được")
                Order order = orderDAO.findByOrderCode(orderCode);
                if (order == null) {
                    log.warn("Approve order failed: order not found orderCode={}", orderCode);
                    return ActionResult.failure("Không tìm thấy đơn hàng: " + orderCode);
                }
                List<OrderItem> items = orderDAO.findItemsByOrderId(order.getOrderId());
                StringBuilder insufficientSkus = new StringBuilder();
                int insufficientCount = 0;
                for (OrderItem item : items) {
                    int available = inventoryDAO.getAvailableStock(item.getProductId(), warehouseId);
                    if (available < item.getQuantity()) {
                        insufficientCount++;
                        insufficientSkus.append(String.format(
                            "%n  - SKU %s: cần %d, chỉ còn %d",
                            item.getSkuCode(), item.getQuantity(), available));
                    }
                }
                if (insufficientSkus.length() > 0) {
                    // Bài 3: chỉ fail khi TẤT CẢ SKU đều hết; nếu chỉ một vài SKU thiếu thì tách đơn
                    if (insufficientCount >= items.size()) {
                        log.warn("Approve order failed: ALL items out of stock orderCode={} warehouseId={} details={}",
                            orderCode, warehouseId, insufficientSkus);
                        return ActionResult.failure(
                            "Không thể duyệt đơn: tất cả SKU đều hết hàng tại kho đã chọn." + insufficientSkus);
                    }
                    log.info("Approve order with partial stock: orderCode={} warehouseId={} insufficient={}/{} details={}",
                        orderCode, warehouseId, insufficientCount, items.size(), insufficientSkus);
                    String partialNote = "Đơn tách: " + insufficientCount + "/" + items.size()
                        + " SKU hết hàng chờ nhập. Chi tiết:" + insufficientSkus;
                    boolean ok = orderDAO.updateOrderStatusAndWarehouse(orderCode, "PICKING", warehouseId, partialNote);
                    if (ok) {
                        try {
                            outboundService.autoCreateFromOrder(orderCode, warehouseId, 1);
                        } catch (Exception ex) {
                            log.warn("Failed to auto-create outbound for order {}: {}", orderCode, ex.getMessage());
                        }
                        return ActionResult.success(
                            "Đã duyệt phần có hàng. " + insufficientCount
                            + " SKU hết hàng, chờ nhập thêm (xem ghi chú đơn).");
                    } else {
                        log.error("Order approve DAO failed: orderCode={}", orderCode);
                        return ActionResult.failure("Không thể duyệt đơn hàng.");
                    }
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
                // Bắt buộc lý do từ chối (fix xung đột giữa notification và DB)
                if (note == null || note.trim().isEmpty()) {
                    log.warn("Reject order failed: empty reason orderCode={}", orderCode);
                    return ActionResult.failure("Vui lòng nhập lý do từ chối đơn hàng.");
                }
                if (note.trim().length() < 10) {
                    log.warn("Reject order failed: reason too short ({} chars) orderCode={}", note.trim().length(), orderCode);
                    return ActionResult.failure("Lý do từ chối phải có ít nhất 10 ký tự để phục vụ truy vết.");
                }
                String trimmedNote = note.trim();
                // orders.order_status ENUM only allows: PENDING, CONFIRMED, PICKING,
                // PACKED, SHIPPED, DELIVERED, CANCELLED, RETURNED. "REJECTED" is not
                // in the ENUM and would cause MySQL 1265 Data truncated.
                // Use CANCELLED + persist reason in review_note.
                boolean ok = orderDAO.updateOrderStatusAndWarehouse(orderCode, "CANCELLED", 0, trimmedNote);
                if (ok) {
                    log.info("Order rejected: orderCode={} reason={}", orderCode, trimmedNote);
                    return ActionResult.success("Từ chối đơn hàng thành công.");
                } else {
                    log.error("Order reject DAO failed: orderCode={}", orderCode);
                    return ActionResult.failure("Không thể từ chối đơn hàng.");
                }
            }
            case "generate_tracking": {
                Order current = orderDAO.findByOrderCode(orderCode);
                if (current == null) {
                    log.warn("Generate tracking failed: order not found orderCode={}", orderCode);
                    return ActionResult.failure("Không tìm thấy đơn hàng: " + orderCode);
                }

                // Lazada end-to-end: if the order belongs to a Lazada channel,
                // call Lazada's /order/fulfill/pack so the marketplace itself
                // allocates the tracking number. For other channels (Shopee,
                // TikTok, local) we keep the local generation flow.
                if ("LAZADA".equalsIgnoreCase(current.getChannel())
                        && current.getChannelId() > 0) {
                    LazadaShipmentService.ShipmentResult r =
                            new LazadaShipmentService().packAndAllocate(current);
                    if (!r.success) {
                        log.error("Lazada pack failed: orderCode={} err={}",
                                orderCode, r.errorMessage);
                        return ActionResult.failure(
                                "Lazada cấp vận đơn thất bại: " + r.errorMessage);
                    }
                    Map<String, Object> data = new HashMap<>();
                    data.put("trackingNo", r.trackingNo);
                    data.put("packageId", r.packageId);
                    return ActionResult.success(
                            "Lazada đã cấp vận đơn " + r.trackingNo
                                    + " (package " + r.packageId + ")", data);
                }

                // Server-side generate nếu client không truyền trackingNo
                String finalTracking = (trackingNo == null || trackingNo.trim().isEmpty())
                    ? generateTrackingNo(current)
                    : trackingNo.trim();
                if (orderDAO.existsByTrackingNo(finalTracking)) {
                    log.warn("Generate tracking failed: duplicate trackingNo={} orderCode={}", finalTracking, orderCode);
                    return ActionResult.failure("Mã vận đơn đã tồn tại: " + finalTracking);
                }
                boolean ok = orderDAO.updateOrderTrackingNo(orderCode, finalTracking);
                if (ok) {
                    log.info("Tracking generated: orderCode={} trackingNo={}", orderCode, finalTracking);
                    Map<String, Object> data = new HashMap<>();
                    data.put("trackingNo", finalTracking);
                    return ActionResult.success("Cập nhật tracking thành công.", data);
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
            case "rts": {
                // TODO: tích hợp LazadaRTSService.submitRTS(orderCode)
                // Hiện tại chưa gọi API thật — chỉ log để trace
                log.info("RTS request received for orderCode={} — Lazada RTS API integration pending", orderCode);
                return ActionResult.failure("Tính năng tạo vận đơn (RTS) đang chờ tích hợp API Lazada.");
            }
            case "webhook": {
                String status = determineWebhookStatus(platformStatus);
                if (status == null) {
                    log.warn("Webhook status unknown: orderCode={} platformStatus={}", orderCode, platformStatus);
                    return ActionResult.failure("Trạng thái webhook không xác định: " + platformStatus);
                }
                log.info("Webhook processing: orderCode={} platformStatus={} mappedStatus={}", orderCode, platformStatus, status);
                // Bài 5: xử lý khách hủy đơn từ sàn (tránh kho đóng gói đơn ảo)
                if ("BUYER_CANCELLED".equalsIgnoreCase(status)) {
                    return handleBuyerCancellation(orderCode);
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
                    // ENUM không có "RMA" → dùng "RETURNED" (đã có sẵn trong ENUM).
                    // Lưu ý: trạng thái RMA nghiệp vụ thể hiện qua note/rma_reason trong DB.
                    boolean ok = orderDAO.updateOrderRMA(orderCode, "RETURNED",
                        "Yêu cầu trả hàng qua webhook", "Chưa kiểm tra", "Đã hoàn trả");
                    return ok ? ActionResult.success("Xử lý trả hàng thành công.")
                              : ActionResult.failure("Không thể xử lý trả hàng.");
                } else if ("COMPLETED".equals(status)) {
                    // ENUM không có "COMPLETED" → dùng "DELIVERED" (đã có sẵn).
                    // Completed = delivered, nghiệp vụ tương đương.
                    boolean ok = orderDAO.updateOrderStatus(orderCode, "DELIVERED");
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
            case "PICKUP":       return "PICKED_UP";
            case "PICKED_UP":    return "PICKED_UP";
            case "TRANSIT":
            case "IN_TRANSIT":   return "IN_TRANSIT";
            case "DELIVERED":    return "DELIVERED";
            case "RETURN":
            case "RETURNED":     return "RETURNED";
            case "COMPLETED":    return "COMPLETED";
            // Bài 5: TikTok gửi "BUYER_CANCELLED", Shopee/Lazada gửi "CANCELLED"
            case "CANCELLED":
                return "BUYER_CANCELLED";
            default: return null;
        }
    }

    /**
     * Bài 5: xử lý khi khách hủy đơn từ sàn.
     * - Đã SHIPPED/DELIVERED: từ chối (hàng đã đi)
     * - Còn lại: hủy đơn + release soft-allocate (cộng lại qty_available đã trừ khi duyệt)
     */
    private ActionResult handleBuyerCancellation(String orderCode) {
        Order order = orderDAO.findByOrderCode(orderCode);
        if (order == null) {
            log.warn("handleBuyerCancellation: order not found orderCode={}", orderCode);
            return ActionResult.failure("Không tìm thấy đơn: " + orderCode);
        }

        String currentStatus = order.getStatus();
        if ("SHIPPED".equalsIgnoreCase(currentStatus)
            || "DELIVERED".equalsIgnoreCase(currentStatus)) {
            log.warn("handleBuyerCancellation: order already shipped orderCode={} status={}",
                orderCode, currentStatus);
            return ActionResult.failure(
                "Đơn đã xuất kho (trạng thái " + currentStatus + "), không thể hủy qua webhook. Liên hệ kho.");
        }

        String reason = "Khách hàng hủy đơn qua webhook sàn.";
        boolean ok = orderDAO.updateOrderStatusAndWarehouse(
            orderCode, "CANCELLED", 0, reason);
        if (!ok) {
            log.error("handleBuyerCancellation: DAO update failed orderCode={}", orderCode);
            return ActionResult.failure("Không thể hủy đơn trong database.");
        }

        if (order.getWarehouseId() > 0) {
            List<OrderItem> items = orderDAO.findItemsByOrderId(order.getOrderId());
            int released = 0;
            for (OrderItem item : items) {
                try {
                    boolean releasedOk = inventoryDAO.releaseSoftAllocateInventory(
                        item.getProductId(),
                        order.getWarehouseId(),
                        BigDecimal.valueOf(item.getQuantity()));
                    if (releasedOk) released++;
                } catch (Exception e) {
                    log.warn("handleBuyerCancellation: release stock failed orderCode={} productId={} qty={}: {}",
                        orderCode, item.getProductId(), item.getQuantity(), e.getMessage());
                }
            }
            log.info("handleBuyerCancellation: released {}/{} items for order {}",
                released, items.size(), orderCode);
        }

        log.info("Order cancelled by buyer via webhook: orderCode={}", orderCode);
        return ActionResult.success("Đã hủy đơn theo yêu cầu khách hàng, tồn kho đã được trả lại.");
    }

    /**
     * Sinh mã vận đơn phía server (idempotent kết hợp existsByTrackingNo).
     * Format: {PREFIX}-{YYYYMMDD}-{9 chữ số ngẫu nhiên}
     * PREFIX theo channel: Shopee→SPX, Lazada→LZE, TikTok→TKT, khác→VTP
     */
    private String generateTrackingNo(Order order) {
        String channel = order.getChannel() == null ? "" : order.getChannel();
        String prefix;
        if (channel.equalsIgnoreCase("Shopee")) {
            prefix = "SPX";
        } else if (channel.equalsIgnoreCase("Lazada")) {
            prefix = "LZE";
        } else if (channel.equalsIgnoreCase("TikTok")) {
            prefix = "TKT";
        } else {
            prefix = "VTP";
        }
        String datePart = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        // 9 chữ số từ currentTimeMillis (cực hiếm trùng; thêm existsByTrackingNo check)
        long rand = (System.nanoTime() ^ System.currentTimeMillis()) % 1_000_000_000L;
        if (rand < 0) rand = -rand;
        return String.format("%s-%s-%09d", prefix, datePart, rand);
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
        String sql = "SELECT COALESCE(o.channel, 'Khác') AS channel, SUM(o.total_amount) AS revenue "
                   + "FROM orders o "
                   + "WHERE o.created_at >= ? AND o.created_at < ? GROUP BY o.channel ORDER BY revenue DESC";
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
        private final Map<String, Object> data;

        private ActionResult(boolean success, String message) {
            this(success, message, null);
        }

        private ActionResult(boolean success, String message, Map<String, Object> data) {
            this.success = success;
            this.message = message;
            this.data = data;
        }

        public static ActionResult success(String message) {
            return new ActionResult(true, message, null);
        }

        public static ActionResult success(String message, Map<String, Object> data) {
            return new ActionResult(true, message, data);
        }

        public static ActionResult failure(String message) {
            return new ActionResult(false, message, null);
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
        public Map<String, Object> getData() { return data; }
    }
}
