package com.wms.service.auth;

import com.wms.dao.UserDAO;
import com.wms.model.Channel;
import com.wms.model.User;
import org.mindrot.jbcrypt.BCrypt;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.sql.SQLException;
import java.util.Map;
import java.util.Optional;
import java.util.TreeMap;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * AuthService — Business logic for authentication and API integrations.
 *
 * TEAM RULE: Servlets call Services. Services call DAOs. DAOs never call Services.
 */
public class AuthService {

    private static final Logger LOGGER = Logger.getLogger(AuthService.class.getName());

    private final UserDAO userDAO = new UserDAO();

    /**
     * Authenticates a user with username + plain-text password.
     *
     * @return the User if credentials are valid and account is active; null otherwise.
     */
    public User authenticate(String username, String rawPassword) {
        try {
            Optional<User> optional = userDAO.findByUsername(username);
            if (optional.isEmpty()) {
                LOGGER.info("Login failed: user not found — " + username);
                return null;
            }

            User user = optional.get();

            if (!BCrypt.checkpw(rawPassword, user.getPasswordHash())) {
                LOGGER.info("Login failed: wrong password for — " + username);
                return null;
            }

            user.setPasswordHash(null);
            LOGGER.info("Login success: " + username + " [" + user.getRole() + "]");
            return user;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error during authentication.", e);
            return null;
        }
    }

    // ========================================================================
    // LAZADA OAUTH — PER-CHANNEL, NO HARDCODED CONSTANTS
    // ========================================================================

    /**
     * Exchanges an authorization code for an access token using Lazada OAuth 2.0.
     * Credentials (App Key, App Secret, API base URL) are read from the provided
     * Channel object, enabling multi-channel support without any hardcoding.
     *
     * Signature algorithm: HMAC-SHA256 (Lazada requirement)
     * Parameter ordering: lexicographical (dictionary) sort before hashing
     *
     * @param channel  The Channel whose apiKey, appSecret, and apiUrl are used
     *                 to build and sign the request.
     * @param authCode The authorization code received from Lazada.
     * @return The raw JSON response string from the Lazada API.
     */
    public String getAccessToken(Channel channel, String authCode) {
        validateChannel(channel);

        String baseUrl = normalizeBaseUrl(channel.getApiUrl());
        String apiPath  = "/auth/token/create";

        // Step 1: Build params TreeMap (auto-sorted lexicographically by Lazada spec)
        TreeMap<String, String> params = new TreeMap<>();
        params.put("app_key",     channel.getApiKey());
        params.put("code",        authCode);
        params.put("sign_method", "sha256");
        params.put("timestamp",   String.valueOf(System.currentTimeMillis()));

        // Step 2: Generate HMAC-SHA256 signature
        String signature = generateHmacSha256Signature(apiPath, params, channel.getAppSecret());
        params.put("sign", signature);

        // Step 3: POST to https://{baseUrl}/auth/token/create
        String urlString = baseUrl + apiPath;
        return postFormUrlEncoded(urlString, params);
    }

    /**
     * Refreshes an expired Lazada access token using the channel's stored refresh token.
     *
     * @param channel The Channel whose apiKey, appSecret, apiUrl, and refreshToken
     *                 are used to sign and send the refresh request.
     * @return The raw JSON response string from the Lazada API.
     */
    public String refreshAccessToken(Channel channel) {
        validateChannel(channel);

        if (channel.getRefreshToken() == null || channel.getRefreshToken().trim().isEmpty()) {
            throw new IllegalArgumentException("channel.refreshToken must not be null or empty");
        }

        String baseUrl = normalizeBaseUrl(channel.getApiUrl());
        String apiPath  = "/auth/token/refresh";

        TreeMap<String, String> params = new TreeMap<>();
        params.put("app_key",      channel.getApiKey());
        params.put("grant_type",   "refresh_token");
        params.put("refresh_token", channel.getRefreshToken());
        params.put("sign_method",  "sha256");
        params.put("timestamp",    String.valueOf(System.currentTimeMillis()));

        String signature = generateHmacSha256Signature(apiPath, params, channel.getAppSecret());
        params.put("sign", signature);

        String urlString = baseUrl + apiPath;
        return postFormUrlEncoded(urlString, params);
    }

    // ========================================================================
    // HMAC-SHA256 SIGNATURE — INLINE, VANILLA JAVA
    // ========================================================================

