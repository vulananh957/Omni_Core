<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    /* ─── Page Header ─── */
    .wt-page-header {
        display: flex; align-items: center; justify-content: space-between;
        margin-bottom: 24px;
    }
    .wt-page-title { font-size: 18px; font-weight: 800; color: var(--navy); letter-spacing: -0.02em; }
    .wt-page-sub   { font-size: 12px; color: rgba(16,55,92,.45); margin-top: 3px; }

    /* ─── Stats Grid ─── */
    .wt-stats {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 14px;
        margin-bottom: 20px;
    }
    @media (max-width: 860px) { .wt-stats { grid-template-columns: repeat(2, 1fr); } }
    .wt-stat {
        background: #fff; border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 14px 18px;
        display: flex; align-items: center; gap: 14px;
    }
    .wt-stat-icon {
        width: 38px; height: 38px; border-radius: var(--radius-btn);
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .wt-stat-icon svg { width: 18px; height: 18px; }
    .wt-stat-val  { font-size: 22px; font-weight: 800; color: var(--navy); letter-spacing: -0.03em; line-height: 1; }
    .wt-stat-lbl  { font-size: 11px; color: rgba(16,55,92,.50); font-weight: 500; margin-top: 2px; }

    /* ─── Toolbar ─── */
    .wt-toolbar {
        background: #fff; border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 12px 14px;
        display: flex; align-items: center; gap: 10px;
        margin-bottom: 14px;
    }
    .wt-search-wrap { position: relative; flex: 1; min-width: 0; }
    .wt-search-icon {
        position: absolute; left: 11px; top: 50%; transform: translateY(-50%);
        width: 14px; height: 14px; color: rgba(16,55,92,.30); pointer-events: none;
    }
    .wt-search-input {
        width: 100%; padding: 8px 12px 8px 34px;
        background: var(--alice); border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px; color: var(--navy); outline: none;
        box-sizing: border-box;
    }
    .wt-search-input::placeholder { color: rgba(16,55,92,.30); }
    .wt-search-input:focus { border-color: rgba(16,55,92,.30); }
    .wt-btn-create {
        display: flex; align-items: center; gap: 7px;
        padding: 8px 16px; white-space: nowrap;
        background: var(--orange); color: #fff;
        border: none; border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px; font-weight: 600; cursor: pointer;
        transition: opacity .15s;
    }
    .wt-btn-create:hover { opacity: .88; }
    .wt-btn-create svg { width: 14px; height: 14px; }

    /* ─── Tabs ─── */
    .wt-tabs {
        background: #fff; border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 4px; display: flex; flex-wrap: wrap; gap: 4px;
        margin-bottom: 14px;
    }
    .wt-tab {
        display: flex; align-items: center; gap: 7px;
        padding: 7px 14px;
        border: none; background: none; cursor: pointer;
        font-size: 12px; font-weight: 600; color: rgba(16,55,92,.50);
        border-radius: calc(var(--radius-btn) - 4px);
        transition: all .15s;
    }
    .wt-tab.active { background: var(--navy); color: #fff; }
    .wt-tab:not(.active):hover { color: var(--navy); }
    .wt-tab-badge {
        padding: 1px 6px; border-radius: 999px;
        font-size: 10px; font-weight: 700;
    }
    .wt-tab.active .wt-tab-badge     { background: rgba(255,255,255,.20); color: #fff; }
    .wt-tab:not(.active) .wt-tab-badge { background: rgba(16,55,92,.08); color: rgba(16,55,92,.60); }

    /* ─── Table Card ─── */
    .wt-card {
        background: #fff; border: 1px solid var(--border);
        border-radius: var(--radius-card); overflow: hidden;
    }
    .wt-table-scroll { overflow-x: auto; }
    .wt-table { width: 100%; border-collapse: collapse; }
    .wt-table thead tr { background: var(--alice); border-bottom: 1px solid var(--border); }
    .wt-table thead th {
        padding: 10px 16px; font-size: 10px; font-weight: 700;
        text-transform: uppercase; letter-spacing: .08em;
        color: rgba(16,55,92,.40); white-space: nowrap;
    }
    .wt-table thead th:first-child { padding-left: 20px; }
    .wt-table thead th.ta-r { text-align: right; }
    .wt-table tbody tr { border-bottom: 1px solid var(--border); transition: background .12s; }
    .wt-table tbody tr:last-child { border-bottom: none; }
    .wt-table tbody tr:hover { background: rgba(240,245,250,.5); }
    .wt-table tbody td { padding: 13px 16px; vertical-align: middle; }
    .wt-table tbody td:first-child { padding-left: 20px; }
    .wt-table tbody td.ta-r { text-align: right; }

    /* Cell typographies */
    .wt-code   { font-family: monospace; font-weight: 700; font-size: 12px; color: var(--navy); }
    .wt-nm     { font-size: 13px; font-weight: 600; color: var(--navy); }
    .wt-sub    { font-size: 11px; color: rgba(16,55,92,.45); margin-top: 2px; }
    .wt-qty    { font-size: 14px; font-weight: 800; color: var(--navy); }
    .wt-date   { font-size: 12px; color: rgba(16,55,92,.55); }
    .wt-empty  { text-align: center; padding: 40px; font-size: 13px; color: rgba(16,55,92,.40); }

    /* Status badge */
    .wt-pill {
        display: inline-flex; align-items: center; gap: 5px;
        padding: 3px 10px; border-radius: 20px;
        font-size: 11px; font-weight: 700;
    }
    .wt-pill__dot { width: 6px; height: 6px; border-radius: 50%; }
    .wt-pill.draft      { background: rgba(16,55,92,.08); color: rgba(16,55,92,.65); }
    .wt-pill.draft .wt-pill__dot        { background: rgba(16,55,92,.30); }
    .wt-pill.in-transit { background: rgba(245,158,11,.15); color: #b45309; }
    .wt-pill.in-transit .wt-pill__dot   { background: #f59e0b; }
    .wt-pill.received   { background: #ecfdf5; color: #065f46; }
    .wt-pill.received .wt-pill__dot     { background: #10b981; }
    .wt-pill.cancelled  { background: #fef2f2; color: #991b1b; }
    .wt-pill.cancelled .wt-pill__dot    { background: #ef4444; }
    .wt-pill.pending    { background: rgba(255,186,8,.18); color: #c2410c; }
    .wt-pill.pending .wt-pill__dot      { background: #fbbf24; }

    /* Row action buttons */
    .wt-row-actions { display: flex; align-items: center; justify-content: flex-end; gap: 6px; }
    .wt-btn-icon {
        width: 30px; height: 30px;
        display: flex; align-items: center; justify-content: center;
        border: none; background: none; cursor: pointer;
        color: rgba(16,55,92,.40); border-radius: calc(var(--radius-btn) - 4px);
        transition: all .12s;
    }
    .wt-btn-icon:hover { color: var(--navy); background: var(--alice); }
    .wt-btn-icon svg { width: 14px; height: 14px; }
    .wt-btn-icon.danger:hover { color: #ef4444; background: #fef2f2; }
    .wt-btn-sm {
        padding: 4px 10px; border: none; cursor: pointer;
        border-radius: calc(var(--radius-btn) - 4px);
        font-size: 11px; font-weight: 700; transition: opacity .12s;
    }
    .wt-btn-sm.navy   { background: var(--navy); color: #fff; }
    .wt-btn-sm.navy:hover   { opacity: .85; }
    .wt-btn-sm.orange { background: var(--orange); color: #fff; }
    .wt-btn-sm.orange:hover { opacity: .85; }

    /* ─── Modal ─── */
    .wt-overlay {
        position: fixed; inset: 0;
        background: rgba(16,55,92,.40); backdrop-filter: blur(4px);
        display: flex; align-items: center; justify-content: center;
        z-index: 1000; padding: 16px;
    }
    .wt-modal {
        background: #fff; width: 100%; max-width: 520px;
        border-radius: var(--radius-card);
        box-shadow: 0 25px 50px rgba(16,55,92,.20);
        display: flex; flex-direction: column;
        max-height: 92vh; overflow: hidden;
    }
    .wt-modal-hd {
        display: flex; align-items: flex-start; justify-content: space-between;
        padding: 18px 24px; border-bottom: 1px solid var(--border);
    }
    .wt-modal-hd h2 {
        font-size: 15px; font-weight: 800; color: var(--navy);
        text-transform: uppercase; letter-spacing: .04em; margin: 0;
    }
    .wt-modal-hd p { font-size: 12px; color: rgba(16,55,92,.40); margin: 3px 0 0; }
    .wt-modal-close {
        background: none; border: none; cursor: pointer; flex-shrink: 0;
        font-size: 22px; line-height: 1; color: rgba(16,55,92,.40);
        padding: 0 0 0 12px;
    }
    .wt-modal-close:hover { color: var(--navy); }
    .wt-modal-body {
        padding: 22px 24px; overflow-y: auto; flex: 1;
        display: flex; flex-direction: column; gap: 18px;
    }
    .wt-modal-ft {
        display: flex; align-items: center; justify-content: flex-end;
        gap: 10px; padding: 14px 24px;
        border-top: 1px solid var(--border); background: var(--alice);
    }
    .wt-sec-title {
        font-size: 11px; font-weight: 700; text-transform: uppercase;
        letter-spacing: .06em; color: var(--navy);
        padding-bottom: 8px; border-bottom: 1px solid rgba(16,55,92,.10);
        margin-bottom: 10px;
    }
    .wt-form-row   { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
    .wt-form-group { display: flex; flex-direction: column; gap: 5px; }
    .wt-label {
        font-size: 11px; font-weight: 600; text-transform: uppercase;
        color: rgba(16,55,92,.60); letter-spacing: .04em;
    }
    .wt-label-row { display: flex; align-items: center; justify-content: space-between; }
    .wt-avail {
        font-size: 11px; font-weight: 700; color: var(--orange);
        background: rgba(255,186,8,.18); padding: 2px 8px; border-radius: 10px;
    }
    .wt-input, .wt-select, .wt-textarea {
        padding: 8px 11px; border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px; color: var(--navy);
        background: #fff; outline: none; width: 100%;
        font-family: inherit; box-sizing: border-box;
    }
    .wt-select { background: var(--alice); }
    .wt-input:focus, .wt-select:focus, .wt-textarea:focus { border-color: rgba(16,55,92,.30); }
    .wt-textarea { resize: none; }
    .wt-zone-box {
        padding: 13px 15px; border: 1px solid #e2e8f0;
        background: rgba(240,245,250,.5);
        border-radius: calc(var(--radius-btn) - 2px);
    }
    .wt-zone-box-lbl {
        display: flex; align-items: center; gap: 7px;
        font-size: 11px; font-weight: 700; text-transform: uppercase;
        color: rgba(16,55,92,.70); margin-bottom: 10px;
    }
    .wt-zone-bar { width: 6px; height: 12px; border-radius: 3px; flex-shrink: 0; }
    .wt-zone-cols { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
    .wt-sub-label {
        font-size: 10px; font-weight: 600; text-transform: uppercase;
        color: rgba(16,55,92,.50); margin-bottom: 4px; letter-spacing: .04em;
    }
    .wt-select-sm {
        padding: 7px 10px; border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 4px);
        font-size: 12px; color: var(--navy);
        background: #fff; outline: none; width: 100%;
        box-sizing: border-box;
    }
    .wt-btn {
        padding: 8px 18px; border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px; font-weight: 600; cursor: pointer;
        border: none; transition: opacity .15s;
    }
    .wt-btn.cancel { background: #fff; border: 1px solid var(--border); color: rgba(16,55,92,.70); }
    .wt-btn.cancel:hover { color: var(--navy); }
    .wt-btn.navy   { background: var(--navy); color: #fff; }
    .wt-btn.navy:hover   { opacity: .85; }
    .wt-btn.orange { background: var(--orange); color: #fff; }
    .wt-btn.orange:hover { opacity: .85; }

    /* Detail modal extras */
    .wt-detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
    .wt-detail-sep  { padding-top: 14px; border-top: 1px solid var(--border); }
    .wt-dl-lbl  { font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,.40); margin-bottom: 3px; }
    .wt-dl-val  { font-size: 13px; font-weight: 700; color: var(--navy); }
    .wt-dl-val.sm    { font-size: 12px; font-weight: 600; }
    .wt-dl-val.muted { font-size: 11px; color: rgba(16,55,92,.50); }
    .wt-flow {
        display: grid; grid-template-columns: 1fr auto 1fr;
        align-items: center; gap: 10px;
        background: var(--alice); padding: 12px;
        border-radius: calc(var(--radius-btn) - 2px);
    }
    .wt-flow-arrow { color: rgba(16,55,92,.40); display: flex; align-items: center; }
    .wt-flow-arrow svg { width: 16px; height: 16px; }
    .wt-detail-note {
        font-size: 12px; color: rgba(16,55,92,.70); line-height: 1.6;
        background: rgba(240,245,250,.5); padding: 10px 12px;
        border: 1px solid var(--border); border-radius: calc(var(--radius-btn) - 4px);
    }
    .wt-pending-info {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 7px 14px; background: #fffbeb; color: #b45309;
        font-size: 12px; font-weight: 600;
        border: 1px solid #fde68a; border-radius: calc(var(--radius-btn) - 2px);
    }
    .wt-page-btn {
        display: inline-flex; align-items: center; justify-content: center;
        padding: 5px 10px; min-width: 28px; height: 28px;
        background: #fff; border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 4px);
        font-size: 12px; font-weight: 600; color: rgba(16,55,92,.60);
        cursor: pointer; transition: all .12s;
        box-sizing: border-box;
    }
    .wt-page-btn:hover { color: var(--navy); background: var(--alice); border-color: rgba(16,55,92,.30); }
    .wt-page-btn.active { background: var(--navy); color: #fff; border-color: var(--navy); pointer-events: none; }
</style>

<!-- ═══ PAGE HEADER ═══ -->
<div class="wt-page-header">
    <div>
        <div class="wt-page-title">Điều Chuyển Kho</div>
        <div class="wt-page-sub">Quản lý lệnh điều chuyển hàng hóa giữa các kho và khu vực</div>
    </div>
</div>

<!-- ═══ STATS ═══ -->
<div class="wt-stats">
    <div class="wt-stat">
        <div class="wt-stat-icon" style="background:rgba(16,55,92,.08);">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                 stroke="rgba(16,55,92,1)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8M12 17v4"/>
            </svg>
        </div>
        <div>
            <div class="wt-stat-val" id="wtStatTotal">${statusCounts.all != null ? statusCounts.all : 0}</div>
            <div class="wt-stat-lbl">Tổng phiếu</div>
        </div>
    </div>
    <div class="wt-stat">
        <div class="wt-stat-icon" style="background:rgba(245,158,11,.15);">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                 stroke="#f59e0b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
            </svg>
        </div>
        <div>
            <div class="wt-stat-val" id="wtStatTransit" style="color:#b45309;">${statusCounts.IN_TRANSIT != null ? statusCounts.IN_TRANSIT : 0}</div>
            <div class="wt-stat-lbl">Đang chuyển</div>
        </div>
    </div>
    <div class="wt-stat">
        <div class="wt-stat-icon" style="background:#ecfdf5;">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                 stroke="#059669" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>
            </svg>
        </div>
        <div>
            <div class="wt-stat-val" id="wtStatReceived" style="color:#059669;">${statusCounts.RECEIVED != null ? statusCounts.RECEIVED : 0}</div>
            <div class="wt-stat-lbl">Đã nhận</div>
        </div>
    </div>
    <div class="wt-stat">
        <div class="wt-stat-icon" style="background:rgba(16,55,92,.05);">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                 stroke="rgba(16,55,92,.50)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                <polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/>
            </svg>
        </div>
        <div>
            <div class="wt-stat-val" id="wtStatDraft" style="color:rgba(16,55,92,.60);">${statusCounts.DRAFT != null ? statusCounts.DRAFT : 0}</div>
            <div class="wt-stat-lbl">Bản nháp</div>
        </div>
    </div>
</div>

<!-- ═══ TOOLBAR ═══ -->
<div class="wt-toolbar">
    <div class="wt-search-wrap">
        <svg class="wt-search-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
             fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
        </svg>
        <input class="wt-search-input" type="text" id="wtSearch" value="<c:out value='${search}'/>"
               placeholder="Tìm mã phiếu, kho nguồn, kho đích…"/>
    </div>
    <button class="wt-btn-create" id="wtBtnCreate">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
        </svg>
        Tạo phiếu chuyển kho
    </button>
</div>

<!-- ═══ TABS ═══ -->
<div class="wt-tabs" id="wtTabs">
    <button class="wt-tab ${empty currentStatus || currentStatus == 'all' ? 'active' : ''}" data-tab="all">
        Tất cả <span class="wt-tab-badge" id="wtBadge-all">${statusCounts.all != null ? statusCounts.all : 0}</span>
    </button>
    <button class="wt-tab ${currentStatus == 'DRAFT' ? 'active' : ''}" data-tab="DRAFT">
        Nháp <span class="wt-tab-badge" id="wtBadge-DRAFT">${statusCounts.DRAFT != null ? statusCounts.DRAFT : 0}</span>
    </button>
    <button class="wt-tab ${currentStatus == 'IN_TRANSIT' ? 'active' : ''}" data-tab="IN_TRANSIT">
        Đang chuyển <span class="wt-tab-badge" id="wtBadge-IN_TRANSIT">${statusCounts.IN_TRANSIT != null ? statusCounts.IN_TRANSIT : 0}</span>
    </button>
    <button class="wt-tab ${currentStatus == 'RECEIVED' ? 'active' : ''}" data-tab="RECEIVED">
        Đã nhận <span class="wt-tab-badge" id="wtBadge-RECEIVED">${statusCounts.RECEIVED != null ? statusCounts.RECEIVED : 0}</span>
    </button>
    <button class="wt-tab ${currentStatus == 'CANCELLED' ? 'active' : ''}" data-tab="CANCELLED">
        Đã hủy <span class="wt-tab-badge" id="wtBadge-CANCELLED">${statusCounts.CANCELLED != null ? statusCounts.CANCELLED : 0}</span>
    </button>
</div>

<!-- ═══ TABLE ═══ -->
<div class="wt-card">
    <div class="wt-table-scroll">
        <table class="wt-table">
            <thead>
                <tr>
                    <th>Mã phiếu</th>
                    <th>Từ kho</th>
                    <th>Đến kho</th>
                    <th>Ngày tạo</th>
                    <th>Trạng thái</th>
                    <th class="ta-r">Thao tác</th>
                </tr>
            </thead>
            <tbody id="wtTableBody">
                <tr><td colspan="6" class="wt-empty">Đang tải dữ liệu…</td></tr>
            </tbody>
        </table>
    </div>
    <!-- Pagination Footer -->
    <div class="wt-pagination" style="display: flex; align-items: center; justify-content: space-between; padding: 12px 20px; border-top: 1px solid var(--border);">
        <div style="font-size: 12px; color: rgba(16,55,92,.50);">
            Hiển thị <b>${startRecord}</b> - <b>${endRecord}</b> trên tổng số <b>${totalTransfers}</b> kết quả
        </div>
        <c:if test="${totalPages > 1}">
        <div style="display: flex; gap: 4px;">
            <c:if test="${currentPageNum > 1}">
                <a href="?status=${currentStatus}&search=${search}&page=${currentPageNum - 1}" class="wt-page-btn" style="text-decoration:none;">&laquo; Trước</a>
            </c:if>
            <c:forEach var="p" begin="1" end="${totalPages}">
                <a href="?status=${currentStatus}&search=${search}&page=${p}" class="wt-page-btn ${p == currentPageNum ? 'active' : ''}" style="text-decoration:none;">${p}</a>
            </c:forEach>
            <c:if test="${currentPageNum < totalPages}">
                <a href="?status=${currentStatus}&search=${search}&page=${currentPageNum + 1}" class="wt-page-btn" style="text-decoration:none;">Sau &raquo;</a>
            </c:if>
        </div>
        </c:if>
    </div>
</div>

<!-- ═══ MODAL: TẠO PHIẾU ═══ -->
<div class="wt-overlay" id="wtCreateOverlay" style="display:none;">
    <div class="wt-modal">
        <div class="wt-modal-hd">
            <div>
                <h2>Tạo Phiếu Chuyển Kho</h2>
                <p>Điều chuyển hàng hóa giữa kho hoặc khu vực lưu trữ</p>
            </div>
            <button class="wt-modal-close" id="wtBtnCloseCreate">×</button>
        </div>
        <div class="wt-modal-body">
            <!-- Sản phẩm -->
            <div>
                <div class="wt-sec-title">Thông tin sản phẩm</div>
                <div style="display:flex;flex-direction:column;gap:10px;">
                    <div class="wt-form-group">
                        <label class="wt-label">Mã sản phẩm (SKU) *</label>
                        <select class="wt-input" id="wtFormSku" style="background:#fff;cursor:pointer;">
                            <option value="">— Chọn sản phẩm —</option>
                        </select>
                    </div>
                    <div class="wt-form-group">
                        <label class="wt-label">Tên sản phẩm</label>
                        <input class="wt-input" type="text" id="wtFormSkuName" readonly
                               style="background:var(--alice);cursor:not-allowed;" placeholder="Chọn SKU để tự điền"/>
                    </div>
                    <div class="wt-form-group">
                        <div class="wt-label-row">
                            <label class="wt-label">Số lượng chuyển *</label>
                            <span class="wt-avail" id="wtAvail">Khả dụng: — sp</span>
                        </div>
                        <input class="wt-input" type="number" id="wtFormQty" min="1" value="1"/>
                    </div>
                </div>
            </div>
            <!-- Điều chuyển -->
            <div>
                <div class="wt-sec-title">Thông tin điều chuyển</div>
                <div style="display:flex;flex-direction:column;gap:10px;">
                    <div class="wt-zone-box">
                        <div class="wt-zone-box-lbl">
                            <span class="wt-zone-bar" style="background:var(--orange);"></span>
                            Từ (Nguồn xuất)
                        </div>
                        <div class="wt-zone-cols">
                            <div>
                                <div class="wt-sub-label">Chi nhánh kho</div>
                                <select class="wt-select-sm" id="wtFormSrcWH">
                                    <option value="">— Chọn kho —</option>
                                </select>
                            </div>
                            <div>
                                <div class="wt-sub-label">Khu vực (Zone)</div>
                                <select class="wt-select-sm" id="wtFormSrcZone">
                                    <option value="">— Chọn zone —</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="wt-zone-box">
                        <div class="wt-zone-box-lbl">
                            <span class="wt-zone-bar" style="background:var(--navy);"></span>
                            Đến (Đích nhập)
                        </div>
                        <div class="wt-zone-cols">
                            <div>
                                <div class="wt-sub-label">Chi nhánh kho</div>
                                <select class="wt-select-sm" id="wtFormDstWH">
                                    <option value="">— Chọn kho —</option>
                                </select>
                            </div>
                            <div>
                                <div class="wt-sub-label">Khu vực (Zone)</div>
                                <select class="wt-select-sm" id="wtFormDstZone">
                                    <option value="">— Chọn zone —</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Ghi chú -->
            <div class="wt-form-group">
                <label class="wt-label">Ghi chú / Lý do điều chuyển</label>
                <textarea class="wt-textarea" id="wtFormNote" rows="3"
                    placeholder="Ví dụ: Chuyển hàng từ Zone A sang Zone Hàng Hỏng để kiểm tra…"></textarea>
            </div>
        </div>
        <div class="wt-modal-ft">
            <button class="wt-btn cancel" id="wtBtnCancelCreate">Hủy</button>
            <button class="wt-btn navy"   id="wtBtnDraft">Lưu nháp</button>
            <button class="wt-btn orange" id="wtBtnSubmit">Trình duyệt</button>
        </div>
    </div>
</div>

<!-- ═══ MODAL: CHI TIẾT ═══ -->
<div class="wt-overlay" id="wtDetailOverlay" style="display:none;" onclick="wtCloseDetail(event)">
    <div class="wt-modal" onclick="event.stopPropagation()">
        <div class="wt-modal-hd" style="background:rgba(240,245,250,.4);">
            <h2 style="text-transform:none;font-size:14px;">Chi tiết Phiếu Chuyển Kho</h2>
            <button class="wt-modal-close"
                    onclick="document.getElementById('wtDetailOverlay').style.display='none'">×</button>
        </div>
        <div class="wt-modal-body" id="wtDetailBody"></div>
        <div class="wt-modal-ft">
            <span class="wt-pending-info" id="wtDetailPending" style="display:none;">
                Đang chờ Business Manager phê duyệt
            </span>
            <button class="wt-btn navy"
                    onclick="document.getElementById('wtDetailOverlay').style.display='none'">Đóng</button>
        </div>
    </div>
</div>

<script id="db-transfers-data" type="application/json">
[
    <c:forEach items="${transfers}" var="t" varStatus="s">
        {
            "id": ${t.transferId},
            "code": "<c:out value='${t.transferCode}'/>",
            "fromWH": "<c:out value='${t.fromWarehouseName}'/>",
            "toWH": "<c:out value='${t.toWarehouseName}'/>",
            "status": "<c:out value='${t.status}'/>",
            "createdAt": "<c:out value='${t.createdAt}'/>"
        }${!s.last ? ',' : ''}
    </c:forEach>
]
</script>

<script id="db-warehouses-data" type="application/json">
[
    <c:forEach items="${warehouses}" var="w" varStatus="s">
        { "id": ${w.warehouseId}, "name": "<c:out value='${w.warehouseName}'/>" }${!s.last ? ',' : ''}
    </c:forEach>
]
</script>

<script id="db-products-data" type="application/json">
[
    <c:forEach items="${products}" var="p" varStatus="s">
        { "sku": "<c:out value='${p.sku}'/>", "name": "<c:out value='${p.name}'/>" }${!s.last ? ',' : ''}
    </c:forEach>
]
</script>

<!-- ═══ JAVASCRIPT ═══ -->
<script>
(function () {
    'use strict';

    /* ─── Data injected from servlet ─── */
    var DB_TRANSFERS = JSON.parse(document.getElementById('db-transfers-data').textContent || '[]');
    var DB_WAREHOUSES = JSON.parse(document.getElementById('db-warehouses-data').textContent || '[]');
    var DB_PRODUCTS = JSON.parse(document.getElementById('db-products-data').textContent || '[]');

    /* ─── State ─── */
    var localTransfers = [];   // local-created (draft/pending), not yet in DB
    var activeTab  = "${currentStatus != null ? currentStatus : 'all'}";
    var searchTxt  = "${search != null ? search : ''}";
    var detailDoc  = null;

    /* ─── DOM refs ─── */
    var tbody      = document.getElementById('wtTableBody');
    var tabs       = document.getElementById('wtTabs');
    var searchEl   = document.getElementById('wtSearch');
    var createOvl  = document.getElementById('wtCreateOverlay');
    var detailOvl  = document.getElementById('wtDetailOverlay');
    var detailBody = document.getElementById('wtDetailBody');
    var pendingNote= document.getElementById('wtDetailPending');
    var fSku       = document.getElementById('wtFormSku');
    var fSkuName   = document.getElementById('wtFormSkuName');
    var fQty       = document.getElementById('wtFormQty');
    var fSrcWH     = document.getElementById('wtFormSrcWH');
    var fSrcZone   = document.getElementById('wtFormSrcZone');
    var fDstWH     = document.getElementById('wtFormDstWH');
    var fDstZone   = document.getElementById('wtFormDstZone');
    var fNote      = document.getElementById('wtFormNote');

    /* ─── Populate form selects ─── */
    function buildWhOption(sel, ph) {
        sel.innerHTML = '<option value="">' + ph + '</option>';
        DB_WAREHOUSES.forEach(function (w) {
            var o = document.createElement('option');
            o.value = w.id; o.textContent = w.name;
            sel.appendChild(o);
        });
    }
    buildWhOption(fSrcWH, '— Chọn kho xuất —');
    buildWhOption(fDstWH, '— Chọn kho nhập —');

    if (DB_PRODUCTS.length > 0) {
        fSku.innerHTML = '<option value="">— Chọn sản phẩm —</option>';
        DB_PRODUCTS.forEach(function (p) {
            var o = document.createElement('option');
            o.value = p.sku; o.textContent = p.sku + ' – ' + p.name;
            fSku.appendChild(o);
        });
    }

    fSku.addEventListener('change', function () {
        var p = DB_PRODUCTS.find(function (x) { return x.sku === fSku.value; });
        fSkuName.value = p ? p.name : '';
    });

    function populateZones(whSel, zoneSel) {
        // Zone info not available server-side yet; keep placeholder
        zoneSel.innerHTML = '<option value="">— Chọn zone —</option>';
    }
    fSrcWH.addEventListener('change', function () { populateZones(fSrcWH, fSrcZone); });
    fDstWH.addEventListener('change', function () { populateZones(fDstWH, fDstZone); });

    /* ─── Status config ─── */
    function statusCfg(s) {
        var m = {
            'DRAFT':      { cls: 'draft',      lbl: 'Nháp' },
            'IN_TRANSIT': { cls: 'in-transit',  lbl: 'Đang chuyển' },
            'RECEIVED':   { cls: 'received',    lbl: 'Đã nhận' },
            'CANCELLED':  { cls: 'cancelled',   lbl: 'Đã hủy' },
            'pending':    { cls: 'pending',     lbl: 'Chờ duyệt' },
            'draft':      { cls: 'draft',       lbl: 'Nháp' }
        };
        return m[s] || { cls: 'draft', lbl: s };
    }

    function pill(s) {
        var c = statusCfg(s);
        return '<span class="wt-pill ' + c.cls + '">' +
               '<span class="wt-pill__dot"></span>' + esc(c.lbl) + '</span>';
    }

    /* ─── Merge DB + local for display ─── */
    function allTransfers() {
        var dbRows = DB_TRANSFERS.map(function (t) {
            return { _src: 'db', id: t.code, fromWH: t.fromWH, toWH: t.toWH,
                     status: t.status, createdAt: t.createdAt, _raw: t };
        });
        var localRows = localTransfers.map(function (t) {
            return { _src: 'local', id: t.id, fromWH: t.fromWH, toWH: t.toWH,
                     status: t.status, createdAt: t.createdAt, _raw: t };
        });
        return dbRows.concat(localRows);
    }

    /* ─── Render ─── */
    function render() {
        var all = allTransfers();

        if (all.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="wt-empty">Không có phiếu chuyển kho nào phù hợp.</td></tr>';
            return;
        }

        tbody.innerHTML = all.map(function (t) {
            var acts = '<button class="wt-btn-icon" data-action="view" data-id="' + esc(t.id) + '" title="Xem chi tiết">' + eyeSVG() + '</button>';
            if (t._src === 'local' && t.status === 'draft') {
                acts += '<button class="wt-btn-sm navy" data-action="submit" data-id="' + esc(t.id) + '">Gửi duyệt</button>' +
                        '<button class="wt-btn-icon danger" data-action="del" data-id="' + esc(t.id) + '" title="Xóa nháp">' + trashSVG() + '</button>';
            }
            return '<tr>' +
                '<td><span class="wt-code">' + esc(t.id) + '</span></td>' +
                '<td>' +
                    '<div class="wt-nm">' + esc(t.fromWH || '—') + '</div>' +
                '</td>' +
                '<td>' +
                    '<div class="wt-nm">' + esc(t.toWH || '—') + '</div>' +
                '</td>' +
                '<td><span class="wt-date">' + esc(t.createdAt || '—') + '</span></td>' +
                '<td>' + pill(t.status) + '</td>' +
                '<td class="ta-r"><div class="wt-row-actions">' + acts + '</div></td>' +
                '</tr>';
        }).join('');
    }

    /* ─── Table events ─── */
    tbody.addEventListener('click', function (e) {
        var btn = e.target.closest('[data-action]');
        if (!btn) return;
        var action = btn.dataset.action;
        var id     = btn.dataset.id;

        if (action === 'view') {
            var all = allTransfers();
            var t = all.find(function (x) { return x.id === id; });
            if (t) openDetail(t);
        } else if (action === 'submit') {
            var t = localTransfers.find(function (x) { return x.id === id; });
            if (t) { t.status = 'pending'; render(); }
        } else if (action === 'del') {
            if (confirm('Xóa bản nháp này?')) {
                localTransfers = localTransfers.filter(function (x) { return x.id !== id; });
                render();
            }
        }
    });

    /* ─── Tabs ─── */
    tabs.addEventListener('click', function (e) {
        var btn = e.target.closest('.wt-tab');
        if (!btn) return;
        var tab = btn.dataset.tab;
        window.location.href = '?status=' + tab + '&search=' + encodeURIComponent(searchEl.value) + '&page=1';
    });

    /* ─── Search ─── */
    searchEl.addEventListener('keypress', function (e) {
        if (e.key === 'Enter') {
            window.location.href = '?status=' + activeTab + '&search=' + encodeURIComponent(this.value) + '&page=1';
        }
    });

    /* ─── Create modal ─── */
    document.getElementById('wtBtnCreate').addEventListener('click', function () {
        fSku.value = ''; fSkuName.value = ''; fQty.value = 1; fNote.value = '';
        createOvl.style.display = 'flex';
    });
    document.getElementById('wtBtnCloseCreate').addEventListener('click', function () { createOvl.style.display = 'none'; });
    document.getElementById('wtBtnCancelCreate').addEventListener('click', function () { createOvl.style.display = 'none'; });
    createOvl.addEventListener('click', function (e) { if (e.target === createOvl) createOvl.style.display = 'none'; });

    function doCreate(isSubmit) {
        var sku = fSku.value.trim();
        if (!sku) { alert('Vui lòng chọn sản phẩm (SKU)!'); return; }
        var qty = parseInt(fQty.value, 10) || 0;
        if (qty <= 0) { alert('Số lượng phải lớn hơn 0!'); return; }

        var srcWHId  = fSrcWH.value;
        var dstWHId  = fDstWH.value;
        var srcWH    = DB_WAREHOUSES.find(function (w) { return String(w.id) === srcWHId; });
        var dstWH    = DB_WAREHOUSES.find(function (w) { return String(w.id) === dstWHId; });

        var now = new Date();
        var nowStr = now.getFullYear() + '-' +
                     String(now.getMonth()+1).padStart(2,'0') + '-' +
                     String(now.getDate()).padStart(2,'0') + ' ' +
                     String(now.getHours()).padStart(2,'0') + ':' +
                     String(now.getMinutes()).padStart(2,'0');

        localTransfers.unshift({
            id:        'TR-L-' + String(Date.now()).slice(-6),
            sku:       sku,
            skuName:   fSkuName.value.trim(),
            qty:       qty,
            fromWH:    srcWH ? srcWH.name : (srcWHId || '—'),
            toWH:      dstWH ? dstWH.name : (dstWHId || '—'),
            status:    isSubmit ? 'pending' : 'draft',
            createdAt: nowStr,
            note:      fNote.value.trim() || null,
            createdBy: 'Nhân viên kho'
        });

        createOvl.style.display = 'none';
        fSku.value = ''; fSkuName.value = ''; fQty.value = 1; fNote.value = '';
        render();
    }

    document.getElementById('wtBtnDraft').addEventListener('click', function () { doCreate(false); });
    document.getElementById('wtBtnSubmit').addEventListener('click', function () { doCreate(true); });

    /* ─── Detail modal ─── */
    function openDetail(t) {
        detailDoc = t;
        var r = t._raw || t;
        var noteHtml = r.note ?
            '<div class="wt-detail-sep">' +
            '<div class="wt-dl-lbl" style="margin-bottom:6px;">Ghi chú / Lý do:</div>' +
            '<div class="wt-detail-note">' + esc(r.note) + '</div>' +
            '</div>' : '';

        detailBody.innerHTML =
            '<div class="wt-detail-grid" style="padding-bottom:14px;border-bottom:1px solid var(--border);">' +
                '<div><div class="wt-dl-lbl">Mã phiếu:</div>' +
                '<div style="font-weight:700;font-size:15px;color:var(--navy);margin-top:2px;font-family:monospace;">' + esc(t.id) + '</div></div>' +
                '<div><div class="wt-dl-lbl">Trạng thái:</div><div style="margin-top:4px;">' + pill(t.status) + '</div></div>' +
            '</div>' +
            '<div class="wt-flow">' +
                '<div>' +
                    '<div class="wt-dl-lbl" style="font-size:9px;">Từ kho:</div>' +
                    '<div style="font-size:12px;font-weight:700;color:var(--navy);">' + esc(t.fromWH || '—') + '</div>' +
                '</div>' +
                '<div class="wt-flow-arrow"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 1l4 4-4 4"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/><path d="M7 23l-4-4 4-4"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/></svg></div>' +
                '<div>' +
                    '<div class="wt-dl-lbl" style="font-size:9px;">Đến kho:</div>' +
                    '<div style="font-size:12px;font-weight:700;color:var(--navy);">' + esc(t.toWH || '—') + '</div>' +
                '</div>' +
            '</div>' +
            '<div class="wt-detail-sep">' +
                '<div class="wt-detail-grid">' +
                    '<div><div class="wt-dl-lbl">Ngày tạo:</div>' +
                    '<div class="wt-dl-val muted">' + esc(t.createdAt || '—') + '</div></div>' +
                    (r.qty ? '<div><div class="wt-dl-lbl">Số lượng:</div>' +
                    '<div class="wt-dl-val">' + esc(r.qty) + ' sản phẩm</div></div>' : '') +
                '</div>' +
            '</div>' +
            noteHtml;

        pendingNote.style.display = (t.status === 'pending') ? 'inline-flex' : 'none';
        detailOvl.style.display = 'flex';
    }

    window.wtCloseDetail = function (e) {
        if (e.target === detailOvl) detailOvl.style.display = 'none';
    };

    /* ─── SVG helpers ─── */
    function eyeSVG() {
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>';
    }
    function trashSVG() {
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>';
    }
    function esc(v) {
        if (v == null) return '';
        return String(v)
            .replace(/&/g,'&amp;').replace(/</g,'&lt;')
            .replace(/>/g,'&gt;').replace(/"/g,'&quot;')
            .replace(/'/g,'&#039;');
    }

    /* ─── Init ─── */
    render();

})();
</script>
