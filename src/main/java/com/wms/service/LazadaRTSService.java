package com.wms.service;

import com.lazada.lazop.api.*;
import com.wms.util.AppConstants;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LazadaRTSService — Service for confirming orders as Ready to Ship (RTS).
 * Handles the package transition status using the Lazada Open Platform API.
 */
public class LazadaRTSService {

    private static final Logger LOGGER = Logger.getLogger(LazadaRTSService.class.getName());

    public static void main(String[] args) {
        String url = AppConstants.LAZADA_API_URL;
        String appKey = AppConstants.getLazadaAppKey();
        String appSecret = AppConstants.getLazadaAppSecret();
        String token = System.getenv("LAZADA_ACCESS_TOKEN");

        if (token == null || token.isBlank()) {
            LOGGER.warning("LAZADA_ACCESS_TOKEN not set. Skipping test.");
            return;
        }

        String packageId = args.length > 0 ? args[0] : "PKG-MOCK-12345";

        try {
            LazopClient client = new LazopClient(url, appKey, appSecret);
            LazopRequest request = new LazopRequest();
            request.setApiName("/order/package/rts");
            request.setHttpMethod("POST");
            request.addApiParameter("packages", "[{\"package_id\":\"" + packageId + "\"}]");

            System.out.println("Sending Ready To Ship (RTS) request to Lazada...");
            LazopResponse response = client.execute(request, token);
            System.out.println("RTS Result: " + response.getBody());

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "LazadaRTSService: API call failed", e);
        }
    }
}
