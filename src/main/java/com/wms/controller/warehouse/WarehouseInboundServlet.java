package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import com.wms.model.InboundOrder;
import com.wms.model.Product;
import com.wms.model.Warehouse;
import com.wms.service.product.ProductService;
import com.wms.service.warehouse.InboundService;
import com.wms.service.warehouse.WarehouseService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * WarehouseInboundServlet — Handles Inbound Receipts (Nhập kho) for the
 * Warehouse Staff.
 *
 * Maps to /warehouse/inbound.
 */
public class WarehouseInboundServlet extends BaseController {

    private final InboundService inboundService = new InboundService();
    private final ProductService productService = new ProductService();
    private final WarehouseService warehouseService = new WarehouseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            List<InboundOrder> inboundList = inboundService.findAll();
            List<Product> products = productService.findAll();
            List<Warehouse> warehouses = warehouseService.findAllActive();
            req.setAttribute("inboundList", inboundList);
            req.setAttribute("products", products);
            setJsonAttr(req, "productsJson", products);
            req.setAttribute("warehouses", warehouses);
        } catch (Exception e) {
            req.setAttribute("inboundList", List.of());
            req.setAttribute("products", List.<Product>of());
            req.setAttribute("productsJson", "[]");
            req.setAttribute("warehouses", List.<Warehouse>of());
        }

        req.setAttribute("pageTitle", "Quản Lý Phiếu Nhập Kho");
        req.setAttribute("pageSubtitle",
                "Xử lý hàng từ nhà cung cấp — ghi nhận tồn kho và tạo ledger entry khi xác nhận");
        req.setAttribute("currentPage", "wh-inbound");

        req.setAttribute("contentPage", "/WEB-INF/views/inbound/warehouse-inbound.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
                .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        Integer currentUserId = getCurrentUserId(req);

        if ("create".equals(action) || action == null) {
            String supplierName = req.getParameter("supplierName");
            String warehouseIdStr = req.getParameter("warehouseId");
            String expectedDateStr = req.getParameter("expectedDate");
            String notes = req.getParameter("notes");

            int warehouseId = 0;
            try {
                warehouseId = Integer.parseInt(warehouseIdStr);
            } catch (NumberFormatException e) {
                setError(req, "ID kho không hợp lệ.");
                redirect(resp, "/warehouse/inbound");
                return;
            }

            InboundService.ValidationResult validation = inboundService.validateForCreate(supplierName, warehouseId);
            if (!validation.isSuccess()) {
                setError(req, validation.getMessage());
                redirect(resp, "/warehouse/inbound");
                return;
            }

            LocalDate expectedDate = null;
            if (expectedDateStr != null && !expectedDateStr.trim().isEmpty()) {
                try {
                    expectedDate = LocalDate.parse(expectedDateStr);
                } catch (Exception ignored) {
                }
            }

            try {
                int inboundId = inboundService.createInbound(
                        supplierName, warehouseId, expectedDate, notes,
                        currentUserId != null ? currentUserId : 1);

                if (inboundId > 0) {
                    InboundOrder order = inboundService.findById(inboundId);
                    if (order != null) {
                        setSuccess(req, "Tạo phiếu nhập " + order.getInboundCode() + " thành công!");
                    } else {
                        setSuccess(req, "Tạo phiếu nhập thành công!");
                    }
                } else {
                    setError(req, "Không thể tạo phiếu nhập. Vui lòng thử lại.");
                }
            } catch (Exception e) {
                setError(req, "Lỗi cơ sở dữ liệu: " + e.getMessage());
            }

        } else if ("confirm".equals(action)) {
            String inboundIdStr = req.getParameter("inboundId");
            if (inboundIdStr == null || inboundIdStr.trim().isEmpty()) {
                setError(req, "Thiếu ID phiếu nhập.");
                redirect(resp, "/warehouse/inbound");
                return;
            }
            try {
                int inboundId = Integer.parseInt(inboundIdStr);
                InboundService.TransitionResult result = inboundService.confirmInbound(inboundId);
                if (result.isSuccess()) {
                    setSuccess(req, result.getMessage());
                } else {
                    setError(req, result.getMessage());
                }
            } catch (NumberFormatException e) {
                setError(req, "ID phiếu nhập không hợp lệ.");
            }

        } else if ("receive".equals(action)) {
            String inboundIdStr = req.getParameter("inboundId");
            String[] productIds = req.getParameterValues("productId");
            String[] receivedQtys = req.getParameterValues("receivedQty");

            if (inboundIdStr == null || inboundIdStr.trim().isEmpty()) {
                setError(req, "Thiếu ID phiếu nhập.");
                redirect(resp, "/warehouse/inbound");
                return;
            }

            try {
                int inboundId = Integer.parseInt(inboundIdStr);
                List<InboundService.ReceiptItem> items = new ArrayList<>();
                if (productIds != null && receivedQtys != null) {
                    for (int i = 0; i < productIds.length; i++) {
                        InboundService.ReceiptItem item = new InboundService.ReceiptItem();
                        item.setProductId(Integer.parseInt(productIds[i]));
                        item.setReceivedQty(new BigDecimal(receivedQtys[i]));
                        items.add(item);
                    }
                }

                InboundService.ReceiveResult result = inboundService.receiveGoods(
                        inboundId, items, currentUserId != null ? currentUserId : 1);

                if (result.isSuccess()) {
                    setSuccess(req, result.getMessage());
                } else {
                    setError(req, result.getMessage());
                }
            } catch (Exception e) {
                setError(req, "Dữ liệu không hợp lệ: " + e.getMessage());
            }
        }

        redirect(resp, "/warehouse/inbound");
    }

    private Integer getCurrentUserId(HttpServletRequest req) {
        try {
            Object user = req.getSession(false) != null
                    ? req.getSession(false).getAttribute("loggedInUser")
                    : null;
            if (user != null) {
                return (Integer) user.getClass().getMethod("getUserId").invoke(user);
            }
        } catch (Exception ignored) {
        }
        return null;
    }
}
