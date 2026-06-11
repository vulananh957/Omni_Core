---
name: File Classification by Branch
overview: Liệt kê 150 file theo 5 nhánh. Khi đẩy đúng và merge theo thứ tự, main sẽ y hệt phiên bản đang có trên máy.
todos:
  - id: compile
    content: Tổng hợp từ 5 subagent + xác minh bằng git diff thực tế
    status: completed
---

# Phân Loại File Theo 5 Nhánh — OmniCore WMS

## Tổng Quan

- Cả 5 nhánh đều có **cùng 150 file** — không có file nào thiếu trên nhánh nào.
- Sự khác biệt nằm ở **nội dung** bên trong các file giống nhau.
- Thứ tự merge đúng: `auth-admin` → `business-manager` → `sales-integration` → `warehouse-inbound` → `warehouse-outbound`
- Mỗi nhánh sau merge vào sẽ **override** file cùng tên từ nhánh trước đó. Vì vậy file gửi lên nhánh nào sẽ quyết định phiên bản cuối cùng.

---

## feature-auth-admin (Nhánh nền tảng)

Chứa hệ thống xác thực và quản lý người dùng.

### Filter
- `src/main/java/com/wms/filter/AuthFilter.java`
- `src/main/java/com/wms/filter/EncodingFilter.java`

### Auth Servlet (7 file)
- `src/main/java/com/wms/controller/auth/LoginServlet.java`
- `src/main/java/com/wms/controller/auth/OtpServlet.java`
- `src/main/java/com/wms/controller/auth/LogoutServlet.java`
- `src/main/java/com/wms/controller/auth/ForgotPasswordServlet.java`
- `src/main/java/com/wms/controller/auth/ResetPasswordServlet.java`
- `src/main/java/com/wms/controller/auth/PasswordChangeOtpServlet.java`

### Admin Servlet (4 file)
- `src/main/java/com/wms/controller/admin/UserManagementServlet.java`
- `src/main/java/com/wms/controller/admin/AdminProfileServlet.java`
- `src/main/java/com/wms/controller/admin/HealthCheckServlet.java`
- `src/main/java/com/wms/controller/admin/LazadaAuthCallbackServlet.java`

### Service (4 file)
- `src/main/java/com/wms/service/auth/AuthService.java`
- `src/main/java/com/wms/service/auth/AuthException.java`
- `src/main/java/com/wms/service/auth/EmailService.java`
- `src/main/java/com/wms/service/user/UserService.java`

### DAO (2 file)
- `src/main/java/com/wms/dao/UserDAO.java`
- `src/main/java/com/wms/dao/RoleDAO.java`

### Model (2 file)
- `src/main/java/com/wms/model/User.java`
- `src/main/java/com/wms/model/Role.java`

### Base & Utils (4 file)
- `src/main/java/com/wms/controller/BaseController.java`
- `src/main/java/com/wms/util/AppConstants.java`
- `src/main/java/com/wms/util/DBConnection.java`
- `src/main/java/com/wms/util/DatabaseConfig.java`

### Auth JSP (5 file)
- `src/main/webapp/WEB-INF/views/auth/login.jsp`
- `src/main/webapp/WEB-INF/views/auth/otp.jsp`
- `src/main/webapp/WEB-INF/views/auth/forgot-password.jsp`
- `src/main/webapp/WEB-INF/views/auth/reset-password.jsp`
- `src/main/webapp/WEB-INF/views/auth/password-change-otp.jsp`

### Admin JSP (5 file)
- `src/main/webapp/WEB-INF/views/admin/users-management.jsp`
- `src/main/webapp/WEB-INF/views/admin/user-form.jsp`
- `src/main/webapp/WEB-INF/views/admin/admin-profile.jsp`
- `src/main/webapp/WEB-INF/views/admin/channels-configuration.jsp`
- `src/main/webapp/WEB-INF/views/admin/channel-create.jsp`

### Schema Initializer
- `src/main/java/com/wms/listener/SchemaInitListener.java` (phần seed roles, users, warehouse, categories, SKUs, orders — phiên bản đầy đủ nhất)

### web.xml
- `src/main/webapp/WEB-INF/web.xml` (toàn bộ servlet/filter mappings)

---

## feature-business-manager (Nhánh quản lý kinh doanh)

Chứa dashboard, quản lý kho, SKU, ledger/sổ cái, chuyển kho.

### Business Dashboard (4 file)
- `src/main/java/com/wms/controller/dashboard/BusinessDashboardServlet.java`
- `src/main/java/com/wms/controller/dashboard/BusinessProfileServlet.java`
- `src/main/webapp/WEB-INF/views/dashboard/business.jsp`
- `src/main/webapp/WEB-INF/views/dashboard/profile-settings.jsp`

### Warehouse Management (6 file)
- `src/main/java/com/wms/controller/warehouse/WarehouseServlet.java`
- `src/main/java/com/wms/controller/warehouse/WarehouseProfileServlet.java`
- `src/main/java/com/wms/dao/WarehouseDAO.java`
- `src/main/java/com/wms/model/Warehouse.java`
- `src/main/java/com/wms/model/Zone.java`
- `src/main/webapp/WEB-INF/views/warehouse/warehouse-profile.jsp`
- `src/main/webapp/WEB-INF/views/warehouse/warehouses.jsp`

### Transfer / Chuyển kho (3 file)
- `src/main/java/com/wms/controller/warehouse/WarehouseTransferServlet.java`
- `src/main/java/com/wms/dao/TransferDAO.java`
- `src/main/java/com/wms/service/warehouse/TransferService.java`

### Ledger / Sổ cái (4 file)
- `src/main/java/com/wms/controller/ledger/LedgerServlet.java`
- `src/main/java/com/wms/service/ledger/LedgerService.java`
- `src/main/java/com/wms/dao/LedgerDAO.java` (905 dòng — xử lý approve/reject 5 loại chứng từ)
- `src/main/webapp/WEB-INF/views/ledger/ledger.jsp`

