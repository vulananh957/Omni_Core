package com.wms.controller.admin;

import com.wms.controller.BaseController;
import com.wms.dao.RoleDAO;
import com.wms.dao.UserDAO;
import com.wms.model.Role;
import com.wms.model.User;
import com.wms.service.AuthService;
import com.wms.service.EmailService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;
import java.security.SecureRandom;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * UserManagementServlet — Manages User Accounts & Roles (UC-SYS01).
 * Supports pure MVC layout operations, role associations, deactivation toggles, and password validations.
 */
public class UserManagementServlet extends BaseController {

    private static final Logger LOGGER = Logger.getLogger(UserManagementServlet.class.getName());

    private final UserDAO userDAO = new UserDAO();
    private final RoleDAO roleDAO = new RoleDAO();
    private final EmailService emailService = new EmailService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String pathInfo = req.getPathInfo();

        try {
            if (pathInfo == null || "/".equals(pathInfo) || "/list".equals(pathInfo)) {
                handleList(req, resp);
            } else if ("/create".equals(pathInfo)) {
                handleCreateForm(req, resp);
            } else if ("/edit".equals(pathInfo)) {
                handleEditForm(req, resp);
            } else if ("/toggle".equals(pathInfo)) {
                handleToggleStatus(req, resp);
            } else {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "UserManagementServlet: DB error in doGet: " + e.getMessage(), e);
            throw new ServletException("Database access error in UserManagement", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String pathInfo = req.getPathInfo();

        try {
            if ("/create".equals(pathInfo) || "/save".equals(pathInfo)) {
                handleSaveUser(req, resp);
            } else {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "UserManagementServlet: DB error updating user", e);
            throw new ServletException("Database error during user persistence", e);
        }
    }

    // ── GET Actions ───────────────────────────────────────────

    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        String search = req.getParameter("search");
        String role = req.getParameter("role");
        String status = req.getParameter("status");

        List<User> usersList = userDAO.findFiltered(search, role, status);
        req.setAttribute("usersList", usersList);

        req.setAttribute("pageTitle", "Quản lý Tài khoản & Phân quyền");
        req.setAttribute("pageSubtitle", "Danh sách người dùng, thay đổi phân quyền và trạng thái hoạt động");
        req.setAttribute("currentPage", "admin-users");

        req.setAttribute("contentPage", "/WEB-INF/views/admin/users-management.jsp");
        req.getRequestDispatcher("/WEB-INF/views/layout/admin-layout.jsp").forward(req, resp);
    }

    private void handleCreateForm(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        List<Role> roles = roleDAO.findAll();
        req.setAttribute("roles", roles);
        req.setAttribute("actionUrl", req.getContextPath() + "/admin/users/create");

        req.setAttribute("pageTitle", "Thêm Người Dùng Mới");
        req.setAttribute("pageSubtitle", "Nhập thông tin nhân viên, mật khẩu và gán vai trò hệ thống");
        req.setAttribute("currentPage", "admin-users");

        req.setAttribute("contentPage", "/WEB-INF/views/admin/user-form.jsp");
        req.getRequestDispatcher("/WEB-INF/views/layout/admin-layout.jsp").forward(req, resp);
    }

