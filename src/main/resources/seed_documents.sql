-- 1. Insert warehouses
INSERT IGNORE INTO warehouses (warehouse_id, warehouse_code, warehouse_name, address) 
VALUES (2, 'WH-02', 'Kho Da Nang', 'So 2 Duong XYZ, Da Nang');

-- 2. Insert default zones for warehouse 2
INSERT IGNORE INTO zones (warehouse_id, zone_code, zone_name, zone_type, description) 
VALUES (2, 'NORMAL', 'Khu Thuong', 'NORMAL', 'Khu vuc luu tru hang tot');

-- 3. Seed initial inventory in warehouse 1 and 2
INSERT INTO inventory (product_id, warehouse_id, qty_on_hand, holding, qty_available) 
VALUES (1, 1, 150.000, 0, 150.000)
ON DUPLICATE KEY UPDATE qty_on_hand = 150.000, qty_available = 150.000;

INSERT INTO inventory (product_id, warehouse_id, qty_on_hand, holding, qty_available) 
VALUES (2, 1, 80.000, 0, 80.000)
ON DUPLICATE KEY UPDATE qty_on_hand = 80.000, qty_available = 80.000;

INSERT INTO inventory (product_id, warehouse_id, qty_on_hand, holding, qty_available) 
VALUES (3, 1, 50.000, 0, 50.000)
ON DUPLICATE KEY UPDATE qty_on_hand = 50.000, qty_available = 50.000;

INSERT INTO inventory (product_id, warehouse_id, qty_on_hand, holding, qty_available) 
VALUES (2, 2, 10.000, 0, 10.000)
ON DUPLICATE KEY UPDATE qty_on_hand = 10.000, qty_available = 10.000;

-- 4. Inbound Order (Phiếu Nhập Kho) - PENDING
INSERT IGNORE INTO inbound_orders (inbound_id, inbound_code, warehouse_id, supplier, status, received_by, note, created_by, created_at)
VALUES (1, 'GRN-20260609-001', 1, 'Vinamilk Việt Nam', 'PENDING', 1, 'Nhập bổ sung sữa tươi cho đợt khuyến mãi', 1, NOW() - INTERVAL 1 HOUR);

INSERT IGNORE INTO inbound_items (inbound_item_id, inbound_id, product_id, expected_qty, received_qty)
VALUES (1, 1, 1, 100.000, 100.000);

-- 5. Outbound Order (Phiếu Xuất Kho) - PENDING
INSERT IGNORE INTO outbound_orders (outbound_id, outbound_code, order_id, warehouse_id, status, picked_by, note, created_at)
VALUES (1, 'SOUT-20260609-001', 1, 1, 'PENDING', 1, 'Đơn hàng B2B của đại lý Hà Nội', NOW() - INTERVAL 45 MINUTE);

INSERT IGNORE INTO outbound_items (outbound_item_id, outbound_id, product_id, qty, picked_qty)
VALUES (1, 1, 1, 10.000, 10.000);

-- 6. Stock Transfer (Phiếu Chuyển Kho) - IN_TRANSIT
INSERT IGNORE INTO stock_transfers (transfer_id, transfer_code, from_warehouse_id, to_warehouse_id, created_by, status, note, created_at)
VALUES (1, 'TR-20260609-001', 1, 2, 1, 'IN_TRANSIT', 'Điều chuyển nồi chiên không dầu từ Hà Nội vào Đà Nẵng', NOW() - INTERVAL 30 MINUTE);

INSERT IGNORE INTO stock_transfer_items (transfer_item_id, transfer_id, product_id, shipped_qty, received_qty)
VALUES (1, 1, 2, 5.000, 5.000);

-- 7. Physical Inventory Check (Phiếu Kiểm Kê) - IN_PROGRESS
INSERT IGNORE INTO physical_inventories (inventory_check_id, check_code, warehouse_id, created_by, status, note, created_at)
VALUES (1, 'STK-20260609-001', 1, 1, 'IN_PROGRESS', 'Kiểm kê định kỳ tai nghe Sony', NOW() - INTERVAL 15 MINUTE);

INSERT IGNORE INTO physical_inventory_details (check_detail_id, inventory_check_id, product_id, system_qty, actual_qty, delta_qty, counted_by, counted_at)
VALUES (1, 1, 3, 50.000, 52.000, 2.000, 1, NOW() - INTERVAL 10 MINUTE);
