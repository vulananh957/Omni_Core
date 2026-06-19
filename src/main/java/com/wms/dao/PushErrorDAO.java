package com.wms.dao;

import com.wms.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * PushErrorDAO — Data Access Object for {@code push_errors}.
 *
 * <p>UC-B2C09: Append-only audit log of every failed Lazada push attempt.
 * Sales staff can review the history to spot recurring error patterns.</p>
 *
 * <p>Rows are write-only; there is no update / delete method.</p>
 */
public class PushErrorDAO {

    private static final Logger LOGGER = Logger.getLogger(PushErrorDAO.class.getName());

    /**
     * Persists a push failure for later inspection.
     *
     * @param channelProductId id in {@code channel_products}, or -1 if unknown
     * @param channelId        the channel the push was attempted on
     * @param skuCode          master SKU code (for cross-reference)
     * @param errorCode        Lazada error code (e.g. "BIZ_CHECK_PRICE_IS_ZERO")
     * @param errorMessage     translated VI message (truncated to 500 chars)
     * @param fieldErrorsJson  raw JSON array of field-level errors, or null
     * @param rawResponse      full Lazada response body, or null
     * @return generated id, or -1 on failure
     */
    public int insert(int channelProductId, int channelId, String skuCode,
                      String errorCode, String errorMessage,
                      String fieldErrorsJson, String rawResponse) {
        String sql = "INSERT INTO push_errors "
                   + "(channel_product_id, channel_id, sku_code, error_code, "
                   + " error_message, field_errors_json, raw_response) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql,
                     PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, channelProductId);
            ps.setInt(2, channelId);
            ps.setString(3, truncate(skuCode, 100));
            ps.setString(4, truncate(errorCode, 50));
            ps.setString(5, truncate(errorMessage, 500));
            ps.setString(6, fieldErrorsJson);
            ps.setString(7, rawResponse);
            if (ps.executeUpdate() == 0) return -1;
            try (var keys = ps.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : -1;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING,
                "PushErrorDAO.insert failed channel=" + channelId + " sku=" + skuCode, e);
            return -1;
        }
    }

    private static String truncate(String s, int max) {
        if (s == null) return null;
        return s.length() > max ? s.substring(0, max) : s;
    }
}
