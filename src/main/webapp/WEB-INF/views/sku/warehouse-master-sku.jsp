<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ page import="com.wms.model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="com.wms.util.JsonUtil" %>
<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    if (products == null) products = java.util.Collections.emptyList();

    String productsJson = JsonUtil.toJson(products);
    request.setAttribute("productsJson", productsJson);
%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sku--warehouse-master-sku.css"/>

<!-- ══ STATS SECTION ═════════════════════════════════════════ -->
<div class="stats-grid-3" style="grid-template-columns: repeat(5, 1fr);" id="statsGrid">
    <!-- Card: Total Products -->
    <div class="sku-card card-navy">
        <div class="sku-card__icon">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg>
        </div>
        <div class="sku-card__info">
            <div class="sku-card__lbl">Sản phẩm trong kho</div>
            <div class="sku-card__val" id="stat-total-skus">0</div>
        </div>
    </div>

    <!-- Card: Total available stock -->
    <div class="sku-card card-emerald">
        <div class="sku-card__icon">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><polyline points="7 11 11 15 16 9"/></svg>
        </div>
        <div class="sku-card__info">
            <div class="sku-card__lbl">Tồn khả dụng</div>
            <div class="sku-card__val" id="stat-total-stock">0</div>
        </div>
    </div>

    <!-- Card: Pending approval (always 0 in main: no approval workflow) -->
    <div class="sku-card card-yellow">
        <div class="sku-card__icon">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
        </div>
        <div class="sku-card__info">
            <div class="sku-card__lbl">Chờ duyệt</div>
            <div class="sku-card__val" id="stat-pending-approval">0</div>
        </div>
    </div>

    <!-- Card: Suspended/rejected (always 0 in main) -->
    <div class="sku-card card-red">
        <div class="sku-card__icon">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        </div>
        <div class="sku-card__info">
            <div class="sku-card__lbl">Bị từ chối / tạm dừng</div>
            <div class="sku-card__val" id="stat-suspended">0</div>
        </div>
    </div>

    <!-- Card: Fill rate -->
    <div class="sku-card card-orange">
        <div class="sku-card__icon">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="19" y1="5" x2="5" y2="19"/><circle cx="6.5" cy="6.5" r="2.5"/><circle cx="17.5" cy="17.5" r="2.5"/></svg>
        </div>
        <div class="sku-card__info">
            <div class="sku-card__lbl">Tỷ lệ lấp đầy</div>
            <div class="sku-card__val" id="stat-fill-rate">0%</div>
        </div>
    </div>
</div>

<!-- ══ TOOLBAR SECTION ═══════════════════════════════════════ -->
<div class="toolbar-wrap">
    <!-- Search -->
    <div class="search-input-wrap">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"></svg>
        <input type="text" placeholder="Tìm theo SKU hoặc tên sản phẩm..." id="skuSearchInput"/>
    </div>
    
    <!-- Category select -->
    <div class="select-wrap">
        <select id="skuCategorySelect">
            <option>Tất cả</option>
            <c:forEach var="c" items="${categories}">
                <option><c:out value="${c.categoryName}"/></option>
            </c:forEach>
        </select>
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></svg>
    </div>

    <!-- Zone Status Filter -->
    <div class="select-wrap">
        <select id="skuZoneStatusSelect">
            <option value="all">Tất cả trạng thái Zone</option>
            <option value="unassigned">Chưa gán Zone</option>
            <option value="assigned">Đã gán Zone</option>
        </select>
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></svg>
    </div>
    
    <!-- Fixed warehouse label -->
    <div id="myWarehouseLabel" style="display: flex; align-items: center; gap: 8px; padding: 8px 14px; background: rgba(16,55,92,0.05); border: 1px solid rgba(16,55,92,0.12); border-radius: calc(var(--radius-btn) - 2px); font-size: 13px; font-weight: 600; color: var(--navy);">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
        <span id="myWarehouseName">—</span>
    </div>

    <!-- Export CSV button -->
    <button class="btn-toolbar" id="btnExportCsv" title="Xuất CSV danh sách SKU">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
        Xuất CSV
    </button>
</div>

