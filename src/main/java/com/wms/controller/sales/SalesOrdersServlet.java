package com.wms.controller.sales;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.controller.BaseController;
import com.wms.model.Channel;
import com.wms.model.Order;
import com.wms.service.sales.ChannelService;
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
    private final ChannelService channelService = new ChannelService();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            List<Order> list = orderService.findAllOrders();
            List<Channel> channels = channelService.findAll();
            req.setAttribute("orderList", list);
            req.setAttribute("channels", channels);
            req.setAttribute("channelsJson", objectMapper.writeValueAsString(channels));
        } catch (Exception e) {
            req.setAttribute("orderList", List.of());
            req.setAttribute("channels", List.<Channel>of());
            req.setAttribute("channelsJson", "[]");
        }

        req.setAttribute("pageTitle",    "Danh Sách Đơn Hàng");
        req.setAttribute("pageSubtitle", "Giám sát đơn hàng từ các kênh bán hàng");
        req.setAttribute("currentPage",  "sales-orders");

        req.setAttribute("contentPage", "/WEB-INF/views/sales/sales-orders.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/sales-layout.jsp")
           .forward(req, resp);
    }
}
