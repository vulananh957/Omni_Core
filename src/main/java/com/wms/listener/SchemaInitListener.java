package com.wms.listener;

import com.wms.util.DBConnection;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * SchemaInitListener — Runs once on application startup to ensure the database schema
 * is fully initialised (tables and columns exist).
 *
 * This replaces the fragile "self-modifying DAO constructor" pattern where DDL was
 * executed every time a DAO was instantiated.
 *
 * All schema migrations run ONCE per deployment. If a column already exists, it is skipped.
 */
@WebListener
public class SchemaInitListener implements ServletContextListener {

    private static final Logger LOGGER = Logger.getLogger(SchemaInitListener.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        LOGGER.info("SchemaInitListener: Starting one-time schema initialisation...");
        try {
            ensureRolesTable();
            ensureUsersTableColumns();
            ensureWarehousesTable();
            ensureUserWarehouseAssignments();
            ensureZonesTable();
            ensureCategoriesTable();
            ensureSkusTable();
            ensureProductsTable();
            ensureProductImagesTable();
            ensureChannelsTable();
            ensureChannelProductsTable();
            ensureWebhookLogsTable();
            ensureLazadaSyncLogTable();
            ensureSkuMappingsTable();
            ensureInventoryTable();
            ensureInventoryLedgerTable();
            ensureOrdersTable();
            ensureOrderItemsTable();
            ensureOrderShippingDetailsTable();
            ensureShippingLabelsTable();
            ensureWarehouseReceipts();
            ensureInboundTables();
            ensureWarehouseIssues();
            ensureRmaTables();
            ensureScrapRecordsTable();
            ensureStockTransfers();
            ensureStocktakes();
            seedDefaultData();
            LOGGER.info("SchemaInitListener: Schema initialisation completed successfully.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "SchemaInitListener: FAILED to initialise schema. "
                    + "The application may not function correctly.", e);
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        DBConnection.shutdown();
        LOGGER.info("SchemaInitListener: Connection pool shut down.");
    }

    // ── Helper: create table if not exists ──

    private void createTableIfNotExists(Connection conn, String tableName, String createSql) throws SQLException {
        DatabaseMetaData md = conn.getMetaData();
        try (ResultSet rs = md.getTables(null, null, tableName, new String[]{"TABLE"})) {
            if (!rs.next()) {
                try (Statement st = conn.createStatement()) {
                    st.executeUpdate(createSql);
                    LOGGER.info("SchemaInitListener: Created '" + tableName + "' table.");
                }
            }
        }
    }

    private void addColumnIfMissing(Connection conn, DatabaseMetaData md,
                                   String table, String column, String definition)
            throws SQLException {
        try (ResultSet rs = md.getColumns(null, null, table, column)) {
            if (!rs.next()) {
                try (Statement st = conn.createStatement()) {
                    st.executeUpdate("ALTER TABLE " + table + " ADD COLUMN " + column + " " + definition);
                    LOGGER.info("SchemaInitListener: Added column '" + column + "' to '" + table + "'.");
                }
            }
        }
    }

    // ── Seed default data ──

    private void seedDefaultData() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            Statement st = conn.createStatement();

            // Default warehouse
            st.executeUpdate("INSERT IGNORE INTO warehouses (warehouse_code, warehouse_name, address) "
                    + "VALUES ('WH-01','Kho Ha Noi','So 1 Duong ABC, Ha Noi')");

            // Default categories
            st.executeUpdate("INSERT IGNORE INTO categories (category_id, category_name) VALUES "
                    + "(1, 'Vở & Sổ chép'),"
                    + "(2, 'Phụ kiện cá nhân'),"
                    + "(3, 'Dụng cụ viết & Vẽ'),"
                    + "(4, 'Thiết bị văn phòng tiện ích')");

            // Default roles
            st.executeUpdate("INSERT IGNORE INTO roles (role_name, description) VALUES "
                    + "('ADMIN','Quan tri he thong'),"
                    + "('MANAGER','Quan ly kinh doanh'),"
                    + "('SALES_STAFF','Nhan vien ban hang'),"
                    + "('WAREHOUSE_STAFF','Nhan vien kho')");

            // Default zones for warehouse 1
            st.executeUpdate("INSERT IGNORE INTO zones (warehouse_id, zone_code, zone_name, zone_type, description) VALUES "
                    + "(1,'NORMAL','Khu Thuong','NORMAL','Khu vuc luu tru hang tot'),"
                    + "(1,'RETURN','Khu Tra Hang','RETURN','Khu vuc tam giu hang tra'),"
                    + "(1,'DAMAGED','Khu Hong','DAMAGED','Khu vuc hang hong'),"
                    + "(1,'DESTROY','Khu Tieu Huy','DESTROY','Khu vuc tieu huy hang loi')");

            // Default admin user
            st.executeUpdate("INSERT IGNORE INTO users (username, password_hash, full_name, email, phone, role) VALUES "
                    + "('quanpm','$2a$12$ezv1v4fjwnwMSYQ4DvPHN./NuNfVdwEzGbHuUvlbsabeCZqrLkzxe',"
                    + "'Phạm Minh Quân','pmq07072005@gmail.com','0987654321','ADMIN')");
            st.executeUpdate("UPDATE users SET full_name = 'Phạm Minh Quân', email = 'pmq07072005@gmail.com', phone = '0987654321', role = 'ADMIN' "
                    + "WHERE username = 'quanpm'");

            // Assign admin to warehouse 1
            st.executeUpdate("INSERT IGNORE INTO user_warehouse_assignments (user_id, warehouse_id, is_primary) "
                    + "SELECT user_id, 1, 1 FROM users WHERE username = 'quanpm'");

            // Default SKUs
            st.executeUpdate("INSERT IGNORE INTO skus (sku_code, product_name, category, unit, min_stock, active) VALUES "
                    + "('SKU-001', 'Sữa tươi Vinamilk 180ml', 'Thực Phẩm', 'Cái', 10, 1),"
                    + "('SKU-002', 'Nồi chiên không dầu Philips', 'Đồ Gia Dụng', 'Cái', 5, 1),"
                    + "('SKU-003', 'Tai nghe Sony WH-1000XM4', 'Điện Tử', 'Cái', 2, 1)");

            // Check if orders exist
            try (ResultSet rsOrdersCount = st.executeQuery("SELECT COUNT(*) FROM orders")) {
                if (rsOrdersCount.next() && rsOrdersCount.getInt(1) == 0) {
                    // Seed orders
                    st.executeUpdate("INSERT INTO orders (order_code, warehouse_id, channel, status, total_amount, note, created_at, updated_at) VALUES "
                            + "('ORD-98231', 1, 'ONLINE', 'PENDING', 24000.00, 'Khách đặt qua Shopee', NOW() - INTERVAL 2 HOUR, NOW() - INTERVAL 2 HOUR),"
                            + "('ORD-12948', 1, 'ONLINE', 'PICKING', 1500000.00, 'Xác nhận nhanh', NOW() - INTERVAL 1 DAY, NOW() - INTERVAL 12 HOUR),"
                            + "('ORD-48291', 1, 'ONLINE', 'PACKED', 2500000.00, 'Đóng kỹ chống sốc', NOW() - INTERVAL 1 DAY, NOW() - INTERVAL 10 HOUR),"
                            + "('ORD-57291', 1, 'ONLINE', 'RETURNED', 24000.00, 'Khách trả hàng quay đầu', NOW() - INTERVAL 3 DAY, NOW() - INTERVAL 1 DAY)");

                    // Get the generated order IDs
                    int id1 = -1, id2 = -1, id3 = -1, id4 = -1;
                    try (ResultSet rs = st.executeQuery("SELECT order_id, order_code FROM orders")) {
                        while (rs.next()) {
                            String code = rs.getString("order_code");
                            int id = rs.getInt("order_id");
                            if ("ORD-98231".equals(code)) id1 = id;
                            else if ("ORD-12948".equals(code)) id2 = id;
                            else if ("ORD-48291".equals(code)) id3 = id;
                            else if ("ORD-57291".equals(code)) id4 = id;
                        }
                    }

                    // Get SKU IDs
                    int skuId1 = 1, skuId2 = 2, skuId3 = 3;
                    try (ResultSet rs = st.executeQuery("SELECT sku_id, sku_code FROM skus")) {
                        while (rs.next()) {
                            String code = rs.getString("sku_code");
                            int id = rs.getInt("sku_id");
                            if ("SKU-001".equals(code)) skuId1 = id;
                            else if ("SKU-002".equals(code)) skuId2 = id;
                            else if ("SKU-003".equals(code)) skuId3 = id;
                        }
                    }

                    // Seed order items
                    if (id1 != -1) st.executeUpdate("INSERT INTO order_items (order_id, sku_id, qty, unit_price) VALUES (" + id1 + ", " + skuId1 + ", 2, 12000.00)");
                    if (id2 != -1) st.executeUpdate("INSERT INTO order_items (order_id, sku_id, qty, unit_price) VALUES (" + id2 + ", " + skuId2 + ", 1, 1500000.00)");
                    if (id3 != -1) st.executeUpdate("INSERT INTO order_items (order_id, sku_id, qty, unit_price) VALUES (" + id3 + ", " + skuId3 + ", 1, 2500000.00)");
                    if (id4 != -1) st.executeUpdate("INSERT INTO order_items (order_id, sku_id, qty, unit_price) VALUES (" + id4 + ", " + skuId1 + ", 2, 12000.00)");

                    // Seed custom column values for mock orders
                    if (id2 != -1) st.executeUpdate("UPDATE orders SET tracking_no = 'LZE-8762312', review_note = 'Đã xác nhận và chuyển kho Hà Nội chuẩn bị hàng.' WHERE order_id = " + id2);
                    if (id3 != -1) st.executeUpdate("UPDATE orders SET tracking_no = 'TKT-9281734', review_note = 'Đóng gói hoàn tất, chờ bưu tá lấy hàng.' WHERE order_id = " + id3);
                    if (id4 != -1) st.executeUpdate("UPDATE orders SET tracking_no = 'VTP-1928374', rma_reason = 'Sản phẩm bị bóp méo khi vận chuyển', rma_physical_status = 'Đã nhập Zone Khiếu Nại', rma_platform_status = 'Chờ xử lý' WHERE order_id = " + id4);
                }
            }

            LOGGER.info("SchemaInitListener: Seed data applied.");
        }
    }

    // ── Table initialisers ──

    private void ensureRolesTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "roles",
                "CREATE TABLE roles (role_id INT AUTO_INCREMENT PRIMARY KEY, role_name VARCHAR(50) NOT NULL UNIQUE, description VARCHAR(255)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureUsersTableColumns() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            DatabaseMetaData md = conn.getMetaData();
            addColumnIfMissing(conn, md, "users", "phone", "VARCHAR(20) DEFAULT NULL");
            addColumnIfMissing(conn, md, "users", "otp_preference", "VARCHAR(20) DEFAULT 'EMAIL'");
            addColumnIfMissing(conn, md, "users", "warehouse_id", "INT DEFAULT NULL");
        }
    }

    private void ensureWarehousesTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "warehouses",
                "CREATE TABLE warehouses (warehouse_id INT AUTO_INCREMENT PRIMARY KEY, warehouse_code VARCHAR(20) NOT NULL UNIQUE, warehouse_name VARCHAR(100) NOT NULL, address VARCHAR(255), capacity INT DEFAULT 0, active TINYINT(1) NOT NULL DEFAULT 1, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            DatabaseMetaData md = conn.getMetaData();
            addColumnIfMissing(conn, md, "warehouses", "phone", "VARCHAR(20) DEFAULT NULL");
        }
    }

    private void ensureUserWarehouseAssignments() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "user_warehouse_assignments",
                "CREATE TABLE user_warehouse_assignments (assignment_id INT AUTO_INCREMENT PRIMARY KEY, user_id INT NOT NULL, warehouse_id INT NOT NULL, is_primary TINYINT(1) NOT NULL DEFAULT 0, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, UNIQUE KEY uq_user_warehouse (user_id, warehouse_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureZonesTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "zones",
                "CREATE TABLE zones (zone_id INT AUTO_INCREMENT PRIMARY KEY, warehouse_id INT NOT NULL, zone_code VARCHAR(10) NOT NULL, zone_name VARCHAR(100) NOT NULL, zone_type ENUM('NORMAL','RETURN','DAMAGED','DESTROY') NOT NULL DEFAULT 'NORMAL', description TEXT, active TINYINT(1) NOT NULL DEFAULT 1, UNIQUE KEY uq_zone_code_wh (zone_code, warehouse_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            DatabaseMetaData md = conn.getMetaData();
            addColumnIfMissing(conn, md, "zones", "is_default", "TINYINT(1) NOT NULL DEFAULT 0");
        }
    }

    private void ensureCategoriesTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "categories",
                "CREATE TABLE categories (category_id INT AUTO_INCREMENT PRIMARY KEY, parent_id INT DEFAULT NULL, category_name VARCHAR(100) NOT NULL, level_depth INT DEFAULT 0, active TINYINT(1) NOT NULL DEFAULT 1) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            DatabaseMetaData md = conn.getMetaData();
            addColumnIfMissing(conn, md, "categories", "description", "VARCHAR(255) DEFAULT NULL");
        }
    }

    private void ensureProductsTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "products",
                "CREATE TABLE products (product_id INT AUTO_INCREMENT PRIMARY KEY, category_id INT, sku_code VARCHAR(50) NOT NULL UNIQUE, product_name VARCHAR(255) NOT NULL, base_price DECIMAL(15,2) NOT NULL DEFAULT 0, attributes_text VARCHAR(255), weight_kg DECIMAL(8,3), is_new_arrival TINYINT(1) NOT NULL DEFAULT 0, active TINYINT(1) NOT NULL DEFAULT 1, created_by INT, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, barcode VARCHAR(50) DEFAULT NULL, unit VARCHAR(30) DEFAULT 'Cái', min_stock DECIMAL(12,3) DEFAULT 0, max_stock DECIMAL(12,3) DEFAULT 0, status VARCHAR(20) DEFAULT 'PENDING', approved_at DATETIME DEFAULT NULL, approved_by INT DEFAULT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

            DatabaseMetaData md = conn.getMetaData();
            addColumnIfMissing(conn, md, "products", "barcode", "VARCHAR(50) DEFAULT NULL");
            addColumnIfMissing(conn, md, "products", "unit", "VARCHAR(30) DEFAULT 'Cái'");
            addColumnIfMissing(conn, md, "products", "min_stock", "DECIMAL(12,3) DEFAULT 0");
            addColumnIfMissing(conn, md, "products", "max_stock", "DECIMAL(12,3) DEFAULT 0");
            addColumnIfMissing(conn, md, "products", "status", "VARCHAR(20) DEFAULT 'PENDING'");
            addColumnIfMissing(conn, md, "products", "approved_at", "DATETIME DEFAULT NULL");
            addColumnIfMissing(conn, md, "products", "approved_by", "INT DEFAULT NULL");
        }
    }

    private void ensureProductImagesTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "product_images",
                "CREATE TABLE product_images (image_id INT AUTO_INCREMENT PRIMARY KEY, product_id INT NOT NULL, image_url VARCHAR(500) NOT NULL, is_primary TINYINT(1) NOT NULL DEFAULT 0, sort_order INT NOT NULL DEFAULT 0, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureChannelsTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "channels",
                "CREATE TABLE channels (channel_id INT AUTO_INCREMENT PRIMARY KEY, channel_name VARCHAR(100) NOT NULL, platform VARCHAR(50) NOT NULL, api_url VARCHAR(255), api_key VARCHAR(255), app_secret VARCHAR(255), webhook_secret VARCHAR(255), buffer_stock DECIMAL(12,3) DEFAULT 0.00, is_active TINYINT(1) DEFAULT 1, access_token TEXT, refresh_token TEXT, created_at DATETIME DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureChannelProductsTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "channel_products",
                "CREATE TABLE channel_products (id INT AUTO_INCREMENT PRIMARY KEY, channel_id INT NOT NULL, product_id INT NOT NULL, channel_sku_code VARCHAR(100), channel_price DECIMAL(15,2) NOT NULL DEFAULT 0, channel_stock DECIMAL(12,3) NOT NULL DEFAULT 0, status ENUM('ACTIVE','INACTIVE','PENDING') DEFAULT 'ACTIVE', listed_at DATETIME, updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, UNIQUE KEY uq_channel_product (channel_id, product_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureWebhookLogsTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "webhook_logs",
                "CREATE TABLE webhook_logs (log_id INT AUTO_INCREMENT PRIMARY KEY, channel_id INT, event_type VARCHAR(50) NOT NULL, payload TEXT, status ENUM('SUCCESS','FAILED','PENDING') NOT NULL DEFAULT 'PENDING', error_trace TEXT, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureLazadaSyncLogTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "lazada_sync_log",
                "CREATE TABLE lazada_sync_log (log_id INT AUTO_INCREMENT PRIMARY KEY, channel_id INT, sync_type VARCHAR(50), status ENUM('SUCCESS','FAILED') NOT NULL, request_data TEXT, response_data TEXT, error_msg TEXT, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureSkuMappingsTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "sku_mappings",
                "CREATE TABLE sku_mappings (mapping_id INT AUTO_INCREMENT PRIMARY KEY, sku_id INT NOT NULL, channel_id INT NOT NULL, external_sku VARCHAR(100), seller_sku VARCHAR(100), sync_status ENUM('SYNCED','PENDING','ERROR') DEFAULT 'PENDING', last_sync_at DATETIME, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, UNIQUE KEY uq_sku_channel (sku_id, channel_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureInventoryTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "inventory",
                "CREATE TABLE inventory (inventory_id INT AUTO_INCREMENT PRIMARY KEY, product_id INT NOT NULL, warehouse_id INT NOT NULL, qty_on_hand DECIMAL(12,3) NOT NULL DEFAULT 0, holding DECIMAL(12,3) NOT NULL DEFAULT 0, qty_available DECIMAL(12,3) NOT NULL DEFAULT 0, reorder_point DECIMAL(12,3) DEFAULT NULL, updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, UNIQUE KEY uq_product_warehouse (product_id, warehouse_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureInventoryLedgerTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "inventory_ledger",
                "CREATE TABLE inventory_ledger (ledger_id INT AUTO_INCREMENT PRIMARY KEY, inventory_id INT NOT NULL, product_id INT NOT NULL, warehouse_id INT NOT NULL, transaction_type ENUM('INBOUND','OUTBOUND','ADJUSTMENT','TRANSFER_IN','TRANSFER_OUT') NOT NULL, ref_document_id INT, qty_change DECIMAL(12,3) NOT NULL, avail_change DECIMAL(12,3) NOT NULL, timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by INT, note TEXT) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureSkusTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "skus",
                "CREATE TABLE skus (sku_id INT AUTO_INCREMENT PRIMARY KEY, sku_code VARCHAR(50) NOT NULL UNIQUE, product_name VARCHAR(150) NOT NULL, category VARCHAR(80), unit VARCHAR(30) NOT NULL DEFAULT 'Cái', barcode VARCHAR(50), weight_kg DECIMAL(8,3), description TEXT, min_stock INT NOT NULL DEFAULT 0, active TINYINT(1) NOT NULL DEFAULT 1, created_by INT, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureOrdersTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "orders",
                "CREATE TABLE orders (order_id INT AUTO_INCREMENT PRIMARY KEY, order_code VARCHAR(30) NOT NULL UNIQUE, customer_id INT, warehouse_id INT, channel ENUM('ONLINE','STORE','B2B') NOT NULL DEFAULT 'ONLINE', status ENUM('PENDING','PICKING','PACKED','SHIPPED','DELIVERED','CANCELLED','RETURNED','DISPUTED','DISPUTE_SUCCESS','COMPLETED') NOT NULL DEFAULT 'PENDING', total_amount DECIMAL(15,2) NOT NULL DEFAULT 0, note TEXT, created_by INT, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, tracking_no VARCHAR(100), review_note VARCHAR(255), rma_reason VARCHAR(255), rma_physical_status VARCHAR(100), rma_platform_status VARCHAR(100), dispute_evidence_video VARCHAR(255), dispute_note VARCHAR(255)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            DatabaseMetaData md = conn.getMetaData();
            addColumnIfMissing(conn, md, "orders", "tracking_no", "VARCHAR(100) DEFAULT NULL");
            addColumnIfMissing(conn, md, "orders", "review_note", "VARCHAR(255) DEFAULT NULL");
            addColumnIfMissing(conn, md, "orders", "rma_reason", "VARCHAR(255) DEFAULT NULL");
            addColumnIfMissing(conn, md, "orders", "rma_physical_status", "VARCHAR(100) DEFAULT NULL");
            addColumnIfMissing(conn, md, "orders", "rma_platform_status", "VARCHAR(100) DEFAULT NULL");
            addColumnIfMissing(conn, md, "orders", "dispute_evidence_video", "VARCHAR(255) DEFAULT NULL");
            addColumnIfMissing(conn, md, "orders", "dispute_note", "VARCHAR(255) DEFAULT NULL");
        }
    }

    private void ensureOrderItemsTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "order_items",
                "CREATE TABLE order_items (order_item_id INT AUTO_INCREMENT PRIMARY KEY, order_id INT NOT NULL, sku_id INT NOT NULL, qty INT NOT NULL DEFAULT 1, unit_price DECIMAL(12,2) NOT NULL DEFAULT 0.00) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureOrderShippingDetailsTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "order_shipping_details",
                "CREATE TABLE order_shipping_details (shipping_id INT AUTO_INCREMENT PRIMARY KEY, order_id INT NOT NULL UNIQUE, recipient_name VARCHAR(100) NOT NULL, shipping_address TEXT NOT NULL, courier_name VARCHAR(50), waybill_code VARCHAR(100), shipping_status ENUM('PENDING','PICKED_UP','IN_TRANSIT','OUT_FOR_DELIVERY','DELIVERED','RETURNED') NOT NULL DEFAULT 'PENDING', created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureShippingLabelsTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "shipping_labels",
                "CREATE TABLE shipping_labels (label_id INT AUTO_INCREMENT PRIMARY KEY, order_id INT NOT NULL, outbound_id INT, carrier VARCHAR(50), tracking_no VARCHAR(100), label_url VARCHAR(255), printed TINYINT(1) DEFAULT 0, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureWarehouseReceipts() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "warehouse_receipts",
                "CREATE TABLE warehouse_receipts (receipt_id INT AUTO_INCREMENT PRIMARY KEY, receipt_code VARCHAR(50) NOT NULL UNIQUE, warehouse_id INT NOT NULL, receipt_type ENUM('PURCHASE','RETURN','TRANSFER') NOT NULL DEFAULT 'PURCHASE', supplier_name VARCHAR(255), created_by INT NOT NULL, copied_from_id INT, status ENUM('DRAFT','APPROVED','CANCELLED') NOT NULL DEFAULT 'DRAFT', created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureInboundTables() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "inbound_orders",
                "CREATE TABLE inbound_orders (inbound_id INT AUTO_INCREMENT PRIMARY KEY, inbound_code VARCHAR(30) NOT NULL UNIQUE, warehouse_id INT NOT NULL, supplier VARCHAR(100), status ENUM('PENDING','IN_PROGRESS','RECEIVED','CANCELLED') NOT NULL DEFAULT 'PENDING', received_by INT, note TEXT, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, received_at DATETIME) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            createTableIfNotExists(conn, "inbound_items",
                "CREATE TABLE inbound_items (inbound_item_id INT AUTO_INCREMENT PRIMARY KEY, inbound_id INT NOT NULL, product_id INT NOT NULL, expected_qty DECIMAL(12,3) NOT NULL DEFAULT 0, received_qty DECIMAL(12,3) NOT NULL DEFAULT 0) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            createTableIfNotExists(conn, "receipt_notes",
                "CREATE TABLE receipt_notes (receipt_id INT AUTO_INCREMENT PRIMARY KEY, inbound_id INT NOT NULL, warehouse_id INT NOT NULL, received_by INT, note TEXT, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureWarehouseIssues() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "warehouse_issues",
                "CREATE TABLE warehouse_issues (issue_id INT AUTO_INCREMENT PRIMARY KEY, issue_code VARCHAR(50) NOT NULL UNIQUE, warehouse_id INT NOT NULL, issue_type ENUM('ORDER','SCRAP','TRANSFER') NOT NULL, ref_order_id INT, transfer_id INT, dest_zone_id INT, created_by INT NOT NULL, copied_from_id INT, status ENUM('DRAFT','APPROVED','CANCELLED') NOT NULL DEFAULT 'DRAFT', created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            createTableIfNotExists(conn, "issue_details",
                "CREATE TABLE issue_details (detail_id INT AUTO_INCREMENT PRIMARY KEY, issue_id INT NOT NULL, product_id INT NOT NULL, quantity DECIMAL(12,3) NOT NULL, note VARCHAR(255)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            createTableIfNotExists(conn, "outbound_orders",
                "CREATE TABLE outbound_orders (outbound_id INT AUTO_INCREMENT PRIMARY KEY, order_id INT NOT NULL, warehouse_id INT NOT NULL, status ENUM('PENDING','PICKING','PACKED','SHIPPED','DELIVERED','CANCELLED') NOT NULL DEFAULT 'PENDING', picked_by INT, shipped_at DATETIME, note TEXT, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            createTableIfNotExists(conn, "outbound_items",
                "CREATE TABLE outbound_items (outbound_item_id INT AUTO_INCREMENT PRIMARY KEY, outbound_id INT NOT NULL, product_id INT NOT NULL, qty DECIMAL(12,3) NOT NULL DEFAULT 1, picked_qty DECIMAL(12,3) NOT NULL DEFAULT 0) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            createTableIfNotExists(conn, "picking_sheets",
                "CREATE TABLE picking_sheets (sheet_id INT AUTO_INCREMENT PRIMARY KEY, outbound_id INT NOT NULL, picker_id INT, status ENUM('PENDING','IN_PROGRESS','COMPLETED') DEFAULT 'PENDING', started_at DATETIME, completed_at DATETIME) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            createTableIfNotExists(conn, "delivery_notes",
                "CREATE TABLE delivery_notes (delivery_id INT AUTO_INCREMENT PRIMARY KEY, outbound_id INT NOT NULL, delivered_by INT, delivery_date DATETIME, recipient_name VARCHAR(100), recipient_note TEXT) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureRmaTables() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "rma_requests",
                "CREATE TABLE rma_requests (rma_id INT AUTO_INCREMENT PRIMARY KEY, order_id INT NOT NULL, channel_return_id VARCHAR(100), return_waybill VARCHAR(100), rma_code VARCHAR(50) NOT NULL UNIQUE, status ENUM('PENDING','APPROVED','DISPUTED','RESOLVED') NOT NULL DEFAULT 'PENDING', return_reason VARCHAR(255) NOT NULL, zone_id INT, requested_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, returned_at DATETIME) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            createTableIfNotExists(conn, "rma_items",
                "CREATE TABLE rma_items (rma_item_id INT AUTO_INCREMENT PRIMARY KEY, rma_id INT NOT NULL, product_id INT NOT NULL, channel_return_item_id VARCHAR(100), quantity DECIMAL(12,3) NOT NULL DEFAULT 1, refund_amount DECIMAL(15,2)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            createTableIfNotExists(conn, "qc_inspections",
                "CREATE TABLE qc_inspections (qc_id INT AUTO_INCREMENT PRIMARY KEY, rma_item_id INT NOT NULL, inspected_by INT NOT NULL, good_quantity DECIMAL(12,3) NOT NULL DEFAULT 0, good_zone_id INT, damaged_quantity DECIMAL(12,3) NOT NULL DEFAULT 0, damaged_zone_id INT, notes TEXT, inspected_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            createTableIfNotExists(conn, "return_orders",
                "CREATE TABLE return_orders (return_id INT AUTO_INCREMENT PRIMARY KEY, order_id INT, outbound_id INT, customer_name VARCHAR(100), reason VARCHAR(255), status ENUM('RECEIVED','INSPECTING','PASS','FAIL','RESTOCKED','SCRAPPED') DEFAULT 'RECEIVED', warehouse_id INT NOT NULL, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            createTableIfNotExists(conn, "qc_records",
                "CREATE TABLE qc_records (qc_id INT AUTO_INCREMENT PRIMARY KEY, return_id INT NOT NULL, product_id INT, decision ENUM('PASS','FAIL') NOT NULL, qc_notes TEXT, qc_by INT, qc_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureScrapRecordsTable() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "scrap_records",
                "CREATE TABLE scrap_records (scrap_id INT AUTO_INCREMENT PRIMARY KEY, return_id INT NOT NULL, product_id INT, qty DECIMAL(12,3) NOT NULL DEFAULT 1, reason VARCHAR(255), scrap_by INT, scrap_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureStockTransfers() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "stock_transfers",
                "CREATE TABLE stock_transfers (transfer_id INT AUTO_INCREMENT PRIMARY KEY, transfer_code VARCHAR(50) NOT NULL UNIQUE, from_warehouse_id INT NOT NULL, to_warehouse_id INT NOT NULL, created_by INT NOT NULL, approved_by INT, status ENUM('DRAFT','IN_TRANSIT','RECEIVED','CANCELLED') NOT NULL DEFAULT 'DRAFT', note TEXT, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, completed_at DATETIME) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            createTableIfNotExists(conn, "stock_transfer_items",
                "CREATE TABLE stock_transfer_items (transfer_item_id INT AUTO_INCREMENT PRIMARY KEY, transfer_id INT NOT NULL, product_id INT NOT NULL, shipped_qty DECIMAL(12,3) NOT NULL, received_qty DECIMAL(12,3)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            createTableIfNotExists(conn, "transfer_details",
                "CREATE TABLE transfer_details (transfer_detail_id INT AUTO_INCREMENT PRIMARY KEY, transfer_id INT NOT NULL, product_id INT NOT NULL, qty INT NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private void ensureStocktakes() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            createTableIfNotExists(conn, "physical_inventories",
                "CREATE TABLE physical_inventories (inventory_check_id INT AUTO_INCREMENT PRIMARY KEY, check_code VARCHAR(50) NOT NULL UNIQUE, warehouse_id INT NOT NULL, created_by INT NOT NULL, status ENUM('DRAFT','IN_PROGRESS','APPROVED') NOT NULL DEFAULT 'DRAFT', created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            createTableIfNotExists(conn, "physical_inventory_details",
                "CREATE TABLE physical_inventory_details (check_detail_id INT AUTO_INCREMENT PRIMARY KEY, inventory_check_id INT NOT NULL, product_id INT NOT NULL, system_qty DECIMAL(12,3) NOT NULL DEFAULT 0, actual_qty DECIMAL(12,3) DEFAULT NULL, delta_qty DECIMAL(12,3) DEFAULT NULL, counted_by INT, counted_at DATETIME) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            createTableIfNotExists(conn, "stocktakes",
                "CREATE TABLE stocktakes (stocktake_id INT AUTO_INCREMENT PRIMARY KEY, stocktake_code VARCHAR(30) NOT NULL UNIQUE, warehouse_id INT NOT NULL, status ENUM('PLANNED','IN_PROGRESS','COMPLETED','CANCELLED') DEFAULT 'PLANNED', counted_by INT, approved_by INT, note TEXT, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, completed_at DATETIME) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            createTableIfNotExists(conn, "stocktake_items",
                "CREATE TABLE stocktake_items (item_id INT AUTO_INCREMENT PRIMARY KEY, stocktake_id INT NOT NULL, product_id INT NOT NULL, system_qty INT NOT NULL DEFAULT 0, counted_qty INT DEFAULT NULL, variance INT DEFAULT NULL, counted_by INT, counted_at DATETIME) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }
}
