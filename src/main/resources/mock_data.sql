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
(144, 'trungbd', '$2a$12$jf/LBsYBszp1HeFhwNnmK.1Ez4c03bDR4r8HCi7ogUnw4AQ6K/Rfy', 'Bùi Đức Trung', 'ductrung3625@gmail.com', NULL, 'EMAIL', 'WAREHOUSE_STAFF', 2, 1, '2026-06-10 22:08:24', '2026-06-12 14:21:20');

-- 8. USER WAREHOUSE ASSIGNMENTS
-- lamna (10) → warehouse_id=1 (Hà Nội)
-- trungbd (144) → warehouse_id=2 (HCM)
-- anhvl (8) → MANAGER - thấy tất cả kho
REPLACE INTO user_warehouse_assignments (user_id, warehouse_id, is_primary) VALUES
(1, 1, 1), (1, 2, 0),  -- ADMIN: cả 2 kho
(8, 1, 1), (8, 2, 1),  -- MANAGER (anhvl): cả 2 kho
(10, 1, 1), (10, 2, 0), -- WAREHOUSE_STAFF (lamna): chỉ WH-01
(16, 1, 1), (16, 2, 0), -- SALES_STAFF: WH-01
(144, 1, 0), (144, 2, 1); -- WAREHOUSE_STAFF (trungbd): chỉ WH-02

-- 9. SALES CHANNELS (cần cho Ledger hiển thị đúng)
-- Lưu ý: bảng channels có column is_active, không phải active
REPLACE INTO channels (channel_id, channel_name, platform, is_active) VALUES
(1, 'ONLINE', 'Omnichannel', 1),
(2, 'Shopee', 'Shopee', 1),
(3, 'TikTok', 'TikTok Shop', 1),
(4, 'Lazada', 'Lazada', 1),
(5, 'Website', 'Website', 1);

-- ============================================================
-- STEP 1: NHẬP KHO (Inbounds) - WAREHOUSE 1
-- WAREHOUSE STAFF tạo, MANAGER duyệt
-- ============================================================
-- IN-001: Coolmate giao Áo Thun + Quần Jeans → ĐÃ NHẬP KHO
-- IN-002: Digiworld giao Chuột + Bàn Phím → ĐANG NHẬP
-- IN-003: LocknLock giao Bình Giữ Nhiệt → CHỜ HÀNG VỀ
REPLACE INTO inbound_orders (inbound_id, inbound_code, warehouse_id, supplier, status, received_by, note, created_at, received_at, created_by) VALUES
(1, 'IN-20260612-001', 1, 'Công ty TNHH Coolmate Việt Nam', 'RECEIVED', 10, 'Đợt 1: Áo Thun + Quần Jeans đã nhập đủ', '2026-06-12 08:00:00', '2026-06-12 09:30:00', 10),
(2, 'IN-20260613-001', 1, 'Nhà Phân Phối Logitech Digiworld', 'IN_PROGRESS', 10, 'Đợt 2: Chuột + Bàn Phím - đang kiểm hàng', '2026-06-13 08:00:00', NULL, 10),
(3, 'IN-20260613-002', 1, 'Công ty TNHH Khóa Lock&Lock', 'PENDING', NULL, 'Đợt 3: Bình giữ nhiệt - đang vận chuyển', '2026-06-13 10:00:00', NULL, 10);

-- ============================================================
-- STEP 1B: NHẬP KHO (Inbounds) - WAREHOUSE 2
-- Để MANAGER thấy được nhiều kho, WH Staff khác phụ trách
-- ============================================================
REPLACE INTO inbound_orders (inbound_id, inbound_code, warehouse_id, supplier, status, received_by, note, created_at, received_at, created_by) VALUES
(4, 'IN-20260614-001', 2, 'Công ty TNHH Mỹ Phẩm Sakura', 'RECEIVED', 144, 'Nhập lô Kem Chống Nắng mới', '2026-06-14 08:00:00', '2026-06-14 09:00:00', 144),
(5, 'IN-20260614-002', 2, 'Nhà Phân Phối Apple Việt Nam', 'PENDING', NULL, 'Nhập iPhone 15 Pro - đang kiểm IMEI', '2026-06-14 10:00:00', NULL, 144);

