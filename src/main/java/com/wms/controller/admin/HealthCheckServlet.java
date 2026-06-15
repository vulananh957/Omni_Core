package com.wms.controller.admin;

import com.fasterxml.jackson.databind.node.ObjectNode;
import com.wms.util.DBConnection;
import com.wms.util.JsonUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * HealthCheckServlet — Provides a lightweight health endpoint for monitoring
 * and load-balancer readiness probes.
 *
 * GET /health
 * Returns HTTP 200 with JSON body when all components are healthy.
 * Returns HTTP 503 when any component is unhealthy.
 *
 * No authentication required.
 */
@WebServlet(name = "HealthCheckServlet", urlPatterns = { "/health" })
public class HealthCheckServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(HealthCheckServlet.class.getName());

    private volatile long startupTime;

    @Override
    public void init() {
        startupTime = System.currentTimeMillis();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        ObjectNode root = JsonUtil.getMapper().createObjectNode();
        ObjectNode checks = JsonUtil.getMapper().createObjectNode();

        boolean allHealthy = true;

        // 1. Database health
        boolean dbHealthy = checkDatabase();
        checks.put("database", dbHealthy ? "UP" : "DOWN");
        if (!dbHealthy)
            allHealthy = false;

        // 2. Disk space (Tomcat catalina.base or fallback to user home)
        String diskStatus = checkDiskSpace();
        checks.put("disk", diskStatus);

        root.set("checks", checks);
        root.put("status", allHealthy ? "UP" : "DEGRADED");
        root.put("uptime_seconds", getUptimeSeconds());
        root.put("timestamp", java.time.Instant.now().toString());

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (allHealthy) {
            response.setStatus(HttpServletResponse.SC_OK);
        } else {
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
        }

        try (PrintWriter out = response.getWriter()) {
            JsonUtil.getMapper().writerWithDefaultPrettyPrinter().writeValue(out, root);
        }
    }

    private boolean checkDatabase() {
        String sql = "SELECT 1";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            return rs.next();
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "HealthCheck: Database health check failed", e);
            return false;
        }
    }

    private String checkDiskSpace() {
        try {
            String catalinaBase = System.getProperty("catalina.base");
            java.io.File dir = (catalinaBase != null)
                    ? new java.io.File(catalinaBase)
                    : new java.io.File(System.getProperty("user.home"));

            long usable = dir.getUsableSpace();
            long total = dir.getTotalSpace();
            if (total == 0)
                return "UNKNOWN";

            double usablePct = (double) usable / total * 100;
            if (usablePct < 5) {
                LOGGER.log(Level.WARNING, "HealthCheck: Disk space critically low: "
                        + String.format("%.1f%%", usablePct) + " remaining");
                return "LOW";
            }
            return "OK";
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "HealthCheck: Disk space check failed", e);
            return "UNKNOWN";
        }
    }

    private long getUptimeSeconds() {
        return (System.currentTimeMillis() - startupTime) / 1000;
    }
}
