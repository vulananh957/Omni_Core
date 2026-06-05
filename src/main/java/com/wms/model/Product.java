package com.wms.model;

import java.time.LocalDateTime;

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

    public String getSku() {
        return skuCode;
    }

    public String getSkuName() {
        return productName;
    }

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

    public LocalDateTime getApprovedAt() {
        return approvedAt;
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
        return "Product{" +
                "productId=" + productId +
                ", skuCode='" + skuCode + '\'' +
                ", productName='" + productName + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
}