-- Inbound Items
REPLACE INTO inbound_items (inbound_item_id, inbound_id, product_id, expected_qty, received_qty) VALUES
-- WH-01: IN-001: Áo 300, Quần 150 → nhận đủ
(1, 1, 1, 300.000, 300.000),
(2, 1, 2, 150.000, 150.000),
-- WH-01: IN-002: Chuột 100, Bàn Phím 50 → nhận 1 nửa
(3, 2, 4, 100.000, 50.000),
(4, 2, 5, 50.000, 25.000),
-- WH-01: IN-003: Bình Giữ Nhiệt 80 → chờ
(5, 3, 6, 80.000, 0.000),
-- WH-02: IN-004: Kem Chống Nắng 100 → nhận đủ
(6, 4, 7, 100.000, 100.000),
-- WH-02: IN-005: iPhone (product mới) 50 → chờ
(7, 5, 1, 50.000, 0.000);

-- ============================================================
-- STEP 2: TỒN KHO (Sau khi nhập IN-001, IN-002, IN-004)
-- inventory_id cố định để ledger refer đúng
-- ============================================================
DELETE FROM inventory WHERE product_id IN (1,2,3,4,5,6,7);
INSERT INTO inventory (inventory_id, product_id, warehouse_id, qty_on_hand, holding, qty_available) VALUES
-- WAREHOUSE 1 (Hà Nội)
(1, 1, 1, 295.000, 0.000, 295.000),  -- Áo Thun Kho Hà Nội
(2, 2, 1, 148.000, 0.000, 148.000),  -- Quần Jeans Kho Hà Nội
(3, 3, 1, 0.000, 0.000, 0.000),      -- Kính Râm (chưa nhập)
(4, 4, 1, 48.000, 0.000, 48.000),    -- Chuột Kho Hà Nội
(5, 5, 1, 24.000, 0.000, 24.000),   -- Bàn Phím Kho Hà Nội
(6, 6, 1, 0.000, 0.000, 0.000),      -- Bình Giữ Nhiệt (chưa nhập)
(7, 7, 1, 0.000, 0.000, 0.000),      -- Kem Chống Nắng (chưa nhập vào WH1)
-- WAREHOUSE 2 (HCM) - có tồn kho riêng
(8, 1, 2, 30.000, 0.000, 30.000),    -- Áo Thun Kho HCM (từ transfer cũ)
(9, 2, 2, 20.000, 0.000, 20.000),    -- Quần Jeans Kho HCM (từ transfer cũ)
(10, 7, 2, 95.000, 0.000, 95.000);   -- Kem Chống Nắng Kho HCM (IN-20260614-001)

-- ============================================================
-- STEP 3: ĐƠN HÀNG (Từ sàn - Sales duyệt)
-- ============================================================
-- SO-1001: Shopee (channel=ONLINE) - 5 Áo + 2 Quần → PICKING
-- SO-1002: Lazada (channel=ONLINE) - 3 Kính Râm → PENDING (chưa có stock)
-- SO-1003: TikTok (channel=ONLINE) - 2 Chuột → PACKED
-- SO-1004: Website (channel=ONLINE) - 1 Bàn Phím → SHIPPED
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
-- STEP 5: PHIẾU XUẤT KHO (Outbound) - WAREHOUSE 1
-- WAREHOUSE STAFF tạo, MANAGER duyệt
-- ============================================================
REPLACE INTO outbound_orders (outbound_id, order_id, warehouse_id, status, picked_by, shipped_at, note, created_at, outbound_code) VALUES
(1, 1001, 1, 'PICKING', 10, NULL, 'FR-2026-0001: Xuất cho SO-2026-1001', '2026-06-13 09:05:00', 'DO-2026-0001'),
(2, 1003, 1, 'PACKED', 10, NULL, 'FR-2026-0003: Xuất cho SO-2026-1003', '2026-06-13 08:35:00', 'DO-2026-0002'),
(3, 1004, 1, 'SHIPPED', 10, '2026-06-13 07:50:00', 'FR-2026-0004: Xuất cho SO-2026-1004', '2026-06-13 07:46:00', 'DO-2026-0003');

