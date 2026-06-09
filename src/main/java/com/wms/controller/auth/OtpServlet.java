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
 * OtpServlet — Handles 2-Factor OTP Generation, Dispatch, and Verification.
 */
public class OtpServlet extends BaseController {

    private static final String FLASH_OTP_AUTOMESSAGE = "otpAutoMessage";

    private final EmailService emailService = new EmailService();
    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // 1. If already officially logged in, bypass OTP and go to dashboard
        if (isLoggedIn(req)) {
            User user = (User) req.getSession().getAttribute(AppConstants.SESSION_USER);
            String role = user != null ? user.getRole() : "";
            redirect(res, req.getContextPath() + getDashboardTarget(role));
            return;
        }

        // 2. Validate pending 2FA session context
        HttpSession session = req.getSession(false);
        if (session == null) {
            redirect(res, req.getContextPath() + "/login");
            return;
        }

        User pendingUser = (User) session.getAttribute(AppConstants.SESSION_PENDING_USER);
        if (pendingUser == null) {
            redirect(res, req.getContextPath() + "/login");
            return;
        }

        // Bind flash messages from session to request attributes
        String flashError = (String) session.getAttribute(AppConstants.ATTR_ERROR);
        if (flashError != null) {
            req.setAttribute(AppConstants.ATTR_ERROR, flashError);
            session.removeAttribute(AppConstants.ATTR_ERROR);
        }
        String flashSuccess = (String) session.getAttribute(AppConstants.ATTR_SUCCESS);
        if (flashSuccess != null) {
            req.setAttribute(AppConstants.ATTR_SUCCESS, flashSuccess);
            session.removeAttribute(AppConstants.ATTR_SUCCESS);
        }
        String flashOtpMessage = (String) session.getAttribute(FLASH_OTP_AUTOMESSAGE);
        if (flashOtpMessage != null) {
            req.setAttribute(FLASH_OTP_AUTOMESSAGE, flashOtpMessage);
            session.removeAttribute(FLASH_OTP_AUTOMESSAGE);
        }

        // 3. Auto-send OTP if none exists or already expired
        String pendingOtp = (String) session.getAttribute(AppConstants.SESSION_PENDING_OTP);
        Long expiresAt = (Long) session.getAttribute(AppConstants.SESSION_PENDING_OTP_EXPIRES);
        long now = System.currentTimeMillis();

        if (pendingOtp == null || (expiresAt != null && now > expiresAt)) {
            // Expired — clear stale state
            if (pendingOtp != null) {
                session.removeAttribute(AppConstants.SESSION_PENDING_OTP);
                session.removeAttribute(AppConstants.SESSION_PENDING_OTP_EXPIRES);
                session.removeAttribute(AppConstants.SESSION_PENDING_OTP_DEST);
            }

            // Check email availability
            if (isNullOrEmpty(pendingUser.getEmail())) {
                session.setAttribute(AppConstants.ATTR_ERROR, "Tài khoản của bạn chưa đăng ký Email để nhận mã OTP.");
                redirect(res, req.getContextPath() + "/otp");
                return;
            }

            // Rate limit: don't auto-resend within 60s window
            Long lastSent = (Long) session.getAttribute("otpSentTime");
            if (lastSent == null || (now - lastSent) >= 60_000) {
                String otpCode = generate6DigitOtp();
                long newExpiresAt = now + TimeUnit.MINUTES.toMillis(AppConstants.OTP_EXPIRY_MINUTES);

                boolean sent = emailService.sendOtpCode(pendingUser, otpCode, newExpiresAt);

                if (sent) {
                    session.setAttribute(AppConstants.SESSION_PENDING_OTP, otpCode);
                    session.setAttribute(AppConstants.SESSION_PENDING_OTP_EXPIRES, newExpiresAt);
                    session.setAttribute(AppConstants.SESSION_PENDING_OTP_DEST, maskEmail(pendingUser.getEmail()));
                    session.setAttribute("otpSentTime", now);
                    session.setAttribute(FLASH_OTP_AUTOMESSAGE, "Mã xác thực OTP đã được gửi thành công! Hãy nhập mã bên dưới để tiếp tục đăng nhập.");
                } else {
                    session.setAttribute(AppConstants.ATTR_ERROR, "Không thể gửi mã OTP qua Email. Vui lòng kiểm tra cấu hình SMTP.");
                }
            }

            // Re-bind flash after potential auto-send
            String newFlashError = (String) session.getAttribute(AppConstants.ATTR_ERROR);
            if (newFlashError != null) {
                req.setAttribute(AppConstants.ATTR_ERROR, newFlashError);
                session.removeAttribute(AppConstants.ATTR_ERROR);
            }
            String newFlashMsg = (String) session.getAttribute(FLASH_OTP_AUTOMESSAGE);
            if (newFlashMsg != null) {
                req.setAttribute(FLASH_OTP_AUTOMESSAGE, newFlashMsg);
                session.removeAttribute(FLASH_OTP_AUTOMESSAGE);
            }
        }

