package com.wms.dao;

import com.wms.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * BaseDAO — Common JDBC boilerplate that every concrete DAO repeats:
 * connection acquisition, try-with-resources setup, parameter binding,
 * row iteration, and quiet error logging.
 *
 * <p>Concrete DAOs are NOT required to extend this class. They may pick and
 * choose the helpers they need. Each helper logs the failure under the
 * caller's class name and returns the supplied fallback (empty list / null /
 * -1 / false) so the public method signatures do not have to change.</p>
 *
 * <p>The intent is to remove the same six lines of try/catch noise from
 * every findAll() / findById() / update() / delete() method in the project
 * without changing any SQL or method signature.</p>
 */
public abstract class BaseDAO {

    /** Functional interface that maps a single JDBC row to a domain object. */
    @FunctionalInterface
    public interface RowMapper<T> {
        T map(ResultSet rs) throws SQLException;
    }

    /**
     * Acquire a connection from the pool, log+swallow on failure.
     * Returns null if the pool cannot give us a connection.
     */
    protected Connection openConnection(Logger logger) {
        try {
            return DBConnection.getConnection();
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Failed to acquire DB connection", e);
            return null;
        }
    }

    /**
     * Run a SELECT that returns zero or one row. Returns null when no row
     * exists or the query throws. The mapper is invoked at most once.
     */
    protected <T> T queryOne(Logger logger, String sql, RowMapper<T> mapper, Object... params) {
        try (Connection conn = openConnection(logger);
             PreparedStatement ps = conn == null ? null : conn.prepareStatement(sql)) {
            if (ps == null) return null;
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapper.map(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.WARNING, "queryOne failed: " + sql, e);
        }
        return null;
    }

    /**
     * Run a SELECT that returns zero or more rows. Returns an empty list
     * when no row exists or the query throws.
     */
    protected <T> List<T> queryList(Logger logger, String sql, RowMapper<T> mapper, Object... params) {
        List<T> out = new ArrayList<>();
        try (Connection conn = openConnection(logger);
             PreparedStatement ps = conn == null ? null : conn.prepareStatement(sql)) {
            if (ps == null) return out;
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(mapper.map(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.WARNING, "queryList failed: " + sql, e);
        }
        return out;
    }

    /**
     * Run an INSERT / UPDATE / DELETE statement and return the number of
     * affected rows. Returns -1 on failure so callers can detect it.
     */
    protected int update(Logger logger, String sql, Object... params) {
        try (Connection conn = openConnection(logger);
             PreparedStatement ps = conn == null ? null : conn.prepareStatement(sql)) {
            if (ps == null) return -1;
            bindParams(ps, params);
            return ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.WARNING, "update failed: " + sql, e);
            return -1;
        }
    }

    /**
     * Bind positional parameters (? placeholders) from a varargs array.
     * Skipped automatically if the array is empty so callers can pass
     * nothing for parameterless queries.
     */
    protected void bindParams(PreparedStatement ps, Object[] params) throws SQLException {
        for (int i = 0; i < params.length; i++) {
            ps.setObject(i + 1, params[i]);
        }
    }
}
