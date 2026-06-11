package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import com.wms.model.Product;
import com.wms.model.User;
import com.wms.service.product.ProductService;
import com.wms.service.warehouse.WarehouseService;
import com.wms.util.AppConstants;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * WarehouseInventoryCheckServlet — Handles Physical Inventory Check (Kiểm kê kho) for the Warehouse Staff.
 *
 * Maps to /warehouse/inventory-check.
 */
public class WarehouseInventoryCheckServlet extends BaseController {

    private static final Logger LOGGER = Logger.getLogger(WarehouseInventoryCheckServlet.class.getName());
    private final ProductService productService = new ProductService();
    private final WarehouseService warehouseService = new WarehouseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            req.setAttribute("warehouses", warehouseService.findAll());
        } catch (Exception e) {
            req.setAttribute("warehouses", List.of());
        }

        try {
            req.setAttribute("zones", warehouseService.findAllZones());
        } catch (Exception e) {
            req.setAttribute("zones", List.of());
        }

        try {
            List<User> staff = warehouseService.findByRoles("WAREHOUSE_STAFF");
            req.setAttribute("staffMembers", staff);
        } catch (Exception e) {
            req.setAttribute("staffMembers", List.of());
        }

        try {
            req.setAttribute("categories", productService.findAllCategories());
        } catch (Exception e) {
            req.setAttribute("categories", List.of());
        }

        try {
            req.setAttribute("products", productService.findApproved());
        } catch (Exception e) {
            req.setAttribute("products", List.of());
        }

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Kiểm Kê & Cân Bằng Tồn Kho");
        req.setAttribute("pageSubtitle", "Đối soát số lượng hệ thống vs. đếm tay thực tế — điều chỉnh độ lệch");
        req.setAttribute("currentPage",  "wh-inventory-check");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/inventory/warehouse-inventory-check.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute(AppConstants.SESSION_USER);
        int userId = currentUser != null ? currentUser.getUserId() : 1;

        try {
            if ("create".equals(action)) {
                handleCreate(req, userId);
            } else if ("submit".equals(action)) {
                handleSubmit(req, userId);
            } else if ("adjust".equals(action)) {
                handleAdjust(req, userId);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "WarehouseInventoryCheckServlet doPost error", e);
            req.setAttribute("error", "Lỗi xử lý: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/warehouse/inventory-check");
    }

    private void handleCreate(HttpServletRequest req, int userId) throws Exception {
        String checkCode = "PK-" + java.time.LocalDate.now().toString().replace("-", "")
            + "-" + String.format("%04d", (int)(Math.random() * 9999));
        String whId = req.getParameter("warehouseId");
        String note = req.getParameter("note");
        String itemsJson = req.getParameter("itemsJson");

        if (whId == null || whId.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn kho hàng.");
        }

        int warehouseId = Integer.parseInt(whId);
        warehouseService.createInventoryCheck(checkCode, warehouseId, userId, note, itemsJson);
    }

    private void handleSubmit(HttpServletRequest req, int userId) throws Exception {
        int checkId = Integer.parseInt(req.getParameter("checkId"));
        String resultsJson = req.getParameter("resultsJson");
        if (resultsJson == null || resultsJson.trim().isEmpty()) {
            throw new IllegalArgumentException("Dữ liệu kiểm kê không hợp lệ.");
        }
        warehouseService.submitInventoryCheckResults(checkId, resultsJson);
    }

    private void handleAdjust(HttpServletRequest req, int userId) throws Exception {
        int checkId = Integer.parseInt(req.getParameter("checkId"));
        String adjustmentsJson = req.getParameter("adjustmentsJson");
        if (adjustmentsJson == null || adjustmentsJson.trim().isEmpty()) {
            throw new IllegalArgumentException("Dữ liệu điều chỉnh không hợp lệ.");
        }
        warehouseService.adjustInventoryFromCheck(checkId, adjustmentsJson, userId);
    }
}
