# TODO — Lộ trình Tái cấu trúc Hệ thống B2C Omnichannel WMS Hub

> Tài liệu này tổng hợp các task cần làm dựa trên Báo cáo Kiểm toán As-Built (file `.cursor/plans/as-built_audit_b2c_wms_hub_af51902d.plan.md`) và Bản phản biện chuyên sâu (file `Phản biện Luồng Nghiệp Vụ WMS Omnichannel.md`).
> Mỗi task có: mô tả, file cần sửa, acceptance criteria, effort ước lượng, độ ưu tiên.

---

## Tổng quan tiến độ

- [ ] **Giai đoạn 1 — Critical Hotfixes** (5 task, ~4.5 ngày)
- [ ] **Giai đoạn 2 — Khắc phục Giao thoa Đa kênh** (3 task, ~6 ngày)
- [ ] **Giai đoạn 3 — Hiện đại hóa WMS** (4 task, ~5.5 ngày)
- [ ] **Tech debt / Cleanup** (5 task, ~3 ngày)

**Tổng effort ước tính:** ~19 ngày làm việc (≈ 4 tuần).

---

## Giai đoạn 1 — Critical Hotfixes (Triển khai Ngay)

### [HOTFIX-1] Release Soft-Allocation Lock
- **Mức ưu tiên:** CRITICAL
- **Effort:** 0.5 ngày
- **File cần sửa:**
  - `src/main/java/com/wms/dao/InventoryDAO.java` (THÊM method mới)
  - `src/main/java/com/wms/service/warehouse/OutboundService.java` (sửa `cancel()` line 220-238)
  - `src/main/java/com/wms/service/warehouse/OutboundService.java` (sửa `updateStatus("SHIPPED")` line 120-168)
- **Mô tả:** `inventory.holding` hiện chỉ tăng (qua `softAllocateInventory`) nhưng không có method nào release. Khi đơn cancel hoặc SHIPPED, `holding` bị "kẹt" vĩnh viễn, `qty_available` lao dốt → toàn hệ thống báo hết hàng dù kho vẫn còn.
- **Code mẫu:**
  ```java
  // THÊM MỚI vào InventoryDAO
  public boolean releaseSoftAllocateInventory(int productId, int warehouseId, BigDecimal qty) {
      String sql = "UPDATE inventory SET holding = holding - ?, "
                 + "qty_available = qty_available + ? "
                 + "WHERE product_id = ? AND warehouse_id = ? AND holding >= ?";
      return update(LOGGER, sql, qty, qty, productId, warehouseId, qty) > 0;
  }

  public boolean hardAllocateInventory(int productId, int warehouseId, BigDecimal qty) {
      String sql = "UPDATE inventory SET holding = holding - ?, "
                 + "qty_on_hand = qty_on_hand - ? "
                 + "WHERE product_id = ? AND warehouse_id = ? "
                 + "AND qty_on_hand >= ? AND holding >= ?";
      return update(LOGGER, sql, qty, qty, productId, warehouseId, qty, qty) > 0;
  }
  ```
- **Acceptance criteria:**
  - [ ] Cancel outbound → `holding` giảm, `qty_available` cộng lại
  - [ ] SHIPPED outbound → `holding` giảm, `qty_on_hand` giảm
  - [ ] Guard `holding >= qty` ngăn release âm
  - [ ] Unit test với scenario release 1 phần + release toàn bộ

---

### [HOTFIX-2] Sửa ENUM Mismatch cho Order Status
- **Mức ưu tiên:** CRITICAL
- **Effort:** 0.5 ngày
- **File cần sửa:**
  - `src/main/java/com/wms/service/sales/OrderService.java:90, 139, 144` (sửa 3 chỗ set status sai)
- **Mô tả:** Code dùng `"REJECTED"`, `"RMA"`, `"COMPLETED"` nhưng `orders.order_status` ENUM trong `schema.sql:265-266` chỉ chấp nhận `PENDING, CONFIRMED, PICKING, PACKED, SHIPPED, DELIVERED, CANCELLED, RETURNED`. MySQL throw `1265 Data truncated` khi UPDATE.
- **Cách sửa (khuyến nghị):** Sửa code thay vì mở rộng schema, dùng giá trị ENUM hợp lệ:
  - `"REJECTED"` → `"CANCELLED"` + ghi `note` (đã có `review_note`)
  - `"RMA"` → `"RETURNED"`
  - `"COMPLETED"` → `"DELIVERED"`
