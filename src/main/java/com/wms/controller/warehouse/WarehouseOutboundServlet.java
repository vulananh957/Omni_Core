package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * WarehouseOutboundServlet — Handles Outbound Dispatch (Xuất kho) for the Warehouse Staff.
 * 
 * Maps to /warehouse/outbound.
 */
public class WarehouseOutboundServlet extends BaseController {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Điều Phối Phiếu Xuất Kho");
        req.setAttribute("pageSubtitle", "Nhận lệnh từ Sales Staff — kiểm tra tồn kho, pick, pack và xuất hàng");
        req.setAttribute("currentPage",  "wh-outbound");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/outbound/warehouse-outbound.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }
}
