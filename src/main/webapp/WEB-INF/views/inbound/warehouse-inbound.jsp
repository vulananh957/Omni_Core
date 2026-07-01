<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/inbound--warehouse-inbound.css?v=2"/>
<style>
    .draft-row {
        grid-template-columns: 1.2fr 1.6fr 110px 110px 40px !important;
    }
</style>


<!-- ══ VIEW 1: RECEIPTS TAB ══════════════════════════════════ -->
<div id="view-receipts">
    <!-- Summary Cards -->
    <div class="inbound-stats-grid-4">
        <!-- Card: Pending Items -->
        <div class="inbound-kpi-card tone-blue">
            <div class="inbound-kpi-card__icon-box">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            </div>
            <div class="inbound-kpi-card__info">
                <div class="inbound-kpi-card__val" id="stat-pending">0</div>
                <div class="inbound-kpi-card__lbl">Phiếu chờ mua</div>
            </div>
        </div>

        <!-- Card: In Progress -->
        <div class="inbound-kpi-card tone-orange">
            <div class="inbound-kpi-card__icon-box">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 17V3"/><path d="m6 11 6 6 6-6"/><path d="M19 21H5"/></svg>
            </div>
            <div class="inbound-kpi-card__info">
                <div class="inbound-kpi-card__val" id="stat-in-progress">0</div>
                <div class="inbound-kpi-card__lbl">Đang nhập kho</div>
            </div>
        </div>

        <!-- Card: Completed Weekly -->
        <div class="inbound-kpi-card tone-emerald">
            <div class="inbound-kpi-card__icon-box">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            </div>
            <div class="inbound-kpi-card__info">
                <div class="inbound-kpi-card__val" id="stat-completed">0</div>
                <div class="inbound-kpi-card__lbl">Hoàn thành tuần này</div>
            </div>
        </div>

        <!-- Card: SKU Received -->
        <div class="inbound-kpi-card tone-violet">
            <div class="inbound-kpi-card__icon-box">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m7.5 4.27 9 5.15"/><path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"/><path d="m3.3 7 8.7 5 8.7-5"/><path d="M12 22V12"/></svg>
            </div>
            <div class="inbound-kpi-card__info">
                <div class="inbound-kpi-card__val" id="stat-sku-received">0</div>
                <div class="inbound-kpi-card__lbl">SKU đã nhập</div>
            </div>
        </div>
    </div>

    <!-- GRN List Container (rendered by JavaScript) -->
    <!-- Toolbar -->
    <div class="toolbar" style="margin-bottom:12px;">
        <div class="search-wrap">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"></svg>
            <input type="text" placeholder="Tìm mã phiếu hoặc nhà cung cấp..." id="grnSearchInput"/>
        </div>
        <button class="btn-create" id="btnCreateGRNTrigger">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
            Tạo phiếu mua hàng
        </button>
    </div>

    <!-- Status Filter Tabs -->
    <div class="status-tabs" id="statusTabsContainer"></div>

    <!-- GRN Table (unified) -->
    <div class="grn-list" id="grnListContainer"></div>
</div>



<!-- ══ MODAL: CREATE / DUPLICATE DRAFT GRN ════════════════════ -->
<div class="modal-overlay" id="draftModalOverlay">
    <div class="modal-box" style="max-width: 800px;">
        <div class="modal-hdr">
            <div>
                <h2 class="modal-title" id="draftModalTitle">Tạo phiếu mua hàng</h2>
                <p class="modal-subtitle">Tạo phiếu → nhập kho → hoàn thành. Không cần duyệt.</p>
            </div>
            <button class="modal-close" onclick="closeDraftModal()">&times;</button>
        </div>
        <div class="modal-body" style="background: rgba(240, 244, 250, 0.25);">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                <div class="form-group">
                    <label class="form-label" for="draft-supplier">Nhà cung cấp *</label>
                    <input class="form-input" style="background:#fff;" type="text" id="draft-supplier" placeholder="Tên nhà cung cấp"/>
                </div>
                <div class="form-group">
                    <label class="form-label" for="draft-date">Ngày dự kiến *</label>
                    <input class="form-input" style="background:#fff;" type="date" id="draft-date"/>
                </div>
            </div>
            <div class="form-group">
                <label class="form-label" for="draft-note">Ghi chú</label>
                <textarea class="form-textarea" style="background:#fff;" id="draft-note" rows="3" placeholder="Ghi chú cho phiếu nhập nháp..."></textarea>
            </div>

            <!-- Draft Items grid -->
            <div class="draft-items-box">
                <div class="draft-items-hdr">
                    <span class="draft-items-title">Danh sách SKU</span>
                    <button class="btn-add-row" onclick="addDraftItemRow()">Thêm dòng</button>
                </div>
                <div id="draftRowsContainer">
                    <!-- Rendered dynamically -->
                </div>
            </div>
        </div>
        <div class="modal-ftr" style="background:#fff;">
            <button class="modal-btn-cancel" onclick="closeDraftModal()">Hủy</button>
            <button class="modal-btn-submit" id="btnSubmitGRN" onclick="submitDraftGRN()">Tạo phiếu &amp; Nhập kho</button>
        </div>
    </div>
</div>

<!-- ══ MODAL: RECEIVE GOODS (XÁC NHẬN NHẬP KHO) ══════════════ -->
<div class="modal-overlay" id="receiveModalOverlay">
    <div class="modal-box">
        <div class="modal-hdr">
            <div>
                <h2 class="modal-title">Nhập hàng thực tế</h2>
                <p class="modal-subtitle" id="receiveModalSubtitle">Mã phiếu mua: ...</p>
            </div>
            <button class="modal-close" onclick="closeReceiveModal()">&times;</button>
        </div>
        <div class="modal-body">
            <p style="font-size: 12px; color: rgba(16, 55, 92, 0.6); margin-bottom: 8px;">Nhập SL thực nhận cho từng SKU. Phần chênh lệch (PO đặt − SL thực nhận) sẽ tự động ghi nhận là "Đã trả NCC tại chỗ" và không lưu vào tồn kho.</p>
            <input type="hidden" id="receive-grn-id"/>
            <div id="receiveItemsContainer" style="display:flex; flex-direction:column; gap:12px;">
                <!-- Populate items with 3 inputs: received / accepted / rejected -->
            </div>
        </div>
        <div class="modal-ftr">
            <button class="modal-btn-cancel" onclick="closeReceiveModal()">Hủy</button>
            <button class="modal-btn-submit modal-btn-emerald" onclick="submitConfirmReceive()">Xác nhận nhập kho</button>
        </div>
    </div>
</div>

