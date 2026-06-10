package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * WarehouseDocumentsServlet — Handles stock ledger / documents list (Sổ kho) for the Warehouse Staff.
 *
 * Maps to /warehouse/documents.
 */
public class WarehouseDocumentsServlet extends BaseController {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Sổ Kho");
        req.setAttribute("pageSubtitle", "Quản lý phiếu kho — lưu nháp, trình duyệt và xác nhận hoàn hàng");
        req.setAttribute("currentPage",  "wh-documents");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/warehouse/warehouse-documents.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }
}
