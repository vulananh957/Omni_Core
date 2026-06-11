<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<style>
    /* ─── Metric & Grid Layouts ─── */
    .stats-grid-4 {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 16px;
    }
    .stats-grid-3 {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }
    @media (max-width: 1024px) {
        .stats-grid-4 { grid-template-columns: repeat(2, 1fr); }
        .stats-grid-3 { grid-template-columns: 1fr; }
    }
    @media (max-width: 640px) {
        .stats-grid-4 { grid-template-columns: 1fr; }
    }

    .sku-card {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 16px 20px;
        display: flex;
        align-items: center;
        gap: 16px;
    }
    .sku-card__icon {
        width: 48px;
        height: 48px;
        border-radius: var(--radius-btn);
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }
    .sku-card__icon svg {
        width: 22px;
        height: 22px;
    }
    .sku-card__info {
        flex: 1;
        min-width: 0;
    }
    .sku-card__lbl {
        color: rgba(16, 55, 92, 0.50);
        font-size: 11px;
        font-weight: 500;
        margin-bottom: 2px;
    }
    .sku-card__val {
        font-size: 26px;
        font-weight: 800;
        color: var(--navy);
        line-height: 1.1;
        letter-spacing: -0.03em;
    }

    /* Color variations for cards */
    .card-navy .sku-card__icon { background: rgba(16, 55, 92, 0.08); }
    .card-navy .sku-card__icon svg { color: var(--navy); }
    
    .card-orange .sku-card__icon { background: rgba(235, 131, 23, 0.10); }
    .card-orange .sku-card__icon svg { color: var(--orange); }
    .card-orange .sku-card__val { color: var(--orange); }

    .card-emerald .sku-card__icon { background: #ECFDF5; }
    .card-emerald .sku-card__icon svg { color: #059669; }
    .card-emerald .sku-card__val { color: #059669; }

    .card-yellow .sku-card__icon { background: rgba(245, 200, 66, 0.15); }
    .card-yellow .sku-card__icon svg { color: #d9a000; }
    .card-yellow .sku-card__val { color: var(--orange); }

    .card-red .sku-card__icon { background: #FEF2F2; }
    .card-red .sku-card__icon svg { color: #ef4444; }
    .card-red .sku-card__val { color: #ef4444; }

    /* ─── Toolbar ─── */
    .toolbar-wrap {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 16px;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        gap: 12px;
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
        width: 14px;
        height: 14px;
        color: rgba(16, 55, 92, 0.3);
    }
    .search-input-wrap input {
        width: 100%;
        padding: 8px 16px 8px 36px;
        background: var(--alice);
        border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        outline: none;
        color: var(--navy);
        transition: border-color 0.15s;
    }
    .search-input-wrap input::placeholder {
        color: rgba(16, 55, 92, 0.3);
    }
    .search-input-wrap input:focus {
        border-color: rgba(16, 55, 92, 0.3);
    }
    
    .select-wrap {
        position: relative;
    }
    .select-wrap select {
        appearance: none;
        padding: 8px 36px 8px 16px;
        background: var(--alice);
        border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        outline: none;
        color: var(--navy);
        cursor: pointer;
        font-weight: 500;
    }
    .select-wrap svg {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        width: 14px;
        height: 14px;
        color: rgba(16, 55, 92, 0.4);
        pointer-events: none;
    }

    .btn-toolbar {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 14px;
        background: var(--alice);
        border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
        color: rgba(16, 55, 92, 0.7);
        font-size: 13px;
        font-weight: 500;
        cursor: pointer;
        transition: color 0.15s, background 0.15s;
    }
    .btn-toolbar:hover {
        color: var(--navy);
        background: #e2eaf5;
    }
    .btn-toolbar svg {
        width: 14px;
        height: 14px;
    }

    .btn-add-sku {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 8px 16px;
        background: var(--orange);
        border: none;
        border-radius: calc(var(--radius-btn) - 2px);
        color: #fff;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.15s;
        margin-left: auto;
    }
    .btn-add-sku:hover {
        background: #ea580c;
    }
    .btn-add-sku svg {
        width: 14px;
        height: 14px;
    }

    /* ─── Data Table Card ─── */
    .table-card {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        overflow: hidden;
    }
    .table-scroll {
        overflow-x: auto;
    }
    .sku-table {
        width: 100%;
        border-collapse: collapse;
        text-align: left;
    }
    .sku-table th {
        padding: 12px 16px;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        color: rgba(16, 55, 92, 0.50);
        background: var(--alice);
        letter-spacing: 0.05em;
        border-bottom: 1px solid var(--border);
    }
    .sku-table th:first-child { padding-left: 20px; }
    .sku-table th:last-child { padding-right: 20px; text-align: right; }
    
    .sku-table td {
        padding: 14px 16px;
        border-bottom: 1px solid var(--border);
        vertical-align: middle;
    }
    .sku-table td:first-child { padding-left: 20px; }
    .sku-table td:last-child { padding-right: 20px; text-align: right; }
    
    .sku-table tr {
        transition: background 0.12s;
    }
    .sku-table tr:hover td {
        background: rgba(240, 244, 250, 0.50);
    }

    /* Table cells styling */
    .sku-code-cell {
        font-size: 12px;
        font-family: monospace;
        color: rgba(16, 55, 92, 0.60);
        font-weight: 500;
    }
    .sku-name-cell {
        font-size: 13px;
        font-weight: 600;
        color: var(--navy);
        display: -webkit-box;
        line-clamp: 2;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
        max-width: 220px;
    }
    
    /* Vị trí lưu trữ tags */
    .loc-tag-wrap {
        display: flex;
        flex-direction: column;
        gap: 4px;
    }
    .loc-tag {
        font-size: 12px;
        color: rgba(16, 55, 92, 0.75);
    }
    .loc-tag-code {
        font-weight: 700;
        color: #1d4ed8; /* blue-700 */
    }
    .loc-unassigned {
        color: var(--orange);
        font-size: 12px;
        font-weight: 500;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .loc-unassigned svg {
        width: 14px;
        height: 14px;
    }

    /* Status Pills */
    .pill-badge {
        display: inline-flex;
        align-items: center;
        padding: 4px 10px;
        font-size: 11px;
        font-weight: 600;
        border-radius: 20px;
        white-space: nowrap;
    }
    .pill-badge.approved { background: #ECFDF5; color: #047857; }
    .pill-badge.pending { background: rgba(245, 200, 66, 0.15); color: #b45309; }
    .pill-badge.rejected { background: #FEF2F2; color: #b91c1c; }

    /* Quantity and bars */
    .qty-val {
        font-size: 15px;
        font-weight: 800;
        color: var(--navy);
        letter-spacing: -0.02em;
    }
    .qty-val.low { color: var(--orange); }
    .qty-val.out { color: #ef4444; }
    
    .progress-bar-wrap {
        width: 80px;
        height: 6px;
        background: var(--border);
        border-radius: 9999px;
        overflow: hidden;
        margin-top: 6px;
        margin-left: auto;
    }
    .progress-bar-fill {
        height: 100%;
        border-radius: 9999px;
    }

    .limit-lbl {
        font-size: 12px;
        color: rgba(16, 55, 92, 0.60);
    }
    .limit-val {
        font-weight: 600;
        color: var(--navy);
    }

    .info-lbl {
        font-size: 12px;
        color: rgba(16, 55, 92, 0.60);
    }
    .info-time {
        font-size: 10px;
        color: rgba(16, 55, 92, 0.40);
        margin-top: 1px;
    }

    .btn-act-circle {
        width: 26px;
        height: 26px;
        border-radius: 6px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: none;
        cursor: pointer;
        transition: background 0.15s, color 0.15s;
    }
    .btn-act-circle.edit {
        background: rgba(16, 55, 92, 0.05);
        color: rgba(16, 55, 92, 0.7);
    }
    .btn-act-circle.edit:hover {
        background: rgba(16, 55, 92, 0.1);
        color: var(--navy);
    }
    .btn-act-circle.del {
        background: rgba(239, 68, 68, 0.05);
        color: #ef4444;
    }
    .btn-act-circle.del:hover {
        background: rgba(239, 68, 68, 0.1);
        color: #dc2626;
    }
    .btn-act-circle.info {
        background: rgba(34, 197, 94, 0.05);
        color: #22c55e;
    }
    .btn-act-circle.info:hover {
        background: rgba(34, 197, 94, 0.1);
        color: #16a34a;
    }
    .btn-act-circle svg {
        width: 12px;
        height: 12px;
    }

    /* Table Footer */
    .table-footer {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 12px 20px;
        border-top: 1px solid var(--border);
    }
    .table-footer__info {
        color: rgba(16, 55, 92, 0.40);
        font-size: 12px;
    }
    .pagination {
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .page-btn {
        width: 28px;
        height: 28px;
        border-radius: 6px;
        border: none;
        font-size: 12px;
        font-weight: 500;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: background 0.15s, color 0.15s;
        background: none;
        color: rgba(16, 55, 92, 0.50);
    }
    .page-btn:hover {
        background: var(--alice);
    }
    .page-btn.active {
        background: var(--navy);
        color: #fff;
    }

    /* ─── Modals ─── */
    .modal-overlay {
        position: fixed;
        inset: 0;
        background: rgba(16, 55, 92, 0.40);
        backdrop-filter: blur(4px);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;
        opacity: 0;
        pointer-events: none;
        transition: opacity 0.2s ease;
    }
    .modal-overlay.active {
        opacity: 1;
        pointer-events: auto;
    }
    .modal-box {
        background: #fff;
        width: 100%;
        max-width: 520px;
        border-radius: var(--radius-card);
        box-shadow: 0 20px 25px -5px rgba(16, 55, 92, 0.15), 0 10px 10px -5px rgba(16, 55, 92, 0.1);
        transform: translateY(24px);
        transition: transform 0.2s ease;
        max-height: 90vh;
        display: flex;
        flex-direction: column;
        overflow: hidden;
    }
    .modal-overlay.active .modal-box {
        transform: translateY(0);
    }
    .modal-hdr {
        padding: 16px 24px;
        border-bottom: 1px solid var(--border);
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .modal-title {
        color: var(--navy);
        font-size: 16px;
        font-weight: 800;
    }
    .modal-subtitle {
        color: rgba(16, 55, 92, 0.40);
        font-size: 12px;
        margin-top: 2px;
    }
    .modal-close {
        background: none;
        border: none;
        cursor: pointer;
        font-size: 24px;
        line-height: 1;
        color: rgba(16, 55, 92, 0.40);
        transition: color 0.15s;
    }
    .modal-close:hover {
        color: var(--navy);
    }
    
    .modal-body {
        padding: 24px;
        overflow-y: auto;
        flex: 1;
        display: flex;
        flex-direction: column;
        gap: 16px;
    }
    
    .form-group {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }
    .form-label {
        color: rgba(16, 55, 92, 0.60);
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }
    .form-input {
        width: 100%;
        padding: 10px 14px;
        border: 1px solid var(--border);
        background: var(--alice);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        font-family: inherit;
        color: var(--navy);
        outline: none;
        transition: border-color 0.15s;
    }
    .form-input:focus {
        border-color: rgba(16, 55, 92, 0.40);
    }
    
    .modal-note {
        background: rgba(245, 200, 66, 0.10);
        border: 1px solid rgba(245, 200, 66, 0.30);
        border-radius: calc(var(--radius-btn) - 2px);
        padding: 12px 16px;
        font-size: 12px;
        color: rgba(16, 55, 92, 0.70);
        line-height: 1.5;
    }
    
    .modal-ftr {
        padding: 16px 24px;
        border-top: 1px solid var(--border);
        background: var(--alice);
        display: flex;
        justify-content: flex-end;
        gap: 12px;
    }
    .form-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 12px;
    }
</style>

<!-- ══ STATS SECTION ═════════════════════════════════════════ -->
<div class="stats-grid-4">
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

    <!-- Card: Total Physical Qty -->
    <div class="sku-card card-orange">
        <div class="sku-card__icon">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="7.5 4.21 12 6.81 16.5 4.21"></polyline><polyline points="7.5 19.79 7.5 14.6 3.27 12.15"></polyline><polyline points="16.5 19.79 16.5 14.6 20.73 12.15"></polyline><polyline points="12 12.01 12 17.2 16.23 14.66"></polyline><polyline points="12 12.01 12 17.2 7.77 14.66"></polyline><polyline points="12 12.01 7.5 9.4 3.27 12.15"></polyline><polyline points="12 12.01 16.5 9.4 20.73 12.15"></polyline></svg>
        </div>
        <div class="sku-card__info">
            <div class="sku-card__lbl">Tổng tồn kho khả dụng</div>
            <div class="sku-card__val" id="stat-total-qty">0</div>
        </div>
    </div>

    <!-- Card: Active -->
    <div class="sku-card card-emerald">
        <div class="sku-card__icon">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
        </div>
        <div class="sku-card__info">
            <div class="sku-card__lbl">Đang kinh doanh</div>
            <div class="sku-card__val" id="stat-active-skus">0</div>
        </div>
    </div>

    <!-- Card: Pending -->
    <div class="sku-card card-yellow">
        <div class="sku-card__icon">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
        </div>
        <div class="sku-card__info">
            <div class="sku-card__lbl">Chờ duyệt</div>
            <div class="sku-card__val" id="stat-pending-skus">0</div>
        </div>
    </div>
</div>

<div class="stats-grid-3">
    <!-- Card: Low Stock -->
    <div class="sku-card card-yellow">
        <div class="sku-card__icon">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
        </div>
        <div class="sku-card__info">
            <div class="sku-card__lbl">Sắp hết hàng</div>
            <div class="sku-card__val" id="stat-low-stock">0</div>
        </div>
    </div>

    <!-- Card: Inactive -->
    <div class="sku-card card-red">
        <div class="sku-card__icon">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
        </div>
        <div class="sku-card__info">
            <div class="sku-card__lbl">Tạm ngưng</div>
            <div class="sku-card__val" id="stat-inactive-skus">0</div>
        </div>
    </div>

    <!-- Card: Fill Rate -->
    <div class="sku-card card-navy">
        <div class="sku-card__icon">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M23 6l-9.5 9.5-5-5L1 18"></path><polyline points="17 6 23 6 23 12"></polyline></svg>
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
    
    <button class="btn-toolbar" id="btnFilterTrigger">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon></svg>
        Bộ lọc
    </button>
    <button class="btn-toolbar" id="btnExportCSV">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
        Xuất CSV
    </button>

    <!-- Warehouse filter -->
    <div class="select-wrap">
        <select id="skuWarehouseFilter">
            <option value="">Tat ca kho</option>
            <c:forEach var="w" items="${warehouses}">
                <option value="${w.warehouseId}"><c:out value="${w.warehouseName}"/></option>
            </c:forEach>
        </select>
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></svg>
    </div>

    <button class="btn-add-sku" id="btnCreateSKUTrigger">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
        Thêm SKU mới
    </button>
</div>

<!-- ══ TABLE SECTION ═════════════════════════════════════════ -->
<div class="table-card">
    <div class="table-scroll">
        <table class="sku-table">
            <thead>
                <tr>
                    <th style="width: 140px;">SKU</th>
                    <th style="width: 220px;">Tên sản phẩm</th>
                    <th style="width: 180px;">Vị trí lưu trữ</th>
                    <th style="width: 120px;">Trạng thái</th>
                    <th style="width: 120px; text-align: right;">Tồn kho</th>
                    <th style="width: 140px; text-align: right;">Định mức (Min/Max)</th>
                    <th style="width: 185px;">Thông tin</th>
                    <th style="width: 100px; text-align: right;">Thao tác</th>
                </tr>
            </thead>
            <tbody id="skuTableBody"></tbody>
        </table>
    </div>
    
    <div class="table-footer">
        <span class="table-footer__info" id="skuTableInfo">Hiển thị 0 / 0 SKU</span>
        <div class="pagination" id="skuPagination"></div>
    </div>
</div>

<!-- ══ CREATE MODAL ══════════════════════════════════════════ -->
<div class="modal-overlay" id="createModalOverlay">
    <div class="modal-box">
        <div class="modal-hdr">
            <div>
                <h2 class="modal-title">Tạo SKU mới</h2>
                <p class="modal-subtitle">Nhân viên kho tạo sản phẩm mới (chờ phê duyệt từ Quản lý kinh doanh)</p>
            </div>
            <button class="modal-close" id="createModalClose">&times;</button>
        </div>
        <div class="modal-body">
            <div class="form-group">
                <label class="form-label" for="create-sku">Mã SKU *</label>
                <input class="form-input" type="text" id="create-sku" placeholder="VD: SKU-2026-001"/>
            </div>
            <div class="form-group">
                <label class="form-label" for="create-name">Tên sản phẩm *</label>
                <input class="form-input" type="text" id="create-name" placeholder="Ví dụ: Lược chải tóc gỡ rối - Màu hồng"/>
            </div>
            <div class="form-group">
                <label class="form-label" for="create-category">Danh mục</label>
                <div class="select-wrap" style="width: 100%;">
                    <select class="form-input" id="create-category" style="width: 100%; appearance: none; padding-right: 36px;">
                        <c:forEach var="c" items="${categories}">
                            <option><c:out value="${c.categoryName}"/></option>
                        </c:forEach>
                    </select>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; right: 12px; top: 50%; transform: translateY(-50%); width: 14px; height: 14px; color: rgba(16, 55, 92, 0.4); pointer-events: none;"><polyline points="6 9 12 15 18 9"></polyline></svg>
                </div>
            </div>
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label" for="create-dimensions">Kích thước (D×R×C) cm</label>
                    <input class="form-input" type="text" id="create-dimensions" placeholder="VD: 20×14×1.5"/>
                </div>
                <div class="form-group">
                    <label class="form-label" for="create-weight">Khối lượng (kg)</label>
                    <input class="form-input" type="text" id="create-weight" placeholder="VD: 0.28"/>
                </div>
            </div>
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label" for="create-min">Tồn tối thiểu</label>
                    <input class="form-input" type="number" id="create-min" value="50"/>
                </div>
                <div class="form-group">
                    <label class="form-label" for="create-max">Tồn tối đa</label>
                    <input class="form-input" type="number" id="create-max" value="500"/>
                </div>
            </div>
            
            <div class="modal-note">
                <strong>Lưu ý:</strong> SKU sẽ được tạo ở trạng thái <strong>Chờ duyệt</strong>. Quản lý kinh doanh sẽ gán khu vực và vị trí lưu trữ trong quá trình phê duyệt.
            </div>
        </div>
        <div class="modal-ftr">
            <button class="btn-toolbar" id="createModalCancel">Hủy</button>
            <button class="btn-add-sku" id="btnCreateSKUSubmit">Tạo SKU</button>
        </div>
    </div>
</div>

<!-- ══ EDIT MODAL ════════════════════════════════════════════ -->
<div class="modal-overlay" id="editModalOverlay">
    <div class="modal-box">
        <div class="modal-hdr">
            <div>
                <h2 class="modal-title">Chỉnh sửa SKU</h2>
                <p class="modal-subtitle" id="edit-sku-code-label">SKU-XXXX</p>
            </div>
            <button class="modal-close" id="editModalClose">&times;</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="edit-id"/>
            <div class="form-group">
                <label class="form-label" for="edit-name">Tên sản phẩm</label>
                <input class="form-input" type="text" id="edit-name"/>
            </div>
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label" for="edit-dimensions">Kích thước (D×R×C)</label>
                    <input class="form-input" type="text" id="edit-dimensions"/>
                </div>
                <div class="form-group">
                    <label class="form-label" for="edit-weight">Khối lượng (kg)</label>
                    <input class="form-input" type="text" id="edit-weight"/>
                </div>
            </div>
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label" for="edit-min">Tồn tối thiểu</label>
                    <input class="form-input" type="number" id="edit-min"/>
                </div>
                <div class="form-group">
                    <label class="form-label" for="edit-max">Tồn tối đa</label>
                    <input class="form-input" type="number" id="edit-max"/>
                </div>
            </div>
        </div>
        <div class="modal-ftr">
            <button class="btn-toolbar" id="editModalCancel">Hủy</button>
            <button class="btn-add-sku" id="btnEditSKUSubmit">Lưu thay đổi</button>
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
                    <label class="form-label">Trạng thái phê duyệt</label>
                    <div class="form-input" id="view-approval-status" style="background: rgba(16, 55, 92, 0.02); pointer-events: none; height: auto; min-height: 38px; display: flex; align-items: center; border: 1px solid var(--border); border-radius: 6px; padding: 0 12px; font-weight: 500; color: var(--navy);"></div>
                </div>
                <div class="form-group">
                    <label class="form-label">Đơn vị tính</label>
                    <div class="form-input" id="view-unit" style="background: rgba(16, 55, 92, 0.02); pointer-events: none; height: auto; min-height: 38px; display: flex; align-items: center; border: 1px solid var(--border); border-radius: 6px; padding: 0 12px; font-weight: 500; color: var(--navy);">Cái</div>
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

// Bind server-side product data if available from servlet
var SERVER_PRODUCTS = [];
try {
    var rawJson = '<c:out value="${productsJson}" escapeXml="false"/>';
    if (rawJson && rawJson.trim() && rawJson.indexOf('productsJson') === -1) {
        SERVER_PRODUCTS = JSON.parse(rawJson);
    }
} catch (e) {
    console.warn('warehouse-master-sku: No server product data, using localStorage fallback');
}

// LocalStorage fallback
var savedSKUs = localStorage.getItem('wms_skus');
var localSKUs = savedSKUs ? JSON.parse(savedSKUs) : [];

// Always prefer server data when present; clear stale client cache for this page
if (SERVER_PRODUCTS.length > 0 && savedSKUs) {
    localStorage.removeItem('wms_skus');
    localSKUs = [];
}

// Merge: server data takes priority if available
var skus = (SERVER_PRODUCTS.length > 0) ? SERVER_PRODUCTS.map(function(p) {
    var qtyOnHand = Number(p.qtyOnHand || 0);
    var minStock = Number(p.minStock || 0);
    var maxStock = Number(p.maxStock || 0);
    var approvalStatus = p.status === 'APPROVED' ? 'approved' : p.status === 'REJECTED' ? 'rejected' : 'pending';
    var stockStatus = 'inactive';

    if (approvalStatus === 'approved') {
        if (qtyOnHand <= minStock) {
            stockStatus = 'low_stock';
        } else {
            stockStatus = 'active';
        }
    }

    return {
        id: 'p-' + p.productId,
        sku: p.skuCode || '',
        name: p.productName || '',
        category: p.categoryName || '',
        dimensions: p.attributesText || 'N/A',
        weight: p.weightKg ? p.weightKg + ' kg' : 'N/A',
        qtyOnHand: qtyOnHand,
        minStock: minStock,
        maxStock: maxStock,
        status: stockStatus,
        approvalStatus: approvalStatus,
        locationConfigs: p.locationConfigs || [],
        createdBy: p.creatorName || p.createdBy || '',
        createdAt: p.createdAt || '',
        updatedBy: p.approverName || p.updatedBy || '',
        lastUpdated: p.updatedAt || ''
    };
}) : localSKUs;

/* ─── State ──────────────────────────────────────────────── */
var selectedWarehouse = '';

var LOCATIONS = [];
try {
    var rawWarehousesJson = '<c:out value="${warehousesJson}" escapeXml="false"/>';
    if (rawWarehousesJson && rawWarehousesJson.trim() && rawWarehousesJson.indexOf('warehousesJson') === -1) {
        var parsedWarehouses = JSON.parse(rawWarehousesJson);
        LOCATIONS = parsedWarehouses.map(function(w) {
            return {
                id: 'loc-' + w.warehouseId,
                name: w.warehouseName,
                code: w.warehouseCode,
                city: w.address
            };
        });
    }
} catch (e) {
    LOCATIONS = [];
}

var ZONES = [];
try {
    var rawZonesJson = '<c:out value="${zonesJson}" escapeXml="false"/>';
    if (rawZonesJson && rawZonesJson.trim() && rawZonesJson.indexOf('zonesJson') === -1) {
        var parsedZones = JSON.parse(rawZonesJson);
        ZONES = parsedZones.map(function(z) {
            return {
                id: 'z-' + z.zoneId,
                locationId: 'loc-' + z.warehouseId,
                code: z.zoneCode,
                name: z.zoneName,
                zoneType: z.zoneType,
                allowForNew: z.zoneType === 'NORMAL' || z.zoneType === 'RETURN'
            };
        });
    }
} catch (e) {
    ZONES = [];
}

var search = '';
var selectedCategory = 'Tất cả';
var currentPage = 1;
var pageSize = 15;

/* ─── DOM Elements ───────────────────────────────────────── */
var tableBody   = document.getElementById('skuTableBody');
var tableInfo   = document.getElementById('skuTableInfo');
var pagination  = document.getElementById('skuPagination');

var searchInput = document.getElementById('skuSearchInput');
var catSelect   = document.getElementById('skuCategorySelect');

/* Create Modal Elements */
var createOverlay = document.getElementById('createModalOverlay');
var btnCreateTrigger = document.getElementById('btnCreateSKUTrigger');
var btnCreateClose   = document.getElementById('createModalClose');
var btnCreateCancel  = document.getElementById('createModalCancel');
var btnCreateSubmit  = document.getElementById('btnCreateSKUSubmit');

var createSkuInput  = document.getElementById('create-sku');
var createNameInput = document.getElementById('create-name');
var createCatInput  = document.getElementById('create-category');
var createDimInput  = document.getElementById('create-dimensions');
var createWgtInput  = document.getElementById('create-weight');
var createMinInput  = document.getElementById('create-min');
var createMaxInput  = document.getElementById('create-max');

/* Edit Modal Elements */
var editOverlay   = document.getElementById('editModalOverlay');
var btnEditClose  = document.getElementById('editModalClose');
var btnEditCancel = document.getElementById('editModalCancel');
var btnEditSubmit = document.getElementById('btnEditSKUSubmit');

var editIdInput     = document.getElementById('edit-id');
var editNameInput   = document.getElementById('edit-name');
var editDimInput    = document.getElementById('edit-dimensions');
var editWgtInput    = document.getElementById('edit-weight');
var editMinInput    = document.getElementById('edit-min');
var editMaxInput    = document.getElementById('edit-max');
var editCodeLabel   = document.getElementById('edit-sku-code-label');

/* ─── Handlers ───────────────────────────────────────────── */
if (searchInput) {
    searchInput.addEventListener('input', function (e) {
        search = e.target.value;
        currentPage = 1;
        renderAll();
    });
}

if (catSelect) {
    catSelect.addEventListener('change', function (e) {
        selectedCategory = e.target.value;
        currentPage = 1;
        renderAll();
    });
}

var skuWarehouseFilter = document.getElementById('skuWarehouseFilter');
if (skuWarehouseFilter) {
    skuWarehouseFilter.addEventListener('change', function (e) {
        selectedWarehouse = e.target.value;
        currentPage = 1;
        renderAll();
    });
}

/* Modals toggle */
if (btnCreateTrigger) {
    btnCreateTrigger.addEventListener('click', function () {
        createOverlay.classList.add('active');
    });
}
[btnCreateClose, btnCreateCancel].forEach(function (btn) {
    if (btn) {
        btn.addEventListener('click', function () {
            createOverlay.classList.remove('active');
            clearCreateForm();
        });
    }
});

[btnEditClose, btnEditCancel].forEach(function (btn) {
    if (btn) {
        btn.addEventListener('click', function () {
            editOverlay.classList.remove('active');
        });
    }
});

/* View Modal Elements */
var viewOverlay     = document.getElementById('viewModalOverlay');
var btnViewClose    = document.getElementById('viewModalClose');
var btnViewCloseBtn = document.getElementById('viewModalCloseBtn');

[btnViewClose, btnViewCloseBtn].forEach(function (btn) {
    if (btn) {
        btn.addEventListener('click', function () {
            viewOverlay.classList.remove('active');
        });
    }
});

// Close modals when clicking on background overlays
[createOverlay, editOverlay, viewOverlay].forEach(function (overlay) {
    if (overlay) {
        overlay.addEventListener('click', function (e) {
            if (e.target === overlay) {
                overlay.classList.remove('active');
                if (overlay === createOverlay) {
                    clearCreateForm();
                }
            }
        });
    }
});

/* Create Submit */
if (btnCreateSubmit) {
    btnCreateSubmit.addEventListener('click', function () {
        var skuVal  = createSkuInput.value.trim();
        var nameVal = createNameInput.value.trim();
        
        if (!skuVal || !nameVal) {
            alert('Vui lòng nhập đầy đủ Mã SKU và Tên sản phẩm!');
            return;
        }

        submitPostAction('create', {
            skuCode: skuVal,
            productName: nameVal,
            categoryName: createCatInput.value ? createCatInput.value.trim() : '',
            dimensions: createDimInput.value.trim() || 'N/A',
            weight: createWgtInput.value.trim() || '0',
            minStock: parseInt(createMinInput.value) || 0,
            maxStock: parseInt(createMaxInput.value) || 100
        });
    });
}

/* Edit Submit */
if (btnEditSubmit) {
    btnEditSubmit.addEventListener('click', function () {
        var id = editIdInput.value;
        var nameVal = editNameInput.value.trim();
        
        if (!nameVal) {
            alert('Tên sản phẩm không được bỏ trống!');
            return;
        }

        if (id.indexOf('p-') === 0) {
            var productId = id.substring(2);
            submitPostAction('edit', {
                productId: productId,
                productName: nameVal,
                dimensions: editDimInput.value.trim() || 'N/A',
                weight: editWgtInput.value.trim() || '0',
                minStock: parseInt(editMinInput.value) || 0,
                maxStock: parseInt(editMaxInput.value) || 100
            });
            return;
        }

        var foundIndex = skus.findIndex(function (s) { return s.id === id; });
        if (foundIndex > -1) {
            var now = new Date();
            var timeStr = now.getFullYear() + '-' + 
                          padZero(now.getMonth()+1) + '-' + 
                          padZero(now.getDate()) + ' ' + 
                          padZero(now.getHours()) + ':' + 
                          padZero(now.getMinutes());

            skus[foundIndex].name = nameVal;
            skus[foundIndex].dimensions = editDimInput.value.trim();
            skus[foundIndex].weight = editWgtInput.value.trim();
            skus[foundIndex].minStock = parseInt(editMinInput.value) || 0;
            skus[foundIndex].maxStock = parseInt(editMaxInput.value) || 100;
            skus[foundIndex].lastUpdated = timeStr;
            skus[foundIndex].updatedBy = window.WMS_USER.fullName || 'Nhân viên kho';
        }

        editOverlay.classList.remove('active');
        renderAll();
        alert('Cập nhật SKU thành công!');
    });
}

/* Edit action trigger */
window.triggerEditSKU = function (id) {
    var item = skus.find(function (s) { return s.id === id; });
    if (!item) return;

    editIdInput.value = item.id;
    editCodeLabel.textContent = item.sku;
    editNameInput.value = item.name;
    editDimInput.value = item.dimensions;
    editWgtInput.value = item.weight.replace(' kg', '');
    editMinInput.value = item.minStock;
    editMaxInput.value = item.maxStock;

    editOverlay.classList.add('active');
};

/* View details action trigger */
window.triggerViewSKU = function (id) {
    var item = skus.find(function (s) { return s.id === id; });
    if (!item) return;

    document.getElementById('view-sku-code-label').textContent = item.sku;
    document.getElementById('view-name').textContent = item.name;
    document.getElementById('view-category').textContent = item.category;
    document.getElementById('view-dimensions').textContent = item.dimensions || 'N/A';
    document.getElementById('view-weight').textContent = item.weight || 'N/A';
    document.getElementById('view-min').textContent = item.minStock;
    document.getElementById('view-max').textContent = item.maxStock;
    
    var statusText = item.approvalStatus === 'approved' ? 'Đã duyệt' : item.approvalStatus === 'pending' ? 'Chờ duyệt' : 'Từ chối';
    document.getElementById('view-approval-status').textContent = statusText;
    document.getElementById('view-created-by').textContent = item.createdBy || 'N/A';
    document.getElementById('view-created-at').textContent = item.createdAt || 'N/A';
    document.getElementById('view-updated-by').textContent = item.updatedBy || item.createdBy || 'N/A';
    document.getElementById('view-updated-at').textContent = item.lastUpdated || item.createdAt || 'N/A';

    viewOverlay.classList.add('active');
};

/* Delete action trigger */
window.triggerDeleteSKU = function (id) {
    var item = skus.find(function (s) { return s.id === id; });
    if (!item) return;

    if (item.approvalStatus !== 'pending') {
        alert('Chỉ cho phép xóa sản phẩm ở trạng thái Chờ duyệt.');
        return;
    }

    if (confirm('Bạn có chắc chắn muốn xóa SKU "' + item.sku + '"?')) {
        if (id.indexOf('p-') === 0) {
            var productId = id.substring(2);
            submitPostAction('delete', { productId: productId });
        }
    }
};

/* CSV Export */
var btnExportCSV = document.getElementById('btnExportCSV');
if (btnExportCSV) {
    btnExportCSV.addEventListener('click', function () {
        var filteredList = getFilteredList();
        var headers = ["Mã SKU", "Tên sản phẩm", "Vị trí lưu trữ", "Trạng thái", "Tồn kho", "MIN", "MAX", "Tạo bởi", "Cập nhật"];
        var csvContent = "\uFEFF" + headers.join(",") + "\n";
        
        filteredList.forEach(function (item) {
            var locs = item.locationConfigs && item.locationConfigs.length > 0
                ? item.locationConfigs.map(function(c) {
                    var loc = LOCATIONS.find(function(l) { return l.id === c.locationId; });
                    var zone = ZONES.find(function(z) { return z.id === c.zoneId; });
                    return (loc ? loc.code : '?') + " -> " + (zone ? zone.name : '?');
                  }).join(" | ")
                : "Chưa gán vị trí";
            
            var statusStr = item.approvalStatus === 'approved' ? 'Đã duyệt' : item.approvalStatus === 'pending' ? 'Chờ duyệt' : 'Từ chối';
            
            var row = [
                '"' + item.sku.replace(/"/g, '""') + '"',
                '"' + item.name.replace(/"/g, '""') + '"',
                '"' + locs.replace(/"/g, '""') + '"',
                '"' + statusStr.replace(/"/g, '""') + '"',
                item.qtyOnHand,
                item.minStock,
                item.maxStock,
                '"' + (item.createdBy || '').replace(/"/g, '""') + '"',
                '"' + (item.lastUpdated || '').replace(/"/g, '""') + '"'
            ];
            csvContent += row.join(",") + "\n";
        });
        
        var blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        var link = document.createElement("a");
        link.href = URL.createObjectURL(blob);
        link.setAttribute("download", "master_sku_warehouse_" + new Date().toISOString().slice(0, 10) + ".csv");
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    });
}

/* ─── Helpers ─── */
function padZero(n) { return n < 10 ? '0' + n : n; }

function clearCreateForm() {
    createSkuInput.value = '';
    createNameInput.value = '';
    if (createCatInput.options.length > 0) {
        createCatInput.selectedIndex = 0;
    }
    createDimInput.value = '';
    createWgtInput.value = '';
    createMinInput.value = '50';
    createMaxInput.value = '500';
}

function getFilteredList() {
    return skus.filter(function (s) {
        var matchSearch = s.sku.toLowerCase().indexOf(search.toLowerCase()) > -1 ||
                          s.name.toLowerCase().indexOf(search.toLowerCase()) > -1;
        var matchCat    = selectedCategory === 'Tất cả' || s.category === selectedCategory;
        var matchWh    = selectedWarehouse === '' || (s.warehouseId && s.warehouseId.toString() === selectedWarehouse);
        return matchSearch && matchCat && matchWh;
    });
}

function updateStats(filteredList) {
    var total = skus.length;
    var active = skus.filter(function (s) { return s.status === 'active' && s.approvalStatus === 'approved'; }).length;
    var pending = skus.filter(function (s) { return s.approvalStatus === 'pending'; }).length;
    var lowStock = skus.filter(function (s) { return s.status === 'low_stock' && s.approvalStatus === 'approved'; }).length;
    var inactive = skus.filter(function (s) { return s.status === 'inactive'; }).length;
    var totalPhysicalQty = skus.reduce(function (sum, s) { return sum + s.qtyOnHand; }, 0);
    var totalMaxStock = skus.reduce(function (sum, s) { return sum + s.maxStock; }, 0);
    
    var fillRate = totalMaxStock > 0 ? Math.round((totalPhysicalQty / totalMaxStock) * 100) : 0;

    document.getElementById('stat-total-skus').textContent = total.toLocaleString();
    document.getElementById('stat-total-qty').textContent = totalPhysicalQty.toLocaleString();
    document.getElementById('stat-active-skus').textContent = active.toLocaleString();
    document.getElementById('stat-pending-skus').textContent = pending.toLocaleString();
    document.getElementById('stat-low-stock').textContent = lowStock.toLocaleString();
    document.getElementById('stat-inactive-skus').textContent = inactive.toLocaleString();
    document.getElementById('stat-fill-rate').textContent = fillRate + '%';
}

function renderAll() {
    localStorage.setItem('wms_skus', JSON.stringify(skus));
    
    var filtered = getFilteredList();
    updateStats(filtered);
    
    var totalItems = filtered.length;
    var totalPages = Math.ceil(totalItems / pageSize) || 1;
    if (currentPage > totalPages) currentPage = totalPages;
    
    var startIdx = (currentPage - 1) * pageSize;
    var endIdx = Math.min(startIdx + pageSize, totalItems);
    var paginated = filtered.slice(startIdx, endIdx);
    
    tableInfo.textContent = 'Hiển thị ' + (totalItems > 0 ? (startIdx + 1) : 0) + ' - ' + endIdx + ' / ' + totalItems + ' SKU (Tổng cộng ' + skus.length + ')';
    
    if (paginated.length === 0) {
        tableBody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:48px;color:rgba(16, 55, 92, 0.4)">Không tìm thấy sản phẩm SKU nào.</td></tr>';
        return;
    }
    
    var html = paginated.map(function (item, idx) {
        var acLabel = item.approvalStatus === 'approved' ? 'Đã duyệt' : item.approvalStatus === 'pending' ? 'Chờ duyệt' : 'Từ chối';
        var acClass = item.approvalStatus;

        var statusIconHtml = '';
        if (item.approvalStatus === 'pending') {
            statusIconHtml = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="width:12px;height:12px;margin-right:4px;"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>';
        } else if (item.approvalStatus === 'approved') {
            statusIconHtml = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="width:12px;height:12px;margin-right:4px;"><polyline points="20 6 9 17 4 12"/></svg>';
        } else if (item.approvalStatus === 'rejected') {
            statusIconHtml = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="width:12px;height:12px;margin-right:4px;"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>';
        }

        var stockPct = item.maxStock > 0 ? Math.min(100, Math.round((item.qtyOnHand / item.maxStock) * 100)) : 0;
        var barColor = stockPct > 50 ? '#10b981' : stockPct > 20 ? '#F5C842' : '#ef4444';
        
        var isLow = item.qtyOnHand <= item.minStock;
        var qtyClass = (isLow && item.qtyOnHand > 0) ? 'qty-val low' : (item.qtyOnHand === 0) ? 'qty-val out' : 'qty-val';

        var locHtml = '';
        if (!item.locationConfigs || item.locationConfigs.length === 0) {
            locHtml = '<span class="loc-unassigned">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/></svg>' +
                'Chưa gán vị trí</span>';
        } else {
            locHtml = '<div class="loc-tag-wrap">' +
                item.locationConfigs.map(function (c) {
                    var loc = LOCATIONS.find(function(l) { return l.id === c.locationId; });
                    var zone = ZONES.find(function(z) { return z.id === c.zoneId; });
                    var locCode = loc ? loc.code : '?';
                    var zoneName = zone ? zone.name : '?';
                    return '<div class="loc-tag">' +
                           '<span class="loc-tag-code">' + locCode + '</span>' +
                           '<span style="color: rgba(16, 55, 92, 0.3); margin: 0 6px;">→</span>' +
                           '<span>' + zoneName + '</span>' +
                           '</div>';
                }).join('') +
                '</div>';
        }

        var canEdit = item.approvalStatus === 'pending';
        var editBtnHtml = canEdit ? 
            '<button class="btn-act-circle edit" onclick="triggerEditSKU(\'' + item.id + '\')" title="Sửa">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>' +
            '</button>' : '';

        var viewBtnHtml = 
            '<button class="btn-act-circle info" onclick="triggerViewSKU(\'' + item.id + '\')" title="Xem chi tiết">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>' +
            '</button>';

        var canDelete = item.approvalStatus === 'pending';
        var deleteBtnHtml = canDelete ? 
            '<button class="btn-act-circle del" onclick="triggerDeleteSKU(\'' + item.id + '\')" title="Xóa">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>' +
            '</button>' : 
            '<button class="btn-act-circle del" style="cursor: not-allowed; opacity: 0.4;" onclick="alert(\'Chỉ cho phép xóa sản phẩm ở trạng thái Chờ duyệt.\')" title="Không thể xóa">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>' +
            '</button>';

        var rowClass = (startIdx + idx) % 2 === 0 ? '' : 'style="background:rgba(240, 244, 250, 0.3)"';

        return '<tr ' + rowClass + '>' +
            '<td><div class="sku-code-cell">' + item.sku + '</div></td>' +
            '<td><div class="sku-name-cell" title="' + item.name + '">' + item.name + '</div></td>' +
            '<td>' + locHtml + '</td>' +
            '<td><span class="pill-badge ' + acClass + '">' + statusIconHtml + acLabel + '</span></td>' +
            '<td>' +
                '<div class="' + qtyClass + '">' + item.qtyOnHand.toLocaleString() + '</div>' +
                '<div class="progress-bar-wrap"><div class="progress-bar-fill" style="width:' + stockPct + '%;background:' + barColor + '"></div></div>' +
            '</td>' +
            '<td>' +
                '<div class="limit-lbl">Min: <span class="limit-val">' + item.minStock + '</span></div>' +
                '<div class="limit-lbl">Max: <span class="limit-val">' + item.maxStock + '</span></div>' +
            '</td>' +
            '<td>' +
                '<div class="info-lbl">Tạo: ' + item.createdBy + '</div>' +
                '<div class="info-time">' + item.createdAt + '</div>' +
                '<div class="info-lbl" style="margin-top:4px">Cập nhật: ' + (item.updatedBy || item.createdBy) + '</div>' +
                '<div class="info-time">' + item.lastUpdated + '</div>' +
            '</td>' +
            '<td>' +
                '<div style="display:flex;align-items:center;justify-content:flex-end;gap:8px">' +
                    viewBtnHtml +
                    editBtnHtml +
                    deleteBtnHtml +
                '</div>' +
            '</td>' +
        '</tr>';
    }).join('');

    tableBody.innerHTML = html;

    var pageHtml = '';
    for (var p = 1; p <= totalPages; p++) {
        var act = p === currentPage ? 'active' : '';
        pageHtml += '<button class="page-btn ' + act + '" onclick="window.gotoSKUPage(' + p + ')">' + p + '</button>';
    }
    pagination.innerHTML = pageHtml;
}

window.gotoSKUPage = function (p) {
    currentPage = p;
    renderAll();
};

/* ─── Bootstrap ─── */
renderAll();

})();
</script>
