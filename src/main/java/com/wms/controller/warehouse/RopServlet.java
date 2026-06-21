package com.wms.controller.warehouse;

import com.wms.service.warehouse.RopCalculationService;
import com.wms.util.AppConstants;
import com.wms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * RopServlet — REST API for ROP (Reorder Point) management.
 *
 * <p>POST /api/rop/trigger
 *    Manually triggers a full ROP recomputation for all SKUs.
 *    Authenticated: Manager or Admin only.
 *
 * <p>GET /api/rop/status
 *    Returns the last ROP log entry per product (summary).
 *
 * <p>GET /api/rop/product/{id}
 *    Returns ROP metrics for a single product.
 */
public class RopServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final java.util.logging.Logger LOGGER =
            java.util.logging.Logger.getLogger(RopServlet.class.getName());

    private final RopCalculationService ropService = new RopCalculationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String pathInfo = req.getPathInfo();

        if (pathInfo != null && pathInfo.startsWith("/product/")) {
            getProductRop(req, resp, pathInfo);
        } else {
            getStatus(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        // Auth check: Manager or Admin only
        if (!isManagerOrAdmin(req)) {
            writeError(resp, HttpServletResponse.SC_FORBIDDEN, "Chỉ Manager hoặc Admin mới có quyền chạy tính ROP.");
            return;
        }

        int userId = currentUserId(req);
        int lookback = parseInt(req.getParameter("lookbackDays"), RopCalculationService.DEFAULT_LOOKBACK_DAYS);

        LOGGER.info("ROP manual trigger: userId=" + userId + " lookback=" + lookback);

        RopCalculationService.RopResult result =
                ropService.computeAndUpdateAllRop(lookback, userId);

        StringBuilder json = new StringBuilder(256);
        json.append("{\"success\":true,")
            .append("\"processed\":").append(result.processed).append(",")
            .append("\"updated\":").append(result.updated).append(",")
            .append("\"noData\":").append(result.noData).append(",")
            .append("\"errors\":").append(result.errors).append(",")
            .append("\"elapsedMs\":").append(result.elapsedMs).append(",")
            .append("\"message\":\"").append(esc(result.message)).append("\"}");
        resp.getWriter().write(json.toString());
    }

    /** GET /api/rop/status — last log per product */
    private void getStatus(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        String sql =
            "SELECT rl.product_id, p.sku_code, rl.run_at, rl.d_avg, rl.d_max, "
            + "rl.l_avg, rl.l_max, rl.safety_stock, rl.rop_before, rl.rop_after "
            + "FROM (SELECT product_id, MAX(log_id) AS max_log FROM product_rop_log GROUP BY product_id) latest "
            + "JOIN product_rop_log rl ON rl.log_id = latest.max_log "
            + "JOIN products p ON p.product_id = rl.product_id "
            + "ORDER BY rl.run_at DESC LIMIT 200";
        try (java.sql.Connection conn = com.wms.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             java.sql.ResultSet rs = ps.executeQuery()) {
            StringBuilder sb = new StringBuilder("[");
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                first = false;
                sb.append("{")
                  .append("\"productId\":").append(rs.getInt("product_id")).append(",")
                  .append("\"sku\":\"").append(esc(rs.getString("sku_code"))).append("\",")
                  .append("\"runAt\":\"").append(rs.getTimestamp("run_at")).append("\",")
                  .append("\"dAvg\":").append(nullOr(rs.getBigDecimal("d_avg"))).append(",")
                  .append("\"dMax\":").append(nullOr(rs.getBigDecimal("d_max"))).append(",")
                  .append("\"lAvg\":").append(nullOr(rs.getBigDecimal("l_avg"))).append(",")
                  .append("\"lMax\":").append(nullOr(rs.getBigDecimal("l_max"))).append(",")
                  .append("\"safetyStock\":").append(nullOr(rs.getBigDecimal("safety_stock"))).append(",")
                  .append("\"ropBefore\":").append(nullOr(rs.getBigDecimal("rop_before"))).append(",")
                  .append("\"ropAfter\":").append(nullOr(rs.getBigDecimal("rop_after"))).append("}");
            }
            sb.append("]");
            resp.getWriter().write("{\"success\":true,\"logs\":" + sb + "}");
        } catch (java.sql.SQLException e) {
            LOGGER.warning("RopServlet.getStatus failed: " + e.getMessage());
            writeError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi truy vấn: " + e.getMessage());
        }
    }

    /** GET /api/rop/product/{id} */
    private void getProductRop(HttpServletRequest req, HttpServletResponse resp, String pathInfo)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        String idStr = pathInfo.substring("/product/".length());
        int productId;
        try { productId = Integer.parseInt(idStr); }
        catch (NumberFormatException e) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "Invalid product ID");
            return;
        }

        String sql = "SELECT product_id, sku_code, qty_on_hand, min_stock, rop_calculated, "
                + "d_avg, d_max, l_avg, l_max, safety_stock "
                + "FROM products p "
                + "LEFT JOIN (SELECT product_id, SUM(qty_on_hand) AS qty_on_hand FROM inventory GROUP BY product_id) i "
                + "  ON p.product_id = i.product_id "
                + "WHERE p.product_id = ?";
        try (java.sql.Connection conn = com.wms.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    writeError(resp, HttpServletResponse.SC_NOT_FOUND, "Product not found");
                    return;
                }
                double qtyOnHand = rs.getBigDecimal("qty_on_hand") != null
                        ? rs.getBigDecimal("qty_on_hand").doubleValue() : 0.0;
                double rop = rs.getBigDecimal("rop_calculated") != null
                        ? rs.getBigDecimal("rop_calculated").doubleValue() : 0.0;
                boolean belowRop = qtyOnHand <= rop && rop > 0;

                StringBuilder sb = new StringBuilder(256);
                sb.append("{\"success\":true,\"product\":{")
                  .append("\"productId\":").append(rs.getInt("product_id")).append(",")
                  .append("\"sku\":\"").append(esc(rs.getString("sku_code"))).append("\",")
                  .append("\"qtyOnHand\":").append(qtyOnHand).append(",")
                  .append("\"minStock\":").append(nullOr(rs.getBigDecimal("min_stock"))).append(",")
                  .append("\"ropCalculated\":").append(rop).append(",")
                  .append("\"dAvg\":").append(nullOr(rs.getBigDecimal("d_avg"))).append(",")
                  .append("\"dMax\":").append(nullOr(rs.getBigDecimal("d_max"))).append(",")
                  .append("\"lAvg\":").append(nullOr(rs.getBigDecimal("l_avg"))).append(",")
                  .append("\"lMax\":").append(nullOr(rs.getBigDecimal("l_max"))).append(",")
                  .append("\"safetyStock\":").append(nullOr(rs.getBigDecimal("safety_stock"))).append(",")
                  .append("\"belowRop\":").append(belowRop).append("}}");
                resp.getWriter().write(sb.toString());
            }
        } catch (java.sql.SQLException e) {
            LOGGER.warning("RopServlet.getProductRop failed: " + e.getMessage());
            writeError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi: " + e.getMessage());
        }
    }

    // ── Helpers ─────────────────────────────────────────────────────────

    private boolean isManagerOrAdmin(HttpServletRequest req) {
        Object u = req.getSession().getAttribute(AppConstants.SESSION_USER);
        if (u instanceof User) {
            String role = ((User) u).getRole();
            return "MANAGER".equalsIgnoreCase(role) || "ADMIN".equalsIgnoreCase(role);
        }
        return false;
    }

    private int currentUserId(HttpServletRequest req) {
        Object u = req.getSession().getAttribute(AppConstants.SESSION_USER);
        if (u instanceof User) return ((User) u).getUserId();
        return 1;
    }

    private void writeError(HttpServletResponse resp, int code, String msg) throws IOException {
        resp.setStatus(code);
        resp.getWriter().write("{\"success\":false,\"message\":\"" + esc(msg) + "\"}");
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\","\\\\").replace("\"","\\\"").replace("\n"," ").replace("\r","");
    }

    private String nullOr(BigDecimal v) {
        if (v == null) return "null";
        return v.setScale(4, RoundingMode.HALF_UP).toPlainString();
    }

    private int parseInt(String s, int fallback) {
        if (s == null || s.trim().isEmpty()) return fallback;
        try { return Integer.parseInt(s.trim()); }
        catch (NumberFormatException e) { return fallback; }
    }
}