- **Acceptance criteria:**
  - [ ] Click "Từ chối" đơn → status thành `CANCELLED` không lỗi SQL
  - [ ] Webhook báo `RETURNED` → status thành `RETURNED` không lỗi SQL
  - [ ] Webhook báo `COMPLETED` → status thành `DELIVERED` không lỗi SQL
  - [ ] Test với 1 đơn PENDING thật từ DB

---

### [HOTFIX-3] Tách Maker-Checker khỏi Warehouse (chống Double-Count Ledger)
- **Mức ưu tiên:** CRITICAL
- **Effort:** 2 ngày
- **File cần sửa:**
  - `src/main/java/com/wms/service/warehouse/WarehouseService.java:145-152` (`adjustInventoryFromCheck`)
  - `src/main/java/com/wms/dao/WarehouseDAO.java:524-607` (`applyInventoryAdjustments`)
  - `src/main/java/com/wms/dao/ReturnDAO.java:356-515` (`applyRestock`)
  - `src/main/java/com/wms/service/ledger/LedgerService.java` (thêm method `approveInventoryCheck`, `approveReturnRestock`)
- **Mô tả:** `WarehouseService.adjustInventoryFromCheck` hiện ghi ledger ADJUSTMENT trước, sau đó Manager lại bấm approve ở `/business/ledger` → ghi ledger thêm lần nữa. Tương tự với `ReturnDAO.applyRestock` (ghi ledger INBOUND). Kết quả: 1 hao hụt vật lý bị nhân đôi trong sổ cái.
- **Cách sửa:**
  - Warehouse chỉ được UPDATE status phiếu sang `PENDING_APPROVAL`, KHÔNG được UPSERT inventory/INSERT ledger
  - Manager gọi `LedgerService.approveInventoryCheck()` mới được UPSERT + INSERT ledger
- **Acceptance criteria:**
  - [ ] Kiểm kê chênh -2 áo → chỉ ghi 1 dòng ADJUSTMENT trong `inventory_ledger`
  - [ ] Return PASS → chỉ ghi 1 dòng INBOUND trong `inventory_ledger`
  - [ ] Manager bấm approve phiếu đã ghi rồi → KHÔNG ghi thêm dòng ledger (idempotent)
  - [ ] Test với DB thật: tạo phiếu kiểm kê chênh lệch, kiểm tra `SELECT COUNT(*) FROM inventory_ledger WHERE ref_document_id = ?` = 1

---

### [HOTFIX-4] Bù đắp Transfer Inventory Movement
- **Mức ưu tiên:** CRITICAL
- **Effort:** 1 ngày
- **File cần sửa:**
  - `src/main/java/com/wms/service/warehouse/TransferService.java:92-97` (`markReceived`)
  - `src/main/java/com/wms/dao/TransferDAO.java`
- **Mô tả:** Hàng rời kho A → nhập kho B nhưng DB vẫn báo ở A, không xuất hiện ở B. Vi phạm nguyên lý bảo toàn vật chất.
- **Cách sửa:** Trong `markReceived`:
  1. Trừ tồn kho nguồn (qty_on_hand, qty_available) + giảm holding
  2. Cộng tồn kho đích
  3. Ghi 2 dòng ledger: TRANSFER_OUT + TRANSFER_IN
  4. Update status RECEIVED
- **Acceptance criteria:**
  - [ ] Tạo transfer từ kho A (qty=10) → kho B
  - [ ] Sau khi kho B xác nhận nhận: kho A giảm 10, kho B tăng 10
  - [ ] `inventory_ledger` có 2 dòng mới (TRANSFER_OUT, TRANSFER_IN)
  - [ ] Test rollback nếu 1 trong 2 bước fail

---

