package com.wms.util;

/**
 * AppConstants — Centralised string constants.
 *
 * Avoids magic strings scattered across the codebase.
 */
public final class AppConstants {

    // Prevent instantiation
    private AppConstants() {
        throw new UnsupportedOperationException("This is a utility class and cannot be instantiated");
    }

    // ── Session attribute keys (replaces React Context/State) ─
    public static final String SESSION_USER      = "loggedInUser";
    public static final String SESSION_ROLE      = "userRole";
    public static final String SESSION_WAREHOUSE = "warehouseId";
    public static final String SESSION_PENDING_USER        = "pendingUser";
    public static final String SESSION_PENDING_OTP         = "pendingOtp";
    public static final String SESSION_PENDING_OTP_EXPIRES = "pendingOtpExpires";
    public static final String SESSION_PENDING_OTP_METHOD  = "pendingOtpMethod";
    public static final String SESSION_PENDING_OTP_DEST    = "pendingOtpDestination";
    public static final String SESSION_PENDING_OTP_TARGET  = "pendingOtpTarget";

    // ── Request attribute keys (replaces React prop passing) ──
    public static final String ATTR_ERROR   = "errorMessage";
    public static final String ATTR_SUCCESS = "successMessage";
    public static final String ATTR_INFO    = "infoMessage";
    public static final String ATTR_DATA    = "data";
    public static final String ATTR_PAGE    = "pageTitle";
    public static final String ATTR_LIST    = "itemList";

    // ── JSP view paths ────────────────────────────────────────
    public static final String VIEW_PREFIX = "/WEB-INF/views/";
    public static final String VIEW_SUFFIX = ".jsp";

    // ── User Roles ────────────────────────────────────────────
    public static final String ROLE_ADMIN    = "ADMIN";
    public static final String ROLE_MANAGER  = "MANAGER";
    public static final String ROLE_WAREHOUSE_STAFF = "WAREHOUSE_STAFF";
    public static final String ROLE_SALES_STAFF     = "SALES_STAFF";
    // ROLE_CUSTOMER removed — not used. B2B WMS has 3 business roles + admin only.

    // ── Pagination defaults ───────────────────────────────────
    public static final int DEFAULT_PAGE_SIZE = 15;
    public static final int OTP_EXPIRY_MINUTES = 5;

    // ── Lazada API Integration Constants ──────────────────────
    // Credentials are loaded from db.properties / environment variables (LAZADA_APP_KEY, LAZADA_APP_SECRET).
    // Never hardcode API secrets in source code.
    public static final String LAZADA_AUTH_URL = "https://auth.lazada.com/rest";
    public static final String LAZADA_API_URL = "https://api.lazada.vn/rest";
    public static final String SIGN_METHOD = "sha256";

    /**
     * Lazada App Key — loaded from db.properties or LAZADA_APP_KEY env var.
     */
    public static String getLazadaAppKey() {
        return com.wms.util.DatabaseConfig.getProperty("lazada.appKey",
               System.getenv("LAZADA_APP_KEY"), "138771");
    }

    /**
     * Lazada App Secret — loaded from db.properties or LAZADA_APP_SECRET env var.
     */
    public static String getLazadaAppSecret() {
        return com.wms.util.DatabaseConfig.getProperty("lazada.appSecret",
               System.getenv("LAZADA_APP_SECRET"), "");
    }
}
