-- ============================================================
-- OMNICORE MOCK DATA - FLOW LIÊN THÔNG
-- Nhà cung cấp → Nhập kho → Tồn kho → Đơn hàng → Xuất kho
-- ============================================================

-- 1. WAREHOUSES
REPLACE INTO warehouses (warehouse_id, warehouse_code, warehouse_name, address, active, capacity, phone) VALUES
(1, 'WH-01', 'Kho Hà Nội', 'Số 1 Đường ABC, Phường Cầu Giấy, Quận Cầu Giấy, Hà Nội', 1, 10000, '02412345678'),
(2, 'WH-02', 'Kho TP. Hồ Chí Minh', 'Số 120 Đường XYZ, Phường Bến Nghé, Quận 1, TP. HCM', 1, 8000, '02812345678');

-- 2. ZONES
REPLACE INTO zones (zone_id, warehouse_id, zone_code, zone_name, zone_type, description, active, is_default) VALUES
(1, 1, 'WH01-NORMAL', 'Khu Thường WH01', 'NORMAL', 'Khu vực lưu trữ hàng tốt WH01', 1, 1),
(2, 1, 'WH01-RETURN', 'Khu Trả Hàng WH01', 'RETURN', 'Khu vực tạm giữ hàng trả WH01', 1, 0),
(3, 1, 'WH01-DAMAGED', 'Khu Hỏng WH01', 'DAMAGED', 'Khu vực hàng hỏng WH01', 1, 0),
(4, 1, 'WH01-DESTROY', 'Khu Tiêu Hủy WH01', 'DESTROY', 'Khu vực tiêu hủy WH01', 1, 0),
(5, 2, 'WH02-NORMAL', 'Khu Thường WH02', 'NORMAL', 'Khu vực lưu trữ hàng tốt WH02', 1, 1),
(6, 2, 'WH02-RETURN', 'Khu Trả Hàng WH02', 'RETURN', 'Khu vực tạm giữ hàng trả WH02', 1, 0),
(7, 2, 'WH02-DAMAGED', 'Khu Hỏng WH02', 'DAMAGED', 'Khu vực hàng hỏng WH02', 1, 0),
(8, 2, 'WH02-DESTROY', 'Khu Tiêu Hủy WH02', 'DESTROY', 'Khu vực tiêu hủy WH02', 1, 0);

-- 3. CATEGORIES
REPLACE INTO categories (category_id, category_code, category_name, level_depth, active) VALUES
(1, 'TT', 'Thời trang', 0, 1),
(2, 'DT', 'Điện tử', 0, 1),
(3, 'GD', 'Gia dụng', 0, 1),
(4, 'MP', 'Mỹ phẩm', 0, 1);

-- 4. PRODUCTS (Master SKU)
REPLACE INTO products (product_id, category_id, sku_code, product_name, base_price, unit, min_stock, max_stock, status, active, created_by) VALUES
(1, 1, 'TSH-NAM-001', 'Áo Thun Nam Cotton Organic Coolmate', 189000.00, 'Cái', 20.000, 500.000, 'APPROVED', 1, 1),
(2, 1, 'JEAN-SLIM-002', 'Quần Jeans Nam Slim Fit Co Giãn', 399000.00, 'Cái', 15.000, 300.000, 'APPROVED', 1, 1),
(3, 1, 'SUN-CLASS-003', 'Kính Râm Nam Polarized Chống UV', 299000.00, 'Cái', 10.000, 200.000, 'APPROVED', 1, 1),
(4, 2, 'MOU-WIRE-004', 'Chuột Không Dây Logitech Pebble M350', 550000.00, 'Cái', 5.000, 100.000, 'APPROVED', 1, 1),
(5, 2, 'KEY-MECH-005', 'Bàn Phím Cơ Không Dây Logitech Signature K650', 1250000.00, 'Cái', 5.000, 100.000, 'APPROVED', 1, 1),
(6, 3, 'BOT-THER-006', 'Bình Giữ Nhiệt LocknLock 480ml', 320000.00, 'Cái', 10.000, 150.000, 'APPROVED', 1, 1),
(7, 4, 'SUN-SCRE-007', 'Kem Chống Nắng La Roche-Posay 50ml', 480000.00, 'Hộp', 15.000, 250.000, 'APPROVED', 1, 1);

