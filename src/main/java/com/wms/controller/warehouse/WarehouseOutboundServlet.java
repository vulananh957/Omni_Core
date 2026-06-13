package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import com.wms.dao.FulfillmentRequestDAO;
import com.wms.model.FulfillmentRequest;
import com.wms.model.OutboundOrder;
import com.wms.model.Warehouse;
import com.wms.service.warehouse.OutboundService;
import com.wms.service.warehouse.WarehouseService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * WarehouseOutboundServlet — Handles Outbound Dispatch (Xuất kho) for the Warehouse Staff.
 *
 * Maps to /warehouse/outbound.
 */
public class WarehouseOutboundServlet extends BaseController {

    private static final String CONTEXT_PATH = "/warehouse/outbound";
    private final OutboundService outboundService = new OutboundService();
    private final WarehouseService warehouseService = new WarehouseService();
    private final FulfillmentRequestDAO fulfillmentDAO = new FulfillmentRequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String statusFilter = req.getParameter("status");
        List<OutboundOrder> outboundOrders;

        try {
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                outboundOrders = outboundService.findByStatus(statusFilter);
            } else {
                outboundOrders = outboundService.findAll();
            }
            List<Warehouse> warehouses = warehouseService.findAllActive();
            req.setAttribute("warehouses", warehouses);

            List<FulfillmentRequest> fulfillmentRequests = fulfillmentDAO.findPending();
            req.setAttribute("fulfillmentRequests", fulfillmentRequests);
        } catch (Exception e) {
            outboundOrders = List.of();
            req.setAttribute("warehouses", List.<Warehouse>of());
            req.setAttribute("fulfillmentRequests", List.<FulfillmentRequest>of());
        }

        req.setAttribute("outboundOrders", outboundOrders);
        req.setAttribute("pageTitle",    "Điều Phối Phiếu Xuất Kho");
        req.setAttribute("pageSubtitle", "Nhận lệnh từ Sales Staff — kiểm tra tồn kho, pick, pack và xuất hàng");
        req.setAttribute("currentPage",  "wh-outbound");
        req.setAttribute("contentPage", "/WEB-INF/views/outbound/warehouse-outbound.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("create".equals(action) || action == null) {
            handleCreate(req, resp);
            return;
        }

        if ("updateStatus".equals(action)) {
            handleUpdateStatus(req, resp);
            return;
        }

        if ("cancel".equals(action)) {
            handleCancel(req, resp);
            return;
        }

        setError(req, "Hành động không hợp lệ: " + action);
        redirect(resp, CONTEXT_PATH);
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String orderIdStr = req.getParameter("orderId");
        String warehouseIdStr = req.getParameter("warehouseId");
        String notes = req.getParameter("notes");

        int orderId = 0, warehouseId = 0;
        try {
            orderId = Integer.parseInt(orderIdStr.trim());
            warehouseId = Integer.parseInt(warehouseIdStr.trim());
        } catch (Exception e) {
            setError(req, "Dữ liệu không hợp lệ: orderId hoặc warehouseId phải là số.");
            redirect(resp, CONTEXT_PATH);
            return;
        }

        OutboundService.ValidationResult validation = outboundService.validateForCreate(orderId, warehouseId);
        if (!validation.isSuccess()) {
            setError(req, validation.getMessage());
            redirect(resp, CONTEXT_PATH);
            return;
        }

        try {
            int newId = outboundService.createOutbound(orderId, warehouseId, notes);
            if (newId > 0) {
                setSuccess(req, "Tạo phiếu xuất kho thành công!");
            } else {
                setError(req, "Không thể tạo phiếu xuất kho. Vui lòng thử lại.");
            }
        } catch (Exception e) {
            setError(req, "Lỗi cơ sở dữ liệu: " + e.getMessage());
        }

        redirect(resp, CONTEXT_PATH);
    }

    private void handleUpdateStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String outboundIdStr = req.getParameter("outboundId");
        String newStatus = req.getParameter("status");

        if (outboundIdStr == null || outboundIdStr.trim().isEmpty()
            || newStatus == null || newStatus.trim().isEmpty()) {
            setError(req, "Thiếu thông tin cần thiết để cập nhật trạng thái.");
            redirect(resp, CONTEXT_PATH);
            return;
        }

        try {
            int outboundId = Integer.parseInt(outboundIdStr.trim());
            OutboundService.StatusUpdateResult result = outboundService.updateStatus(outboundId, newStatus);
            if (result.isSuccess()) {
                setSuccess(req, result.getMessage());
            } else {
                setError(req, result.getMessage());
            }
        } catch (NumberFormatException e) {
            setError(req, "ID phiếu xuất không hợp lệ.");
        }

        redirect(resp, CONTEXT_PATH);
    }

    private void handleCancel(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String outboundIdStr = req.getParameter("outboundId");

        if (outboundIdStr == null || outboundIdStr.trim().isEmpty()) {
            setError(req, "Thiếu ID phiếu xuất cần hủy.");
            redirect(resp, CONTEXT_PATH);
            return;
        }

        try {
            int outboundId = Integer.parseInt(outboundIdStr.trim());
            OutboundService.CancelResult result = outboundService.cancel(outboundId);
            if (result.isSuccess()) {
                setSuccess(req, result.getMessage());
            } else {
                setError(req, result.getMessage());
            }
        } catch (NumberFormatException e) {
            setError(req, "ID phiếu xuất không hợp lệ.");
        }

        redirect(resp, CONTEXT_PATH);
    }
}
