package com.lazada.lazop.api;

import java.util.TreeMap;

/**
 * Lazada Open Platform Request SDK Polyfill/Stub.
 */
public class LazopRequest {
    private String apiName;
    private String httpMethod = "GET";
    private final TreeMap<String, String> apiParams = new TreeMap<>();

    public void setApiName(String apiName) {
        this.apiName = apiName;
    }

    public String getApiName() {
        return apiName;
    }

    public void setHttpMethod(String httpMethod) {
        this.httpMethod = httpMethod;
    }

    public String getHttpMethod() {
        return httpMethod;
    }

    public void addApiParameter(String key, String value) {
        apiParams.put(key, value);
    }

    public TreeMap<String, String> getApiParams() {
        return apiParams;
    }
}
