package com.wms.util;

import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Map;
import java.util.TreeMap;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

/**
 * Utility class for Lazada Open Platform API integration.
 * Contains utility methods for cryptographic operations and signatures.
 */
public final class LazadaAPIUtil {

    // Prevent instantiation
    private LazadaAPIUtil() {
        throw new UnsupportedOperationException("This is a utility class and cannot be instantiated");
    }

    /**
     * Generates a signature for a Lazada API request.
     *
     * @param apiPath   The API endpoint path (e.g., "/auth/token/create").
     * @param params    The map of request parameters (both common and business parameters).
     * @param appSecret The Lazada app secret key.
     * @return The generated signature as an uppercase Hex string.
     */
    public static String generateSignature(String apiPath, Map<String, String> params, String appSecret) {
        if (apiPath == null || params == null || appSecret == null) {
            throw new IllegalArgumentException("Parameters apiPath, params, and appSecret must not be null");
        }

        // 1. Sort the parameters alphabetically by key
        Map<String, String> sortedParams = new TreeMap<>(params);

        // 2. Concatenate parameters: start with apiPath, then append key+value for each parameter
        StringBuilder queryStr = new StringBuilder();
        queryStr.append(apiPath);
        for (Map.Entry<String, String> entry : sortedParams.entrySet()) {
            queryStr.append(entry.getKey()).append(entry.getValue());
        }

        // 3. Compute HMAC-SHA256 signature
        try {
            byte[] hmacSha256 = hmacSha256(queryStr.toString(), appSecret);

            // 4. Convert signature to uppercase Hex string
            return bytesToHex(hmacSha256);
        } catch (NoSuchAlgorithmException | InvalidKeyException e) {
            throw new RuntimeException("Failed to generate Lazada API signature", e);
        }
    }

    /**
     * Helper method to compute HMAC-SHA256 hash.
     */
    private static byte[] hmacSha256(String data, String key) throws NoSuchAlgorithmException, InvalidKeyException {
        SecretKeySpec secretKeySpec = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(secretKeySpec);
        return mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * Helper method to convert a byte array to an uppercase Hex string.
     */
    private static String bytesToHex(byte[] bytes) {
        StringBuilder hexString = new StringBuilder();
        for (byte b : bytes) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) {
                hexString.append('0');
            }
            hexString.append(hex);
        }
        return hexString.toString().toUpperCase();
    }
}
