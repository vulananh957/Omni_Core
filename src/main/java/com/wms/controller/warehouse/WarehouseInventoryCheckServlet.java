package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * WarehouseInventoryCheckServlet — Handles Physical Inventory Check (Kiểm kê kho) for the Warehouse Staff.
 *
 * Maps to /warehouse/inventory-check.
 */
public class WarehouseInventoryCheckServlet extends BaseController {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Kiểm Kê & Cân Bằng Tồn Kho");
        req.setAttribute("pageSubtitle", "Đối soát số lượng hệ thống vs. đếm tay thực tế — điều chỉnh độ lệch");
        req.setAttribute("currentPage",  "wh-inventory-check");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/inventory/warehouse-inventory-check.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }
}
