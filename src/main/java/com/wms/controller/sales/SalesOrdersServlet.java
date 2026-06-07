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
 * SalesOrdersServlet — Handles the "Tất cả đơn hàng" (All Orders) page for Sales Staff.
 *
 * Maps to /sales/orders.
 * Mirrors the React OrderManagement component.
 */
public class SalesOrdersServlet extends BaseController {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Fetch order list from MySQL database
        List<Order> list = orderDAO.getAllOrders();
        req.setAttribute("orderList", list);

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Giám Sát Vòng Đời Đơn Hàng");
        req.setAttribute("pageSubtitle", "Theo dõi, tra cứu hành trình đơn hàng đa kênh thời gian thực (Shopee, Lazada, TikTok, Web)");
        req.setAttribute("currentPage",  "sales-orders");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/sales/sales-orders.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/sales-layout.jsp")
           .forward(req, resp);
    }
}
