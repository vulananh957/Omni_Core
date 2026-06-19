package com.wms.service.user;

import com.wms.dao.RoleDAO;
import com.wms.dao.UserDAO;
import com.wms.model.Role;
import com.wms.model.User;
import com.wms.service.auth.EmailService;
import org.mindrot.jbcrypt.BCrypt;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.security.SecureRandom;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

public class UserService {

    private static final Logger log = LoggerFactory.getLogger(UserService.class);

    private final UserDAO userDAO = new UserDAO();
    private final RoleDAO roleDAO = new RoleDAO();
    private final EmailService emailService = new EmailService();

    public List<User> findAllFiltered(String search, String role, String status) throws SQLException {
        return userDAO.findFiltered(search, role, status);
    }

    public Optional<User> findById(int userId) throws SQLException {
        return userDAO.findById(userId);
    }

    public List<Role> findAllRoles() throws SQLException {
        return roleDAO.findAll();
    }

    public Role findRoleById(int roleId) throws SQLException {
        return roleDAO.findById(roleId);
    }

    public List<User> findByRoles(String... roles) throws SQLException {
        return userDAO.findByRoles(roles);
    }

    public boolean toggleStatus(int userId, boolean active) throws SQLException {
        return userDAO.toggleStatus(userId, active);
    }

    public boolean canToggleStatus(int targetUserId, boolean deactivating, Integer loggedInUserId) {
        return !(deactivating && loggedInUserId != null && loggedInUserId == targetUserId);
    }

    public String generateRandomPassword() {
        String upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        String lower = "abcdefghijklmnopqrstuvwxyz";
        String digits = "0123456789";
        String special = "!@#$%";
        SecureRandom random = new SecureRandom();

        StringBuilder sb = new StringBuilder();
        sb.append(upper.charAt(random.nextInt(upper.length())));
        sb.append(lower.charAt(random.nextInt(lower.length())));
        sb.append(digits.charAt(random.nextInt(digits.length())));
        sb.append(special.charAt(random.nextInt(special.length())));

        String pool = upper + lower + digits + special;
        for (int i = 0; i < 6; i++) {
            sb.append(pool.charAt(random.nextInt(pool.length())));
        }

        char[] chars = sb.toString().toCharArray();
        for (int i = chars.length - 1; i > 0; i--) {
            int j = random.nextInt(i + 1);
            char temp = chars[i];
            chars[i] = chars[j];
            chars[j] = temp;
        }
        return new String(chars);
    }

    public boolean isValidPassword(String password) {
        if (password == null || password.length() < 8) return false;
        return password.matches(".*[A-Z].*")
            && password.matches(".*[a-z].*")
            && password.matches(".*[0-9].*")
            && password.matches(".*[!@#$%].*");
    }

    public boolean isEmailTaken(String email, int excludeUserId) throws SQLException {
        return userDAO.isEmailTaken(email, excludeUserId);
    }

    public Optional<User> findByUsername(String username) throws SQLException {
        return userDAO.findByUsername(username);
    }

    public String hashPassword(String rawPassword) {
        return BCrypt.hashpw(rawPassword, BCrypt.gensalt(12));
    }

    public Result createUser(String username, String fullName, String email, String phone,
                            int roleId, boolean active, String rawPassword) {
        try {
            if (username == null || username.trim().isEmpty()
                || fullName == null || fullName.trim().isEmpty()
                || email == null || email.trim().isEmpty()) {
                return Result.failure("Tên đăng nhập, Họ tên và Email không được bỏ trống.");
            }

            if (isEmailTaken(email, 0)) {
                return Result.failure("Địa chỉ email '" + email + "' đã được sử dụng bởi một tài khoản khác.");
            }

            Optional<User> existing = findByUsername(username);
            if (existing.isPresent()) {
                return Result.failure("Tên đăng nhập '" + username + "' đã tồn tại trong hệ thống.");
            }

            Role roleObj = roleDAO.findById(roleId);
            String roleName = (roleObj != null) ? roleObj.getRoleName() : "WAREHOUSE_STAFF";

            String passwordHash = hashPassword(rawPassword);

            User user = new User();
            user.setUsername(username.trim());
            user.setFullName(fullName.trim());
            user.setEmail(email.trim());
            user.setPhone(phone != null ? phone.trim() : null);
            user.setRoleId(roleId);
            user.setRole(roleName);
            user.setActive(active);
            user.setPasswordHash(passwordHash);

            boolean success = userDAO.insert(user);
            if (!success) {
                return Result.failure("Không thể lưu thông tin tài khoản mới.");
            }

            boolean emailSent = emailService.sendNewUserCredentials(user, rawPassword);
            if (!emailSent) {
                log.warn("Failed to send new user email to {}", email);
            }

            return Result.success(user, rawPassword);
        } catch (SQLException e) {
            log.error("Error creating user", e);
            return Result.failure("Lỗi cơ sở dữ liệu: " + e.getMessage());
        }
    }

