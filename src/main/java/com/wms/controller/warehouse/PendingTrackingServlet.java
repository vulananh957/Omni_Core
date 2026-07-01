package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import com.wms.dao.PendingTrackingDAO;
import com.wms.service.sales.OrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * PendingTrackingServlet — Trang liệt kê đơn PICKING chưa có mã vận đơn
 * theo kho mà Warehouse Staff phụ trách. URL: /warehouse/pending-tracking (web.xml)
 *
 * <p>GET: hiển thị bảng đơn chờ cấp tracking
 * <p>POST action=assign: gọi OrderService "generate_tracking" rồi "print_shipping"
 */
public class PendingTrackingServlet extends BaseController {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(PendingTrackingServlet.class.getName());

    private final PendingTrackingDAO dao = new PendingTrackingDAO();
    private final OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        consumeFlash(req);
        req.setCharacterEncoding("UTF-8");

        int warehouseId = currentWarehouseId(req);
        List<Map<String, Object>> pending = dao.findByWarehouse(warehouseId);
        req.setAttribute("pendingList", pending);
        req.setAttribute("pendingCount", pending.size());

        req.setAttribute("pageTitle",    "Đơn Chờ Cấp Mã Vận Đơn");
        req.setAttribute("pageSubtitle", "Đơn đã duyệt PICKING — Warehouse Staff cấp mã vận đơn & in tem");
        req.setAttribute("currentPage",  "warehouse-pending-tracking");
        req.setAttribute("contentPage",  "/WEB-INF/views/warehouse/pending-tracking.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        String action = req.getParameter("action");
        if (!"assign".equals(action)) {
            out.write("{\"success\":false,\"message\":\"Hành động không hợp lệ\"}");
            return;
        }

        String orderCode = req.getParameter("orderCode");
        if (orderCode == null || orderCode.trim().isEmpty()) {
            out.write("{\"success\":false,\"message\":\"Thiếu mã đơn hàng\"}");
            return;
        }

        // Bước 1: sinh tracking_no (server-side, idempotent)
        OrderService.ActionResult trackingResult = orderService.handleAction(
            "generate_tracking", orderCode, null, null, null, null, null, null, null,
            null, null);

        if (!trackingResult.isSuccess()) {
            LOGGER.log(Level.WARNING, "PendingTracking: generate_tracking failed orderCode={0} msg={1}",
                new Object[]{orderCode, trackingResult.getMessage()});
            out.write(jsonError("Không thể cấp mã vận đơn: " + trackingResult.getMessage()));
            return;
        }

        LOGGER.log(Level.INFO, "PendingTracking: tracking assigned and outbound created orderCode={0}", orderCode);
        out.write("{\"success\":true,\"message\":\"Đã cấp mã vận đơn và tạo lệnh xuất kho thành công\"}");
    }

    private String jsonError(String message) {
        if (message == null) return "{\"success\":false,\"message\":\"Lỗi không xác định\"}";
        String safe = message
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r");
        return "{\"success\":false,\"message\":\"" + safe + "\"}";
    }
}
