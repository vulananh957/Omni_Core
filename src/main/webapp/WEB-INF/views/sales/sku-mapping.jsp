<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="com.wms.model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    if (products == null) products = java.util.Collections.emptyList();

    ObjectMapper mapper = new ObjectMapper();
    String productsJson = mapper.valueToTree(products).toString();
    request.setAttribute("productsJson", productsJson);
%>

<%-- ══════════════════════════════════════════════════════════════════
     Sales Staff — Trung Tâm Ánh Xạ SKU Đa Sàn (SKU Mapping Center)
     JSP port of React: SKUMapping.tsx
     All logic is pure vanilla JS — no hardcoded data, no seed data.
     ══════════════════════════════════════════════════════════════════ --%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sales--sku-mapping.css"/>

<%-- ── STATS CARDS — populated by JSP on first load; updated by JS on subsequent renders ── --%>
<div class="sm-stats-grid">
    <div class="sm-stat-card">
        <div class="sm-stat-icon-wrapper blue">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg>
        </div>
        <div>
            <div class="sm-stat-num" id="statTotalMaster">${totalMappings}</div>
            <div class="sm-stat-label">Tổng Ánh Xạ SKU (Database)</div>
        </div>
    </div>
    <div class="sm-stat-card">
        <div class="sm-stat-icon-wrapper orange">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
        </div>
        <div>
            <div class="sm-stat-num" id="statUnmapped">${pendingMappings}</div>
            <div class="sm-stat-label">Ánh xạ PENDING / ERROR</div>
        </div>
    </div>
    <div class="sm-stat-card">
        <div class="sm-stat-icon-wrapper emerald">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
        </div>
        <div>
            <div class="sm-stat-num" id="statMappings">${syncedMappings}</div>
            <div class="sm-stat-label">Ánh xạ SYNCED</div>
        </div>
    </div>
</div>

<%-- ── TABS BAR ── --%>
<div class="sm-tab-bar">
    <div class="sm-tab-buttons">
        <button class="sm-tab active" id="tabUnmapped" onclick="switchTab('unmapped')">
            SẢN PHẨM CHƯA ÁNH XẠ (UNMAPPED SKUs)
            <span class="sm-tab-badge" id="badgeUnmappedCount" style="margin-left:4px;display:none">0</span>
        </button>
        <button class="sm-tab" id="tabMapped" onclick="switchTab('mapped')">
            DANH SÁCH ĐÃ ÁNH XẠ (MAPPED SKUs)
        </button>
    </div>
    <div>
        <button class="sm-btn-pull" onclick="pullMarketplaceProducts()" id="btnPullProducts">
            <svg id="pullSpinnerIcon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.5 2v6h-6M21.34 15.57a10 10 0 1 1-.57-8.38l5.67-5.67"></path></svg>
            Kéo sản phẩm từ Sàn
        </button>
        <button class="sm-btn-pull" onclick="suggestMappings()" id="btnSuggestMappings" style="margin-left:0.5rem" title="Tự động gợi ý ánh xạ dựa trên seller_sku ↔ sku_code">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            Gợi ý ánh xạ
        </button>
    </div>
</div>

<%-- ── SEARCH FILTER TOOLBAR ── --%>
<div class="sm-filter-bar">
    <div class="sm-search">
        <svg class="sm-search-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line>
        </svg>
        <input type="text" placeholder="Tìm theo mã sàn, tên SP trên sàn..." id="smSearchInput" oninput="onSearch(this.value)" />
    </div>
    <select class="sm-select" id="smChannelFilter" onchange="onChannelFilterChange(this.value)" style="min-width:140px">
        <option value="">Tất cả kênh</option>
        <c:forEach var="ch" items="${channels}">
            <option value="${ch.channelId}">${ch.channelName} (${ch.platform})</option>
        </c:forEach>
    </select>
</div>

