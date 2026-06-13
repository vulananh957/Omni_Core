package com.wms.model;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Zone — Domain model representing a storage zone within a warehouse.
 */
public class Zone {

    private int zoneId;
    private int warehouseId;
    private String zoneCode;
    private String zoneName;
    private String zoneType; // "NORMAL" | "RETURN" | "DAMAGED" | "DESTROY"
    private String description;
    private boolean active;

    @JsonProperty("isDefault")
    private boolean isDefault;

    // constructors
    public Zone() {
    }

    // getters and setters
    public int getZoneId() {
        return zoneId;
    }

    public void setZoneId(int zoneId) {
        this.zoneId = zoneId;
    }

    public int getId() {
        return zoneId;
    }

    public void setId(int id) {
        this.zoneId = id;
    }

    public int getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(int warehouseId) {
        this.warehouseId = warehouseId;
    }

    public String getZoneCode() {
        return zoneCode;
    }

    public void setZoneCode(String zoneCode) {
        this.zoneCode = zoneCode;
    }

    public String getCode() {
        return zoneCode;
    }

    public void setCode(String code) {
        this.zoneCode = code;
    }

    public String getZoneName() {
        return zoneName;
    }

    public void setZoneName(String zoneName) {
        this.zoneName = zoneName;
    }

    public String getName() {
        return zoneName;
    }

    public void setName(String name) {
        this.zoneName = name;
    }

    public String getZoneType() {
        return zoneType;
    }

    public void setZoneType(String zoneType) {
        this.zoneType = zoneType;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    @JsonProperty("isDefault")
    public boolean isDefault() {
        return isDefault;
    }

    @JsonProperty("isDefault")
    public void setDefault(boolean isDefault) {
        this.isDefault = isDefault;
    }

    @Override
    public String toString() {
        return "Zone{" +
                "zoneId=" + zoneId +
                ", zoneCode='" + zoneCode + '\'' +
                ", zoneName='" + zoneName + '\'' +
                ", zoneType='" + zoneType + '\'' +
                '}';
    }
}
