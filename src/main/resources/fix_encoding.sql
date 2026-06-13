-- ============================================================
-- FIX ENCODING: Xóa dữ liệu bị encoding sai và re-seed
-- Chạy script này để fix lỗi tiếng Việt bị hiển thị thành "Kho HÃ  Ná»™i"
-- ============================================================

-- Disable foreign key checks temporarily
SET FOREIGN_KEY_CHECKS = 0;

-- Xóa dữ liệu bị corrupted
TRUNCATE TABLE fulfillment_request_items;
TRUNCATE TABLE fulfillment_requests;
TRUNCATE TABLE return_items;
TRUNCATE TABLE qc_records;
TRUNCATE TABLE return_orders;
TRUNCATE TABLE outbound_items;
TRUNCATE TABLE outbound_orders;
TRUNCATE TABLE physical_inventory_details;
TRUNCATE TABLE physical_inventories;
TRUNCATE TABLE stocktake_items;
TRUNCATE TABLE stocktakes;
TRUNCATE TABLE inventory_ledger;
TRUNCATE TABLE inventory;
TRUNCATE TABLE stock_transfer_items;
TRUNCATE TABLE stock_transfers;
TRUNCATE TABLE transfer_details;
TRUNCATE TABLE issue_details;
TRUNCATE TABLE warehouse_issues;
TRUNCATE TABLE receipt_details;
TRUNCATE TABLE warehouse_receipts;
TRUNCATE TABLE receipt_notes;
TRUNCATE TABLE inbound_items;
TRUNCATE TABLE inbound_orders;
TRUNCATE TABLE shipping_labels;
TRUNCATE TABLE order_shipping_details;
TRUNCATE TABLE order_items;
TRUNCATE TABLE orders;
TRUNCATE TABLE sku_mappings;
TRUNCATE TABLE channel_products;
TRUNCATE TABLE webhook_logs;
TRUNCATE TABLE lazada_sync_log;
TRUNCATE TABLE product_images;
TRUNCATE TABLE product_default_zones;
TRUNCATE TABLE rma_items;
TRUNCATE TABLE rma_requests;
TRUNCATE TABLE qc_inspections;
TRUNCATE TABLE scrap_records;
TRUNCATE TABLE skus;
TRUNCATE TABLE products;
TRUNCATE TABLE categories;
TRUNCATE TABLE zones;
TRUNCATE TABLE user_warehouse_assignments;
TRUNCATE TABLE users;
TRUNCATE TABLE roles;
TRUNCATE TABLE channels;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Insert lại dữ liệu sạch với encoding đúng (UTF-8)
-- 1. ROLES
INSERT INTO roles (role_name, description) VALUES
    ('ADMIN', 'Quản trị hệ thống'),
    ('MANAGER', 'Quản lý kinh doanh'),
    ('SALES_STAFF', 'Nhân viên bán hàng'),
    ('WAREHOUSE_STAFF', 'Nhân viên kho');

-- 2. USERS
INSERT INTO users (user_id, username, password_hash, full_name, email, phone, otp_preference, role, warehouse_id, active) VALUES
(1, 'quanpm', '$2a$12$ezv1v4fjwnwMSYQ4DvPHN./NuNfVdwEzGbHuUvlbsabeCZqrLkzxe', 'Phạm Minh Quân', 'pmq07072005@gmail.com', '0987654321', 'EMAIL', 'ADMIN', 1, 1);

-- 3. WAREHOUSES
INSERT INTO warehouses (warehouse_id, warehouse_code, warehouse_name, address, active, capacity, phone) VALUES
(1, 'WH-01', 'Kho Hà Nội', 'Số 1 Đường ABC, Phường Cầu Giấy, Quận Cầu Giấy, Hà Nội', 1, 10000, '02412345678'),
(2, 'WH-02', 'Kho TP. Hồ Chí Minh', 'Số 120 Đường XYZ, Phường Bến Nghé, Quận 1, TP. HCM', 1, 8000, '02812345678');

-- 4. USER WAREHOUSE ASSIGNMENTS
INSERT INTO user_warehouse_assignments (user_id, warehouse_id, is_primary) VALUES
(1, 1, 1), (1, 2, 1);

-- 5. ZONES
INSERT INTO zones (zone_id, warehouse_id, zone_code, zone_name, zone_type, description, active, is_default) VALUES
(1, 1, 'WH01-NORMAL', 'Khu Thường WH01', 'NORMAL', 'Khu vực lưu trữ hàng tốt WH01', 1, 1),
(2, 1, 'WH01-RETURN', 'Khu Trả Hàng WH01', 'RETURN', 'Khu vực tạm giữ hàng trả WH01', 1, 0),
(3, 1, 'WH01-DAMAGED', 'Khu Hỏng WH01', 'DAMAGED', 'Khu vực hàng hỏng WH01', 1, 0),
(4, 1, 'WH01-DESTROY', 'Khu Tiêu Hủy WH01', 'DESTROY', 'Khu vực tiêu hủy WH01', 1, 0),
(5, 2, 'WH02-NORMAL', 'Khu Thường WH02', 'NORMAL', 'Khu vực lưu trữ hàng tốt WH02', 1, 1),
(6, 2, 'WH02-RETURN', 'Khu Trả Hàng WH02', 'RETURN', 'Khu vực tạm giữ hàng trả WH02', 1, 0),
(7, 2, 'WH02-DAMAGED', 'Khu Hỏng WH02', 'DAMAGED', 'Khu vực hàng hỏng WH02', 1, 0),
(8, 2, 'WH02-DESTROY', 'Khu Tiêu Hủy WH02', 'DESTROY', 'Khu vực tiêu hủy WH02', 1, 0);

