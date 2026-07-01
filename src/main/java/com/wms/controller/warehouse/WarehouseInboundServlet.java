package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import com.wms.model.InboundOrder;
import com.wms.model.Product;
import com.wms.model.Warehouse;
import com.wms.service.product.ProductService;
import com.wms.service.warehouse.InboundService;
import com.wms.model.ReceiptNote;
import com.wms.service.warehouse.WarehouseService;
import com.wms.service.common.NotificationService;

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
    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        consumeFlash(req);
        try {
            int myWarehouseId = currentWarehouseId(req);
            List<InboundOrder> inboundList = inboundService.findByWarehouse(myWarehouseId);
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
            String expectedDateStr = req.getParameter("expectedDate");
            String notes = req.getParameter("notes");

            int warehouseId = currentWarehouseId(req);

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
            redirect(resp, "/warehouse/inbound");
            return;

        } else if ("receive".equals(action)) {
            String inboundIdStr = req.getParameter("inboundId");
            String[] productIds = req.getParameterValues("productId");
            String[] receivedQtys = req.getParameterValues("receivedQty");
            String[] unitCosts = req.getParameterValues("unitCost");

            if (inboundIdStr == null || inboundIdStr.trim().isEmpty()) {
                setFlashError(req, "Thiếu ID phiếu nhập.");
                redirect(resp, "/warehouse/inbound");
                return;
            }

            try {
                int inboundId = Integer.parseInt(inboundIdStr);
                InboundOrder io = inboundService.findById(inboundId);
                int myWarehouseId = currentWarehouseId(req);
                if (io == null || io.getWarehouseId() != myWarehouseId) {
                    setFlashError(req, "Bạn không có quyền nhận hàng cho phiếu nhập thuộc kho khác.");
                    redirect(resp, "/warehouse/inbound");
                    return;
                }
                List<InboundService.ReceiptItem> items = new ArrayList<>();
                if (productIds != null && receivedQtys != null) {
                    for (int i = 0; i < productIds.length; i++) {
                        InboundService.ReceiptItem item = new InboundService.ReceiptItem();
                        item.setProductId(Integer.parseInt(productIds[i]));
                        item.setReceivedQty(parseDecimal(receivedQtys[i]));
                        item.setUnitCost(parseDecimal(unitCosts != null ? unitCosts[i] : null));
                        items.add(item);
                    }
                }

                InboundService.ReceiveResult result = inboundService.receiveGoods(
                        inboundId, items, currentUserId != null ? currentUserId : 1);

                if (result.isSuccess()) {
                    setFlashSuccess(req, result.getMessage());
                    // Notify the WH staff who created this GRN: stock updated
                    if (io.getCreatedBy() > 0) {
                        notificationService.notifyGrnApproved(io.getCreatedBy(), inboundId, io.getInboundCode());
                    }
                } else {
                    setFlashError(req, result.getMessage());
                }
            } catch (Exception e) {
                setFlashError(req, "Dữ liệu không hợp lệ: " + e.getMessage());
            }
            redirect(resp, "/warehouse/inbound");
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

    public static BigDecimal parseDecimal(String val) {
        if (val == null || val.trim().isEmpty()) return null;
        try { return new BigDecimal(val.trim()); }
        catch (NumberFormatException e) { return null; }
    }

    @com.fasterxml.jackson.annotation.JsonIgnoreProperties(ignoreUnknown = true)
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