### Channel Management (3 file)
- `src/main/java/com/wms/controller/admin/ChannelListServlet.java`
- `src/main/java/com/wms/controller/admin/ChannelConfigServlet.java`
- `src/main/java/com/wms/dao/ChannelDAO.java`

### SKU / Product Management (8 file)
- `src/main/java/com/wms/controller/sku/MasterSKUServlet.java`
- `src/main/java/com/wms/controller/warehouse/WarehouseMasterSKUServlet.java`
- `src/main/java/com/wms/service/product/ProductService.java`
- `src/main/java/com/wms/service/product/CategoryService.java`
- `src/main/java/com/wms/dao/ProductDAO.java`
- `src/main/java/com/wms/model/Product.java`
- `src/main/java/com/wms/model/Category.java`
- `src/main/java/com/wms/model/Channel.java`

### Warehouse Service (1 file)
- `src/main/java/com/wms/service/warehouse/WarehouseService.java`

### Returns (4 file)
- `src/main/java/com/wms/controller/warehouse/WarehouseReturnsServlet.java`
- `src/main/java/com/wms/service/warehouse/ReturnService.java`
- `src/main/java/com/wms/dao/ReturnDAO.java`
- `src/main/java/com/wms/model/ReturnOrder.java`
- `src/main/java/com/wms/model/ReturnItem.java`

### JSP bổ sung
- `src/main/webapp/WEB-INF/views/returns/warehouse-returns.jsp`
- `src/main/webapp/WEB-INF/views/transfer/warehouse-transfer.jsp`
- `src/main/webapp/WEB-INF/views/layout/admin-layout.jsp`
- `src/main/webapp/WEB-INF/views/layout/warehouse-layout.jsp`

---

## feature-sales-integration (Nhánh tích hợp bán hàng)

Chứa đơn hàng, SKU mapping, Lazada sync, channel products.

### Sales Servlet (6 file)
- `src/main/java/com/wms/controller/sales/SalesOrdersServlet.java`
- `src/main/java/com/wms/controller/sales/SalesOrderProcessingServlet.java`
- `src/main/java/com/wms/controller/sales/SalesChannelProductsServlet.java`
- `src/main/java/com/wms/controller/sales/OrderActionServlet.java`
- `src/main/java/com/wms/controller/sales/SalesProfileServlet.java`
- `src/main/java/com/wms/controller/sales/SalesSKUMappingServlet.java`

### Sales Service (4 file)
- `src/main/java/com/wms/service/sales/OrderService.java`
- `src/main/java/com/wms/service/sales/SkuMappingService.java`
- `src/main/java/com/wms/service/sales/ChannelService.java`
- `src/main/java/com/wms/service/lazada/LazadaFulfillmentService.java`

### Order DAO & Model (3 file)
- `src/main/java/com/wms/dao/OrderDAO.java` (phiên bản đầy đủ với JOIN shipping_details + users)
- `src/main/java/com/wms/model/Order.java` (phiên bản có thêm trường note)
- `src/main/java/com/wms/model/OrderItem.java`

### SKU Mapping (2 file)
- `src/main/java/com/wms/dao/SkuMappingDAO.java`
- `src/main/java/com/wms/model/SkuMapping.java`

### Channel Product (2 file)
- `src/main/java/com/wms/dao/ChannelProductDAO.java`
- `src/main/java/com/wms/model/ChannelProduct.java`

### Lazada Services (3 file)
- `src/main/java/com/wms/service/lazada/LazadaOrderService.java`
- `src/main/java/com/wms/service/lazada/LazadaRTSService.java`

### Inventory (2 file)
- `src/main/java/com/wms/controller/inventory/InventoryServlet.java`
- `src/main/java/com/wms/dao/InventoryDAO.java`

### Staff (2 file)
- `src/main/java/com/wms/controller/staff/StaffServlet.java`
- `src/main/webapp/WEB-INF/views/staff/staff.jsp`

### Sales JSP (5 file)
- `src/main/webapp/WEB-INF/views/sales/sales-orders.jsp`
- `src/main/webapp/WEB-INF/views/sales/order-processing.jsp`
- `src/main/webapp/WEB-INF/views/sales/channel-products.jsp`
- `src/main/webapp/WEB-INF/views/sales/sku-mapping.jsp`
- `src/main/webapp/WEB-INF/views/sales/sales-profile.jsp`

### Layout
- `src/main/webapp/WEB-INF/views/layout/sales-layout.jsp`
- `src/main/webapp/WEB-INF/views/layout/dashboard-layout.jsp`

### Category (1 file)
- `src/main/java/com/wms/controller/category/CategoryServlet.java`

---

## feature-warehouse-inbound (Nhánh nhập kho)

Chứa logic nhập kho, document center, kiểm kê.

### Inbound Core (5 file — hoàn toàn mới)
- `src/main/java/com/wms/controller/warehouse/WarehouseInboundServlet.java` (phiên bản đầy đủ với ProductService, WarehouseService, ObjectMapper)
- `src/main/java/com/wms/service/warehouse/InboundService.java` (184 dòng)
- `src/main/java/com/wms/dao/InboundDAO.java`
- `src/main/java/com/wms/model/InboundOrder.java`
- `src/main/java/com/wms/model/ReceiptNote.java`

### Inbound JSP (1 file)
- `src/main/webapp/WEB-INF/views/inbound/warehouse-inbound.jsp` (phiên bản đầy đủ)

### Document Center (2 file)
- `src/main/java/com/wms/controller/warehouse/WarehouseDocumentsServlet.java`
- `src/main/webapp/WEB-INF/views/warehouse/warehouse-documents.jsp` (2496 dòng)

