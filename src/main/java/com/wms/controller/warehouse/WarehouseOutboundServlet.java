package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import com.wms.dao.InventoryDAO;
import com.wms.dao.OutboundDAO;
import com.wms.model.OutboundOrder;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * WarehouseOutboundServlet — Handles Outbound Dispatch (Xuất kho) for the Warehouse Staff.
 *
 * Maps to /warehouse/outbound.
 *
 * doGet:  loads outbound list from OutboundDAO and inventory from InventoryDAO, forwards to JSP
 * doPost: handles create / updateStatus / cancel actions
 */
public class WarehouseOutboundServlet extends BaseController {

    private static final String CONTEXT_PATH = "/warehouse/outbound";
    private final OutboundDAO outboundDAO = new OutboundDAO();
    private final InventoryDAO inventoryDAO = new InventoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String statusFilter = req.getParameter("status");
        List<OutboundOrder> outboundOrders;

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            outboundOrders = outboundDAO.findByStatus(statusFilter.trim().toUpperCase());
        } else {
            outboundOrders = outboundDAO.findAll();
        }

        for (OutboundOrder order : outboundOrders) {
            order.setItems(outboundDAO.findItemsByOutboundId(order.getOutboundId()));
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
        try {
            String orderIdStr = req.getParameter("orderId");
            String warehouseIdStr = req.getParameter("warehouseId");
            String notes = req.getParameter("notes");

            if (isNullOrEmpty(orderIdStr) || isNullOrEmpty(warehouseIdStr)) {
                setError(req, "Thiếu thông tin bắt buộc: orderId, warehouseId.");
                redirect(resp, CONTEXT_PATH);
                return;
            }

            int orderId = Integer.parseInt(orderIdStr.trim());
            int warehouseId = Integer.parseInt(warehouseIdStr.trim());

            String today = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
            String seqSuffix = String.format("%03d", (int)(Math.random() * 999));
            String outboundCode = "SOUT-" + today + "-" + seqSuffix;

            OutboundOrder order = new OutboundOrder();
            order.setOutboundCode(outboundCode);
            order.setOrderId(orderId);
            order.setWarehouseId(warehouseId);
            order.setStatus(OutboundOrder.STATUS_PENDING);
            order.setNotes(notes != null ? notes.trim() : null);
            order.setCreatedAt(LocalDateTime.now());

            int newId = outboundDAO.insert(order);
            if (newId > 0) {
                setSuccess(req, "Tạo phiếu xuất kho " + outboundCode + " thành công!");
            } else {
                setError(req, "Không thể tạo phiếu xuất kho. Vui lòng thử lại.");
            }
        } catch (NumberFormatException e) {
            setError(req, "Dữ liệu không hợp lệ: orderId hoặc warehouseId phải là số.");
        }

        redirect(resp, CONTEXT_PATH);
    }

    private void handleUpdateStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            String outboundIdStr = req.getParameter("outboundId");
            String newStatus = req.getParameter("status");

            if (isNullOrEmpty(outboundIdStr) || isNullOrEmpty(newStatus)) {
                setError(req, "Thiếu thông tin cần thiết để cập nhật trạng thái.");
                redirect(resp, CONTEXT_PATH);
                return;
            }

            int outboundId = Integer.parseInt(outboundIdStr.trim());
            String status = newStatus.trim().toUpperCase();

            if (!isValidStatusTransition(status)) {
                setError(req, "Trạng thái '" + status + "' không hợp lệ hoặc không thể chuyển đổi.");
                redirect(resp, CONTEXT_PATH);
                return;
            }

            boolean updated = outboundDAO.updateStatus(outboundId, status);
            if (updated) {
                setSuccess(req, "Cập nhật trạng thái phiếu xuất thành '" + status + "' thành công!");
            } else {
                setError(req, "Không thể cập nhật trạng thái. Phiếu xuất có thể không tồn tại.");
            }
        } catch (NumberFormatException e) {
            setError(req, "ID phiếu xuất không hợp lệ.");
        }

        redirect(resp, CONTEXT_PATH);
    }

    private void handleCancel(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            String outboundIdStr = req.getParameter("outboundId");
            if (isNullOrEmpty(outboundIdStr)) {
                setError(req, "Thiếu ID phiếu xuất cần hủy.");
                redirect(resp, CONTEXT_PATH);
                return;
            }

            int outboundId = Integer.parseInt(outboundIdStr.trim());
            OutboundOrder existing = outboundDAO.findById(outboundId);

            if (existing == null) {
                setError(req, "Phiếu xuất không tồn tại.");
                redirect(resp, CONTEXT_PATH);
                return;
            }

            if (OutboundOrder.STATUS_SHIPPED.equals(existing.getStatus())
                    || OutboundOrder.STATUS_CANCELLED.equals(existing.getStatus())) {
                setError(req, "Không thể hủy phiếu ở trạng thái '" + existing.getStatus() + "'.");
                redirect(resp, CONTEXT_PATH);
                return;
            }

            boolean cancelled = outboundDAO.updateStatus(outboundId, OutboundOrder.STATUS_CANCELLED);
            if (cancelled) {
                setSuccess(req, "Đã hủy phiếu xuất " + existing.getOutboundCode() + " thành công.");
            } else {
                setError(req, "Không thể hủy phiếu xuất. Vui lòng thử lại.");
            }
        } catch (NumberFormatException e) {
            setError(req, "ID phiếu xuất không hợp lệ.");
        }

        redirect(resp, CONTEXT_PATH);
    }

    private boolean isValidStatusTransition(String newStatus) {
        return OutboundOrder.STATUS_PENDING.equals(newStatus)
            || OutboundOrder.STATUS_PICKING.equals(newStatus)
            || OutboundOrder.STATUS_PACKED.equals(newStatus)
            || OutboundOrder.STATUS_SHIPPED.equals(newStatus)
            || OutboundOrder.STATUS_CANCELLED.equals(newStatus);
    }
}