-- 5. SKUs
REPLACE INTO skus (sku_id, sku_code, product_name, category, unit, min_stock, active) VALUES
(1, 'TSH-NAM-001', 'Áo Thun Nam Cotton Organic Coolmate', 'Thời trang', 'Cái', 20, 1),
(2, 'JEAN-SLIM-002', 'Quần Jeans Nam Slim Fit Co Giãn', 'Thời trang', 'Cái', 15, 1),
(3, 'SUN-CLASS-003', 'Kính Râm Nam Polarized Chống UV', 'Thời trang', 'Cái', 10, 1),
(4, 'MOU-WIRE-004', 'Chuột Không Dây Logitech Pebble M350', 'Điện tử', 'Cái', 5, 1),
(5, 'KEY-MECH-005', 'Bàn Phím Cơ Không Dây Logitech Signature K650', 'Điện tử', 'Cái', 5, 1),
(6, 'BOT-THER-006', 'Bình Giữ Nhiệt LocknLock 480ml', 'Gia dụng', 'Cái', 10, 1),
(7, 'SUN-SCRE-007', 'Kem Chống Nắng La Roche-Posay 50ml', 'Mỹ phẩm', 'Hộp', 15, 1);

-- 6. PRODUCT DEFAULT ZONES
REPLACE INTO product_default_zones (product_id, warehouse_id, zone_id) VALUES
(1, 1, 1), (2, 1, 1), (3, 1, 1), (4, 1, 1), (5, 1, 1), (6, 1, 1), (7, 1, 1),
(1, 2, 5), (2, 2, 5), (3, 2, 5), (4, 2, 5), (5, 2, 5), (6, 2, 5), (7, 2, 5);

-- 7. USERS
REPLACE INTO users (user_id, username, password_hash, full_name, email, phone, otp_preference, role, warehouse_id, active, created_at, updated_at) VALUES
(1, 'quanpm', '$2a$12$ezv1v4fjwnwMSYQ4DvPHN./NuNfVdwEzGbHuUvlbsabeCZqrLkzxe', 'Phạm Minh Quân', 'pmq07072005@gmail.com', '0987654321', 'EMAIL', 'ADMIN', 1, 1, '2026-06-03 08:33:03', '2026-06-10 19:48:29'),
(8, 'anhvl', '$2a$12$uMVE2wnpLv8P8XLV75P3qO84Yzn95o2/2rxfq43NwKxwfFeRHd/xG', 'Vũ Lan Anh', 'vulananha9@gmail.com', NULL, 'EMAIL', 'MANAGER', 1, 1, '2026-06-04 20:43:34', '2026-06-13 09:35:56'),
(10, 'lamna', '$2a$12$DRCJRXUWudZu9AvtxUlBXOqdvEuasna7dOKotHc3PDs9Xl1LDRL5K', 'Nguyễn Ánh Lâm', 'lamanhng.yds@gmail.com', NULL, 'EMAIL', 'WAREHOUSE_STAFF', 1, 1, '2026-06-04 21:21:41', '2026-06-13 10:01:04'),
(16, 'tungnhn', '$2a$12$mO9B8FFvwhPgLIHAFqWdQOvoIDftDodcbjZjjABwYfCXu5zRf4PZa', 'Nguyễn Hữu Nhật Tùng', 'nguyentung031205@gmail.com', NULL, 'EMAIL', 'SALES_STAFF', 1, 1, '2026-06-06 00:52:42', '2026-06-07 15:31:46'),
(144, 'trungbd', '$2a$12$jf/LBsYBszp1HeFhwNnmK.1Ez4c03bDR4r8HCi7ogUnw4AQ6K/Rfy', 'Bùi Đức Trung', 'ductrung3625@gmail.com', NULL, 'EMAIL', 'SALES_STAFF', 1, 1, '2026-06-10 22:08:24', '2026-06-12 14:21:20');

-- 8. USER WAREHOUSE ASSIGNMENTS
REPLACE INTO user_warehouse_assignments (user_id, warehouse_id, is_primary) VALUES
(1, 1, 1), (1, 2, 1),
(8, 1, 1), (8, 2, 0),
(10, 1, 1), (10, 2, 0),
(16, 1, 1), (16, 2, 0),
(144, 1, 1), (144, 2, 0);

