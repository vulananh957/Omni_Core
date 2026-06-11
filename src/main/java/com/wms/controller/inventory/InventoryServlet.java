package com.wms.controller.inventory;

import com.wms.controller.BaseController;
import com.wms.model.Warehouse;
import com.wms.service.warehouse.WarehouseService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * InventoryServlet — Handles requests for the Inventory Management page.
 *
 * Maps to /business/inventory.
 */
public class InventoryServlet extends BaseController {

    private final WarehouseService warehouseService = new WarehouseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            List<Warehouse> warehouses = warehouseService.findAllActive();
            req.setAttribute("warehouses", warehouses);
        } catch (Exception e) {
            req.setAttribute("warehouses", List.<Warehouse>of());
        }

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Tồn Kho");
        req.setAttribute("pageSubtitle", "Quản lý tồn kho vật lý theo từng mặt hàng và kho bãi");
        req.setAttribute("currentPage",  "inventory");

        // Inventory data — empty until backend is implemented
        req.setAttribute("inventoryListJson", "[]");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/inventory/inventory.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/dashboard-layout.jsp")
           .forward(req, resp);
    }
}