### Inventory Check (2 file)
- `src/main/java/com/wms/controller/warehouse/WarehouseInventoryCheckServlet.java`
- `src/main/webapp/WEB-INF/views/inventory/warehouse-inventory-check.jsp`

### Inventory JSP
- `src/main/webapp/WEB-INF/views/inventory/inventory.jsp`

### SKU JSP (2 file)
- `src/main/webapp/WEB-INF/views/sku/master-sku.jsp`
- `src/main/webapp/WEB-INF/views/sku/warehouse-master-sku.jsp`

### Dashboard JSP
- `src/main/webapp/WEB-INF/views/dashboard/business.jsp`

### Warehouse Returns JSP
- `src/main/webapp/WEB-INF/views/returns/warehouse-returns.jsp`

### Outbound & Transfer JSP (bổ sung)
- `src/main/webapp/WEB-INF/views/outbound/warehouse-outbound.jsp`
- `src/main/webapp/WEB-INF/views/transfer/warehouse-transfer.jsp`

---

## feature-warehouse-outbound (Nhánh xuất kho — đầy đủ nhất)

Chứa toàn bộ code từ 4 nhánh trên + logic xuất kho. Đây là nhánh có phiên bản **hoàn chỉnh nhất** cho hầu hết file.

### Outbound Core (4 file)
- `src/main/java/com/wms/controller/warehouse/WarehouseOutboundServlet.java` (phiên bản cuối cùng)
- `src/main/java/com/wms/service/warehouse/OutboundService.java`
- `src/main/java/com/wms/dao/OutboundDAO.java`
- `src/main/java/com/wms/model/OutboundOrder.java`
- `src/main/java/com/wms/model/OutboundItem.java`

### Outbound JSP (1 file)
- `src/main/webapp/WEB-INF/views/outbound/warehouse-outbound.jsp`

---

## File Chung Còn Lại (Đẩy Lên Nhánh Nào Cũng Được)

Những file này **giống hệt nhau** trên tất cả 5 nhánh — không cần quan tâm gửi nhánh nào:

### Lazada SDK
- `src/main/java/com/lazada/lazop/api/LazopClient.java`
- `src/main/java/com/lazada/lazop/api/LazopRequest.java`
- `src/main/java/com/lazada/lazop/api/LazopResponse.java`
- `src/main/java/com/wms/util/LazadaAPIUtil.java`

### Resources
- `src/main/resources/schema.sql`
- `src/main/resources/seed_documents.sql`
- `src/main/resources/db.properties`
- `src/main/resources/mail.properties`

### Config
- `src/main/webapp/META-INF/context.xml`

### CSS/JS
- `src/main/webapp/assets/css/dashboard.css`
- `src/main/webapp/assets/css/main.css`
- `src/main/webapp/assets/js/main.js`

### Error Pages
- `src/main/webapp/WEB-INF/views/error/400.jsp`
- `src/main/webapp/WEB-INF/views/error/403.jsp`
- `src/main/webapp/WEB-INF/views/error/404.jsp`
- `src/main/webapp/WEB-INF/views/error/500.jsp`

### Category JSP
- `src/main/webapp/WEB-INF/views/category/categories.jsp`

### Root
- `pom.xml`
- `README.md`
- `.gitignore`

---

## Cách Merge Đúng Thứ Tự

```bash
# 1. Đẩy code đúng lên từng nhánh
git checkout feature-auth-admin && git push
git checkout feature-business-manager && git push
git checkout feature-sales-integration && git push
git checkout feature-warehouse-inbound && git push
git checkout feature-warehouse-outbound && git push

# 2. Merge theo thứ tự vào main
git checkout main

git merge feature-auth-admin          # 1. Base auth
git merge feature-business-manager    # 2. + kinh doanh/kho/ledger
git merge feature-sales-integration   # 3. + bán hàng/Lazada
git merge feature-warehouse-inbound   # 4. + nhập kho
git merge feature-warehouse-outbound  # 5. + xuất kho (cuối cùng)
```

Khi merge xong, `main` sẽ y hệt phiên bản đang có trên máy. Mỗi nhánh sau override file cùng tên từ nhánh trước, nên `warehouse-outbound` (merge cuối cùng) quyết định phiên bản cuối cùng cho hầu hết file.

## 1. feature/warehouse-inbound (10 files)
thành viên 5: glpat-Qq3eZQeKooAHgVeueEYisWM6MQpvOjEKdTpteXdmdA8.01.170toecna
username: trung3625 (ductrung3625@gmail.com)


### Servlet
- `src/main/java/com/wms/controller/warehouse/WarehouseInboundServlet.java`
  HTTP handler GET/POST `/warehouse/inbound`. Xu ly 3 action: `create` (tao yeu cau nhap), `confirm` (xac nhan bat dau nhan hang, PENDING → IN_PROGRESS), `receive` (ghi nhan hang thuc nhan, tao ledger entry).

### Service
- `src/main/java/com/wms/service/warehouse/InboundService.java`
  Business logic: tao don, xac nhan, ghi nhan hang, goi InventoryDAO de cap nhat ton kho.

### DAO
- `src/main/java/com/wms/dao/InboundDAO.java`
  CRUD bang `inbound_orders` va `inbound_items`, generate ma IN-YYYYMMDD-XXX, tim theo status.

### Models
- `src/main/java/com/wms/model/InboundOrder.java`
  Domain entity cho yeu cau nhap kho (goods receipt note). Thuoc tinh: inboundId, inboundCode, supplierName, warehouseId, status (PENDING/IN_PROGRESS/RECEIVED/CANCELLED), expectedDate, receivedDate, creator, notes.
- `src/main/java/com/wms/model/ReceiptNote.java`
  Domain entity cho tung dong item trong phieu nhap. Thuoc tinh: expected vs. received/accepted/rejected quantities.

