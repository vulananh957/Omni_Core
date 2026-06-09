package com.wms.controller.admin;

import com.wms.controller.BaseController;
import com.wms.model.Channel;
import com.wms.service.sales.ChannelService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * ChannelListServlet — Handles the "Channels Configuration" list screen.
 *
 * Routing via pathInfo:
 *   GET  /admin/channels          → list all (optional ?keyword= search)
 *   GET  /admin/channels/edit/5   → forward to channel-create with channelId param
 *   GET  /admin/channels/delete/5 → delete and redirect to list
 *   GET  /admin/channels/authorize/5 → store channelId in session and redirect to Lazada OAuth
 */
public class ChannelListServlet extends BaseController {

    private final ChannelService channelService = new ChannelService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String pathInfo = req.getPathInfo();

        if (pathInfo != null && pathInfo.startsWith("/delete/")) {
            handleDelete(req, resp, pathInfo);
            return;
        }

        if (pathInfo != null && pathInfo.startsWith("/authorize/")) {
            handleAuthorizeRedirect(req, resp, pathInfo);
            return;
        }

        if (pathInfo != null && pathInfo.startsWith("/edit/")) {
            handleEditForm(req, resp, pathInfo);
            return;
        }

        handleList(req, resp);
    }

    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        try {
            List<Channel> channels = keyword != null
                ? channelService.findAll(keyword)
                : channelService.findAll();
            req.setAttribute("channelsList", channels);
            req.setAttribute("searchKeyword", keyword);
        } catch (Exception e) {
            req.setAttribute("channelsList", List.of());
        }

        req.setAttribute("pageTitle", "Cấu hình Kênh Kết Nối");
        req.setAttribute("pageSubtitle", "Quản lý danh sách các kênh thương mại điện tử đa kênh Lazada, Shopee, TikTok Shop");
        req.setAttribute("currentPage", "admin-channels");

        req.setAttribute("contentPage", "/WEB-INF/views/admin/channels-configuration.jsp");
        req.getRequestDispatcher("/WEB-INF/views/layout/admin-layout.jsp").forward(req, resp);
    }

    private void handleEditForm(HttpServletRequest req, HttpServletResponse resp, String pathInfo)
            throws ServletException, IOException {
        int channelId = parseChannelId(pathInfo);
        if (channelId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=invalid_channel_id");
            return;
        }

        Channel channel;
        try {
            channel = channelService.findById(channelId);
        } catch (Exception e) {
            channel = null;
        }

        if (channel == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=channel_not_found");
            return;
        }

        req.setAttribute("channel", channel);
        req.setAttribute("isEditMode", true);
        req.setAttribute("pageTitle", "Chỉnh sửa Kênh Kết Nối");
        req.setAttribute("pageSubtitle", "Cập nhật cấu hình kênh: " + channel.getChannelName());
        req.setAttribute("currentPage", "admin-channels");

        req.setAttribute("contentPage", "/WEB-INF/views/admin/channel-create.jsp");
        req.getRequestDispatcher("/WEB-INF/views/layout/admin-layout.jsp").forward(req, resp);
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, String pathInfo)
            throws IOException {
        int channelId = parseChannelId(pathInfo);
        if (channelId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=invalid_channel_id");
            return;
        }

        Channel channel;
        try {
            channel = channelService.findById(channelId);
        } catch (Exception e) {
            channel = null;
        }

        if (channel == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=channel_not_found");
            return;
        }

        try {
            boolean deleted = channelService.deleteChannel(channelId);
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=" + (deleted ? "deleted" : "error&message=delete_failed"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=delete_failed");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            handleDelete(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=invalid_action");
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String idParam = req.getParameter("channelId");
        int channelId = -1;
        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                channelId = Integer.parseInt(idParam.trim());
            } catch (NumberFormatException e) {
                // keep -1
            }
        }

        if (channelId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=invalid_channel_id");
            return;
        }

        try {
            boolean deleted = channelService.deleteChannel(channelId);
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=" + (deleted ? "deleted" : "error&message=delete_failed"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=delete_failed");
        }
    }

    private void handleAuthorizeRedirect(HttpServletRequest req, HttpServletResponse resp, String pathInfo)
            throws IOException {
        int channelId = parseChannelId(pathInfo);
        if (channelId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=invalid_channel_id");
            return;
        }

        Channel channel;
        try {
            channel = channelService.findById(channelId);
        } catch (Exception e) {
            channel = null;
        }

        if (channel == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=channel_not_found");
            return;
        }

        HttpSession session = req.getSession(true);
        session.setAttribute("pending_channel_id", String.valueOf(channelId));

        String ngrokUrl = channelService.getNgrokPublicUrl();
        String contextPath = req.getContextPath();

        String redirectUri;
        if (ngrokUrl != null) {
            if (ngrokUrl.endsWith("/")) {
                ngrokUrl = ngrokUrl.substring(0, ngrokUrl.length() - 1);
            }
            redirectUri = ngrokUrl + contextPath + "/lazada/callback";
        } else {
            String scheme = req.getHeader("X-Forwarded-Proto");
            if (scheme == null || scheme.trim().isEmpty()) {
                scheme = req.getScheme();
            }
            String host = req.getHeader("X-Forwarded-Host");
            if (host == null || host.trim().isEmpty()) {
                String serverName = req.getServerName();
                int serverPort = req.getServerPort();
                if (serverPort == 80 || serverPort == 443) {
                    host = serverName;
                } else {
                    host = serverName + ":" + serverPort;
                }
            }
            redirectUri = scheme + "://" + host + contextPath + "/lazada/callback";
        }

        String oauthUrl = "https://auth.lazada.com/oauth/authorize?response_type=code"
                + "&force_auth=true"
                + "&redirect_uri=" + java.net.URLEncoder.encode(redirectUri, java.nio.charset.StandardCharsets.UTF_8)
                + "&client_id=" + channel.getApiKey();

        resp.sendRedirect(oauthUrl);
    }

    private int parseChannelId(String pathInfo) {
        try {
            String idStr = pathInfo.substring(pathInfo.lastIndexOf('/') + 1);
            return Integer.parseInt(idStr);
        } catch (Exception e) {
            return -1;
        }
    }
}
