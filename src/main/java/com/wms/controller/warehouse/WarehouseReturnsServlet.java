package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import com.wms.dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * WarehouseReturnsServlet — Handles Returns, RMA & QC (Hàng hoàn & QC) for the Warehouse Staff.
 *
 * Maps to /warehouse/returns.
 */
public class WarehouseReturnsServlet extends BaseController {

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Pull approved products for the SKU select dropdown
        var products = productDAO.findApproved();
        req.setAttribute("products", products);

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Trung Tâm Tiếp Nhận Hàng Hoàn QC");
        req.setAttribute("pageSubtitle", "Phân loại hàng khách trả — nhập lại kho bán hoặc chuyển kho phế phẩm");
        req.setAttribute("currentPage",  "wh-returns");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/returns/warehouse-returns.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }
}