-- ============================================================
-- STEP 5B: PHIẾU XUẤT KHO (Outbound) - WAREHOUSE 2
-- Để MANAGER thấy được nhiều kho
-- ============================================================
REPLACE INTO outbound_orders (outbound_id, order_id, warehouse_id, status, picked_by, shipped_at, note, created_at, outbound_code) VALUES
(4, 1005, 2, 'PICKING', 144, NULL, 'Xuất cho khách lẻ tại HCM', '2026-06-14 09:00:00', 'DO-2026-0004'),
(5, 1006, 2, 'PENDING', NULL, NULL, 'Xuất bổ sung cho đơn online HCM', '2026-06-14 10:00:00', 'DO-2026-0005');

-- Thêm orders cho WH-02
REPLACE INTO orders (order_id, order_code, customer_id, warehouse_id, channel, status, total_amount, note, created_by, created_at) VALUES
(1005, 'SO-2026-1005', 16, 2, 'ONLINE', 'PICKING', 5*480000, 'Khách lẻ tại HCM - Mỹ Phẩm Sakura', 16, '2026-06-14 09:00:00'),
(1006, 'SO-2026-1006', 16, 2, 'ONLINE', 'PENDING', 10*480000, 'Online HCM - Kem Chống Nắng', 16, '2026-06-14 10:00:00');

REPLACE INTO order_items (order_item_id, order_id, product_id, qty, unit_price) VALUES
(10, 1005, 7, 5, 480000.00),
(11, 1006, 7, 10, 480000.00);

REPLACE INTO outbound_items (outbound_id, product_id, qty, picked_qty, shelf_location) VALUES
(1, 1, 5.000, 5.000, 'A-01-02'),
(1, 2, 2.000, 2.000, 'B-04-11'),
(2, 4, 2.000, 2.000, 'C-02-05'),
(3, 5, 1.000, 1.000, 'D-03-08'),
(4, 7, 5.000, 5.000, 'E-01-01'),
(5, 7, 10.000, 0.000, 'E-01-01');

-- ============================================================
-- STEP 6: CẬP NHẬT TỒN KHO SAU XUẤT (đã có ở STEP 2)
-- ============================================================

-- ============================================================
-- STEP 7: ĐIỀU CHUYỂN KHO
-- ============================================================
REPLACE INTO stock_transfers (transfer_id, transfer_code, from_warehouse_id, to_warehouse_id, created_by, status, note, created_at) VALUES
(1, 'TR-2026-0001', 1, 2, 10, 'IN_TRANSIT', 'Chuyển 30 Áo Thun + 20 Quần Jeans sang Kho HCM', '2026-06-13 11:00:00');

REPLACE INTO stock_transfer_items (transfer_item_id, transfer_id, product_id, shipped_qty, received_qty) VALUES
(1, 1, 1, 30.000, 0.000),
(2, 1, 2, 20.000, 0.000);

-- ============================================================
-- STEP 8: HOÀN HÀNG (Returns) - WAREHOUSE 1
-- Mã: RT-YYYY-NNNN (Return)
-- ============================================================
REPLACE INTO return_orders (return_id, return_code, order_id, outbound_id, customer_name, customer_phone, reason, status, warehouse_id, created_at) VALUES
(1, 'RT-2026-0001', 1003, 2, 'Nguyễn Văn Hải', '0901234567', 'Chuột không hoạt động - lỗi pin sạc', 'RECEIVED', 1, '2026-06-13 11:00:00'),
(2, 'RT-2026-0002', 1004, 3, 'Trần Văn Nam', '0912345678', 'Bàn phím thiếu 2 phím - giao thiếu hàng', 'INSPECTING', 1, '2026-06-13 13:30:00'),
(3, 'RT-2026-0003', 1001, 1, 'Phạm Minh Hoàng', '0934567890', 'Áo thun nhận sai size - đặt M nhận L', 'PASS', 1, '2026-06-13 15:00:00');

