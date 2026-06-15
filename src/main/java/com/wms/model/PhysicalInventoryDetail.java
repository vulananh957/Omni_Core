package com.wms.model;

public class PhysicalInventoryDetail {
    private int checkDetailId;
    private String skuCode;
    private String productName;
    private double systemQty;
    private Double actualQty;
    private Double deltaQty;

    // Getters and Setters
    public int getCheckDetailId() { return checkDetailId; }
    public void setCheckDetailId(int checkDetailId) { this.checkDetailId = checkDetailId; }

    public String getSkuCode() { return skuCode; }
    public void setSkuCode(String skuCode) { this.skuCode = skuCode; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public double getSystemQty() { return systemQty; }
    public void setSystemQty(double systemQty) { this.systemQty = systemQty; }

    public Double getActualQty() { return actualQty; }
    public void setActualQty(Double actualQty) { this.actualQty = actualQty; }

    public Double getDeltaQty() { return deltaQty; }
    public void setDeltaQty(Double deltaQty) { this.deltaQty = deltaQty; }
}
