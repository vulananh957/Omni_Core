package com.wms.controller.category;

import com.wms.controller.BaseController;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * CategoryServlet — Handles requests for the Category Management page.
 * 
 * Maps to /business/categories.
 */
public class CategoryServlet extends BaseController {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Quản Lý Danh Mục Sản Phẩm");
        req.setAttribute("pageSubtitle", "Xây dựng sơ đồ cây phân cấp danh mục sản phẩm và ánh xạ danh mục đa sàn");
        req.setAttribute("currentPage",  "categories");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/category/categories.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/dashboard-layout.jsp")
           .forward(req, resp);
    }
}