<%-- ── DATA GRID TABLE ── --%>
<div class="sm-table-card">
    <%-- Pulling loading overlay --%>
    <div class="sm-pull-overlay" id="smPullOverlay">
        <div class="sm-loader-spinner"></div>
        <div style="font-size: 13px; font-weight: 700; color: var(--navy)">Đang kết nối API Gateway Sandbox đa sàn...</div>
        <div style="font-size: 10px; color: rgba(16,55,92,.4); margin-top: 4px">Đang kéo các sản phẩm chưa gán ánh xạ từ Shopee, Lazada, TikTok API...</div>
    </div>

    <div class="sm-table-scroll">
        <table class="sm-table">
            <thead>
                <tr id="smTableHeader">
                    <%-- Populated by JS for unmapped/mapped tabs --%>
                </tr>
            </thead>
            <tbody id="smTableBody">
                <%-- Populated by JS for unmapped/mapped tabs --%>
            </tbody>
        </table>
    </div>
</div>

<%-- ── MAPPING CONFIG DIALOG MODAL ── --%>
<div class="sm-modal-overlay" id="smMappingModalOverlay" onclick="closeMappingModal()">
    <div class="sm-modal" onclick="event.stopPropagation()">
        <div class="sm-modal-header">
            <div class="sm-modal-title">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path></svg>
                Cấu hình Ánh xạ sản phẩm đa kênh
            </div>
            <button class="sm-modal-close" onclick="closeMappingModal()">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
            </button>
        </div>
        <div class="sm-modal-body">
            <%-- PART 1: CHANNEL ITEM INFO --%>
            <div class="sm-channel-box">
                <div class="sm-channel-box-title">1. Sản phẩm trên Sàn (Channel Item)</div>
                <div style="display:grid;grid-template-columns: 1fr 1fr; gap:12px; font-size:13px">
                    <div>
                        <div style="color:rgba(16,55,92,.4);font-size:10px">Kênh bán hàng</div>
                        <strong id="mdChannelName">-</strong>
                    </div>
                    <div>
                        <div style="color:rgba(16,55,92,.4);font-size:10px">Mã SKU trên sàn (Mã Sàn)</div>
                        <strong id="mdChannelSKU" style="font-family:monospace">-</strong>
                    </div>
                </div>
                <div style="border-top:1px solid rgba(229,234,243,.6); margin-top:8px; padding-top:8px; font-size:13px">
                    <div style="color:rgba(16,55,92,.4);font-size:10px">Tên SP hiển thị trên sàn</div>
                    <strong id="mdChannelItemName" style="color:var(--navy)">-</strong>
                </div>
            </div>

            <%-- PART 2: WMS MASTER SKU ALLOCATIONS --%>
            <div>
                <div class="sm-mapping-section-header">
                    <span class="sm-mapping-section-title">2. Liên kết với Master SKU nội bộ (Hệ thống WMS)</span>
                    <button class="sm-btn-add-row" onclick="addLinkedRow()" id="btnModalAddRow">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                        Thêm mã nội bộ
                    </button>
                </div>
                <div id="mdLinkedRowsContainer">
                    <%-- Dynamic allocation rows --%>
                </div>
            </div>
        </div>
        <div class="sm-modal-footer">
            <button class="sm-btn white" onclick="closeMappingModal()">HỦY</button>
            <button class="sm-btn primary" onclick="saveMappingConfig()" id="btnModalSave">LƯU</button>
        </div>
    </div>
</div>

<%-- ── NOTIFICATION TOAST POPUP ── --%>
<div class="op-toast" id="opToast" style="position: fixed; top: 2rem; right: 2rem; background: var(--navy); color: #fff; padding: 1rem 1.5rem; border-radius: var(--radius-btn); box-shadow: 0 10px 25px rgba(0,0,0,.15); z-index: 120; font-size: 13px; font-weight: 700; display: flex; align-items: center; gap: 0.75rem; transform: translateY(-20px); opacity: 0; pointer-events: none; transition: all .25s ease-out;">
    <svg id="opToastIcon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="width:16px;height:16px"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
    <span id="opToastMsg">Thông báo hệ thống</span>