    public Result updateUser(int userId, String username, String fullName, String email,
                             String phone, int roleId, boolean active, Integer existingWarehouseId) {
        try {
            if (username == null || username.trim().isEmpty()
                || fullName == null || fullName.trim().isEmpty()
                || email == null || email.trim().isEmpty()) {
                return Result.failure("Tên đăng nhập, Họ tên và Email không được bỏ trống.");
            }

            if (isEmailTaken(email, userId)) {
                return Result.failure("Địa chỉ email '" + email + "' đã được sử dụng bởi một tài khoản khác.");
            }

            Role roleObj = roleDAO.findById(roleId);
            String roleName = (roleObj != null) ? roleObj.getRoleName() : "WAREHOUSE_STAFF";

            User user = new User();
            user.setUserId(userId);
            user.setUsername(username.trim());
            user.setFullName(fullName.trim());
            user.setEmail(email.trim());
            user.setPhone(phone != null ? phone.trim() : null);
            user.setRoleId(roleId);
            user.setRole(roleName);
            user.setActive(active);
            if (existingWarehouseId != null) {
                user.setWarehouseId(existingWarehouseId);
            }

            boolean success = userDAO.update(user);
            if (!success) {
                return Result.failure("Không thể cập nhật thông tin tài khoản.");
            }

            return Result.success(user, null);
        } catch (SQLException e) {
            log.error("Error updating user", e);
            return Result.failure("Lỗi cơ sở dữ liệu: " + e.getMessage());
        }
    }

    public boolean updateUser(int userId, boolean active) throws SQLException {
        return userDAO.toggleStatus(userId, active);
    }

    public boolean updateUserFull(User user) throws SQLException {
        return userDAO.update(user);
    }

    public void updateProfile(User user) throws SQLException {
        userDAO.updateProfile(user);
    }

    public void changePassword(int userId, String currentPassword, String newPassword) throws SQLException {
        Optional<User> dbUser = userDAO.findById(userId);
        if (dbUser.isEmpty() || dbUser.get().getPasswordHash() == null) {
            throw new SQLException("User not found or no password set");
        }
        String currentHash = dbUser.get().getPasswordHash();
        if (!BCrypt.checkpw(currentPassword, currentHash)) {
            throw new SQLException("Mật khẩu hiện tại không chính xác");
        }
        String newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));
        userDAO.updatePassword(userId, newHash);
    }

    public void updatePasswordDirect(int userId, String newHash) throws SQLException {
        userDAO.updatePassword(userId, newHash);
    }

    public void updateOtpPreference(int userId, String otpPreference) throws SQLException {
        userDAO.updateOtpPreference(userId, otpPreference);
    }

    public boolean isUsernameTaken(String username, int excludeUserId) throws SQLException {
        return userDAO.isUsernameTaken(username, excludeUserId);
    }

    public void updateUsername(int userId, String newUsername) throws SQLException {
        userDAO.updateUsername(userId, newUsername);
    }

    public static class Result {
        private final boolean success;
        private final String message;
        private final User user;
        private final String rawPassword;

        private Result(boolean success, String message, User user, String rawPassword) {
            this.success = success;
            this.message = message;
            this.user = user;
            this.rawPassword = rawPassword;
        }

        public static Result success(User user, String rawPassword) {
            return new Result(true, null, user, rawPassword);
        }

        public static Result failure(String message) {
            return new Result(false, message, null, null);
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
        public User getUser() { return user; }
        public String getRawPassword() { return rawPassword; }
    }
}
