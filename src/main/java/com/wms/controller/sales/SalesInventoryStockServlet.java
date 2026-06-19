package com.wms.controller.sales;

import com.wms.controller.BaseController;
import com.wms.dao.InventoryDAO;
import com.wms.util.JsonUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * SalesInventoryStockServlet — Returns real-time inventory stock per SKU per warehouse as JSON.
 * Maps to GET /sales/inventory-stock.
 *
 * The order-processing page reads stock from localStorage['wh_pricing_sales'], which is
 * normally populated by the channel-products page. To keep the order-processing page
 * working even when the user has not visited channel-products first, this endpoint
 * serves the authoritative stock data straight from the inventory table.
 *
 * Response shape (used by order-processing.jsp):
 * {
 *   "success": true,
 *   "stocks": [
 *     { "sku": "TSH-NAM-001", "warehouseName": "Kho Hà Nội", "qtyOnHand": 200, "qtyAvailable": 200 },
 *     ...
 *   ]
 * }
 */
public class SalesInventoryStockServlet extends BaseController {

    private final InventoryDAO inventoryDAO = new InventoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");

        try {
            List<Map<String, Object>> rows = inventoryDAO.findAllInventorySummary();
            List<Map<String, Object>> stocks = new java.util.ArrayList<>();
            for (Map<String, Object> row : rows) {
                Map<String, Object> s = new LinkedHashMap<>();
                s.put("sku",           row.get("skuCode"));
                s.put("warehouseName", row.get("warehouseName"));
                s.put("qtyOnHand",     row.get("qtyOnHand"));
                s.put("qtyAvailable",  row.get("qtyAvailable"));
                stocks.add(s);
            }
            Map<String, Object> payload = new LinkedHashMap<>();
            payload.put("success", true);
            payload.put("stocks", stocks);
            writeJson(resp, JsonUtil.toJson(payload));
        } catch (Exception e) {
            Map<String, Object> payload = new HashMap<>();
            payload.put("success", false);
            payload.put("message", e.getMessage());
            writeJson(resp, JsonUtil.toJson(payload));
        }
    }
}
