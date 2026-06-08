-- ============================================================
-- WMS Hub — MySQL Schema (Synced with ERD in dbdiagram)
-- Database: wms_hub
-- Charset:  utf8mb4 (full Vietnamese + emoji support)
-- ============================================================

CREATE DATABASE IF NOT EXISTS wms_hub
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE wms_hub;

-- ── NHOM 1: Users & RBAC ───────────────────────────────

CREATE TABLE IF NOT EXISTS roles (
    role_id      INT AUTO_INCREMENT PRIMARY KEY,
    role_name    VARCHAR(50)  NOT NULL UNIQUE,
    description  VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO roles (role_name, description) VALUES
    ('ADMIN',           'Quan tri he thong'),
    ('MANAGER',         'Quan ly kinh doanh'),
    ('SALES_STAFF',      'Nhan vien ban hang'),
    ('WAREHOUSE_STAFF', 'Nhan vien kho');

CREATE TABLE IF NOT EXISTS users (
    user_id         INT AUTO_INCREMENT PRIMARY KEY,
    username        VARCHAR(50)  NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    full_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(100) NOT NULL,
    phone           VARCHAR(20)  DEFAULT NULL,
    role            ENUM('ADMIN','MANAGER','SALES_STAFF','WAREHOUSE_STAFF') NOT NULL DEFAULT 'WAREHOUSE_STAFF',
    warehouse_id    INT NOT NULL DEFAULT 1,
    active          TINYINT(1)   NOT NULL DEFAULT 1,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_users_role (role),
    INDEX idx_users_active (active),
    INDEX idx_users_email (email),
    INDEX idx_users_warehouse (warehouse_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- user-warehouse assignments: N-N via join table (ERD: user_branch_assignments)
CREATE TABLE IF NOT EXISTS user_warehouse_assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id       INT NOT NULL,
    warehouse_id  INT NOT NULL,
    is_primary    TINYINT(1) NOT NULL DEFAULT 0,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_warehouse (user_id, warehouse_id),
    FOREIGN KEY (user_id)      REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── NHOM 2: Warehouses (Branches) ─────────────────────

CREATE TABLE IF NOT EXISTS warehouses (
    warehouse_id   INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_code VARCHAR(20)  NOT NULL UNIQUE,
    warehouse_name VARCHAR(100) NOT NULL,
    address        VARCHAR(255),
    phone          VARCHAR(20)  DEFAULT NULL,
    capacity       INT          DEFAULT 0,
    active         TINYINT(1)   NOT NULL DEFAULT 1,
    created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Zones within a warehouse (ERD: zones)
CREATE TABLE IF NOT EXISTS zones (
    zone_id     INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    zone_code   VARCHAR(10)  NOT NULL,
    zone_name   VARCHAR(100) NOT NULL,
    zone_type   ENUM('NORMAL','RETURN','DAMAGED','DESTROY') NOT NULL DEFAULT 'NORMAL',
    description TEXT,
    active      TINYINT(1) NOT NULL DEFAULT 1,
    is_default  TINYINT(1) NOT NULL DEFAULT 0,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    UNIQUE KEY uq_zone_code_wh (zone_code, warehouse_id),
    INDEX idx_zones_wh (warehouse_id),
    INDEX idx_zones_type (zone_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── NHOM 3: Products & Categories ──────────────────────

CREATE TABLE IF NOT EXISTS categories (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    parent_id     INT DEFAULT NULL,
    category_name VARCHAR(100) NOT NULL,
    description   VARCHAR(255) DEFAULT NULL,
    level_depth   INT DEFAULT 0,
    active        TINYINT(1) NOT NULL DEFAULT 1,
    FOREIGN KEY (parent_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    INDEX idx_cat_parent (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Products (ERD: products)
CREATE TABLE IF NOT EXISTS products (
    product_id      INT AUTO_INCREMENT PRIMARY KEY,
    category_id     INT,
    sku_code        VARCHAR(50)  NOT NULL UNIQUE,
    product_name    VARCHAR(255) NOT NULL,
    base_price     DECIMAL(15,2) NOT NULL DEFAULT 0,
    attributes_text VARCHAR(255),
    weight_kg       DECIMAL(8,3),
    is_new_arrival  TINYINT(1) NOT NULL DEFAULT 0,
    active          TINYINT(1)   NOT NULL DEFAULT 1,
    created_by      INT,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    FOREIGN KEY (created_by)  REFERENCES users(user_id),
    INDEX idx_products_category (category_id),
    INDEX idx_products_active (active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Product images (ERD: product_images)
CREATE TABLE IF NOT EXISTS product_images (
    image_id    INT AUTO_INCREMENT PRIMARY KEY,
    product_id  INT NOT NULL,
    image_url   VARCHAR(500) NOT NULL,
    is_primary  TINYINT(1) NOT NULL DEFAULT 0,
    sort_order  INT NOT NULL DEFAULT 0,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_img_product_primary (product_id, is_primary)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── NHOM 4: Sales Channels ──────────────────────────────

CREATE TABLE IF NOT EXISTS channels (
    channel_id     INT AUTO_INCREMENT PRIMARY KEY,
    channel_name   VARCHAR(100) NOT NULL,
    platform       VARCHAR(50)  NOT NULL,
    api_url        VARCHAR(255),
    api_key        VARCHAR(255),
    app_secret     VARCHAR(255),
    webhook_secret VARCHAR(255),
    buffer_stock   DECIMAL(12,3) DEFAULT 0.00,
    is_active      TINYINT(1)  DEFAULT 1,
    access_token   TEXT,
    refresh_token  TEXT,
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Channel-specific products (ERD: channel_products)
CREATE TABLE IF NOT EXISTS channel_products (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    channel_id       INT NOT NULL,
    product_id       INT NOT NULL,
    channel_sku_code VARCHAR(100),
    channel_price    DECIMAL(15,2) NOT NULL DEFAULT 0,
    channel_stock    DECIMAL(12,3) NOT NULL DEFAULT 0,
    status           ENUM('ACTIVE','INACTIVE','PENDING') DEFAULT 'ACTIVE',
    listed_at        DATETIME,
    updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (channel_id) REFERENCES channels(channel_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id)  REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY uq_channel_product (channel_id, product_id),
    INDEX idx_cp_external (channel_sku_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Webhook event log (ERD: webhook_logs)
CREATE TABLE IF NOT EXISTS webhook_logs (
    log_id      INT AUTO_INCREMENT PRIMARY KEY,
    channel_id  INT,
    event_type  VARCHAR(50) NOT NULL,
    payload     TEXT,
    status      ENUM('SUCCESS','FAILED','PENDING') NOT NULL DEFAULT 'PENDING',
    error_trace TEXT,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (channel_id) REFERENCES channels(channel_id) ON DELETE SET NULL,
    INDEX idx_wl_event (event_type),
    INDEX idx_wl_status (status),
    INDEX idx_wl_channel (channel_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Lazada sync log
CREATE TABLE IF NOT EXISTS lazada_sync_log (
    log_id         INT AUTO_INCREMENT PRIMARY KEY,
    channel_id     INT,
    sync_type      VARCHAR(50),
    status         ENUM('SUCCESS','FAILED') NOT NULL,
    request_data   TEXT,
    response_data  TEXT,
    error_msg      TEXT,
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (channel_id) REFERENCES channels(channel_id) ON DELETE SET NULL,
    INDEX idx_lsl_status (status),
    INDEX idx_lsl_channel (channel_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── NHOM 5: Inventory ───────────────────────────────────

CREATE TABLE IF NOT EXISTS inventory (
    inventory_id   INT AUTO_INCREMENT PRIMARY KEY,
    product_id     INT NOT NULL,
    warehouse_id   INT NOT NULL,
    qty_on_hand   DECIMAL(12,3) NOT NULL DEFAULT 0,
    holding        DECIMAL(12,3) NOT NULL DEFAULT 0,
    qty_available  DECIMAL(12,3) NOT NULL DEFAULT 0,
    reorder_point  DECIMAL(12,3) DEFAULT NULL,
    updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_product_warehouse (product_id, warehouse_id),
    FOREIGN KEY (product_id)   REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id) ON DELETE CASCADE,
    INDEX idx_inv_product (product_id),
    INDEX idx_inv_warehouse (warehouse_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS inventory_ledger (
    ledger_id        INT AUTO_INCREMENT PRIMARY KEY,
    inventory_id     INT NOT NULL,
    product_id       INT NOT NULL,
    warehouse_id     INT NOT NULL,
    transaction_type ENUM('INBOUND','OUTBOUND','ADJUSTMENT','TRANSFER_IN','TRANSFER_OUT') NOT NULL,
    ref_document_id  INT,
    qty_change       DECIMAL(12,3) NOT NULL,
    avail_change     DECIMAL(12,3) NOT NULL,
    timestamp        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by       INT,
    note             TEXT,
    FOREIGN KEY (inventory_id)  REFERENCES inventory(inventory_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id)    REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id)  REFERENCES warehouses(warehouse_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by)    REFERENCES users(user_id),
    INDEX idx_ledger_inventory (inventory_id),
    INDEX idx_ledger_product (product_id),
    INDEX idx_ledger_type (transaction_type),
    INDEX idx_ledger_timestamp (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── NHOM 6: Orders ─────────────────────────────────────

CREATE TABLE IF NOT EXISTS orders (
    order_id           INT AUTO_INCREMENT PRIMARY KEY,
    channel_id         INT,
    channel_order_id   VARCHAR(100),
    warehouse_id       INT NOT NULL,
    order_status       ENUM('PENDING','CONFIRMED','PICKING','PACKED','SHIPPED','DELIVERED','CANCELLED','RETURNED')
                       NOT NULL DEFAULT 'PENDING',
    total_actual_paid  DECIMAL(15,2) NOT NULL DEFAULT 0,
    fee_breakdown_json TEXT,
    sync_status        ENUM('PENDING','SYNCED','FAILED') DEFAULT 'PENDING',
    created_by         INT,
    customer_id        INT,
    created_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (channel_id)   REFERENCES channels(channel_id) ON DELETE SET NULL,
    FOREIGN KEY (warehouse_id)  REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (created_by)    REFERENCES users(user_id),
    FOREIGN KEY (customer_id)   REFERENCES users(user_id),
    INDEX idx_orders_status (order_status),
    INDEX idx_orders_channel (channel_id),
    INDEX idx_orders_channel_oid (channel_order_id),
    INDEX idx_orders_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id      INT AUTO_INCREMENT PRIMARY KEY,
    order_id           INT NOT NULL,
    product_id         INT NOT NULL,
    quantity           DECIMAL(12,3) NOT NULL DEFAULT 1,
    unit_price        DECIMAL(15,2) NOT NULL DEFAULT 0,
    seller_discount    DECIMAL(15,2) DEFAULT 0,
    platform_discount  DECIMAL(15,2) DEFAULT 0,
    item_shipping_fee  DECIMAL(15,2) DEFAULT 0,
    actual_price       DECIMAL(15,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (order_id)  REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_oi_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Order shipping details (ERD: order_shipping_details)
CREATE TABLE IF NOT EXISTS order_shipping_details (
    shipping_id      INT AUTO_INCREMENT PRIMARY KEY,
    order_id         INT NOT NULL UNIQUE,
    recipient_name   VARCHAR(100) NOT NULL,
    shipping_address TEXT NOT NULL,
    courier_name     VARCHAR(50),
    waybill_code     VARCHAR(100),
    shipping_status  ENUM('PENDING','PICKED_UP','IN_TRANSIT','OUT_FOR_DELIVERY','DELIVERED','RETURNED')
                     NOT NULL DEFAULT 'PENDING',
    created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Shipping labels
CREATE TABLE IF NOT EXISTS shipping_labels (
    label_id     INT AUTO_INCREMENT PRIMARY KEY,
    order_id     INT NOT NULL,
    outbound_id  INT,
    carrier      VARCHAR(50),
    tracking_no  VARCHAR(100),
    label_url    VARCHAR(255),
    printed      TINYINT(1) DEFAULT 0,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id)  REFERENCES orders(order_id) ON DELETE CASCADE,
    INDEX idx_sl_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── NHOM 7: Inbound / Warehouse Receipts ────────────────

CREATE TABLE IF NOT EXISTS warehouse_receipts (
    receipt_id    INT AUTO_INCREMENT PRIMARY KEY,
    receipt_code  VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id  INT NOT NULL,
    receipt_type  ENUM('PURCHASE','RETURN','TRANSFER') NOT NULL DEFAULT 'PURCHASE',
    supplier_name VARCHAR(255),
    created_by    INT NOT NULL,
    copied_from_id INT,
    status        ENUM('DRAFT','APPROVED','CANCELLED') NOT NULL DEFAULT 'DRAFT',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (warehouse_id)  REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (created_by)     REFERENCES users(user_id),
    FOREIGN KEY (copied_from_id) REFERENCES warehouse_receipts(receipt_id) ON DELETE SET NULL,
    INDEX idx_wr_status (status),
    INDEX idx_wr_warehouse (warehouse_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS receipt_details (
    detail_id   INT AUTO_INCREMENT PRIMARY KEY,
    receipt_id  INT NOT NULL,
    product_id  INT NOT NULL,
    quantity    DECIMAL(12,3) NOT NULL,
    unit_cost   DECIMAL(15,2) DEFAULT NULL,
    note        VARCHAR(255),
    FOREIGN KEY (receipt_id) REFERENCES warehouse_receipts(receipt_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_rd_receipt (receipt_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Legacy alias (for existing code compatibility)
CREATE TABLE IF NOT EXISTS inbound_orders (
    inbound_id   INT AUTO_INCREMENT PRIMARY KEY,
    inbound_code VARCHAR(30) NOT NULL UNIQUE,
    warehouse_id INT NOT NULL,
    supplier     VARCHAR(100),
    status       ENUM('PENDING','IN_PROGRESS','RECEIVED','CANCELLED') NOT NULL DEFAULT 'PENDING',
    received_by  INT,
    note         TEXT,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    received_at  DATETIME,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (received_by)  REFERENCES users(user_id),
    INDEX idx_inbound_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS inbound_items (
    inbound_item_id INT AUTO_INCREMENT PRIMARY KEY,
    inbound_id      INT NOT NULL,
    product_id      INT NOT NULL,
    expected_qty    DECIMAL(12,3) NOT NULL DEFAULT 0,
    received_qty    DECIMAL(12,3) NOT NULL DEFAULT 0,
    FOREIGN KEY (inbound_id) REFERENCES inbound_orders(inbound_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id)  REFERENCES products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS receipt_notes (
    receipt_id   INT AUTO_INCREMENT PRIMARY KEY,
    inbound_id   INT NOT NULL,
    warehouse_id INT NOT NULL,
    received_by  INT,
    note         TEXT,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (inbound_id)  REFERENCES inbound_orders(inbound_id) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (received_by) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── NHOM 8: Outbound / Warehouse Issues ─────────────────

CREATE TABLE IF NOT EXISTS warehouse_issues (
    issue_id       INT AUTO_INCREMENT PRIMARY KEY,
    issue_code     VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id   INT NOT NULL,
    issue_type     ENUM('ORDER','SCRAP','TRANSFER') NOT NULL,
    ref_order_id   INT,
    transfer_id    INT,
    dest_zone_id   INT,
    created_by     INT NOT NULL,
    copied_from_id INT,
    status         ENUM('DRAFT','APPROVED','CANCELLED') NOT NULL DEFAULT 'DRAFT',
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (warehouse_id)   REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (created_by)     REFERENCES users(user_id),
    FOREIGN KEY (copied_from_id) REFERENCES warehouse_issues(issue_id) ON DELETE SET NULL,
    INDEX idx_wi_status (status),
    INDEX idx_wi_type (issue_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS issue_details (
    detail_id   INT AUTO_INCREMENT PRIMARY KEY,
    issue_id    INT NOT NULL,
    product_id  INT NOT NULL,
    quantity    DECIMAL(12,3) NOT NULL,
    note        VARCHAR(255),
    FOREIGN KEY (issue_id)   REFERENCES warehouse_issues(issue_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_id_issue (issue_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Legacy alias (for existing code compatibility)
CREATE TABLE IF NOT EXISTS outbound_orders (
    outbound_id   INT AUTO_INCREMENT PRIMARY KEY,
    order_id      INT NOT NULL,
    warehouse_id   INT NOT NULL,
    status        ENUM('PENDING','PICKING','PACKED','SHIPPED','DELIVERED','CANCELLED')
                  NOT NULL DEFAULT 'PENDING',
    picked_by     INT,
    shipped_at    DATETIME,
    note          TEXT,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id)    REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (picked_by)   REFERENCES users(user_id),
    INDEX idx_out_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS outbound_items (
    outbound_item_id INT AUTO_INCREMENT PRIMARY KEY,
    outbound_id      INT NOT NULL,
    product_id       INT NOT NULL,
    qty              DECIMAL(12,3) NOT NULL DEFAULT 1,
    picked_qty       DECIMAL(12,3) NOT NULL DEFAULT 0,
    FOREIGN KEY (outbound_id) REFERENCES outbound_orders(outbound_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id)  REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_oi_outbound (outbound_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS picking_sheets (
    sheet_id      INT AUTO_INCREMENT PRIMARY KEY,
    outbound_id   INT NOT NULL,
    picker_id     INT,
    status        ENUM('PENDING','IN_PROGRESS','COMPLETED') DEFAULT 'PENDING',
    started_at   DATETIME,
    completed_at DATETIME,
    FOREIGN KEY (outbound_id) REFERENCES outbound_orders(outbound_id),
    FOREIGN KEY (picker_id)   REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS delivery_notes (
    delivery_id     INT AUTO_INCREMENT PRIMARY KEY,
    outbound_id     INT NOT NULL,
    delivered_by    INT,
    delivery_date   DATETIME,
    recipient_name  VARCHAR(100),
    recipient_note  TEXT,
    FOREIGN KEY (outbound_id)  REFERENCES outbound_orders(outbound_id),
    FOREIGN KEY (delivered_by) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── NHOM 9: RMA / Returns ─────────────────────────────

CREATE TABLE IF NOT EXISTS rma_requests (
    rma_id            INT AUTO_INCREMENT PRIMARY KEY,
    order_id          INT NOT NULL,
    channel_return_id VARCHAR(100),
    return_waybill    VARCHAR(100),
    rma_code          VARCHAR(50) NOT NULL UNIQUE,
    status            ENUM('PENDING','APPROVED','DISPUTED','RESOLVED') NOT NULL DEFAULT 'PENDING',
    return_reason     VARCHAR(255) NOT NULL,
    zone_id           INT,
    requested_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    returned_at       DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (zone_id)   REFERENCES zones(zone_id) ON DELETE SET NULL,
    INDEX idx_rma_status (status),
    INDEX idx_rma_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS rma_items (
    rma_item_id            INT AUTO_INCREMENT PRIMARY KEY,
    rma_id                 INT NOT NULL,
    product_id             INT NOT NULL,
    channel_return_item_id VARCHAR(100),
    quantity               DECIMAL(12,3) NOT NULL DEFAULT 1,
    refund_amount          DECIMAL(15,2),
    FOREIGN KEY (rma_id)    REFERENCES rma_requests(rma_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_rmai_rma (rma_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS qc_inspections (
    qc_id             INT AUTO_INCREMENT PRIMARY KEY,
    rma_item_id       INT NOT NULL,
    inspected_by      INT NOT NULL,
    good_quantity     DECIMAL(12,3) NOT NULL DEFAULT 0,
    good_zone_id      INT,
    damaged_quantity  DECIMAL(12,3) NOT NULL DEFAULT 0,
    damaged_zone_id   INT,
    notes             TEXT,
    inspected_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rma_item_id)  REFERENCES rma_items(rma_item_id) ON DELETE CASCADE,
    FOREIGN KEY (inspected_by) REFERENCES users(user_id),
    FOREIGN KEY (good_zone_id)  REFERENCES zones(zone_id) ON DELETE SET NULL,
    FOREIGN KEY (damaged_zone_id) REFERENCES zones(zone_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Legacy alias (for existing code compatibility)
CREATE TABLE IF NOT EXISTS return_orders (
    return_id     INT AUTO_INCREMENT PRIMARY KEY,
    order_id       INT,
    outbound_id   INT,
    customer_name  VARCHAR(100),
    reason         VARCHAR(255),
    status         ENUM('RECEIVED','INSPECTING','PASS','FAIL','RESTOCKED','SCRAPPED') DEFAULT 'RECEIVED',
    warehouse_id   INT NOT NULL,
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id)    REFERENCES orders(order_id) ON DELETE SET NULL,
    FOREIGN KEY (outbound_id) REFERENCES outbound_orders(outbound_id) ON DELETE SET NULL,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    INDEX idx_ro_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS qc_records (
    qc_id       INT AUTO_INCREMENT PRIMARY KEY,
    return_id   INT NOT NULL,
    product_id  INT,
    decision    ENUM('PASS','FAIL') NOT NULL,
    qc_notes    TEXT,
    qc_by       INT,
    qc_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (return_id) REFERENCES return_orders(return_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE SET NULL,
    FOREIGN KEY (qc_by)      REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS scrap_records (
    scrap_id    INT AUTO_INCREMENT PRIMARY KEY,
    return_id   INT NOT NULL,
    product_id  INT,
    qty         DECIMAL(12,3) NOT NULL DEFAULT 1,
    reason      VARCHAR(255),
    scrap_by    INT,
    scrap_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (return_id) REFERENCES return_orders(return_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE SET NULL,
    FOREIGN KEY (scrap_by)   REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── NHOM 10: Stocktakes ────────────────────────────────

CREATE TABLE IF NOT EXISTS physical_inventories (
    inventory_check_id INT AUTO_INCREMENT PRIMARY KEY,
    check_code         VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id       INT NOT NULL,
    created_by         INT NOT NULL,
    status             ENUM('DRAFT','IN_PROGRESS','APPROVED') NOT NULL DEFAULT 'DRAFT',
    created_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (created_by)   REFERENCES users(user_id),
    INDEX idx_pi_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS physical_inventory_details (
    check_detail_id    INT AUTO_INCREMENT PRIMARY KEY,
    inventory_check_id INT NOT NULL,
    product_id         INT NOT NULL,
    system_qty         DECIMAL(12,3) NOT NULL DEFAULT 0,
    actual_qty         DECIMAL(12,3) DEFAULT NULL,
    delta_qty          DECIMAL(12,3) DEFAULT NULL,
    counted_by         INT,
    counted_at         DATETIME,
    FOREIGN KEY (inventory_check_id) REFERENCES physical_inventories(inventory_check_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id)        REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (counted_by)        REFERENCES users(user_id),
    INDEX idx_pid_check (inventory_check_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Legacy aliases (for existing code compatibility)
CREATE TABLE IF NOT EXISTS stocktakes (
    stocktake_id    INT AUTO_INCREMENT PRIMARY KEY,
    stocktake_code  VARCHAR(30) NOT NULL UNIQUE,
    warehouse_id     INT NOT NULL,
    status          ENUM('PLANNED','IN_PROGRESS','COMPLETED','CANCELLED') DEFAULT 'PLANNED',
    counted_by      INT,
    approved_by     INT,
    note            TEXT,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at    DATETIME,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (counted_by)  REFERENCES users(user_id),
    FOREIGN KEY (approved_by) REFERENCES users(user_id),
    INDEX idx_st_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS stocktake_items (
    item_id      INT AUTO_INCREMENT PRIMARY KEY,
    stocktake_id INT NOT NULL,
    product_id   INT NOT NULL,
    system_qty   INT NOT NULL DEFAULT 0,
    counted_qty INT DEFAULT NULL,
    variance     INT DEFAULT NULL,
    counted_by   INT,
    counted_at   DATETIME,
    FOREIGN KEY (stocktake_id) REFERENCES stocktakes(stocktake_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id)   REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (counted_by)   REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── NHOM 11: Stock Transfers ──────────────────────────

CREATE TABLE IF NOT EXISTS stock_transfers (
    transfer_id      INT AUTO_INCREMENT PRIMARY KEY,
    transfer_code    VARCHAR(50) NOT NULL UNIQUE,
    from_warehouse_id INT NOT NULL,
    to_warehouse_id   INT NOT NULL,
    created_by       INT NOT NULL,
    approved_by      INT,
    status           ENUM('DRAFT','IN_TRANSIT','RECEIVED','CANCELLED') NOT NULL DEFAULT 'DRAFT',
    note             TEXT,
    created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at     DATETIME,
    FOREIGN KEY (from_warehouse_id) REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (to_warehouse_id)   REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (created_by)       REFERENCES users(user_id),
    FOREIGN KEY (approved_by)      REFERENCES users(user_id),
    INDEX idx_st_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS stock_transfer_items (
    transfer_item_id INT AUTO_INCREMENT PRIMARY KEY,
    transfer_id      INT NOT NULL,
    product_id       INT NOT NULL,
    shipped_qty      DECIMAL(12,3) NOT NULL,
    received_qty     DECIMAL(12,3) DEFAULT NULL,
    FOREIGN KEY (transfer_id) REFERENCES stock_transfers(transfer_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id)  REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_sti_transfer (transfer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Legacy alias (for existing code compatibility)
CREATE TABLE IF NOT EXISTS transfer_details (
    transfer_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    transfer_id       INT NOT NULL,
    product_id       INT NOT NULL,
    qty              INT NOT NULL,
    FOREIGN KEY (transfer_id) REFERENCES stock_transfers(transfer_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id)  REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_td_transfer (transfer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── Seed Data ────────────────────────────────────────────

INSERT IGNORE INTO warehouses (warehouse_code, warehouse_name, address)
VALUES ('WH-01', 'Kho Ha Noi', 'So 1 Duong ABC, Ha Noi');

-- Default zones for warehouse 1
INSERT IGNORE INTO zones (warehouse_id, zone_code, zone_name, zone_type, description) VALUES
    (1, 'NORMAL', 'Khu Thuong', 'NORMAL', 'Khu vuc luu tru hang tot'),
    (1, 'RETURN', 'Khu Tra Hang', 'RETURN', 'Khu vuc tam giu hang tra'),
    (1, 'DAMAGED', 'Khu Hong', 'DAMAGED', 'Khu vuc hang hong'),
    (1, 'DESTROY', 'Khu Tieu Huy', 'DESTROY', 'Khu vuc tieu huy hang loi');

-- Default admin user: quanpm / Admin@123 (BCrypt hash)
INSERT IGNORE INTO users (username, password_hash, full_name, email, phone, role)
VALUES ('quanpm',
        '$2a$12$ezv1v4fjwnwMSYQ4DvPHN./NuNfVdwEzGbHuUvlbsabeCZqrLkzxe',
        'Phạm Minh Quân', 'pmq07072005@gmail.com', '0987654321', 'ADMIN');

-- Assign admin to warehouse 1
INSERT IGNORE INTO user_warehouse_assignments (user_id, warehouse_id, is_primary)
SELECT user_id, 1, 1 FROM users WHERE username = 'quanpm';

-- Default categories
INSERT IGNORE INTO categories (category_name, level_depth) VALUES
    ('Thuc Pham', 0),
    ('Do Gia Dung', 0),
    ('Dien Tu', 0),
    ('My Pham', 0),
    ('Sach', 0);
