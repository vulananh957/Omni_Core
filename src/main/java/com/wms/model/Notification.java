package com.wms.model;

import java.time.LocalDateTime;

/**
 * Notification — Domain model representing a system notification / alert.
 *
 * <p>Notifications are scoped by role and optionally by warehouse_id so that
 * warehouse staff only see alerts for their own warehouse. The notification
 * type drives the icon colour and priority is reflected in the UI badge.</p>
 */
public class Notification {

    // ── Notification Types ───────────────────────────────────────────
    public static final String TYPE_INBOUND    = "INBOUND";    // Phiếu nhập kho
    public static final String TYPE_OUTBOUND   = "OUTBOUND";   // Phiếu xuất kho
    public static final String TYPE_TRANSFER   = "TRANSFER";   // Phiếu chuyển kho
    public static final String TYPE_RETURN     = "RETURN";     // Phiếu hoàn hàng (RMA)
    public static final String TYPE_DEFECTIVE  = "DEFECTIVE";  // Hàng lỗi
    public static final String TYPE_INVENTORY  = "INVENTORY";  // Phiếu kiểm kê
    public static final String TYPE_ORDER      = "ORDER";      // Đơn hàng mới / cập nhật
    public static final String TYPE_APPROVAL   = "APPROVAL";   // Phiếu chờ duyệt
    public static final String TYPE_SYSTEM     = "SYSTEM";     // Thông báo hệ thống

    // ── Priority Levels ─────────────────────────────────────────────
    public static final String PRIORITY_LOW    = "LOW";
    public static final String PRIORITY_NORMAL = "NORMAL";
    public static final String PRIORITY_HIGH   = "HIGH";
    public static final String PRIORITY_URGENT = "URGENT";

    private long id;
    private int recipientUserId;
    private String recipientRole;
    private Integer warehouseId;           // null = all warehouses
    private String notificationType;
    private String title;
    private String message;
    private String referenceType;          // e.g. "GRN", "GI", "KK", "TR", "RMA", "ORDER"
    private Long referenceId;               // FK to the source document/record
    private String priority;
    private boolean isRead;
    private LocalDateTime createdAt;
    private LocalDateTime readAt;
    // Derived fields (set by DAO mapping, not persisted)
    private String warehouseName;          // for display

    // ── Constructors ────────────────────────────────────────────────

    public Notification() {
        this.priority = PRIORITY_NORMAL;
        this.isRead = false;
    }

    public Notification(int recipientUserId, String recipientRole, Integer warehouseId,
                       String notificationType, String title, String message,
                       String referenceType, Long referenceId, String priority) {
        this.recipientUserId = recipientUserId;
        this.recipientRole = recipientRole;
        this.warehouseId = warehouseId;
        this.notificationType = notificationType;
        this.title = title;
        this.message = message;
        this.referenceType = referenceType;
        this.referenceId = referenceId;
        this.priority = priority != null ? priority : PRIORITY_NORMAL;
        this.isRead = false;
    }

    // ── Convenience factory methods ────────────────────────────────

    /**
     * Creates a role-scoped notification (no specific user).
     */
    public static Notification forRole(String recipientRole, Integer warehouseId,
                                      String type, String title, String message,
                                      String refType, Long refId, String priority) {
        Notification n = new Notification();
        n.recipientUserId = 0;
        n.recipientRole = recipientRole;
        n.warehouseId = warehouseId;
        n.notificationType = type;
        n.title = title;
        n.message = message;
        n.referenceType = refType;
        n.referenceId = refId;
        n.priority = priority;
        return n;
    }

    /**
     * Creates a user-specific notification.
     */
    public static Notification forUser(int userId, String recipientRole, Integer warehouseId,
                                      String type, String title, String message,
                                      String refType, Long refId, String priority) {
        Notification n = new Notification();
        n.recipientUserId = userId;
        n.recipientRole = recipientRole;
        n.warehouseId = warehouseId;
        n.notificationType = type;
        n.title = title;
        n.message = message;
        n.referenceType = refType;
        n.referenceId = refId;
        n.priority = priority;
        return n;
    }

    // ── Getters / Setters ─────────────────────────────────────────

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public int getRecipientUserId() {
        return recipientUserId;
    }

    public void setRecipientUserId(int recipientUserId) {
        this.recipientUserId = recipientUserId;
    }

    public String getRecipientRole() {
        return recipientRole;
    }

    public void setRecipientRole(String recipientRole) {
        this.recipientRole = recipientRole;
    }

    public Integer getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(Integer warehouseId) {
        this.warehouseId = warehouseId;
    }

    public String getNotificationType() {
        return notificationType;
    }

    public void setNotificationType(String notificationType) {
        this.notificationType = notificationType;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getReferenceType() {
        return referenceType;
    }

    public void setReferenceType(String referenceType) {
        this.referenceType = referenceType;
    }

    public Long getReferenceId() {
        return referenceId;
    }

    public void setReferenceId(Long referenceId) {
        this.referenceId = referenceId;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean read) {
        isRead = read;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getReadAt() {
        return readAt;
    }

    public void setReadAt(LocalDateTime readAt) {
        this.readAt = readAt;
    }

    public String getWarehouseName() {
        return warehouseName;
    }

    public void setWarehouseName(String warehouseName) {
        this.warehouseName = warehouseName;
    }

    // ── Computed helpers ───────────────────────────────────────────

    public boolean isHighPriority() {
        return PRIORITY_HIGH.equals(priority) || PRIORITY_URGENT.equals(priority);
    }

    /**
     * Returns a CSS icon class suffix for this notification type.
     * e.g. "grn", "gi", "tr", "rma", "defect", "order"
     */
    public String getIconClass() {
        if (notificationType == null) return "default";
        switch (notificationType) {
            case TYPE_INBOUND:   return "grn";
            case TYPE_OUTBOUND:  return "gi";
            case TYPE_TRANSFER:  return "tr";
            case TYPE_RETURN:    return "rma";
            case TYPE_DEFECTIVE: return "defect";
            case TYPE_ORDER:     return "order";
            case TYPE_APPROVAL:  return "approval";
            default:              return "default";
        }
    }

    /**
     * Returns relative time string e.g. "5 phút trước", "2 giờ trước"
     */
    public String getRelativeTime() {
        if (createdAt == null) return "";
        LocalDateTime now = LocalDateTime.now();
        long minutes = java.time.Duration.between(createdAt, now).toMinutes();
        if (minutes < 1) return "Vừa xong";
        if (minutes < 60) return minutes + " phút trước";
        long hours = minutes / 60;
        if (hours < 24) return hours + " giờ trước";
        long days = hours / 24;
        if (days < 7) return days + " ngày trước";
        return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM HH:mm"));
    }

    @Override
    public String toString() {
        return "Notification{" +
                "id=" + id +
                ", type=" + notificationType +
                ", title='" + title + '\'' +
                ", read=" + isRead +
                '}';
    }
}
