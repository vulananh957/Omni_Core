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
import java.util.concurrent.TimeUnit;

/**
 * ResetPasswordServlet — Handles OTP verification and setting new password for forgot password flow.
 */
public class ResetPasswordServlet extends BaseController {

    private static final String FLASH_ERROR = "rpError";
    private static final String FLASH_SUCCESS = "rpSuccess";

    private final UserDAO userDAO = new UserDAO();
    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        // Check if user has initiated forgot password flow
        Integer fpUserId = (Integer) session.getAttribute("fpUserId");
        String pendingOtp = (String) session.getAttribute("fpPendingOtp");
        Long expiresAt = (Long) session.getAttribute("fpPendingOtpExpires");
        String emailDest = (String) session.getAttribute("fpEmailDest");

        if (fpUserId == null || pendingOtp == null) {
            res.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        // Check if OTP expired
        long now = System.currentTimeMillis();
        if (expiresAt != null && now > expiresAt) {
            session.removeAttribute("fpPendingOtp");
            session.removeAttribute("fpPendingOtpExpires");
            session.removeAttribute("fpUserId");
            session.setAttribute(FLASH_ERROR, "Mã xác thực đã hết hạn. Vui lòng yêu cầu mã mới.");
            res.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        // Load user info
        try {
            var userOpt = userDAO.findById(fpUserId);
            if (userOpt.isPresent()) {
                req.setAttribute("userName", userOpt.get().getFullName());
            }
        } catch (Exception e) {
            // Ignore
        }

        req.setAttribute("emailDestination", emailDest != null ? emailDest : "Email của bạn");
        bindFlashMessages(req, session);
        forward(req, res, "auth/reset-password");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        HttpSession session = req.getSession(false);
        String action = req.getParameter("action");

        if ("verify".equalsIgnoreCase(action)) {
            handleVerify(req, res, session);
        } else if ("resend".equalsIgnoreCase(action)) {
            handleResend(req, res, session);
        } else {
            res.sendRedirect(req.getContextPath() + "/reset-password");
        }
    }

    private void handleVerify(HttpServletRequest req, HttpServletResponse res, HttpSession session) throws IOException {
        String otpInput = req.getParameter("otp");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        // Validate OTP
        if (isNullOrEmpty(otpInput) || !otpInput.matches("\\d{6}")) {
            session.setAttribute(FLASH_ERROR, "Vui lòng nhập mã OTP gồm 6 chữ số.");
            res.sendRedirect(req.getContextPath() + "/reset-password");
            return;
        }

        // Validate passwords
        if (isNullOrEmpty(newPassword)) {
            session.setAttribute(FLASH_ERROR, "Vui lòng nhập mật khẩu mới.");
            res.sendRedirect(req.getContextPath() + "/reset-password");
            return;
        }

        if (newPassword.length() < 8) {
            session.setAttribute(FLASH_ERROR, "Mật khẩu mới phải có ít nhất 8 ký tự.");
            res.sendRedirect(req.getContextPath() + "/reset-password");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            session.setAttribute(FLASH_ERROR, "Mật khẩu mới và xác nhận mật khẩu không khớp.");
            res.sendRedirect(req.getContextPath() + "/reset-password");
            return;
        }

        // Get session data
        String expectedOtp = (String) session.getAttribute("fpPendingOtp");
        Long expiresAt = (Long) session.getAttribute("fpPendingOtpExpires");
        Integer fpUserId = (Integer) session.getAttribute("fpUserId");

        if (expectedOtp == null || fpUserId == null) {
            session.setAttribute(FLASH_ERROR, "Phiên đặt lại mật khẩu đã hết hạn. Vui lòng bắt đầu lại.");
            res.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        // Check expiry
        long now = System.currentTimeMillis();
        if (expiresAt != null && now > expiresAt) {
            session.removeAttribute("fpPendingOtp");
            session.removeAttribute("fpPendingOtpExpires");
            session.removeAttribute("fpUserId");
            session.setAttribute(FLASH_ERROR, "Mã xác thực đã hết hạn. Vui lòng yêu cầu mã mới.");
            res.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        // Verify OTP
        if (!expectedOtp.equals(otpInput.trim())) {
            session.setAttribute(FLASH_ERROR, "Mã xác thực không chính xác.");
            res.sendRedirect(req.getContextPath() + "/reset-password");
            return;
        }

        // Update password
        try {
            String newHash = org.mindrot.jbcrypt.BCrypt.hashpw(newPassword, org.mindrot.jbcrypt.BCrypt.gensalt(12));
            userDAO.updatePassword(fpUserId, newHash);

            // Clear session data
            session.removeAttribute("fpUserId");
            session.removeAttribute("fpPendingOtp");
            session.removeAttribute("fpPendingOtpExpires");
            session.removeAttribute("fpOtpSentTime");
            session.removeAttribute("fpEmailDest");

            session.setAttribute(FLASH_SUCCESS, "Đặt lại mật khẩu thành công! Vui lòng đăng nhập với mật khẩu mới.");
            res.sendRedirect(req.getContextPath() + "/login");

        } catch (Exception e) {
            session.setAttribute(FLASH_ERROR, "Có lỗi xảy ra. Vui lòng thử lại.");
            res.sendRedirect(req.getContextPath() + "/reset-password");
        }
    }

    private void handleResend(HttpServletRequest req, HttpServletResponse res, HttpSession session) throws IOException {
        long now = System.currentTimeMillis();
        Long lastSent = (Long) session.getAttribute("fpOtpSentTime");

        if (lastSent != null && (now - lastSent) < 60_000) {
            long remaining = 60 - ((now - lastSent) / 1000);
            session.setAttribute(FLASH_ERROR, "Vui lòng đợi " + remaining + " giây trước khi gửi lại mã.");
            res.sendRedirect(req.getContextPath() + "/reset-password");
            return;
        }

        Integer fpUserId = (Integer) session.getAttribute("fpUserId");
        if (fpUserId == null) {
            res.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        // Reload user
        try {
            var userOpt = userDAO.findById(fpUserId);
            if (userOpt.isEmpty()) {
                session.setAttribute(FLASH_ERROR, "Không tìm thấy tài khoản. Vui lòng bắt đầu lại.");
                res.sendRedirect(req.getContextPath() + "/forgot-password");
                return;
            }

            User user = userOpt.get();

            if (isNullOrEmpty(user.getEmail())) {
                session.setAttribute(FLASH_ERROR, "Tài khoản này chưa đăng ký Email.");
                res.sendRedirect(req.getContextPath() + "/forgot-password");
                return;
            }

            // Send new OTP
            EmailService emailService = new EmailService();
            String newOtp = generate6DigitOtp();
            long expiresAt = now + TimeUnit.MINUTES.toMillis(AppConstants.OTP_EXPIRY_MINUTES);

            boolean sent = emailService.sendOtpCode(user, newOtp, expiresAt);

            if (!sent) {
                session.setAttribute(FLASH_ERROR, "Không thể gửi mã OTP. Vui lòng kiểm tra cấu hình SMTP.");
                res.sendRedirect(req.getContextPath() + "/reset-password");
                return;
            }

            session.setAttribute("fpPendingOtp", newOtp);
            session.setAttribute("fpPendingOtpExpires", expiresAt);
            session.setAttribute("fpOtpSentTime", now);
            session.setAttribute("fpEmailDest", maskEmail(user.getEmail()));

            session.setAttribute(FLASH_SUCCESS, "Mã xác thực mới đã được gửi đến Email của bạn.");
            res.sendRedirect(req.getContextPath() + "/reset-password");

        } catch (Exception e) {
            session.setAttribute(FLASH_ERROR, "Có lỗi xảy ra. Vui lòng thử lại.");
            res.sendRedirect(req.getContextPath() + "/reset-password");
        }
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
