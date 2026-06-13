package com.wms.model;

/**
 * FulfillmentRequestItem — Domain model for fulfillment_request_items table.
 * Represents a line item within a fulfillment request.
 */
public class FulfillmentRequestItem {

    private int itemId;
    private String requestId;
    private String skuCode;
    private String skuName;
    private int qty;

    public FulfillmentRequestItem() {}

    public FulfillmentRequestItem(int itemId, String requestId, String skuCode,
                                   String skuName, int qty) {
        this.itemId = itemId;
        this.requestId = requestId;
        this.skuCode = skuCode;
        this.skuName = skuName;
        this.qty = qty;
    }

    public int getItemId() {
        return itemId;
    }

    public void setItemId(int itemId) {
        this.itemId = itemId;
    }

    public String getRequestId() {
        return requestId;
    }

    public void setRequestId(String requestId) {
        this.requestId = requestId;
    }

    public String getSkuCode() {
        return skuCode;
    }

    public void setSkuCode(String skuCode) {
        this.skuCode = skuCode;
    }

    public String getSkuName() {
        return skuName;
    }

    public void setSkuName(String skuName) {
        this.skuName = skuName;
    }

    public int getQty() {
        return qty;
    }

    public void setQty(int qty) {
        this.qty = qty;
    }
}
