package com.wms.model;

import java.time.LocalDateTime;

public class PhysicalInventory {
    private int checkId;
    private String checkCode;
    private int warehouseId;
    private String warehouseName;
    private String status;
    private String note;
    private String creatorName;
    private LocalDateTime createdAt;
    private int totalItems;
    private int countedItems;
    private double totalDelta;

    // Getters and Setters
    public int getCheckId() { return checkId; }
    public void setCheckId(int checkId) { this.checkId = checkId; }

    public String getCheckCode() { return checkCode; }
    public void setCheckCode(String checkCode) { this.checkCode = checkCode; }

    public int getWarehouseId() { return warehouseId; }
    public void setWarehouseId(int warehouseId) { this.warehouseId = warehouseId; }

    public String getWarehouseName() { return warehouseName; }
    public void setWarehouseName(String warehouseName) { this.warehouseName = warehouseName; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getCreatorName() { return creatorName; }
    public void setCreatorName(String creatorName) { this.creatorName = creatorName; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public int getTotalItems() { return totalItems; }
    public void setTotalItems(int totalItems) { this.totalItems = totalItems; }

    public int getCountedItems() { return countedItems; }
    public void setCountedItems(int countedItems) { this.countedItems = countedItems; }

    public double getTotalDelta() { return totalDelta; }
    public void setTotalDelta(double totalDelta) { this.totalDelta = totalDelta; }
}