</div>

<%
    // Clear session toast after displaying
    if (request.getSession().getAttribute("toastMessage") != null) {
        request.getSession().removeAttribute("toastMessage");
        request.getSession().removeAttribute("toastSuccess");
    }
%>
<div id="productsJsonData" style="display:none;"><c:out value="${productsJson}"/></div>

<script>
// ── GLOBALS ─────────────────────────────────────────────────────────
let activeTab = "unmapped";
let searchQuery = "";
let channelFilter = "";

let APPROVED_MASTER_SKUS = [];
let unmappedList = [];
let rawMappings = [];

let selectedUnmappedProduct = null;
let modalLinkedRows = [];

// ── INIT DOMContentLoaded ──────────────────────────────────────────
document.addEventListener("DOMContentLoaded", function() {
    loadDataFromStorage();
    renderAll();

    // Server-side toast from session
    const toastMsg = "<c:out value='${sessionScope.toastMessage}' />";
    const toastSuccess = "<c:out value='${sessionScope.toastSuccess}' />";
    if (toastMsg && toastMsg !== "") {
        showToast(toastMsg, toastSuccess === "true" ? "success" : "error");
    }

    window.addEventListener("ORDER_STORE_UPDATED", function() {
        loadDataFromStorage();
        renderAll();
    });
});

function loadDataFromStorage() {
    // 1. Mappings intermediate join table
    const storedMappings = localStorage.getItem("sku_raw_mappings_v2");
    if (storedMappings) {
        try { rawMappings = JSON.parse(storedMappings); } catch(e) { rawMappings = []; }
    } else {
        rawMappings = [];
        localStorage.setItem("sku_raw_mappings_v2", JSON.stringify([]));
    }
    
    // 2. Unmapped pool
    const storedPool = localStorage.getItem("sku_unmapped_pool_v2");
    if (storedPool) {
        try { unmappedList = JSON.parse(storedPool); } catch(e) { unmappedList = []; }
    } else {
        unmappedList = []; // Empty initially
    }

    // 3. Approved WMS Master SKUs
    const prodElem = document.getElementById("productsJsonData");
    if (prodElem && prodElem.textContent.trim()) {
        try {
            const parsed = JSON.parse(prodElem.textContent.trim());
            APPROVED_MASTER_SKUS = parsed.map(p => {
                return {
                    id: p.productId,
                    sku: p.sku || p.skuCode || '',
                    name: p.name || p.productName || '',
                    category: p.categoryName || '',
                    qtyOnHand: p.qtyOnHand || 0
                };
            });
        } catch(e) {
            console.error("Failed to parse database products in sku-mapping:", e);
            APPROVED_MASTER_SKUS = [];
        }
    } else {
        const savedSKUs = localStorage.getItem("wms_skus");
        if (savedSKUs) {
            try {
                APPROVED_MASTER_SKUS = JSON.parse(savedSKUs);
            } catch(e) {
                APPROVED_MASTER_SKUS = [];
            }
        } else {
            APPROVED_MASTER_SKUS = [];
        }
    }
}

function saveOrdersToStorage() {
    localStorage.setItem("sku_raw_mappings_v2", JSON.stringify(rawMappings));
    localStorage.setItem("sku_unmapped_pool_v2", JSON.stringify(unmappedList));
    // Trigger sync
    window.dispatchEvent(new CustomEvent("ORDER_STORE_UPDATED"));
}

