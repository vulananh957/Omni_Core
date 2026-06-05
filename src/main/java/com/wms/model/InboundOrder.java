package com.wms.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * InboundOrder — Domain model representing an inbound purchase order / goods receipt note.
 * Status workflow: PENDING → CONFIRMED → RECEIVED / CANCELLED
 */
public class InboundOrder {

    public static final String STATUS_PENDING    = "PENDING";
    public static final String STATUS_IN_PROGRESS = "IN_PROGRESS";
    public static final String STATUS_CONFIRMED  = "CONFIRMED";
    public static final String STATUS_RECEIVED   = "RECEIVED";
    public static final String STATUS_CANCELLED  = "CANCELLED";

    private int inboundId;
    private String inboundCode;
    private String supplierName;
    private int warehouseId;
    private String warehouseName;
    private String status;
    private LocalDate expectedDate;
    private LocalDate receivedDate;
    private int createdBy;
    private String notes;
    private LocalDateTime createdAt;

    // ── Constructors ──────────────────────────────────────────

    public InboundOrder() {
    }

    public InboundOrder(int inboundId, String inboundCode, String supplierName,
                       int warehouseId, String status) {
        this.inboundId = inboundId;
        this.inboundCode = inboundCode;
        this.supplierName = supplierName;
        this.warehouseId = warehouseId;
        this.status = status;
    }

    // ── Getters / Setters ───────────────────────────────────

    public int getInboundId() {
        return inboundId;
    }

    public void setInboundId(int inboundId) {
        this.inboundId = inboundId;
    }

    public String getInboundCode() {
        return inboundCode;
    }

    public void setInboundCode(String inboundCode) {
        this.inboundCode = inboundCode;
    }

    public String getSupplierName() {
        return supplierName;
    }

    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }

    public int getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(int warehouseId) {
        this.warehouseId = warehouseId;
    }

    public String getWarehouseName() {
        return warehouseName;
    }

    public void setWarehouseName(String warehouseName) {
        this.warehouseName = warehouseName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDate getExpectedDate() {
        return expectedDate;
    }

    public void setExpectedDate(LocalDate expectedDate) {
        this.expectedDate = expectedDate;
    }

    public LocalDate getReceivedDate() {
        return receivedDate;
    }

    public void setReceivedDate(LocalDate receivedDate) {
        this.receivedDate = receivedDate;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "InboundOrder{" +
                "inboundId=" + inboundId +
                ", inboundCode='" + inboundCode + '\'' +
                ", supplierName='" + supplierName + '\'' +
                ", warehouseId=" + warehouseId +
                ", status='" + status + '\'' +
                '}';
    }
}
