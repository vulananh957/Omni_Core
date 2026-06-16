package com.wms.service.lazada;

import com.wms.dao.ChannelDAO;
import com.wms.model.Channel;
import com.wms.service.auth.AuthService;
import com.wms.util.AppConstants;
import com.wms.util.LazadaAPIUtil;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.TreeMap;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LazadaHttpClient — low-level HTTP helper for Lazada Open Platform APIs.
 *
 * Responsibilities:
 *   1. Build HMAC-SHA256 signed requests from per-channel credentials
 *      (apiKey, appSecret, apiUrl, accessToken).
 *   2. Execute GET or POST form-urlencoded calls and return raw JSON.
 *   3. Detect expired access tokens (HTTP code, response "code":"104"
 *      or message contains "expired_access_token") and transparently
 *      refresh via AuthService.refreshAccessToken then retry ONCE.
 *   4. Persist the new tokens back to the {@code channels} table so the
 *      next call does not re-trigger refresh.
 *
 * All higher-level services (LazadaOrderService, LazadaProductService,
 * LazadaFulfillmentService, etc.) must route calls through this client
 * instead of touching {@link java.net.HttpURLConnection} directly.
 */
public class LazadaHttpClient {

    private static final Logger LOGGER = Logger.getLogger(LazadaHttpClient.class.getName());
    private static final ObjectMapper MAPPER = new ObjectMapper();

    private static final int CONNECT_TIMEOUT_MS = 10_000;
    private static final int READ_TIMEOUT_MS    = 20_000;

    /** Lazada returns this code when the access token has expired. */
    private static final String EXPIRED_TOKEN_CODE = "104";

    private final AuthService authService = new AuthService();
    private final ChannelDAO  channelDAO  = new ChannelDAO();

    // ──────────────────────────────────────────────────────────
    // GET
    // ──────────────────────────────────────────────────────────

    /**
     * Executes an authenticated GET against {@code channel.apiUrl + apiPath}.
     * Automatically refreshes the access token once if expired.
     *
     * @param channel  the channel providing credentials
     * @param apiPath  e.g. "/orders/get"
     * @param params   business parameters (will be merged with auth params)
     * @return raw JSON response body
     */
    public String executeGet(String apiPath, Map<String, String> params, Channel channel) {
        return executeWithRefresh(channel, apiPath, params, "GET", null);
    }

    // ──────────────────────────────────────────────────────────
    // POST
    // ──────────────────────────────────────────────────────────

    /**
     * Executes an authenticated POST (form-urlencoded) against the channel API.
     *
     * @param channel  the channel providing credentials
     * @param apiPath  e.g. "/product/create"
     * @param params   business parameters
     * @param body     optional raw body override; if null the params are sent
     *                 as application/x-www-form-urlencoded
     * @return raw JSON response body
     */
    public String executePost(String apiPath, Map<String, String> params,
                              Channel channel, String body) {
        return executeWithRefresh(channel, apiPath, params, "POST", body);
    }

    /** Convenience overload: POST with params as form body. */
    public String executePost(String apiPath, Map<String, String> params, Channel channel) {
        return executeWithRefresh(channel, apiPath, params, "POST", null);
    }

    // ──────────────────────────────────────────────────────────
    // Core: sign + send + detect expired token + retry
    // ──────────────────────────────────────────────────────────

    private String executeWithRefresh(Channel channel, String apiPath,
                                      Map<String, String> params, String httpMethod,
                                      String rawBody) {
        if (channel == null) {
            throw new IllegalArgumentException("channel must not be null");
        }
        if (channel.getAccessToken() == null || channel.getAccessToken().trim().isEmpty()) {
            throw new IllegalArgumentException(
                    "channel.accessToken must not be empty — re-authorize the channel first");
        }
        if (channel.getApiKey() == null || channel.getAppSecret() == null) {
            throw new IllegalArgumentException("channel.apiKey/appSecret must not be null");
        }

        // 1) Try with current access token
        String response = doCall(channel, apiPath, params, httpMethod, rawBody);
        if (response == null) {
            throw new RuntimeException("Empty response from Lazada " + apiPath);
        }

        // 2) Inspect for expired token and refresh + retry ONCE if so
        if (isExpiredTokenResponse(response)) {
            LOGGER.warning("Lazada access token expired for channel "
                    + channel.getChannelId() + " — refreshing and retrying " + apiPath);
            try {
                String refreshJson = authService.refreshAccessToken(channel);
                JsonNode root = MAPPER.readTree(refreshJson);
                String newAccess  = root.path("access_token").asText("");
                String newRefresh = root.path("refresh_token").asText("");
                if (newAccess.isEmpty()) {
                    throw new RuntimeException(
                            "Refresh response did not contain access_token: " + refreshJson);
                }
                // Persist back to DB so other schedulers pick up the new token
                channelDAO.updateLazadaTokens(channel.getChannelId(), newAccess, newRefresh);
                channel.setAccessToken(newAccess);
                channel.setRefreshToken(newRefresh);
                // Retry the original call exactly once
                response = doCall(channel, apiPath, params, httpMethod, rawBody);
            } catch (Exception e) {
                throw new RuntimeException(
                        "Failed to refresh Lazada access token for channel "
                                + channel.getChannelId() + ": " + e.getMessage(), e);
            }
        }
        return response;
    }

