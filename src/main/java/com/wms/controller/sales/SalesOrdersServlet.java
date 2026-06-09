package com.wms.controller.sales;

import com.wms.controller.BaseController;
import com.wms.model.Order;
import com.wms.service.sales.OrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * SalesOrdersServlet — Handles the "Đơn hàng" (Orders) page for Sales Staff.
 * Maps to /sales/orders.
 */
public class SalesOrdersServlet extends BaseController {

    private final OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            List<Order> list = orderService.findAllOrders();
            req.setAttribute("orderList", list);
        } catch (Exception e) {
            req.setAttribute("orderList", List.of());
        }

        req.setAttribute("pageTitle",    "Danh Sách Đơn Hàng");
        req.setAttribute("pageSubtitle", "Giám sát đơn hàng từ các kênh bán hàng");
        req.setAttribute("currentPage",  "sales-orders");

        req.setAttribute("contentPage", "/WEB-INF/views/sales/sales-orders.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/sales-layout.jsp")
           .forward(req, resp);
    }
}