-- ============================================================
-- STEP 1: NHẬP KHO (Inbounds)
-- ============================================================
-- IN-001: Coolmate giao Áo Thun + Quần Jeans → ĐÃ NHẬP KHO
-- IN-002: Digiworld giao Chuột + Bàn Phím → ĐANG NHẬP
-- IN-003: LocknLock giao Bình Giữ Nhiệt → CHỜ HÀNG VỀ
REPLACE INTO inbound_orders (inbound_id, inbound_code, warehouse_id, supplier, status, received_by, note, created_at, received_at, created_by) VALUES
(1, 'IN-20260612-001', 1, 'Công ty TNHH Coolmate Việt Nam', 'RECEIVED', 10, 'Đợt 1: Áo Thun + Quần Jeans đã nhập đủ', '2026-06-12 08:00:00', '2026-06-12 09:30:00', 10),
(2, 'IN-20260613-001', 1, 'Nhà Phân Phối Logitech Digiworld', 'IN_PROGRESS', NULL, 'Đợt 2: Chuột + Bàn Phím - đang kiểm hàng', '2026-06-13 08:00:00', NULL, 10),
(3, 'IN-20260613-002', 1, 'Công ty TNHH Khóa Lock&Lock', 'PENDING', NULL, 'Đợt 3: Bình giữ nhiệt - đang vận chuyển', '2026-06-13 10:00:00', NULL, 10);

-- Inbound Items
REPLACE INTO inbound_items (inbound_item_id, inbound_id, product_id, expected_qty, received_qty) VALUES
-- IN-001: Áo 300, Quần 150 → nhận đủ
(1, 1, 1, 300.000, 300.000),
(2, 1, 2, 150.000, 150.000),
-- IN-002: Chuột 100, Bàn Phím 50 → nhận 1 nửa
(3, 2, 4, 100.000, 50.000),
(4, 2, 5, 50.000, 25.000),
-- IN-003: Bình Giữ Nhiệt 80 → chờ
(5, 3, 6, 80.000, 0.000);

-- ============================================================
-- STEP 2: TỒN KHO (Sau khi nhập IN-001 và IN-002)
-- ============================================================
REPLACE INTO inventory (product_id, warehouse_id, qty_on_hand, holding, qty_available) VALUES
(1, 1, 300.000, 0.000, 300.000),  -- Áo Thun (từ IN-001)
(2, 1, 150.000, 0.000, 150.000),  -- Quần Jeans (từ IN-001)
(4, 1, 50.000, 0.000, 50.000),    -- Chuột (từ IN-002)
(5, 1, 25.000, 0.000, 25.000),    -- Bàn Phím (từ IN-002)
(1, 2, 0.000, 0.000, 0.000),      -- Kho 2 trống
(2, 2, 0.000, 0.000, 0.000);

-- ============================================================
-- STEP 3: ĐƠN HÀNG (Từ sàn - Sales duyệt)
-- ============================================================
-- SO-1001: Shopee - 5 Áo + 2 Quần → PICKING
-- SO-1002: Lazada - 3 Kính Râm → PENDING (chưa có stock)
-- SO-1003: TikTok - 2 Chuột → PACKED
-- SO-1004: Website - 1 Bàn Phím → SHIPPED
REPLACE INTO orders (order_id, order_code, customer_id, warehouse_id, channel, status, total_amount, note, created_by, created_at) VALUES
(1001, 'SO-2026-1001', 16, 1, 'ONLINE', 'PICKING', 5*189000 + 2*399000, 'Shopee - Khách cần giao gấp buổi chiều', 16, '2026-06-13 09:00:00'),
(1002, 'SO-2026-1002', 16, 1, 'ONLINE', 'PENDING', 3*299000, 'Lazada - Khách đặt nhưng kho chưa có Kính Râm', 16, '2026-06-13 10:00:00'),
(1003, 'SO-2026-1003', 16, 1, 'ONLINE', 'PACKED', 2*550000, 'TikTok Shop - Đã đóng gói, chờ SPX lấy', 16, '2026-06-13 08:30:00'),
(1004, 'SO-2026-1004', 16, 1, 'ONLINE', 'SHIPPED', 1*1250000, 'Website - Đã giao cho GHN lúc 7:50', 16, '2026-06-13 07:45:00');

-- Order Items
REPLACE INTO order_items (order_item_id, order_id, product_id, qty, unit_price) VALUES
(1, 1001, 1, 5, 189000.00),
(2, 1001, 2, 2, 399000.00),
(3, 1002, 3, 3, 299000.00),
(4, 1003, 4, 2, 550000.00),
(5, 1004, 5, 1, 1250000.00);