<!-- ══ TABLE SECTION ═════════════════════════════════════════ -->
<div class="table-card">
    <div class="table-scroll">
        <table class="sku-table">
            <thead>
                <tr>
                    <th style="width: 240px;">Sản phẩm (SKU & Tên)</th>
                    <th style="width: 130px;">Danh mục</th>
                    <th style="width: 110px; text-align: right;">Tồn tay</th>
                    <th style="width: 180px;">Khu vực cất hàng (Zone)</th>
                    <th style="width: 100px; text-align: right;">Định mức (Min/Max)</th>
                    <th style="width: 110px; text-align: center;">Trạng thái</th>
                    <th style="width: 130px;">Cập nhật</th>
                    <th style="width: 150px; text-align: center;">Thao tác</th>
                </tr>
            </thead>
            <tbody id="skuTableBody"></tbody>
        </table>
    </div>
    
    <div class="table-footer">
        <span class="table-footer__info" id="skuTableInfo">Hiển thị 0 / 0 SKU</span>
        <span style="margin-right:auto; margin-left:12px; font-size:11px; color:rgba(16,55,92,0.4); font-style:italic;">Danh sách chỉ đọc · Liên hệ Manager để chỉnh sửa thông tin sản phẩm</span>
        <div class="pagination" id="skuPagination"></div>
    </div>
</div>

<!-- ══ ZONE CONFIG MODAL (for Warehouse Staff) ═════════════════ -->
<div class="modal-overlay" id="configModalOverlay">
    <div class="modal-box">
        <div class="modal-hdr">
            <div>
                <h2 class="modal-title">Cấu hình lưu trữ</h2>
                <p class="modal-subtitle" id="config-sku-label">SKU-XXXX</p>
            </div>
            <button class="modal-close" id="configModalClose">&times;</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="config-product-id"/>

            <!-- Locked warehouse badge -->
            <div style="display:flex; align-items:center; gap:8px; padding:10px 14px; background:rgba(16,55,92,0.04); border:1px solid rgba(16,55,92,0.12); border-radius:6px; margin-bottom:4px;">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="rgba(16,55,92,0.5)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                <span style="font-size:12px; color:rgba(16,55,92,0.6);">
                    Áp dụng cho kho: <strong id="config-warehouse-name" style="color:var(--navy);">—</strong>
                </span>
            </div>

            <div class="form-group">
                <label class="form-label" for="config-zone-select">Khu vực cất hàng (Zone)</label>
                <select id="config-zone-select" class="form-input" style="appearance:none; padding:10px 14px;">
                    <option value="">— Chọn khu vực trong kho —</option>
                </select>
                <span style="font-size:11px; color:rgba(16,55,92,0.4);">Chọn Zone nơi mã hàng này sẽ được lưu trữ tại kho của bạn</span>
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label" for="config-min">Tồn tối thiểu (Min)</label>
                    <input class="form-input" type="number" id="config-min" min="0" placeholder="VD: 10"/>
                    <span style="font-size:11px; color:rgba(16,55,92,0.4);">Báo động khi tổng tồn kho xuống dưới mức này</span>
                </div>
                <div class="form-group">
                    <label class="form-label" for="config-max">Tồn tối đa (Max)</label>
                    <input class="form-input" type="number" id="config-max" min="0" placeholder="VD: 200"/>
                    <span style="font-size:11px; color:rgba(16,55,92,0.4);">Ngưỡng tối đa cho phép tại kho này</span>
                </div>
            </div>
            
            <div class="modal-note">
                Cấu hình này chỉ áp dụng cho <strong>kho của bạn</strong>. Không ảnh hưởng đến các chi nhánh kho khác.
            </div>
        </div>
        <div class="modal-ftr">
            <button class="btn-toolbar" id="configModalCancel">Hủy</button>
            <button class="btn-add-sku" id="btnConfigSubmit">Lưu cấu hình</button>
        </div>
    </div>
</div>