    private boolean isExpiredTokenResponse(String response) {
        if (response == null || response.isEmpty()) return false;
        try {
            JsonNode root = MAPPER.readTree(response);
            String code    = root.path("code").asText("");
            String message = root.path("message").asText("");
            if (EXPIRED_TOKEN_CODE.equals(code)) return true;
            String lcMsg = message.toLowerCase();
            return lcMsg.contains("expired") || lcMsg.contains("invalid access_token")
                    || lcMsg.contains("access_token expired");
        } catch (Exception e) {
            // Not JSON or not parseable — assume OK and let caller decide
            return false;
        }
    }

    // ──────────────────────────────────────────────────────────
    // Low-level: build signed request and execute
    // ──────────────────────────────────────────────────────────

    private String doCall(Channel channel, String apiPath, Map<String, String> params,
                          String httpMethod, String rawBody) {
        // Lazada requires all common params in a sorted map; build a new tree
        // so we don't mutate the caller's map.
        TreeMap<String, String> signed = new TreeMap<>();
        if (params != null) {
            signed.putAll(params);
        }
        signed.put("app_key",     channel.getApiKey());
        signed.put("timestamp",   String.valueOf(System.currentTimeMillis()));
        signed.put("sign_method", AppConstants.SIGN_METHOD);
        signed.put("access_token", channel.getAccessToken());

        String signature = LazadaAPIUtil.generateSignature(
                apiPath, signed, channel.getAppSecret());
        signed.put("sign", signature);

        String apiBaseUrl = channel.getApiUrl();
        if (apiBaseUrl == null || apiBaseUrl.trim().isEmpty()) {
            apiBaseUrl = AppConstants.LAZADA_API_URL;
        }
        if (apiBaseUrl.endsWith("/")) {
            apiBaseUrl = apiBaseUrl.substring(0, apiBaseUrl.length() - 1);
        }

        HttpURLConnection conn = null;
        try {
            URL url;
            String body;
            if ("GET".equalsIgnoreCase(httpMethod)) {
                url = new URL(apiBaseUrl + apiPath + "?" + buildQueryString(signed));
                conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("GET");
            } else {
                url = new URL(apiBaseUrl + apiPath);
                conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("POST");
                conn.setDoOutput(true);
                conn.setDoInput(true);
                conn.setRequestProperty("Content-Type",
                        "application/x-www-form-urlencoded; charset=UTF-8");
                body = (rawBody != null) ? rawBody : buildFormUrlEncodedBody(signed);
                try (OutputStream os = conn.getOutputStream()) {
                    os.write(body.getBytes(StandardCharsets.UTF_8));
                    os.flush();
                }
            }
            conn.setConnectTimeout(CONNECT_TIMEOUT_MS);
            conn.setReadTimeout(READ_TIMEOUT_MS);
            conn.setRequestProperty("Accept", "application/json");

            int code = conn.getResponseCode();
            LOGGER.info("Lazada " + httpMethod + " " + apiPath + " => HTTP " + code);

            try (BufferedReader br = new BufferedReader(new InputStreamReader(
                    code >= 200 && code < 300
                            ? conn.getInputStream()
                            : conn.getErrorStream(),
                    StandardCharsets.UTF_8))) {
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) sb.append(line.trim());
                return sb.toString();
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "LazadaHttpClient: " + httpMethod + " " + apiPath + " failed", e);
            throw new RuntimeException("Lazada API call failed: " + apiPath, e);
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    private String buildQueryString(Map<String, String> params) {
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, String> e : params.entrySet()) {
            if (sb.length() > 0) sb.append('&');
            sb.append(URLEncoder.encode(e.getKey(), StandardCharsets.UTF_8));
            sb.append('=');
            sb.append(URLEncoder.encode(e.getValue(), StandardCharsets.UTF_8));
        }
        return sb.toString();
    }

    private String buildFormUrlEncodedBody(Map<String, String> params) {
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, String> e : params.entrySet()) {
            if (sb.length() > 0) sb.append('&');
            sb.append(URLEncoder.encode(e.getKey(), StandardCharsets.UTF_8));
            sb.append('=');
            sb.append(URLEncoder.encode(e.getValue(), StandardCharsets.UTF_8));
        }
        return sb.toString();
    }
}
