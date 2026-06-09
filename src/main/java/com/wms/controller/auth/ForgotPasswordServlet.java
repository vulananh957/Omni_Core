package com.wms.controller.auth;

import com.wms.controller.BaseController;
import com.wms.dao.UserDAO;
import com.wms.model.User;
import com.wms.service.auth.EmailService;
import com.wms.util.AppConstants;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.Optional;
import java.util.concurrent.TimeUnit;

/**
 * ForgotPasswordServlet — Handles the "forgot password" flow.
 * 
 * Flow:
 * 1. GET  /forgot-password            → show email entry form
 * 2. POST /forgot-password?action=request → find user by email/username, send OTP, redirect to verify page
 * 3. GET  /reset-password             → show OTP + new password form
 * 4. POST /reset-password?action=verify  → verify OTP, update password, redirect to login
 */
public class ForgotPasswordServlet extends BaseController {

    private static final String FLASH_ERROR = "fpError";
    private static final String FLASH_SUCCESS = "fpSuccess";

    private final UserDAO userDAO = new UserDAO();
    private final EmailService emailService = new EmailService();
    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        bindFlashMessages(req, session);
        forward(req, res, "auth/forgot-password");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("request".equalsIgnoreCase(action)) {
            handleRequest(req, res);
        } else {
            res.sendRedirect(req.getContextPath() + "/forgot-password");
        }
    }

    private void handleRequest(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(true);
        String identifier = req.getParameter("identifier");

        if (isNullOrEmpty(identifier)) {
            session.setAttribute(FLASH_ERROR, "Vui lòng nhập Email hoặc Username.");
            res.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        identifier = identifier.trim();

        // Find user by email or username
        Optional<User> userOpt;
        try {
            userOpt = userDAO.findByEmail(identifier);
            if (userOpt.isEmpty()) {
                userOpt = userDAO.findByUsername(identifier);
            }
        } catch (Exception e) {
            userOpt = Optional.empty();
        }

        if (userOpt.isEmpty()) {
            session.setAttribute(FLASH_ERROR, "Không tìm thấy tài khoản với Email hoặc Username này.");
            res.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        User user = userOpt.get();

        if (isNullOrEmpty(user.getEmail())) {
            session.setAttribute(FLASH_ERROR, "Tài khoản này chưa đăng ký Email. Vui lòng liên hệ quản trị viên.");
            res.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        long now = System.currentTimeMillis();

        // Rate limit: 60 seconds between requests
        Long lastSent = (Long) session.getAttribute("fpOtpSentTime");
        if (lastSent != null && (now - lastSent) < 60_000) {
            long remaining = 60 - ((now - lastSent) / 1000);
            session.setAttribute(FLASH_ERROR, "Vui lòng đợi " + remaining + " giây trước khi yêu cầu mã mới.");
            res.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        // Generate 6-digit OTP
        String otpCode = generate6DigitOtp();
        long expiresAt = now + TimeUnit.MINUTES.toMillis(AppConstants.OTP_EXPIRY_MINUTES);

        // Send OTP via email
        boolean sent = emailService.sendOtpCode(user, otpCode, expiresAt);

        if (!sent) {
            session.setAttribute(FLASH_ERROR, "Không thể gửi mã OTP qua Email. Vui lòng kiểm tra cấu hình SMTP.");
            res.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        // Store in session
        session.setAttribute("fpUserId", user.getUserId());
        session.setAttribute("fpPendingOtp", otpCode);
        session.setAttribute("fpPendingOtpExpires", expiresAt);
        session.setAttribute("fpOtpSentTime", now);
        session.setAttribute("fpEmailDest", maskEmail(user.getEmail()));

        session.setAttribute(FLASH_SUCCESS, "Mã xác thực đã được gửi đến Email của bạn.");
        res.sendRedirect(req.getContextPath() + "/reset-password");
    }

    private String generate6DigitOtp() {
        int code = secureRandom.nextInt(1000000);
        return String.format("%06d", code);
    }

    private String maskEmail(String email) {
        if (isNullOrEmpty(email)) return "";
        int atIndex = email.indexOf('@');
        if (atIndex < 2) return "***";
        String localPart = email.substring(0, atIndex);
        String domainPart = email.substring(atIndex);
        if (localPart.length() <= 3) {
            return localPart.substring(0, 1) + "***" + domainPart;
        }
        return localPart.substring(0, 2) + "***" + localPart.substring(localPart.length() - 1) + domainPart;
    }

    private void bindFlashMessages(HttpServletRequest req, HttpSession session) {
        if (session == null) return;
        String flashError = (String) session.getAttribute(FLASH_ERROR);
        if (flashError != null) {
            req.setAttribute("errorMessage", flashError);
            session.removeAttribute(FLASH_ERROR);
        }
        String flashSuccess = (String) session.getAttribute(FLASH_SUCCESS);
        if (flashSuccess != null) {
            req.setAttribute("successMessage", flashSuccess);
            session.removeAttribute(FLASH_SUCCESS);
        }
    }

}