function getSKUTotalStock(skuCode) {
    const ps = JSON.parse(localStorage.getItem('wh_pricing_sales') || '[]');
    const record = ps.find(p => p.sku === skuCode);
    if (record) {
        if (record.warehouseStock) {
            let total = 0;
            for (let key in record.warehouseStock) {
                total += record.warehouseStock[key] || 0;
            }
            return total;
        }
        if (record.qtyAvailable !== undefined) return record.qtyAvailable;
        if (record.qtyOnHand !== undefined) return record.qtyOnHand;
    }
    
    // Fallback to wms_skus record
    const wmsItem = APPROVED_MASTER_SKUS.find(item => item.sku === skuCode);
    return wmsItem ? (wmsItem.qtyOnHand || 0) : 0;
}

// ── TOAST NOTIFICATIONS POPUP ──
function showToast(msg, type = "success") {
    const toast = document.getElementById("opToast");
    const label = document.getElementById("opToastMsg");
    const icon = document.getElementById("opToastIcon");
    
    if (type === "success") {
        toast.style.background = "#059669";
        icon.innerHTML = `<path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline>`;
    } else {
        toast.style.background = "#dc2626";
        icon.innerHTML = `<circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line>`;
    }
    label.textContent = msg;
    
    toast.style.opacity = 1;
    toast.style.transform = "translateY(0)";
    setTimeout(() => {
        toast.style.opacity = 0;
        toast.style.transform = "translateY(-20px)";
    }, 4000);
}

// ── RENDER & SWITCH TABS ─────────────────────────────────────────────
function switchTab(tabId) {
    activeTab = tabId;

    document.querySelectorAll(".sm-tab").forEach(btn => btn.classList.remove("active"));
    if (tabId === "unmapped") document.getElementById("tabUnmapped").classList.add("active");
    if (tabId === "mapped") document.getElementById("tabMapped").classList.add("active");

    const searchInp = document.getElementById("smSearchInput");
    if (tabId === "unmapped") {
        searchInp.placeholder = "Tìm theo mã sàn, tên SP trên sàn...";
    } else if (tabId === "mapped") {
        searchInp.placeholder = "Tìm theo Master SKU, tên SP gốc WMS...";
    }

    renderAll();
}

function renderAll() {
    renderStats();
    renderTabBadges();
    renderTableHeader();
    renderTableBody();
}

function renderStats() {
    document.getElementById("statTotalMaster").textContent = APPROVED_MASTER_SKUS.length;
    document.getElementById("statUnmapped").textContent = unmappedList.length;
    document.getElementById("statMappings").textContent = rawMappings.length;
}

function renderTabBadges() {
    const badge = document.getElementById("badgeUnmappedCount");
    if (unmappedList.length > 0) {
        badge.textContent = unmappedList.length;
        badge.style.display = "inline-block";
    } else {
        badge.style.display = "none";
    }
}

function onSearch(val) {
    searchQuery = val.trim().toLowerCase();
    renderAll();
}

function onChannelFilterChange(val) {
    channelFilter = val;
}

// ── MARKETPLACE PRODUCT PULL — calls server which delegates to LazadaProductService ──
async function pullMarketplaceProducts() {
    const chId = document.getElementById("smChannelFilter").value;
    if (!chId) {
        showToast("Vui lòng chọn kênh cần kéo sản phẩm trước.", "error");
        return;
    }

    const overlay = document.getElementById("smPullOverlay");
    const icon = document.getElementById("pullSpinnerIcon");
    const btn = document.getElementById("btnPullProducts");
    overlay.classList.add("open");
    icon.style.animation = "spin 1s linear infinite";
    btn.disabled = true;

    try {
        // Fire-and-forget: the server processes this in the background.
        const res = await fetch("${pageContext.request.contextPath}/sales/channel-products?action=pull&channelId=" + chId);
        if (!res.ok) {
            showToast("Kéo sản phẩm thất bại: HTTP " + res.status, "error");
        } else {
            showToast("Đã gửi yêu cầu kéo sản phẩm. Vui lòng đợi vài phút rồi refresh trang.", "success");
        }
    } catch (e) {
        showToast("Lỗi kết nối: " + e.message, "error");
    } finally {
        overlay.classList.remove("open");
        icon.style.animation = "none";
        btn.disabled = false;
    }
}

