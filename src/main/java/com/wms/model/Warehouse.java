package com.wms.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Warehouse — Domain model representing a physical warehouse branch.
 */
public class Warehouse {

    private int warehouseId;
    private String warehouseCode;
    private String warehouseName;
    private String address;
    private String phone;
    private int capacity;
    private boolean active;
    private LocalDateTime createdAt;
    private List<Zone> zones = new ArrayList<>();

    // constructors
    public Warehouse() {
    }

    // getters and setters
    public int getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(int warehouseId) {
        this.warehouseId = warehouseId;
    }

    public int getId() {
        return warehouseId;
    }

    public void setId(int id) {
        this.warehouseId = id;
    }

    public String getWarehouseCode() {
        return warehouseCode;
    }

    public void setWarehouseCode(String warehouseCode) {
        this.warehouseCode = warehouseCode;
    }

    public String getCode() {
        return warehouseCode;
    }

    public void setCode(String code) {
        this.warehouseCode = code;
    }

    public String getWarehouseName() {
        return warehouseName;
    }

    public void setWarehouseName(String warehouseName) {
        this.warehouseName = warehouseName;
    }

    public String getName() {
        return warehouseName;
    }

    public void setName(String name) {
        this.warehouseName = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public String getStatus() {
        return active ? "active" : "closed";
    }

    public void setStatus(String status) {
        this.active = "active".equalsIgnoreCase(status);
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public List<Zone> getZones() {
        return zones;
    }

    public void setZones(List<Zone> zones) {
        this.zones = zones;
    }

    @Override
    public String toString() {
        return "Warehouse{" +
                "warehouseId=" + warehouseId +
                ", warehouseCode='" + warehouseCode + '\'' +
                ", warehouseName='" + warehouseName + '\'' +
                ", active=" + active +
                '}';
    }
}
