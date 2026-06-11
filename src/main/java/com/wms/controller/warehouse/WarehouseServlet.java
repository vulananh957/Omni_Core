package com.wms.controller.warehouse;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.controller.BaseController;
import com.wms.dao.WarehouseDAO;
import com.wms.model.Warehouse;
import com.wms.model.Zone;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * WarehouseServlet — Handles requests for the Warehouse List page and AJAX APIs.
 * 
 * Maps to /business/warehouses.
 */
public class WarehouseServlet extends BaseController {

    private static final Logger LOGGER = Logger.getLogger(WarehouseServlet.class.getName());
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("list".equals(action)) {
            handleList(req, resp);
            return;
        }

        // Regular page load
        req.setAttribute("pageTitle",    "Danh Sách Kho Hàng");
        req.setAttribute("pageSubtitle", "Quản lý thông tin, phân khu lưu trữ và trạng thái các chi nhánh kho");
        req.setAttribute("currentPage",  "warehouses");
        req.setAttribute("contentPage", "/WEB-INF/views/warehouse/warehouses.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/dashboard-layout.jsp")
           .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        try {
            if ("save".equals(action)) {
                handleSave(req, resp);
            } else if ("toggleStatus".equals(action)) {
                handleToggleStatus(req, resp);
            } else {
                writeJson(resp, "{\"success\":false,\"message\":\"Hành động không hợp lệ.\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "WarehouseServlet.doPost error: ", e);
            writeJson(resp, "{\"success\":false,\"message\":\"Đã xảy ra lỗi hệ thống: " + e.getMessage() + "\"}");
        }
    }

    private void handleList(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            List<Warehouse> list = warehouseDAO.findAll();
            String json = objectMapper.writeValueAsString(list);
            writeJson(resp, json);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "WarehouseServlet.handleList error: ", e);
            writeJson(resp, "[]");
        }
    }

    private void handleSave(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            Warehouse w = objectMapper.readValue(req.getReader(), Warehouse.class);

            if (w == null || isNullOrEmpty(w.getWarehouseCode()) || isNullOrEmpty(w.getWarehouseName())) {
                writeJson(resp, "{\"success\":false,\"message\":\"Thiếu thông tin bắt buộc (mã kho, tên kho).\"}");
                return;
            }

            // Map and format codes/names
            w.setWarehouseCode(w.getWarehouseCode().trim().toUpperCase());
            w.setWarehouseName(w.getWarehouseName().trim());
            w.setAddress(w.getAddress() != null ? w.getAddress().trim() : "");
            w.setPhone(w.getPhone() != null ? w.getPhone().trim() : "");

            // Assign warehouseCode prefix to all zones if they don't have it
            List<Zone> zones = w.getZones();
            if (zones != null) {
                for (Zone z : zones) {
                    if (z.getZoneCode() == null || z.getZoneCode().trim().isEmpty()) {
                        // Generate code from type
                        z.setZoneCode(w.getWarehouseCode() + "-" + z.getZoneType().substring(0, 4).toUpperCase());
                    } else {
                        z.setZoneCode(z.getZoneCode().trim().toUpperCase());
                    }
                    z.setZoneName(z.getZoneName().trim());
                    z.setActive(true); // default to active when saved
                }
            }

            boolean success;
            if (w.getWarehouseId() > 0) {
                success = warehouseDAO.update(w, zones);
            } else {
                success = warehouseDAO.insert(w, zones);
            }

            if (success) {
                writeJson(resp, "{\"success\":true}");
            } else {
                writeJson(resp, "{\"success\":false,\"message\":\"Không thể lưu thông tin kho. Vui lòng kiểm tra trùng mã kho.\"}");
            }

        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "WarehouseServlet.handleSave error: ", e);
            writeJson(resp, "{\"success\":false,\"message\":\"Lỗi định dạng dữ liệu: " + e.getMessage() + "\"}");
        }
    }

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idStr = req.getParameter("id");
        String activeStr = req.getParameter("active");

        if (isNullOrEmpty(idStr) || isNullOrEmpty(activeStr)) {
            writeJson(resp, "{\"success\":false,\"message\":\"Thiếu tham số ID hoặc trạng thái.\"}");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            boolean active = Boolean.parseBoolean(activeStr);
            boolean success = warehouseDAO.toggleStatus(id, active);
            if (success) {
                writeJson(resp, "{\"success\":true}");
            } else {
                writeJson(resp, "{\"success\":false,\"message\":\"Không thể thay đổi trạng thái kho.\"}");
            }
        } catch (NumberFormatException e) {
            writeJson(resp, "{\"success\":false,\"message\":\"ID không hợp lệ.\"}");
        }
    }
}
