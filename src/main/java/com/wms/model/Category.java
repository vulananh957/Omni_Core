package com.wms.model;

import java.time.LocalDateTime;

/**
 * Category — Domain model for product category hierarchy.
 * Supports multi-level tree structure via parentId reference.
 * 
 * Business rules:
 * - categoryCode: ma dinh danh 3-4 ky tu, UPPERCASE, bat bien sau khi tao
 * - isImmutable: true = da co san pham, khong cho sua categoryCode
 * - active: true = dang hoat dong, false = ngung hoat dong (khong xoa)
 */
public class Category {

    private int categoryId;
    private String categoryCode;    // Ma dinh danh 3-4 ky tu (VD: "EYE", "SUN")
    private String categoryName;
    private Integer parentId;
    private String description;
    private int levelDepth;
    private boolean isImmutable;    // true = da lock categoryCode
    private boolean active;         // true = hoat dong, false = ngung hoat dong
    private String parentCode;      // ma cua danh muc cha (dung cho SKU generation)
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // ── Constructors ──────────────────────────────────────────

    public Category() {
    }

    public Category(int categoryId, String categoryName, Integer parentId, String description) {
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.parentId = parentId;
        this.description = description;
    }

    // ── Getters / Setters ─────────────────────────────────────

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public Integer getParentId() {
        return parentId;
    }

    public void setParentId(Integer parentId) {
        this.parentId = parentId;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
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

    public int getLevelDepth() {
        return levelDepth;
    }

    public void setLevelDepth(int levelDepth) {
        this.levelDepth = levelDepth;
    }

    // ── Category Code (Ma dinh danh) ──────────────────────────────

    public String getCategoryCode() {
        return categoryCode;
    }

    public void setCategoryCode(String categoryCode) {
        this.categoryCode = categoryCode != null ? categoryCode.toUpperCase() : null;
    }

    // ── Immutability (Bat bien - da lock categoryCode) ─────────────

    public boolean isImmutable() {
        return isImmutable;
    }

    public void setImmutable(boolean immutable) {
        this.isImmutable = immutable;
    }

    // ── Active Status (Trang thai hoat dong) ─────────────────────

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    // ── Parent Code (dung cho SKU generation) ─────────────────────

    public String getParentCode() {
        return parentCode;
    }

    public void setParentCode(String parentCode) {
        this.parentCode = parentCode;
    }

    @Override
    public String toString() {
        return "Category{" +
                "categoryId=" + categoryId +
                ", categoryName='" + categoryName + '\'' +
                ", parentId=" + parentId +
                '}';
    }
}
