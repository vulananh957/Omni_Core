package com.wms.controller.sales;

import com.wms.controller.BaseController;
import com.wms.dao.ChannelDAO;
import com.wms.dao.LazadaCategoryDAO;
import com.wms.model.Channel;
import com.wms.service.lazada.LazadaCategorySyncService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.logging.Logger;

/**
 * LazadaCategorySyncServlet — admin/manager action to mirror Lazada's
 * /category/tree/get into the local DB. Mapped at /sales/lazada-categories/sync.
 */
@WebServlet(name = "LazadaCategorySyncServlet", urlPatterns = {"/sales/lazada-categories/sync"})
public class LazadaCategorySyncServlet extends BaseController {

    private static final Logger LOGGER = Logger.getLogger(LazadaCategorySyncServlet.class.getName());
    private final LazadaCategorySyncService syncService = new LazadaCategorySyncService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int channelId;
        try {
            channelId = Integer.parseInt(req.getParameter("channelId"));
        } catch (Exception e) {
            writeJson(resp, "{\"success\":false,\"message\":\"channelId required\"}");
            return;
        }
        Channel ch = new ChannelDAO().findById(channelId);
        if (ch == null) {
            writeJson(resp, "{\"success\":false,\"message\":\"Channel not found\"}");
            return;
        }
        LazadaCategorySyncService.SyncResult r = syncService.syncCategories(ch);
        LOGGER.info("LazadaCategorySyncServlet: channel=" + channelId
                + " success=" + r.success + " count=" + r.count + " msg=" + r.message);
        writeJson(resp, "{\"success\":" + r.success
                + ",\"count\":" + r.count
                + ",\"message\":\"" + r.message.replace("\"", "'") + "\"}");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Return count of synced leaf categories for each channel
        int channelId;
        try {
            channelId = Integer.parseInt(req.getParameter("channelId"));
        } catch (Exception e) {
            writeJson(resp, "{\"success\":false,\"message\":\"channelId required\"}");
            return;
        }
        LazadaCategoryDAO dao = new LazadaCategoryDAO();
        int total = dao.count(channelId);
        int leaves = dao.findLeaves(channelId).size();
        writeJson(resp, "{\"success\":true,\"total\":" + total + ",\"leaves\":" + leaves + "}");
    }
}