<!-- ══ VIEW DETAIL MODAL ══════════════════════════════════════ -->
<div class="modal-overlay" id="viewModalOverlay">
    <div class="modal-box">
        <div class="modal-hdr">
            <div>
                <h2 class="modal-title">Chi tiết SKU sản phẩm</h2>
                <p class="modal-subtitle" id="view-sku-code-label">SKU-XXXX</p>
            </div>
            <button class="modal-close" id="viewModalClose">&times;</button>
        </div>
        <div class="modal-body" style="max-height: 60vh; overflow-y: auto;">
            <div class="form-group">
                <label class="form-label">Tên sản phẩm</label>
                <div class="form-input" id="view-name" style="background: rgba(16, 55, 92, 0.02); pointer-events: none; height: auto; min-height: 38px; display: flex; align-items: center; border: 1px solid var(--border); border-radius: 6px; padding: 0 12px; font-weight: 500; color: var(--navy);"></div>
            </div>
            <div class="form-group">
                <label class="form-label">Danh mục</label>
                <div class="form-input" id="view-category" style="background: rgba(16, 55, 92, 0.02); pointer-events: none; height: auto; min-height: 38px; display: flex; align-items: center; border: 1px solid var(--border); border-radius: 6px; padding: 0 12px; font-weight: 500; color: var(--navy);"></div>
            </div>
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Kích thước (D×R×C) cm</label>
                    <div class="form-input" id="view-dimensions" style="background: rgba(16, 55, 92, 0.02); pointer-events: none; height: auto; min-height: 38px; display: flex; align-items: center; border: 1px solid var(--border); border-radius: 6px; padding: 0 12px; font-weight: 500; color: var(--navy);"></div>
                </div>
                <div class="form-group">
                    <label class="form-label">Khối lượng (kg)</label>
                    <div class="form-input" id="view-weight" style="background: rgba(16, 55, 92, 0.02); pointer-events: none; height: auto; min-height: 38px; display: flex; align-items: center; border: 1px solid var(--border); border-radius: 6px; padding: 0 12px; font-weight: 500; color: var(--navy);"></div>
                </div>
            </div>
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Tồn tối thiểu (MIN)</label>
                    <div class="form-input" id="view-min" style="background: rgba(16, 55, 92, 0.02); pointer-events: none; height: auto; min-height: 38px; display: flex; align-items: center; border: 1px solid var(--border); border-radius: 6px; padding: 0 12px; font-weight: 500; color: var(--navy);"></div>
                </div>
                <div class="form-group">
                    <label class="form-label">Tồn tối đa (MAX)</label>
                    <div class="form-input" id="view-max" style="background: rgba(16, 55, 92, 0.02); pointer-events: none; height: auto; min-height: 38px; display: flex; align-items: center; border: 1px solid var(--border); border-radius: 6px; padding: 0 12px; font-weight: 500; color: var(--navy);"></div>
                </div>
            </div>
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Đơn vị tính</label>
                    <div class="form-input" id="view-unit" style="background: rgba(16, 55, 92, 0.02); pointer-events: none; height: auto; min-height: 38px; display: flex; align-items: center; border: 1px solid var(--border); border-radius: 6px; padding: 0 12px; font-weight: 500; color: var(--navy);">Cái</div>
                </div>
                <div class="form-group">
                    <label class="form-label">Trạng thái duyệt</label>
                    <div class="form-input" id="view-approval-status" style="background: rgba(16, 55, 92, 0.02); pointer-events: none; height: auto; min-height: 38px; display: flex; align-items: center; border: 1px solid var(--border); border-radius: 6px; padding: 0 12px; font-weight: 500; color: var(--navy);">Đã duyệt</div>
                </div>
            </div>
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Người tạo</label>
                    <div class="form-input" id="view-created-by" style="background: rgba(16, 55, 92, 0.02); pointer-events: none; height: auto; min-height: 38px; display: flex; align-items: center; border: 1px solid var(--border); border-radius: 6px; padding: 0 12px; font-weight: 500; color: var(--navy);"></div>
                </div>
                <div class="form-group">
                    <label class="form-label">Thời gian tạo</label>
                    <div class="form-input" id="view-created-at" style="background: rgba(16, 55, 92, 0.02); pointer-events: none; height: auto; min-height: 38px; display: flex; align-items: center; border: 1px solid var(--border); border-radius: 6px; padding: 0 12px; font-weight: 500; color: var(--navy);"></div>
                </div>
            </div>
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Người cập nhật</label>
                    <div class="form-input" id="view-updated-by" style="background: rgba(16, 55, 92, 0.02); pointer-events: none; height: auto; min-height: 38px; display: flex; align-items: center; border: 1px solid var(--border); border-radius: 6px; padding: 0 12px; font-weight: 500; color: var(--navy);"></div>
                </div>
                <div class="form-group">
                    <label class="form-label">Thời gian cập nhật</label>
                    <div class="form-input" id="view-updated-at" style="background: rgba(16, 55, 92, 0.02); pointer-events: none; height: auto; min-height: 38px; display: flex; align-items: center; border: 1px solid var(--border); border-radius: 6px; padding: 0 12px; font-weight: 500; color: var(--navy);"></div>
                </div>
            </div>
        </div>
        <div class="modal-ftr">
            <button class="btn-toolbar" id="viewModalCloseBtn" style="background: var(--navy); color: white;">Đóng</button>
        </div>
    </div>
