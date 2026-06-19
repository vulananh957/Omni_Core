package com.wms.model;

/**
 * CategoryMapping — UC-B2C09: links a WMS internal category to one or
 * more Lazada leaf categories. Sales staff curate these in the
 * "/sales/categories" page so the publish wizard can pre-fill or
 * suggest a Lazada leaf instead of forcing the user to search
 * 2890+ leaves every time.
 */
public class CategoryMapping {
    private int mappingId;
    private int channelId;
    private int wmsCategoryId;
    private long lazadaCategoryId;
    private String lazadaName;
    private boolean primary;
    private Integer createdBy;
    private java.sql.Timestamp createdAt;
    private java.sql.Timestamp updatedAt;

    public int getMappingId() { return mappingId; }
    public void setMappingId(int mappingId) { this.mappingId = mappingId; }

    public int getChannelId() { return channelId; }
    public void setChannelId(int channelId) { this.channelId = channelId; }

    public int getWmsCategoryId() { return wmsCategoryId; }
    public void setWmsCategoryId(int wmsCategoryId) { this.wmsCategoryId = wmsCategoryId; }

    public long getLazadaCategoryId() { return lazadaCategoryId; }
    public void setLazadaCategoryId(long lazadaCategoryId) { this.lazadaCategoryId = lazadaCategoryId; }

    public String getLazadaName() { return lazadaName; }
    public void setLazadaName(String lazadaName) { this.lazadaName = lazadaName; }

    public boolean isPrimary() { return primary; }
    public void setPrimary(boolean primary) { this.primary = primary; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public java.sql.Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(java.sql.Timestamp createdAt) { this.createdAt = createdAt; }

    public java.sql.Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(java.sql.Timestamp updatedAt) { this.updatedAt = updatedAt; }
}