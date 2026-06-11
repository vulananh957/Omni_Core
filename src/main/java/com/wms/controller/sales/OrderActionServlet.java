package com.wms.controller.sales;

import com.wms.controller.BaseController;
import com.wms.dao.OrderDAO;
import com.wms.dao.WarehouseDAO;
import com.wms.model.Warehouse;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * OrderActionServlet — Handles POST requests for order lifecycle status
 * modifications.
 * Maps to /sales/order-action.
 */
public class OrderActionServlet extends BaseController {
    private static final Logger LOGGER = Logger.getLogger(OrderActionServlet.class.getName());
    private final OrderDAO orderDAO = new OrderDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String action = req.getParameter("action");
        String orderCode = req.getParameter("orderCode");
        if (action == null || orderCode == null) {
            out.write("{\"success\":false,\"message\":\"Missing action or orderCode\"}");
            return;
        }
        boolean success = false;
        String message = "";
        try {
            switch (action) {
                case "approve": {
                    String warehouseName = req.getParameter("warehouseName");
                    String note = req.getParameter("note");
                    int warehouseId = resolveWarehouseIdByName(warehouseName);
                    success = orderDAO.updateOrderStatusAndWarehouse(orderCode, "PICKING", warehouseId,
                            (note == null || note.isEmpty()) ? "Phê duyệt đơn hàng thành công và bàn giao chỉ định kho."
                                    : note);
                    break;
                }
                case "reject": {
                    String note = req.getParameter("note");
                    success = orderDAO.updateOrderStatusAndWarehouse(orderCode, "CANCELLED", 1,
                            (note == null || note.isEmpty())
                                    ? "Từ chối duyệt đơn do phát hiện dấu hiệu gian lận hoặc thiếu thông tin."
                                    : note);
                    break;
                }
                case "generate_tracking": {
                    String trackingNo = req.getParameter("trackingNo");
                    success = orderDAO.updateOrderTrackingNo(orderCode, trackingNo);
                    break;
                }
                case "print_shipping": {
                    success = orderDAO.updateOrderStatus(orderCode, "PACKED");
                    break;
                }
                case "webhook": {
                    String type = req.getParameter("type");
                    if ("pickup".equals(type) || "transit".equals(type)) {
                        success = orderDAO.updateOrderStatus(orderCode, "SHIPPED");
                    } else if ("delivered".equals(type)) {
                        success = orderDAO.updateOrderStatus(orderCode, "DELIVERED");
                    } else if ("return".equals(type)) {
                        success = orderDAO.updateOrderRMA(orderCode, "RETURNED",
                                "Khách hàng báo sản phẩm bị lỗi hoặc không khớp mô tả",
                                "Đã nhập Zone Khiếu Nại", "Chờ xử lý");
                    } else if ("completed".equals(type)) {
                        success = orderDAO.updateOrderStatus(orderCode, "COMPLETED");
                    }
                    break;
                }
                case "dispute": {
                    String video = req.getParameter("video");
                    String note = req.getParameter("note");
                    success = orderDAO.updateOrderDispute(orderCode, "DISPUTE_SUCCESS", video, note, "Đã bồi thường");
                    break;
                }
                default:
                    message = "Unknown action: " + action;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "OrderActionServlet Error", e);
            message = e.getMessage();
        }
        if (success) {
            out.write("{\"success\":true}");
        } else {
            out.write("{\"success\":false,\"message\":\"" + (message.isEmpty() ? "Database update failed" : message)
                    + "\"}");
        }
    }

    private int resolveWarehouseIdByName(String name) {
        if (name == null || name.isEmpty())
            return 1;
        List<Warehouse> list = warehouseDAO.findAll();
        for (Warehouse w : list) {
            if (w.getWarehouseName().equalsIgnoreCase(name.trim())) {
                return w.getWarehouseId();
            }
        }
        return 1; // Fallback to warehouse 1
    }
}
