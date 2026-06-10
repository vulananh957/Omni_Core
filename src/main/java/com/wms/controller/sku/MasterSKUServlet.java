package com.wms.controller.sku;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.controller.BaseController;
import com.wms.model.Warehouse;
import com.wms.service.product.ProductService;
import com.wms.service.warehouse.WarehouseService;

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

        req.setAttribute("pageTitle",    "Danh Muc Master SKU");
        req.setAttribute("pageSubtitle", "Quan ly thong tin goc san pham — nguon chuan dong bo da kenh");
        req.setAttribute("currentPage",  "master-sku");

        req.setAttribute("contentPage", "/WEB-INF/views/sku/master-sku.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/dashboard-layout.jsp")
           .forward(req, resp);
    }
}
