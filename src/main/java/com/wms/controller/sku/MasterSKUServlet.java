package com.wms.controller.sku;

import com.wms.controller.BaseController;
import com.wms.service.product.ProductService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
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

        req.setAttribute("pageTitle",    "Danh Mục Master SKU");
        req.setAttribute("pageSubtitle", "Quản lý thông tin gốc sản phẩm — nguồn chuẩn đồng bộ đa kênh");
        req.setAttribute("currentPage",  "master-sku");

        req.setAttribute("contentPage", "/WEB-INF/views/sku/master-sku.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/dashboard-layout.jsp")
           .forward(req, resp);
    }
}
