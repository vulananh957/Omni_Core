package com.wms.model;

/**
 * StockPushItem — Represents a single SKU to be pushed to Lazada's
 * UpdateSellableQuantity endpoint after an inbound receipt is confirmed.
 *
 * <p>Carries both the Lazada identifiers (item_id, sku_id, sellerSku)
 * and the WMS-side quantities used for logging and auditing.</p>
 */
public class StockPushItem {

    private int productId;
    private String sellerSku;
    private String lazadaSkuId;
    private String channelItemId;
    private java.math.BigDecimal pushQty;
    private java.math.BigDecimal systemAvailable;
    private java.math.BigDecimal bufferStock;
    private int channelId;
    private String inboundCode;

    public StockPushItem() {}

    public StockPushItem(int productId, String sellerSku, String lazadaSkuId,
                         String channelItemId, java.math.BigDecimal pushQty,
                         java.math.BigDecimal systemAvailable,
                         java.math.BigDecimal bufferStock,
                         int channelId, String inboundCode) {
        this.productId = productId;
        this.sellerSku = sellerSku;
        this.lazadaSkuId = lazadaSkuId;
        this.channelItemId = channelItemId;
        this.pushQty = pushQty;
        this.systemAvailable = systemAvailable;
        this.bufferStock = bufferStock;
        this.channelId = channelId;
        this.inboundCode = inboundCode;
    }

    // ── Getters / Setters ─────────────────────────────────────

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getSellerSku() {
        return sellerSku;
    }

    public void setSellerSku(String sellerSku) {
        this.sellerSku = sellerSku;
    }

    public String getLazadaSkuId() {
        return lazadaSkuId;
    }

    public void setLazadaSkuId(String lazadaSkuId) {
        this.lazadaSkuId = lazadaSkuId;
    }

    public String getChannelItemId() {
        return channelItemId;
    }

    public void setChannelItemId(String channelItemId) {
        this.channelItemId = channelItemId;
    }

    public java.math.BigDecimal getPushQty() {
        return pushQty;
    }

    public void setPushQty(java.math.BigDecimal pushQty) {
        this.pushQty = pushQty;
    }

    public java.math.BigDecimal getSystemAvailable() {
        return systemAvailable;
    }

    public void setSystemAvailable(java.math.BigDecimal systemAvailable) {
        this.systemAvailable = systemAvailable;
    }

    public java.math.BigDecimal getBufferStock() {
        return bufferStock;
    }

    public void setBufferStock(java.math.BigDecimal bufferStock) {
        this.bufferStock = bufferStock;
    }

    public int getChannelId() {
        return channelId;
    }

    public void setChannelId(int channelId) {
        this.channelId = channelId;
    }

    public String getInboundCode() {
        return inboundCode;
    }

    public void setInboundCode(String inboundCode) {
        this.inboundCode = inboundCode;
    }
}
