package com.wms.model;

import java.math.BigDecimal;

public class RtvItem {
    private int rtvItemId;
    private int rtvId;
    private int productId;
    private String sku;
    private String name;
    private BigDecimal qtyReturn;
    private BigDecimal unitCost;

    public int getRtvItemId() { return rtvItemId; }
    public void setRtvItemId(int rtvItemId) { this.rtvItemId = rtvItemId; }

    public int getRtvId() { return rtvId; }
    public void setRtvId(int rtvId) { this.rtvId = rtvId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public BigDecimal getQtyReturn() { return qtyReturn; }
    public void setQtyReturn(BigDecimal qtyReturn) { this.qtyReturn = qtyReturn; }

    public BigDecimal getUnitCost() { return unitCost; }
    public void setUnitCost(BigDecimal unitCost) { this.unitCost = unitCost; }
}
