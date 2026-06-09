package com.wms.controller.auth;

import com.wms.controller.BaseController;
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
 * PasswordChangeOtpServlet — Handles OTP verification for password change requests.
 * 
 * Flow:
 * 1. GET  /password-change-otp — send OTP to user's email and show verification form
 * 2. POST /password-change-otp?action=verify — verify OTP and proceed with password change
 */
public class PasswordChangeOtpServlet extends BaseController {

    private static final String FLASH_ERROR = "pwdChangeError";
    private static final String FLASH_SUCCESS = "pwdChangeSuccess";

    private final EmailService emailService = new EmailService();
    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute(AppConstants.SESSION_USER) == null) {
            redirect(res, req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute(AppConstants.SESSION_USER);

        // Check if user has email
        if (isNullOrEmpty(user.getEmail())) {
            session.setAttribute(FLASH_ERROR, "Tài khoản của bạn chưa đăng ký Email để nhận mã OTP.");
            redirect(res, req.getContextPath() + getProfileUrl(user.getRole()));
            return;
        }

        long now = System.currentTimeMillis();

        // Check rate limit
        Long lastSent = (Long) session.getAttribute("pwdChangeOtpSentTime");
        if (lastSent != null && (now - lastSent) < 60_000) {
            long remaining = 60 - ((now - lastSent) / 1000);
            session.setAttribute(FLASH_ERROR, "Vui lòng đợi " + remaining + " giây trước khi yêu cầu mã mới.");
            redirect(res, req.getContextPath() + getProfileUrl(user.getRole()));
            return;
        }

        // Generate and send OTP
        String otpCode = generate6DigitOtp();
        long expiresAt = now + TimeUnit.MINUTES.toMillis(AppConstants.OTP_EXPIRY_MINUTES);

        boolean sent = emailService.sendOtpCode(user, otpCode, expiresAt);

        if (!sent) {
            session.setAttribute(FLASH_ERROR, "Không thể gửi mã OTP qua Email. Vui lòng kiểm tra cấu hình SMTP.");
            redirect(res, req.getContextPath() + getProfileUrl(user.getRole()));
            return;
        }

        // Store OTP in session
        session.setAttribute("pwdChangePendingOtp", otpCode);
        session.setAttribute("pwdChangePendingOtpExpires", expiresAt);
        session.setAttribute("pwdChangePendingNewPassword", session.getAttribute("pwdChangePendingNewPassword"));
        session.setAttribute("pwdChangeOtpSentTime", now);
        session.setAttribute("pwdChangeOtpDest", maskEmail(user.getEmail()));

        // Bind flash messages
        bindFlashMessages(req, session);

        // Expose data to view
        req.setAttribute("otpName", user.getFullName());
        req.setAttribute("otpDestination", maskEmail(user.getEmail()));

        forward(req, res, "auth/password-change-otp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute(AppConstants.SESSION_USER) == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute(AppConstants.SESSION_USER);
        String action = req.getParameter("action");

        if ("verify".equalsIgnoreCase(action)) {
            handleVerify(req, res, session, user);
        } else if ("resend".equalsIgnoreCase(action)) {
            handleResend(req, res, session, user);
        } else {
            redirect(res, req.getContextPath() + "/password-change-otp");
        }
    }

    private void handleVerify(HttpServletRequest req, HttpServletResponse res, HttpSession session, User user)
            throws IOException, ServletException {
        String otpInput = req.getParameter("otp");

        if (isNullOrEmpty(otpInput)) {
            session.setAttribute(FLASH_ERROR, "Vui lòng nhập mã OTP.");
            bindFlashMessages(req, session);
            forward(req, res, "auth/password-change-otp");
            return;
        }

        otpInput = otpInput.trim();
        if (!otpInput.matches("\\d{6}")) {
            session.setAttribute(FLASH_ERROR, "Mã OTP không hợp lệ. Vui lòng nhập đúng 6 chữ số.");
            bindFlashMessages(req, session);
            forward(req, res, "auth/password-change-otp");
            return;
        }

        String expectedOtp = (String) session.getAttribute("pwdChangePendingOtp");
        Long expiresAt = (Long) session.getAttribute("pwdChangePendingOtpExpires");
        long now = System.currentTimeMillis();

        if (expiresAt == null || now > expiresAt) {
            session.removeAttribute("pwdChangePendingOtp");
            session.removeAttribute("pwdChangePendingOtpExpires");
            session.removeAttribute("pwdChangePendingNewPassword");
            session.setAttribute(FLASH_ERROR, "Mã OTP đã hết hạn. Vui lòng yêu cầu mã xác thực mới.");
            redirect(res, req.getContextPath() + getProfileUrl(user.getRole()));
            return;
        }

        if (expectedOtp == null || !expectedOtp.equals(otpInput)) {
            session.setAttribute(FLASH_ERROR, "Mã OTP không chính xác. Vui lòng nhập lại.");
            bindFlashMessages(req, session);
            forward(req, res, "auth/password-change-otp");
            return;
        }

        // OTP verified! Clear OTP session data
        session.removeAttribute("pwdChangePendingOtp");
        session.removeAttribute("pwdChangePendingOtpExpires");
        session.removeAttribute("pwdChangeOtpSentTime");
        session.removeAttribute("pwdChangeOtpDest");

        // Get the pending password from session
        String newPassword = (String) session.getAttribute("pwdChangePendingNewPassword");

        if (isNullOrEmpty(newPassword)) {
            session.setAttribute(FLASH_ERROR, "Phiên đổi mật khẩu đã hết hạn. Vui lòng thử lại.");
            redirect(res, req.getContextPath() + getProfileUrl(user.getRole()));
            return;
        }

        // Clear pending password data
        session.removeAttribute("pwdChangePendingNewPassword");

        // Change password directly
        boolean success = changePassword(user.getUserId(), newPassword);

        if (success) {
            session.setAttribute(FLASH_SUCCESS, "Đổi mật khẩu thành công!");
        } else {
            session.setAttribute(FLASH_ERROR, "Có lỗi xảy ra khi đổi mật khẩu. Vui lòng thử lại.");
        }

        redirect(res, req.getContextPath() + getProfileUrl(user.getRole()));
    }

    private void handleResend(HttpServletRequest req, HttpServletResponse res, HttpSession session, User user)
            throws IOException {
        long now = System.currentTimeMillis();
        Long lastSent = (Long) session.getAttribute("pwdChangeOtpSentTime");

        if (lastSent != null && (now - lastSent) < 60_000) {
            long remaining = 60 - ((now - lastSent) / 1000);
            session.setAttribute(FLASH_ERROR, "Vui lòng đợi " + remaining + " giây trước khi gửi lại mã.");
            redirect(res, req.getContextPath() + "/password-change-otp");
            return;
        }

        if (isNullOrEmpty(user.getEmail())) {
            session.setAttribute(FLASH_ERROR, "Tài khoản của bạn chưa đăng ký Email để nhận mã OTP.");
            redirect(res, req.getContextPath() + getProfileUrl(user.getRole()));
            return;
        }

        String otpCode = generate6DigitOtp();
        long expiresAt = now + TimeUnit.MINUTES.toMillis(AppConstants.OTP_EXPIRY_MINUTES);

        boolean sent = emailService.sendOtpCode(user, otpCode, expiresAt);

        if (!sent) {
            session.setAttribute(FLASH_ERROR, "Không thể gửi mã OTP qua Email. Vui lòng kiểm tra cấu hình SMTP.");
            redirect(res, req.getContextPath() + getProfileUrl(user.getRole()));
            return;
        }

        session.setAttribute("pwdChangePendingOtp", otpCode);
        session.setAttribute("pwdChangePendingOtpExpires", expiresAt);
        session.setAttribute("pwdChangeOtpSentTime", now);
        session.setAttribute("pwdChangeOtpDest", maskEmail(user.getEmail()));
        session.setAttribute(FLASH_SUCCESS, "Mã xác thực mới đã được gửi thành công!");

        redirect(res, req.getContextPath() + "/password-change-otp");
    }

    private boolean changePassword(int userId, String newPassword) {
        try {
            com.wms.dao.UserDAO userDAO = new com.wms.dao.UserDAO();
            String newHash = org.mindrot.jbcrypt.BCrypt.hashpw(newPassword, org.mindrot.jbcrypt.BCrypt.gensalt(12));
            userDAO.updatePassword(userId, newHash);
            return true;
        } catch (Exception e) {
            return false;
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

    private String getProfileUrl(String role) {
        if (role == null) return "/login";
        switch (role) {
            case "ADMIN":
                return "/admin/profile";
            case "MANAGER":
                return "/business/profile";
            case "WAREHOUSE_STAFF":
                return "/warehouse/profile";
            case "SALES_STAFF":
                return "/sales/profile";
            default:
                return "/login";
        }
    }

    private void bindFlashMessages(HttpServletRequest req, HttpSession session) {
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
