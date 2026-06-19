package com.wms.dao;

import com.wms.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * WarehouseIssueDAO — Data Access Object for warehouse issue notes (warehouse_issues).
 * Currently supports SCRAP (disposal) issues.
 */
public class WarehouseIssueDAO {

    private static final Logger LOGGER = Logger.getLogger(WarehouseIssueDAO.class.getName());
    private static final DateTimeFormatter CODE_FMT = DateTimeFormatter.ofPattern("yyyyMMdd");

    /**
     * Creates a SCRAP (disposal) issue note in DRAFT status with a single line item.
     * Does NOT touch inventory — stock deduction happens later on BM approval.
     *
     * @return the generated issue_code, or null on failure.
     */
    public String createScrapIssue(int warehouseId, int createdBy, int productId, BigDecimal qty, String reason) {
        String issueCode = "XH-" + LocalDate.now().format(CODE_FMT) + "-"
                         + String.format("%03d", (int) (Math.random() * 1000));

        String sqlIssue = "INSERT INTO warehouse_issues "
                        + "(issue_code, warehouse_id, issue_type, created_by, status, created_at) "
                        + "VALUES (?, ?, 'SCRAP', ?, 'DRAFT', NOW())";
        String sqlDetail = "INSERT INTO issue_details (issue_id, product_id, quantity, note) "
                         + "VALUES (?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int issueId;
            try (PreparedStatement ps = conn.prepareStatement(sqlIssue, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, issueCode);
                ps.setInt(2, warehouseId);
                ps.setInt(3, createdBy);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (!rs.next()) { conn.rollback(); return null; }
                    issueId = rs.getInt(1);
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(sqlDetail)) {
                ps.setInt(1, issueId);
                ps.setInt(2, productId);
                ps.setBigDecimal(3, qty);
                ps.setString(4, reason);
                ps.executeUpdate();
            }

            conn.commit();
            LOGGER.info("createScrapIssue: created " + issueCode + " for product " + productId);
            return issueCode;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "WarehouseIssueDAO: Failed to create scrap issue", e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { /* ignore */ }
            }
            return null;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { /* ignore */ }
            }
        }
    }
}