</div>

<div id="productsJsonData" style="display:none;"><c:out value="${productsJson}"/></div>
<div id="warehousesJsonData" style="display:none;"><c:out value="${warehousesJson}"/></div>
<div id="zonesJsonData" style="display:none;"><c:out value="${zonesJson}"/></div>
<div id="categoriesJsonData" style="display:none;"><c:out value="${categoriesJson}"/></div>

<!-- ══ SKU JAVASCRIPT STATE & LOGIC ══════════════════════════ -->
<script>
// Expose JSTL session user details to client-side
window.WMS_USER = {
    fullName: "${fn:escapeXml(not empty loggedInUser.fullName ? loggedInUser.fullName : 'Guest')}",
    role: "${fn:escapeXml(not empty loggedInUser.role ? loggedInUser.role : 'Guest')}"
};

function submitPostAction(action, params) {
    var form = document.createElement('form');
    form.method = 'POST';
    form.action = window.location.pathname;

    var actionInput = document.createElement('input');
    actionInput.type = 'hidden';
    actionInput.name = 'action';
    actionInput.value = action;
    form.appendChild(actionInput);

    for (var key in params) {
        if (params.hasOwnProperty(key)) {
            var input = document.createElement('input');
            input.type = 'hidden';
            input.name = key;
            input.value = params[key];
            form.appendChild(input);
        }
    }

    document.body.appendChild(form);
    form.submit();
}


