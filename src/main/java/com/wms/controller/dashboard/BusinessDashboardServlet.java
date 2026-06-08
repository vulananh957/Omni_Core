package com.wms.controller.dashboard;

import com.wms.controller.BaseController;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
public class BusinessDashboardServlet extends BaseController {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Page metadata for the layout
        req.setAttribute("pageTitle",    "Bảng Điều Khiển Hệ Thống Bán Hàng");
        req.setAttribute("pageSubtitle", "Quản lý bán hàng đa kênh - Theo dõi doanh thu và xu hướng");
        req.setAttribute("currentPage",  "dashboard");

        // Tell the layout which body fragment to include
        req.setAttribute("contentPage",
            "/WEB-INF/views/dashboard/business.jsp");

        // Forward to the shell layout
        req.getRequestDispatcher("/WEB-INF/views/layout/dashboard-layout.jsp")
           .forward(req, resp);
    }
}
