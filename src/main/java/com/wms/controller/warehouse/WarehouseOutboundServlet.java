package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import com.wms.dao.FulfillmentRequestDAO;
import com.wms.model.FulfillmentRequest;
import com.wms.model.OutboundOrder;
import com.wms.model.User;
import com.wms.model.Warehouse;
import com.wms.service.product.ProductService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.wms.service.warehouse.InboundService;
import com.wms.service.warehouse.OutboundService;
import com.wms.service.warehouse.RtvService;
import com.wms.service.warehouse.WarehouseService;
import com.wms.util.AppConstants;
import com.wms.util.JsonUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * WarehouseOutboundServlet — Handles Outbound Dispatch (Xuất kho) for the Warehouse Staff.
 *
 * Maps to /warehouse/outbound.
 * All queries are scoped to the staff's own warehouse. The warehouse dropdown is locked
 * to that single warehouse, and the staff may create disposal notes that are saved
 * (not deducted) for BM approval.
 */
public class WarehouseOutboundServlet extends BaseController {

    private static final String CONTEXT_PATH = "/warehouse/outbound";
    private final OutboundService outboundService = new OutboundService();
    private final WarehouseService warehouseService = new WarehouseService();
    private final FulfillmentRequestDAO fulfillmentDAO = new FulfillmentRequestDAO();
    private final ProductService productService = new ProductService();
    private final InboundService inboundService = new InboundService();
    private final RtvService rtvService = new RtvService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        consumeFlash(req);
        int myWarehouseId = currentWarehouseId(req);
        String statusFilter = req.getParameter("status");
        List<OutboundOrder> outboundOrders;

        try {
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                outboundOrders = outboundService.findByWarehouseAndStatus(myWarehouseId, statusFilter);
            } else {
                outboundOrders = outboundService.findByWarehouse(myWarehouseId);
            }
            // Lock the warehouse list to the staff's own warehouse (used by create/disposal dropdowns)
            Warehouse myWarehouse = warehouseService.findById(myWarehouseId);
            List<Warehouse> warehouses = (myWarehouse != null) ? List.of(myWarehouse) : List.<Warehouse>of();
            req.setAttribute("warehouses", warehouses);
            setJsonAttr(req, "warehousesJson", warehouses);

            List<FulfillmentRequest> fulfillmentRequests = fulfillmentDAO.findPendingByWarehouse(myWarehouseId);
            req.setAttribute("fulfillmentRequests", fulfillmentRequests);
            setJsonAttr(req, "fulfillmentRequestsJson", fulfillmentRequests);

            setJsonAttr(req, "productsJson", productService.findAll());

            List<com.wms.model.InboundOrder> inboundList = inboundService.findAll();
            req.setAttribute("inboundList", inboundList);