        // 4. Calculate resend countdown
        Long sentTime = (Long) session.getAttribute("otpSentTime");
        long elapsedSeconds = sentTime != null ? (now - sentTime) / 1000 : 999;
        req.setAttribute("resendCountdown", Math.max(0, 60 - elapsedSeconds));

        // 5. Expose verify view
        req.setAttribute("otpName", pendingUser.getFullName());
        req.setAttribute("otpDestination", session.getAttribute(AppConstants.SESSION_PENDING_OTP_DEST));
        forward(req, res, "auth/otp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) {
            redirect(res, req.getContextPath() + "/login");
            return;
        }

        User pendingUser = (User) session.getAttribute(AppConstants.SESSION_PENDING_USER);
        if (pendingUser == null) {
            redirect(res, req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");

        // Resend OTP via email
        if ("resend".equalsIgnoreCase(action)) {
            Long lastSent = (Long) session.getAttribute("otpSentTime");
            long now = System.currentTimeMillis();

            if (lastSent != null && (now - lastSent) < 60_000) {
                session.setAttribute(AppConstants.ATTR_ERROR, "Vui lòng đợi 60 giây trước khi gửi lại mã.");
                redirect(res, req.getContextPath() + "/otp");
                return;
            }

            if (isNullOrEmpty(pendingUser.getEmail())) {
                session.setAttribute(AppConstants.ATTR_ERROR, "Tài khoản của bạn chưa đăng ký Email để nhận mã OTP.");
                redirect(res, req.getContextPath() + "/otp");
                return;
            }

            String otpCode = generate6DigitOtp();
            long newExpiresAt = now + TimeUnit.MINUTES.toMillis(AppConstants.OTP_EXPIRY_MINUTES);

            String maskedDest = maskEmail(pendingUser.getEmail());
            boolean sent = emailService.sendOtpCode(pendingUser, otpCode, newExpiresAt);

            if (!sent) {
                session.setAttribute(AppConstants.ATTR_ERROR, "Không thể gửi mã OTP qua Email. Vui lòng kiểm tra cấu hình SMTP.");
                redirect(res, req.getContextPath() + "/otp");
                return;
            }

            session.setAttribute(AppConstants.SESSION_PENDING_OTP, otpCode);
            session.setAttribute(AppConstants.SESSION_PENDING_OTP_EXPIRES, newExpiresAt);
            session.setAttribute(AppConstants.SESSION_PENDING_OTP_DEST, maskedDest);
            session.setAttribute("otpSentTime", now);
            session.setAttribute(FLASH_OTP_AUTOMESSAGE, "Mã xác thực mới đã được gửi thành công!");

            redirect(res, req.getContextPath() + "/otp");
            return;
        }

        // Standard Action: OTP Validation
        String otpInput = req.getParameter("otp");
        if (isNullOrEmpty(otpInput)) {
            setError(req, "Vui lòng nhập mã OTP.");
            bindVerificationErrorView(req, session, pendingUser);
            forward(req, res, "auth/otp");
            return;
        }

        otpInput = otpInput.trim();
        if (!otpInput.matches("\\d{6}")) {
            setError(req, "Mã OTP không hợp lệ. Vui lòng nhập đúng 6 chữ số.");
            bindVerificationErrorView(req, session, pendingUser);
            forward(req, res, "auth/otp");
            return;
        }

        String expectedOtp = (String) session.getAttribute(AppConstants.SESSION_PENDING_OTP);
        Long expiresAt = (Long) session.getAttribute(AppConstants.SESSION_PENDING_OTP_EXPIRES);
        long now = System.currentTimeMillis();

        if (expiresAt == null || now > expiresAt) {
            session.removeAttribute(AppConstants.SESSION_PENDING_OTP);
            session.removeAttribute(AppConstants.SESSION_PENDING_OTP_EXPIRES);
            session.removeAttribute(AppConstants.SESSION_PENDING_OTP_DEST);
            session.setAttribute(AppConstants.ATTR_ERROR, "Mã OTP đã hết hạn. Vui lòng yêu cầu mã xác thực mới.");
            redirect(res, req.getContextPath() + "/otp");
            return;
        }

        if (expectedOtp == null || !expectedOtp.equals(otpInput)) {
            setError(req, "Mã OTP không chính xác. Vui lòng nhập lại.");
            bindVerificationErrorView(req, session, pendingUser);
            forward(req, res, "auth/otp");
            return;
        }

        // OTP is VALID -> OFFICIALLY Log in!
        String role = pendingUser.getRole() != null ? pendingUser.getRole() : "";
        String target = (String) session.getAttribute(AppConstants.SESSION_PENDING_OTP_TARGET);
        if (isNullOrEmpty(target)) {
            target = getDashboardTarget(role);
        }

        session.setAttribute(AppConstants.SESSION_USER, pendingUser);
        session.setAttribute(AppConstants.SESSION_ROLE, role);
        session.setAttribute(AppConstants.SESSION_WAREHOUSE, pendingUser.getWarehouseId());
        session.setMaxInactiveInterval(30 * 60); // Official 30 min session timeout

        // Clean up transient attributes
        clearOtpVerificationState(session);
        session.removeAttribute(AppConstants.SESSION_PENDING_USER);

        redirect(res, req.getContextPath() + target);
    }

    private String generate6DigitOtp() {
        int code = 100000 + secureRandom.nextInt(900000);
        return String.valueOf(code);
    }

    private void bindVerificationErrorView(HttpServletRequest req, HttpSession session, User pendingUser) {
        req.setAttribute("otpDestination", session.getAttribute(AppConstants.SESSION_PENDING_OTP_DEST));
        req.setAttribute("otpName", pendingUser != null ? pendingUser.getFullName() : null);

        Long sentTime = (Long) session.getAttribute("otpSentTime");
        long elapsedSeconds = sentTime != null ? (System.currentTimeMillis() - sentTime) / 1000 : 999;
        req.setAttribute("resendCountdown", Math.max(0, 60 - elapsedSeconds));
    }

    private void clearOtpVerificationState(HttpSession session) {
        session.removeAttribute(AppConstants.SESSION_PENDING_OTP);
        session.removeAttribute(AppConstants.SESSION_PENDING_OTP_EXPIRES);
        session.removeAttribute(AppConstants.SESSION_PENDING_OTP_DEST);
        session.removeAttribute(AppConstants.SESSION_PENDING_OTP_TARGET);
        session.removeAttribute("otpSentTime");
    }

    private String maskEmail(String email) {
        if (isNullOrEmpty(email)) {
            return "";
        }
        int atIndex = email.indexOf('@');
        if (atIndex < 2) {
            return "***";
        }
        String localPart = email.substring(0, atIndex);
        String domainPart = email.substring(atIndex);
        if (localPart.length() <= 3) {
            return localPart.substring(0, 1) + "***" + domainPart;
        }
        return localPart.substring(0, 2) + "***" + localPart.substring(localPart.length() - 1) + domainPart;
    }

    private String getDashboardTarget(String role) {
        if (role == null) {
            return "/login";
        }
        switch (role) {
            case "ADMIN":
                return "/admin/users";
            case "MANAGER":
                return "/business/dashboard";
            case "WAREHOUSE_STAFF":
                return "/warehouse/master-sku";
            case "SALES_STAFF":
                return "/sales/orders";
            default:
                return "/login";
        }
    }
}