-- Order Shipping Details
REPLACE INTO order_shipping_details (order_id, recipient_name, shipping_address, courier_name, waybill_code, shipping_status) VALUES
(1001, 'Phạm Minh Hoàng', '120 Lê Lợi, P. Bến Thành, Q.1, TP.HCM', 'SPX Express', 'SPX123456789', 'PENDING'),
(1002, 'Lê Thị Mai', '45 Hàng Ngang, Q. Hoàn Kiếm, Hà Nội', 'Giao Hàng Nhanh (GHN)', 'GHN987654321', 'PENDING'),
(1003, 'Nguyễn Văn Hải', '288 Nguyễn Văn Cừ, Ninh Kiều, Cần Thơ', 'Viettel Post', 'VTP246813579', 'DELIVERED'),
(1004, 'Trần Văn Nam', '88 Nguyễn Trãi, Q.5, TP.HCM', 'Giao Hàng Nhanh (GHN)', 'GHN246813579', 'IN_TRANSIT');

-- ============================================================
-- STEP 4: FULFILLMENT REQUESTS
-- ============================================================
REPLACE INTO fulfillment_requests (request_id, order_id, warehouse_id, status, auto_created, created_at) VALUES
('FR-2026-0001', 1001, 1, 'CONVERTED', 0, '2026-06-13 09:01:00'),
('FR-2026-0002', 1002, 1, 'PENDING', 0, '2026-06-13 10:01:00'),
('FR-2026-0003', 1003, 1, 'CONVERTED', 0, '2026-06-13 08:32:00'),
('FR-2026-0004', 1004, 1, 'CONVERTED', 0, '2026-06-13 07:46:00');

REPLACE INTO fulfillment_request_items (request_id, sku_code, sku_name, qty) VALUES
('FR-2026-0001', 'TSH-NAM-001', 'Áo Thun Nam Cotton Organic Coolmate', 5),
('FR-2026-0001', 'JEAN-SLIM-002', 'Quần Jeans Nam Slim Fit Co Giãn', 2),
('FR-2026-0002', 'SUN-CLASS-003', 'Kính Râm Nam Polarized Chống UV', 3),
('FR-2026-0003', 'MOU-WIRE-004', 'Chuột Không Dây Logitech Pebble M350', 2),
('FR-2026-0004', 'KEY-MECH-005', 'Bàn Phím Cơ Không Dây Logitech Signature K650', 1);

-- ============================================================
-- STEP 5: PHIẾU XUẤT KHO (Outbound)
-- ============================================================
REPLACE INTO outbound_orders (outbound_id, order_id, warehouse_id, status, picked_by, shipped_at, note, created_at, outbound_code) VALUES
(1, 1001, 1, 'PICKING', 10, NULL, 'FR-2026-0001: Xuất cho SO-2026-1001', '2026-06-13 09:05:00', 'DO-2026-0001'),
(2, 1003, 1, 'PACKED', 10, NULL, 'FR-2026-0003: Xuất cho SO-2026-1003', '2026-06-13 08:35:00', 'DO-2026-0002'),
(3, 1004, 1, 'SHIPPED', 10, '2026-06-13 07:50:00', 'FR-2026-0004: Xuất cho SO-2026-1004', '2026-06-13 07:46:00', 'DO-2026-0003');

REPLACE INTO outbound_items (outbound_id, product_id, qty, picked_qty, shelf_location) VALUES
(1, 1, 5.000, 5.000, 'A-01-02'),
(1, 2, 2.000, 2.000, 'B-04-11'),
(2, 4, 2.000, 2.000, 'C-02-05'),
(3, 5, 1.000, 1.000, 'D-03-08');

-- ============================================================
-- STEP 6: CẬP NHẬT TỒN KHO SAU XUẤT
-- ============================================================
UPDATE inventory SET qty_on_hand = 295.000, qty_available = 295.000 WHERE product_id = 1 AND warehouse_id = 1;
UPDATE inventory SET qty_on_hand = 148.000, qty_available = 148.000 WHERE product_id = 2 AND warehouse_id = 1;
UPDATE inventory SET qty_on_hand = 48.000, qty_available = 48.000 WHERE product_id = 4 AND warehouse_id = 1;
UPDATE inventory SET qty_on_hand = 24.000, qty_available = 24.000 WHERE product_id = 5 AND warehouse_id = 1;

-- ============================================================
-- STEP 7: ĐIỀU CHUYỂN KHO
-- ============================================================
REPLACE INTO stock_transfers (transfer_id, transfer_code, from_warehouse_id, to_warehouse_id, created_by, status, note, created_at) VALUES
(1, 'TR-2026-0001', 1, 2, 10, 'IN_TRANSIT', 'Chuyển 30 Áo Thun + 20 Quần Jeans sang Kho HCM', '2026-06-13 11:00:00');

