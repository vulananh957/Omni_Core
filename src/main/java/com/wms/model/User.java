package com.wms.model;

import java.time.LocalDateTime;

/**
 * User — Domain model / JavaBean representing the user accounts.
 *
 * Fully backward-compatible with legacy ENUM structures while supporting standard RBAC tables.
 */
public class User {

    private int userId;
    private String username;
    private String passwordHash;
    private String fullName;
    private String email;
    private String roleStr;        // Fallback string for backward compatibility
    private Role role;             // Role object for JOIN operations
    private int roleId;
    private int warehouseId = 0;
    private boolean active = true;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String phone;
    private String otpPreference = "EMAIL"; // EMAIL | SMS

    // ── Constructors ──────────────────────────────────────────

    public User() {
    }

    public User(int userId, String username, String fullName, String email,
                String roleStr, int warehouseId, boolean active) {
        this.userId = userId;
        this.username = username;
        this.fullName = fullName;
        this.email = email;
        this.roleStr = roleStr;
        this.warehouseId = warehouseId;
        this.active = active;
    }

    // ── Getters / Setters ─────────────────────────────────────

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    /**
     * Backward-compatible role string retriever.
     * Returns the nested role's name if present, else fallbacks to the flat string.
     */
    public String getRole() {
        if (role != null) {
            return role.getRoleName();
        }
        return roleStr;
    }

    public void setRole(String roleStr) {
        this.roleStr = roleStr;
    }

    public Role getRoleObject() {
        return role;
    }

    public void setRoleObject(Role role) {
        this.role = role;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public int getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(int warehouseId) {
        this.warehouseId = warehouseId;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getPhoneNumber() {
        return phone;
    }

    public void setPhoneNumber(String phone) {
        this.phone = phone;
    }

    public String getOtpPreference() {
        return otpPreference;
    }

    public void setOtpPreference(String otpPreference) {
        this.otpPreference = otpPreference;
    }

    public String getFormattedCreatedAt() {
        if (createdAt == null) {
            return "";
        }
        java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        return createdAt.format(formatter);
    }

    @Override
    public String toString() {
        return "User{" +
                "userId=" + userId +
                ", username='" + username + '\'' +
                ", role='" + getRole() + '\'' +
                ", active=" + active +
                '}';
    }
}
