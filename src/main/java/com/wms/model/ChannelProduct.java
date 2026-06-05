package com.wms.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * ChannelProduct — Domain model for channel-specific product listings.
 * Represents a product published on a marketplace channel (Lazada/Shopee/TikTok).
 */
public class ChannelProduct {

    private int id;
    private int channelId;
    private int productId;
    private String channelSkuCode;
    private BigDecimal channelPrice;
    private BigDecimal channelStock;
    private String status;
    private LocalDateTime listedAt;
    private LocalDateTime updatedAt;

    // Enriched fields (populated by DAO joins)
    private String channelName;
    private String channelPlatform;
    private String skuCode;
    private String productName;
    private String categoryName;

    public ChannelProduct() {}

    public ChannelProduct(int id, int channelId, int productId, String channelSkuCode,
                         BigDecimal channelPrice, BigDecimal channelStock, String status,
                         LocalDateTime listedAt, LocalDateTime updatedAt) {
        this.id = id;
        this.channelId = channelId;
        this.productId = productId;
        this.channelSkuCode = channelSkuCode;
        this.channelPrice = channelPrice;
        this.channelStock = channelStock;
        this.status = status;
        this.listedAt = listedAt;
        this.updatedAt = updatedAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getChannelId() {
        return channelId;
    }

    public void setChannelId(int channelId) {
        this.channelId = channelId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getChannelSkuCode() {
        return channelSkuCode;
    }

    public void setChannelSkuCode(String channelSkuCode) {
        this.channelSkuCode = channelSkuCode;
    }

    public BigDecimal getChannelPrice() {
        return channelPrice;
    }

    public void setChannelPrice(BigDecimal channelPrice) {
        this.channelPrice = channelPrice;
    }

    public BigDecimal getChannelStock() {
        return channelStock;
    }

    public void setChannelStock(BigDecimal channelStock) {
        this.channelStock = channelStock;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getListedAt() {
        return listedAt;
    }

    public void setListedAt(LocalDateTime listedAt) {
        this.listedAt = listedAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getChannelName() {
        return channelName;
    }

    public void setChannelName(String channelName) {
        this.channelName = channelName;
    }

    public String getChannelPlatform() {
        return channelPlatform;
    }

    public void setChannelPlatform(String channelPlatform) {
        this.channelPlatform = channelPlatform;
    }

    public String getSkuCode() {
        return skuCode;
    }

    public void setSkuCode(String skuCode) {
        this.skuCode = skuCode;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }
}
