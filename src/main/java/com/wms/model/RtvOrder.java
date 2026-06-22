package com.wms.model;

import java.util.List;

public class RtvOrder {
    private int id;
    private String code;
    private int inboundId;
    private String inboundCode;
    private int warehouseId;
    private String warehouseName;
    private String supplier;
    private String status;
    private String reason;
    private String note;
    private String createdAt;
    private List<RtvItem> items;

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public int getInboundId() { return inboundId; }
    public void setInboundId(int inboundId) { this.inboundId = inboundId; }

    public String getInboundCode() { return inboundCode; }
    public void setInboundCode(String inboundCode) { this.inboundCode = inboundCode; }

    public int getWarehouseId() { return warehouseId; }
    public void setWarehouseId(int warehouseId) { this.warehouseId = warehouseId; }

    public String getWarehouseName() { return warehouseName; }
    public void setWarehouseName(String warehouseName) { this.warehouseName = warehouseName; }

    public String getSupplier() { return supplier; }
    public void setSupplier(String supplier) { this.supplier = supplier; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    public List<RtvItem> getItems() { return items; }
    public void setItems(List<RtvItem> items) { this.items = items; }
}