<!-- ══ MODAL: CREATE PO (Server-side) ════════════════════════════════ -->
<div class="modal-overlay" id="createPOModal">
    <div class="modal-box" style="max-width:560px;">
        <div class="modal-hdr">
            <div>
                <h2 class="modal-title">Tạo phiếu mua hàng mới</h2>
                <p class="modal-subtitle">Tạo đơn mua hàng từ nhà cung cấp</p>
            </div>
            <button class="modal-close" onclick="closeCreatePOModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/warehouse/inbound" id="createPOForm">
            <input type="hidden" name="action" value="create"/>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label" for="po-supplier">Nhà cung cấp *</label>
                    <input class="form-input" style="background:#fff;" type="text" id="po-supplier" name="supplierName" placeholder="Tên nhà cung cấp..." required/>
                </div>
                <div class="form-group">
                    <label class="form-label" for="po-warehouse">Kho nhập *</label>
                    <select class="form-input" style="background:#fff;" id="po-warehouse" name="warehouseId" required>
                        <option value="">— Chọn kho —</option>
                        <c:forEach items="${warehouses}" var="w">
                            <option value="${w.warehouseId}">${w.warehouseName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" for="po-date">Ngày dự kiến nhận</label>
                    <input class="form-input" style="background:#fff;" type="date" id="po-date" name="expectedDate"/>
                </div>
                <div class="form-group">
                    <label class="form-label" for="po-notes">Ghi chú</label>
                    <textarea class="form-textarea" style="background:#fff;" id="po-notes" name="notes" rows="3" placeholder="Ghi chú thêm (nếu có)..."></textarea>
                </div>
            </div>
            <div class="modal-ftr" style="background:#fff;">
                <button type="button" class="modal-btn-cancel" onclick="closeCreatePOModal()">Hủy</button>
                <button type="submit" class="modal-btn-submit">Tạo phiếu mua hàng</button>
            </div>
        </form>
    </div>
</div>

<!-- ══ MODAL: CONFIRM RECEIVE (Server-side) ═════════════════════════ -->
<div class="modal-overlay" id="receiveDBModal">
    <div class="modal-box" style="max-width:600px;">
        <div class="modal-hdr">
            <div>
                <h2 class="modal-title">Nhập hàng thực tế</h2>
                <p class="modal-subtitle" id="receiveDB-subtitle">Mã phiếu: ...</p>
            </div>
            <button class="modal-close" onclick="closeReceiveDBModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/warehouse/inbound" id="receiveDBForm">
            <input type="hidden" name="action" value="receive"/>
            <input type="hidden" name="inboundId" id="receiveDB-inboundId"/>
            <div class="modal-body">
                <p style="font-size:12px; color:rgba(16,55,92,0.60); margin-bottom:8px;">
                    Nhập số lượng thực tế cho từng sản phẩm. Hệ thống sẽ cộng tồn kho khả dụng và tạo ledger entry.
                </p>
                <div id="receiveDBItemsContainer" style="display:flex; flex-direction:column; gap:10px;">
                    <!-- Dynamic items -->
                </div>
            </div>
            <div class="modal-ftr" style="background:#fff;">
                <button type="button" class="modal-btn-cancel" onclick="closeReceiveDBModal()">Hủy</button>
                <button type="submit" class="modal-btn-submit modal-btn-emerald">Xác nhận nhập hàng</button>
            </div>
        </form>
    </div>
</div>

<!-- ══ MODAL: DETAIL VIEW ═══════════════════════════════════ -->
<div class="modal-overlay" id="detailModalOverlay">
    <div class="modal-box" style="max-width: 960px;">
        <div class="modal-hdr">
            <div>
                <h2 class="modal-title">Chi tiết Phiếu mua hàng</h2>
                <p class="modal-subtitle" id="detailModalSubtitle">GRN-XXXX</p>
            </div>
            <button class="modal-close" onclick="closeDetailModal()">&times;</button>
        </div>
        <div class="modal-body" style="gap: 16px;">
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:16px; font-size:13px; color:var(--navy);">
                <div><strong>Nhà cung cấp:</strong> <span id="detail-supplier">NCC</span></div>
                <div><strong>Trạng thái:</strong> <span id="detail-status-badge">Badge</span></div>
                <div><strong>Ngày tạo:</strong> <span id="detail-created-at">Date</span></div>
                <div><strong>Ngày nhận hàng:</strong> <span id="detail-expected-date">Date</span></div>
            </div>
            <div class="draft-items-box">
                <div class="draft-items-hdr" style="background:var(--alice);">
                    <span class="draft-items-title" style="font-weight:700;">Danh sách mặt hàng nhập kho</span>
                </div>
                <table class="grn-body-table">
                    <thead>
                        <tr style="background:#fff;">
                            <th style="padding-left:16px; min-width:90px;">SKU</th>
                            <th style="min-width:140px;">Sản phẩm</th>
                            <th style="text-align:right; width:90px; white-space:nowrap;">Đơn giá</th>
                            <th style="text-align:right; width:70px; white-space:nowrap;">Đặt mua</th>
                            <th style="text-align:right; width:80px; white-space:nowrap;">Thực nhận</th>
                            <th style="text-align:right; width:80px; white-space:nowrap; color:#b45309;">Trả NCC</th>
                            <th style="text-align:right; width:100px; white-space:nowrap; padding-right:16px;">Thành tiền</th>
                        </tr>
                    </thead>
                    <tbody id="detailItemsTableBody">
                        <!-- Populate -->
                    </tbody>
                </table>
            </div>
            <div class="modal-note" id="detail-notes-box" style="display:none; padding:12px; border:1px solid #ffebc2; background:#fffcf5; border-radius:6px; font-size:12px; color:rgba(16, 55, 92, 0.75);">
                <strong>Ghi chú:</strong> <span id="detail-note-content">Note</span>
            </div>
        </div>
        <div class="modal-ftr">
            <button class="modal-btn-cancel" onclick="closeDetailModal()">Đóng</button>
        </div>
    </div>
</div>

<script id="db-products-data" type="application/json"><c:out value="${productsJson}" escapeXml="false"/></script>
<script id="db-page-flags-data" type="application/json">{"hasInboundList": ${not empty inboundList ? 'true' : 'false'}}</script>
<script id="db-user-data" type="application/json">{"fullName":"<c:out value='${loggedInUser.fullName}'/>","role":"<c:out value='${loggedInUser.role}'/>"}</script>
<script id="db-inbound-list-data" type="application/json">[
<c:forEach items="${inboundList}" var="io" varStatus="s">{"inboundId":${io.inboundId},"inboundCode":"<c:out value='${io.inboundCode}'/>","supplierName":"<c:out value='${io.supplierName}'/>","warehouseName":"<c:out value='${io.warehouseName}'/>","status":"<c:out value='${io.status}'/>","createdAt":"<c:out value='${io.createdAt}'/>","items":${io.itemsJson}}${!s.last ? ',' : ''}
</c:forEach>]
</script>

<script>
(function () {
'use strict';

function safeJsonParse(rawValue, fallbackValue) {
    if (!rawValue) {
        return fallbackValue;
    }
    try {
        return JSON.parse(rawValue);
    } catch (error) {
        return fallbackValue;
    }
}

function escapeHtml(string) {
    if (!string) return '';
    var map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return string.toString().replace(/[&<>"']/g, function(m) { return map[m]; });
}

var WMS_USER_DATA = safeJsonParse(document.getElementById('db-user-data') && document.getElementById('db-user-data').textContent, {});
var PAGE_FLAGS = safeJsonParse(document.getElementById('db-page-flags-data') && document.getElementById('db-page-flags-data').textContent, {});
var DB_PRODUCTS = safeJsonParse(document.getElementById('db-products-data') && document.getElementById('db-products-data').textContent, []);

window.WMS_USER = {
    fullName: WMS_USER_DATA.fullName || 'Guest',
    role: WMS_USER_DATA.role || 'Guest',
    myWarehouseId: parseInt("${myWarehouseId}") || 1
};

// Inbound Receipts — server data is single source of truth.
// Local drafts are no longer used; all GRNs are created directly on the server.
var serverInboundList = safeJsonParse(document.getElementById('db-inbound-list-data') && document.getElementById('db-inbound-list-data').textContent, []);
console.log('[INBOUND] serverInboundList:', serverInboundList.length, serverInboundList);
var grns = (serverInboundList || []).map(function(o) {
    var mappedStatus = o.status;
    if (o.status === 'PENDING') mappedStatus = 'pending';
    else if (o.status === 'IN_PROGRESS') mappedStatus = 'in_progress';
    else if (o.status === 'RECEIVED') mappedStatus = 'completed';
    else if (o.status === 'CANCELLED') mappedStatus = 'cancelled';
    else mappedStatus = o.status || 'pending';

    return {
        id: o.inboundId,
        inboundCode: o.inboundCode,
        supplier: o.supplierName,
        warehouseName: o.warehouseName,
        status: mappedStatus,
        createdAt: o.createdAt,
        items: (o.items || []).map(function(item) {
            return {
                productId: item.productId || 0,
                skuCode: item.skuCode || item.sku || '',
                skuName: item.skuName || item.productName || '',
                orderedQty: parseFloat(item.orderedQty || item.expectedQty || 0),
                receivedQty: parseFloat(item.receivedQty || 0),
                acceptedQty: parseFloat(item.acceptedQty || 0),
                rejectedQty: parseFloat(item.rejectedQty || 0),
                price: parseFloat(item.price || 0)
            };
        })
    };
});
console.log('[INBOUND] grns loaded:', grns.length, grns);

// Master SKUs
var savedSKUs = localStorage.getItem('wms_skus');
var skus = safeJsonParse(savedSKUs, []);
if ((!skus || skus.length === 0) && DB_PRODUCTS.length > 0) {
    skus = DB_PRODUCTS.map(function(p) {
        return {
            id: p.productId || p.id,
            sku: p.skuCode || p.sku,
            name: p.productName || p.name,
            category: p.categoryName || p.category || 'Chưa phân loại',
            status: p.status || 'PENDING',
            qtyOnHand: p.qtyOnHand || 0,
            approvalStatus: p.approvalStatus || 'approved'
        };
    });
}

// Pricing configuration — removed (base_price managed by Manager in master-sku)

// ─── STATE VARIABLES ───
var activeStatusTab = 'all'; // 'all', 'pending', 'in_progress', 'completed', 'cancelled'
var searchKeyword = '';
var expandedGrnId = null;

// Modal forms state
var draftMode = 'create'; // 'create' or 'duplicate'
var draftSourceId = null;
var draftForm = {
    supplier: '',
    expectedDate: '',
    note: '',
    items: []
};


// ─── VIEW 1: RECEIPTS LOGIC ───
// Search handler
var searchInput = document.getElementById('grnSearchInput');
if (searchInput) {
    searchInput.addEventListener('input', function(e) {
        searchKeyword = e.target.value;
        renderReceipts();
    });
}

function getFilteredGRNs() {
    return grns.filter(function (g) {
        var matchTab = activeStatusTab === 'all' || g.status === activeStatusTab;
        var matchSearch = g.id.toString().toLowerCase().indexOf(searchKeyword.toLowerCase()) > -1 || 
                          (g.supplier && g.supplier.toLowerCase().indexOf(searchKeyword.toLowerCase()) > -1) ||
                          (g.inboundCode && g.inboundCode.toLowerCase().indexOf(searchKeyword.toLowerCase()) > -1);
        return matchTab && matchSearch;
    });
}

function updateReceiptsKPIs() {
    var pendingCount = grns.filter(function(g) { return g.status === 'pending'; }).length;
    var inProgressCount = grns.filter(function(g) { return g.status === 'in_progress'; }).length;
    var completedCount = grns.filter(function(g) { return g.status === 'completed'; }).length;
    
    // Sum total received qty of all completed GRN items
    var skuReceivedCount = 0;
    grns.forEach(function(g) {
        if (g.status === 'completed') {
            g.items.forEach(function(item) {
                skuReceivedCount += (item.receivedQty || 0);
            });
        }
    });

    document.getElementById('stat-pending').textContent = pendingCount;
    document.getElementById('stat-in-progress').textContent = inProgressCount;
    document.getElementById('stat-completed').textContent = completedCount;
    document.getElementById('stat-sku-received').textContent = skuReceivedCount.toLocaleString();
}

function renderStatusTabs() {
    var counts = {
        all: grns.length,
        pending: grns.filter(function(g) { return g.status === 'pending'; }).length,
        in_progress: grns.filter(function(g) { return g.status === 'in_progress'; }).length,
        completed: grns.filter(function(g) { return g.status === 'completed'; }).length,
        cancelled: grns.filter(function(g) { return g.status === 'cancelled'; }).length
    };

    var tabsData = [
        { id: 'all', label: 'Tất cả' },
        { id: 'pending', label: 'Chờ' },
        { id: 'in_progress', label: 'Đang nhập' },
        { id: 'completed', label: 'Đã nhập' },
        { id: 'cancelled', label: 'Đã hủy' }
    ];

    var html = tabsData.map(function(tab) {
        var act = tab.id === activeStatusTab ? 'active' : '';
        return '<button class="status-tab-btn ' + act + '" onclick="window.selectStatusTab(\'' + tab.id + '\')">' +
            tab.label +
            '<span class="status-tab-badge">' + counts[tab.id] + '</span>' +
            '</button>';
    }).join('');

    var tabsContainer = document.getElementById('statusTabsContainer');
    if (tabsContainer) tabsContainer.innerHTML = html;
}

window.selectStatusTab = function(statusId) {
    activeStatusTab = statusId;
    renderReceipts();
};

window.viewGRNDetail = function(grnId, event) {
    if (event) event.stopPropagation();
    expandedGrnId = expandedGrnId == grnId ? null : grnId;
    renderReceipts();
};

window.toggleGrnExpand = function(grnId) {
    expandedGrnId = expandedGrnId == grnId ? null : grnId;
    renderReceipts();
};

window.toggleDropdownMenu = function(grnId, event) {
    if (event) event.stopPropagation();

    var menu = document.getElementById('dropdown-' + grnId);
    if (!menu) return;

    var wasOpen = menu.dataset.open === '1';

    // Close all menus first
    var allMenus = document.querySelectorAll('.dropdown-menu');
    allMenus.forEach(function(m) {
        m.classList.remove('active');
        m.removeAttribute('style'); // clear fixed positioning
        m.dataset.open = '0';
    });

    // If it was already active, just close it and stop
    if (wasOpen) {
        return;
    }

    // Position the menu using fixed coordinates relative to the trigger button
    var btn = event ? event.currentTarget : null;
    
    // Set display block first so we can measure offsetHeight
    menu.classList.add('active');
    
    if (btn) {
        var rect = btn.getBoundingClientRect();
        menu.style.position = 'fixed';
        menu.style.zIndex = '9999';
        
        var menuHeight = menu.offsetHeight || 120;
        var spaceBelow = window.innerHeight - rect.bottom;
        
        if (spaceBelow < menuHeight + 10 && rect.top > menuHeight + 10) {
            // Position above the button
            menu.style.top = 'auto';
            menu.style.bottom = (window.innerHeight - rect.top + 8) + 'px';
        } else {
            // Position below the button
            menu.style.top = (rect.bottom + 8) + 'px';
            menu.style.bottom = 'auto';
        }
        
        menu.style.right = (window.innerWidth - rect.right) + 'px';
        menu.style.left = 'auto';
    }

    menu.dataset.open = '1';
};


// Close menus when clicking outside
document.addEventListener('click', function(e) {
    if (!e.target.closest('.dropdown-wrap') && !e.target.closest('.dropdown-menu')) {
        var allMenus = document.querySelectorAll('.dropdown-menu');
        allMenus.forEach(function(m) {
            m.classList.remove('active');
            m.removeAttribute('style');
            m.dataset.open = '0';
        });
    }
});


function getStatusConfig(status) {
    var configs = {
        pending: { label: "Chờ hàng về", bg: "pending", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>' },
        in_progress: { label: "Đang nhập kho", bg: "in_progress", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 17V3"/><path d="m6 11 6 6 6-6"/><path d="M19 21H5"/></svg>' },
        completed: { label: "Hoàn thành", bg: "completed", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>' },
        cancelled: { label: "Đã hủy", bg: "cancelled", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>' }
    };
    return configs[status] || configs.pending;
}

function renderReceipts() {
    localStorage.setItem('wh_inbound_grns', JSON.stringify(grns));
    updateReceiptsKPIs();
    renderStatusTabs();

    var filtered = getFilteredGRNs();
    var listContainer = document.getElementById('grnListContainer');
    
    if (filtered.length === 0) {
        listContainer.innerHTML = '<div style="background:#fff; border:1px dashed var(--border); border-radius:12px; padding:48px; text-align:center; color:rgba(16, 55, 92, 0.40); font-weight:500; font-size:13px;">Không tìm thấy phiếu nhập kho nào.</div>';
        return;
    }

    var html = filtered.map(function(grn) {
        var sc = getStatusConfig(grn.status);
        var isExpanded = expandedGrnId == grn.id;
        var totalOrdered = grn.items.reduce(function(sum, i) { return sum + i.orderedQty; }, 0);
        var totalReceived = grn.items.reduce(function(sum, i) { return sum + i.receivedQty; }, 0);

        var expandedClass = isExpanded ? 'expanded' : '';
        
        // Locked indicator
        var lockHtml = (grn.isLocked && grn.status === 'draft') ?
            '<span class="pill-badge draft" style="margin-left:8px;">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:10px;height:10px;margin-right:2px;"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>' +
            'Khóa</span>' : '';

        // Inbound action button (pending waits for BM / in_progress can receive)
        var receiveBtn = '';
        var isDbBacked = (typeof grn.id === 'number') || /^\d+$/.test(String(grn.id));
        if (isDbBacked) {
            if (grn.status === 'in_progress') {
                receiveBtn = '<button class="btn-action-grn btn-action-emerald" onclick="window.dbOpenReceiveModal(\'' + grn.id + '\', \'' + (grn.inboundCode || grn.id) + '\', event)">Nhập kho</button>';
            }
        } else {
            if (grn.status === 'pending' || grn.status === 'in_progress' || grn.status === 'confirmed') {
                receiveBtn = '<button class="btn-action-grn" onclick="openReceiveModal(\'' + grn.id + '\', event)">Nhập kho</button>';
            }
        }

        // Eye action button (view detail - for all statuses)
        var detailBtn =
            '<button class="btn-action-icon" onclick="openDetailModal(\'' + grn.id + '\', event)" title="Xem chi tiết">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/></svg>' +
            '</button>';

        // Dropdown actions menu (đã bỏ "Trình duyệt BM" — phiếu mới thẳng IN_PROGRESS)
        var dropdownHtml = '';
        if (grn.status === 'pending' || grn.status === 'in_progress') {
            dropdownHtml =
                '<button class="dropdown-btn" onclick="openDetailModal(\'' + grn.id + '\', event)">' +
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/></svg>' +
                    'Xem chi tiết' +
                '</button>';
        }


        var menuActions = '';
        if (grn.status === 'draft' && !grn.isLocked) {
            menuActions = 
                '<div class="dropdown-wrap">' +
                    '<button class="btn-action-icon" onclick="window.toggleDropdownMenu(\'' + grn.id + '\', event)" title="Thao tác">' +
                        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"/><circle cx="12" cy="5" r="1"/><circle cx="12" cy="19" r="1"/></svg>' +
                    '</button>' +
                    '<div class="dropdown-menu" id="dropdown-' + grn.id + '">' +
                        '<button class="dropdown-btn" onclick="window.editDraftGRN(\'' + grn.id + '\', event)">' +
                            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 1 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>' +
                            'Chỉnh sửa' +
                        '</button>' +
                        '<button class="dropdown-btn" style="color:#dc2626;" onclick="window.deleteDraftGRN(\'' + grn.id + '\', event)">' +
                            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>' +
                            'Xoá nháp' +
                        '</button>' +
                        dropdownHtml +
                    '</div>' +
                '</div>';
        }


        // Expanded table rows
        var itemsRows = grn.items.map(function(item) {
            var pct = Math.round((item.receivedQty / item.orderedQty) * 100);
            var remaining = item.orderedQty - item.receivedQty;
            var barColor = pct === 100 ? '#10b981' : pct > 0 ? '#F5C842' : 'var(--border)';
            var remainingClass = remaining > 0 ? 'color: var(--orange); font-weight:600;' : 'color: #047857; font-weight:600;';
            var priceHtml = item.price ? item.price.toLocaleString('vi-VN') + ' đ' : '—';

            return '<tr>' +
                '<td><span style="font-family:monospace; color:rgba(16, 55, 92, 0.6);">' + item.skuCode + '</span></td>' +
                '<td><span style="color:var(--navy); font-weight:600;">' + item.skuName + '</span></td>' +
                '<td style="text-align:right; font-weight:600; color:var(--navy); white-space:nowrap;">' + priceHtml + '</td>' +
                '<td style="text-align:right; font-weight:600; color:var(--navy);">' + item.orderedQty + '</td>' +
                '<td style="text-align:right; font-weight:600; color:#047857;">' + item.receivedQty + '</td>' +
                '<td style="text-align:right; ' + remainingClass + '">' + remaining + '</td>' +
                '<td><div style="display:flex; align-items:center; gap:8px;">' +
                    '<div class="progress-bar-wrap"><div class="progress-bar-fill" style="width:' + pct + '%; background:' + barColor + ';"></div></div>' +
                    '<span style="font-size:10px; color:rgba(16, 55, 92, 0.4); min-width:24px; text-align:right;">' + pct + '%</span>' +
                '</div></td>' +
            '</tr>';
        }).join('');

        // Notes box
        var notesBox = grn.note ? 
            '<div class="grn-notes-bar">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="4" x2="20" y1="9" y2="9"/><line x1="4" x2="20" y1="15" y2="15"/><line x1="10" x2="8" y1="3" y2="21"/><line x1="16" x2="14" y1="3" y2="21"/></svg>' +
                '<span>' + grn.note + '</span>' +
            '</div>' : '';

        // Receiver bar
        var receiverBox = grn.receivedBy ?
            '<div class="grn-user-bar">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>' +
                '<span>Người nhập kho: <span style="font-weight:600; color:var(--navy);">' + grn.receivedBy + '</span></span>' +
            '</div>' : '';

        return '<div class="grn-item ' + expandedClass + '">' +
            '<!-- Header -->' +
            '<div class="grn-hdr" onclick="window.toggleGrnExpand(\'' + grn.id + '\')">' +
                '<div class="grn-hdr__icon ' + 'tone-' + (grn.status === 'completed' ? 'emerald' : grn.status === 'in_progress' ? 'orange' : grn.status === 'pending' ? 'blue' : 'navy') + '">' +
                    sc.icon +
                '</div>' +
                '<div class="grn-hdr__info">' +
                    '<div class="grn-meta-row">' +
                        '<span class="grn-id">' + (grn.inboundCode || grn.id) + '</span>' +
                        '<span class="pill-badge ' + grn.status + '"><span class="pill-badge__dot"></span>' + sc.label + '</span>' +
                        lockHtml +
                    '</div>' +
                    '<div class="grn-supplier-row">' +
                        '<span class="grn-supplier-cell">' +
                            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 22V4a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v18Z"/><path d="M6 12H4a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h2Z"/><path d="M18 9h2a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2h-2Z"/></svg>' +
                            grn.supplier +
                        '</span>' +
                        '<span>' + grn.createdAt + '</span>' +
                    '</div>' +
                '</div>' +
                '<div class="grn-stats-row">' +
                    '<div class="grn-stat">' +
                        '<div class="grn-stat__lbl">SKU</div>' +
                        '<div class="grn-stat__val">' + grn.items.length + '</div>' +
                    '</div>' +
                    '<div class="grn-stat">' +
                        '<div class="grn-stat__lbl">Nhập / Đặt</div>' +
                        '<div class="grn-stat__val">' +
                            '<span style="' + (totalReceived === totalOrdered ? 'color:#059669;' : '') + '">' + totalReceived + '</span>' +
                            '<span style="font-size:11px; color:rgba(16, 55, 92, 0.3);">/' + totalOrdered + '</span>' +
                        '</div>' +
                    '</div>' +
                    detailBtn +
                    receiveBtn +
                    menuActions +
                    '<svg class="grn-chevron" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>' +
                '</div>' +
            '</div>' +
            
            '<!-- Expanded Body -->' +
            '<div class="grn-body">' +
                '<table class="grn-body-table">' +
                    '<thead>' +
                        '<tr>' +
                            '<th style="width: 140px;">SKU</th>' +
                            '<th>Tên sản phẩm</th>' +
                            '<th style="width: 100px; text-align: right;">Đơn giá</th>' +
                            '<th style="width: 80px; text-align: right;">Đặt</th>' +
                            '<th style="width: 80px; text-align: right;">Đã nhập</th>' +
                            '<th style="width: 80px; text-align: right;">Còn lại</th>' +
                            '<th style="width: 140px;">Tiến độ</th>' +
                        '</tr>' +
                    '</thead>' +
                    '<tbody>' +
                        itemsRows +
                    '</tbody>' +
                '</table>' +
                notesBox +
                receiverBox +
            '</div>' +
        '</div>';
    }).join('');

    listContainer.innerHTML = html;
}

// ─── DRAFT MODAL ACTIONS ───
var draftOverlay = document.getElementById('draftModalOverlay');

window.openDraftModal = function(mode, sourceId) {
    draftMode = mode;
    draftSourceId = sourceId || null;
    
    var titleEl = document.getElementById('draftModalTitle');
    var supplierInput = document.getElementById('draft-supplier');
    var dateInput = document.getElementById('draft-date');
    var noteInput = document.getElementById('draft-note');
    
    if (mode === 'create') {
        titleEl.textContent = 'Tạo phiếu mua hàng';
        draftForm = {
            supplier: '',
            expectedDate: '',
            note: '',
            items: [{ skuCode: '', skuName: '', orderedQty: 10, price: 0 }]
        };
    } else { // duplicate
        var source = grns.find(function(g) { return g.id == sourceId; });
        titleEl.textContent = 'Nhân bản phiếu nhập';
        draftForm = {
            supplier: source ? source.supplier : '',
            expectedDate: source ? source.expectedDate : '',
            note: source ? (source.note || '') : '',
            items: source ? source.items.map(function(item) {
                return { skuCode: item.skuCode, skuName: item.skuName, orderedQty: item.orderedQty, price: item.price || 0 };
            }) : []
        };
    }
    
    // Fill values
    supplierInput.value = draftForm.supplier;
    dateInput.value = draftForm.expectedDate;
    noteInput.value = draftForm.note;
    
    renderDraftRows();
    draftOverlay.classList.add('active');
};

window.closeDraftModal = function() {
    draftOverlay.classList.remove('active');
};

window.duplicateGRN = function(grnId, event) {
    if (event) event.stopPropagation();
    openDraftModal('duplicate', grnId);
};

window.editDraftGRN = function(grnId, event) {
    if (event) event.stopPropagation();
    var grn = grns.find(function(g) { return g.id == grnId; });
    if (!grn) return;
    
    // Close any open dropdown
    var allMenus = document.querySelectorAll('.dropdown-menu');
    allMenus.forEach(function(m) { m.classList.remove('active'); });
    
    draftMode = 'edit';
    draftSourceId = grnId;
    
    var titleEl = document.getElementById('draftModalTitle');
    titleEl.textContent = 'Chỉnh sửa phiếu nhập nháp';
    draftForm = {
        supplier: grn.supplier || '',
        expectedDate: grn.expectedDate || '',
        note: grn.note || '',
        items: grn.items.map(function(item) {
            return { skuCode: item.skuCode, skuName: item.skuName, orderedQty: item.orderedQty, price: item.price || 0, receivedQty: item.receivedQty || 0 };
        })
    };
    if (draftForm.items.length === 0) {
        draftForm.items.push({ skuCode: '', skuName: '', orderedQty: 10, price: 0 });
    }
    
    document.getElementById('draft-supplier').value = draftForm.supplier;
    document.getElementById('draft-date').value = draftForm.expectedDate;
    document.getElementById('draft-note').value = draftForm.note;
    
    renderDraftRows();
    draftOverlay.classList.add('active');
    
    // Override submit to update existing draft instead of creating new
    var submitBtn = document.querySelector('#draftModalOverlay .modal-btn-submit');
    if (submitBtn) {
        submitBtn.onclick = function() {
            // Update the draft in grns array
            var idx = grns.findIndex(function(g) { return g.id == grnId; });
            if (idx > -1) {
                var supplierVal = document.getElementById('draft-supplier').value.trim();
                var dateVal = document.getElementById('draft-date').value;
                var noteVal = document.getElementById('draft-note').value.trim();
                if (!supplierVal || !dateVal) {
                    alert('Vui lòng nhập đầy đủ Nhà cung cấp và Ngày dự kiến!');
                    return;
                }
                var validItems = draftForm.items.filter(function(i) { return i.skuCode && i.orderedQty > 0; }).map(function(i) {
                    return {
                        skuCode: i.skuCode,
                        skuName: i.skuName,
                        orderedQty: parseFloat(i.orderedQty || 0),
                        receivedQty: parseFloat(i.receivedQty || 0),
                        price: parseFloat(i.price || 0)
                    };
                });
                if (validItems.length === 0) {
                    alert('Vui lòng chọn ít nhất một SKU hợp lệ!');
                    return;
                }
                grns[idx].supplier = supplierVal;
                grns[idx].expectedDate = dateVal;
                grns[idx].note = noteVal;
                grns[idx].items = validItems;
                closeDraftModal();
                renderReceipts();
                alert('Đã cập nhật phiếu nhập nháp!');
            }
            // Restore default submit
            submitBtn.onclick = submitDraftGRN;
        };
    }
};

window.deleteDraftGRN = function(grnId, event) {
    if (event) event.stopPropagation();
    // Close any open dropdown
    var allMenus = document.querySelectorAll('.dropdown-menu');
    allMenus.forEach(function(m) { m.classList.remove('active'); m.dataset.open = '0'; });
    if (!confirm('Bạn có chắc chắn muốn xoá bản nháp "' + grnId + '" không?')) return;
    grns = grns.filter(function(g) { return g.id != grnId; });
    localStorage.setItem('wh_inbound_grns', JSON.stringify(grns));
    renderReceipts();
};

window.addDraftItemRow = function() {
    draftForm.items.push({ skuCode: '', skuName: '', orderedQty: 10, price: 0 });
    renderDraftRows();
};

window.removeDraftItemRow = function(index) {
    if (draftForm.items.length > 1) {
        draftForm.items.splice(index, 1);
        renderDraftRows();
    }
};

window.updateDraftRowSku = function(index, skuCode) {
    var item = skus.find(function(s) { return s.sku === skuCode; });
    draftForm.items[index].skuCode = skuCode;
    draftForm.items[index].skuName = item ? item.name : '';
    
    // Re-render only inputs names to prevent focus loss, or re-render fully
    renderDraftRows();
};

window.updateDraftRowQty = function(index, qty) {
    draftForm.items[index].orderedQty = parseInt(qty) || 0;
};

window.updateDraftRowPrice = function(index, price) {
    draftForm.items[index].price = parseFloat(price) || 0;
};

function renderDraftRows() {
    var container = document.getElementById('draftRowsContainer');
    
    // Build select options of approved SKUs
    var approvedSkus = skus.filter(function(s) { return !s.approvalStatus || s.approvalStatus === 'approved'; });
    
    var html = draftForm.items.map(function(rowItem, index) {
        var skuOptions = approvedSkus.map(function(s) {
            var selected = rowItem.skuCode === s.sku ? 'selected' : '';
            return '<option value="' + s.sku + '" ' + selected + '>' + s.sku + ' (' + s.name.substring(0, 20) + '...)</option>';
        }).join('');
        
        var selectHtml = 
            '<select class="sku-select-input" onchange="window.updateDraftRowSku(' + index + ', this.value)">' +
                '<option value="">-- Chọn SKU --</option>' +
                skuOptions +
            '</select>';

        return '<div class="draft-row">' +
            '<div>' + selectHtml + '</div>' +
            '<div><input class="form-input" style="background:#f1f5f9; border-color:var(--border);" type="text" readonly value="' + rowItem.skuName + '" placeholder="Tên sản phẩm tự điền"/></div>' +
            '<div><input class="form-input" style="text-align:right; background:#fff;" type="number" min="0" placeholder="Giá nhập..." value="' + (rowItem.price || '') + '" onchange="window.updateDraftRowPrice(' + index + ', this.value)"/></div>' +
            '<div><input class="form-input" style="text-align:center; background:#fff;" type="number" min="1" value="' + rowItem.orderedQty + '" onchange="window.updateDraftRowQty(' + index + ', this.value)"/></div>' +
            '<div style="text-align:right;"><button class="btn-del-row" onclick="window.removeDraftItemRow(' + index + ')">&times;</button></div>' +
        '</div>';
    }).join('');
    
    container.innerHTML = html;
}

window.submitDraftGRN = function() {
    var supplierInput = document.getElementById('draft-supplier').value.trim();
    var dateInput = document.getElementById('draft-date').value;
    var noteInput = document.getElementById('draft-note').value.trim();

    if (!supplierInput || !dateInput) {
        alert('Vui lòng nhập đầy đủ Nhà cung cấp và Ngày dự kiến!');
        return;
    }

    var validItems = draftForm.items.filter(function(i) {
        return i.skuCode && i.orderedQty > 0;
    }).map(function(i) {
        return {
            skuCode: i.skuCode,
            skuName: i.skuName,
            orderedQty: i.orderedQty,
            receivedQty: 0,
            price: i.price || 0
        };
    });

    if (validItems.length === 0) {
        alert('Vui lòng chọn ít nhất một SKU hợp lệ với số lượng lớn hơn 0!');
        return;
    }

    var btn = document.getElementById('btnSubmitGRN');
    btn.disabled = true;
    btn.textContent = 'Đang tạo...';

    fetch('${pageContext.request.contextPath}/warehouse/inbound', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
            action: 'create',
            supplierName: supplierInput,
            expectedDate: dateInput,
            notes: noteInput || '',
            itemsJson: JSON.stringify(validItems)
        })
    }).then(function(res) {
        if (res.redirected) {
            window.location.href = res.url;
        } else {
            window.location.reload();
        }
    }).catch(function() {
        btn.disabled = false;
        btn.textContent = 'Tạo phiếu & Nhập kho';
        alert('Lỗi kết nối. Vui lòng thử lại.');
    });
};

// ─── ACTION BUTTONS ───
window.submitForBMAvailability = function(grnId, event) {
    if (event) event.stopPropagation();
    var grn = grns.find(function(g) { return g.id == grnId; });
    if (grn) {
        // Remove from local storage drafts to prevent duplicate on reload
        grns = grns.filter(function(g) { return g.id != grnId; });
        localStorage.setItem('wh_inbound_grns', JSON.stringify(grns));

        var form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/warehouse/inbound';

        var actionInput = document.createElement('input');
        actionInput.type = 'hidden';
        actionInput.name = 'action';
        actionInput.value = 'create';
        form.appendChild(actionInput);

        var supplierInput = document.createElement('input');
        supplierInput.type = 'hidden';
        supplierInput.name = 'supplierName';
        supplierInput.value = grn.supplier;
        form.appendChild(supplierInput);

        var whInput = document.createElement('input');
        whInput.type = 'hidden';
        whInput.name = 'warehouseId';
        whInput.value = window.WMS_USER.myWarehouseId || 1;
        form.appendChild(whInput);

        var dateInput = document.createElement('input');
        dateInput.type = 'hidden';
        dateInput.name = 'expectedDate';
        dateInput.value = grn.expectedDate || '';
        form.appendChild(dateInput);

        var noteInput = document.createElement('input');
        noteInput.type = 'hidden';
        noteInput.name = 'notes';
        noteInput.value = grn.note || '';
        form.appendChild(noteInput);

        var itemsInput = document.createElement('input');
        itemsInput.type = 'hidden';
        itemsInput.name = 'itemsJson';
        itemsInput.value = JSON.stringify(grn.items);
        form.appendChild(itemsInput);

        document.body.appendChild(form);
        form.submit();
    }
};

window.cancelDraftGRN = function(grnId, event) {
    if (event) event.stopPropagation();
    if (confirm('Bạn có chắc chắn muốn hủy bản nháp phiếu nhập này không?')) {
        var grn = grns.find(function(g) { return g.id == grnId; });
        if (grn) {
            grn.status = 'cancelled';
            grn.isLocked = true;
            renderReceipts();
        }
    }
};

// ─── RECEIVE GOODS MODAL ───
var receiveOverlay = document.getElementById('receiveModalOverlay');
var receiveQuantities = {};

window.openReceiveModal = function(grnId, event) {
    if (event) event.stopPropagation();
    var grn = grns.find(function(g) { return g.id == grnId; });
    if (!grn) return;
    
    document.getElementById('receive-grn-id').value = grnId;
    document.getElementById('receiveModalSubtitle').textContent = grnId + ' · ' + grn.supplier;
    
    receiveQuantities = {};
    
    var container = document.getElementById('receiveItemsContainer');
    var html = grn.items.map(function(item) {
        // Default to remaining ordered quantity
        var defaultReceived = item.orderedQty - item.receivedQty;
        var defaultAccepted = defaultReceived;
        var defaultRejected = 0;
        var safeId = item.skuCode.replace(/[^a-zA-Z0-9]/g, '_');

        receiveQuantities[item.skuCode] = {
            received: defaultReceived,
            accepted: defaultAccepted,
            rejected: defaultRejected
        };
        
        return '<div class="receive-item-card">' +
            '<div style="flex:1;">' +
                '<div style="font-weight:700; color:var(--navy); font-size:13px;">' + item.skuName + '</div>' +
                '<div style="font-family:monospace; color:rgba(16, 55, 92, 0.5); font-size:11px;">' + item.skuCode + '</div>' +
                '<div style="font-size:11px; color:rgba(16, 55, 92, 0.4); margin-top:2px;">Số lượng đặt: <strong style="color:var(--navy);">' + item.orderedQty + '</strong> (Đã nhận: ' + item.receivedQty + ')</div>' +
            '</div>' +
            '<div style="display:flex; align-items:center; gap:8px;">' +
                '<div style="display:flex;flex-direction:column;align-items:center;gap:2px;">' +
                    '<label style="font-size:10px;font-weight:700;color:rgba(16,55,92,0.55);">THỰC NHẬN</label>' +
                    '<input class="price-input" style="width:75px;" type="number" min="0" max="' + defaultReceived + '" value="' + defaultReceived + '" ' +
                        'id="recv-received-' + safeId + '" ' +
                        'onchange="window.updateReceiveQty(\'' + item.skuCode + '\', \'received\', this.value)"/>' +
                '</div>' +
                '<div style="display:flex;flex-direction:column;align-items:center;gap:2px;">' +
                    '<label style="font-size:10px;font-weight:700;color:#10b981;">CHẤP NHẬN</label>' +
                    '<input class="price-input" style="width:75px;" type="number" min="0" max="' + defaultReceived + '" value="' + defaultAccepted + '" ' +
                        'id="recv-accepted-' + safeId + '" ' +
                        'onchange="window.updateReceiveQty(\'' + item.skuCode + '\', \'accepted\', this.value)"/>' +
                '</div>' +
                '<div style="display:flex;flex-direction:column;align-items:center;gap:2px;">' +
                    '<label style="font-size:10px;font-weight:700;color:#dc2626;">TỪ CHỐI</label>' +
                    '<div id="recv-rejected-' + safeId + '" style="width:75px;padding:6px 8px;background:#fef2f2;border:1px solid #fca5a5;border-radius:6px;text-align:center;font-size:13px;font-weight:600;color:#dc2626;">' + defaultRejected + '</div>' +
                '</div>' +
            '</div>' +
        '</div>';
    }).join('');
    
    container.innerHTML = html;
    receiveOverlay.classList.add('active');
};

window.updateReceiveQty = function(skuCode, field, value) {
    var safeId = skuCode.replace(/[^a-zA-Z0-9]/g, '_');
    var num = parseInt(value) || 0;

    if (!receiveQuantities[skuCode]) {
        receiveQuantities[skuCode] = { received: 0, accepted: 0, rejected: 0 };
    }
    receiveQuantities[skuCode][field] = num;

    var maxAccepted = receiveQuantities[skuCode].received;
    if (field === 'received') {
        // Adjust accepted/rejected accordingly
        var accepted = parseInt(document.getElementById('recv-accepted-' + safeId).value) || 0;
        if (accepted > num) {
            receiveQuantities[skuCode].accepted = num;
            document.getElementById('recv-accepted-' + safeId).value = num;
            accepted = num;
        }
        receiveQuantities[skuCode].rejected = 0;
        document.getElementById('recv-rejected-' + safeId).textContent = 0;
    } else if (field === 'accepted') {
        var received = receiveQuantities[skuCode].received;
        var rejected = Math.max(0, received - num);
        receiveQuantities[skuCode].rejected = rejected;
        document.getElementById('recv-rejected-' + safeId).textContent = rejected;
        if (num > received) {
            receiveQuantities[skuCode].accepted = received;
            document.getElementById('recv-accepted-' + safeId).value = received;
        }
    }

    // Update rejected display color
    var rejected = receiveQuantities[skuCode].rejected;
    var rejectedDiv = document.getElementById('recv-rejected-' + safeId);
    if (rejectedDiv) {
        rejectedDiv.style.color = rejected > 0 ? '#dc2626' : '#6b7280';
    }
};

window.closeReceiveModal = function() {
    receiveOverlay.classList.remove('active');
};

window.submitConfirmReceive = function() {
    var grnId = document.getElementById('receive-grn-id').value;
    var grn = grns.find(function(g) { return g.id == grnId; });
    if (!grn) return;
    
    var now = new Date();
    var timeStr = now.getFullYear() + '-' +
                       padZero(now.getMonth()+1) + '-' +
                       padZero(now.getDate()) + ' ' +
                       padZero(now.getHours()) + ':' +
                       padZero(now.getMinutes());

    // Update quantities on items
    grn.items.forEach(function(item) {
        var qtyData = receiveQuantities[item.skuCode] || { received: 0, accepted: 0, rejected: 0 };
        var addedReceived = qtyData.received;
        var addedAccepted = qtyData.accepted;
        var addedRejected = qtyData.rejected;

        item.receivedQty = (item.receivedQty || 0) + addedReceived;
        item.acceptedQty = (item.acceptedQty || 0) + addedAccepted;
        item.rejectedQty = (item.rejectedQty || 0) + addedRejected;

        if (addedAccepted > 0) {
            // Only accepted quantity goes to stock
            logInventoryLedger(item.skuCode, 'inbound', addedAccepted, grnId, 'GRN', 'Nhập thực tế từ ' + grn.supplier);
            updateMasterSkuQty(item.skuCode, addedAccepted);
        }
    });
    
    // Check if fully received
    var allCompleted = grn.items.every(function(item) {
        return item.receivedQty >= item.orderedQty;
    });
    
    grn.status = allCompleted ? 'completed' : 'in_progress';
    grn.receivedBy = window.WMS_USER.fullName || 'Nhân viên kho';
    
    closeReceiveModal();
    renderReceipts();
    alert('Xác nhận nhập kho phiếu ' + grnId + ' thành công!');
};

function updateMasterSkuQty(skuCode, addedQty) {
    var currentSKUs = safeJsonParse(localStorage.getItem('wms_skus'), []);
    var index = currentSKUs.findIndex(function(s) { return s.sku === skuCode; });
    if (index > -1) {
        currentSKUs[index].qtyOnHand = (currentSKUs[index].qtyOnHand || 0) + addedQty;
        currentSKUs[index].lastUpdated = new Date().toISOString().slice(0, 16).replace("T", " ");
        currentSKUs[index].updatedBy = window.WMS_USER.fullName || 'Nhân viên kho';
        localStorage.setItem('wms_skus', JSON.stringify(currentSKUs));
        skus = currentSKUs; // sync local variable
    }
}

// ─── HELPERS ───
function logInventoryLedger(sku, type, quantity, referenceId, referenceType, notes) {
    var ledgerStr = localStorage.getItem('wh_inventory_ledger');
    var ledger = safeJsonParse(ledgerStr, []);

    var entry = {
        id: 'LEG-' + Date.now() + '-' + Math.random().toString(36).substring(2, 9),
        sku: sku,
        type: type,
        quantity: quantity,
        warehouseId: 'WH001',
        zone: '',
        location: '',
        referenceId: referenceId,
        referenceType: referenceType,
        notes: notes,
        createdAt: new Date().toISOString(),
        createdBy: window.WMS_USER.fullName || 'Nhân viên kho'
    };

    ledger.push(entry);
    localStorage.setItem('wh_inventory_ledger', JSON.stringify(ledger));
}

// ─── DETAIL MODAL VIEW ───
var detailOverlay = document.getElementById('detailModalOverlay');

window.openDetailModal = function(grnId, event) {
    if (event) event.stopPropagation();
    var grn = grns.find(function(g) { return g.id == grnId; });
    if (!grn) return;
    
    document.getElementById('detailModalSubtitle').textContent = grn.inboundCode || grn.id;
    document.getElementById('detail-supplier').textContent = grn.supplier;
    document.getElementById('detail-created-at').textContent = grn.createdAt;
    document.getElementById('detail-expected-date').textContent = grn.expectedDate;
    
    // Status badge
    var sc = getStatusConfig(grn.status);
    document.getElementById('detail-status-badge').innerHTML = 
        '<span class="pill-badge ' + grn.status + '"><span class="pill-badge__dot"></span>' + sc.label + '</span>';
        
    // Notes block
    var notesBox = document.getElementById('detail-notes-box');
    if (grn.note) {
        document.getElementById('detail-note-content').textContent = grn.note;
        notesBox.style.display = 'block';
    } else {
        notesBox.style.display = 'none';
    }
    
    // Items table
    var tbody = document.getElementById('detailItemsTableBody');
    var isCompleted = (grn.status === 'completed');
    var html = grn.items.map(function(item) {
        var priceHtml = item.price ? item.price.toLocaleString('vi-VN') + ' đ' : '—';
        // SL thực nhận = SL cộng vào tồn kho (đã loại bỏ QC/accepted/rejected).
        var received = parseFloat(item.receivedQty || 0);
        var ordered = parseFloat(item.orderedQty || 0);
        var returnedNcc = Math.max(0, ordered - received);
        var lineTotal = (item.price && received) ? (item.price * received).toLocaleString('vi-VN') + ' đ' : '—';
        var returnedHtml = returnedNcc > 0
            ? '<span style="color:#b45309; font-weight:700;">' + returnedNcc + '</span>'
            : '<span style="color:rgba(16,55,92,0.3);">0</span>';
        return '<tr>' +
            '<td style="white-space:nowrap;"><span style="font-family:monospace; font-size:11px; color:rgba(16,55,92,0.6);">' + escapeHtml(item.skuCode) + '</span></td>' +
            '<td><span style="font-weight:600; color:var(--navy);">' + escapeHtml(item.skuName) + '</span></td>' +
            '<td style="text-align:right; font-weight:600; color:var(--navy); white-space:nowrap;">' + priceHtml + '</td>' +
            '<td style="text-align:right; font-weight:600; white-space:nowrap;">' + ordered + '</td>' +
            '<td style="text-align:right; font-weight:600; white-space:nowrap; color:#047857;">' + received + '</td>' +
            '<td style="text-align:right; white-space:nowrap;">' + returnedHtml + '</td>' +
            '<td style="text-align:right; font-weight:700; color:var(--navy); white-space:nowrap; padding-right:16px;">' + lineTotal + '</td>' +
        '</tr>';
    }).join('');
    tbody.innerHTML = html;
    
    detailOverlay.classList.add('active');
};

window.closeDetailModal = function() {
    detailOverlay.classList.remove('active');
};

// Close detail and other overlays when clicking background
[draftOverlay, receiveOverlay, detailOverlay].forEach(function(ov) {
    if (ov) {
        ov.addEventListener('click', function(e) {
            if (e.target === ov) {
                ov.classList.remove('active');
            }
        });
    }
});

// ─── HELPERS ───
function padZero(n) { return n < 10 ? '0' + n : n; }

// ─── INIT ───
renderReceipts();

// ─── DB-SIDE INBOUND TABLE (from WarehouseInboundServlet) ───
function dbStatusLabel(status) {
    var m = {
        'PENDING':    { label: 'Chờ',        cls: 'pending' },
        'IN_PROGRESS':{ label: 'Đang nhập',   cls: 'confirmed' },
        'CONFIRMED':  { label: 'Đã xác nhận', cls: 'confirmed' },
        'RECEIVED':   { label: 'Đã nhập',     cls: 'received' },
        'CANCELLED':  { label: 'Đã hủy',      cls: 'cancelled' }
    };
    var c = m[status] || { label: status, cls: 'pending' };
    return '<span class="status-pill ' + c.cls + '"><span class="status-pill__dot"></span>' + c.label + '</span>';
}

// DB Inbound counts (for filter tabs)
function dbCounts() {
    return {
        all:         grns.length,
        pending:     grns.filter(function(o){ return o.status === 'pending'; }).length,
        in_progress: grns.filter(function(o){ return o.status === 'in_progress'; }).length,
        completed:   grns.filter(function(o){ return o.status === 'completed'; }).length,
        cancelled:   grns.filter(function(o){ return o.status === 'cancelled'; }).length
    };
}

// Update filter tab counts if elements exist
var counts = dbCounts();
var dbCountAll = document.getElementById('db-count-all');
if (dbCountAll) {
    dbCountAll.textContent = counts.all;
    document.getElementById('db-count-pending').textContent = counts.pending;
    document.getElementById('db-count-in_progress').textContent = counts.in_progress;
    document.getElementById('db-count-completed').textContent = counts.completed;
    document.getElementById('db-count-cancelled').textContent = counts.cancelled;
}

function esc(v) {
    if (v == null) return '';
    return String(v).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

var tabs = document.getElementById('dbFilterTabs');
if (tabs) {
    tabs.addEventListener('click', function(e) {
        var btn = e.target.closest('.db-filter-btn');
        if (!btn) return;
        activeStatusTab = btn.dataset.filter;
        tabs.querySelectorAll('.db-filter-btn').forEach(function(b) { b.classList.remove('active'); });
        btn.classList.add('active');
        renderReceipts();
    });
}

window.openCreatePOModal = function() {
    document.getElementById('createPOModal').classList.add('active');
};
window.closeCreatePOModal = function() {
    document.getElementById('createPOModal').classList.remove('active');
};

window.dbOpenReceiveModal = function(id, code, event) {
    if (event) event.stopPropagation();
    var grn = grns.find(function(g) { return g.id == id; });
    if (!grn) return;

    document.getElementById('receiveDB-inboundId').value = id;
    document.getElementById('receiveDB-subtitle').textContent = 'Mã phiếu mua: ' + code;

    var container = document.getElementById('receiveDBItemsContainer');
    var html = grn.items.map(function(item) {
        var defaultVal = item.orderedQty - item.receivedQty;
        if (defaultVal < 0) defaultVal = 0;
        var returnedNccDefault = 0;
        return '<div class="receive-item-card" style="padding:12px 16px; background:#f8fafc; border:1px solid var(--border); border-radius:8px; margin-bottom:8px;">' +
            '<div style="display:flex; justify-content:space-between; align-items:flex-start; gap:16px;">' +
            '<div style="flex:1;">' +
                '<div style="font-weight:700; color:var(--navy); font-size:13px;">' + esc(item.skuName) + '</div>' +
                '<div style="font-family:monospace; color:rgba(16, 55, 92, 0.5); font-size:11px;">' + esc(item.skuCode) + '</div>' +
                    '<div style="font-size:11px; color:rgba(16, 55, 92, 0.4); margin-top:2px;">Đặt: <strong style="color:var(--navy);">' + item.orderedQty + '</strong> · Đã nhận: <strong style="color:#047857;">' + item.receivedQty + '</strong></div>' +
            '</div>' +
                '<div style="display:flex; align-items:center; gap:8px; flex-shrink:0;">' +
                '<input type="hidden" name="productId" value="' + item.productId + '"/>' +
                    '<input type="hidden" name="unitCost" value="' + (item.price || 0) + '"/>' +
                    '<div style="display:flex; flex-direction:column; align-items:center; gap:2px;">' +
                        '<label style="font-size:10px; font-weight:700; color:#1d4ed8;">SL THỰC NHẬN</label>' +
                        '<input class="price-input" style="width:80px; padding:5px; border:1px solid var(--border); border-radius:4px; text-align:right; font-size:13px; font-weight:600; color:#1d4ed8;" type="number" name="receivedQty" min="0" max="' + defaultVal + '" value="' + defaultVal + '" data-ordered="' + item.orderedQty + '" data-already-received="' + (item.receivedQty || 0) + '" onchange="window.syncReturnNcc(this)"/>' +
                    '</div>' +
                    '<div style="display:flex; flex-direction:column; align-items:center; gap:2px;">' +
                        '<label style="font-size:10px; font-weight:700; color:#b45309;">TRẢ NCC TẠI CHỖ</label>' +
                        '<div class="returned-ncc-cell" style="width:80px; padding:5px 6px; background:#fffbeb; border:1px solid #fde68a; border-radius:4px; text-align:right; font-size:13px; font-weight:600; color:#b45309; min-height:33px; line-height:1.5;">' + Math.max(0, item.orderedQty - (item.receivedQty || 0) - defaultVal) + '</div>' +
                    '</div>' +
                '</div>' +
            '</div>' +
        '</div>';
    }).join('');

    container.innerHTML = html;
    document.getElementById('receiveDBModal').classList.add('active');
};

window.closeReceiveDBModal = function() {
    document.getElementById('receiveDBModal').classList.remove('active');
};

// Auto-calc "Trả NCC tại chỗ" = PO đặt - SL thực nhận
window.syncReturnNcc = function(inputEl) {
    var ordered = parseFloat(inputEl.getAttribute('data-ordered')) || 0;
    var alreadyReceived = parseFloat(inputEl.getAttribute('data-already-received')) || 0;
    var receivedNow = parseFloat(inputEl.value) || 0;
    // Tổng SL thực nhận cộng dồn (đã nhận trước đó + lần này)
    var totalReceived = alreadyReceived + receivedNow;
    var returned = Math.max(0, ordered - totalReceived);
    var cell = inputEl.parentElement.parentElement.querySelector('.returned-ncc-cell');
    if (cell) cell.textContent = returned;
};

['createPOModal', 'receiveDBModal'].forEach(function(id) {
    var el = document.getElementById(id);
    if (el) {
        el.addEventListener('click', function(e) {
            if (e.target === el) {
                el.classList.remove('active');
            }
        });
    }
});

// renderDbTable() removed since it is not defined and merged into renderReceipts()

var createBtn = document.getElementById('btnCreateGRNTrigger');
if (createBtn) {
    createBtn.addEventListener('click', function() {
        openDraftModal('create');
    });
}

// Auto-open create modal if action=create parameter is found
var params = new URLSearchParams(window.location.search);
if (params.get('action') === 'create') {
    var prefilledSku = params.get('sku') || '';
    setTimeout(function() {
        if (typeof openDraftModal === 'function') {
            openDraftModal('create');
            if (prefilledSku && draftForm && draftForm.items && draftForm.items[0]) {
                var foundItem = skus.find(function(s) { return s.sku === prefilledSku; });
                draftForm.items[0].skuCode = prefilledSku;
                draftForm.items[0].skuName = foundItem ? foundItem.name : '';
                if (typeof renderDraftRows === 'function') renderDraftRows();
            }
        }
    }, 300);
}
})();

</script>
