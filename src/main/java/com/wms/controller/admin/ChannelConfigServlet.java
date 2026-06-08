package com.wms.controller.admin;

import com.lazada.lazop.api.LazopClient;
import com.lazada.lazop.api.LazopRequest;
import com.lazada.lazop.api.LazopResponse;
import com.wms.controller.BaseController;
import com.wms.dao.ChannelDAO;
import com.wms.model.Channel;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * ChannelConfigServlet — Handles UC-SYS03 (Channel Create/Edit) configuration screen.
 *
 * Implements standard MVC flow to manage basic channel details, API credentials,
 * connection tests, and sync parameters.
 *
 * Routing via pathInfo:
 *   GET  /admin/channels/create        → empty form (create mode)
 *   POST /admin/channels/create        → save new channel
 *   GET  /admin/channels/create?id=5   → pre-populated form (edit mode)
 *   POST /admin/channels/create?id=5   → update existing channel
 */
public class ChannelConfigServlet extends BaseController {

    private final ChannelDAO channelDAO = new ChannelDAO();

    // ========================================================================
    // GET — show create or edit form
    // ========================================================================

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String channelIdStr = req.getParameter("id");

        if (channelIdStr != null && !channelIdStr.trim().isEmpty()) {
            int channelId = parseId(channelIdStr);
            Channel channel = channelDAO.findById(channelId);
            if (channel != null) {
                req.setAttribute("channel", channel);
                req.setAttribute("isEditMode", true);
                req.setAttribute("pageTitle", "Chỉnh sửa Kênh Kết Nối");
                req.setAttribute("pageSubtitle", "Cập nhật cấu hình kênh: " + channel.getChannelName());
            } else {
                req.setAttribute("isEditMode", false);
                req.setAttribute("pageTitle", "Thêm Kênh Kết Nối Mới");
                req.setAttribute("pageSubtitle", "Thiết lập kết nối API, Xác thực và Đồng bộ tồn kho với Sàn TMĐT");
            }
        } else {
            req.setAttribute("isEditMode", false);
            req.setAttribute("pageTitle", "Thêm Kênh Kết Nối Mới");
            req.setAttribute("pageSubtitle", "Thiết lập kết nối API, Xác thực và Đồng bộ tồn kho với Sàn TMĐT");
        }

