package com.wms.controller.admin;

import com.wms.controller.BaseController;
import com.wms.dao.ChannelDAO;
import com.wms.model.Channel;
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

    private final ChannelDAO channelDAO = new ChannelDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String pathInfo = req.getPathInfo();

        // DELETE action
        if (pathInfo != null && pathInfo.startsWith("/delete/")) {
            handleDelete(req, resp, pathInfo);
            return;
        }

        // OAUTH RE-AUTHORIZE action
        if (pathInfo != null && pathInfo.startsWith("/authorize/")) {
            handleAuthorizeRedirect(req, resp, pathInfo);
            return;
        }

        // EDIT action — forward to channel-create form
        if (pathInfo != null && pathInfo.startsWith("/edit/")) {
            handleEditForm(req, resp, pathInfo);
            return;
        }

        // LIST action — with optional keyword search
        handleList(req, resp);
    }

    // ========================================================================
    // LIST — server-side keyword search via DAO
    // ========================================================================

    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        List<Channel> channels = channelDAO.findAll(keyword);
        req.setAttribute("channelsList", channels);
        req.setAttribute("searchKeyword", keyword);

        req.setAttribute("pageTitle", "Cấu hình Kênh Kết Nối");
        req.setAttribute("pageSubtitle", "Quản lý danh sách các kênh thương mại điện tử đa kênh Lazada, Shopee, TikTok Shop");
        req.setAttribute("currentPage", "admin-channels");

        req.setAttribute("contentPage", "/WEB-INF/views/admin/channels-configuration.jsp");
        req.getRequestDispatcher("/WEB-INF/views/layout/admin-layout.jsp").forward(req, resp);
    }

    // ========================================================================
    // EDIT form — load channel by id and forward to channel-create.jsp
    // ========================================================================

    private void handleEditForm(HttpServletRequest req, HttpServletResponse resp, String pathInfo)
            throws ServletException, IOException {
        int channelId = parseChannelId(pathInfo);
        if (channelId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=invalid_channel_id");
            return;
        }

        Channel channel = channelDAO.findById(channelId);
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

    // ========================================================================
    // DELETE
    // ========================================================================

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, String pathInfo)
            throws IOException {
        int channelId = parseChannelId(pathInfo);
        if (channelId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=invalid_channel_id");
            return;
        }

        Channel channel = channelDAO.findById(channelId);
        if (channel == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=channel_not_found");
            return;
        }

        // Re-fetch with id set so DAO can delete
        channel.setChannelId(channelId);
        boolean deleted = channelDAO.delete(channelId);

        if (deleted) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=deleted");
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=delete_failed");
        }
    }

    // ========================================================================
    // POST — delete via form submission
    // ========================================================================

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

    // ========================================================================
    // DELETE (POST handler)
    // ========================================================================

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

        boolean deleted = channelDAO.delete(channelId);
        if (deleted) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=deleted");
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=delete_failed");
        }
    }

    // ========================================================================
    // OAUTH RE-AUTHORIZE — store channelId in session and redirect to Lazada
    // ========================================================================

    private void handleAuthorizeRedirect(HttpServletRequest req, HttpServletResponse resp, String pathInfo)
            throws IOException {
        int channelId = parseChannelId(pathInfo);
        if (channelId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=invalid_channel_id");
            return;
        }

        Channel channel = channelDAO.findById(channelId);
        if (channel == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=channel_not_found");
            return;
        }

        HttpSession session = req.getSession(true);
        session.setAttribute("pending_channel_id", String.valueOf(channelId));

        String redirectUri;
        String ngrokUrl = getNgrokPublicUrl();
        String contextPath = req.getContextPath();
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

    // ========================================================================
    // Helpers
    // ========================================================================

    private String getNgrokPublicUrl() {
        try {
            java.net.URL url = new java.net.URL("http://localhost:4040/api/tunnels");
            java.net.HttpURLConnection conn = (java.net.HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(1000);
            conn.setReadTimeout(1000);
            if (conn.getResponseCode() == 200) {
                java.io.BufferedReader in = new java.io.BufferedReader(
                        new java.io.InputStreamReader(conn.getInputStream(), java.nio.charset.StandardCharsets.UTF_8));
                StringBuilder content = new StringBuilder();
                String line;
                while ((line = in.readLine()) != null) {
                    content.append(line);
                }
                in.close();
                String json = content.toString();
                com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                com.fasterxml.jackson.databind.JsonNode root = mapper.readTree(json);
                com.fasterxml.jackson.databind.JsonNode tunnelsNode = root.path("tunnels");
                if (tunnelsNode.isArray() && tunnelsNode.size() > 0) {
                    for (com.fasterxml.jackson.databind.JsonNode tunnel : tunnelsNode) {
                        String publicUrl = tunnel.path("public_url").asText();
                        if (publicUrl != null && (publicUrl.startsWith("https://") || publicUrl.startsWith("http://"))) {
                            return publicUrl;
                        }
                    }
                }
            }
        } catch (Exception e) {
            // Ignore, ngrok not running or failed to fetch
        }
        return null;
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
