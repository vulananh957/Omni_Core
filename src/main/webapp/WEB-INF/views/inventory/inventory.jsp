<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    /* ─── Stats Grid ─── */
    .stats-grid-3 {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }
    @media (max-width: 768px) {
        .stats-grid-3 { grid-template-columns: 1fr; }
    }

    .stat-card {
        background: #fff;
        border: 1px solid var(--border);
        padding: 16px;
        border-radius: var(--radius-card);
    }
    .stat-card__inner {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .stat-card__icon {
        width: 40px;
        height: 40px;
        border-radius: var(--radius-btn);
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }
    .stat-card__icon svg {
        width: 20px;
        height: 20px;
    }
    .stat-card__val {
        font-size: 22px;
        font-weight: 700;
        color: var(--navy);
        line-height: 1.1;
    }
    .stat-card__lbl {
        color: rgba(16, 55, 92, 0.50);
        font-size: 12px;
        margin-top: 2px;
    }

    /* Card color themes */
    .theme-red .stat-card__icon { background: #FEF2F2; }
    .theme-red .stat-card__icon svg { color: #ef4444; }
    .theme-yellow .stat-card__icon { background: rgba(245, 200, 66, 0.10); }
    .theme-yellow .stat-card__icon svg { color: var(--orange); }
    .theme-navy .stat-card__icon { background: rgba(16, 55, 92, 0.10); }
    .theme-navy .stat-card__icon svg { color: var(--navy); }

    /* ─── Filters Bar ─── */
    .filter-bar {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 16px;
        flex-wrap: wrap;
    }
    .search-input-wrap {
        position: relative;
        flex: 1;
        min-width: 240px;
    }
    .search-input-wrap svg {
        position: absolute;
        left: 12px;
        top: 50%;
        transform: translateY(-50%);
        width: 16px;
        height: 16px;
        color: rgba(16, 55, 92, 0.30);
        pointer-events: none;
    }
    .search-input {
        width: 100%;
        padding: 8px 16px 8px 40px;
        background: #fff;
        border: 1px solid var(--border);
        font-size: 13px;
        color: var(--navy);
        outline: none;
        transition: border-color 0.15s;
        border-radius: calc(var(--radius-btn) - 2px);
    }
    .search-input::placeholder { color: rgba(16, 55, 92, 0.30); }
    .search-input:focus { border-color: rgba(16, 55, 92, 0.30); }

    .select-wrap {
        position: relative;
    }
    .select-wrap svg {
        position: absolute;
        left: 12px;
        top: 50%;
        transform: translateY(-50%);
        width: 14px;
        height: 14px;
        color: rgba(16, 55, 92, 0.30);
        pointer-events: none;
    }
    .filter-select {
        padding: 8px 32px 8px 36px;
        background: #fff;
        border: 1px solid var(--border);
        font-size: 13px;
        color: var(--navy);
        outline: none;
        cursor: pointer;
        border-radius: calc(var(--radius-btn) - 2px);
        appearance: none;
        min-width: 140px;
    }
    .filter-select:focus { border-color: rgba(16, 55, 92, 0.30); }

    .btn-sort {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 14px;
        background: #fff;
        border: 1px solid var(--border);
        font-size: 13px;
        font-weight: 500;
        color: rgba(16, 55, 92, 0.60);
        cursor: pointer;
        transition: color 0.15s;
        border-radius: calc(var(--radius-btn) - 2px);
    }
    .btn-sort:hover { color: var(--navy); }
    .btn-sort svg { width: 14px; height: 14px; }

    /* ─── Data Table ─── */
    .table-card {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        overflow: hidden;
    }
    .table-responsive { width: 100%; overflow-x: auto; }
    .wms-table { width: 100%; border-collapse: collapse; }
    .wms-table th {
        background: var(--alice);
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: rgba(16, 55, 92, 0.50);
        padding: 12px 16px;
        border-bottom: 1px solid var(--border);
        white-space: nowrap;
    }
    .wms-table td {
        padding: 14px 16px;
        border-bottom: 1px solid #F0F3FA;
        vertical-align: middle;
        font-size: 13px;
        color: var(--navy);
    }
    .wms-table tbody tr { transition: background 0.15s; }
    .wms-table tbody tr:hover { background: rgba(240, 244, 250, 0.50); }

    /* Cell styles */
    .sku-code { font-family: monospace; font-weight: 600; color: var(--navy); font-size: 13px; }
    .product-name { font-weight: 500; line-height: 1.4; max-width: 240px; }
    .warehouse-code { font-family: monospace; font-size: 12px; color: rgba(16, 55, 92, 0.60); }
    .warehouse-name { font-size: 12px; color: rgba(16, 55, 92, 0.60); }

    .qty-cell { display: flex; align-items: center; justify-content: flex-end; gap: 6px; }
    .qty-cell svg { width: 14px; height: 14px; color: var(--orange); flex-shrink: 0; }
    .qty-number { font-weight: 600; font-size: 13px; }
    .qty-number.critical { color: #ef4444; }
    .qty-number.warning { color: var(--orange); }
    .qty-number.safe { color: #059669; }

    /* Status badge */
    .status-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 4px 8px;
        font-size: 11px;
        font-weight: 600;
        border: 1px solid transparent;
        border-radius: calc(var(--radius-btn) - 4px);
    }
    .status-badge.critical { background: #FEF2F2; color: #ef4444; border-color: rgba(239, 68, 68, 0.20); }
    .status-badge.warning { background: rgba(245, 200, 66, 0.10); color: var(--orange); border-color: rgba(245, 158, 11, 0.20); }
    .status-badge.safe { background: #ECFDF5; color: #047857; border-color: rgba(16, 185, 129, 0.20); }

    /* Action buttons */
    .btn-bao-kho {
        display: flex;
        align-items: center;
        gap: 6px;
        padding: 6px 12px;
        font-size: 11px;
        font-weight: 600;
        border: none;
        cursor: pointer;
        border-radius: calc(var(--radius-btn) - 4px);
        color: #fff;
        transition: background 0.15s;
        margin: 0 auto;
    }
    .btn-bao-kho.bg-red { background: #ef4444; }
    .btn-bao-kho.bg-red:hover { background: #dc2626; }
    .btn-bao-kho.bg-navy { background: var(--navy); }
    .btn-bao-kho.bg-navy:hover { background: #0d2c4b; }
    .btn-bao-kho svg { width: 12px; height: 12px; }

    .btn-da-bao {
        display: flex;
        align-items: center;
        gap: 6px;
        padding: 6px 12px;
        font-size: 11px;
        font-weight: 600;
        border: 1px solid rgba(16, 185, 129, 0.20);
        background: #ECFDF5;
        color: #047857;
        border-radius: calc(var(--radius-btn) - 4px);
        cursor: default;
        margin: 0 auto;
    }
    .btn-da-bao svg { width: 12px; height: 12px; }

    /* Footer */
    .table-footer {
        padding: 16px 24px;
        background: var(--alice);
        border-top: 1px solid #F0F3FA;
        display: flex;
        align-items: center;
        justify-content: space-between;
        font-size: 12px;
        color: rgba(16, 55, 92, 0.60);
    }
</style>

<!-- ═══ Stats Grid ═══ -->
<div class="stats-grid-3">
    <!-- Critical -->
    <div class="stat-card theme-red">
        <div class="stat-card__inner">
            <div class="stat-card__icon">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/>
                    <line x1="12" x2="12" y1="9" y2="13"/><line x1="12" x2="12.01" y1="17" y2="17"/>
                </svg>
            </div>
            <div>
                <div class="stat-card__val" id="criticalCountEl">0</div>
                <div class="stat-card__lbl">Cảnh báo nghiêm trọng</div>
            </div>
        </div>
    </div>

    <!-- Warning -->
    <div class="stat-card theme-yellow">
        <div class="stat-card__inner">
            <div class="stat-card__icon">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/>
                    <line x1="12" x2="12" y1="9" y2="13"/><line x1="12" x2="12.01" y1="17" y2="17"/>
                </svg>
            </div>
            <div>
                <div class="stat-card__val" id="warningCountEl">0</div>
                <div class="stat-card__lbl">Cảnh báo sắp hết</div>
            </div>
        </div>
    </div>

    <!-- Total -->
    <div class="stat-card theme-navy">
        <div class="stat-card__inner">
            <div class="stat-card__icon">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="m7.5 4.27 9 5.15"/>
                    <path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"/>
                    <path d="m3.3 7 8.7 5 8.7-5"/><path d="M12 22V12"/>
                </svg>
            </div>
            <div>
                <div class="stat-card__val" id="totalCountEl">0</div>
                <div class="stat-card__lbl">Tổng dòng tồn kho</div>
            </div>
        </div>
    </div>
</div>

<!-- ═══ Filters ═══ -->
<div class="filter-bar">
    <div class="search-input-wrap">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>
        </svg>
        <input class="search-input" type="text" id="inventorySearch" placeholder="Tìm mã SKU, tên sản phẩm..."/>
    </div>

    <div class="select-wrap">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/>
        </svg>
        <select class="filter-select" id="whFilter">
            <option value="Tất cả">Tất cả kho</option>
            <c:forEach var="w" items="${warehouses}">
                <option value="${w.warehouseCode}">${w.warehouseCode}</option>
            </c:forEach>
        </select>
    </div>

    <div class="select-wrap">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/>
        </svg>
        <select class="filter-select" id="statusFilter">
            <option value="Tất cả">Tất cả trạng thái</option>
            <option value="Nghiêm trọng">Nghiêm trọng</option>
            <option value="Sắp hết">Sắp hết</option>
            <option value="An toàn">An toàn</option>
        </select>
    </div>

    <button class="btn-sort" id="btnSortPhysical" title="Tồn ít → nhiều">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="m3 16 4 4 4-4"/><path d="M7 20V4"/>
            <path d="m21 8-4-4-4 4"/><path d="M17 4v16"/>
        </svg>
        Tồn vật lý
    </button>
</div>

<!-- ═══ Table ═══ -->
<div class="table-card">
    <div class="table-responsive">
        <table class="wms-table">
            <thead>
                <tr>
                    <th style="text-align: left;">Mã SKU</th>
                    <th style="text-align: left;">Tên sản phẩm</th>
                    <th style="text-align: center;">Mã kho</th>
                    <th style="text-align: left;">Tên kho</th>
                    <th style="text-align: right;">Tồn vật lý</th>
                    <th style="text-align: center;">Trạng thái</th>
                    <th style="text-align: center;">Hành động</th>
                </tr>
            </thead>
            <tbody id="inventoryTableBody">
                <!-- Populated by JS -->
            </tbody>
        </table>
    </div>
    <div class="table-footer">
        <span id="showingCountEl">Hiển thị 0 / 0 dòng tồn kho</span>
    </div>
</div>

<!-- ═══ JAVASCRIPT ═══ -->
<script>
(function() {
    'use strict';

    // Data will come from backend. For now, empty array.
    var inventoryList = [];
    try {
        var rawInventoryJson = '<c:out value="${inventoryListJson}" escapeXml="false"/>';
        if (rawInventoryJson && rawInventoryJson.trim()) {
            inventoryList = JSON.parse(rawInventoryJson);
        }
    } catch (e) {
        inventoryList = [];
    }

    // DOM
    var criticalCountEl  = document.getElementById('criticalCountEl');
    var warningCountEl   = document.getElementById('warningCountEl');
    var totalCountEl     = document.getElementById('totalCountEl');
    var inventorySearch  = document.getElementById('inventorySearch');
    var whFilter         = document.getElementById('whFilter');
    var statusFilter     = document.getElementById('statusFilter');
    var btnSortPhysical  = document.getElementById('btnSortPhysical');
    var tableBody        = document.getElementById('inventoryTableBody');
    var showingCountEl   = document.getElementById('showingCountEl');

    // State
    var sortAsc = true;
    var searchText = '';
    var selectedWarehouse = 'Tất cả';
    var selectedStatus = 'Tất cả';
    var notified = [];

    // Events
    inventorySearch.addEventListener('input', function(e) {
        searchText = e.target.value;
        render();
    });
    whFilter.addEventListener('change', function(e) {
        selectedWarehouse = e.target.value;
        render();
    });
    statusFilter.addEventListener('change', function(e) {
        selectedStatus = e.target.value;
        render();
    });
    btnSortPhysical.addEventListener('click', function() {
        sortAsc = !sortAsc;
        btnSortPhysical.title = sortAsc ? 'Tồn ít → nhiều' : 'Tồn nhiều → ít';
        render();
    });

    function render() {
        // Filter
        var filtered = inventoryList.filter(function(item) {
            var matchSearch = item.sku.toLowerCase().indexOf(searchText.toLowerCase()) !== -1 ||
                              item.name.toLowerCase().indexOf(searchText.toLowerCase()) !== -1;
            var matchWh = selectedWarehouse === 'Tất cả' || item.warehouseCode === selectedWarehouse;
            var matchStatus = selectedStatus === 'Tất cả' ||
                              (selectedStatus === 'Nghiêm trọng' && item.level === 'critical') ||
                              (selectedStatus === 'Sắp hết' && item.level === 'warning') ||
                              (selectedStatus === 'An toàn' && item.level === 'safe');
            return matchSearch && matchWh && matchStatus;
        });

        // Sort
        filtered.sort(function(a, b) {
            return sortAsc ? a.qtyOnHand - b.qtyOnHand : b.qtyOnHand - a.qtyOnHand;
        });

        // KPIs (based on full list, not filtered)
        var criticalCount = inventoryList.filter(function(i) { return i.level === 'critical'; }).length;
        var warningCount  = inventoryList.filter(function(i) { return i.level === 'warning'; }).length;
        criticalCountEl.textContent = criticalCount;
        warningCountEl.textContent  = warningCount;
        totalCountEl.textContent    = inventoryList.length;
        showingCountEl.textContent  = 'Hiển thị ' + filtered.length + ' / ' + inventoryList.length + ' dòng tồn kho';

        // Build rows
        tableBody.innerHTML = '';

        if (filtered.length === 0) {
            var tr = document.createElement('tr');
            var td = document.createElement('td');
            td.colSpan = 7;
            td.style.padding = '40px 24px';
            td.style.textAlign = 'center';
            td.style.color = 'rgba(16,55,92,0.40)';
            td.style.fontSize = '13px';
            td.textContent = 'Không tìm thấy dòng tồn kho nào phù hợp';
            tr.appendChild(td);
            tableBody.appendChild(tr);
            return;
        }

        filtered.forEach(function(item) {
            var tr = document.createElement('tr');

            // SKU
            var td1 = document.createElement('td');
            td1.innerHTML = '<span class="sku-code">' + esc(item.sku) + '</span>';
            tr.appendChild(td1);

            // Name
            var td2 = document.createElement('td');
            td2.style.maxWidth = '240px';
            td2.innerHTML = '<div class="product-name" title="' + esc(item.name) + '">' + esc(item.name) + '</div>';
            tr.appendChild(td2);

            // Warehouse Code
            var td3 = document.createElement('td');
            td3.style.textAlign = 'center';
            td3.innerHTML = '<span class="warehouse-code">' + esc(item.warehouseCode) + '</span>';
            tr.appendChild(td3);

            // Warehouse Name
            var td4 = document.createElement('td');
            td4.innerHTML = '<span class="warehouse-name">' + esc(item.warehouseName) + '</span>';
            tr.appendChild(td4);

            // Qty
            var td5 = document.createElement('td');
            td5.style.textAlign = 'right';
            var needsAlert = item.level === 'critical' || item.level === 'warning';
            var qtyHtml = '<div class="qty-cell">';
            if (needsAlert) {
                qtyHtml += '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><line x1="12" x2="12" y1="9" y2="13"/><line x1="12" x2="12.01" y1="16" y2="16"/></svg>';
            }
            qtyHtml += '<span class="qty-number ' + item.level + '">' + item.qtyOnHand.toLocaleString() + '</span>';
            qtyHtml += '</div>';
            td5.innerHTML = qtyHtml;
            tr.appendChild(td5);

            // Status
            var td6 = document.createElement('td');
            td6.style.textAlign = 'center';
            var labelMap = { critical: 'Nghiêm trọng', warning: 'Sắp hết', safe: 'An toàn' };
            td6.innerHTML = '<span class="status-badge ' + item.level + '">' + labelMap[item.level] + '</span>';
            tr.appendChild(td6);

            // Action
            var td7 = document.createElement('td');
            td7.style.textAlign = 'center';
            if (needsAlert) {
                if (notified.indexOf(item.id) !== -1) {
                    td7.innerHTML = '<span class="btn-da-bao">' +
                        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>' +
                        'Đã báo</span>';
                } else {
                    var btnColor = item.level === 'critical' ? 'bg-red' : 'bg-navy';
                    var btn = document.createElement('button');
                    btn.className = 'btn-bao-kho ' + btnColor;
                    btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg> Báo kho';
                    btn.addEventListener('click', (function(id) {
                        return function() {
                            notified.push(id);
                            render();
                        };
                    })(item.id));
                    td7.appendChild(btn);
                }
            } else {
                td7.innerHTML = '<span style="color: rgba(16,55,92,0.30); font-size: 11px;">—</span>';
            }
            tr.appendChild(td7);

            tableBody.appendChild(tr);
        });
    }

    function esc(text) {
        if (!text) return '';
        return text.toString()
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }

    // Initial render
    render();
})();
</script>