### Views
- `src/main/webapp/WEB-INF/views/inbound/warehouse-inbound.jsp`
  Giao dien chinh cua man hinh Nhap Kho (2,496 dong). Chua KPI cards, filter tabs, danh sach don, modal tao don, modal xac nhan nhan hang.

### Layout
- `src/main/webapp/WEB-INF/views/layout/warehouse-layout.jsp` (chi phan nav "Nhập kho" o dong 72-81)
  Them menu item "Nhập kho" vao sidebar cho nhan vien kho.

### Database
- `src/main/resources/schema.sql` (phan `inbound_orders`, `inbound_items` table DDL)
  Tao bang `inbound_orders` (id, inbound_code, supplier_name, warehouse_id, status, expected_date, received_date, notes) va `inbound_items` (id, inbound_order_id, sku_code, sku_name, expected_qty, received_qty, accepted_qty, rejected_qty).
- `src/main/resources/seed_documents.sql` (dong 26)
  Comment seed cho inbound order PENDING.

### Schema Initializer
- `src/main/java/com/wms/listener/SchemaInitListener.java` (dong 436-443)
  Tao bang `inbound_orders` va `inbound_items` khi khoi dong ung dung.

### web.xml
- `src/main/webapp/WEB-INF/web.xml` (dong 213-218)
  Mapping: `WarehouseInboundServlet` → `/warehouse/inbound`.

---

## 2. feature/warehouse-outbound (10 files)
thành viên 4: glpat-aloTgOu8ba1lRFRB3HLacGM6MQpvOjEKdTpuNG03OA8.01.171qbcwy9
username: lamanhnguyen0910 (lamanhnguyen0910@gmail.com)
t

### Servlet
- `src/main/java/com/wms/controller/warehouse/WarehouseOutboundServlet.java`
  HTTP handler `/warehouse/outbound`. Xu ly cac action: `list`, `create` (tao yeu cau xuat), `pick` (in phieu pick), `pack` (dong goi), `ready` (san sang giao), `dispatch` (xuat kho + tru ton).

### Service
- `src/main/java/com/wms/service/warehouse/OutboundService.java`
  Business logic: tao don xuat, cap nhat trang thai pick/pack/dispatch, goi LedgerDAO de xu ly GI approval va tru ton kho.

### DAO
- `src/main/java/com/wms/dao/OutboundDAO.java`
  CRUD bang `outbound_orders` va `outbound_items`, generate ma OUT-YYYYMMDD-XXX.

### Models
- `src/main/java/com/wms/model/OutboundOrder.java`
  Domain entity cho yeu cau xuat kho. Thuoc tinh: outboundId, outboundCode, orderId (nguon tu don ban hang), warehouseId, status (PENDING/PICKING/PACKED/READY/DISPATCHED/CANCELLED), pickedBy, packedBy, notes.
- `src/main/java/com/wms/model/OutboundItem.java`
  Domain entity cho tung dong item trong phieu xuat.

### Views
- `src/main/webapp/WEB-INF/views/outbound/warehouse-outbound.jsp`
  Giao dien chinh cua man hinh Xuat Kho. Chua KPI outbound, filter tabs, danh sach don, modal tao don, modal cap nhat trang thai.

### Layout
- `src/main/webapp/WEB-INF/views/layout/warehouse-layout.jsp` (chi phan nav "Xuất kho" o dong 82-86)
  Them menu item "Xuất kho" vao sidebar cho nhan vien kho.

### Database
- `src/main/resources/schema.sql` (phan `outbound_orders`, `outbound_items`, `picking_sheets`, `delivery_notes` table DDL)
  Tao 4 bang: `outbound_orders`, `outbound_items`, `picking_sheets`, `delivery_notes`.
- `src/main/resources/seed_documents.sql` (dong 31)
  Comment seed cho outbound order PENDING.

### Schema Initializer
- `src/main/java/com/wms/listener/SchemaInitListener.java` (dong 444-455)
  Tao 4 bang lien quan outbound khi khoi dong.

### web.xml
- `src/main/webapp/WEB-INF/web.xml` (dong 223-228)
  Mapping: `WarehouseOutboundServlet` → `/warehouse/outbound`.

---

## 3. feature/business-manager (35 files)
thành viên 2: tôi
username: vulananh957 (vulananh957@gmail.com)
glpat-JoBb0OcBmWfvJ4RLV5z9-mM6MQpvOjEKdTpteXdnZA8.01.1703e3bnp


### Business Dashboard
- `src/main/java/com/wms/controller/dashboard/BusinessProfileServlet.java`
  Servlet cho trang tieu de/bieu do cua Business Manager tai `/business/profile`.
- `src/main/java/com/wms/controller/admin/AdminProfileServlet.java`
  Servlet cho trang profile (dung chung voi admin, nhung co the chuyen sang business-manager neu can).
- `src/main/webapp/WEB-INF/views/dashboard/business.jsp`
  Trang dashboard chinh cho Business Manager. Hien thi KPI doanh thu, don hang, tra hang, ty le роста, bieu do theo ngay/kenh/san pham. View nay goi OrderService truc tiep de lay so lieu SQL.
- `src/main/webapp/WEB-INF/views/dashboard/profile-settings.jsp`
  Trang cai dat profile cho Business Manager.

### SKU Management
- `src/main/java/com/wms/controller/sku/MasterSKUServlet.java`
  Servlet CRUD cho Master SKU tai `/sku/master`. Action: `list`, `create`, `edit`, `approve`, `reject`, `delete`.
- `src/main/java/com/wms/service/sku/MasterSKUService.java`
  Business logic: tao SKU PENDING, approve (gan zone), reject, delete.
