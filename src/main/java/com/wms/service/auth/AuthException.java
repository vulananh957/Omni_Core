package com.wms.service.auth;

/**
 * Thrown when authentication fails for a specific, distinguishable reason.
 * Allows LoginServlet to show the correct error message to the user.
 */
public class AuthException extends RuntimeException {

    public enum Reason {
        NOT_FOUND,       // username/email/phone does not exist
        WRONG_PASSWORD,  // credentials exist but password is wrong
        ACCOUNT_LOCKED   // account exists but is deactivated
    }

    private final Reason reason;

    public AuthException(Reason reason, String message) {
        super(message);
        this.reason = reason;
    }

    public Reason getReason() {
        return reason;
    }
}
