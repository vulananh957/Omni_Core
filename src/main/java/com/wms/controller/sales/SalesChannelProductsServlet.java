package com.wms.controller.sales;

import com.wms.controller.BaseController;
import com.wms.dao.ChannelDAO;
import com.wms.model.Channel;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * SalesChannelProductsServlet — Handles the "Sản phẩm theo kênh" page for Sales Staff.
 *
 * Maps to /sales/channel-products.
 */
public class SalesChannelProductsServlet extends BaseController {

    private final ChannelDAO channelDAO = new ChannelDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Query active channels list for the new Channel Management tab
        List<Channel> channels = channelDAO.findAll();
        req.setAttribute("channelsList", channels);

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Sản Phẩm Theo Kênh");
        req.setAttribute("pageSubtitle", "Quản lý sản phẩm kinh doanh trên các sàn thương mại điện tử");
        req.setAttribute("currentPage",  "sales-channel-products");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/sales/channel-products.jsp");

        // Forward to the layout shell
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

                Channel channel = channelDAO.findById(channelId);
                if (channel == null) {
                    writeJson(resp, "{\"success\":false,\"message\":\"Channel not found\"}");
                    return;
                }

                channel.setBufferStock(bufferStock);
                boolean updated = channelDAO.update(channel);

                if (updated) {
                    writeJson(resp, "{\"success\":true}");
                } else {
                    writeJson(resp, "{\"success\":false,\"message\":\"Failed to update database\"}");
                }
            } catch (Exception e) {
                writeJson(resp, "{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
            }
        } else {
            writeJson(resp, "{\"success\":false,\"message\":\"Unknown action\"}");
        }
    }
}