### [HOTFIX-5] ATP Validation cho Sales Approve
- **Mức ưu tiên:** CRITICAL
- **Effort:** 0.5 ngày
- **File cần sửa:**
  - `src/main/java/com/wms/service/sales/OrderService.java:65-86` (case `approve`)
  - `src/main/java/com/wms/dao/InventoryDAO.java` (thêm `getQtyAvailable(productId, warehouseId)` nếu chưa có)
- **Mô tả:** Hiện `OrderService.handleAction("approve")` chuyển thẳng status sang PICKING mà không kiểm tra `qty_available`. Duyệt được cả đơn không có hàng → Warehouse nhận picking sheet ảo.
- **Cách sửa:** Trước khi update status, kiểm tra `qty_available >= item.quantity` cho từng `OrderItem`. Nếu thiếu → fail với message rõ ràng.
- **Acceptance criteria:**
  - [ ] Đơn 5 áo nhưng kho chỉ có 3 áo → approve fail với message "Không đủ tồn cho SKU X: cần 5, có 3"
  - [ ] Đơn 5 áo, kho có 10 áo → approve thành công
  - [ ] Đơn nhiều SKU, 1 SKU thiếu → fail toàn bộ đơn (atomic)
  - [ ] Test với mock data trong `mock_data.sql`

---

## Giai đoạn 2 — Khắc phục Giao thoa Đa kênh (Trung hạn)

### [MULTICHANNEL-1] SKU Mapping Lookup trong Lazada Sync
- **Mức ưu tiên:** HIGH
- **Effort:** 2 ngày
- **File cần sửa:**
  - `src/main/java/com/wms/scheduler/LazadaSyncScheduler.java:149-204` (`saveOrdersToDb`)
  - `src/main/java/com/wms/dao/SkuMappingDAO.java` (thêm `findByExternalSku`)
  - `src/main/resources/schema.sql` (THÊM bảng `mapping_exceptions`)
- **Mô tả:** Hiện `LazadaSyncScheduler` hardcode `product_id = DUMMY-LAZADA` (qty ảo 100,000). Bỏ qua toàn bộ `sku_mappings` mà Sales đã xây. Đơn Lazada không resolve được SKU thật → soft-allocate trên DUMMY, kho thật không giảm → Overselling.
- **Cách sửa:**
  1. Tra cứu `sku_mappings` theo `external_sku` + `channel_id` → lấy `sku_id` thật
  2. Nếu không tìm thấy → INSERT vào bảng mới `mapping_exceptions` (status PENDING) để Sales xử lý
  3. KHÔNG tạo order_items nếu không resolve được SKU
- **Bảng mới:**
  ```sql
  CREATE TABLE mapping_exceptions (
      exception_id INT AUTO_INCREMENT PRIMARY KEY,
      channel_id INT NOT NULL,
      external_order_id VARCHAR(100) NOT NULL,
      external_sku VARCHAR(100) NOT NULL,
      received_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      resolved_at DATETIME,
      resolved_by INT,
      FOREIGN KEY (channel_id) REFERENCES channels(channel_id)
  );
  ```
- **Acceptance criteria:**
  - [ ] Đơn Lazada có SKU mapping → resolve đúng `product_id`, soft-allocate đúng kho
  - [ ] Đơn Lazada KHÔNG có SKU mapping → INSERT vào `mapping_exceptions`, KHÔNG tạo order
  - [ ] Sales xem được danh sách `mapping_exceptions` ở `/sales/sku-mapping` (thêm tab mới)
  - [ ] Sau khi Sales tạo mapping + click "Resolve" → đơn được re-process

---

### [MULTICHANNEL-2] Implement Buffer Stock trong ATP Calculation
- **Mức ưu tiên:** MEDIUM
- **Effort:** 1 ngày
- **File cần sửa:**
  - TẠO MỚI `src/main/java/com/wms/service/warehouse/InventoryQueryService.java`
  - `src/main/java/com/wms/service/sales/ChannelService.java` (gọi `InventoryQueryService` khi update stock lên channel)
