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
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            req.setAttribute("products", productService.findAll());
            req.setAttribute("pendingProducts", productService.findPendingApproval());
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "MasterSKUServlet: Failed to load product data", e);
        }

        try {
            req.setAttribute("categories", productService.findAllCategories());
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "MasterSKUServlet: Failed to load categories", e);
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
                p.setWeightKg(parseDouble(req.getParameter("weightKg")));
                p.setAttributesText(req.getParameter("attributes"));

                boolean ok = productService.createProduct(p, userId);
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
                updates.setWeightKg(parseDouble(req.getParameter("weightKg")));
                updates.setMinStock(parseDouble(req.getParameter("minStock")));
                updates.setMaxStock(parseDouble(req.getParameter("maxStock")));
                updates.setAttributesText(req.getParameter("attributes"));

                ProductService.UpdateResult r = productService.updateProduct(productId, updates);
                if (!r.isSuccess()) {
                    req.setAttribute("error", r.getMessage());
                }
                resp.sendRedirect(req.getContextPath() + "/business/master-sku");

            } else if ("approve".equals(action)) {
                int productId = Integer.parseInt(req.getParameter("productId"));
                String zoneConfigsJson = req.getParameter("locationConfigsJson");
                List<Product.LocationConfig> configs = parseLocationConfigs(zoneConfigsJson);
                boolean ok = productService.approveProductWithZones(productId, userId, configs);
                if (!ok) {
                    req.setAttribute("error", "Không thể duyệt sản phẩm.");
                }
                resp.sendRedirect(req.getContextPath() + "/business/master-sku");

            } else if ("reject".equals(action)) {
                int productId = Integer.parseInt(req.getParameter("productId"));
                String reason = req.getParameter("rejectReason");
                boolean ok = productService.rejectProduct(productId, reason);
                if (!ok) {
                    req.setAttribute("error", "Không thể từ chối sản phẩm.");
                }
                resp.sendRedirect(req.getContextPath() + "/business/master-sku");

            } else if ("delete".equals(action)) {
                int productId = Integer.parseInt(req.getParameter("productId"));
                ProductService.DeleteResult r = productService.deleteProduct(productId);
                if (!r.isSuccess()) {
                    req.setAttribute("error", r.getMessage());
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
