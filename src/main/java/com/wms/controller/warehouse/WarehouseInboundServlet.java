package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * WarehouseInboundServlet — Handles Inbound Receipts (Nhập kho) for the Warehouse Staff.
 * 
 * Maps to /warehouse/inbound.
 */
public class WarehouseInboundServlet extends BaseController {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Quản Lý Phiếu Nhập Kho");
        req.setAttribute("pageSubtitle", "Xử lý hàng từ nhà cung cấp — ghi nhận tồn kho và tạo ledger entry khi xác nhận");
        req.setAttribute("currentPage",  "wh-inbound");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/inbound/warehouse-inbound.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }
}