- **Mô tả:** `channels.buffer_stock` tồn tại (`schema.sql:147`) nhưng là dead field — không được đọc bởi bất kỳ service nào. Sales cập nhật nhưng vô tác dụng. Cần ATP formula: `available_to_promise = qty_on_hand - holding - buffer_stock`.
- **Code mẫu:**
  ```java
  public BigDecimal getAtpForChannel(int productId, int warehouseId, int channelId) {
      BigDecimal onHand = inventoryDAO.getQtyOnHand(productId, warehouseId);
      BigDecimal holding = inventoryDAO.getHolding(productId, warehouseId);
      BigDecimal buffer = channelDAO.getBufferStock(channelId);
      return onHand.subtract(holding).subtract(buffer).max(BigDecimal.ZERO);
  }
  ```
- **Acceptance criteria:**
  - [ ] `getAtpForChannel` trả về đúng công thức
  - [ ] Khi sync stock lên Lazada/Shopee API → dùng ATP, không dùng qty_available
  - [ ] Test với buffer=5, on_hand=100, holding=10 → ATP = 85

---

### [MULTICHANNEL-3] Event-Driven Ledger (thay Maker-Checker cho INBOUND/OUTBOUND/TRANSFER)
- **Mức ưu tiên:** HIGH
- **Effort:** 3 ngày
- **File cần sửa:**
  - TẠO MỚI `src/main/java/com/wms/service/warehouse/InventoryCommandBus.java`
  - `src/main/java/com/wms/service/warehouse/InboundService.java` (refactor `receiveGoods`)
  - `src/main/java/com/wms/service/warehouse/OutboundService.java` (refactor `updateStatus("SHIPPED")`)
  - `src/main/java/com/wms/service/warehouse/TransferService.java` (refactor `markReceived`)
  - `src/main/java/com/wms/service/ledger/LedgerService.java` (giữ `approveDocument` chỉ cho ADJUSTMENT/SCRAP)
- **Mô tả:** Maker-Checker hiện bắt Manager duyệt tay mọi phiếu nhập/xuất → nút thắt cổ chai trong peak season. Cần tự động ghi ledger khi Warehouse xác nhận, chỉ giữ Maker-Checker cho các phiếu bất thường (ADJUSTMENT, SCRAP).
- **Pattern:** Tạo `InventoryCommandBus` — mọi mutation inventory phải qua đây, ghi ledger atomic.
- **Acceptance criteria:**
  - [ ] Warehouse xác nhận nhận hàng → tồn kho + ledger được cập nhật NGAY (không cần Manager duyệt)
  - [ ] Warehouse xác nhận SHIPPED → tồn kho giảm + ledger OUTBOUND được ghi NGAY
  - [ ] Manager chỉ cần duyệt phiếu Kiểm kê (ADJUSTMENT) và Xuất hủy (SCRAP)
  - [ ] Ledger và inventory luôn đồng bộ (transaction test)

---

## Giai đoạn 3 — Hiện đại hóa WMS (Dài hạn)

### [WMS-MODERN-1] Implement Directed Picking (thay 5 method STUB)
- **Mức ưu tiên:** MEDIUM
- **Effort:** 3 ngày
- **File cần sửa:**
  - `src/main/java/com/wms/dao/OutboundDAO.java` (implement 5 method: `assignPicker`, `createPickingSheet`, `markAllPicked`, `completePickingSheet`, `createShippingLabel`, `createDeliveryNote`)
  - `src/main/java/com/wms/service/warehouse/OutboundService.java:120-168` (gọi các method thật thay vì stub)
- **Mô tả:** 5 method trong `OutboundService.updateStatus` cho các nhánh PICKING, PACKED, SHIPPED hiện là STUB/TODO → toàn bộ quy trình Pick-Pack-Ship không cập nhật DB. Không hỗ trợ Wave Picking / Zone Picking.
- **Acceptance criteria:**
  - [ ] Chuyển sang PICKING → `outbound_orders.picked_by` được set, `picking_sheets` được tạo
  - [ ] Chuyển sang PACKED → `outbound_items.picked_qty = qty`, `picking_sheets.status = COMPLETED`, `shipping_labels` được insert
  - [ ] Chuyển sang SHIPPED → `delivery_notes` được insert với `delivered_by`, `delivery_date`
  - [ ] Test với outbound order thật từ DB

