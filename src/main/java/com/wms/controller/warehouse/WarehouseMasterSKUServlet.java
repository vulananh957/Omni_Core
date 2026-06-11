package com.wms.controller.warehouse;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.controller.BaseController;
import com.wms.model.Category;
import com.wms.model.Product;
import com.wms.model.User;
import com.wms.model.Warehouse;
import com.wms.model.Zone;
import com.wms.service.product.ProductService;
import com.wms.service.warehouse.WarehouseService;
import com.wms.util.AppConstants;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.logging.Logger;

/**
 * WarehouseMasterSKUServlet — Handles requests for the Master SKU catalog under the Warehouse Staff role.
 *
 * Maps to /warehouse/master-sku.
 *
 * doGet:  loads full product list and forwards to JSP
 * doPost: handles create / edit actions submitted from the JSP form
 */
public class WarehouseMasterSKUServlet extends BaseController {

    private static final Logger LOGGER = Logger.getLogger(WarehouseMasterSKUServlet.class.getName());
    private static final String CONTEXT_PATH = "/warehouse/master-sku";

    private final ProductService productService = new ProductService();
    private final WarehouseService warehouseService = new WarehouseService();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            List<Product> products = productService.findAll();
            req.setAttribute("products", products);
            req.setAttribute("productsJson", productService.toJson(products));

            List<Warehouse> warehouses = warehouseService.findAllActive();
            req.setAttribute("warehouses", warehouses);
            req.setAttribute("warehousesJson", objectMapper.writeValueAsString(warehouses));

            List<Zone> allZones = warehouseService.findAllZones();
            req.setAttribute("zones", allZones);
            req.setAttribute("zonesJson", objectMapper.writeValueAsString(allZones));

