package com.wms.controller.admin;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.dao.ChannelDAO;
import com.wms.model.Channel;
import com.wms.service.auth.AuthService;
import com.wms.service.sales.ChannelService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LazadaAuthCallbackServlet — Handles the OAuth redirect/callback from Lazada.
 *
 * Exchanges the authorization code for access and refresh tokens,
 * retrieves the correct Channel from DB using the session-stored channelId,
 * and persists the new tokens to the database.
 */
public class LazadaAuthCallbackServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LazadaAuthCallbackServlet.class.getName());

    private final AuthService authService = new AuthService();
    private final ChannelService channelService = new ChannelService();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String code = request.getParameter("code");

        if (code == null || code.trim().isEmpty()) {
            LOGGER.warning("Lazada auth callback received without 'code' parameter.");
            response.sendRedirect(request.getContextPath() + "/admin/channels?status=error&message=missing_code");
            return;
        }

        HttpSession session = request.getSession(false);
        String channelIdStr = request.getParameter("channel_id");
        if (channelIdStr == null && session != null) {
            channelIdStr = (String) session.getAttribute("pending_channel_id");
        }

        if (channelIdStr == null) {
            LOGGER.warning("Lazada auth callback: no channel_id available to identify the channel.");
            response.sendRedirect(request.getContextPath() + "/admin/channels?status=error&message=missing_channel_id");
            return;
        }

        int channelId;
        try {
            channelId = Integer.parseInt(channelIdStr);
        } catch (NumberFormatException e) {
            LOGGER.warning("Lazada auth callback: invalid channel_id: " + channelIdStr);
            response.sendRedirect(request.getContextPath() + "/admin/channels?status=error&message=invalid_channel_id");
            return;
        }

        Channel channel;
        try {
            channel = channelService.findById(channelId);
        } catch (Exception e) {
            LOGGER.warning("Lazada auth callback: channel not found for id: " + channelId);
            response.sendRedirect(request.getContextPath() + "/admin/channels?status=error&message=channel_not_found");
            return;
        }

        if (channel == null) {
            LOGGER.warning("Lazada auth callback: channel not found for id: " + channelId);
            response.sendRedirect(request.getContextPath() + "/admin/channels?status=error&message=channel_not_found");
            return;
        }

        try {
            LOGGER.info("Initiating token exchange for channel '" + channel.getChannelName() + "' (ID: " + channelId + ")");
            String jsonResponse = authService.getAccessToken(channel, code);

            JsonNode rootNode = objectMapper.readTree(jsonResponse);

            if (rootNode.has("code") && !rootNode.has("access_token")) {
                String errorCode = rootNode.path("code").asText();
                String errorMessage = rootNode.path("message").asText();
                LOGGER.severe("Lazada OAuth API error response: [" + errorCode + "] " + errorMessage);
                response.sendRedirect(request.getContextPath() + "/admin/channels?status=error&message=api_error");
                return;
            }

            String accessToken = rootNode.path("access_token").asText();
            String refreshToken = rootNode.path("refresh_token").asText();

            if (accessToken == null || accessToken.isEmpty() || refreshToken == null || refreshToken.isEmpty()) {
                LOGGER.severe("Parsed access_token or refresh_token is empty. Response: " + jsonResponse);
                response.sendRedirect(request.getContextPath() + "/admin/channels?status=error&message=parsing_error");
                return;
            }

            boolean dbUpdated = channelService.updateLazadaTokens(channelId, accessToken, refreshToken);

            if (dbUpdated) {
                LOGGER.info("Tokens successfully saved for channel '" + channel.getChannelName() + "' (ID: " + channelId + ")");
                response.sendRedirect(request.getContextPath() + "/admin/channels?status=success");
            } else {
                LOGGER.severe("Failed to update tokens in the database for channel ID: " + channelId);
                response.sendRedirect(request.getContextPath() + "/admin/channels?status=error&message=db_save_failed");
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error processing Lazada auth callback for channel ID: " + channelId, e);
            response.sendRedirect(request.getContextPath() + "/admin/channels?status=error&message=system_error");
        } finally {
            if (session != null) {
                session.removeAttribute("pending_channel_id");
            }
        }
    }
}
