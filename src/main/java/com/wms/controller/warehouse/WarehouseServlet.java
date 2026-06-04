package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * WarehouseServlet — Handles requests for the Warehouse List page.
 * 
 * Maps to /business/warehouses.
 */
public class WarehouseServlet extends BaseController {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Danh Sách Kho Hàng");
        req.setAttribute("pageSubtitle", "Quản lý thông tin, phân khu lưu trữ và trạng thái các chi nhánh kho");
        req.setAttribute("currentPage",  "warehouses");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/warehouse/warehouses.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/dashboard-layout.jsp")
           .forward(req, resp);
    }
}
