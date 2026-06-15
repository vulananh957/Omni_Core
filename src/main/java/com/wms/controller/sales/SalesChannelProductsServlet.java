package com.wms.controller.sales;

import com.wms.controller.BaseController;
import com.wms.service.sales.ChannelService;
import com.wms.util.JsonUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * SalesChannelProductsServlet — Handles the "Sản phẩm theo kênh" page for Sales Staff.
 * Maps to /sales/channel-products.
 */
public class SalesChannelProductsServlet extends BaseController {

    private final ChannelService channelService = new ChannelService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            List<?> channels = channelService.findAll();
            req.setAttribute("channelsList", channels);
            req.setAttribute("channelsJson", JsonUtil.toJson(channels));
        } catch (Exception e) {
            req.setAttribute("channelsList", List.of());
            req.setAttribute("channelsJson", "[]");
        }

        req.setAttribute("pageTitle",    "Sản Phẩm Theo Kênh");
        req.setAttribute("pageSubtitle", "Quản lý sản phẩm kinh doanh trên các sàn thương mại điện tử");
        req.setAttribute("currentPage",  "sales-channel-products");

        req.setAttribute("contentPage", "/WEB-INF/views/sales/channel-products.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/sales-layout.jsp")
           .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("updateBufferStock".equals(action)) {
            String channelIdStr = req.getParameter("channelId");
            String bufferStockStr = req.getParameter("bufferStock");

            if (isNullOrEmpty(channelIdStr) || isNullOrEmpty(bufferStockStr)) {
                writeJson(resp, "{\"success\":false,\"message\":\"Missing parameters\"}");
                return;
            }

            try {
                int channelId = Integer.parseInt(channelIdStr);
                double bufferStock = Double.parseDouble(bufferStockStr);
                boolean updated = channelService.updateBufferStock(channelId, bufferStock);
                if (updated) {
                    writeJson(resp, "{\"success\":true}");
                } else {
                    writeJson(resp, "{\"success\":false,\"message\":\"Channel not found\"}");
                }
            } catch (Exception e) {
                writeJson(resp, "{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
            }
        } else {
            writeJson(resp, "{\"success\":false,\"message\":\"Unknown action\"}");
        }
    }
}