// ── AUTO-SUGGEST MAPPING — calls SkuMappingSuggestService ──
async function suggestMappings() {
    const chId = document.getElementById("smChannelFilter").value;
    if (!chId) {
        showToast("Vui lòng chọn kênh trước.", "error");
        return;
    }
    try {
        const res = await fetch("${pageContext.request.contextPath}/sales/sku-mapping?action=suggest&channelId=" + chId);
        if (!res.ok) {
            showToast("Lỗi HTTP " + res.status, "error");
            return;
        }
        const data = await res.json();
        showToast("Đã tạo gợi ý cho " + data.length + " SKU chưa ánh xạ. Mở tab Unmapped để xem chi tiết.", "success");
    } catch (e) {
        showToast("Lỗi: " + e.message, "error");
    }
}

// ── RENDER DYNAMIC TABLES ────────────────────────────────────────────
function renderTableHeader() {
    const header = document.getElementById("smTableHeader");

    let html = "";
    if (activeTab === "unmapped") {
        html = `
            <th style="width: 120px">Kênh Bán</th>
            <th style="width: 160px">Mã SKU Sàn (Channel SKU)</th>
            <th style="width: 280px">Tên sản phẩm trên Sàn</th>
            <th style="width: 320px">Mô tả chi tiết sàn</th>
            <th style="width: 120px; text-align: center">Hành Động</th>
        `;
    } else {
        html = `
            <th style="width: 144px">Master SKU</th>
            <th style="width: 250px">Tên sản phẩm gốc WMS</th>
            <th style="width: 160px">Ngành hàng</th>
            <th style="width: 128px; text-align: center">Lazada</th>
            <th style="width: 128px; text-align: center">Website</th>
            <th style="width: 144px; text-align: right">Tồn kho khả dụng</th>
        `;
    }
    header.innerHTML = html;
}

