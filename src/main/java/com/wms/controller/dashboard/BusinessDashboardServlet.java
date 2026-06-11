package com.wms.controller.dashboard;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.controller.BaseController;
import com.wms.model.Channel;
import com.wms.service.sales.ChannelService;
import com.wms.service.sales.OrderService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class BusinessDashboardServlet extends BaseController {

    private final ChannelService channelService = new ChannelService();
    private final OrderService orderService = new OrderService();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String period = req.getParameter("period");
        if (period == null || period.trim().isEmpty()) period = "week";

        try {
            List<Channel> channels = channelService.findAll();
            req.setAttribute("channels", channels);
            req.setAttribute("channelsJson", objectMapper.writeValueAsString(channels));
        } catch (Exception e) {
            req.setAttribute("channels", List.<Channel>of());
            req.setAttribute("channelsJson", "[]");
        }

        // Load KPI data
        try {
            req.setAttribute("totalRevenue", orderService.getTotalRevenue(period));
            req.setAttribute("totalOrders", orderService.getTotalOrders(period));
            req.setAttribute("avgOrderValue", orderService.getAvgOrderValue(period));
            req.setAttribute("returnRate", orderService.getReturnRate(period));
            req.setAttribute("revenueGrowth", orderService.getRevenueGrowth());
            req.setAttribute("dailyData", orderService.getDailyRevenueData(period));
            req.setAttribute("channelData", orderService.getChannelRevenueData(period));
            req.setAttribute("orderStatus", orderService.getOrderStatusCounts());
            req.setAttribute("topProducts", orderService.getTopProducts(5));
        } catch (Exception e) {
            // KPI loading failed — attributes remain unset, JS will show "N/A"
        }

        try {
            req.setAttribute("dailyDataJson", objectMapper.writeValueAsString(orderService.getDailyRevenueData(period)));
            req.setAttribute("channelDataJson", objectMapper.writeValueAsString(orderService.getChannelRevenueData(period)));
            req.setAttribute("orderStatusJson", objectMapper.writeValueAsString(orderService.getOrderStatusCounts()));
            req.setAttribute("topProductsJson", objectMapper.writeValueAsString(orderService.getTopProducts(5)));
        } catch (Exception e) {
            req.setAttribute("dailyDataJson", "null");
            req.setAttribute("channelDataJson", "null");
            req.setAttribute("orderStatusJson", "null");
            req.setAttribute("topProductsJson", "null");
        }

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