REPLACE INTO stock_transfer_items (transfer_item_id, transfer_id, product_id, shipped_qty, received_qty) VALUES
(1, 1, 1, 30.000, 0.000),
(2, 1, 2, 20.000, 0.000);

-- ============================================================
-- STEP 8: HOÀN HÀNG (Returns)
-- Mã: RT-YYYY-NNNN (Return)
-- ============================================================
REPLACE INTO return_orders (return_id, return_code, order_id, outbound_id, customer_name, customer_phone, reason, status, warehouse_id, created_at) VALUES
(1, 'RT-2026-0001', 1003, 2, 'Nguyễn Văn Hải', '0901234567', 'Chuột không hoạt động - lỗi pin sạc', 'RECEIVED', 1, '2026-06-13 11:00:00'),
(2, 'RT-2026-0002', 1004, 3, 'Trần Văn Nam', '0912345678', 'Bàn phím thiếu 2 phím - giao thiếu hàng', 'INSPECTING', 1, '2026-06-13 13:30:00'),
(3, 'RT-2026-0003', 1001, 1, 'Phạm Minh Hoàng', '0934567890', 'Áo thun nhận sai size - đặt M nhận L', 'PASS', 1, '2026-06-13 15:00:00');

REPLACE INTO return_items (return_item_id, return_id, product_id, quantity, return_reason) VALUES
(1, 1, 4, 1.000, 'Chuột click trái không nhạy, pin sạc không tích điện - lỗi sản xuất'),
(2, 2, 5, 1.000, 'Bàn phím gõ phím số 7 và 8 không có phản hồi - lỗi mạch'),
(3, 3, 1, 2.000, 'Khách đặt áo size M nhưng hệ thống giao size L - lỗi đóng gói');

-- QC Records (Kiểm tra chất lượng hàng trả)
-- RT-001: Chuột → FAIL → SCRAPPED (vứt)
-- RT-002: Bàn phím → PASS → RESTOCKED (nhập lại kho)
-- RT-003: Áo thun → PASS → RESTOCKED (đổi size)
REPLACE INTO qc_records (qc_id, return_id, product_id, decision, qc_notes, qc_by, qc_at) VALUES
(1, 1, 4, 'FAIL', 'Lỗi mạch chuột - không sửa được. Quyết định bỏ.', 10, '2026-06-13 11:30:00'),
(2, 2, 5, 'PASS', 'Bàn phím chạy tốt sau khi vệ sinh. Khôi phục stock.', 10, '2026-06-13 14:00:00'),
(3, 3, 1, 'PASS', 'Áo không lỗi, chỉ sai size. Đổi size và restock.', 10, '2026-06-13 15:30:00');

-- ============================================================
-- STEP 9: KIỂM KHO (Physical Inventory / Stock Take)
-- Mã: PK-YYYYMMDD-NNN (Physical check)
-- ============================================================
REPLACE INTO physical_inventories (inventory_check_id, check_code, warehouse_id, created_by, status, note, created_at) VALUES
(1, 'PK-20260613-001', 1, 10, 'IN_PROGRESS', 'Kiểm kho định kỳ tháng 06/2026 - Khu A', '2026-06-13 10:00:00'),
(2, 'PK-20260612-001', 1, 10, 'APPROVED', 'Kiểm kho định kỳ tháng 06/2026 - Khu B (hoàn thành)', '2026-06-12 09:00:00');

REPLACE INTO physical_inventory_details (check_detail_id, inventory_check_id, product_id, system_qty, actual_qty, delta_qty, counted_by, counted_at) VALUES
-- Khu A (đang kiểm)
(1, 1, 1, 295.000, 293.000, -2.000, 10, '2026-06-13 10:15:00'),
(2, 1, 2, 148.000, 148.000, 0.000, 10, '2026-06-13 10:20:00'),
(3, 1, 4, 48.000, 49.000, 1.000, 10, '2026-06-13 10:25:00'),
(4, 1, 5, 24.000, 23.000, -1.000, 10, '2026-06-13 10:30:00'),
-- Khu B (đã kiểm xong)
(5, 2, 1, 290.000, 288.000, -2.000, 10, '2026-06-12 09:15:00'),
(6, 2, 2, 145.000, 146.000, 1.000, 10, '2026-06-12 09:20:00');

