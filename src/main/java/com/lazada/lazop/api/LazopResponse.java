package com.lazada.lazop.api;

/**
 * Lazada Open Platform Response SDK Polyfill/Stub.
 */
public class LazopResponse {
    private final String body;

    public LazopResponse(String body) {
        this.body = body;
    }

    public String getBody() {
        return body;
    }
}
