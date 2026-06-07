package com.wms.model;

import java.math.BigDecimal;

/**
 * OutboundItem — Domain model for the outbound_items table.
 * Represents a line item within an outbound order.
 */
public class OutboundItem {

    private int outboundItemId;
    private int outboundId;
    private int productId;
    private BigDecimal qty;
    private BigDecimal pickedQty;
    private String shelfLocation;
    private String skuCode;
    private String skuName;

    public OutboundItem() {
    }

    public OutboundItem(int outboundItemId, int outboundId, int productId,
                        BigDecimal qty, BigDecimal pickedQty, String shelfLocation) {
        this.outboundItemId = outboundItemId;
        this.outboundId = outboundId;
        this.productId = productId;
        this.qty = qty;
        this.pickedQty = pickedQty;
        this.shelfLocation = shelfLocation;
    }

    // ── Getters / Setters ─────────────────────────────────────

    public int getOutboundItemId() {
        return outboundItemId;
    }

    public void setOutboundItemId(int outboundItemId) {
        this.outboundItemId = outboundItemId;
    }

    public int getOutboundId() {
        return outboundId;
    }

    public void setOutboundId(int outboundId) {
        this.outboundId = outboundId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public BigDecimal getQty() {
        return qty;
    }

    public void setQty(BigDecimal qty) {
        this.qty = qty;
    }

    public BigDecimal getPickedQty() {
        return pickedQty;
    }

    public void setPickedQty(BigDecimal pickedQty) {
        this.pickedQty = pickedQty;
    }

    public String getShelfLocation() {
        return shelfLocation;
    }

    public void setShelfLocation(String shelfLocation) {
        this.shelfLocation = shelfLocation;
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

    @Override
    public String toString() {
        return "OutboundItem{" +
                "outboundItemId=" + outboundItemId +
                ", outboundId=" + outboundId +
                ", productId=" + productId +
                ", qty=" + qty +
                ", pickedQty=" + pickedQty +
                ", shelfLocation='" + shelfLocation + '\'' +
                '}';
    }
}