    private void handleEditForm(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        int userId = Integer.parseInt(idStr);
        User loggedInUser = (User) req.getSession().getAttribute("loggedInUser");
        if (loggedInUser != null && loggedInUser.getUserId() == userId) {
            resp.sendRedirect(req.getContextPath() + "/admin/profile");
            return;
        }

        Optional<User> userOpt = userDAO.findById(userId);

        if (userOpt.isEmpty()) {
            req.setAttribute("errorMessage", "Không tìm thấy người dùng có ID " + userId);
            handleList(req, resp);
            return;
        }

        List<Role> roles = roleDAO.findAll();
        req.setAttribute("user", userOpt.get());
        req.setAttribute("roles", roles);
        req.setAttribute("actionUrl", req.getContextPath() + "/admin/users/create");

        req.setAttribute("pageTitle", "Cập nhật Người Dùng");
        req.setAttribute("pageSubtitle", "Chỉnh sửa thông tin cá nhân hoặc vai trò hoạt động");
        req.setAttribute("currentPage", "admin-users");

        req.setAttribute("contentPage", "/WEB-INF/views/admin/user-form.jsp");
        req.getRequestDispatcher("/WEB-INF/views/layout/admin-layout.jsp").forward(req, resp);
    }

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException {
        String idStr = req.getParameter("id");
        String activeStr = req.getParameter("active");

        if (idStr != null && activeStr != null) {
            int userId = Integer.parseInt(idStr);
            boolean active = Boolean.parseBoolean(activeStr);
            
            // Prevent self-deactivation / locking own account
            User loggedInUser = (User) req.getSession().getAttribute("loggedInUser");
            if (loggedInUser != null && loggedInUser.getUserId() == userId && !active) {
                resp.sendRedirect(req.getContextPath() + "/admin/users?status=self_toggle_error");
                return;
            }
            
            userDAO.toggleStatus(userId, active);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/users?status=toggle_success");
    }

    // ── POST / Form Actions ───────────────────────────────────

    private void handleSaveUser(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {

        String userIdStr = req.getParameter("userId");
        String username = req.getParameter("username");
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String roleIdStr = req.getParameter("roleId");
        String activeStr = req.getParameter("active");

        boolean isUpdate = userIdStr != null && !userIdStr.trim().isEmpty() && Integer.parseInt(userIdStr) > 0;
        int userId = isUpdate ? Integer.parseInt(userIdStr) : 0;
        int roleId = Integer.parseInt(roleIdStr);
        boolean active = "true".equals(activeStr) || "1".equals(activeStr);

        // Fetch corresponding role name to maintain backward compatibility (roleStr)
        Role roleObj = roleDAO.findById(roleId);
        String roleName = (roleObj != null) ? roleObj.getRoleName() : "WAREHOUSE_STAFF";

        // Create transient User to preserve form values if error occurs
        User user = new User();
        user.setUserId(userId);
        user.setUsername(username);
        user.setFullName(fullName);
        user.setEmail(email);
        user.setPhone(phone);
        user.setRoleId(roleId);
        user.setRole(roleName);
        user.setActive(active);

        // ── Validation ────────────────────────────────────────

        if (isNullOrEmpty(username) || isNullOrEmpty(fullName) || isNullOrEmpty(email)) {
            setError(req, "Các trường Tên đăng nhập, Họ tên và Email không được bỏ trống.");
            reloadForm(req, resp, user);
            return;
        }

        // Check email uniqueness
        if (userDAO.isEmailTaken(email, userId)) {
            setError(req, "Địa chỉ email '" + email + "' đã được sử dụng bởi một tài khoản khác.");
            reloadForm(req, resp, user);
            return;
        }

        if (!isUpdate) {
            // Check username uniqueness
            if (userDAO.findByUsername(username).isPresent()) {
                setError(req, "Tên đăng nhập '" + username + "' đã tồn tại trong hệ thống.");
                reloadForm(req, resp, user);
                return;
            }

            // Generate secure random password automatically
            String randomPassword = generateRandomPassword();

            // HASH PASSWORD before saving!
            String passwordHash = AuthService.hashPassword(randomPassword);
            user.setPasswordHash(passwordHash);

            boolean success = userDAO.insert(user);
            if (success) {
                boolean emailSent = emailService.sendNewUserCredentials(user, randomPassword);
                if (!emailSent) {
                    LOGGER.log(Level.WARNING, "UserManagementServlet: Failed to send new user email to " + email);
                }

                String phoneTarget = (phone != null && !phone.isEmpty()) ? phone : "[Chua dang ky]";
                LOGGER.info("UserManagementServlet: Account created for " + username
                        + " at phone " + phoneTarget + " (SMS notification simulated in dev)");

                // Save raw temporary credentials in HTTP session as a transient flash state
                req.getSession().setAttribute("newGeneratedPassword", randomPassword);
                req.getSession().setAttribute("newCreatedUser", user);
                resp.sendRedirect(req.getContextPath() + "/admin/users?status=success");
            } else {
                setError(req, "Không thể lưu thông tin tài khoản mới.");
                reloadForm(req, resp, user);
            }

        } else {
            // Processing user update
            Optional<User> existingOpt = userDAO.findById(userId);
            if (existingOpt.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/admin/users");
                return;
            }

            // Preserving original warehouse allocation
            user.setWarehouseId(existingOpt.get().getWarehouseId());

            // Password updates are not allowed from admin user edit screen
            if (req.getParameter("password") != null || req.getParameter("confirmPassword") != null) {
                setError(req, "Admin không có quyền đổi mật khẩu người dùng từ màn hình này.");
                reloadForm(req, resp, user);
                return;
            }

            // Save standard profile fields
            boolean success = userDAO.update(user);

            if (success) {
                resp.sendRedirect(req.getContextPath() + "/admin/users?status=success");
            } else {
                setError(req, "Không thể cập nhật thông tin tài khoản.");
                reloadForm(req, resp, user);
            }
        }
    }

    private void reloadForm(HttpServletRequest req, HttpServletResponse resp, User user)
            throws SQLException, ServletException, IOException {
        req.setAttribute("user", user);
        req.setAttribute("roles", roleDAO.findAll());
        req.setAttribute("actionUrl", req.getContextPath() + "/admin/users/create");

        req.setAttribute("pageTitle", user.getUserId() > 0 ? "Cập nhật Người Dùng" : "Thêm Người Dùng Mới");
        req.setAttribute("pageSubtitle", user.getUserId() > 0 ? "Chỉnh sửa thông tin cá nhân hoặc vai trò hoạt động" : "Nhập thông tin nhân viên, mật khẩu và gán vai trò hệ thống");
        req.setAttribute("currentPage", "admin-users");

        req.setAttribute("contentPage", "/WEB-INF/views/admin/user-form.jsp");
        req.getRequestDispatcher("/WEB-INF/views/layout/admin-layout.jsp").forward(req, resp);
    }

    /**
     * Password complexity checks:
     * - Min 8 characters
     * - Contains uppercase, lowercase, and digit
     * - Contains at least one special char (!@#$%)
     */
    private boolean isValidPassword(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        boolean hasUpper = password.matches(".*[A-Z].*");
        boolean hasLower = password.matches(".*[a-z].*");
        boolean hasDigit = password.matches(".*[0-9].*");
        boolean hasSpecial = password.matches(".*[!@#$%].*");
        return hasUpper && hasLower && hasDigit && hasSpecial;
    }

    /**
     * Generates a cryptographically strong 10-character password conforming to complexity requirements:
     * - Minimum 8 characters (10 characters generated)
     * - Contains at least 1 uppercase letter
     * - Contains at least 1 lowercase letter
     * - Contains at least 1 numeric digit (0-9)
     * - Contains at least 1 special character from [!@#$%]
     */
    private String generateRandomPassword() {
        String upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        String lower = "abcdefghijklmnopqrstuvwxyz";
        String digits = "0123456789";
        String special = "!@#$%";
        SecureRandom random = new SecureRandom();
        
        StringBuilder sb = new StringBuilder();
        // Force inclusion of at least one character from each class
        sb.append(upper.charAt(random.nextInt(upper.length())));
        sb.append(lower.charAt(random.nextInt(lower.length())));
        sb.append(digits.charAt(random.nextInt(digits.length())));
        sb.append(special.charAt(random.nextInt(special.length())));
        
        // Fill the remaining 6 characters from a combined pool
        String pool = upper + lower + digits + special;
        for (int i = 0; i < 6; i++) {
            sb.append(pool.charAt(random.nextInt(pool.length())));
        }
        
        // Shuffle the buffer cryptographically to eliminate deterministic order
        char[] chars = sb.toString().toCharArray();
        for (int i = chars.length - 1; i > 0; i--) {
            int j = random.nextInt(i + 1);
            char temp = chars[i];
            chars[i] = chars[j];
            chars[j] = temp;
        }
        return new String(chars);
    }
}
