package com.wms.model;

import java.time.LocalDateTime;

/**
 * Channel — Domain model for B2C Sales Channel Integrations (Lazada, Shopee, TikTok, etc.)
 */
public class Channel {

    private int channelId;
    private String channelName;
    private String platform;
    private String apiUrl;
    private String apiKey;
    private String appSecret;
    private String webhookSecret;
    private double bufferStock;
    private boolean isActive;
    private String accessToken;
    private String refreshToken;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // ── Constructors ──────────────────────────────────────────

    public Channel() {
    }

    public Channel(int channelId, String channelName, String platform, String apiUrl, 
                   String apiKey, String appSecret, String webhookSecret, double bufferStock, 
                   boolean isActive, String accessToken, String refreshToken) {
        this.channelId = channelId;
        this.channelName = channelName;
        this.platform = platform;
        this.apiUrl = apiUrl;
        this.apiKey = apiKey;
        this.appSecret = appSecret;
        this.webhookSecret = webhookSecret;
        this.bufferStock = bufferStock;
        this.isActive = isActive;
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
    }

    // ── Getters / Setters ─────────────────────────────────────

    public int getChannelId() {
        return channelId;
    }

    public void setChannelId(int channelId) {
        this.channelId = channelId;
    }

    public String getChannelName() {
        return channelName;
    }

    public void setChannelName(String channelName) {
        this.channelName = channelName;
    }

    public String getPlatform() {
        return platform;
    }

    public void setPlatform(String platform) {
        this.platform = platform;
    }

    public String getApiUrl() {
        return apiUrl;
    }

    public void setApiUrl(String apiUrl) {
        this.apiUrl = apiUrl;
    }

    public String getApiKey() {
        return apiKey;
    }

    public void setApiKey(String apiKey) {
        this.apiKey = apiKey;
    }

    public String getAppSecret() {
        return appSecret;
    }

    public void setAppSecret(String appSecret) {
        this.appSecret = appSecret;
    }

    public String getWebhookSecret() {
        return webhookSecret;
    }

    public void setWebhookSecret(String webhookSecret) {
        this.webhookSecret = webhookSecret;
    }

    public double getBufferStock() {
        return bufferStock;
    }

    public void setBufferStock(double bufferStock) {
        this.bufferStock = bufferStock;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        this.isActive = active;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "Channel{" +
                "channelId=" + channelId +
                ", channelName='" + channelName + '\'' +
                ", platform='" + platform + '\'' +
                ", isActive=" + isActive +
                '}';
    }
}
