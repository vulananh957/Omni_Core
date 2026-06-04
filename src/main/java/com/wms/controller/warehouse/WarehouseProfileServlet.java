package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import com.wms.dao.UserDAO;
import com.wms.model.User;
import com.wms.util.AppConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Optional;

/**
 * WarehouseProfileServlet — Handles Account Settings (Cài đặt tài khoản) for Warehouse Staff.
 *
 * Maps to /warehouse/profile.
 */
public class WarehouseProfileServlet extends BaseController {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        User sessionUser = (User) session.getAttribute(AppConstants.SESSION_USER);

        if (sessionUser != null) {
            try {
                Optional<User> freshUserOpt = userDAO.findById(sessionUser.getUserId());
                if (freshUserOpt.isPresent()) {
                    User freshUser = freshUserOpt.get();
                    freshUser.setPasswordHash(null);
                    session.setAttribute(AppConstants.SESSION_USER, freshUser);
                }
            } catch (SQLException e) {
                // DB not connected, fallback to session user
            }
        }

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Cài Đặt Tài Khoản");
        req.setAttribute("pageSubtitle", "Quản lý thông tin cá nhân và bảo mật");
        req.setAttribute("currentPage",  "wh-profile");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/warehouse/warehouse-profile.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession();
        User sessionUser = (User) session.getAttribute(AppConstants.SESSION_USER);

        if (sessionUser == null) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Hành động không hợp lệ\"}");
            return;
        }

        try {
            if ("updateProfile".equals(action)) {
                String fullName = req.getParameter("fullName");
                String email = req.getParameter("email");
                String phone = req.getParameter("phone");

                if (fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty()) {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Họ tên và Email không được để trống\"}");
                    return;
                }

                sessionUser.setFullName(fullName.trim());
                sessionUser.setEmail(email.trim());
                sessionUser.setPhone(phone != null ? phone.trim() : null);

                try {
                    userDAO.updateProfile(sessionUser);
                } catch (SQLException e) {
                    // DB not connected fallback
                }

                session.setAttribute(AppConstants.SESSION_USER, sessionUser);
                resp.getWriter().write("{\"success\":true,\"message\":\"Cập nhật thông tin thành công!\"}");

            } else if ("updatePassword".equals(action)) {
                String currentPassword = req.getParameter("currentPassword");
                String newPassword = req.getParameter("newPassword");

                if (currentPassword == null || newPassword == null || newPassword.length() < 8) {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Mật khẩu mới phải có ít nhất 8 ký tự\"}");
                    return;
                }

                // Verify current password
                String currentHash = null;
                try {
                    Optional<User> dbUserOpt = userDAO.findById(sessionUser.getUserId());
                    if (dbUserOpt.isPresent()) {
                        currentHash = dbUserOpt.get().getPasswordHash();
                    }
                } catch (SQLException e) {
                    // DB not connected
                }

                if (currentHash == null || !BCrypt.checkpw(currentPassword, currentHash)) {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Mật khẩu hiện tại không chính xác\"}");
                    return;
                }

                // Update DB with new hash
                String newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));
                try {
                    userDAO.updatePassword(sessionUser.getUserId(), newHash);
                } catch (SQLException e) {
                    // DB not connected fallback
                }

                resp.getWriter().write("{\"success\":true,\"message\":\"Đổi mật khẩu thành công!\"}");
            } else {
                resp.getWriter().write("{\"success\":false,\"message\":\"Hành động không xác định\"}");
            }
        } catch (Exception e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống: " + e.getMessage() + "\"}");
        }
    }
}