function renderTableBody() {
    const tbody = document.getElementById("smTableBody");
    tbody.innerHTML = "";

    if (activeTab === "unmapped") {
        const filtered = unmappedList.filter(item => {
            if (!searchQuery) return true;
            return (item.channelSKU && item.channelSKU.toLowerCase().indexOf(searchQuery) > -1) ||
                   (item.channelItemName && item.channelItemName.toLowerCase().indexOf(searchQuery) > -1);
        });

        if (filtered.length === 0) {
            tbody.innerHTML = '<tr>' +
                '<td colspan="5" class="op-empty">' +
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><line x1="9" y1="9" x2="15" y2="15"></line><line x1="15" y1="9" x2="9" y2="15"></line></svg>' +
                    (unmappedList.length === 0 ? "Không có sản phẩm sàn nào. Vui lòng nhấn nút [ Kéo sản phẩm từ Sàn ] ở góc trên để tải." : "Không tìm thấy sản phẩm sàn nào khớp với từ khóa tìm kiếm.") +
                '</td>' +
            '</tr>';
            return;
        }

        filtered.forEach(item => {
            const tr = document.createElement("tr");
            tr.innerHTML = '<td>' +
                    '<span class="sm-badge-channel" style="background:' + (item.channelColor || '#64748b') + '">' +
                        item.channel +
                    '</span>' +
                '</td>' +
                '<td><span style="font-weight:700;font-family:monospace">' + item.channelSKU + '</span></td>' +
                '<td><span style="font-weight:600">' + item.channelItemName + '</span></td>' +
                '<td><span style="color:rgba(16,55,92,.6);font-size:11.5px;display:block;white-space:nowrap;text-overflow:ellipsis;overflow:hidden;max-width:300px">' + item.desc + '</span></td>' +
                '<td style="text-align:center">' +
                    '<button class="sm-btn-action" onclick="openMappingModal(\'' + item.id + '\')">' +
                        '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"/></svg>' +
                        'Ánh Xạ' +
                    '</button>' +
                '</td>';
            tbody.appendChild(tr);
        });
        
    } else { // mapped tab
        const filtered = APPROVED_MASTER_SKUS.filter(wms => {
            // Check if has mapped relations
            const matchedRels = rawMappings.filter(m => m.masterSKU === wms.sku);
            if (matchedRels.length === 0) return false;
            
            if (!searchQuery) return true;
            return (wms.sku && wms.sku.toLowerCase().indexOf(searchQuery) > -1) ||
                   (wms.name && wms.name.toLowerCase().indexOf(searchQuery) > -1);
        });
        
        if (filtered.length === 0) {
            tbody.innerHTML = '<tr>' +
                '<td colspan="8" class="op-empty">' +
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><line x1="9" y1="9" x2="15" y2="15"></line><line x1="15" y1="9" x2="9" y2="15"></line></svg>' +
                    (APPROVED_MASTER_SKUS.length === 0 
                        ? 'Không tìm thấy Master SKU đã duyệt nào trong hệ thống. Vui lòng vào trang quản lý Master SKU để tạo và duyệt sản phẩm trước.' 
                        : 'Không có sản phẩm nào đã gán ánh xạ phù hợp.'
                    ) +
                '</td>' +
            '</tr>';
            return;
        }
        
        filtered.forEach(wms => {
            const tr = document.createElement("tr");
            const rels = rawMappings.filter(m => m.masterSKU === wms.sku);
            
            const getChannelRelsHtml = (chan) => {
                const matched = rels.filter(r => r.channel.toLowerCase().indexOf(chan.toLowerCase()) > -1);
                if (matched.length === 0) return '<span style="color:rgba(16,55,92,.2)">—</span>';
                return '<div style="display:flex;flex-direction:column;align-items:center;gap:6px">' +
                    matched.map(m => 
                        '<div class="sm-mapped-pill" title="Mã SKU Sàn: ' + m.channelSKU + ' - Click để hủy liên kết">' +
                            '<span class="sm-mapped-sku">' + m.channelSKU + '</span>' +
                            (m.conversionRate > 1 ? '<span class="sm-conversion-tag">x' + m.conversionRate + '</span>' : '') +
                            '<span class="sm-unlink-btn" onclick="event.stopPropagation(); deleteMapping(\'' + m.mappingId + '\')">' +
                                '<svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>' +
                            '</span>' +
                        '</div>'
                    ).join('') +
                '</div>';
            };
            
            const qty = getSKUTotalStock(wms.sku);
            
            tr.innerHTML = '<td><span style="font-family:monospace;font-weight:700">' + wms.sku + '</span></td>' +
                '<td><strong style="color:var(--navy)">' + wms.name + '</strong></td>' +
                '<td><span style="color:rgba(16,55,92,.6)">' + (wms.category || 'Chưa phân loại') + '</span></td>' +
                '<td style="text-align:center">' + getChannelRelsHtml('lazada') + '</td>' +
                '<td style="text-align:center">' + getChannelRelsHtml('website') + '</td>' +
                '<td style="text-align:right"><strong style="font-size:13.5px">' + qty.toLocaleString() + '</strong></td>';
            tbody.appendChild(tr);
        });
    }
}

// ── UNLINK/DELETE MAPPING RELATION ────────────────────────────────────
function deleteMapping(mappingId) {
    if (confirm("Bạn có chắc chắn muốn hủy liên kết ánh xạ này không?")) {
        rawMappings = rawMappings.filter(m => m.mappingId !== mappingId);
        localStorage.setItem("sku_raw_mappings_v2", JSON.stringify(rawMappings));
        
        // Also remove from channel products grid
        const stored = localStorage.getItem("channel_products_v2");
        if (stored) {
            try {
                let products = JSON.parse(stored);
                products = products.filter(p => p.id !== "p_" + mappingId);
                localStorage.setItem("channel_products_v2", JSON.stringify(products));
            } catch(e) {
                console.error(e);
            }
        }
        
        saveOrdersToStorage();
        renderAll();
        showToast("Đã hủy liên kết ánh xạ thành công!", "success");
    }
}

