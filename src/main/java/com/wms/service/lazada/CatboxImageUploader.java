package com.wms.service.lazada;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Uploads a binary image to catbox.moe and returns the permanent public HTTPS URL.
 * Catbox is used as a publicly-reachable relay when Lazada cannot reach our
 * internal / ngrok server URLs during /images/migrate.
 *
 * API: POST https://catbox.moe/user/api.php
 *   requrl:  https://catbox.moe/api/upload
 *   filebin: https://catbox.moe/api/upload.php
 *
 * Both accept multipart/form-data with a "fileToUpload" field.
 */
public class CatboxImageUploader {

    private static final Logger LOGGER = Logger.getLogger(CatboxImageUploader.class.getName());

    private static final int CONNECT_TIMEOUT_MS = 15_000;
    private static final int READ_TIMEOUT_MS    = 30_000;

    /**
     * @param imageBytes raw JPEG/PNG/GIF/WebP bytes
     * @param filename   filename for the Content-Disposition header
     * @return the public HTTPS URL on success, or null on failure
     */
    public String upload(byte[] imageBytes, String filename) {
        String[] hosts = {
            "https://catbox.moe/user/api.php",
            "https://litterbox.catbox.moe/resources/internals/api.php"
        };
        for (String uploadUrl : hosts) {
            String result = doUpload(uploadUrl, imageBytes, filename);
            if (result != null) return result;
        }
        return null;
    }

    private String doUpload(String uploadUrl, byte[] imageBytes, String filename) {
        String boundary = "----CatboxBoundary" + System.currentTimeMillis();
        HttpURLConnection conn = null;
        try {
            URL url = new URL(uploadUrl);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setDoInput(true);
            conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);
            conn.setConnectTimeout(CONNECT_TIMEOUT_MS);
            conn.setReadTimeout(READ_TIMEOUT_MS);

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            baos.write(("--" + boundary + "\r\n").getBytes(StandardCharsets.UTF_8));
            baos.write("Content-Disposition: form-data; name=\"reqtype\"\r\n\r\nfileupload\r\n".getBytes(StandardCharsets.UTF_8));
            baos.write(("--" + boundary + "\r\n").getBytes(StandardCharsets.UTF_8));
            baos.write(("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\""
                    + filename + "\"\r\n").getBytes(StandardCharsets.UTF_8));
            baos.write(("Content-Type: application/octet-stream\r\n\r\n").getBytes(StandardCharsets.UTF_8));
            baos.write(imageBytes);
            baos.write(("\r\n--" + boundary + "--\r\n").getBytes(StandardCharsets.UTF_8));

            byte[] body = baos.toByteArray();
            conn.setRequestProperty("Content-Length", String.valueOf(body.length));

            try (OutputStream os = conn.getOutputStream()) {
                os.write(body);
                os.flush();
            }

            int code = conn.getResponseCode();
            String contentType = conn.getContentType() != null ? conn.getContentType() : "";

            try (BufferedReader br = new BufferedReader(new InputStreamReader(
                    code >= 200 && code < 300 ? conn.getInputStream() : conn.getErrorStream(),
                    StandardCharsets.UTF_8))) {
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) sb.append(line.trim());
                String resp = sb.toString();

                if (code >= 200 && code < 300
                        && resp.startsWith("https://")
                        && !resp.contains("error")
                        && !resp.contains("Error")) {
                    LOGGER.info("CatboxImageUploader: success => " + resp);
                    return resp.trim();
                }
                LOGGER.warning("CatboxImageUploader: " + uploadUrl + " => HTTP " + code
                        + " contentType=" + contentType + " body=" + resp);
                return null;
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "CatboxImageUploader: upload failed to " + uploadUrl, e);
            return null;
        } finally {
            if (conn != null) conn.disconnect();
        }
    }
}