-- ============================================================
-- STEP 8B: HOÀN HÀNG (Returns) - WAREHOUSE 2
-- Để MANAGER thấy được nhiều kho
-- ============================================================
REPLACE INTO return_orders (return_id, return_code, order_id, outbound_id, customer_name, customer_phone, reason, status, warehouse_id, created_at) VALUES
(4, 'RT-2026-0004', 1005, 4, 'Lê Thị Hương', '0945678901', 'Kem chống nắng không phù hợp da - dị ứng', 'RECEIVED', 2, '2026-06-14 11:00:00');

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
-- STEP 9: KIỂM KHO (Physical Inventory / Stock Take) - WAREHOUSE 1
-- Mã: PK-YYYYMMDD-NNN (Physical check)
-- ============================================================
REPLACE INTO physical_inventories (inventory_check_id, check_code, warehouse_id, created_by, status, note, created_at) VALUES
(1, 'PK-20260613-001', 1, 10, 'IN_PROGRESS', 'Kiểm kho định kỳ tháng 06/2026 - Khu A', '2026-06-13 10:00:00'),
(2, 'PK-20260612-001', 1, 10, 'APPROVED', 'Kiểm kho định kỳ tháng 06/2026 - Khu B (hoàn thành)', '2026-06-12 09:00:00');

-- ============================================================
-- STEP 9B: KIỂM KHO (Physical Inventory / Stock Take) - WAREHOUSE 2
-- Để MANAGER thấy được nhiều kho
-- ============================================================
REPLACE INTO physical_inventories (inventory_check_id, check_code, warehouse_id, created_by, status, note, created_at) VALUES
(3, 'PK-20260614-001', 2, 144, 'IN_PROGRESS', 'Kiểm kho định kỳ tháng 06/2026 - Kho HCM', '2026-06-14 10:00:00');

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
-- Transaction types: INBOUND | OUTBOUND | ADJUSTMENT | TRANSFER_IN | TRANSFER_OUT
-- inventory_id phải khớp với bản ghi thực tế trong inventory
-- ref_document_id: inbound_id, order_id, transfer_id, inventory_check_id...
-- ============================================================

-- ═══ 10.1 NHẬP KHO (Inbound) ════════════════════════════

-- IN-20260612-001: Coolmate giao Áo Thun 300 + Quần Jeans 150 → RECEIVED
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(1, 1, 1, 'INBOUND', 1, 300.000, 300.000, '2026-06-12 09:30:00', 10, 'Nhập kho IN-20260612-001 | Coolmate | Áo Thun Nam Cotton Organic Coolmate 300 cái'),
(2, 2, 1, 'INBOUND', 1, 150.000, 150.000, '2026-06-12 09:30:00', 10, 'Nhập kho IN-20260612-001 | Coolmate | Quần Jeans Nam Slim Fit 150 cái');

-- IN-20260613-001: Digiworld giao 1 phần → Chuột 50 + Bàn Phím 25
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(4, 4, 1, 'INBOUND', 2, 50.000, 50.000, '2026-06-13 09:00:00', 10, 'Nhập kho IN-20260613-001 | Digiworld | Chuột Logitech Pebble 50 cái (nhận 1/2 lô)'),
(5, 5, 1, 'INBOUND', 2, 25.000, 25.000, '2026-06-13 09:00:00', 10, 'Nhập kho IN-20260613-001 | Digiworld | Bàn Phím Cơ Logitech 25 cái (nhận 1/2 lô)');

-- ═══ 10.2 XUẤT KHO (Outbound) ═══════════════════════════