// ── MAPPING MODAL CONTROLS ───────────────────────────────────────────
function openMappingModal(id) {
    const item = unmappedList.find(x => x.id === id);
    if (!item) return;
    
    selectedUnmappedProduct = item;
    
    // Header channel details
    document.getElementById("mdChannelName").textContent = item.channel;
    document.getElementById("mdChannelName").style.color = item.channelColor || "#10375c";
    document.getElementById("mdChannelSKU").textContent = item.channelSKU;
    document.getElementById("mdChannelItemName").textContent = item.channelItemName;
    
    // Check if approved master SKUs list is empty
    if (APPROVED_MASTER_SKUS.length === 0) {
        document.getElementById("btnModalAddRow").disabled = true;
        document.getElementById("btnModalSave").disabled = true;
        document.getElementById("mdLinkedRowsContainer").innerHTML = `
            <div style="padding: 1.5rem; text-align: center; color: #dc2626; font-size:12.5px; font-weight:700; background:#fef2f2; border:1px solid #fecaca; border-radius:8px">
                Không tìm thấy WMS Master SKU nào đã được phê duyệt! <br/>Vui lòng liên hệ Admin/Warehouse Staff để phê duyệt sản phẩm trước.
            </div>
        `;
    } else {
        document.getElementById("btnModalAddRow").disabled = false;
        document.getElementById("btnModalSave").disabled = false;
        modalLinkedRows = [{ masterSKU: APPROVED_MASTER_SKUS[0].sku, conversionRate: 1 }];
        renderModalRows();
    }
    
    document.getElementById("smMappingModalOverlay").classList.add("open");
}

function closeMappingModal() {
    document.getElementById("smMappingModalOverlay").classList.remove("open");
    selectedUnmappedProduct = null;
    modalLinkedRows = [];
}

function renderModalRows() {
    const container = document.getElementById("mdLinkedRowsContainer");
    container.innerHTML = "";
    
    modalLinkedRows.forEach((row, idx) => {
        const div = document.createElement("div");
        div.className = "sm-row-card";
        
        let selectOptionsHtml = "";
        APPROVED_MASTER_SKUS.forEach(sku => {
            selectOptionsHtml += '<option value="' + sku.sku + '" ' + (sku.sku === row.masterSKU ? 'selected' : '') + '>' + sku.name + ' (' + sku.sku + ')</option>';
        });
        
        div.innerHTML = '<div style="flex:1;min-width:0">' +
                '<span class="sm-field-label">Chọn sản phẩm gốc kho WMS</span>' +
                '<select class="sm-select" onchange="updateLinkedRow(' + idx + ', \'masterSKU\', this.value)">' +
                    selectOptionsHtml +
                '</select>' +
            '</div>' +
            '<div style="width:80px;flex-shrink:0">' +
                '<span class="sm-field-label" style="text-align:center">Tỉ lệ</span>' +
                '<input type="number" class="sm-input" min="1" value="' + row.conversionRate + '" onchange="updateLinkedRow(' + idx + ', \'conversionRate\', this.value)"/>' +
            '</div>' +
            (modalLinkedRows.length > 1 ? 
                '<div style="padding-top:14px;flex-shrink:0">' +
                    '<button class="sm-btn-remove" onclick="removeLinkedRow(' + idx + ')">' +
                        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>' +
                    '</button>' +
                '</div>'
             : '');
        container.appendChild(div);
    });
}

function addLinkedRow() {
    if (APPROVED_MASTER_SKUS.length === 0) return;
    modalLinkedRows.push({ masterSKU: APPROVED_MASTER_SKUS[0].sku, conversionRate: 1 });
    renderModalRows();
}

