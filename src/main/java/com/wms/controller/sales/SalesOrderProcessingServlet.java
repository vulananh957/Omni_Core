package com.wms.controller.sales;

import com.wms.controller.BaseController;
import com.wms.dao.OrderDAO;
import com.wms.model.Order;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * SalesOrderProcessingServlet — Handles the "Xử lý đơn hàng" (Order Processing) page for Sales Staff.
 *
 * Maps to /sales/order-processing.
 * Mirrors the React OrderProcessing component.
 */
public class SalesOrderProcessingServlet extends BaseController {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Fetch order list from MySQL database
        List<Order> list = orderDAO.getAllOrders();
        req.setAttribute("orderList", list);

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Xử Lý Đơn Hàng");
        req.setAttribute("pageSubtitle", "Sales Staff duyệt đơn, in tem vận chuyển hàng loạt, xác nhận RTS và xử lý khiếu nại RMA");
        req.setAttribute("currentPage",  "sales-processing");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/sales/order-processing.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/sales-layout.jsp")
           .forward(req, resp);
    }
}