(function () {
'use strict';

/* ─── Data from server ─────────────────────────────────────── */
var skus = [];
try {
    var rawJsonEl = document.getElementById('productsJsonData');
    var rawJson = rawJsonEl ? rawJsonEl.textContent : '';
    if (rawJson && rawJson.trim()) {
        var SERVER_PRODUCTS = JSON.parse(rawJson);
        skus = SERVER_PRODUCTS.map(function(p) {
    return {
        id: 'p-' + p.productId,
        sku: p.skuCode || '',
        name: p.productName || '',
        category: p.categoryName || '',
        dimensions: p.attributesText || 'N/A',
        weight: p.weightKg ? p.weightKg + ' kg' : 'N/A',
                qtyOnHand: Number(p.qtyOnHand || 0),
                minStock: Number(p.minStock || 0),
                maxStock: Number(p.maxStock || 0),
        locationConfigs: p.locationConfigs || [],
                createdBy: p.creatorName || '',
        createdAt: p.createdAt || '',
                updatedBy: p.creatorName || '',
        lastUpdated: p.updatedAt || ''
    };
        });
    }
} catch (e) {
    console.warn('warehouse-master-sku: No server product data');
}

var LOCATIONS = [];
try {
    var rawWarehousesJsonEl = document.getElementById('warehousesJsonData');
    var rawWarehousesJson = rawWarehousesJsonEl ? rawWarehousesJsonEl.textContent : '';
    if (rawWarehousesJson && rawWarehousesJson.trim()) {
        LOCATIONS = JSON.parse(rawWarehousesJson).map(function(w) {
            return { id: w.warehouseId.toString(), name: w.warehouseName, code: w.warehouseCode };
        });
    }
} catch (e) { LOCATIONS = []; }

var ZONES = [];
try {
    var rawZonesJsonEl = document.getElementById('zonesJsonData');
    var rawZonesJson = rawZonesJsonEl ? rawZonesJsonEl.textContent : '';
    if (rawZonesJson && rawZonesJson.trim()) {
        ZONES = JSON.parse(rawZonesJson).map(function(z) {
            return {
                id: z.zoneId.toString(),
                locationId: z.warehouseId.toString(),
                code: z.zoneCode,
                name: z.zoneName,
                zoneType: z.zoneType
            };
        });
    }
} catch (e) { ZONES = []; }

var DB_CATEGORIES = [];
try {
    var rawCategoriesJsonEl = document.getElementById('categoriesJsonData');
    var rawCategoriesJson = rawCategoriesJsonEl ? rawCategoriesJsonEl.textContent : '';
    if (rawCategoriesJson && rawCategoriesJson.trim()) {
        DB_CATEGORIES = JSON.parse(rawCategoriesJson).map(function(c) {
            return { categoryId: c.id, categoryName: c.name, parentId: c.parentId };
        });
    }
} catch (e) {}

/* ─── Helpers ─────────────────────────────────────────────── */
function escapeHtml(str) {
    if (!str) return '';
    return str.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&#039;");
}

function buildCategoryTreeOptions(categories, isFilter) {
    var html = isFilter ? '<option value="Tất cả">Tất cả</option>' : '';
    function recurse(parentId, prefix) {
        categories.filter(function(c) {
            var p = c.parentId;
            return (parentId === null) ? (p === null || p === 0 || p === 'null') : (p == parentId);
        }).forEach(function(node) {
            html += '<option value="' + escapeHtml(node.categoryName) + '">' + prefix + escapeHtml(node.categoryName) + '</option>';
            recurse(node.categoryId, prefix + '    ');
        });
    }
    recurse(null, '');
    return html;
}

function padZero(n) { return n < 10 ? '0' + n : n; }

/* ─── State ──────────────────────────────────────────────── */
var search = '';
var selectedCategory = 'Tất cả';
var currentPage = 1;
var pageSize = 20;

/* ─── Init: set warehouse label ─ */
(function initMyWarehouse() {
    var label = document.getElementById('myWarehouseName');
    if (label && LOCATIONS.length > 0) {
        label.textContent = LOCATIONS[0].name;
    }
if (catSelect && DB_CATEGORIES.length > 0) {
    catSelect.innerHTML = buildCategoryTreeOptions(DB_CATEGORIES, true);
}
})();

/* ─── DOM Elements ───────────────────────────────────────── */
var tableBody  = document.getElementById('skuTableBody');
var tableInfo  = document.getElementById('skuTableInfo');
var pagination = document.getElementById('skuPagination');
var searchInput = document.getElementById('skuSearchInput');
var catSelect   = document.getElementById('skuCategorySelect');

/* Config Modal */
var configOverlay        = document.getElementById('configModalOverlay');
var btnConfigClose      = document.getElementById('configModalClose');
var btnConfigCancel     = document.getElementById('configModalCancel');
var btnConfigSubmit     = document.getElementById('btnConfigSubmit');
var configSkuLabel      = document.getElementById('config-sku-label');
var configProductId     = document.getElementById('config-product-id');
var configZoneSelect    = document.getElementById('config-zone-select');
var configWarehouseName  = document.getElementById('config-warehouse-name');
var configMinInput      = document.getElementById('config-min');
var configMaxInput      = document.getElementById('config-max');

/* View Modal */
var viewOverlay      = document.getElementById('viewModalOverlay');
var btnViewClose    = document.getElementById('viewModalClose');
var btnViewCloseBtn = document.getElementById('viewModalCloseBtn');

/* ─── Config Modal: populate zone select ─────────────────── */
function populateZoneSelect(warehouseId) {
    if (!configZoneSelect) return;
    var zones = ZONES.filter(function(z) { return z.locationId === warehouseId; });
    var html = '<option value="">— Chọn khu vực trong kho —</option>';
    zones.forEach(function(z) {
        html += '<option value="' + z.id + '">' + z.code + ' — ' + z.name + '</option>';
    });
    configZoneSelect.innerHTML = html;
}

/* ─── Config Modal: open & close ────────────────────────── */
window.triggerConfigSKU = function(id) {
    var item = skus.find(function(s) { return s.id === id; });
    if (!item) return;

    configSkuLabel.textContent = item.sku;
    configProductId.value = item.id;
    configMinInput.value = item.minStock || '';
    configMaxInput.value = item.maxStock || '';

    var myLoc = LOCATIONS[0] || null;
    configWarehouseName.textContent = myLoc ? myLoc.name : '—';
    populateZoneSelect(myLoc ? myLoc.id : null);

    if (myLoc && item.locationConfigs) {
        var existing = item.locationConfigs.find(function(c) {
            return c.locationId && c.locationId.toString() === myLoc.id;
        });
        configZoneSelect.value = (existing && existing.zoneId) ? existing.zoneId.toString() : '';
    } else {
        configZoneSelect.value = '';
    }

    configOverlay.classList.add('active');
};

function closeConfigModal() {
    configOverlay.classList.remove('active');
}

if (btnConfigClose) btnConfigClose.addEventListener('click', closeConfigModal);
if (btnConfigCancel) btnConfigCancel.addEventListener('click', closeConfigModal);
if (configOverlay) configOverlay.addEventListener('click', function(e) {
    if (e.target === configOverlay) closeConfigModal();
});

/* ─── Config Submit ──────────────────────────────────────── */
if (btnConfigSubmit) {
    btnConfigSubmit.addEventListener('click', function() {
        var id = configProductId.value;
        var zoneId = configZoneSelect.value;
        var min = parseInt(configMinInput.value) || 0;
        var max = parseInt(configMaxInput.value) || 100;

        submitPostAction('edit', {
            productId: id.replace('p-', ''),
            minStock: min,
            maxStock: max,
            zoneId: zoneId
        });
    });
}

/* ─── Export CSV ─────────────────────────────────────────── */
var btnExport = document.getElementById('btnExportCsv');
if (btnExport) {
    btnExport.addEventListener('click', function() {
        var rows = [['SKU', 'Tên sản phẩm', 'Danh mục', 'Tồn tay', 'Min', 'Max', 'Trạng thái']];
        // Use the most-recently filtered set
        var data = (typeof filtered !== 'undefined' && filtered) ? filtered : skus;
        data.forEach(function(s) {
            rows.push([s.sku, s.name, s.category, s.qtyOnHand, s.minStock, s.maxStock, 'Đã duyệt']);
        });
        var csv = rows.map(function(r) {
            return r.map(function(c) { return '"' + String(c == null ? '' : c).replace(/"/g, '""') + '"'; }).join(',');
        }).join('\n');
        var blob = new Blob(['\uFEFF' + csv], { type: 'text/csv;charset=utf-8;' });
        var url = URL.createObjectURL(blob);
        var a = document.createElement('a');
        a.href = url; a.download = 'sku-catalog.csv';
        document.body.appendChild(a); a.click();
        setTimeout(function() { document.body.removeChild(a); URL.revokeObjectURL(url); }, 100);
    });
}

/* ─── View Modal ─────────────────────────────────────────── */
window.triggerViewSKU = function(id) {
    var item = skus.find(function(s) { return s.id === id; });
    if (!item) return;

    document.getElementById('view-sku-code-label').textContent = item.sku;
    document.getElementById('view-name').textContent = item.name;
    document.getElementById('view-category').textContent = item.category;
    document.getElementById('view-dimensions').textContent = item.dimensions || 'N/A';
    document.getElementById('view-weight').textContent = item.weight || 'N/A';
    document.getElementById('view-min').textContent = item.minStock;
    document.getElementById('view-max').textContent = item.maxStock;
    document.getElementById('view-created-by').textContent = item.createdBy || 'N/A';
    document.getElementById('view-created-at').textContent = item.createdAt || 'N/A';
    document.getElementById('view-updated-by').textContent = item.updatedBy || item.createdBy || 'N/A';
    document.getElementById('view-updated-at').textContent = item.lastUpdated || item.createdAt || 'N/A';

    viewOverlay.classList.add('active');
};

if (btnViewClose) btnViewClose.addEventListener('click', function() { viewOverlay.classList.remove('active'); });
if (btnViewCloseBtn) btnViewCloseBtn.addEventListener('click', function() { viewOverlay.classList.remove('active'); });
if (viewOverlay) viewOverlay.addEventListener('click', function(e) {
    if (e.target === viewOverlay) viewOverlay.classList.remove('active');
});

/* ─── Search & Filter ────────────────────────────────────── */
if (searchInput) {
    searchInput.addEventListener('input', function(e) {
        search = e.target.value;
        currentPage = 1;
        renderAll();
    });
}
if (catSelect) {
    catSelect.addEventListener('change', function(e) {
        selectedCategory = e.target.value;
        currentPage = 1;
        renderAll();
    });
}
var zoneStatusSelect = document.getElementById('skuZoneStatusSelect');
if (zoneStatusSelect) {
    zoneStatusSelect.addEventListener('change', function(e) {
        currentPage = 1;
        renderAll();
    });
}

/* ─── Stats ──────────────────────────────────────────────── */
function updateStats(total, totalStock, fillRate) {
    var t = document.getElementById('stat-total-skus');
    var s = document.getElementById('stat-total-stock');
    var f = document.getElementById('stat-fill-rate');
    if (t) t.textContent = total.toLocaleString();
    if (s) s.textContent = totalStock.toLocaleString();
    if (f) f.textContent = fillRate + '%';
    // Pending approval and Suspended stay 0 — omnicore-main has no approval workflow.
}

/* ─── Render Table ────────────────────────────────────────── */
function renderAll() {
    var myLoc = LOCATIONS[0];
    var myLocId = myLoc ? myLoc.id : null;

    var zoneStatusSelect = document.getElementById('skuZoneStatusSelect');
    var selectedZoneStatus = zoneStatusSelect ? zoneStatusSelect.value : 'all';

    var filtered = skus.filter(function(s) {
        var matchSearch = !search ||
            s.sku.toLowerCase().indexOf(search.toLowerCase()) > -1 ||
            s.name.toLowerCase().indexOf(search.toLowerCase()) > -1;
        var matchCat = selectedCategory === 'Tat ca' || selectedCategory === 'Tất cả' || s.category === selectedCategory;
        
        var myConfig = myLocId ? s.locationConfigs.find(function(c) {
            return c.locationId && c.locationId.toString() === myLocId;
        }) : null;
        var hasZone = !!(myConfig && myConfig.zoneId);

        var matchZoneStatus = true;
        if (selectedZoneStatus === 'unassigned') {
            matchZoneStatus = !hasZone;
        } else if (selectedZoneStatus === 'assigned') {
            matchZoneStatus = hasZone;
        }

        return matchSearch && matchCat && matchZoneStatus;
    });

    // Active count = total (every SKU in main is implicitly approved).
    var totalStock = filtered.reduce(function(acc, s) { return acc + s.qtyOnHand; }, 0);
    var maxStockTotal = filtered.reduce(function(acc, s) { return acc + (s.maxStock || 0); }, 0);
    var fillRate = maxStockTotal > 0 ? Math.min(100, Math.round((totalStock / maxStockTotal) * 100)) : 0;
    updateStats(filtered.length, totalStock, fillRate);
    
    var totalItems = filtered.length;
    var totalPages = Math.ceil(totalItems / pageSize) || 1;
    if (currentPage > totalPages) currentPage = totalPages;
    var startIdx = (currentPage - 1) * pageSize;
    var endIdx = Math.min(startIdx + pageSize, totalItems);
    var paginated = filtered.slice(startIdx, endIdx);
    
    tableInfo.textContent = 'Hiển thị ' + (totalItems > 0 ? startIdx + 1 : 0) + '–' + endIdx + ' / ' + totalItems + ' SKU';
    
    if (paginated.length === 0) {
        tableBody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:48px;color:rgba(16,55,92,0.4)">Không tìm thấy sản phẩm nào.</td></tr>';
        pagination.innerHTML = '';
        return;
    }
    
    var html = paginated.map(function(item, idx) {
        var isLow = item.qtyOnHand < item.minStock;
        var isOut = item.qtyOnHand === 0;

        var locHtml = '';
        if (myLocId && item.locationConfigs) {
            var myConfig = item.locationConfigs.find(function(c) {
                return c.locationId && c.locationId.toString() === myLocId;
            });
            if (myConfig && myConfig.zoneId) {
                var zone = ZONES.find(function(z) { return z.id === myConfig.zoneId.toString(); });
                if (zone) {
                    locHtml = '<span style="font-size: 13px; color: var(--navy); font-weight: 600;">' + escapeHtml(zone.name) + '</span>';
                }
            }
        }
        if (!locHtml) {
            locHtml = '<span class="loc-unassigned" style="background: rgba(245, 200, 66, 0.15); color: #d9a000; border: 1px solid rgba(245, 200, 66, 0.3); padding: 4px 8px; border-radius: 4px; display: inline-flex; align-items: center; gap: 4px; font-size: 11px; font-weight: 600;">' +
                '⚠️ Chưa cấu hình</span>';
        }

        var isLowOrOut = item.qtyOnHand === 0 || item.qtyOnHand < item.minStock;
        var inboundBtnStyle = isLowOrOut
            ? 'background: rgba(239, 68, 68, 0.1); color: #ef4444; border: 1px solid rgba(239, 68, 68, 0.2);'
            : 'background: rgba(16, 55, 92, 0.05); color: var(--navy); border: 1px solid rgba(16, 55, 92, 0.1);';

        var rowClass = (startIdx + idx) % 2 === 0 ? '' : 'style="background:rgba(240,244,250,0.3)"';

        return '<tr ' + rowClass + '>' +
            '<td>' +
                '<div class="sku-code-cell" style="font-weight: 700; margin-bottom: 2px;">' + escapeHtml(item.sku) + '</div>' +
                '<div class="sku-name-cell" style="font-weight: 700; font-size: 13px;" title="' + escapeHtml(item.name) + '">' + escapeHtml(item.name) + '</div>' +
            '</td>' +
            '<td><div style="font-size: 13px; color: var(--navy);">' + escapeHtml(item.category || '—') + '</div></td>' +
            '<td style="text-align:right;">' +
                '<div class="qty-val' + (isOut ? ' out' : (isLow ? ' low' : '')) + '">' + item.qtyOnHand.toLocaleString() + '</div>' +
                '<div style="font-size: 10px; color: rgba(16,55,92,0.45); margin-top: 2px;">' + escapeHtml(item.dimensions || '—') + '</div>' +
            '</td>' +
            '<td>' + locHtml + '</td>' +
            '<td style="text-align: right;">' +
                '<div style="font-size: 13px; color: var(--navy); font-weight: 600;">' + item.minStock + ' / ' + item.maxStock + '</div>' +
            '</td>' +
            '<td style="text-align:center;"><span class="pill pill--green">Đã duyệt</span></td>' +
            '<td>' +
                '<div style="font-size: 12px; color: var(--navy); font-weight: 500;">' + (item.lastUpdated || item.createdAt || '—') + '</div>' +
                '<div style="font-size: 10px; color: rgba(16,55,92,0.45); margin-top: 2px;">' + escapeHtml(item.updatedBy || item.createdBy || '—') + '</div>' +
            '</td>' +
            '<td style="text-align: center;">' +
                '<div style="display:flex;align-items:center;justify-content:center;gap:8px;">' +
                    '<button class="btn-act-circle edit" onclick="window.triggerConfigSKU(\'' + item.id + '\')" title="Cấu hình Kho" style="width:28px;height:28px;">' +
                        '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>' +
                    '</button>' +
                    '<button class="btn-act-circle" onclick="window.location.href=\'${pageContext.request.contextPath}/warehouse/inbound?action=create&sku=\' + encodeURIComponent(\'' + item.sku + '\')" title="Nhập hàng" style="width:28px;height:28px; ' + inboundBtnStyle + '">' +
                        '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>' +
                    '</button>' +
                '</div>' +
            '</td>' +
        '</tr>';
    }).join('');

    tableBody.innerHTML = html;

    var pageHtml = '';
    for (var p = 1; p <= totalPages; p++) {
        pageHtml += '<button class="page-btn' + (p === currentPage ? ' active' : '') + '" onclick="window.gotoSKUPage(' + p + ')">' + p + '</button>';
    }
    pagination.innerHTML = pageHtml;
}

window.gotoSKUPage = function(p) {
    currentPage = p;
    renderAll();
};

renderAll();

})();
</script>

