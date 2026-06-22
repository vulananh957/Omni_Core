package com.wms.controller.warehouse;

import com.fasterxml.jackson.core.type.TypeReference;
import com.wms.controller.BaseController;
import com.wms.model.InboundOrder;
import com.wms.model.Product;
import com.wms.model.Warehouse;
import com.wms.service.product.ProductService;
import com.wms.service.warehouse.InboundService;
import com.wms.model.ReceiptNote;
import com.wms.service.warehouse.RtvService;
import com.wms.service.warehouse.WarehouseService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.wms.util.JsonUtil;

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
    private final RtvService rtvService = new RtvService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        consumeFlash(req);
        try {
            List<InboundOrder> inboundList = inboundService.findAll();
            List<Product> products = productService.findAll();
            List<Warehouse> warehouses = warehouseService.findAllActive();
            req.setAttribute("inboundList", inboundList);
            req.setAttribute("products", products);
            setJsonAttr(req, "productsJson", products);
            req.setAttribute("warehouses", warehouses);
            req.setAttribute("myWarehouseId", currentWarehouseId(req));
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

        try {
            List<?> rtvList = rtvService.findByWarehouse(currentWarehouseId(req));
            req.setAttribute("rtvList", rtvList);
            setJsonAttr(req, "rtvListJson", rtvList);
        } catch (Exception e) {
            req.setAttribute("rtvList", List.of());
            setJsonAttr(req, "rtvListJson", List.of());
        }

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
                setFlashError(req, "ID kho không hợp lệ.");
                redirect(resp, "/warehouse/inbound");
                return;
            }

            InboundService.ValidationResult validation = inboundService.validateForCreate(supplierName, warehouseId);
            if (!validation.isSuccess()) {
                setFlashError(req, validation.getMessage());
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

            String itemsJson = req.getParameter("itemsJson");
            List<DraftItem> items = null;
            if (itemsJson != null && !itemsJson.trim().isEmpty()) {
                try {
                    items = com.wms.util.JsonUtil.getMapper().readValue(itemsJson,
                            new com.fasterxml.jackson.core.type.TypeReference<List<DraftItem>>() {});
                    System.err.println("[DEBUG] itemsJson parsed, count=" + (items != null ? items.size() : 0));
                    if (items != null) {
                        for (DraftItem it : items) {
                            System.err.println("[DEBUG]   DraftItem: sku=" + it.getSkuCode() + " qty=" + it.getOrderedQty() + " price=" + it.getPrice());
                        }
                    }
                } catch (Exception e) {
                    System.err.println("[ERROR] Failed to parse itemsJson: " + e.getMessage());
                    e.printStackTrace();
                }
            } else {
                System.err.println("[WARN] itemsJson is null or empty");
            }

            try {
                int inboundId = inboundService.createInbound(
                        supplierName, warehouseId, expectedDate, notes,
                        currentUserId != null ? currentUserId : 1);
                System.err.println("[DEBUG] createInbound returned id=" + inboundId);

                if (inboundId > 0) {
                    if (items != null && !items.isEmpty()) {
                        com.wms.dao.ProductDAO productDAO = new com.wms.dao.ProductDAO();
                        com.wms.dao.InboundDAO inboundDAO = new com.wms.dao.InboundDAO();
                        for (DraftItem item : items) {
                            System.err.println("[DEBUG] Looking up product: sku=" + item.getSkuCode());
                            Product prod = productDAO.findBySkuCode(item.getSkuCode());
                            if (prod != null) {
                                System.err.println("[DEBUG]   Found product id=" + prod.getProductId() + " name=" + prod.getProductName());
                                if (item.getPrice() != null && item.getPrice().compareTo(BigDecimal.ZERO) > 0) {
                                    prod.setBasePrice(item.getPrice().doubleValue());
                                    productDAO.update(prod);
                                }
                                ReceiptNote rn = new ReceiptNote();
                                rn.setInboundId(inboundId);
                                rn.setProductId(prod.getProductId());
                                rn.setExpectedQty(item.getOrderedQty());
                                rn.setReceivedQty(BigDecimal.ZERO);
                                rn.setAcceptedQty(BigDecimal.ZERO);
                                rn.setRejectedQty(BigDecimal.ZERO);
                                rn.setUnitCost(item.getPrice());
                                boolean inserted = inboundDAO.insertReceipt(rn);
                                System.err.println("[DEBUG]   insertReceipt result=" + inserted);
                            } else {
                                System.err.println("[WARN]   Product not found for sku=" + item.getSkuCode());
                            }
                        }
                    }

                    InboundOrder order = inboundService.findById(inboundId);
                    if (order != null) {
                        setFlashSuccess(req, "Tạo phiếu nhập " + order.getInboundCode() + " thành công!");
                    } else {
                        setFlashSuccess(req, "Tạo phiếu nhập thành công!");
                    }
                } else {
                    setFlashError(req, "Không thể tạo phiếu nhập. Vui lòng thử lại.");
                }
            } catch (Exception e) {
                setFlashError(req, "Lỗi cơ sở dữ liệu: " + e.getMessage());
            }

        } else if ("confirm".equals(action)) {
            String inboundIdStr = req.getParameter("inboundId");
            if (inboundIdStr == null || inboundIdStr.trim().isEmpty()) {
                setFlashError(req, "Thiếu ID phiếu nhập.");
                redirect(resp, "/warehouse/inbound");
                return;
            }
            try {
                int inboundId = Integer.parseInt(inboundIdStr);
                InboundService.TransitionResult result = inboundService.confirmInbound(inboundId);
                if (result.isSuccess()) {
                    setFlashSuccess(req, result.getMessage());
                } else {
                    setFlashError(req, result.getMessage());
                }
            } catch (NumberFormatException e) {
                setFlashError(req, "ID phiếu nhập không hợp lệ.");
            }

        } else if ("receive".equals(action)) {
            String inboundIdStr = req.getParameter("inboundId");
            String[] productIds = req.getParameterValues("productId");
            String[] receivedQtys = req.getParameterValues("receivedQty");
            String[] acceptedQtys = req.getParameterValues("acceptedQty");
            String[] unitCosts = req.getParameterValues("unitCost");

            if (inboundIdStr == null || inboundIdStr.trim().isEmpty()) {
                setFlashError(req, "Thiếu ID phiếu nhập.");
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
                        item.setReceivedQty(parseDecimal(receivedQtys[i]));
                        item.setAcceptedQty(parseDecimal(acceptedQtys != null ? acceptedQtys[i] : null));
                        item.setUnitCost(parseDecimal(unitCosts != null ? unitCosts[i] : null));
                        items.add(item);
                    }
                }

                InboundService.ReceiveResult result = inboundService.receiveGoods(
                        inboundId, items, currentUserId != null ? currentUserId : 1);

                if (result.isSuccess()) {
                    setFlashSuccess(req, result.getMessage());
                } else {
                    setFlashError(req, result.getMessage());
                }
            } catch (Exception e) {
                setFlashError(req, "Dữ liệu không hợp lệ: " + e.getMessage());
            }
            redirect(resp, "/warehouse/inbound");
            return;
        } else if ("createRtv".equals(action)) {
            // AJAX RTV creation
            resp.setContentType("application/json;charset=UTF-8");
            try {
                int inboundId = Integer.parseInt(req.getParameter("inboundId"));
                String reason = req.getParameter("reason");
                String note = req.getParameter("note");
                String itemsJson = req.getParameter("itemsJson");
                List<RtvService.RtvItemRequest> itemRequests = null;
                if (itemsJson != null && !itemsJson.trim().isEmpty()) {
                    itemRequests = JsonUtil.getMapper().readValue(itemsJson,
                            new TypeReference<List<RtvService.RtvItemRequest>>() {});
                }
                int uid = currentUserId != null ? currentUserId : 1;
                RtvService.RtvResult result = rtvService.createRtv(inboundId, itemRequests, reason, note, uid);
                resp.getWriter().write("{\"success\":" + result.isSuccess()
                        + ",\"message\":\"" + rtvEscapeJson(result.getMessage()) + "\"}");
            } catch (Exception e) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + rtvEscapeJson(e.getMessage()) + "\"}");
            }
            return;
        } else if ("approveRtv".equals(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            try {
                int rtvId = Integer.parseInt(req.getParameter("rtvId"));
                int uid = currentUserId != null ? currentUserId : 1;
                RtvService.RtvResult result = rtvService.approveRtv(rtvId, uid);
                resp.getWriter().write("{\"success\":" + result.isSuccess()
                        + ",\"message\":\"" + rtvEscapeJson(result.getMessage()) + "\"}");
            } catch (Exception e) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + rtvEscapeJson(e.getMessage()) + "\"}");
            }
            return;
        } else if ("completeRtv".equals(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            try {
                int rtvId = Integer.parseInt(req.getParameter("rtvId"));
                int uid = currentUserId != null ? currentUserId : 1;
                RtvService.RtvResult result = rtvService.completeRtv(rtvId, uid);
                resp.getWriter().write("{\"success\":" + result.isSuccess()
                        + ",\"message\":\"" + rtvEscapeJson(result.getMessage()) + "\"}");
            } catch (Exception e) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + rtvEscapeJson(e.getMessage()) + "\"}");
            }
            return;
        } else if ("cancelRtv".equals(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            try {
                int rtvId = Integer.parseInt(req.getParameter("rtvId"));
                int uid = currentUserId != null ? currentUserId : 1;
                RtvService.RtvResult result = rtvService.cancelRtv(rtvId, uid);
                resp.getWriter().write("{\"success\":" + result.isSuccess()
                        + ",\"message\":\"" + rtvEscapeJson(result.getMessage()) + "\"}");
            } catch (Exception e) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + rtvEscapeJson(e.getMessage()) + "\"}");
            }
            return;
        } else {
            redirect(resp, "/warehouse/inbound");
        }
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

    private int currentWarehouseId(HttpServletRequest req) {
        Object user = req.getSession(false) != null
                ? req.getSession(false).getAttribute("loggedInUser")
                : null;
        if (user != null) {
            try {
                return (Integer) user.getClass().getMethod("getWarehouseId").invoke(user);
            } catch (Exception ignored) {
            }
        }
        return 1;
    }

    @com.fasterxml.jackson.annotation.JsonIgnoreProperties(ignoreUnknown = true)
    public static BigDecimal parseDecimal(String val) {
        if (val == null || val.trim().isEmpty()) return null;
        try { return new BigDecimal(val.trim()); }
        catch (NumberFormatException e) { return null; }
    }

    private String rtvEscapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "");
    }

    public static class DraftItem {
        private String skuCode;
        private BigDecimal orderedQty;
        private BigDecimal price;

        public String getSkuCode() { return skuCode; }
        public void setSkuCode(String skuCode) { this.skuCode = skuCode; }
        public BigDecimal getOrderedQty() { return orderedQty; }
        public void setOrderedQty(BigDecimal orderedQty) { this.orderedQty = orderedQty; }
        public BigDecimal getPrice() { return price; }
        public void setPrice(BigDecimal price) { this.price = price; }
    }
}