        req.setAttribute("currentPage", "admin-channels-create");
        req.setAttribute("contentPage", "/WEB-INF/views/admin/channel-create.jsp");
        req.getRequestDispatcher("/WEB-INF/views/layout/admin-layout.jsp").forward(req, resp);
    }

    // ========================================================================
    // POST — save new channel OR update existing channel
    // ========================================================================

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if ("testConnection".equals(action)) {
            handleTestConnection(req, resp);
            return;
        }

        String channelIdStr = req.getParameter("channelId");
        boolean isEdit = channelIdStr != null && !channelIdStr.trim().isEmpty();
        int channelId = isEdit ? parseId(channelIdStr) : -1;

        if (isEdit && channelId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=error&message=invalid_channel_id");
            return;
        }

        // Bind form fields to Channel model
        Channel channel = bindChannel(req, isEdit, channelId);

        boolean success;
        if (isEdit) {
            success = channelDAO.update(channel);
        } else {
            success = channelDAO.insert(channel);
        }

        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/channels?status=" + (isEdit ? "updated" : "success"));
        } else {
            req.setAttribute("channel", channel);
            req.setAttribute("errorMessage", "Không thể lưu cấu hình kênh bán hàng vào cơ sở dữ liệu.");
            doGet(req, resp);
        }
    }

    // ========================================================================
    // AJAX — test API connection
    // ========================================================================

    private static final String LAZADA_AUTH_URL = "https://auth.lazada.com/rest";

    private void handleTestConnection(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String apiKey = req.getParameter("apiKey");
        String appSecret = req.getParameter("appSecret");
        String authorizationCode = req.getParameter("authCode");

        if (apiKey == null || apiKey.trim().isEmpty() || appSecret == null || appSecret.trim().isEmpty()) {
            writeJson(resp, "{\"success\":false,\"message\":\"App Key và App Secret không được để trống!\"}");
            return;
        }

        try {
            LazopClient client = new LazopClient(LAZADA_AUTH_URL, apiKey.trim(), appSecret.trim());
            LazopRequest request = new LazopRequest();
            request.setApiName("/auth/token/create");
            request.setHttpMethod("POST");
            request.addApiParameter("code", authorizationCode != null ? authorizationCode.trim() : "");
            LazopResponse response = client.execute(request, null);
            String body = response.getBody();

            if (body == null || body.trim().isEmpty()) {
                writeJson(resp, "{\"success\":false,\"message\":\"Server Lazada không phản hồi. Vui lòng thử lại sau!\"}");
                return;
            }

            if (body.contains("\"code\":\"ISV\"")) {
                writeJson(resp, "{\"success\":false,\"message\":\"Lỗi hệ thống: thiếu tham số bắt buộc hoặc App Key không đúng!\"}");
                return;
            }
            if (body.contains("\"code\":\"IncompleteSignature\"")) {
                writeJson(resp, "{\"success\":false,\"message\":\"App Secret hoặc App Key không chính xác. Chữ ký bảo mật bị từ chối!\"}");
                return;
            }
            if (body.contains("\"code\":\"InvalidCode\"")) {
                writeJson(resp, "{\"success\":false,\"message\":\"Authorization Code không hợp lệ, đã được sử dụng hoặc đã hết hạn sau 30 phút!\"}");
                return;
            }
            if (body.contains("\"code\":\"InvalidParameter\"")) {
                writeJson(resp, "{\"success\":false,\"message\":\"Tham số không hợp lệ. Vui lòng kiểm tra App Key, App Secret và Authorization Code!\"}");
                return;
            }
            if (body.contains("\"code\":\"MissingParameter\"")) {
                writeJson(resp, "{\"success\":false,\"message\":\"Thiếu tham số bắt buộc (Authorization Code). Vui lòng nhập mã ủy quyền từ Lazada!\"}");
                return;
            }
            if (body.contains("\"access_token\"")) {
                com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                com.fasterxml.jackson.databind.JsonNode root = mapper.readTree(body);
                String accessToken = root.path("access_token").asText();
                String refreshToken = root.path("refresh_token").asText();

                writeJson(resp, "{\"success\":true,\"message\":\"Kết nối thử nghiệm thành công! Vui lòng lưu cấu hình để hoàn tất.\","
                        + "\"accessToken\":\"" + escapeJson(accessToken) + "\","
                        + "\"refreshToken\":\"" + escapeJson(refreshToken) + "\"}");
                return;
            }

            writeJson(resp, "{\"success\":false,\"message\":\"Phản hồi không xác định từ Lazada. Vui lòng thử lại!\"}");

        } catch (Exception e) {
            writeJson(resp, "{\"success\":false,\"message\":\"Lỗi kết nối: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    // ========================================================================
    // Bind HTTP parameters to Channel model
    // ========================================================================

    private Channel bindChannel(HttpServletRequest req, boolean isEdit, int channelId) {
        Channel channel = new Channel();

        if (isEdit) {
            channel.setChannelId(channelId);
            Channel existing = channelDAO.findById(channelId);
            if (existing != null) {
                channel.setBufferStock(existing.getBufferStock());
                channel.setAccessToken(existing.getAccessToken());
                channel.setRefreshToken(existing.getRefreshToken());
                channel.setAppSecret(existing.getAppSecret());
            }
        }

        channel.setPlatform(req.getParameter("platform"));
        channel.setChannelName(req.getParameter("channelName"));
        channel.setApiUrl(req.getParameter("apiUrl"));

        String activeStr = req.getParameter("isActive");
        channel.setActive("true".equals(activeStr) || "1".equals(activeStr));

        channel.setApiKey(req.getParameter("apiKey"));
        
        String appSecretParam = req.getParameter("appSecret");
        if (appSecretParam != null && !appSecretParam.trim().isEmpty()) {
            channel.setAppSecret(appSecretParam);
        }

        channel.setWebhookSecret(req.getParameter("webhookSecret"));

        String accessTokenParam = req.getParameter("accessToken");
        if (accessTokenParam != null && !accessTokenParam.trim().isEmpty()) {
            channel.setAccessToken(accessTokenParam);
        }

        String refreshTokenParam = req.getParameter("refreshToken");
        if (refreshTokenParam != null && !refreshTokenParam.trim().isEmpty()) {
            channel.setRefreshToken(refreshTokenParam);
        }

        if (!isEdit) {
            channel.setBufferStock(5.0);
        }

        return channel;
    }

    private int parseId(String idStr) {
        try {
            return Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            return -1;
        }
    }
}