function removeLinkedRow(idx) {
    if (modalLinkedRows.length <= 1) return;
    modalLinkedRows.splice(idx, 1);
    renderModalRows();
}

function updateLinkedRow(idx, field, value) {
    if (field === "masterSKU") {
        modalLinkedRows[idx].masterSKU = value;
    } else {
        modalLinkedRows[idx].conversionRate = Math.max(1, parseInt(value) || 1);
    }
}

// ── SAVE MAPPINGS INTERACTION ────────────────────────────────────────
function syncMappingToChannelProducts(mappingId, masterSKU, channelName, channelSKU, productName, stock, description) {
    const stored = localStorage.getItem("channel_products_v2");
    let products = [];
    if (stored) {
        try { products = JSON.parse(stored); } catch (e) { products = []; }
    }
    
    const channelColors = {
        Shopee: "#EE4D2D",
        TikTok: "#69C9D0",
        "TikTok Shop": "#69C9D0",
        Lazada: "#0F146D",
        Website: "#EB8317"
    };
    const chan = channelName.toLowerCase().replace(" shop", "");
    const exists = products.some(p => p.masterSKU === masterSKU && p.channel === chan);
    
    if (!exists) {
        const newItem = {
            id: "p_" + mappingId, // Binds to mappingId so it deletes nicely
            masterSKU: masterSKU,
            channelSKU: channelSKU,
            channel: chan,
            channelName: channelName.replace(" Shop", ""),
            channelColor: channelColors[channelName] || "#64748b",
            productName: productName,
            description: description || (productName + " - Kết nối ánh xạ đa sàn."),
            images: [
                chan === "shopee" 
                ? "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&auto=format&fit=crop" 
                : chan === "lazada" 
                    ? "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&auto=format&fit=crop" 
                    : "https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400&auto=format&fit=crop"
            ],
            price: chan === "shopee" ? 250000 : chan === "lazada" ? 220000 : 190000,
            status: "active",
            stock: stock,
            channelItemId: chan.toUpperCase().slice(0,3) + "-ITEM-" + Math.floor(100000 + Math.random() * 900000),
            bufferStock: 0,
            syncStatus: "success"
        };
        products.push(newItem);
        localStorage.setItem("channel_products_v2", JSON.stringify(products));
    }
}

function saveMappingConfig() {
    if (modalLinkedRows.length === 0) {
        alert("Vui lòng thêm ít nhất một liên kết Master SKU!");
        return;
    }
    
    modalLinkedRows.forEach(row => {
        const matched = APPROVED_MASTER_SKUS.find(wms => wms.sku === row.masterSKU);
        const mapId = "map_" + Date.now() + "_" + Math.floor(100 + Math.random() * 900);
        
        rawMappings.push({
            mappingId: mapId,
            masterSKU: row.masterSKU,
            masterName: matched ? matched.name : "Sản phẩm gốc",
            channel: selectedUnmappedProduct.channel,
            channelSKU: selectedUnmappedProduct.channelSKU,
            channelItemName: selectedUnmappedProduct.channelItemName,
            conversionRate: row.conversionRate
        });
        
        // Sync to channel products database
        const stockQty = getSKUTotalStock(row.masterSKU);
        syncMappingToChannelProducts(
            mapId,
            row.masterSKU,
            selectedUnmappedProduct.channel,
            selectedUnmappedProduct.channelSKU,
            selectedUnmappedProduct.channelItemName,
            stockQty || 100,
            selectedUnmappedProduct.desc
        );
    });
    
    // Save unmapped pool reduction
    unmappedList = unmappedList.filter(item => item.id !== selectedUnmappedProduct.id);
    
    saveOrdersToStorage();
    closeMappingModal();
    renderAll();
    showToast("Thiết lập ánh xạ Nhiều-Nhiều và các quy tắc Combo quy đổi thành công!", "success");
}
</script>
