package com.wms.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * OutboundOrder — Domain model for the outbound_orders table.
 * Represents a warehouse dispatch order (Xuất kho).
 * Status workflow: PENDING → PICKING → PACKED → SHIPPED / CANCELLED
 */
public class OutboundOrder {

    public static final String STATUS_PENDING   = "PENDING";
    public static final String STATUS_PICKING  = "PICKING";
    public static final String STATUS_PACKED   = "PACKED";
    public static final String STATUS_SHIPPED  = "SHIPPED";
    public static final String STATUS_CANCELLED = "CANCELLED";

    private int outboundId;
    private String outboundCode;
    private int orderId;
    private int warehouseId;
    private String status;
    private String notes;
    private LocalDateTime createdAt;
    private Integer pickedBy;
    private LocalDateTime pickedAt;

    private List<OutboundItem> items = new ArrayList<>();
    private String warehouseName;

    private String shippingAddress;
    private String courierName;
    private String recipientName;
    private String orderCode;

    public OutboundOrder() {
    }

    public OutboundOrder(int outboundId, String outboundCode, int orderId, int warehouseId,
                         String status, String notes, LocalDateTime createdAt,
                         Integer pickedBy, LocalDateTime pickedAt) {
        this.outboundId = outboundId;
        this.outboundCode = outboundCode;
        this.orderId = orderId;
        this.warehouseId = warehouseId;
        this.status = status;
        this.notes = notes;
        this.createdAt = createdAt;
        this.pickedBy = pickedBy;
        this.pickedAt = pickedAt;
    }

    // Getters / Setters for new fields
    public String getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    public String getCourierName() {
        return courierName;
    }

    public void setCourierName(String courierName) {
        this.courierName = courierName;
    }

    public String getRecipientName() {
        return recipientName;
    }

    public void setRecipientName(String recipientName) {
        this.recipientName = recipientName;
    }

    public String getOrderCode() {
        return orderCode;
    }

    public void setOrderCode(String orderCode) {
        this.orderCode = orderCode;
    }

    // ── Getters / Setters ─────────────────────────────────────

    public int getOutboundId() {
        return outboundId;
    }

    public void setOutboundId(int outboundId) {
        this.outboundId = outboundId;
    }

    public String getOutboundCode() {
        return outboundCode;
    }

    public void setOutboundCode(String outboundCode) {
        this.outboundCode = outboundCode;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(int warehouseId) {
        this.warehouseId = warehouseId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    public Integer getPickedBy() {
        return pickedBy;
    }

    public void setPickedBy(Integer pickedBy) {
        this.pickedBy = pickedBy;
    }

    public LocalDateTime getPickedAt() {
        return pickedAt;
    }

    public void setPickedAt(LocalDateTime pickedAt) {
        this.pickedAt = pickedAt;
    }

    public List<OutboundItem> getItems() {
        return items;
    }

    public void setItems(List<OutboundItem> items) {
        this.items = items;
    }

    public String getWarehouseName() {
        return warehouseName;
    }

    public void setWarehouseName(String warehouseName) {
        this.warehouseName = warehouseName;
    }

    @Override
    public String toString() {
        return "OutboundOrder{" +
                "outboundId=" + outboundId +
                ", outboundCode='" + outboundCode + '\'' +
                ", orderId=" + orderId +
                ", warehouseId=" + warehouseId +
                ", status='" + status + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
