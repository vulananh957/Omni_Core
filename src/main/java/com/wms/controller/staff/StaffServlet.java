package com.wms.controller.staff;

import com.wms.controller.BaseController;
import com.wms.model.User;
import com.wms.model.Warehouse;
import com.wms.service.user.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import com.wms.util.AppConstants;

/**
 * StaffServlet — Handles requests for the Staff Management page.
 *
 * Maps to /business/staff
 */
public class StaffServlet extends BaseController {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            List<User> staffList = userService.findByRoles("MANAGER", "SALES_STAFF", "WAREHOUSE_STAFF");
            List<Warehouse> warehouses = findWarehouses();

            Map<Integer, String> warehouseMap = warehouses.stream()
                .collect(Collectors.toMap(Warehouse::getWarehouseId, Warehouse::getWarehouseName, (v1, v2) -> v1));

            req.setAttribute("pageTitle",    "Quản Lý Nhân Sự");
            req.setAttribute("pageSubtitle", "Giám sát, luân chuyển vai trò và quản lý trạng thái kích hoạt tài khoản hệ thống");
            req.setAttribute("currentPage",  "staff");
            req.setAttribute("warehouses",   warehouses);

            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < staffList.size(); i++) {
                User u = staffList.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"userId\":").append(u.getUserId()).append(",");
                json.append("\"username\":\"").append(escapeJson(u.getUsername())).append("\",");
                json.append("\"fullName\":\"").append(escapeJson(u.getFullName())).append("\",");
                json.append("\"email\":\"").append(escapeJson(u.getEmail() != null ? u.getEmail() : "")).append("\",");
                json.append("\"phone\":\"").append(escapeJson(u.getPhone() != null ? u.getPhone() : "")).append("\",");
                json.append("\"role\":\"").append(roleToJsFormat(u.getRole())).append("\",");
                json.append("\"status\":\"").append(u.isActive() ? "active" : "inactive").append("\",");
                String branchName = "";
                if ("warehouse_staff".equals(roleToJsFormat(u.getRole()))) {
                    branchName = warehouseMap.getOrDefault(u.getWarehouseId(), "Chưa gán kho");
                }
                json.append("\"warehouseId\":").append(u.getWarehouseId()).append(",");
                json.append("\"branch\":\"").append(escapeJson(branchName)).append("\"");
                json.append("}");
            }
            json.append("]");

            req.setAttribute("staffListJson", json.toString());
            req.setAttribute("contentPage", "/WEB-INF/views/staff/staff.jsp");

            req.getRequestDispatcher("/WEB-INF/views/layout/dashboard-layout.jsp")
               .forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Database error loading staff list", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String userIdStr = req.getParameter("userId");
        String roleStr = req.getParameter("role");
        String activeStr = req.getParameter("active");
        String warehouseIdStr = req.getParameter("warehouseId");

        if (isNullOrEmpty(userIdStr) || isNullOrEmpty(roleStr) || isNullOrEmpty(activeStr)) {
            writeJson(resp, "{\"success\":false,\"message\":\"Thiếu thông tin yêu cầu.\"}");
            return;
        }

        try {
            int userId = Integer.parseInt(userIdStr);
            boolean active = Boolean.parseBoolean(activeStr);

            String dbRole = mapFrontendRoleToDb(roleStr);
            if (dbRole == null) {
                writeJson(resp, "{\"success\":false,\"message\":\"Vai trò không hợp lệ.\"}");
                return;
            }

            var userOpt = userService.findById(userId);
            if (userOpt.isEmpty()) {
                writeJson(resp, "{\"success\":false,\"message\":\"Không tìm thấy nhân viên.\"}");
                return;
            }

            User loggedInUser = (User) req.getSession().getAttribute(AppConstants.SESSION_USER);
            if (loggedInUser != null && loggedInUser.getUserId() == userId) {
                writeJson(resp, "{\"success\":false,\"message\":\"Bạn không thể tự thay đổi vai trò hoặc trạng thái hoạt động của chính mình.\"}");
                return;
            }

            User user = userOpt.get();
            user.setRole(dbRole);
            user.setActive(active);
            if ("WAREHOUSE_STAFF".equals(dbRole)) {
                if (!isNullOrEmpty(warehouseIdStr) && !"0".equals(warehouseIdStr)) {
                    user.setWarehouseId(Integer.parseInt(warehouseIdStr));
                } else {
                    user.setWarehouseId(0);
                }
            } else {
                user.setWarehouseId(0);
            }

            boolean updated = userService.updateUserFull(user);
            if (updated) {
                writeJson(resp, "{\"success\":true}");
            } else {
                writeJson(resp, "{\"success\":false,\"message\":\"Không thể cập nhật thông tin trong cơ sở dữ liệu.\"}");
            }
        } catch (NumberFormatException e) {
            writeJson(resp, "{\"success\":false,\"message\":\"Định dạng ID người dùng không hợp lệ.\"}");
        } catch (SQLException e) {
            writeJson(resp, "{\"success\":false,\"message\":\"Lỗi cơ sở dữ liệu: " + e.getMessage() + "\"}");
        }
    }

    private String mapFrontendRoleToDb(String roleStr) {
        switch (roleStr) {
            case "business_manager": return "MANAGER";
            case "sales_staff": return "SALES_STAFF";
            case "warehouse_staff": return "WAREHOUSE_STAFF";
            default: return null;
        }
    }

    private String roleToJsFormat(String role) {
        if (role == null) return "warehouse_staff";
        String lower = role.toLowerCase().replace("  ", " ").replace(" ", "_");
        switch (lower) {
            case "admin": return "admin";
            case "manager": case "business_manager": return "business_manager";
            case "sales_staff": return "sales_staff";
            case "warehouse_staff": return "warehouse_staff";
            default: return lower;
        }
    }



    private List<Warehouse> findWarehouses() {
        try {
            return new com.wms.service.warehouse.WarehouseService().findAll();
        } catch (SQLException e) {
            return List.of();
        }
    }
}