            List<Category> categories = productService.findAllCategories();
            req.setAttribute("categories", categories);
        } catch (Exception e) {
            LOGGER.warning("Failed to load products: " + e.getMessage());
            req.setAttribute("products", java.util.List.<Product>of());
            req.setAttribute("productsJson", "[]");
            req.setAttribute("warehouses", java.util.List.<Warehouse>of());
            req.setAttribute("warehousesJson", "[]");
            req.setAttribute("zones", java.util.List.<Zone>of());
            req.setAttribute("zonesJson", "[]");
            req.setAttribute("categories", java.util.List.<Category>of());
        }

        consumeFlash(req);
        req.setAttribute("pageTitle",    "Danh Mục Master SKU");
        req.setAttribute("pageSubtitle", "Quản lý thông tin gốc sản phẩm — nguồn chuẩn đồng bộ đa kênh");
        req.setAttribute("currentPage",  "wh-master-sku");
        req.setAttribute("contentPage", "/WEB-INF/views/sku/warehouse-master-sku.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if ("create".equals(action)) {
            handleCreate(req, resp);
        } else if ("edit".equals(action)) {
            handleEdit(req, resp);
        } else if ("delete".equals(action)) {
            handleDelete(req, resp);
        } else {
            setFlashError(req, "Hành động không hợp lệ: " + action);
            redirect(resp, CONTEXT_PATH);
        }
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String skuCode      = req.getParameter("skuCode");
        String productName  = req.getParameter("productName");
        String dimensions   = req.getParameter("dimensions");
        String weightStr    = req.getParameter("weight");
        String minStockStr  = req.getParameter("minStock");
        String maxStockStr  = req.getParameter("maxStock");

        if (isNullOrEmpty(skuCode) || isNullOrEmpty(productName)) {
            setFlashError(req, "Mã SKU và Tên sản phẩm là bắt buộc.");
            redirect(resp, CONTEXT_PATH);
            return;
        }

        Product product = new Product();
        product.setSkuCode(skuCode.trim());
        product.setProductName(productName.trim());
        product.setUnit("Cái");

        Integer categoryId = productService.resolveCategoryId(req.getParameter("categoryName"));
        product.setCategoryId(categoryId);

        if (!isNullOrEmpty(dimensions)) {
            product.setAttributesText(dimensions.trim());
        }
        if (!isNullOrEmpty(weightStr)) {
            try { product.setWeightKg(Double.parseDouble(weightStr.trim())); } catch (NumberFormatException ignored) {}
        }
        if (!isNullOrEmpty(minStockStr)) {
            try { product.setMinStock(Double.parseDouble(minStockStr.trim())); } catch (NumberFormatException ignored) {}
        }
        if (!isNullOrEmpty(maxStockStr)) {
            try { product.setMaxStock(Double.parseDouble(maxStockStr.trim())); } catch (NumberFormatException ignored) {}
        }

        User loggedInUser = (User) ((req.getSession(false) != null)
                ? req.getSession(false).getAttribute(AppConstants.SESSION_USER) : null);
        Integer createdBy = (loggedInUser != null) ? loggedInUser.getUserId() : null;

        try {
            boolean created = productService.createProduct(product, createdBy);
            if (created) {
                setFlashSuccess(req, "Đã tạo SKU " + skuCode.trim() + " thành công! Đang chờ phê duyệt.");
            } else {
                setFlashError(req, "Không thể tạo SKU. Vui lòng kiểm tra lại Mã SKU hoặc thử lại.");
            }
        } catch (Exception e) {
            LOGGER.severe("Error creating product: " + e.getMessage());
            setFlashError(req, "Lỗi cơ sở dữ liệu: " + e.getMessage());
        }

        redirect(resp, CONTEXT_PATH);
    }

    private void handleEdit(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String productIdStr = req.getParameter("productId");
        String productName  = req.getParameter("productName");
        String dimensions   = req.getParameter("dimensions");
        String weightStr    = req.getParameter("weight");
        String minStockStr  = req.getParameter("minStock");
        String maxStockStr  = req.getParameter("maxStock");

        if (isNullOrEmpty(productIdStr)) {
            setFlashError(req, "Thiếu ID sản phẩm cần chỉnh sửa.");
            redirect(resp, CONTEXT_PATH);
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            setFlashError(req, "ID sản phẩm không hợp lệ.");
            redirect(resp, CONTEXT_PATH);
            return;
        }

        Product updates = new Product();
        if (!isNullOrEmpty(productName)) updates.setProductName(productName.trim());
        if (!isNullOrEmpty(dimensions)) updates.setAttributesText(dimensions.trim());
        if (!isNullOrEmpty(weightStr)) {
            try { updates.setWeightKg(Double.parseDouble(weightStr.trim())); } catch (NumberFormatException ignored) {}
        }
        if (!isNullOrEmpty(minStockStr)) {
            try { updates.setMinStock(Double.parseDouble(minStockStr.trim())); } catch (NumberFormatException ignored) {}
        }
        if (!isNullOrEmpty(maxStockStr)) {
            try { updates.setMaxStock(Double.parseDouble(maxStockStr.trim())); } catch (NumberFormatException ignored) {}
        }

        ProductService.UpdateResult result = productService.updateProduct(productId, updates);
        if (result.isSuccess()) {
            setFlashSuccess(req, "Đã cập nhật SKU thành công!");
        } else {
            setFlashError(req, result.getMessage());
        }

        redirect(resp, CONTEXT_PATH);
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String productIdStr = req.getParameter("productId");
        if (isNullOrEmpty(productIdStr)) {
            setFlashError(req, "Thiếu ID sản phẩm cần xóa.");
            redirect(resp, CONTEXT_PATH);
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            setFlashError(req, "ID sản phẩm không hợp lệ.");
            redirect(resp, CONTEXT_PATH);
            return;
        }

        ProductService.DeleteResult result = productService.deleteProduct(productId);
        if (result.isSuccess()) {
            setFlashSuccess(req, "Đã xóa thành công sản phẩm!");
        } else {
            setFlashError(req, result.getMessage());
        }

        redirect(resp, CONTEXT_PATH);
    }
}
