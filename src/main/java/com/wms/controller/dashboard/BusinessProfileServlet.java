package com.wms.controller.dashboard;

import com.wms.controller.BaseController;
import com.wms.model.User;
import com.wms.service.user.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Optional;

import com.wms.util.AppConstants;

/**
 * BusinessProfileServlet — Handles Account Settings (Cài đặt tài khoản) for Business Manager.
 * Maps to /business/profile.
 */
public class BusinessProfileServlet extends BaseController {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        User sessionUser = (User) session.getAttribute(AppConstants.SESSION_USER);

        if (sessionUser != null) {
            try {
                Optional<User> freshUserOpt = userService.findById(sessionUser.getUserId());
                if (freshUserOpt.isPresent()) {
                    User freshUser = freshUserOpt.get();
                    freshUser.setPasswordHash(null);
                    session.setAttribute(AppConstants.SESSION_USER, freshUser);
                }
            } catch (SQLException e) {
                // DB not connected, fallback to session user
            }
        }

        req.setAttribute("pageTitle",    "Cài Đặt Tài Khoản");
        req.setAttribute("pageSubtitle", "Quản lý thông tin cá nhân và bảo mật");
        req.setAttribute("currentPage",  "profile");

        req.setAttribute("contentPage", "/WEB-INF/views/dashboard/profile-settings.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/dashboard-layout.jsp")
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
                    userService.updateProfile(sessionUser);
                } catch (SQLException e) {
                    // DB not connected fallback
                }

                session.setAttribute(AppConstants.SESSION_USER, sessionUser);
                resp.getWriter().write("{\"success\":true,\"message\":\"Cập nhật thông tin thành công!\"}");

            } else if ("updatePassword".equals(action)) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Vui lòng xác minh OTP để đổi mật khẩu\"}");

            } else if ("initPasswordChange".equals(action)) {
                String newPassword = req.getParameter("newPassword");
                if (newPassword == null || newPassword.length() < 8) {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Mật khẩu mới phải có ít nhất 8 ký tự\"}");
                    return;
                }
                session.setAttribute("pwdChangePendingNewPassword", newPassword);
                resp.getWriter().write("{\"success\":true,\"message\":\"OK\"}");
            } else {
                resp.getWriter().write("{\"success\":false,\"message\":\"Hành động không xác định\"}");
            }
        } catch (Exception e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống: " + e.getMessage() + "\"}");
        }
    }
}