---

### [WMS-MODERN-2] RBAC Filter (phân quyền theo URL)
- **Mức ưu tiên:** HIGH
- **Effort:** 1 ngày
- **File cần sửa:**
  - TẠO MỚI `src/main/java/com/wms/filter/RoleAccessFilter.java`
  - `src/main/webapp/WEB-INF/web.xml` (đăng ký filter mới)
- **Mô tả:** `AuthFilter` hiện chỉ check "đã login", không phân quyền theo URL. Bất kỳ user đã login đều gọi được `/business/ledger` → BUG bảo mật.
- **Cách sửa:** Tạo `RoleAccessFilter` map `path_prefix → allowed_roles`:
  ```java
  private static final Map<String, String[]> PATH_ROLES = Map.of(
      "/business/", new String[]{"MANAGER","ADMIN"},
      "/warehouse/", new String[]{"WAREHOUSE_STAFF","MANAGER","ADMIN"},
      "/sales/", new String[]{"SALES_STAFF","MANAGER","ADMIN"},
      "/admin/", new String[]{"ADMIN"}
  );
  ```
- **Acceptance criteria:**
  - [ ] Sales login → gọi `/business/ledger` → 403
  - [ ] Warehouse login → gọi `/business/master-sku` → 403
  - [ ] Manager login → truy cập mọi URL
  - [ ] Test với 4 role khác nhau

---

### [WMS-MODERN-3] Webhook HMAC-SHA256 Verification
- **Mức ưu tiên:** HIGH
- **Effort:** 0.5 ngày
- **File cần sửa:**
  - `src/main/java/com/wms/controller/sales/OrderActionServlet.java` (case `webhook`)
  - `src/main/java/com/wms/dao/ChannelDAO.java` (thêm `getWebhookSecret`)
- **Mô tả:** Webhook nhận `platformStatus` qua POST param mà không verify signature. Bất kỳ ai biết URL đều có thể giả mạo update status đơn.
- **Cách sửa:** Verify HMAC-SHA256 dùng `channels.webhook_secret`:
  ```java
  String secret = channelDAO.getWebhookSecret(channelId);
  String computed = HmacUtils.hmacSha256Hex(secret, payload);
  if (!MessageDigest.isEqual(signature.getBytes(), computed.getBytes())) {
      return ActionResult.failure("Invalid signature");
  }
  ```
- **Acceptance criteria:**
  - [ ] Webhook đúng signature → xử lý bình thường
  - [ ] Webhook sai signature → 401 Unauthorized
  - [ ] Webhook không có signature → 401
  - [ ] Test với HMAC đúng + sai

---

### [WMS-MODERN-4] Optimistic Locking cho SHIPPED Transition
- **Mức ưu tiên:** MEDIUM
- **Effort:** 1 ngày
- **File cần sửa:**
  - `src/main/java/com/wms/dao/OrderDAO.java` (`updateOrderStatus` — thêm `updated_at` vào WHERE)
  - `src/main/java/com/wms/dao/OutboundDAO.java` (`updateStatus` tương tự)
- **Mô tả:** 2 actor cùng trigger SHIPPED (Warehouse `updateStatus` + Sales webhook) → race condition. Cần optimistic lock dựa trên `updated_at`.
- **Code mẫu:**
  ```sql
  UPDATE orders SET status = ?, updated_at = NOW()
  WHERE order_id = ? AND updated_at = ?
  -- Nếu 0 rows affected → throw OptimisticLockException
  ```
- **Acceptance criteria:**
  - [ ] 2 request đồng thời update SHIPPED → 1 thành công, 1 fail với OptimisticLockException
  - [ ] Test concurrent với JUnit + ExecutorService
  - [ ] UI hiển thị message "Đơn đã được cập nhật bởi người khác, vui lòng refresh"

---

## Tech Debt / Cleanup (Backlog)

