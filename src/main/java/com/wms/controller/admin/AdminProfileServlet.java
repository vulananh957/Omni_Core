package com.wms.controller.admin;

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
 * AdminProfileServlet — Handles Account Settings (Cài đặt tài khoản) and 2FA/OTP Configuration.
 * Maps to /admin/profile.
 */
public class AdminProfileServlet extends BaseController {

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
        req.setAttribute("pageSubtitle", "Quản lý thông tin cá nhân và bảo mật tài khoản quản trị");
        req.setAttribute("currentPage",  "admin-profile");

        req.setAttribute("contentPage", "/WEB-INF/views/admin/admin-profile.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/admin-layout.jsp")
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
                handleUpdateProfile(req, resp, sessionUser, session);
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
            } else if ("updateOtp".equals(action)) {
                handleUpdateOtp(req, resp, sessionUser, session);
            } else if ("updateUsername".equals(action)) {
                handleUpdateUsername(req, resp, sessionUser, session);
            } else {
                resp.getWriter().write("{\"success\":false,\"message\":\"Hành động không xác định\"}");
            }
        } catch (Exception e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống: " + e.getMessage() + "\"}");
        }
    }

    private void handleUpdateProfile(HttpServletRequest req, HttpServletResponse resp,
                                     User sessionUser, HttpSession session) throws IOException {
        String username = req.getParameter("username");
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");

        if (username == null || username.trim().isEmpty()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Username không được để trống\"}");
            return;
        }

        username = username.trim();
        if (username.length() < 3 || username.length() > 30) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Username phải từ 3 đến 30 ký tự\"}");
            return;
        }

        if (!username.matches("^[a-zA-Z0-9_]+$")) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Username chỉ được chứa chữ, số và dấu gạch dưới\"}");
            return;
        }

        try {
            if (userService.isUsernameTaken(username, sessionUser.getUserId())) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Username đã được sử dụng\"}");
                return;
            }
        } catch (SQLException e) {
            // DB not connected fallback
        }

        if (fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Họ tên và Email không được để trống\"}");
            return;
        }

        sessionUser.setUsername(username);
        sessionUser.setFullName(fullName.trim());
        sessionUser.setEmail(email.trim());
        sessionUser.setPhone(phone != null ? phone.trim() : null);

        try {
            userService.updateUsername(sessionUser.getUserId(), username);
            userService.updateProfile(sessionUser);
        } catch (SQLException e) {
            // DB not connected fallback
        }

        session.setAttribute(AppConstants.SESSION_USER, sessionUser);
        resp.getWriter().write("{\"success\":true,\"message\":\"Cập nhật thông tin thành công!\"}");
    }

    private void handleUpdateOtp(HttpServletRequest req, HttpServletResponse resp,
                                 User sessionUser, HttpSession session) throws IOException {
        String otpPreference = req.getParameter("otpPreference");
        if (!"EMAIL".equals(otpPreference) && !"SMS".equals(otpPreference)) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Cấu hình OTP không hợp lệ\"}");
            return;
        }

        sessionUser.setOtpPreference(otpPreference);
        try {
            userService.updateOtpPreference(sessionUser.getUserId(), otpPreference);
        } catch (SQLException e) {
            // DB not connected fallback
        }

        session.setAttribute(AppConstants.SESSION_USER, sessionUser);
        resp.getWriter().write("{\"success\":true,\"message\":\"Cập nhật cấu hình OTP thành công!\"}");
    }

    private void handleUpdateUsername(HttpServletRequest req, HttpServletResponse resp,
                                     User sessionUser, HttpSession session) throws IOException {
        String newUsername = req.getParameter("newUsername");
        if (newUsername == null || newUsername.trim().isEmpty()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Username không được để trống\"}");
            return;
        }

        newUsername = newUsername.trim();
        if (newUsername.length() < 3 || newUsername.length() > 30) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Username phải từ 3 đến 30 ký tự\"}");
            return;
        }

        if (!newUsername.matches("^[a-zA-Z0-9_]+$")) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Username chỉ được chứa chữ, số và dấu gạch dưới\"}");
            return;
        }

        try {
            if (userService.isUsernameTaken(newUsername, sessionUser.getUserId())) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Username đã được sử dụng\"}");
                return;
            }
            userService.updateUsername(sessionUser.getUserId(), newUsername);
            sessionUser.setUsername(newUsername);
            session.setAttribute(AppConstants.SESSION_USER, sessionUser);
            resp.getWriter().write("{\"success\":true,\"message\":\"Đổi username thành công!\"}");
        } catch (SQLException e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi cơ sở dữ liệu\"}");
        }
    }
}
