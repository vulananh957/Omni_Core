package com.wms.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DBConnection — HikariCP-backed connection factory.
 *
 * Usage:
 *   try (Connection conn = DBConnection.getConnection()) {
 *       // ... use conn
 *   }
 *
 * Configuration is loaded from:
 *   1. Environment variables (DB_HOST, DB_PORT, DB_NAME, DB_USERNAME, DB_PASSWORD)
 *   2. /db.properties on classpath
 *   3. Hardcoded defaults (dev only)
 *
 * TEAM RULE: Never create Connection objects outside this class.
 * Always call conn.close() or use try-with-resources.
 */
public class DBConnection {

    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());

    private static volatile HikariDataSource dataSource;

    private DBConnection() {
        throw new UnsupportedOperationException();
    }

    /**
     * Initialises the HikariCP pool (once, on first access).
     */
    private static void initDataSource() {
        synchronized (DBConnection.class) {
            if (dataSource != null) {
                return;
            }

            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(DatabaseConfig.getJdbcUrl());
            config.setUsername(DatabaseConfig.getUsername());
            config.setPassword(DatabaseConfig.getPassword());
            config.setDriverClassName("com.mysql.cj.jdbc.Driver");

            config.setMinimumIdle(DatabaseConfig.getPoolMinIdle());
            config.setMaximumPoolSize(DatabaseConfig.getPoolMaxSize());
            config.setConnectionTimeout(DatabaseConfig.getPoolConnectionTimeout());
            config.setIdleTimeout(DatabaseConfig.getPoolIdleTimeout());
            config.setMaxLifetime(DatabaseConfig.getPoolMaxLifetime());

            config.setPoolName("WMS-HikariCP-Pool");
            config.addDataSourceProperty("cachePrepStmts", "true");
            config.addDataSourceProperty("prepStmtCacheSize", "250");
            config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
            config.addDataSourceProperty("characterEncoding", "UTF-8");
            config.setConnectionInitSql("SET NAMES utf8mb4");

            dataSource = new HikariDataSource(config);
            LOGGER.info("HikariCP connection pool initialised — max="
                    + config.getMaximumPoolSize() + ", minIdle=" + config.getMinimumIdle());
        }
    }

    private static final String SQL_SET_CHARSET =
        "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci";

    private static void enforceUtf8mb4(Connection conn) {
        try (Statement st = conn.createStatement()) {
            st.executeUpdate(SQL_SET_CHARSET);
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to enforce utf8mb4 on connection", e);
        }
    }

    /**
     * Returns a pooled Connection.
     * Caller must close the connection (or use try-with-resources).
     */
    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            initDataSource();
        }
        Connection conn = dataSource.getConnection();
        enforceUtf8mb4(conn);
        return conn;
    }

    /**
     * Closes the entire connection pool (call on app shutdown only).
     */
    public static void shutdown() {
        if (dataSource != null) {
            dataSource.close();
            LOGGER.info("HikariCP pool shut down.");
        }
    }

    // ── Utility: silent close helpers ────────────────────────

    public static void closeQuietly(AutoCloseable... resources) {
        for (AutoCloseable r : resources) {
            if (r != null) {
                try {
                    r.close();
                } catch (Exception e) {
                    LOGGER.log(Level.WARNING, "Failed to close resource", e);
                }
            }
        }
    }
}
