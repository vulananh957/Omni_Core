package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import com.wms.dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * WarehouseMasterSKUServlet — Handles requests for the Master SKU catalog under the Warehouse Staff role.
 *
 * Maps to /warehouse/master-sku.
 */
public class WarehouseMasterSKUServlet extends BaseController {

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<?> products = productDAO.findAll();
        req.setAttribute("products", products);
        req.setAttribute("pageTitle",    "Danh Mục Master SKU");
        req.setAttribute("pageSubtitle", "Quản lý thông tin gốc sản phẩm — nguồn chuẩn đồng bộ đa kênh");
        req.setAttribute("currentPage",  "wh-master-sku");
        req.setAttribute("contentPage", "/WEB-INF/views/sku/warehouse-master-sku.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }
}
