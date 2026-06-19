package com.wms.model;

import java.time.LocalDateTime;

/**
 * ProductImage — Domain model for an image attached to a master SKU product.
 * Used by UC-B2C09 to migrate external image URLs onto Lazada before pushing
 * the product via {@code /product/create}.
 *
 * <p>One product may have many images; at most one is marked {@code is_primary}
 * (sort_order=0). Lazada requires at least one image and uses the first/primary
 * one as the cover thumbnail.
 */
public class ProductImage {

    private int imageId;
    private int productId;
    private String imageUrl;
    private boolean isPrimary;
    private int sortOrder;
    private LocalDateTime createdAt;

    public ProductImage() {}

    public ProductImage(int imageId, int productId, String imageUrl,
                        boolean isPrimary, int sortOrder) {
        this.imageId = imageId;
        this.productId = productId;
        this.imageUrl = imageUrl;
        this.isPrimary = isPrimary;
        this.sortOrder = sortOrder;
    }

    public int getImageId() {
        return imageId;
    }

    public void setImageId(int imageId) {
        this.imageId = imageId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public boolean isPrimary() {
        return isPrimary;
    }

    public void setPrimary(boolean primary) {
        isPrimary = primary;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "ProductImage{id=" + imageId + ", productId=" + productId
                + ", url='" + imageUrl + "', primary=" + isPrimary + "}";
    }
}