    /**
     * Generates a Lazada API request signature using HMAC-SHA256.
     *
     * Algorithm (per Lazada Open Platform spec):
     *   1. Sort all parameters lexicographically by key (TreeMap guarantees this).
     *   2. Concatenate: apiPath + key1 + value1 + key2 + value2 + ...
     *   3. Compute HMAC-SHA256 of the concatenated string using appSecret as key.
     *   4. Return uppercase Hex string.
     *
     * @param apiPath   The API endpoint path (e.g., "/auth/token/create").
     * @param params    Sorted map of request parameters (must include app_key, timestamp, sign_method, code).
     * @param appSecret The channel's appSecret key.
     * @return The signature as an uppercase Hex string.
     */
    private String generateHmacSha256Signature(String apiPath, TreeMap<String, String> params, String appSecret) {
        if (apiPath == null || params == null || appSecret == null) {
            throw new IllegalArgumentException("apiPath, params, and appSecret must not be null");
        }

        // Step 1: Build signing string — apiPath followed by each key+value pair
        //         in lexicographical order (TreeMap guarantees sorted iteration)
        StringBuilder signingString = new StringBuilder();
        signingString.append(apiPath);
        for (Map.Entry<String, String> entry : params.entrySet()) {
            signingString.append(entry.getKey()).append(entry.getValue());
        }

        // Step 2: Compute HMAC-SHA256
        try {
            SecretKeySpec secretKeySpec = new SecretKeySpec(
                    appSecret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(secretKeySpec);
            byte[] hmacBytes = mac.doFinal(signingString.toString().getBytes(StandardCharsets.UTF_8));

            // Step 3: Convert to uppercase Hex
            return bytesToHex(hmacBytes);
        } catch (NoSuchAlgorithmException | InvalidKeyException e) {
            throw new RuntimeException("HMAC-SHA256 signature generation failed", e);
        }
    }

    /**
     * Converts a byte array to an uppercase hexadecimal string.
     */
    private String bytesToHex(byte[] bytes) {
        StringBuilder hex = new StringBuilder();
        for (byte b : bytes) {
            int unsigned = 0xff & b;
            String h = Integer.toHexString(unsigned);
            if (h.length() == 1) {
                hex.append('0');
            }
            hex.append(h);
        }
        return hex.toString().toUpperCase();
    }

    // ========================================================================
    // HTTP POST HELPER — application/x-www-form-urlencoded
    // ========================================================================

    /**
     * Sends a POST request with application/x-www-form-urlencoded body.
     *
     * @param urlString The full URL to POST to.
     * @param params    The form parameters (already URL-encoded keys; values will be encoded).
     * @return The raw JSON response body from the server.
     */
    private String postFormUrlEncoded(String urlString, TreeMap<String, String> params) {
        HttpURLConnection conn = null;
        try {
            URL url = new URL(urlString);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setDoInput(true);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
            conn.setConnectTimeout(10_000);
            conn.setReadTimeout(15_000);

            // Build and write request body
            String body = buildFormUrlEncodedBody(params);
            try (OutputStream os = conn.getOutputStream()) {
                os.write(body.getBytes(StandardCharsets.UTF_8));
                os.flush();
            }

            int responseCode = conn.getResponseCode();
            LOGGER.info("LazadaAuth POST [" + urlString + "] => HTTP " + responseCode);

            BufferedReader reader = new BufferedReader(new InputStreamReader(
                    responseCode >= 200 && responseCode < 300
                            ? conn.getInputStream()
                            : conn.getErrorStream(),
                    StandardCharsets.UTF_8));

            StringBuilder response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line.trim());
            }
            reader.close();

            String jsonResponse = response.toString();
            LOGGER.info("LazadaAuth Response: " + jsonResponse);
            return jsonResponse;

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lazada API communication error: " + urlString, e);
            throw new RuntimeException("Lazada API communication error", e);
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }

    /**
     * Builds an application/x-www-form-urlencoded request body string.
     */
    private String buildFormUrlEncodedBody(TreeMap<String, String> params) {
        StringBuilder body = new StringBuilder();
        for (Map.Entry<String, String> param : params.entrySet()) {
            if (body.length() > 0) {
                body.append('&');
            }
            body.append(URLEncoder.encode(param.getKey(), StandardCharsets.UTF_8));
            body.append('=');
            body.append(URLEncoder.encode(param.getValue(), StandardCharsets.UTF_8));
        }
        return body.toString();
    }

    // ========================================================================
    // VALIDATION HELPERS
    // ========================================================================

    private void validateChannel(Channel channel) {
        if (channel == null) {
            throw new IllegalArgumentException("channel must not be null");
        }
        if (channel.getApiKey() == null || channel.getApiKey().trim().isEmpty()) {
            throw new IllegalArgumentException("channel.apiKey must not be null or empty");
        }
        if (channel.getAppSecret() == null || channel.getAppSecret().trim().isEmpty()) {
            throw new IllegalArgumentException("channel.appSecret must not be null or empty");
        }
    }

    private String normalizeBaseUrl(String apiUrl) {
        if (apiUrl == null || apiUrl.trim().isEmpty()) {
            return "https://auth.lazada.com";
        }
        String url = apiUrl.trim();
        if (url.endsWith("/")) {
            url = url.substring(0, url.length() - 1);
        }
        return url;
    }

    // ========================================================================
    // UTILITY
    // ========================================================================

    /**
     * Hashes a raw password using BCrypt (cost factor 12).
     */
    public static String hashPassword(String rawPassword) {
        return BCrypt.hashpw(rawPassword, BCrypt.gensalt(12));
    }
}