- `src/main/java/com/wms/dao/SkuDAO.java`
  CRUD bang `skus` voi cac truong: sku_id, sku_code, sku_name, category_id, status (PENDING/ACTIVE/INACTIVE), zone_id, safety_stock, image_url, ...
- `src/main/java/com/wms/model/Sku.java`
  Domain entity cho Master SKU.
- `src/main/webapp/WEB-INF/views/sku/warehouse-master-sku.jsp`
  Giao dien quan ly Master SKU: danh sach, tao, chi tiet, phe duyet, PDF.
- `src/main/webapp/WEB-INF/views/sku/master-sku.jsp`
  Mot view SKU khac (co the la phien ban cu hon, can kiem tra noi dung).

### Zone & Warehouse Management
- `src/main/java/com/wms/controller/warehouse/WarehouseServlet.java`
  Servlet CRUD cho kho tai `/warehouse/list`. Action: `list`, `create`, `edit`, `delete`.
- `src/main/java/com/wms/dao/WarehouseDAO.java`
  CRUD bang `warehouses` va `zones`. Chi dinh zone theo SKU khi approve.
- `src/main/java/com/wms/model/Warehouse.java`
  Domain entity cho Warehouse.
- `src/main/java/com/wms/model/Zone.java`
  Domain entity cho Zone.
- `src/main/webapp/WEB-INF/views/warehouse/warehouse-profile.jsp`
  Giao dien quan ly kho.
- `src/main/webapp/WEB-INF/views/layout/warehouse-layout.jsp` (phan category-nav)
  Navigation phan loai/zone trong warehouse layout.

### Ledger / Sổ Cái (Maker-Checker Approval)
- `src/main/java/com/wms/controller/ledger/LedgerServlet.java`
  Servlet tai `/business/ledger`. Hien thi tat ca loai chung tu (Nhap/Xuat/Chuyen/Dieu chinh/Tra) voi nut phe duyet/ty tu choi (maker-checker).
- `src/main/java/com/wms/service/ledger/LedgerService.java`
  Business logic wrapper cho LedgerDAO.
- `src/main/java/com/wms/dao/LedgerDAO.java`
  DAO chinh cho chuc nang sổ cái: lay danh sach chung tu theo loai (INBOUND/OUTBOUND/TRANSFER/ADJUSTMENT/RETURN), cap nhat trang thai (APPROVED/REJECTED), ghi inventory_ledger, gui notification. Day la mot trong nhung file quan trong nhat — da su dung boi 4/5 nhanh.
- `src/main/webapp/WEB-INF/views/ledger/ledger.jsp`
  Giao dien Sổ Cái toan cuc: tab chon loai chung tu, filter, danh sach, modal chi tiet, modal phe duyet, PDF.

### Transfer (Chuyen Kho)
- `src/main/java/com/wms/controller/warehouse/WarehouseTransferServlet.java`
  Servlet xu ly chuyen kho giua cac kho/nhan vien.
- `src/main/webapp/WEB-INF/views/transfer/warehouse-transfer.jsp`
  Giao dien chuyen kho.

### Channel Configuration (Admin/Business)
- `src/main/java/com/wms/controller/admin/ChannelListServlet.java`
  Servlet danh sach kenh tai `/admin/channels`.
- `src/main/java/com/wms/controller/admin/ChannelConfigServlet.java`
  Servlet cau hinh kenh tai `/admin/channel/config`.
- `src/main/java/com/wms/dao/ChannelDAO.java`
  CRUD bang `channels` (kenh Lazada/Shopee/TikTok).
- `src/main/webapp/WEB-INF/views/admin/channels-configuration.jsp`
  Trang cau hinh cac kenh.
- `src/main/webapp/WEB-INF/views/admin/channel-create.jsp`
  Form tao kenh.

### Database
- `src/main/resources/schema.sql` (phan `skus`, `categories`, `zones`, `warehouses`, `inventory_ledger`, `channels`, `picking_sheets`, `delivery_notes`)
  Tat ca DDL cho bang master SKU, zone, warehouse, inventory_ledger, channels.
- `src/main/resources/seed_documents.sql`
  Seed data cho categories va channels.

### Schema Initializer
- `src/main/java/com/wms/listener/SchemaInitListener.java` (dong 1-435, 444-...)
  Tao tat ca bang master data: categories, warehouses, zones, channels, inventory_ledger, skus (phan business-manager).

### web.xml
- `src/main/webapp/WEB-INF/web.xml` (phan servlet mappings cho warehouse/list, business/ledger, sku/master, admin/channels, warehouse/transfer)

### Profile & Layout
- `src/main/webapp/WEB-INF/views/admin/admin-profile.jsp` (chi phan Business Manager — can tach phan route theo role)
- `src/main/webapp/WEB-INF/views/layout/admin-layout.jsp` (dung chung, chi commit khi business-manager can)

---

