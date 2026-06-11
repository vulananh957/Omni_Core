package com.wms.controller.inventory;

import com.wms.controller.BaseController;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * InventoryServlet — Handles requests for the Inventory Management page.
 * 
 * Maps to /business/inventory.
 */
public class InventoryServlet extends BaseController {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

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
