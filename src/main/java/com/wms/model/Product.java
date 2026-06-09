package com.wms.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Product — Domain model representing a master SKU product.
 * Status workflow: PENDING → APPROVED / REJECTED
 */
public class Product {

    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_APPROVED = "APPROVED";
    public static final String STATUS_REJECTED = "REJECTED";

    private int productId;
    private String skuCode;
    private String productName;
    private Integer categoryId;
    private String barcode;
    private String unit;
    private Double minStock;
    private Double maxStock;
    private String status;
    private LocalDateTime approvedAt;
    private Integer approvedBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String categoryName;
    private Integer createdBy;
    private String creatorName;
    private String attributesText;
    private Double weightKg;
    private String reviewNote;
    private Double qtyOnHand = 0.0;
    private String approverName;
    private List<LocationConfig> locationConfigs = new ArrayList<>();

    public static class LocationConfig {
        private String locationId;
        private String zoneId;

        public LocationConfig() {}

        public LocationConfig(String locationId, String zoneId) {
            this.locationId = locationId;
            this.zoneId = zoneId;
        }

        public String getLocationId() {
            return locationId;
        }

        public void setLocationId(String locationId) {
            this.locationId = locationId;
        }

        public String getZoneId() {
            return zoneId;
        }

        public void setZoneId(String zoneId) {
            this.zoneId = zoneId;
        }
    }


    // ── Constructors ──────────────────────────────────────────

    public Product() {
    }

    public Product(int productId, String skuCode, String productName, Integer categoryId, String status) {
        this.productId = productId;
        this.skuCode = skuCode;
        this.productName = productName;
        this.categoryId = categoryId;
        this.status = status;
    }

    // ── Getters / Setters ─────────────────────────────────────

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getSkuCode() {
        return skuCode;
    }

    public void setSkuCode(String skuCode) {
        this.skuCode = skuCode;
    }

    @JsonProperty("sku")
    public String getSku() {
        return skuCode;
    }

    public String getSkuName() {
        return productName;
    }

    @JsonProperty("name")
    public String getName() {
        return productName;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public Integer getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Integer categoryId) {
        this.categoryId = categoryId;
    }

    public String getBarcode() {
        return barcode;
    }

    public void setBarcode(String barcode) {
        this.barcode = barcode;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public Double getMinStock() {
        return minStock;
    }

    public void setMinStock(Double minStock) {
        this.minStock = minStock;
    }

    public Double getMaxStock() {
        return maxStock;
    }

    public void setMaxStock(Double maxStock) {
        this.maxStock = maxStock;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @JsonIgnore
    public LocalDateTime getApprovedAt() {
        return approvedAt;
    }

    @JsonProperty("approvedAt")
    public String getApprovedAtAsString() {
        if (approvedAt == null) return "";
        return approvedAt.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
    }

    public void setApprovedAt(LocalDateTime approvedAt) {
        this.approvedAt = approvedAt;
    }

    public Integer getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(Integer approvedBy) {
        this.approvedBy = approvedBy;
    }

    @JsonIgnore
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    @JsonProperty("createdAt")
    public String getCreatedAtAsString() {
        if (createdAt == null) return "";
        return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    @JsonIgnore
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    @JsonProperty("lastUpdated")
    public String getUpdatedAtAsString() {
        if (updatedAt == null) return "";
        return updatedAt.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
    }

    @JsonProperty("updatedAt")
    public String getUpdatedAtAsString2() {
        return getUpdatedAtAsString();
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    @JsonIgnore
    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }

    public String getCreatorName() {
        return creatorName;
    }

    public void setCreatorName(String creatorName) {
        this.creatorName = creatorName;
    }

    public String getAttributesText() {
        return attributesText;
    }

    public void setAttributesText(String attributesText) {
        this.attributesText = attributesText;
    }

    public Double getWeightKg() {
        return weightKg;
    }

    public void setWeightKg(Double weightKg) {
        this.weightKg = weightKg;
    }

    // New Fields Getters and Setters
    public String getReviewNote() {
        return reviewNote;
    }

    public void setReviewNote(String reviewNote) {
        this.reviewNote = reviewNote;
    }

    public Double getQtyOnHand() {
        return qtyOnHand;
    }

    public void setQtyOnHand(Double qtyOnHand) {
        this.qtyOnHand = qtyOnHand;
    }

    public String getApproverName() {
        return approverName;
    }

    public void setApproverName(String approverName) {
        this.approverName = approverName;
    }

    public List<LocationConfig> getLocationConfigs() {
        return locationConfigs;
    }

    public void setLocationConfigs(List<LocationConfig> locationConfigs) {
        this.locationConfigs = locationConfigs;
    }

    // Helper Getters for Jackson to match JSP property expectations
    @JsonProperty("id")
    public String getIdAsString() {
        return "p-" + productId;
    }

    @JsonProperty("category")
    public String getCategory() {
        return categoryName != null ? categoryName : "";
    }

    @JsonProperty("dimensions")
    public String getDimensions() {
        return attributesText != null ? attributesText : "N/A";
    }

    @JsonProperty("weight")
    public String getWeight() {
        return weightKg != null ? weightKg + " kg" : "N/A";
    }

    @JsonProperty("approvalStatus")
    public String getApprovalStatus() {
        if (status == null) return "pending";
        return status.toLowerCase();
    }

    @JsonProperty("createdBy")
    public String getCreatedByName() {
        return creatorName != null ? creatorName : (createdBy != null ? String.valueOf(createdBy) : "");
    }

    @JsonProperty("updatedBy")
    public String getUpdatedBy() {
        return approverName != null ? approverName : "";
    }


    @Override
    public String toString() {
        return "Product{" +
                "productId=" + productId +
                ", skuCode='" + skuCode + '\'' +
                ", productName='" + productName + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
}
