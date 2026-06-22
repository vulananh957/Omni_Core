package com.wms.model;

/**
 * DashboardMetrics — Live operational KPIs for the Warehouse Information header.
 */
public class DashboardMetrics {

    private int totalSku;
    private double totalPhysical;
    private int alertCount;

    public DashboardMetrics() {}

    public DashboardMetrics(int totalSku, double totalPhysical, int alertCount) {
        this.totalSku = totalSku;
        this.totalPhysical = totalPhysical;
        this.alertCount = alertCount;
    }

    public int getTotalSku()     { return totalSku; }
    public void setTotalSku(int v) { this.totalSku = v; }

    public double getTotalPhysical()   { return totalPhysical; }
    public void setTotalPhysical(double v) { this.totalPhysical = v; }

    public int getAlertCount()    { return alertCount; }
    public void setAlertCount(int v) { this.alertCount = v; }
}