### [CLEANUP-1] Sửa Query Sai Cột trong SkuMappingDAO
- **Mức ưu tiên:** LOW
- **Effort:** 0.5 giờ
- **File:** `src/main/java/com/wms/dao/SkuMappingDAO.java` (method `findAllSkus`)
- **Mô tả:** Query `WHERE status = 'APPROVED'` nhưng bảng `products` không có cột `status` (chỉ có `active`). Sửa thành `WHERE active = 1` hoặc thêm cột `status` vào schema nếu muốn workflow duyệt SKU.
- **Acceptance criteria:** Query chạy không lỗi, trả về đúng SKU active.

### [CLEANUP-2] Implement `/business/inventory` (hiện đang trống)
- **Mức ưu tiên:** LOW
- **Effort:** 0.5 ngày
- **File:** `src/main/java/com/wms/controller/inventory/InventoryServlet.java`
- **Mô tả:** `InventoryServlet.doGet()` chỉ render `"[]"`. Cần query thật:
  ```sql
  SELECT i.*, p.sku_code, p.product_name, w.warehouse_name
  FROM inventory i 
  JOIN products p ON i.product_id = p.product_id
  JOIN warehouses w ON i.warehouse_id = w.warehouse_id
  ```
- **Acceptance criteria:** Hiển thị bảng tồn kho với filter theo kho + SKU.

### [CLEANUP-3] Refactor `BusinessProfileServlet.updatePassword`
- **Mức ưu tiên:** LOW
- **Effort:** 0.5 ngày
- **File:** `src/main/java/com/wms/controller/dashboard/BusinessProfileServlet.java`
- **Mô tả:** Hiện `updatePassword` chỉ trả "Vui lòng xác minh OTP". Cần tích hợp `PasswordChangeOtpServlet` đã có sẵn ở `/password-change-otp`.
- **Acceptance criteria:** User đổi password phải qua OTP flow đầy đủ.

### [CLEANUP-4] Xóa `CUSTOMER` Role Constant (dead code)
- **Mức ưu tiên:** LOW
- **Effort:** 15 phút
- **File:** `src/main/java/com/wms/util/AppConstants.java:43`
- **Mô tả:** `ROLE_CUSTOMER` tồn tại trong constant nhưng không có trong schema ENUM, không có UI/role nào dùng.
- **Acceptance criteria:** Xóa constant, không ảnh hưởng compile.

### [CLEANUP-5] Migrate toàn bộ code sang bảng mới (loại bỏ bảng legacy)
- **Mức ưu tiên:** LOW
- **Effort:** 3 ngày
- **File:** Nhiều file trong `dao/`, `service/`, `controller/`
- **Mô tả:** Hiện có 4 cặp bảng song sinh:
  - `inbound_orders` (legacy) ↔ `warehouse_receipts` (mới)
  - `outbound_orders` (legacy) ↔ `warehouse_issues` (mới)
  - `physical_inventories` (legacy) ↔ `stocktakes` (mới)
  - `return_orders` (legacy) ↔ `rma_requests` (mới)
  Code mới gần như chỉ dùng bảng legacy → cần migrate hoặc xóa bảng mới.
- **Acceptance criteria:** Chỉ còn 1 bảng cho mỗi domain, query thống nhất.

---

## Lịch trình đề xuất (4 tuần)

| Tuần | Task | Owner |
|---|---|---|
| Tuần 1 | HOTFIX-1, HOTFIX-2, HOTFIX-5 (3 task nhanh, có thể chạy song song) | Backend Lead |
| Tuần 2 | HOTFIX-3, HOTFIX-4 (tách Maker-Checker + Transfer movement) | Backend Lead |
| Tuần 3 | MULTICHANNEL-1, MULTICHANNEL-3 (SKU mapping + Event-driven ledger) | Backend Lead + 1 Dev |
| Tuần 4 | WMS-MODERN-1, WMS-MODERN-2, WMS-MODERN-3, WMS-MODERN-4 | Full team |

---

## References

- **Báo cáo As-Built đầy đủ:** `.cursor/plans/as-built_audit_b2c_wms_hub_af51902d.plan.md`
- **Bản phản biện chuyên sâu:** `Phản biện Luồng Nghiệp Vụ WMS Omnichannel.md`
- **Schema:** `src/main/resources/schema.sql`
- **Web.xml:** `src/main/webapp/WEB-INF/web.xml`
