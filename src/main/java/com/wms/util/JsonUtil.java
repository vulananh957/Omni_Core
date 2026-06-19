package com.wms.util;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import java.util.logging.Logger;

/**
 * Utility class for shared Jackson ObjectMapper with Java Time support.
 */
public class JsonUtil {

    private static final Logger LOGGER = Logger.getLogger(JsonUtil.class.getName());
    private static final ObjectMapper MAPPER = new ObjectMapper();

    static {
        // Register JavaTimeModule to handle java.time.LocalDateTime
        MAPPER.registerModule(new JavaTimeModule());
        // Write dates as standard ISO-8601 strings rather than timestamps
        MAPPER.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
        // Ensure UTF-8 encoding for proper Vietnamese character handling
        MAPPER.getFactory().disable(JsonGenerator.Feature.AUTO_CLOSE_TARGET);
    }

    public static ObjectMapper getMapper() {
        return MAPPER;
    }

    public static String toJson(Object obj) {
        if (obj == null) return "null";
        try {
            return MAPPER.writeValueAsString(obj);
        } catch (JsonProcessingException e) {
            LOGGER.warning("JsonUtil serialization failed: " + e.getMessage());
            return "[]";
        }
    }
}
