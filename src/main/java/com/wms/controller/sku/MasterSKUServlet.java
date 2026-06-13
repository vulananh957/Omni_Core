package com.wms.controller.sku;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.controller.BaseController;
import com.wms.model.Product;
import com.wms.model.User;
import com.wms.model.Warehouse;
import com.wms.service.product.ProductService;
import com.wms.service.warehouse.WarehouseService;
import com.wms.util.AppConstants;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * MasterSKUServlet — Handles requests for the Master SKU catalog.
 *
 * Maps to /business/master-sku.
 */
public class MasterSKUServlet extends BaseController {

    private static final Logger LOGGER = Logger.getLogger(MasterSKUServlet.class.getName());
    private final ProductService productService = new ProductService();
    private final WarehouseService warehouseService = new WarehouseService();
    private final ObjectMapper objectMapper = com.wms.util.JsonUtil.getMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        consumeFlash(req);
        try {
            req.setAttribute("products", productService.findAll());
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "MasterSKUServlet: Failed to load product data", e);
        }

        try {
            List<com.wms.model.Category> categories = productService.findAllCategories();
            req.setAttribute("categories", categories);
            req.setAttribute("categoriesJson", objectMapper.writeValueAsString(categories));
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "MasterSKUServlet: Failed to load categories", e);
            req.setAttribute("categories", List.of());
            req.setAttribute("categoriesJson", "[]");
        }

        try {
            List<Warehouse> warehouses = warehouseService.findAllActive();
            req.setAttribute("warehouses", warehouses);
            req.setAttribute("warehousesJson", objectMapper.writeValueAsString(warehouses));
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "MasterSKUServlet: Failed to load warehouses", e);
            req.setAttribute("warehouses", List.<Warehouse>of());
            req.setAttribute("warehousesJson", "[]");
        }

        req.setAttribute("pageTitle",    "Danh Mục Master SKU");
        req.setAttribute("pageSubtitle", "Quản lý thông tin gốc sản phẩm — nguồn chuẩn đồng bộ đa kênh");
        req.setAttribute("currentPage",  "master-sku");

        req.setAttribute("contentPage", "/WEB-INF/views/sku/master-sku.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/dashboard-layout.jsp")
           .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute(AppConstants.SESSION_USER);

        boolean isManager = currentUser != null && "MANAGER".equals(currentUser.getRole());
        boolean isWriteAction = action != null && (
            "create".equals(action) || "update".equals(action) ||
            "delete".equals(action) || "approve".equals(action) ||
            "reject".equals(action)
        );

        if (isWriteAction && !isManager) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                "Chi Business Manager moi co quyen thuc hien hanh dong nay.");
            return;
        }

        int userId = currentUser != null ? currentUser.getUserId() : 1;

        try {
            if ("create".equals(action)) {
                Product p = new Product();
                p.setSkuCode(req.getParameter("skuCode"));
                p.setProductName(req.getParameter("productName"));
                String catId = req.getParameter("categoryId");
                if (catId != null && !catId.trim().isEmpty()) {
                    p.setCategoryId(Integer.parseInt(catId));
                }
                p.setBarcode(req.getParameter("barcode"));
                p.setUnit(req.getParameter("unit"));
                String min = req.getParameter("minStock");
                if (min != null && !min.trim().isEmpty()) p.setMinStock(Double.parseDouble(min));
                String max = req.getParameter("maxStock");
                if (max != null && !max.trim().isEmpty()) p.setMaxStock(Double.parseDouble(max));
                p.setWeightKg(parseDouble(req.getParameter("weight")));
                p.setAttributesText(req.getParameter("dimensions"));

                String zonesJson = req.getParameter("locationConfigsJson");
                List<Product.LocationConfig> zones = parseLocationConfigs(zonesJson);

                boolean ok = productService.createProductWithZones(p, userId, zones);
                if (!ok) {
                    req.setAttribute("error", "Không thể tạo sản phẩm. Có thể mã SKU đã tồn tại.");
                    doGet(req, resp);
                    return;
                }
                resp.sendRedirect(req.getContextPath() + "/business/master-sku");

            } else if ("update".equals(action)) {
                int productId = Integer.parseInt(req.getParameter("productId"));
                Product updates = new Product();
                updates.setProductName(req.getParameter("productName"));
                String catId = req.getParameter("categoryId");
                if (catId != null && !catId.trim().isEmpty()) {
                    updates.setCategoryId(Integer.parseInt(catId));
                }
                updates.setWeightKg(parseDouble(req.getParameter("weight")));
                updates.setMinStock(parseDouble(req.getParameter("minStock")));
                updates.setMaxStock(parseDouble(req.getParameter("maxStock")));
                updates.setAttributesText(req.getParameter("dimensions"));
                updates.setBarcode(req.getParameter("barcode"));
                updates.setUnit(req.getParameter("unit"));

                String zonesJson = req.getParameter("locationConfigsJson");
                List<Product.LocationConfig> zones = parseLocationConfigs(zonesJson);

                ProductService.UpdateResult r = productService.updateProduct(productId, updates, zones);
                if (!r.isSuccess()) {
                    session.setAttribute("errorMessage", r.getMessage());
                } else {
                    session.setAttribute("successMessage", "Cập nhật SKU thành công!");
                }
                resp.sendRedirect(req.getContextPath() + "/business/master-sku");

            } else if ("delete".equals(action)) {
                int productId = Integer.parseInt(req.getParameter("productId"));
                ProductService.DeleteResult r = productService.deleteProduct(productId);
                if (!r.isSuccess()) {
                    setFlashError(req, r.getMessage());
                } else {
                    setFlashSuccess(req, "Xóa SKU thành công!");
                }
                resp.sendRedirect(req.getContextPath() + "/business/master-sku");

            } else {
                resp.sendRedirect(req.getContextPath() + "/business/master-sku");
            }
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Tham số không hợp lệ: " + e.getMessage());
            doGet(req, resp);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "MasterSKUServlet doPost error", e);
            req.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            doGet(req, resp);
        }
    }

    private Double parseDouble(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try { return Double.parseDouble(s.trim()); }
        catch (NumberFormatException e) { return null; }
    }

    private List<Product.LocationConfig> parseLocationConfigs(String json) {
        if (json == null || json.trim().isEmpty()) return List.of();
        try {
            return objectMapper.readValue(json,
                objectMapper.getTypeFactory().constructCollectionType(List.class, Product.LocationConfig.class));
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to parse locationConfigsJson", e);
            return List.of();
        }
    }
}