-- DO-2026-0001: SO-2026-1001 → Áo 5 + Quần 2 (Shopee)
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(1, 1, 1, 'OUTBOUND', 1001, -5.000, -5.000, '2026-06-13 09:05:00', 10, 'Xuất kho DO-2026-0001 | SO-2026-1001 | Shopee | Phạm Minh Hoàng | Áo Thun 5 cái'),
(2, 2, 1, 'OUTBOUND', 1001, -2.000, -2.000, '2026-06-13 09:05:00', 10, 'Xuất kho DO-2026-0001 | SO-2026-1001 | Shopee | Phạm Minh Hoàng | Quần Jeans 2 cái');

-- DO-2026-0002: SO-2026-1003 → Chuột 2 (TikTok)
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(4, 4, 1, 'OUTBOUND', 1003, -2.000, -2.000, '2026-06-13 08:35:00', 10, 'Xuất kho DO-2026-0002 | SO-2026-1003 | TikTok | Nguyễn Văn Hải | Chuột Logitech 2 cái');

-- DO-2026-0003: SO-2026-1004 → Bàn Phím 1 (Website)
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(5, 5, 1, 'OUTBOUND', 1004, -1.000, -1.000, '2026-06-13 07:50:00', 10, 'Xuất kho DO-2026-0003 | SO-2026-1004 | Website | Trần Văn Nam | Bàn Phím Cơ 1 cái');

-- ═══ 10.3 ĐIỀU CHỈNH (Adjustment) ══════════════════════

-- PK-20260612-001 (Khu B) → Áo -2, Quần +1
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(1, 1, 1, 'ADJUSTMENT', 2, -2.000, -2.000, '2026-06-12 09:30:00', 10, 'Kiểm kho PK-20260612-001 | Khu B | Thiếu 2 áo - nghi đóng gói nhầm sang đơn khác'),
(2, 2, 1, 'ADJUSTMENT', 2, 1.000, 1.000, '2026-06-12 09:30:00', 10, 'Kiểm kho PK-20260612-001 | Khu B | Thừa 1 quần + từ đơn hoàn trước');

-- ═══ 10.4 HOÀN HÀNG (Returns) ═══════════════════════════

-- RT-2026-0002: Bàn Phím QC PASS → Restock (+1)
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(5, 5, 1, 'INBOUND', 2, 1.000, 1.000, '2026-06-13 14:30:00', 10, 'Hoàn hàng RT-2026-0002 | Trần Văn Nam | Bàn Phím Cơ 1 cái | QC PASS - khôi phục stock');

-- RT-2026-0003: Áo Thun QC PASS → Restock (+2)
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(1, 1, 1, 'INBOUND', 3, 2.000, 2.000, '2026-06-13 16:00:00', 10, 'Hoàn hàng RT-2026-0003 | Phạm Minh Hoàng | Áo Thun sai size 2 cái | QC PASS - khôi phục stock');

-- RT-2026-0001: Chuột QC FAIL → SCRAPPED (không ghi ledger vì hàng bị hủy)

-- ═══ 10.5 ĐIỀU CHUYỂN KHO (Transfer) ════════════════════

-- TR-2026-0001: Chuyển 30 Áo + 20 Quần sang Kho HCM
INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, ref_document_id, qty_change, avail_change, timestamp, created_by, note) VALUES
(1, 1, 1, 'TRANSFER_OUT', 1, -30.000, -30.000, '2026-06-13 11:00:00', 10, 'Điều chuyển TR-2026-0001 | Kho Hà Nội → Kho HCM | Áo Thun 30 cái'),
(2, 2, 1, 'TRANSFER_OUT', 1, -20.000, -20.000, '2026-06-13 11:00:00', 10, 'Điều chuyển TR-2026-0001 | Kho Hà Nội → Kho HCM | Quần Jeans 20 cái'),
(8, 1, 2, 'TRANSFER_IN', 1, 30.000, 30.000, '2026-06-13 11:00:00', 10, 'Điều chuyển TR-2026-0001 | Nhận từ Kho Hà Nội | Áo Thun 30 cái'),
(9, 2, 2, 'TRANSFER_IN', 1, 20.000, 20.000, '2026-06-13 11:00:00', 10, 'Điều chuyển TR-2026-0001 | Nhận từ Kho Hà Nội | Quần Jeans 20 cái');
