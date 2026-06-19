package com.wms.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * FulfillmentRequest — Domain model for fulfillment_requests table.
 * Represents a fulfillment request sent from Sales to Warehouse for outbound processing.
 */
public class FulfillmentRequest {

    private String requestId;
    private String orderId;
    private int warehouseId;
    private String status;
    private boolean autoCreated;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private List<FulfillmentRequestItem> items = new ArrayList<>();

    public static final String STATUS_PENDING   = "PENDING";
    public static final String STATUS_CONVERTED = "CONVERTED";
    public static final String STATUS_CANCELLED = "CANCELLED";

    public FulfillmentRequest() {}

    public FulfillmentRequest(String requestId, String orderId, int warehouseId,
                              String status, boolean autoCreated,
                              LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.requestId = requestId;
        this.orderId = orderId;
        this.warehouseId = warehouseId;
        this.status = status;
        this.autoCreated = autoCreated;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public String getRequestId() {
        return requestId;
    }

    public void setRequestId(String requestId) {
        this.requestId = requestId;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
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

    public boolean isAutoCreated() {
        return autoCreated;
    }

    public void setAutoCreated(boolean autoCreated) {
        this.autoCreated = autoCreated;
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

    public List<FulfillmentRequestItem> getItems() {
        return items;
    }

    public void setItems(List<FulfillmentRequestItem> items) {
        this.items = items;
    }
}
