package com.wms.service;

import com.lazada.lazop.api.*;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.util.AppConstants;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LazadaFulfillmentService — Service for handling Lazada order fulfillment.
 * Handles tasks like fetching order item IDs and generating shipping documents (waybills).
 */
public class LazadaFulfillmentService {

    private static final Logger LOGGER = Logger.getLogger(LazadaFulfillmentService.class.getName());

    public static void main(String[] args) {
        String url = AppConstants.LAZADA_API_URL;
        String appKey = AppConstants.getLazadaAppKey();
        String appSecret = AppConstants.getLazadaAppSecret();
        String token = System.getenv("LAZADA_ACCESS_TOKEN");

        if (token == null || token.isBlank()) {
            LOGGER.warning("LAZADA_ACCESS_TOKEN not set. Skipping test.");
            return;
        }

        String orderId = args.length > 0 ? args[0] : "390697385501209";

        try {
            LazopClient client = new LazopClient(url, appKey, appSecret);
            ObjectMapper objectMapper = new ObjectMapper();

            System.out.println("=== Step 1: Fetch Order Items from /order/items/get ===");
            LazopRequest itemsRequest = new LazopRequest();
            itemsRequest.setApiName("/order/items/get");
            itemsRequest.setHttpMethod("GET");
            itemsRequest.addApiParameter("order_id", orderId);

            LazopResponse itemsResponse = client.execute(itemsRequest, token);
            String itemsBody = itemsResponse.getBody();
            System.out.println("Result /order/items/get: " + itemsBody);

            JsonNode itemsRootNode = objectMapper.readTree(itemsBody);
            JsonNode dataArray = itemsRootNode.path("data");

            if (!dataArray.isArray() || dataArray.size() == 0) {
                System.out.println("No order items found or API returned an error.");
                return;
            }

            long orderItemId = dataArray.get(0).path("order_item_id").asLong();
            System.out.println("Extracted order_item_id: " + orderItemId);

            System.out.println("=== Step 2: Fetch Shipping Label from /order/document/get ===");
            LazopRequest docRequest = new LazopRequest();
            docRequest.setApiName("/order/document/get");
            docRequest.setHttpMethod("GET");
            docRequest.addApiParameter("doc_type", "shippingLabel");
            docRequest.addApiParameter("order_item_ids", "[" + orderItemId + "]");

            LazopResponse docResponse = client.execute(docRequest, token);
            System.out.println("Shipping Label result: " + docResponse.getBody());

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "LazadaFulfillmentService: API call failed", e);
        }
    }
}