-- 6. CATEGORIES
INSERT INTO categories (category_id, category_code, category_name, level_depth, active) VALUES
(1, 'TT', 'Thời trang', 0, 1),
(2, 'DT', 'Điện tử', 0, 1),
(3, 'GD', 'Gia dụng', 0, 1),
(4, 'MP', 'Mỹ phẩm', 0, 1);

-- 7. PRODUCTS
INSERT INTO products (product_id, category_id, sku_code, product_name, base_price, unit, min_stock, max_stock, status, active, created_by) VALUES
(1, 1, 'TSH-NAM-001', 'Áo Thun Nam Cotton Organic Coolmate', 189000.00, 'Cái', 20.000, 500.000, 'APPROVED', 1, 1),
(2, 1, 'JEAN-SLIM-002', 'Quần Jeans Nam Slim Fit Co Giãn', 399000.00, 'Cái', 15.000, 300.000, 'APPROVED', 1, 1),
(3, 1, 'SUN-CLASS-003', 'Kính Râm Nam Polarized Chống UV', 299000.00, 'Cái', 10.000, 200.000, 'APPROVED', 1, 1),
(4, 2, 'MOU-WIRE-004', 'Chuột Không Dây Logitech Pebble M350', 550000.00, 'Cái', 5.000, 100.000, 'APPROVED', 1, 1),
(5, 2, 'KEY-MECH-005', 'Bàn Phím Cơ Không Dây Logitech Signature K650', 1250000.00, 'Cái', 5.000, 100.000, 'APPROVED', 1, 1),
(6, 3, 'BOT-THER-006', 'Bình Giữ Nhiệt LocknLock 480ml', 320000.00, 'Cái', 10.000, 150.000, 'APPROVED', 1, 1),
(7, 4, 'SUN-SCRE-007', 'Kem Chống Nắng La Roche-Posay 50ml', 480000.00, 'Hộp', 15.000, 250.000, 'APPROVED', 1, 1);

-- 8. SKUs
INSERT INTO skus (sku_id, sku_code, product_name, category, unit, min_stock, active) VALUES
(1, 'TSH-NAM-001', 'Áo Thun Nam Cotton Organic Coolmate', 'Thời trang', 'Cái', 20, 1),
(2, 'JEAN-SLIM-002', 'Quần Jeans Nam Slim Fit Co Giãn', 'Thời trang', 'Cái', 15, 1),
(3, 'SUN-CLASS-003', 'Kính Râm Nam Polarized Chống UV', 'Thời trang', 'Cái', 10, 1),
(4, 'MOU-WIRE-004', 'Chuột Không Dây Logitech Pebble M350', 'Điện tử', 'Cái', 5, 1),
(5, 'KEY-MECH-005', 'Bàn Phím Cơ Không Dây Logitech Signature K650', 'Điện tử', 'Cái', 5, 1),
(6, 'BOT-THER-006', 'Bình Giữ Nhiệt LocknLock 480ml', 'Gia dụng', 'Cái', 10, 1),
(7, 'SUN-SCRE-007', 'Kem Chống Nắng La Roche-Posay 50ml', 'Mỹ phẩm', 'Hộp', 15, 1);

-- 9. PRODUCT DEFAULT ZONES
INSERT INTO product_default_zones (product_id, warehouse_id, zone_id) VALUES
(1, 1, 1), (2, 1, 1), (3, 1, 1), (4, 1, 1), (5, 1, 1), (6, 1, 1), (7, 1, 1),
(1, 2, 5), (2, 2, 5), (3, 2, 5), (4, 2, 5), (5, 2, 5), (6, 2, 5), (7, 2, 5);

-- 10. INVENTORY
INSERT INTO inventory (product_id, warehouse_id, qty_on_hand, holding, qty_available) VALUES
(1, 1, 300.000, 0.000, 300.000),
(2, 1, 150.000, 0.000, 150.000),
(4, 1, 50.000, 0.000, 50.000),
(5, 1, 25.000, 0.000, 25.000),
(1, 2, 0.000, 0.000, 0.000),
(2, 2, 0.000, 0.000, 0.000);

-- ============================================================
-- FIX ENCODING COMPLETED
-- Bây giờ restart Tomcat để reload dữ liệu
-- ============================================================
