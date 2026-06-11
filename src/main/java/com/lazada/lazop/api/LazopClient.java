package com.lazada.lazop.api;

import com.wms.util.LazadaAPIUtil;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.TreeMap;

/**
 * Lazada Open Platform Client SDK Polyfill/Stub.
 * Uses HTTP Connection and LazadaAPIUtil to execute Lazada API requests.
 */
public class LazopClient {
    private final String serverUrl;
    private final String appKey;
    private final String appSecret;

    public LazopClient(String serverUrl, String appKey, String appSecret) {
        this.serverUrl = serverUrl;
        this.appKey = appKey;
        this.appSecret = appSecret;
    }

    public LazopResponse execute(LazopRequest request, String accessToken) throws Exception {
        TreeMap<String, String> params = new TreeMap<>(request.getApiParams());
        params.put("app_key", appKey);
        params.put("timestamp", String.valueOf(System.currentTimeMillis()));
        params.put("sign_method", "sha256");

        if (accessToken != null && !accessToken.isEmpty()) {
            params.put("access_token", accessToken);
        }

        // Generate signature
        String signature = LazadaAPIUtil.generateSignature(request.getApiName(), params, appSecret);
        params.put("sign", signature);

        String fullUrl = serverUrl + request.getApiName();
        HttpURLConnection conn = null;

        try {
            if ("GET".equalsIgnoreCase(request.getHttpMethod())) {
                String queryStr = buildQueryString(params);
                fullUrl += "?" + queryStr;
                URL url = new URL(fullUrl);
                conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("GET");
                conn.setConnectTimeout(10000);
                conn.setReadTimeout(15000);
                conn.setRequestProperty("Accept", "application/json");
            } else {
                URL url = new URL(fullUrl);
                conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("POST");
                conn.setDoOutput(true);
                conn.setConnectTimeout(10000);
                conn.setReadTimeout(15000);
                conn.setRequestProperty("Accept", "application/json");
                conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
                
                String postData = buildQueryString(params);
                try (OutputStream os = conn.getOutputStream()) {
                    byte[] input = postData.getBytes(StandardCharsets.UTF_8);
                    os.write(input, 0, input.length);
                }
            }

            int responseCode = conn.getResponseCode();

            StringBuilder response = new StringBuilder();
            try (BufferedReader br = new BufferedReader(
                    new InputStreamReader(
                            responseCode >= 200 && responseCode < 300 
                                    ? conn.getInputStream() 
                                    : conn.getErrorStream(), 
                            StandardCharsets.UTF_8))) {
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line.trim());
                }
            }

            return new LazopResponse(response.toString());

        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }

    private String buildQueryString(Map<String, String> params) throws Exception {
        StringBuilder query = new StringBuilder();
        for (Map.Entry<String, String> entry : params.entrySet()) {
            if (query.length() > 0) {
                query.append('&');
            }
            query.append(URLEncoder.encode(entry.getKey(), StandardCharsets.UTF_8.name()));
            query.append('=');
            query.append(URLEncoder.encode(entry.getValue(), StandardCharsets.UTF_8.name()));
        }
        return query.toString();
    }
}