            List<?> rtvList = rtvService.findByWarehouse(myWarehouseId);
            req.setAttribute("rtvList", rtvList);
            setJsonAttr(req, "rtvListJson", rtvList);
        } catch (Exception e) {
            outboundOrders = List.of();
            req.setAttribute("warehouses", List.<Warehouse>of());
            req.setAttribute("warehousesJson", "[]");
            req.setAttribute("fulfillmentRequests", List.<FulfillmentRequest>of());
            req.setAttribute("fulfillmentRequestsJson", "[]");
            req.setAttribute("productsJson", "[]");
            req.setAttribute("inboundList", List.of());
            req.setAttribute("rtvList", List.of());
            setJsonAttr(req, "rtvListJson", "[]");
        }

        req.setAttribute("outboundOrders", outboundOrders);
        setJsonAttr(req, "outboundOrdersJson", outboundOrders);
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

        if ("pickItem".equals(action)) {
            handlePickItem(req, resp);
            return;
        }

        if ("disposal".equals(action)) {
            handleDisposal(req, resp);
            return;
        }

        if ("createRtv".equals(action)) {
            handleCreateRtv(req, resp);
            return;
        }

        if ("approveRtv".equals(action)) {
            handleApproveRtv(req, resp);
            return;
        }

        if ("completeRtv".equals(action)) {
            handleCompleteRtv(req, resp);
            return;
        }

        if ("cancelRtv".equals(action)) {
            handleCancelRtv(req, resp);
            return;
        }

        setFlashError(req, "Hành động không hợp lệ: " + action);
        redirect(resp, req.getContextPath() + CONTEXT_PATH);
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String orderIdStr = req.getParameter("orderId");
        String notes = req.getParameter("notes");

        int warehouseId = currentWarehouseId(req);
        int orderId = 0;
        try {
            orderId = Integer.parseInt(orderIdStr.trim());
        } catch (Exception e) {
            setFlashError(req, "Dữ liệu không hợp lệ: orderId phải là số.");
            redirect(resp, req.getContextPath() + CONTEXT_PATH);
            return;
        }

        OutboundService.ValidationResult validation = outboundService.validateForCreate(orderId, warehouseId);
        if (!validation.isSuccess()) {
            setFlashError(req, validation.getMessage());
            redirect(resp, req.getContextPath() + CONTEXT_PATH);
            return;
        }

        try {
            int newId = outboundService.createOutbound(orderId, warehouseId, notes);
            if (newId > 0) {
                setFlashSuccess(req, "Tạo phiếu xuất kho thành công!");
            } else {
                setFlashError(req, "Không thể tạo phiếu xuất kho. Vui lòng thử lại.");
            }
        } catch (Exception e) {
            setFlashError(req, "Lỗi cơ sở dữ liệu: " + e.getMessage());
        }

        redirect(resp, req.getContextPath() + CONTEXT_PATH);
    }

    private void handleUpdateStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String outboundIdStr = req.getParameter("outboundId");
        String newStatus = req.getParameter("status");

        if (outboundIdStr == null || outboundIdStr.trim().isEmpty()
            || newStatus == null || newStatus.trim().isEmpty()) {
            setFlashError(req, "Thiếu thông tin cần thiết để cập nhật trạng thái.");
            redirect(resp, req.getContextPath() + CONTEXT_PATH);
            return;
        }

        try {
            int outboundId = Integer.parseInt(outboundIdStr.trim());
            OutboundService.StatusUpdateResult result = outboundService.updateStatus(outboundId, newStatus, currentUserId(req));
            if (result.isSuccess()) {
                setFlashSuccess(req, result.getMessage());
            } else {
                setFlashError(req, result.getMessage());
            }
        } catch (NumberFormatException e) {
            setFlashError(req, "ID phiếu xuất không hợp lệ.");
        }

        redirect(resp, req.getContextPath() + CONTEXT_PATH);
    }

    private void handleCancel(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String outboundIdStr = req.getParameter("outboundId");

        if (outboundIdStr == null || outboundIdStr.trim().isEmpty()) {
            setFlashError(req, "Thiếu ID phiếu xuất cần hủy.");
            redirect(resp, req.getContextPath() + CONTEXT_PATH);
            return;
        }

        try {
            int outboundId = Integer.parseInt(outboundIdStr.trim());
            OutboundService.CancelResult result = outboundService.cancel(outboundId);
            if (result.isSuccess()) {
                setFlashSuccess(req, result.getMessage());
            } else {
                setFlashError(req, result.getMessage());
            }
        } catch (NumberFormatException e) {
            setFlashError(req, "ID phiếu xuất không hợp lệ.");
        }

        redirect(resp, req.getContextPath() + CONTEXT_PATH);
    }

    /** AJAX: persist a single line item's picked state during picking. */
    private void handlePickItem(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try {
            int outboundId = Integer.parseInt(req.getParameter("outboundId").trim());
            int productId = Integer.parseInt(req.getParameter("productId").trim());
            boolean picked = "true".equalsIgnoreCase(req.getParameter("picked"));
            boolean ok = outboundService.updateItemPicked(outboundId, productId, picked);
            resp.getWriter().write("{\"success\":" + ok + "}");
        } catch (Exception e) {
            resp.getWriter().write("{\"success\":false}");
        }
    }

    /** Creates a disposal (SCRAP) issue note. Saves only — no stock deduction. */
    private void handleDisposal(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String sku = req.getParameter("sku");
        String reason = req.getParameter("reason");
        int warehouseId = currentWarehouseId(req);
        java.math.BigDecimal qty;
        try {
            qty = new java.math.BigDecimal(req.getParameter("qty").trim());
        } catch (Exception e) {
            setFlashError(req, "Dữ liệu phiếu xuất huỷ không hợp lệ.");
            redirect(resp, req.getContextPath() + CONTEXT_PATH);
            return;
        }
        OutboundService.StatusUpdateResult r =
            outboundService.createDisposal(sku, qty, reason, warehouseId, currentUserId(req));
        if (r.isSuccess()) {
            setFlashSuccess(req, r.getMessage());
        } else {
            setFlashError(req, r.getMessage());
        }
        redirect(resp, req.getContextPath() + CONTEXT_PATH);
    }

    private Integer currentUserId(HttpServletRequest req) {
        Object u = req.getSession().getAttribute(AppConstants.SESSION_USER);
        if (u instanceof User) {
            return ((User) u).getUserId();
        }
        return null;
    }

    private int currentWarehouseId(HttpServletRequest req) {
        Object u = req.getSession().getAttribute(AppConstants.SESSION_USER);
        if (u instanceof User && ((User) u).getWarehouseId() > 0) {
            return ((User) u).getWarehouseId();
        }
        return 1;
    }

    private void handleCreateRtv(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try {
            int inboundId = Integer.parseInt(req.getParameter("inboundId"));
            String reason = req.getParameter("reason");
            String note = req.getParameter("note");
            String poCode = req.getParameter("poCode");
            String supplierCode = req.getParameter("supplierCode");
            String contactPerson = req.getParameter("contactPerson");
            String proposal = req.getParameter("proposal");
            String itemsJson = req.getParameter("itemsJson");
            List<RtvService.RtvItemRequest> itemRequests = null;
            if (itemsJson != null && !itemsJson.trim().isEmpty()) {
                itemRequests = JsonUtil.getMapper().readValue(itemsJson,
                        new TypeReference<List<RtvService.RtvItemRequest>>() {});
            }
            Integer currentUserId = currentUserId(req);
            int uid = currentUserId != null ? currentUserId : 1;
            RtvService.RtvResult result = rtvService.createRtv(inboundId, itemRequests, reason, note, uid, poCode, supplierCode, contactPerson, proposal);
            resp.getWriter().write("{\"success\":" + result.isSuccess()
                    + ",\"message\":\"" + rtvEscapeJson(result.getMessage()) + "\"}");
        } catch (Exception e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + rtvEscapeJson(e.getMessage()) + "\"}");
        }
    }

    private void handleApproveRtv(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try {
            int rtvId = Integer.parseInt(req.getParameter("rtvId"));
            Integer currentUserId = currentUserId(req);
            int uid = currentUserId != null ? currentUserId : 1;

            Object u = req.getSession().getAttribute(AppConstants.SESSION_USER);
            if (u instanceof User) {
                User user = (User) u;
                if (!"MANAGER".equals(user.getRole())) {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Chỉ cấp quản lý (Manager) mới có quyền duyệt phiếu trả hàng NCC.\"}");
                    return;
                }
            } else {
                resp.getWriter().write("{\"success\":false,\"message\":\"Yêu cầu đăng nhập.\"}");
                return;
            }

            RtvService.RtvResult result = rtvService.approveRtv(rtvId, uid);
            resp.getWriter().write("{\"success\":" + result.isSuccess()
                    + ",\"message\":\"" + rtvEscapeJson(result.getMessage()) + "\"}");
        } catch (Exception e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + rtvEscapeJson(e.getMessage()) + "\"}");
        }
    }

    private void handleCompleteRtv(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try {
            int rtvId = Integer.parseInt(req.getParameter("rtvId"));
            Integer currentUserId = currentUserId(req);
            int uid = currentUserId != null ? currentUserId : 1;
            RtvService.RtvResult result = rtvService.completeRtv(rtvId, uid);
            resp.getWriter().write("{\"success\":" + result.isSuccess()
                    + ",\"message\":\"" + rtvEscapeJson(result.getMessage()) + "\"}");
        } catch (Exception e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + rtvEscapeJson(e.getMessage()) + "\"}");
        }
    }

    private void handleCancelRtv(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try {
            int rtvId = Integer.parseInt(req.getParameter("rtvId"));
            Integer currentUserId = currentUserId(req);
            int uid = currentUserId != null ? currentUserId : 1;

            Object u = req.getSession().getAttribute(AppConstants.SESSION_USER);
            if (u instanceof User) {
                User user = (User) u;
                if (!"MANAGER".equals(user.getRole())) {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Chỉ cấp quản lý (Manager) mới có quyền hủy phiếu trả hàng NCC.\"}");
                    return;
                }
            } else {
                resp.getWriter().write("{\"success\":false,\"message\":\"Yêu cầu đăng nhập.\"}");
                return;
            }

            RtvService.RtvResult result = rtvService.cancelRtv(rtvId, uid);
            resp.getWriter().write("{\"success\":" + result.isSuccess()
                    + ",\"message\":\"" + rtvEscapeJson(result.getMessage()) + "\"}");
        } catch (Exception e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + rtvEscapeJson(e.getMessage()) + "\"}");
        }
    }

    private String rtvEscapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "");
    }
}