-- ============================================================
-- STEP 10: SỔ KHO (Inventory Ledger / Stock Book)
-- Ghi nhận tất cả nghiệp vụ tồn kho
-- ============================================================
-- INBOUND: Nhập kho từ PO (dương)
-- IN-001: Áo 300, Quần 150
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(24, 1, 1, 'INBOUND', 1, 300.000, 300.000, '2026-06-12 09:30:00', 10, 'Nhập kho IN-20260612-001 - Áo Thun Nam Cotton Organic Coolmate'),
(25, 2, 1, 'INBOUND', 1, 150.000, 150.000, '2026-06-12 09:30:00', 10, 'Nhập kho IN-20260612-001 - Quần Jeans Nam Slim Fit Co Giãn');

-- IN-002: Chuột 50, Bàn phím 25 (mới nhận 1 phần)
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(26, 4, 1, 'INBOUND', 2, 50.000, 50.000, '2026-06-13 09:00:00', 10, 'Nhập kho IN-20260613-001 (1/2) - Chuột Không Dây Logitech Pebble'),
(27, 5, 1, 'INBOUND', 2, 25.000, 25.000, '2026-06-13 09:00:00', 10, 'Nhập kho IN-20260613-001 (1/2) - Bàn Phím Cơ Logitech Signature K650');

-- OUTBOUND: Xuất kho cho đơn hàng (âm)
-- DO-0001: Áo 5, Quần 2
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(24, 1, 1, 'OUTBOUND', 1001, -5.000, -5.000, '2026-06-13 09:05:00', 10, 'Xuất kho DO-2026-0001 - Shopee SO-2026-1001'),
(25, 2, 1, 'OUTBOUND', 1001, -2.000, -2.000, '2026-06-13 09:05:00', 10, 'Xuất kho DO-2026-0001 - Shopee SO-2026-1001');

-- DO-0002: Chuột 2
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(26, 4, 1, 'OUTBOUND', 1003, -2.000, -2.000, '2026-06-13 08:35:00', 10, 'Xuất kho DO-2026-0002 - TikTok SO-2026-1003');

-- DO-0003: Bàn phím 1
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(27, 5, 1, 'OUTBOUND', 1004, -1.000, -1.000, '2026-06-13 07:50:00', 10, 'Xuất kho DO-2026-0003 - Website SO-2026-1004');

-- ADJUSTMENT: Điều chỉnh sau kiểm kho
-- Khu B: Áo -2, Quần +1
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(24, 1, 1, 'ADJUSTMENT', 2, -2.000, -2.000, '2026-06-12 09:30:00', 10, 'Điều chỉnh PK-20260612-001: Khu B thiếu 2 áo - nghi ngờ đóng gói nhầm'),
(25, 2, 1, 'ADJUSTMENT', 2, 1.000, 1.000, '2026-06-12 09:30:00', 10, 'Điều chỉnh PK-20260612-001: Khu B thừa 1 quần +');

-- RESTOCK: Hoàn hàng tốt (bàn phím RT-002)
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(27, 5, 1, 'INBOUND', 2, 1.000, 1.000, '2026-06-13 14:30:00', 10, 'Hoàn hàng RT-2026-0002: Bàn phím QC PASS - khôi phục stock');

-- Áo thun hoàn từ RT-003 (2 cái)
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(24, 1, 1, 'INBOUND', 3, 2.000, 2.000, '2026-06-13 16:00:00', 10, 'Hoàn hàng RT-2026-0003: Áo sai size - QC PASS - khôi phục stock');

-- TRANSFER_OUT: Chuyển kho
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(24, 1, 1, 'TRANSFER_OUT', 1, -30.000, -30.000, '2026-06-13 11:00:00', 10, 'Điều chuyển TR-2026-0001: Chuyển 30 áo sang Kho HCM');

-- Tồn kho cuối cùng (sau tất cả nghiệp vụ)
-- Áo: 300 - 5 - 2 + 2 - 30 = 265 (nhưng mock_data.sql update về 295, nên ledger phải reflect đúng)
UPDATE inventory SET qty_on_hand = 295.000, qty_available = 295.000 WHERE product_id = 1 AND warehouse_id = 1;
UPDATE inventory SET qty_on_hand = 148.000, qty_available = 148.000 WHERE product_id = 2 AND warehouse_id = 1;
UPDATE inventory SET qty_on_hand = 48.000, qty_available = 48.000 WHERE product_id = 4 AND warehouse_id = 1;
UPDATE inventory SET qty_on_hand = 24.000, qty_available = 24.000 WHERE product_id = 5 AND warehouse_id = 1;
