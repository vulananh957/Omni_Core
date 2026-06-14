package com.wms.controller.warehouse;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.wms.controller.BaseController;
import com.wms.dao.InventoryCheckDAO;
import com.wms.model.Product;
import com.wms.model.User;
import com.wms.service.product.ProductService;
import com.wms.service.warehouse.WarehouseService;
import com.wms.util.AppConstants;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * WarehouseInventoryCheckServlet — Handles Physical Inventory Check (Kiểm kê kho) for the Warehouse Staff.
 *
 * Maps to /warehouse/inventory-check.
 *
 * Behaviour:
 *  - GET (HTML, no "ajax" param): render the JSP page (master data only).
 *  - GET ?ajax=1&action=checks : JSON list of all physical_inventories (newest first).
 *  - GET ?ajax=1&action=checkDetails&checkId=N : JSON list of line items.
 *  - POST JSON {action: "create" | "submit" | "adjust"} : server-side handlers.
 */
public class WarehouseInventoryCheckServlet extends BaseController {

    private static final Logger LOGGER = Logger.getLogger(WarehouseInventoryCheckServlet.class.getName());
    private final ProductService productService = new ProductService();
    private final WarehouseService warehouseService = new WarehouseService();
    private final ObjectMapper objectMapper = new ObjectMapper()
            .registerModule(new JavaTimeModule())
            .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String ajax = req.getParameter("ajax");
        if ("1".equals(ajax)) {
            handleAjaxGet(req, resp);
            return;
        }

        try {
            req.setAttribute("warehouses", warehouseService.findAll());
            req.setAttribute("warehousesJson", objectMapper.writeValueAsString(warehouseService.findAll()));
        } catch (Exception e) {
            req.setAttribute("warehouses", List.of());
            req.setAttribute("warehousesJson", "[]");
        }

        try {
            req.setAttribute("zones", warehouseService.findAllZones());
            req.setAttribute("zonesJson", objectMapper.writeValueAsString(warehouseService.findAllZones()));
        } catch (Exception e) {
            req.setAttribute("zones", List.of());
            req.setAttribute("zonesJson", "[]");
        }

        try {
            List<User> staff = warehouseService.findByRoles("WAREHOUSE_STAFF");
            req.setAttribute("staffMembers", staff);
        } catch (Exception e) {
            req.setAttribute("staffMembers", List.of());
        }

        try {
            req.setAttribute("categories", productService.findAllCategories());
            req.setAttribute("categoriesJson", objectMapper.writeValueAsString(productService.findAllCategories()));
        } catch (Exception e) {
            req.setAttribute("categories", List.of());
            req.setAttribute("categoriesJson", "[]");
        }