## 4. feature/auth-admin (43 files)
thành viên 1: pmq07072005 (email: pmq07072005@gmail.com)
glpat-FDRZ_E0iHfHViAl3jN47kGM6MQpvOjEKdTpteXdmZw8.01.171kr4mmf
### Security Filters
- `src/main/java/com/wms/filter/AuthFilter.java`
  Filter kiem tra session SESSION_USER, danh cho tat ca request ngoai tru /auth/* va /assets/*.
- `src/main/java/com/wms/filter/EncodingFilter.java`
  Filter set UTF-8 encoding cho moi request.

### Auth Servlets
- `src/main/java/com/wms/controller/auth/LoginServlet.java`
  GET /login (hien form), POST /login (xac thuc BCrypt, chuyen huong sang OTP).
- `src/main/java/com/wms/controller/auth/OtpServlet.java`
  Tao ma 6 chu so, gui email, xac minh OTP (5 phut het han, 60s giua lan gui).
- `src/main/java/com/wms/controller/auth/LogoutServlet.java`
  Invalidate session, chuyen huong ve /login.
- `src/main/java/com/wms/controller/auth/ForgotPasswordServlet.java`
  Gui OTP reset mat khau qua email.
- `src/main/java/com/wms/controller/auth/ResetPasswordServlet.java`
  Xac minh OTP + dat mat khau moi (BCrypt).
- `src/main/java/com/wms/controller/auth/PasswordChangeOtpServlet.java`
  Gui OTP khi nguoi dung dang nhap muon doi mat khau.

### Auth Services
- `src/main/java/com/wms/service/auth/AuthService.java`
  Xac thuc username/password BCrypt. Ham `login()`, `sendOtp()`, `verifyOtp()`, `initPasswordReset()`, `completePasswordReset()`. Tra ve typed AuthException.
- `src/main/java/com/wms/service/auth/AuthException.java`
  RuntimeException voi enum Reason (NOT_FOUND, WRONG_PASSWORD, ACCOUNT_LOCKED).
- `src/main/java/com/wms/service/auth/EmailService.java`
  Gui email SMTP (Jakarta Mail): credentials moi, ma OTP.

### Admin Servlets
- `src/main/java/com/wms/controller/admin/UserManagementServlet.java`
  CRUD tai khoan tai `/admin/users`. Action: list, create, edit, toggle-status. Tao random password + gui email.
- `src/main/java/com/wms/controller/admin/AdminProfileServlet.java`
  Profile admin: cap nhat ten, email, phone, username (kiem tra trung), OTP preference, doi mat khau (gui OTP truoc).
- `src/main/java/com/wms/controller/admin/HealthCheckServlet.java`
  Health check endpoint `/health` (JSON, danh cho load-balancer).
- `src/main/java/com/wms/controller/admin/LazadaAuthCallbackServlet.java`
  OAuth callback cho Lazada: exchange code lay token, luu vao bang channels.

### Services
- `src/main/java/com/wms/service/user/UserService.java`
  Business logic: search user, create (BCrypt hash), update, toggle active/inactive, generate random password, gui credentials email, update profile, update OTP preference.

### DAOs
- `src/main/java/com/wms/dao/UserDAO.java`
  CRUD bang `users`: find-by-username/email/id, find-all-filtered, find-by-roles, insert, update, toggle-status, update-profile, update-password, update-otp-preference, kiem tra trung username/email.
- `src/main/java/com/wms/dao/RoleDAO.java`
  CRUD bang `roles`: find-all, find-by-id.

### Models
- `src/main/java/com/wms/model/User.java`
  Domain entity: userId, username, passwordHash, fullName, email, phone, role/roleStr, roleId, warehouseId, active, otpPreference, createdAt.
- `src/main/java/com/wms/model/Role.java`
  Domain entity: roleId, roleName (ADMIN/MANAGER/WAREHOUSE_STAFF/SALES_STAFF), description.

### Base Controller
- `src/main/java/com/wms/controller/BaseController.java`
  Abstract base cho tat ca servlet: forward(), redirect(), flash error/success, isLoggedIn(), writeJson(), isNullOrEmpty().

### Constants
- `src/main/java/com/wms/util/AppConstants.java`
  Tap hop constant: session keys (SESSION_USER, SESSION_PENDING_OTP, ATTR_ERROR, ATTR_SUCCESS), role constants (ROLE_ADMIN, ROLE_MANAGER, ...), OTP expiry, Lazada API URLs.

### Schema Initializer
- `src/main/java/com/wms/listener/SchemaInitListener.java` (dong 1-150)
  Tao bang `roles` va `users` (voi cot phone, otp_preference, warehouse_id), seed 4 roles, seed default admin user (quanpm).
- `src/main/java/com/wms/listener/LoggingInitListener.java`
  JUL-to-SLF4J bridge cho Lazada SDK logging.

### Auth Views
- `src/main/webapp/WEB-INF/views/auth/login.jsp`
  Form dang nhap: username, password, hien thi loi.
- `src/main/webapp/WEB-INF/views/auth/otp.jsp`
  Form xac minh OTP 6 chu so, hien thi email da gui, countdown gui lai.
- `src/main/webapp/WEB-INF/views/auth/forgot-password.jsp`
  Form "Quen mat khau": nhap email/username.
- `src/main/webapp/WEB-INF/views/auth/reset-password.jsp`
  Form dat lai mat khau: nhap OTP + mat khau moi.
- `src/main/webapp/WEB-INF/views/auth/password-change-otp.jsp`
  Form OTP doi mat khau khi da dang nhap.

### Admin Views
- `src/main/webapp/WEB-INF/views/admin/users-management.jsp`
  Dashboard quan ly nguoi dung: danh sach, search, filter role/status, nut edit, toggle active.
- `src/main/webapp/WEB-INF/views/admin/user-form.jsp`
  Form tao/sua nguoi dung: username, full name, email, phone, role, active, password (chi khi tao moi).
- `src/main/webapp/WEB-INF/views/admin/admin-profile.jsp`
  Trang profile admin: thong tin, doi username, OTP preference, doi mat khau.
- `src/main/webapp/WEB-INF/views/admin/channels-configuration.jsp`
  Trang cau hinh kenh.
- `src/main/webapp/WEB-INF/views/admin/channel-create.jsp`
  Form tao kenh.
- `src/main/webapp/WEB-INF/views/layout/admin-layout.jsp`
  Template layout cho tat ca view admin.

### web.xml
- `src/main/webapp/WEB-INF/web.xml` (phan servlet mappings cho /login, /otp, /logout, /forgot-password, /reset-password, /password-change-otp, /admin/users, /admin/profile, /health, /auth/lazada/callback, /admin/channels, /admin/channel/config)
  Phan filter mappings: EncodingFilter, AuthFilter.

---

## 5. feature/sales-integration (35 files)
thành viên 3: nguyentungtiktik (email: nguyentung031205@gmail.com)
glpat-sRuZYY3U0zZG86cUQXD9LWM6MQpvOjEKdTpteXdmaQ8.01.171vep1m2

### Order Management (Ban hang)
- `src/main/java/com/wms/controller/sales/OrderActionServlet.java`
  Servlet xu ly action tren don hang tai `/sales/order/action`: approve, reject, cancel, update-shipping.
- `src/main/java/com/wms/service/sales/OrderService.java`
  Business logic: tao don (tu form hoac Lazada sync), auto-tao outbound khi approve, tinh doanh thu, KPI dashboard. Chi chon: OrderService goi OutboundService khi approve don hang.
- `src/main/java/com/wms/dao/OrderDAO.java`
  CRUD bang `orders` va `order_items`. Lay dashboard KPI, chi tiet don, loc theo status/channel/date.
- `src/main/java/com/wms/model/Order.java`
  Domain entity cho don hang.
- `src/main/java/com/wms/model/OrderItem.java`
  Domain entity cho tung mat hang trong don.

### SKU Mapping (Tich hop Marketplace)
- `src/main/java/com/wms/controller/sales/SalesSKUMappingServlet.java`
  Servlet CRUD cho SKU mapping tai `/sales/sku-mapping`: list, create, edit, delete, sync-price, sync-stock.
- `src/main/java/com/wms/service/sales/SkuMappingService.java`
  Business logic: tao/update/sync gia/gia von/stock giua master SKU va channel SKU. Doc nguoc lai tu model.
- `src/main/java/com/wms/dao/SkuMappingDAO.java`
  CRUD bang `sku_mappings`. Tim theo warehouse/channel/sku. Chi chon: SkuMappingDAO goi InventoryDAO de sync stock.

### Sales Staff Profile
- `src/main/java/com/wms/controller/sales/SalesProfileServlet.java`
  Profile cho nhan vien ban hang tai `/sales/profile`.
- `src/main/webapp/WEB-INF/views/sales/sales-profile.jsp`
  View profile nhan vien ban hang.

### Lazada Integration
- `src/main/java/com/wms/service/lazada/LazadaOrderService.java`
  Lay danh sach don tu Lazada API, convert sang Order entity, insert/update vao DB.
- `src/main/java/com/wms/service/lazada/LazadaRTSService.java`
  Cap nhat "Ready to Ship" cho don Lazada.
- `src/main/java/com/wms/util/LazadaAPIUtil.java`
  Utility cho viec goi API Lazada: sign request HMAC-SHA256, build URL, parse JSON response.
- `src/main/java/com/wms/scheduler/LazadaSyncScheduler.java`
  Scheduled task chay deu (mac dinh 5 phut) de dong bo don tu Lazada. Doc config tu context-param trong web.xml.
- `src/main/java/com/lazada/lazop/api/LazopResponse.java`
  Lazada Open Platform SDK — Lop response.
- `src/main/java/com/wms/controller/admin/LazadaAuthCallbackServlet.java`
  OAuth callback — lay authorization code, exchange token, luu vao bang channels.
- `src/main/java/com/wms/service/sales/ChannelService.java`
  Business logic cho channel management: lay token, kiem tra token expiry, refresh token.

### Sales Views
- `src/main/webapp/WEB-INF/views/sales/sales-orders.jsp`
  Trang chinh cua nhan vien ban hang: danh sach don, filter, action buttons.
- `src/main/webapp/WEB-INF/views/sales/sku-mapping.jsp`
  Trang quan ly SKU mapping: danh sach, tao, edit, nut sync gia/stock.
- `src/main/webapp/WEB-INF/views/sales/channel-products.jsp`
  Trang xem san pham theo kenh.
- `src/main/webapp/WEB-INF/views/layout/sales-layout.jsp`
  Layout template cho tat ca view nhan vien ban hang.

### Inventory (Lien quan Sales)
- `src/main/java/com/wms/controller/inventory/InventoryServlet.java`
  Servlet tai `/inventory/list`: hien thi ton kho, filter theo warehouse/zone/SKU, export Excel.
- `src/main/java/com/wms/dao/InventoryDAO.java`
  CRUD bang `inventory`. Lay ton kho hien tai, loc, tong hop. Chi chon: Phuong thuc `addInventory()` duoc goi boi InboundService khi nhap kho (lien quan feature/warehouse-inbound).
- `src/main/webapp/WEB-INF/views/inventory/inventory.jsp`
  Giao dien quan ly ton kho.

### Category Management
- `src/main/java/com/wms/controller/category/CategoryServlet.java`
  Servlet CRUD cho categories tai `/category/list`.
- `src/main/java/com/wms/dao/CategoryDAO.java`
  CRUD bang `categories`.
- `src/main/webapp/WEB-INF/views/category/category-management.jsp`
  Giao dien quan ly danh muc san pham.

### Database
- `src/main/resources/schema.sql` (phan `orders`, `order_items`, `sku_mappings`, `channels`)
  Tao 4 bang: orders, order_items, sku_mappings, channels.
- `src/main/resources/seed_documents.sql` (phan seed orders)
  Seed data cho orders.

### Schema Initializer
- `src/main/java/com/wms/listener/SchemaInitListener.java` (dong 150-435)
  Tao bang orders, order_items, sku_mappings, channels, inventory khi khoi dong.

### web.xml
- `src/main/webapp/WEB-INF/web.xml` (phan servlet mappings cho /sales/order/action, /sales/sku-mapping, /sales/profile, /inventory/list, /category/list, /auth/lazada/callback, /lazada/sync)
  Phan context-param cho Lazada sync (enabled, interval).

---

## 6. Shared / Cross-Branch Files

Nhung file nay lien quan den nhieu hon mot nhanh. Can commit vao **nhanh chinh** (main/develop) hoac commit cung voi **nhanh nao can tien** trong danh sach duoi day:

| File | Branches lien quan | Ghi chu |
|---|---|---|
| `src/main/webapp/WEB-INF/web.xml` | Tat ca 5 nhanh | Chua mappings cho tat ca servlet. Moi nhanh them phan servlet mapping cua minh. Can merge truoc khi deploy. |
| `src/main/webapp/assets/css/dashboard.css` | Tat ca 5 nhanh | CSS dung chung cho tat ca layout. Neu chi sua CSS rieng, commit vao nhanh cua minh. |
| `src/main/webapp/assets/js/main.js` | Tat ca 5 nhanh | JS dung chung: password toggle, sidebar, auto-dismiss alerts, confirm actions. |
| `src/main/java/com/wms/util/DatabaseConfig.java` | Tat ca 5 nhanh | DB config: env var override. Khong can sua. |
| `src/main/java/com/wms/util/StatusLabelService.java` | feature/warehouse-inbound, feature/warehouse-outbound, feature/sales-integration | Dung chung de hien thi nhan trang thai. Neu sua, commit vao nhanh nao can tien. |
| `src/main/java/com/wms/model/ChannelProduct.java` | feature/sales-integration, feature/business-manager | Dung chung cho channel products. |
| `src/main/java/com/wms/model/ReturnOrder.java` + `ReturnItem.java` | feature/warehouse-outbound, feature/sales-integration | Quan ly tra hang. Lien quan den xuat kho va don hang. |
| `src/main/java/com/wms/controller/warehouse/WarehouseReturnsServlet.java` | feature/warehouse-inbound, feature/warehouse-outbound | QC return center — xu ly nhan hang tra sau kiem tra chat luong. |
| `src/main/java/com/wms/service/warehouse/ReturnService.java` | feature/warehouse-outbound, feature/sales-integration | Business logic tra hang. |
| `src/main/java/com/wms/dao/ReturnDAO.java` | feature/warehouse-outbound, feature/sales-integration | CRUD bang returns. |
| `src/main/webapp/WEB-INF/views/returns/warehouse-returns.jsp` | feature/warehouse-inbound, feature/warehouse-outbound | View tra hang — co phan "Tiep nhan hang sau QC" lien quan inbound. |
| `src/main/webapp/WEB-INF/views/warehouse/warehouse-documents.jsp` | feature/warehouse-inbound, feature/warehouse-outbound, feature/business-manager | Document center: tab GRN (inbound), GI (outbound), Transfer, Adjustment, Return. |
| `src/main/webapp/WEB-INF/views/warehouse/warehouse-documents.jsp` | feature/warehouse-inbound, feature/warehouse-outbound | Document center: tab GRN (inbound) va GI (outbound). |
| `src/main/java/com/wms/dao/LedgerDAO.java` | feature/warehouse-inbound, feature/warehouse-outbound, feature/business-manager | Sổ cái — xu ly approve/reject tat ca loai chung tu. La DIEM CHENH giua 4/5 nhanh. RUT GON: LedgerDAO xu ly APPROVED/REJECTED cho INBOUND, OUTBOUND, TRANSFER, ADJUSTMENT, RETURN. No ghi vao inventory_ledger va goi InventoryDAO. |
| `src/main/java/com/wms/service/ledger/LedgerService.java` | feature/warehouse-inbound, feature/warehouse-outbound, feature/business-manager | Wrapper service cho LedgerDAO. |
| `src/main/java/com/wms/controller/warehouse/WarehouseDocumentsServlet.java` | feature/warehouse-inbound, feature/warehouse-outbound | Servlet cho trang Document Center. |
| `src/main/java/com/wms/service/warehouse/WarehouseService.java` | feature/warehouse-inbound, feature/warehouse-outbound | Dung chung cho warehouse operations. |
| `src/main/java/com/wms/controller/warehouse/WarehouseProfileServlet.java` | feature/warehouse-inbound, feature/warehouse-outbound, feature/business-manager | Profile cua warehouse. |
| `src/main/webapp/WEB-INF/views/staff/staff.jsp` | feature/auth-admin | Staff management page. |
| `src/main/java/com/wms/controller/staff/StaffServlet.java` | feature/auth-admin | Servlet cho staff management. |
| `src/main/webapp/WEB-INF/views/error/400.jsp`, `403.jsp`, `500.jsp` | Tat ca 5 nhanh | Error pages. |
| `src/main/java/com/wms/controller/admin/ChannelListServlet.java` + `ChannelConfigServlet.java` | feature/sales-integration, feature/business-manager | Channel config — nhung admin servlet nay cung lien quan den sales. |

---

## 7. Thu Tu Commit De Tranh Chen Lech

```
1. feature/auth-admin          (truoc tien — tao user/role/AuthFilter)
2. feature/business-manager    (sau auth-admin — dashboard, ledger, warehouse, SKU)
3. feature/sales-integration   (sau business-manager — orders, SKU mapping, Lazada)
4. feature/warehouse-inbound   (sau sales-integration — inbound orders)
5. feature/warehouse-outbound  (cuoi cung — outbound orders)
```

Lý do: inbound/outbound can ledger (business-manager) va orders (sales-integration) da ton tai. Auth filter can ton tai truoc tat ca cac route.

### Chu y ve LedgerDAO va InventoryDAO
Day la 2 file "diem cham" — duoc su dung boi nhieu nhanh nhat:
- **LedgerDAO** — doc/ghi chung tu, approve/reject, ghi ledger entries
- **InventoryDAO** — doc/ghi ton kho, duoc goi boi InboundService, OutboundService, SkuMappingService, LedgerDAO

Neu co chen lech tren 2 file nay, can merge tay vao nhanh chinh truoc khi commit tung nhanh.
