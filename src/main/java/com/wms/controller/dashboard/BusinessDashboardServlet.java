package com.wms.controller.dashboard;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.controller.BaseController;
import com.wms.model.Channel;
import com.wms.service.sales.ChannelService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class BusinessDashboardServlet extends BaseController {

    private final ChannelService channelService = new ChannelService();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            List<Channel> channels = channelService.findAll();
            req.setAttribute("channels", channels);
            req.setAttribute("channelsJson", objectMapper.writeValueAsString(channels));
        } catch (Exception e) {
            req.setAttribute("channels", List.<Channel>of());
            req.setAttribute("channelsJson", "[]");
        }

        // Page metadata for the layout
        req.setAttribute("pageTitle",    "Bang Dieu Khien He Thong Ban Hang");
        req.setAttribute("pageSubtitle", "Quan ly ban hang da kenh - Theo doi doanh thu va xu huong");
        req.setAttribute("currentPage",  "dashboard");

        // Tell the layout which body fragment to include
        req.setAttribute("contentPage",
            "/WEB-INF/views/dashboard/business.jsp");

        // Forward to the shell layout
        req.getRequestDispatcher("/WEB-INF/views/layout/dashboard-layout.jsp")
           .forward(req, resp);
    }
}
