package com.wms.controller.sku;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.controller.BaseController;
import com.wms.dao.CategoryDAO;
import com.wms.dao.ProductDAO;
import com.wms.dao.WarehouseDAO;
import com.wms.model.Product;
import com.wms.model.User;
import com.wms.util.AppConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
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
    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Pull flash error/success if any
        consumeFlash(req);

        try {
            List<?> allProducts = productDAO.findAll();
            List<?> pendingProducts = productDAO.findPendingApproval();
            List<?> categories = categoryDAO.findAll();
            List<?> warehouses = warehouseDAO.findAll();

            req.setAttribute("products", allProducts);
            req.setAttribute("pendingProducts", pendingProducts);
            req.setAttribute("categories", categories);

            String productsJson = objectMapper.writeValueAsString(allProducts);
            req.setAttribute("productsJson", productsJson);

            String warehousesJson = objectMapper.writeValueAsString(warehouses);
            req.setAttribute("warehousesJson", warehousesJson);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "MasterSKUServlet: Failed to load product data", e);
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

        User loggedInUser = (User) req.getSession().getAttribute(AppConstants.SESSION_USER);
        if (loggedInUser == null) {
            setFlashError(req, "Bạn cần đăng nhập để thực hiện thao tác này.");
            redirect(resp, req.getContextPath() + "/business/master-sku");
            return;
        }

        try {
            if ("reject".equals(action)) {
                String productIdStr = req.getParameter("productId");
                String rejectReason = req.getParameter("rejectReason");

                if (isNullOrEmpty(productIdStr) || isNullOrEmpty(rejectReason)) {
                    setFlashError(req, "Thiếu thông tin sản phẩm hoặc lý do từ chối.");
                } else {
                    int productId = Integer.parseInt(productIdStr.trim());
                    boolean success = productDAO.reject(productId, rejectReason.trim());
                    if (success) {
                        setFlashSuccess(req, "Từ chối duyệt SKU thành công!");
                    } else {
                        setFlashError(req, "Từ chối duyệt SKU thất bại.");
                    }
                }
            } else if ("approve".equals(action)) {
                String productIdStr = req.getParameter("productId");
                String locationConfigsJson = req.getParameter("locationConfigsJson");

                if (isNullOrEmpty(productIdStr)) {
                    setFlashError(req, "Thiếu ID sản phẩm cần phê duyệt.");
                } else {
                    int productId = Integer.parseInt(productIdStr.trim());
                    List<Product.LocationConfig> configs = null;
                    if (!isNullOrEmpty(locationConfigsJson)) {
                        configs = objectMapper.readValue(
                            locationConfigsJson,
                            new TypeReference<List<Product.LocationConfig>>() {}
                        );
                    }
                    boolean success = productDAO.approveProductWithZones(productId, loggedInUser.getUserId(), configs);
                    if (success) {
                        setFlashSuccess(req, "Phê duyệt SKU và gán vị trí kho thành công!");
                    } else {
                        setFlashError(req, "Phê duyệt SKU thất bại.");
                    }
                }
            } else {
                setFlashError(req, "Hành động không hợp lệ.");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "MasterSKUServlet.doPost error: ", e);
            setFlashError(req, "Lỗi hệ thống: " + e.getMessage());
        }

        redirect(resp, req.getContextPath() + "/business/master-sku");
    }
}
