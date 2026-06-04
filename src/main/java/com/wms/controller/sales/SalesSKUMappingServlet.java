package com.wms.controller.sales;

import com.wms.controller.BaseController;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * SalesSKUMappingServlet — Handles the "Ánh xạ SKU" (SKU Mapping Center) page for Sales Staff.
 *
 * Maps to /sales/sku-mapping.
 * Mirrors the React SKUMapping component.
 */
public class SalesSKUMappingServlet extends BaseController {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Trung Tâm Ánh Xạ SKU Đa Sàn");
        req.setAttribute("pageSubtitle", "Kết nối Master SKU nội bộ kho hàng với Channel SKU trên các sàn TMĐT");
        req.setAttribute("currentPage",  "sales-sku-mapping");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/sales/sku-mapping.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/sales-layout.jsp")
           .forward(req, resp);
    }
}
