package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import com.wms.dao.CategoryDAO;
import com.wms.dao.ProductDAO;
import com.wms.model.Category;
import com.wms.model.Product;
import com.wms.model.User;
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

    private final ProductDAO    productDAO  = new ProductDAO();
    private final CategoryDAO   categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<?> products = productDAO.findAll();
        consumeFlash(req);  // pull any session flash messages into request scope
        req.setAttribute("products", products);
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
        } else {
            setFlashError(req, "Hành động không hợp lệ: " + action);
            redirect(resp, CONTEXT_PATH);
        }
    }

    // ── Create a new product SKU ──────────────────────────────────────────────

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String skuCode      = req.getParameter("skuCode");
        String productName  = req.getParameter("productName");
        String categoryName = req.getParameter("categoryName");
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
        product.setStatus(Product.STATUS_PENDING);
        product.setUnit("Cái");

        // Resolve category name → category ID
        Integer categoryId = resolveCategoryId(categoryName);
        product.setCategoryId(categoryId);

        // Parse optional numeric fields
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

        // Attach current user as creator
        User loggedInUser = (User) req.getSession(false) != null
                ? (User) req.getSession(false).getAttribute(AppConstants.SESSION_USER)
                : null;
        if (loggedInUser != null) {
            product.setCreatedBy(loggedInUser.getUserId());
        }

        boolean created = productDAO.insert(product);
        if (created) {
            setFlashSuccess(req, "Đã tạo SKU " + skuCode.trim() + " thành công! Đang chờ phê duyệt.");
        } else {
            setFlashError(req, "Không thể tạo SKU. Vui lòng kiểm tra lại Mã SKU hoặc thử lại.");
        }

        redirect(resp, CONTEXT_PATH);
    }

    // ── Edit an existing product SKU ─────────────────────────────────────────

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

        Product existing = productDAO.findById(productId);
        if (existing == null) {
            setFlashError(req, "Không tìm thấy sản phẩm với ID: " + productId);
            redirect(resp, CONTEXT_PATH);
            return;
        }

        // Apply editable fields
        if (!isNullOrEmpty(productName)) {
            existing.setProductName(productName.trim());
        }
        if (!isNullOrEmpty(dimensions)) {
            existing.setAttributesText(dimensions.trim());
        }
        if (!isNullOrEmpty(weightStr)) {
            try { existing.setWeightKg(Double.parseDouble(weightStr.trim())); } catch (NumberFormatException ignored) {}
        }
        if (!isNullOrEmpty(minStockStr)) {
            try { existing.setMinStock(Double.parseDouble(minStockStr.trim())); } catch (NumberFormatException ignored) {}
        }
        if (!isNullOrEmpty(maxStockStr)) {
            try { existing.setMaxStock(Double.parseDouble(maxStockStr.trim())); } catch (NumberFormatException ignored) {}
        }

        boolean updated = productDAO.update(existing);
        if (updated) {
            setFlashSuccess(req, "Đã cập nhật SKU " + existing.getSkuCode() + " thành công!");
        } else {
            setFlashError(req, "Không thể cập nhật SKU. Vui lòng thử lại.");
        }

        redirect(resp, CONTEXT_PATH);
    }

    // ── Helper: resolve category name to category ID ──────────────────────────

    private Integer resolveCategoryId(String categoryName) {
        if (isNullOrEmpty(categoryName)) return null;
        String trimmed = categoryName.trim();
        List<Category> categories = categoryDAO.findAll();
        for (Category c : categories) {
            if (trimmed.equalsIgnoreCase(c.getCategoryName())) {
                return c.getCategoryId();
            }
        }
        // Category not found — return null (product saved without category)
        LOGGER.warning("WarehouseMasterSKUServlet: Category not found for name='" + trimmed + "'");
        return null;
    }
}