        try {
            req.setAttribute("products", productService.findAll());
            req.setAttribute("productsJson", objectMapper.writeValueAsString(productService.findAll()));
        } catch (Exception e) {
            req.setAttribute("products", List.of());
            req.setAttribute("productsJson", "[]");
        }

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Kiểm Kê & Cân Bằng Tồn Kho");
        req.setAttribute("pageSubtitle", "Đối soát số lượng hệ thống vs. đếm tay thực tế — điều chỉnh độ lệch");
        req.setAttribute("currentPage",  "wh-inventory-check");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/inventory/warehouse-inventory-check.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }

    private void handleAjaxGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        // Make sure the container doesn't chunk a tiny JSON body.
        resp.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        resp.setHeader("Pragma", "no-cache");

        String action = req.getParameter("action");
        Object payload;
        try {
            if ("checks".equals(action)) {
                List<InventoryCheckDAO.CheckHeader> checks = warehouseService.findAllInventoryChecks();
                LOGGER.log(Level.INFO, "InventoryCheckServlet: Found {0} checks", checks.size());
                payload = checks;
            } else if ("checkDetails".equals(action)) {
                int checkId = Integer.parseInt(req.getParameter("checkId"));
                List<InventoryCheckDAO.CheckDetail> details = warehouseService.findInventoryCheckDetails(checkId);
                payload = details;
            } else {
                payload = new java.util.LinkedHashMap<String, Object>() {{
                    put("success", false);
                    put("message", "Unknown ajax action: " + action);
                }};
            }
        } catch (NumberFormatException nfe) {
            payload = new java.util.LinkedHashMap<String, Object>() {{
                put("success", false);
                put("message", "Invalid checkId parameter");
            }};
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "WarehouseInventoryCheckServlet ajax GET error", e);
            payload = new java.util.LinkedHashMap<String, Object>() {{
                put("success", false);
                put("message", e.getClass().getSimpleName() + ": " + (e.getMessage() == null ? "" : e.getMessage()));
            }};
        }

        byte[] body = objectMapper.writeValueAsBytes(payload);
        resp.setContentLength(body.length);
        resp.getOutputStream().write(body);
        resp.getOutputStream().flush();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Always reply JSON for POST
        resp.setContentType("application/json; charset=UTF-8");
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute(AppConstants.SESSION_USER);
        int userId = currentUser != null ? currentUser.getUserId() : 1;

        try {
            String action = readAction(req);
            if ("create".equals(action)) {
                handleCreate(req, userId);
                writeJson(resp, true, "Tạo phiếu kiểm kê thành công.");
            } else if ("submit".equals(action)) {
                handleSubmit(req, userId);
                writeJson(resp, true, "Đã cập nhật kết quả kiểm đếm.");
            } else if ("adjust".equals(action)) {
                handleAdjust(req, userId);
                writeJson(resp, true, "Đã điều chỉnh tồn kho và ghi sổ kho.");
            } else {
                writeJson(resp, false, "Hành động không hợp lệ: " + action);
            }
        } catch (IllegalArgumentException e) {
            writeJson(resp, false, e.getMessage());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "WarehouseInventoryCheckServlet doPost error", e);
            writeJson(resp, false, "Lỗi xử lý: " + e.getMessage());
        }
    }

    private String readAction(HttpServletRequest req) throws IOException {
        String ctype = req.getContentType();
        if (ctype != null && ctype.toLowerCase().contains("application/json")) {
            var node = objectMapper.readTree(req.getInputStream());
            return node.has("action") ? node.get("action").asText() : "";
        }
        return req.getParameter("action") != null ? req.getParameter("action") : "";
    }

    private Map<String, Object> readJsonBody(HttpServletRequest req) throws IOException {
        String ctype = req.getContentType();
        if (ctype != null && ctype.toLowerCase().contains("application/json")) {
            var node = objectMapper.readTree(req.getInputStream());
            Map<String, Object> out = new LinkedHashMap<>();
            node.fields().forEachRemaining(e -> out.put(e.getKey(), e.getValue().asText()));
            return out;
        }
        Map<String, Object> out = new LinkedHashMap<>();
        req.getParameterMap().forEach((k, v) -> {
            if (v != null && v.length > 0) out.put(k, v[0]);
        });
        return out;
    }

    private void handleCreate(HttpServletRequest req, int userId) throws Exception {
        Map<String, Object> body = readJsonBody(req);
        String title    = strOrNull(body.get("title"));
        int warehouseId = intOrThrow(body.get("warehouseId"), "Vui lòng chọn chi nhánh kho.");
        String note     = strOrNull(body.get("note"));
        String scopeType = strOrNull(body.get("scopeType"));
        String scopeValue = strOrNull(body.get("scopeValue"));
        String itemsJson = strOrNull(body.get("itemsJson"));

        if (title == null) throw new IllegalArgumentException("Vui lòng nhập Tiêu đề phiếu.");

        // Build checkCode: PK-YYYYMMDD-NNNN
        java.time.LocalDate today = java.time.LocalDate.now();
        String suffix = String.format("-%04d", (int)(Math.random() * 9999));
        String checkCode = "PK-" + today.toString().replace("-", "") + suffix;

        // Build items JSON if not provided
        if (itemsJson == null) {
            StringBuilder sb = new StringBuilder("[");
            List<Product> products = safeProducts();
            int idx = 0;
            for (Product p : products) {
                boolean include = false;
                if ("all".equals(scopeType)) {
                    include = true;
                } else if ("category".equals(scopeType) && scopeValue != null) {
                    include = String.valueOf(p.getCategoryId()).equals(scopeValue);
                } else if ("sku".equals(scopeType) && scopeValue != null) {
                    include = p.getSkuCode() != null && p.getSkuCode().equals(scopeValue);
                }
                if (include) {
                    if (idx > 0) sb.append(",");
                    double sysQty = p.getQtyOnHand() != null ? p.getQtyOnHand().doubleValue() : 0d;
                    sb.append("{\"productId\":").append(p.getProductId())
                      .append(",\"systemQty\":").append(sysQty).append("}");
                    idx++;
                }
            }
            sb.append("]");
            itemsJson = sb.toString();
        }
        warehouseService.createInventoryCheck(checkCode, warehouseId, userId, note, itemsJson);
    }

    private void handleSubmit(HttpServletRequest req, int userId) throws Exception {
        Map<String, Object> body = readJsonBody(req);
        int checkId = intOrThrow(body.get("checkId"), "Thiếu checkId.");
        String resultsJson = strOrNull(body.get("resultsJson"));
        if (resultsJson == null) throw new IllegalArgumentException("Thiếu dữ liệu kết quả kiểm đếm.");
        warehouseService.submitInventoryCheckResults(checkId, resultsJson);
    }

    private void handleAdjust(HttpServletRequest req, int userId) throws Exception {
        Map<String, Object> body = readJsonBody(req);
        int checkId = intOrThrow(body.get("checkId"), "Thiếu checkId.");
        String adjustmentsJson = strOrNull(body.get("adjustmentsJson"));
        if (adjustmentsJson == null) throw new IllegalArgumentException("Thiếu dữ liệu điều chỉnh.");
        warehouseService.adjustInventoryFromCheck(checkId, adjustmentsJson, userId);
    }

    private List<Product> safeProducts() {
        try { return productService.findAll(); } catch (Exception e) { return List.of(); }
    }

    private static String strOrNull(Object o) {
        if (o == null) return null;
        String s = String.valueOf(o);
        return (s == null || s.trim().isEmpty() || "null".equals(s)) ? null : s;
    }

    private static int intOrThrow(Object o, String err) {
        if (o == null) throw new IllegalArgumentException(err);
        try { return Integer.parseInt(String.valueOf(o)); }
        catch (NumberFormatException e) { throw new IllegalArgumentException(err); }
    }

    private void writeJson(HttpServletResponse resp, boolean success, String message) throws IOException {
        Map<String, Object> r = new HashMap<>();
        r.put("success", success);
        r.put("message", message);
        objectMapper.writeValue(resp.getWriter(), r);
    }
}
