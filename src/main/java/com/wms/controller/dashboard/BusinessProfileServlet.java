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
                // OTP flow for password change:
                //   1. User has called initPasswordChange → OTP generated and stored in session
                //   2. User enters OTP in the form, submits with action="updatePassword"
                //   3. Servlet validates OTP matches session → calls UserService to update password
                String otp = req.getParameter("otp");
                String newPassword = (String) session.getAttribute("pwdChangePendingNewPassword");

                if (newPassword == null) {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Bạn cần khởi tạo đổi mật khẩu trước (initPasswordChange).\"}");
                    return;
                }
                if (otp == null || otp.trim().isEmpty()) {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Vui lòng nhập mã OTP.\"}");
                    return;
                }

                String sessionOtp = (String) session.getAttribute("pwdChangeOtp");
                java.time.LocalDateTime expiresAt = (java.time.LocalDateTime) session.getAttribute("pwdChangeOtpExpires");
                java.time.LocalDateTime now = java.time.LocalDateTime.now();

                if (sessionOtp == null || expiresAt == null || now.isAfter(expiresAt)) {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Mã OTP đã hết hạn. Vui lòng yêu cầu mã mới.\"}");
                    return;
                }
                if (!sessionOtp.equals(otp.trim())) {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Mã OTP không chính xác.\"}");
                    return;
                }

                // OTP hợp lệ → hash mật khẩu mới rồi cập nhật
                try {
                    String newHash = org.mindrot.jbcrypt.BCrypt.hashpw(newPassword, org.mindrot.jbcrypt.BCrypt.gensalt(12));
                    userService.updatePasswordDirect(sessionUser.getUserId(), newHash);
                    // Xóa session OTP sau khi dùng
                    session.removeAttribute("pwdChangeOtp");
                    session.removeAttribute("pwdChangeOtpExpires");
                    session.removeAttribute("pwdChangePendingNewPassword");
                    resp.getWriter().write("{\"success\":true,\"message\":\"Đổi mật khẩu thành công!\"}");
                } catch (SQLException e) {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống: " + e.getMessage() + "\"}");
                }

            } else if ("initPasswordChange".equals(action)) {
                // Initialises OTP for password change.
                String newPassword = req.getParameter("newPassword");
                if (newPassword == null || newPassword.length() < 8) {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Mật khẩu mới phải có ít nhất 8 ký tự\"}");
                    return;
                }
                session.setAttribute("pwdChangePendingNewPassword", newPassword);

                // Generate a 6-digit OTP, valid for 5 minutes
                String otp = String.format("%06d", (int)(Math.random() * 1_000_000));
                session.setAttribute("pwdChangeOtp", otp);
                session.setAttribute("pwdChangeOtpExpires", java.time.LocalDateTime.now().plusMinutes(5));
                // Trong thực tế sẽ gửi qua email/SMS. Ở đây trả về cho test/dev.
                resp.getWriter().write("{\"success\":true,\"message\":\"Mã OTP của bạn là: " + otp
                    + " (có hiệu lực 5 phút)\"}");

            } else {
                resp.getWriter().write("{\"success\":false,\"message\":\"Hành động không xác định\"}");
            }
        } catch (Exception e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống: " + e.getMessage() + "\"}");
        }
    }
}
