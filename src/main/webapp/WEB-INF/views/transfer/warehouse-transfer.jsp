<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    /* ─── DB Transfer Section ─── */
    .db-tr-header {
        display: flex; align-items: center; justify-content: space-between;
        margin-bottom: 16px;
    }
    .db-tr-title { font-size: 15px; font-weight: 800; color: var(--navy); letter-spacing: -0.02em; }
    .db-tr-subtitle { font-size: 12px; color: rgba(16,55,92,.40); margin-top: 2px; }
    .db-tr-badge {
        display: inline-flex; align-items: center; gap: 4px;
        padding: 3px 10px; border-radius: 20px;
        font-size: 10px; font-weight: 700;
        background: rgba(6,182,212,.1); color: #0891b2;
        border: 1px solid rgba(6,182,212,.2);
    }
    .db-tr-tabs {
        background: #fff; border: 1px solid var(--border);
        border-radius: var(--radius-card); padding: 4px;
        display: flex; flex-wrap: wrap; gap: 4px;
        margin-bottom: 16px;
    }
    .db-tr-tab {
        display: flex; align-items: center; gap: 6px;
        padding: 6px 14px; font-size: 12px; font-weight: 600;
        border: none; background: none; cursor: pointer;
        color: rgba(16,55,92,.50); border-radius: calc(var(--radius-btn) - 4px);
        transition: all .15s;
    }
    .db-tr-tab.active { background: var(--navy); color: #fff; }
    .db-tr-tab:not(.active):hover { color: var(--navy); }
    .db-tr-count {
        font-size: 9px; font-weight: 700; padding: 1px 5px; border-radius: 9999px;
    }
    .db-tr-tab.active .db-tr-count { background: rgba(255,255,255,.2); color: #fff; }
    .db-tr-tab:not(.active) .db-tr-count { background: rgba(16,55,92,.08); color: rgba(16,55,92,.5); }
    .db-tr-table-card {
        background: #fff; border: 1px solid var(--border);
        border-radius: var(--radius-card); overflow: hidden; margin-bottom: 20px;
    }
    .db-tr-table { width: 100%; border-collapse: collapse; }
    .db-tr-table thead tr { background: var(--alice); border-bottom: 1px solid var(--border); }
    .db-tr-table thead th {
        padding: 10px 16px; font-size: 10px; font-weight: 700;
        text-transform: uppercase; letter-spacing: .08em; color: rgba(16,55,92,.4);
    }
    .db-tr-table thead th:first-child { padding-left: 20px; }
    .db-tr-table thead th.text-right { text-align: right; }
    .db-tr-table tbody tr { border-bottom: 1px solid var(--border); transition: background .12s; }
    .db-tr-table tbody tr:last-child { border-bottom: none; }
    .db-tr-table tbody tr:hover { background: rgba(240,244,250,.5); }
    .db-tr-table tbody td { padding: 12px 16px; font-size: 13px; color: var(--navy); }
    .db-tr-table tbody td:first-child { padding-left: 20px; }
    .db-tr-table tbody td.text-right { text-align: right; }
    .db-tr-empty { text-align: center; padding: 32px; color: rgba(16,55,92,.4); }
    .db-tr-code { font-family: monospace; font-weight: 700; color: var(--navy); font-size: 12px; }
    .db-tr-wh { font-weight: 500; }
    .db-tr-zone { font-size: 11px; color: rgba(16,55,92,.5); margin-top: 2px; }
    .db-tr-status-pill {
        display: inline-flex; align-items: center; gap: 4px;
        padding: 3px 10px; border-radius: 20px; font-size: 10px; font-weight: 700;
    }
    .db-tr-status-pill__dot { width: 5px; height: 5px; border-radius: 50%; }
    .db-tr-status-pill.draft     { background: rgba(16,55,92,.08); color: rgba(16,55,92,.6); }
    .db-tr-status-pill.draft .db-tr-status-pill__dot { background: rgba(16,55,92,.3); }
    .db-tr-status-pill.in_transit { background: rgba(245,200,66,.15); color: #d97706; }
    .db-tr-status-pill.in_transit .db-tr-status-pill__dot { background: #f5c842; }
    .db-tr-status-pill.received  { background: #ecfdf5; color: #047857; }
    .db-tr-status-pill.received .db-tr-status-pill__dot { background: #10b981; }
    .db-tr-status-pill.cancelled { background: #fef2f2; color: #991b1b; }
    .db-tr-status-pill.cancelled .db-tr-status-pill__dot { background: #ef4444; }
    .db-tr-action {
        display: inline-flex; align-items: center; gap: 4px;
        padding: 5px 12px; border: none; border-radius: calc(var(--radius-btn) - 4px);
        font-size: 11px; font-weight: 700; cursor: pointer;
        background: var(--navy); color: #fff; transition: opacity .12s;
    }
    .db-tr-action:hover { opacity: .88; }
</style>

<style>
    /* ─── Stats Grid ─── */
    .tr-stats-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }
    @media (max-width: 900px) {
        .tr-stats-grid { grid-template-columns: repeat(2, 1fr); }
    }
    .tr-stat-card {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 16px 20px;
        display: flex;
        align-items: center;
        gap: 16px;
    }
    .tr-stat-icon {
        width: 40px; height: 40px;
        border-radius: var(--radius-btn);
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .tr-stat-icon svg { width: 20px; height: 20px; }
    .tr-stat-value {
        font-size: 22px; font-weight: 800; color: var(--navy);
        letter-spacing: -0.03em; line-height: 1;
    }
    .tr-stat-label {
        font-size: 11px; color: rgba(16,55,92,0.50); font-weight: 500; margin-top: 2px;
    }

    /* ─── Toolbar ─── */
    .tr-toolbar {
        background: #fff; border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 14px 16px;
        display: flex; align-items: center; gap: 12px;
        margin-bottom: 16px;
    }
    .tr-search-wrap { position: relative; flex: 1; }
    .tr-search-icon {
        position: absolute; left: 12px; top: 50%; transform: translateY(-50%);
        width: 14px; height: 14px; color: rgba(16,55,92,0.30); pointer-events: none;
    }
    .tr-search-input {
        width: 100%; padding: 8px 14px 8px 36px;
        background: var(--alice); border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px; color: var(--navy); outline: none;
    }
    .tr-search-input::placeholder { color: rgba(16,55,92,0.30); }
    .tr-search-input:focus { border-color: rgba(16,55,92,0.30); }
    .btn-create-transfer {
        display: flex; align-items: center; gap: 8px;
        padding: 8px 16px;
        background: var(--orange); color: #fff;
        border: none; border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px; font-weight: 600; cursor: pointer; white-space: nowrap;
        transition: opacity .15s;
    }
    .btn-create-transfer:hover { opacity: .88; }
    .btn-create-transfer svg { width: 14px; height: 14px; }

    /* ─── Status Tabs ─── */
    .tr-tabs {
        background: #fff; border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 4px; display: flex; gap: 4px;
        margin-bottom: 16px;
    }
    .tr-tab {
        display: flex; align-items: center; gap: 8px;
        padding: 8px 16px;
        border: none; background: none; cursor: pointer;
        font-size: 12px; font-weight: 600; color: rgba(16,55,92,0.50);
        border-radius: calc(var(--radius-btn) - 4px);
        transition: all .15s;
    }
    .tr-tab.active { background: var(--navy); color: #fff; }
    .tr-tab:not(.active):hover { color: var(--navy); }
    .tr-tab-badge {
        padding: 1px 6px; border-radius: 999px;
        font-size: 10px; font-weight: 700;
    }
    .tr-tab.active .tr-tab-badge { background: rgba(255,255,255,.20); color: #fff; }
    .tr-tab:not(.active) .tr-tab-badge { background: rgba(16,55,92,0.08); color: rgba(16,55,92,0.60); }

    /* ─── Table Card ─── */
    .tr-table-card {
        background: #fff; border: 1px solid var(--border);
        border-radius: var(--radius-card); overflow: hidden;
    }
    .tr-table-scroll { overflow-x: auto; }
    .tr-table { width: 100%; border-collapse: collapse; }
    .tr-table thead tr {
        background: var(--alice); border-bottom: 1px solid var(--border);
    }
    .tr-table thead th {
        padding: 10px 16px;
        font-size: 10px; font-weight: 700; text-transform: uppercase;
        letter-spacing: .08em; color: rgba(16,55,92,0.40);
        white-space: nowrap;
    }
    .tr-table thead th:first-child { padding-left: 20px; }
    .tr-table thead th.text-right { text-align: right; }
    .tr-table tbody tr {
        border-bottom: 1px solid var(--border); transition: background .12s;
    }
    .tr-table tbody tr:last-child { border-bottom: none; }
    .tr-table tbody tr:hover { background: rgba(var(--alice-rgb, 240,245,250), .4); }
    .tr-table tbody td { padding: 14px 16px; }
    .tr-table tbody td:first-child { padding-left: 20px; }
    .tr-table tbody td.text-right { text-align: right; }
    .tr-id { font-family: monospace; font-weight: 700; font-size: 12px; color: var(--navy); }
    .tr-sku-name { font-size: 13px; font-weight: 600; color: var(--navy); }
    .tr-sku-code { font-size: 10px; font-family: monospace; color: rgba(16,55,92,0.40); margin-top: 2px; }
    .tr-wh-name { font-size: 12px; font-weight: 500; color: var(--navy); }
    .tr-zone-name { font-size: 11px; color: rgba(16,55,92,0.50); margin-top: 2px; }
    .tr-qty { font-size: 14px; font-weight: 700; color: var(--navy); }
    .tr-creator { font-size: 12px; font-weight: 500; color: var(--navy); }
    .tr-created-at { font-size: 10px; color: rgba(16,55,92,0.40); margin-top: 2px; }

    /* Status badges */
    .tr-badge {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 4px 10px; border-radius: 20px;
        font-size: 11px; font-weight: 600;
    }
    .tr-badge__dot { width: 6px; height: 6px; border-radius: 50%; }
    .tr-badge--draft     { background: rgba(16,55,92,.08); color: rgba(16,55,92,.60); }
    .tr-badge--draft .tr-badge__dot { background: rgba(16,55,92,.30); }
    .tr-badge--pending   { background: rgba(255,186,8,.20); color: #c2410c; }
    .tr-badge--pending .tr-badge__dot { background: #fbbf24; }
    .tr-badge--completed { background: #ecfdf5; color: #065f46; }
    .tr-badge--completed .tr-badge__dot { background: #10b981; }
    .tr-badge--cancelled { background: #fef2f2; color: #991b1b; }
    .tr-badge--cancelled .tr-badge__dot { background: #ef4444; }

    /* Row actions */
    .tr-actions { display: flex; align-items: center; justify-content: flex-end; gap: 6px; }
    .tr-btn-icon {
        width: 32px; height: 32px;
        display: flex; align-items: center; justify-content: center;
        border: none; background: none; cursor: pointer;
        color: rgba(16,55,92,0.40); border-radius: calc(var(--radius-btn) - 4px);
        transition: all .12s;
    }
    .tr-btn-icon:hover { color: var(--navy); background: var(--alice); }
    .tr-btn-icon svg { width: 15px; height: 15px; }
    .tr-btn-icon--danger:hover { color: #ef4444; background: #fef2f2; }
    .tr-btn-submit {
        padding: 4px 10px; border: none; cursor: pointer;
        background: var(--navy); color: #fff;
        font-size: 11px; font-weight: 700;
        border-radius: calc(var(--radius-btn) - 4px);
        transition: opacity .12s;
    }
    .tr-btn-submit:hover { opacity: .85; }
    .tr-badge-pending-row {
        display: inline-flex; align-items: center; gap: 4px;
        padding: 4px 10px;
        background: #fffbeb; color: #b45309;
        font-size: 11px; font-weight: 600;
        border: 1px solid #fde68a;
        border-radius: calc(var(--radius-btn) - 4px);
    }
    .tr-empty {
        text-align: center; padding: 40px 20px;
        font-size: 13px; color: rgba(16,55,92,0.40);
    }

    /* ─── Modals ─── */
    .tr-overlay {
        position: fixed; inset: 0;
        background: rgba(16,55,92,0.40);
        backdrop-filter: blur(4px);
        display: flex; align-items: center; justify-content: center;
        z-index: 1000; padding: 16px;
    }
    .tr-modal {
        background: #fff; width: 100%; max-width: 520px;
        border-radius: var(--radius-card);
        box-shadow: 0 25px 50px rgba(16,55,92,.20);
        display: flex; flex-direction: column;
        max-height: 92vh; overflow: hidden;
    }
    .tr-modal-hd {
        display: flex; align-items: center; justify-content: space-between;
        padding: 18px 24px; border-bottom: 1px solid var(--border);
    }
    .tr-modal-hd h2 {
        font-size: 16px; font-weight: 800; color: var(--navy);
        text-transform: uppercase; letter-spacing: .04em; margin: 0;
    }
    .tr-modal-hd p { font-size: 12px; color: rgba(16,55,92,0.40); margin: 2px 0 0; }
    .tr-modal-close {
        background: none; border: none; cursor: pointer;
        font-size: 22px; line-height: 1; color: rgba(16,55,92,0.40);
    }
    .tr-modal-close:hover { color: var(--navy); }
    .tr-modal-body {
        padding: 24px; overflow-y: auto; flex: 1;
        display: flex; flex-direction: column; gap: 20px;
    }
    .tr-form-section-title {
        font-size: 12px; font-weight: 700; text-transform: uppercase;
        letter-spacing: .06em; color: var(--navy);
        padding-bottom: 8px; border-bottom: 1px solid rgba(16,55,92,0.10);
        margin-bottom: 12px;
    }
    .tr-form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
    .tr-form-group { display: flex; flex-direction: column; gap: 6px; }
    .tr-form-label {
        font-size: 11px; font-weight: 600; text-transform: uppercase;
        color: rgba(16,55,92,0.60); letter-spacing: .04em;
    }
    .tr-form-label-row {
        display: flex; align-items: center; justify-content: space-between;
    }
    .tr-available-badge {
        font-size: 11px; font-weight: 700; color: var(--orange);
        background: rgba(255,186,8,.20); padding: 2px 8px; border-radius: 10px;
    }
    .tr-input, .tr-select, .tr-textarea {
        padding: 8px 12px;
        border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px; color: var(--navy);
        background: #fff; outline: none; width: 100%;
        font-family: inherit;
    }
    .tr-select { background: var(--alice); }
    .tr-input:focus, .tr-select:focus, .tr-textarea:focus { border-color: rgba(16,55,92,0.30); }
    .tr-textarea { resize: none; }
    .tr-zone-box {
        padding: 14px 16px;
        background: rgba(var(--alice-rgb,240,245,250),.5);
        border: 1px solid #e2e8f0;
        border-radius: calc(var(--radius-btn) - 2px);
    }
    .tr-zone-box-label {
        font-size: 11px; font-weight: 700; text-transform: uppercase;
        color: rgba(16,55,92,0.70);
        display: flex; align-items: center; gap: 6px; margin-bottom: 10px;
    }
    .tr-zone-box-bar { width: 6px; height: 12px; border-radius: 3px; flex-shrink: 0; }
    .tr-zone-box + .tr-zone-box { margin-top: 12px; }
    .tr-zone-select-row { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
    .tr-sub-label {
        font-size: 10px; font-weight: 600; text-transform: uppercase;
        color: rgba(16,55,92,0.50); margin-bottom: 4px; letter-spacing: .04em;
    }
    .tr-select-sm {
        padding: 7px 10px;
        border: 1px solid var(--border); border-radius: calc(var(--radius-btn) - 4px);
        font-size: 12px; color: var(--navy);
        background: #fff; outline: none; width: 100%;
    }
    .tr-modal-ft {
        display: flex; align-items: center; justify-content: flex-end;
        gap: 10px; padding: 14px 24px;
        border-top: 1px solid var(--border); background: var(--alice);
    }
    .tr-btn { padding: 8px 16px; border-radius: calc(var(--radius-btn) - 2px); font-size: 13px; font-weight: 600; cursor: pointer; border: none; transition: opacity .15s; }
    .tr-btn--cancel  { background: #fff; border: 1px solid var(--border); color: rgba(16,55,92,0.70); }
    .tr-btn--cancel:hover  { color: var(--navy); }
    .tr-btn--draft   { background: var(--navy); color: #fff; }
    .tr-btn--draft:hover   { opacity: .85; }
    .tr-btn--submit  { background: var(--orange); color: #fff; }
    .tr-btn--submit:hover  { opacity: .85; }
    .tr-btn--close   { background: var(--navy); color: #fff; }
    .tr-btn--close:hover   { opacity: .85; }

    /* Detail modal extras */
    .tr-detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
    .tr-detail-section { padding-top: 14px; border-top: 1px solid var(--border); }
    .tr-detail-dl-label { font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.40); margin-bottom: 2px; }
    .tr-detail-dl-val { font-size: 13px; font-weight: 700; color: var(--navy); }
    .tr-detail-dl-val--sm { font-size: 12px; font-weight: 600; }
    .tr-detail-dl-val--muted { font-size: 11px; color: rgba(16,55,92,0.50); }
    .tr-detail-flow {
        display: grid; grid-template-columns: 1fr auto 1fr;
        align-items: center; gap: 8px;
        background: var(--alice); padding: 12px;
        border-radius: calc(var(--radius-btn) - 2px);
    }
    .tr-detail-flow-arrow { color: rgba(16,55,92,0.40); }
    .tr-detail-flow-arrow svg { width: 16px; height: 16px; }
    .tr-detail-note {
        font-size: 12px; color: rgba(16,55,92,0.70); line-height: 1.6;
        background: rgba(var(--alice-rgb,240,245,250),.5); padding: 10px 12px;
        border: 1px solid var(--border); border-radius: calc(var(--radius-btn) - 4px);
    }
    .tr-pending-info {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 8px 16px; background: #fffbeb; color: #b45309;
        font-size: 12px; font-weight: 600;
        border: 1px solid #fde68a; border-radius: calc(var(--radius-btn) - 2px);
    }
</style>

<!-- ═══ DB-SIDE TRANSFERS (from servlet) ═══ -->
<c:if test="${not empty transfers || not empty warehouses}">
<div class="db-tr-header">
    <div>
        <div class="db-tr-title">Danh sách lệnh chuyển kho (Database)</div>
        <div class="db-tr-subtitle">Dữ liệu chuyển kho từ MySQL — Logic xử lý Day 3</div>
    </div>
    <div class="db-tr-badge">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:12px;height:12px;"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/></svg>
        MySQL · Transfer Day 3
    </div>
</div>

<div class="db-tr-tabs" id="dbTrTabs">
    <button class="db-tr-tab active" data-tab="all">
        Tất cả <span class="db-tr-count" id="dbTr-all">0</span>
    </button>
    <button class="db-tr-tab" data-tab="DRAFT">
        Nháp <span class="db-tr-count" id="dbTr-DRAFT">0</span>
    </button>
    <button class="db-tr-tab" data-tab="IN_TRANSIT">
        Đang chuyển <span class="db-tr-count" id="dbTr-IN_TRANSIT">0</span>
    </button>
    <button class="db-tr-tab" data-tab="RECEIVED">
        Đã nhận <span class="db-tr-count" id="dbTr-RECEIVED">0</span>
    </button>
    <button class="db-tr-tab" data-tab="CANCELLED">
        Đã hủy <span class="db-tr-count" id="dbTr-CANCELLED">0</span>
    </button>
</div>

<div class="db-tr-table-card">
    <table class="db-tr-table">
        <thead>
            <tr>
                <th>Mã phiếu</th>
                <th>Từ kho</th>
                <th>Đến kho</th>
                <th>Ngày tạo</th>
                <th>Trạng thái</th>
                <th class="text-right">Thao tác</th>
            </tr>
        </thead>
        <tbody id="dbTrTableBody">
        </tbody>
    </table>
</div>

<div style="margin-bottom:16px; padding-bottom:16px; border-bottom:1px dashed var(--border);">
    <div style="font-size:12px; font-weight:700; color:rgba(16,55,92,.40); text-transform:uppercase; letter-spacing:.05em; margin-bottom:6px;">Local Demo</div>
    <div style="font-size:12px; color:rgba(16,55,92,.30);">Dữ liệu demo sử dụng localStorage — dùng bảng Database phía trên để làm việc thực tế.</div>
</div>
</c:if>

<!-- ═══ STATS ROW ═══ -->
<div class="tr-stats-grid" id="trStatsGrid">
    <!-- Tổng số yêu cầu -->
    <div class="tr-stat-card">
        <div class="tr-stat-icon" style="background: rgba(16,55,92,0.08);">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                 stroke="rgba(16,55,92,1)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                <polyline points="14 2 14 8 20 8"/>
                <line x1="16" y1="13" x2="8" y2="13"/>
                <line x1="16" y1="17" x2="8" y2="17"/>
                <polyline points="10 9 9 9 8 9"/>
            </svg>
        </div>
        <div>
            <div class="tr-stat-value" id="statTotal">0</div>
            <div class="tr-stat-label">Tổng số yêu cầu</div>
        </div>
    </div>
    <!-- Chờ duyệt -->
    <div class="tr-stat-card">
        <div class="tr-stat-icon" style="background: rgba(255,186,8,0.20);">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                 stroke="var(--orange)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/>
                <polyline points="12 6 12 12 16 14"/>
            </svg>
        </div>
        <div>
            <div class="tr-stat-value" id="statPending" style="color: var(--orange);">0</div>
            <div class="tr-stat-label">Chờ duyệt</div>
        </div>
    </div>
    <!-- Đã hoàn thành -->
    <div class="tr-stat-card">
        <div class="tr-stat-icon" style="background: #ecfdf5;">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                 stroke="#059669" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                <polyline points="22 4 12 14.01 9 11.01"/>
            </svg>
        </div>
        <div>
            <div class="tr-stat-value" id="statCompleted" style="color: #059669;">0</div>
            <div class="tr-stat-label">Đã hoàn thành</div>
        </div>
    </div>
    <!-- Bản nháp -->
    <div class="tr-stat-card">
        <div class="tr-stat-icon" style="background: rgba(16,55,92,0.05);">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                 stroke="rgba(16,55,92,0.50)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
                <line x1="12" y1="9" x2="12" y2="13"/>
                <line x1="12" y1="17" x2="12.01" y2="17"/>
            </svg>
        </div>
        <div>
            <div class="tr-stat-value" id="statDraft" style="color: rgba(16,55,92,0.60);">0</div>
            <div class="tr-stat-label">Bản nháp</div>
        </div>
    </div>
</div>

<!-- ═══ TOOLBAR ═══ -->
<div class="tr-toolbar">
    <div class="tr-search-wrap">
        <svg class="tr-search-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
             fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
        </svg>
        <input class="tr-search-input" type="text" id="trSearch"
               placeholder="Tìm mã phiếu, SKU, tên sản phẩm, kho..."/>
    </div>
    <button class="btn-create-transfer" id="btnOpenCreate">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
        </svg>
        Tạo phiếu chuyển kho
    </button>
</div>

<!-- ═══ STATUS TABS ═══ -->
<div class="tr-tabs" id="trTabs">
    <button class="tr-tab active" data-tab="all">
        Tất cả <span class="tr-tab-badge" id="badge-all">0</span>
    </button>
    <button class="tr-tab" data-tab="draft">
        Bản nháp <span class="tr-tab-badge" id="badge-draft">0</span>
    </button>
    <button class="tr-tab" data-tab="pending_approval">
        Chờ duyệt <span class="tr-tab-badge" id="badge-pending">0</span>
    </button>
    <button class="tr-tab" data-tab="completed">
        Đã hoàn thành <span class="tr-tab-badge" id="badge-completed">0</span>
    </button>
    <button class="tr-tab" data-tab="cancelled">
        Đã hủy <span class="tr-tab-badge" id="badge-cancelled">0</span>
    </button>
</div>

<!-- ═══ TABLE CARD ═══ -->
<div class="tr-table-card">
    <div class="tr-table-scroll">
        <table class="tr-table">
            <thead>
                <tr>
                    <th>Mã phiếu</th>
                    <th>Sản phẩm (SKU)</th>
                    <th>Nguồn xuất (Từ Kho - Zone)</th>
                    <th>Đích nhập (Đến Kho - Zone)</th>
                    <th class="text-right">Số lượng</th>
                    <th>Người tạo</th>
                    <th>Trạng thái</th>
                    <th class="text-right">Thao tác</th>
                </tr>
            </thead>
            <tbody id="trTableBody">
                <!-- Rendered by JS -->
            </tbody>
        </table>
    </div>
</div>

<!-- ═══ MODAL: TẠO PHIẾU CHUYỂN KHO ═══ -->
<div class="tr-overlay" id="createOverlay" style="display:none;">
    <div class="tr-modal" id="createModal">
        <div class="tr-modal-hd">
            <div>
                <h2>Tạo Phiếu Chuyển Kho Hàng</h2>
                <p>Tạo yêu cầu dịch chuyển vị trí lưu trữ của sản phẩm</p>
            </div>
            <button class="tr-modal-close" id="btnCloseCreate">×</button>
        </div>
        <div class="tr-modal-body">
            <!-- THÔNG TIN SẢN PHẨM -->
            <div>
                <div class="tr-form-section-title">Thông tin sản phẩm</div>
                <div style="display:flex; flex-direction:column; gap:12px;">
                    <div class="tr-form-group">
                        <label class="tr-form-label">Mã sản phẩm (Master SKU) *</label>
                        <select class="tr-input" id="formSkuCode" style="background: #fff; cursor: pointer;">
                            <option value="">— Chọn sản phẩm (SKU) —</option>
                        </select>
                    </div>
                    <div class="tr-form-group">
                        <label class="tr-form-label">Tên sản phẩm</label>
                        <input class="tr-input" type="text" id="formSkuName" placeholder="Tên sản phẩm..." readonly style="background: var(--alice); cursor: not-allowed;"/>
                    </div>
                    <div class="tr-form-group">
                        <div class="tr-form-label-row">
                            <label class="tr-form-label">Số lượng cần chuyển *</label>
                            <span class="tr-available-badge" id="availableDisplay">Khả dụng: — sản phẩm</span>
                        </div>
                        <input class="tr-input" type="number" id="formQty" min="1" value="1"/>
                    </div>
                </div>
            </div>

            <!-- THÔNG TIN ĐIỀU CHUYỂN -->
            <div>
                <div class="tr-form-section-title">Thông tin điều chuyển</div>

                <!-- TỪ -->
                <div class="tr-zone-box" style="margin-bottom:12px;">
                    <div class="tr-zone-box-label">
                        <span class="tr-zone-box-bar" style="background: var(--orange);"></span>
                        TỪ (Nguồn Xuất):
                    </div>
                    <div class="tr-zone-select-row">
                        <div>
                            <div class="tr-sub-label">Chi nhánh Kho</div>
                            <select class="tr-select-sm" id="formSourceWH">
                                <option value="">— Chọn kho xuất —</option>
                            </select>
                        </div>
                        <div>
                            <div class="tr-sub-label">Khu vực (Zone)</div>
                            <select class="tr-select-sm" id="formSourceZone">
                                <option value="">— Chọn zone —</option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- ĐẾN -->
                <div class="tr-zone-box">
                    <div class="tr-zone-box-label">
                        <span class="tr-zone-box-bar" style="background: var(--navy);"></span>
                        ĐẾN (Đích Nhập):
                    </div>
                    <div class="tr-zone-select-row">
                        <div>
                            <div class="tr-sub-label">Chi nhánh Kho</div>
                            <select class="tr-select-sm" id="formDestWH">
                                <option value="">— Chọn kho nhập —</option>
                            </select>
                        </div>
                        <div>
                            <div class="tr-sub-label">Khu vực (Zone)</div>
                            <select class="tr-select-sm" id="formDestZone">
                                <option value="">— Chọn zone —</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <!-- GHI CHÚ -->
            <div class="tr-form-group">
                <label class="tr-form-label">Ghi chú / Lý do điều chuyển</label>
                <textarea class="tr-textarea" id="formNote" rows="3"
                          placeholder="Ví dụ: Phát hiện 5 sản phẩm bị trầy xước trong quá trình đóng gói, chuyển sang Zone Hàng Hỏng chờ xử lý"></textarea>
            </div>
        </div>
        <div class="tr-modal-ft">
            <button class="tr-btn tr-btn--cancel" id="btnCancelCreate">HỦY</button>
            <button class="tr-btn tr-btn--draft"  id="btnSaveDraft">LƯU NHÁP</button>
            <button class="tr-btn tr-btn--submit" id="btnSubmitApproval">TRÌNH DUYỆT</button>
        </div>
    </div>
</div>

<!-- ═══ MODAL: CHI TIẾT PHIẾU ═══ -->
<div class="tr-overlay" id="detailOverlay" style="display:none;" onclick="closeDetailModal(event)">
    <div class="tr-modal" id="detailModal" onclick="event.stopPropagation()">
        <div class="tr-modal-hd" style="background: rgba(var(--alice-rgb,240,245,250),.3);">
            <h2 style="text-transform:none; font-size:15px;">Chi tiết Phiếu Chuyển Kho</h2>
            <button class="tr-modal-close" onclick="document.getElementById('detailOverlay').style.display='none'">×</button>
        </div>
        <div class="tr-modal-body" id="detailBody">
            <!-- populated by JS -->
        </div>
        <div class="tr-modal-ft">
            <span class="tr-pending-info" id="detailPendingNote" style="display:none;">
                Đang chờ Business Manager phê duyệt
            </span>
            <button class="tr-btn tr-btn--close"
                    onclick="document.getElementById('detailOverlay').style.display='none'">Đóng</button>
        </div>
    </div>
</div>

<!-- ═══ JAVASCRIPT ═══ -->
<script>
(function () {
    'use strict';

    // ─── Master data (warehouse branches & zones) ───
    var WAREHOUSES = [];



    // ─── State ───
    var transfers   = [];
    var activeTab   = 'all';
    var searchText  = '';
    var detailDoc   = null;

    // Master Product List (Empty as requested by the user, but ready for future use)
    var PRODUCTS    = [];

    // ─── DOM refs ───
    var trTableBody    = document.getElementById('trTableBody');
    var trSearch       = document.getElementById('trSearch');
    var trTabs         = document.getElementById('trTabs');
    var createOverlay  = document.getElementById('createOverlay');
    var detailOverlay  = document.getElementById('detailOverlay');
    var detailBody     = document.getElementById('detailBody');
    var detailPendingNote = document.getElementById('detailPendingNote');
    var formSkuCode    = document.getElementById('formSkuCode');
    var formSkuName    = document.getElementById('formSkuName');
    var formQty        = document.getElementById('formQty');
    var formSourceWH   = document.getElementById('formSourceWH');
    var formSourceZone = document.getElementById('formSourceZone');
    var formDestWH     = document.getElementById('formDestWH');
    var formDestZone   = document.getElementById('formDestZone');
    var formNote       = document.getElementById('formNote');
    var availableDisplay = document.getElementById('availableDisplay');

    // ─── Populate Products select ───
    function populateProducts() {
        formSkuCode.innerHTML = '<option value="">— Chọn sản phẩm (SKU) —</option>';
        PRODUCTS.forEach(function (p) {
            var opt = document.createElement('option');
            opt.value = p.sku;
            opt.textContent = p.sku + ' - ' + p.name;
            formSkuCode.appendChild(opt);
        });
    }
    populateProducts();

    formSkuCode.addEventListener('change', function () {
        var sku = this.value;
        var prod = PRODUCTS.find(function (p) { return p.sku === sku; });
        formSkuName.value = prod ? prod.name : '';
        updateAvailable();
    });

    // ─── Populate warehouse selects ───
    function populateWarehouseSelects() {
        [formSourceWH, formDestWH].forEach(function (sel, idx) {
            var ph = idx === 0 ? '— Chọn kho xuất —' : '— Chọn kho nhập —';
            sel.innerHTML = '<option value="">' + ph + '</option>';
            WAREHOUSES.forEach(function (w) {
                var opt = document.createElement('option');
                opt.value = w.code;
                opt.textContent = w.name;
                sel.appendChild(opt);
            });
        });
    }
    populateWarehouseSelects();

    populateZones(formSourceWH, formSourceZone);
    populateZones(formDestWH,   formDestZone);

    function populateZones(whSelect, zoneSelect) {
        var code = whSelect.value;
        var wh = WAREHOUSES.find(function (w) { return w.code === code; });
        zoneSelect.innerHTML = '<option value="">— Chọn zone —</option>';
        if (wh && wh.zones) {
            wh.zones.forEach(function (z) {
                var opt = document.createElement('option');
                opt.value = z.code;
                opt.textContent = z.name;
                zoneSelect.appendChild(opt);
            });
        }
    }

    formSourceWH.addEventListener('change', function () { populateZones(formSourceWH, formSourceZone); });
    formDestWH.addEventListener('change',   function () { populateZones(formDestWH,   formDestZone); });

    function updateAvailable() {
        // No backend: just show a dash — real stock check happens server-side
        availableDisplay.textContent = 'Khả dụng: — sản phẩm';
    }

    // ─── Open / Close create modal ───
    document.getElementById('btnOpenCreate').addEventListener('click', function () {
        formSkuCode.value  = '';
        formSkuName.value  = '';
        formQty.value      = 1;
        formNote.value     = '';
        createOverlay.style.display = 'flex';
    });
    document.getElementById('btnCloseCreate').addEventListener('click',  function () { createOverlay.style.display = 'none'; });
    document.getElementById('btnCancelCreate').addEventListener('click', function () { createOverlay.style.display = 'none'; });
    createOverlay.addEventListener('click', function (e) { if (e.target === createOverlay) createOverlay.style.display = 'none'; });

    // ─── Create transfer ───
    function handleCreate(isSubmit) {
        var skuCode = formSkuCode.value.trim();
        if (!skuCode) { alert('Vui lòng chọn mã sản phẩm (SKU)'); return; }
        var qty = parseInt(formQty.value, 10) || 0;
        if (qty <= 0) { alert('Số lượng điều chuyển phải lớn hơn 0'); return; }

        var sourceWHCode   = formSourceWH.value;
        var sourceZoneCode = formSourceZone.value;
        var destWHCode     = formDestWH.value;
        var destZoneCode   = formDestZone.value;
        if (sourceWHCode === destWHCode && sourceZoneCode === destZoneCode) {
            alert('Nơi xuất và nơi nhập không được trùng nhau hoàn toàn!');
            return;
        }

        var sourceWH   = WAREHOUSES.find(function (w) { return w.code === sourceWHCode; });
        var destWH     = WAREHOUSES.find(function (w) { return w.code === destWHCode; });
        var sourceZone = sourceWH ? sourceWH.zones.find(function (z) { return z.code === sourceZoneCode; }) : null;
        var destZone   = destWH   ? destWH.zones.find(function (z) { return z.code === destZoneCode; })   : null;

        var nextNum = String(transfers.length + 1).padStart(3, '0');
        var now     = new Date();
        var nowStr  = now.getFullYear() + '-' +
                      String(now.getMonth() + 1).padStart(2, '0') + '-' +
                      String(now.getDate()).padStart(2, '0') + ' ' +
                      String(now.getHours()).padStart(2, '0') + ':' +
                      String(now.getMinutes()).padStart(2, '0');

        var doc = {
            id:                   'TR-2026-' + nextNum,
            skuCode:              skuCode,
            skuName:              formSkuName.value.trim(),
            qty:                  qty,
            sourceWarehouseCode:  sourceWHCode,
            sourceWarehouseName:  sourceWH   ? sourceWH.name   : sourceWHCode,
            sourceZoneCode:       sourceZoneCode,
            sourceZoneName:       sourceZone ? sourceZone.name : sourceZoneCode,
            destWarehouseCode:    destWHCode,
            destWarehouseName:    destWH     ? destWH.name     : destWHCode,
            destZoneCode:         destZoneCode,
            destZoneName:         destZone   ? destZone.name   : destZoneCode,
            status:               isSubmit ? 'pending_approval' : 'draft',
            createdBy:            'Nhân viên kho',
            createdAt:            nowStr,
            note:                 formNote.value.trim() || null
        };

        transfers.unshift(doc);
        createOverlay.style.display = 'none';
        formSkuCode.value  = '';
        formSkuName.value  = '';
        formQty.value      = 1;
        formNote.value     = '';
        render();
    }

    document.getElementById('btnSaveDraft').addEventListener('click',      function () { handleCreate(false); });
    document.getElementById('btnSubmitApproval').addEventListener('click', function () { handleCreate(true); });

    // ─── Tab switching ───
    trTabs.addEventListener('click', function (e) {
        var btn = e.target.closest('.tr-tab');
        if (!btn) return;
        activeTab = btn.dataset.tab;
        trTabs.querySelectorAll('.tr-tab').forEach(function (t) { t.classList.remove('active'); });
        btn.classList.add('active');
        render();
    });

    // ─── Search ───
    trSearch.addEventListener('input', function () { searchText = this.value; render(); });

    // ─── Status badge helper ───
    function statusBadge(status) {
        var cfg = {
            draft:            { cls: 'tr-badge--draft',     label: 'Nháp' },
            pending_approval: { cls: 'tr-badge--pending',   label: 'Chờ duyệt' },
            completed:        { cls: 'tr-badge--completed', label: 'Đã hoàn thành' },
            cancelled:        { cls: 'tr-badge--cancelled', label: 'Đã hủy' }
        };
        var c = cfg[status] || cfg.draft;
        return '<span class="tr-badge ' + c.cls + '">' +
               '<span class="tr-badge__dot"></span>' + esc(c.label) + '</span>';
    }

    // ─── Render ───
    function render() {
        // Counts
        var counts = {
            all:              transfers.length,
            draft:            transfers.filter(function (t) { return t.status === 'draft'; }).length,
            pending_approval: transfers.filter(function (t) { return t.status === 'pending_approval'; }).length,
            completed:        transfers.filter(function (t) { return t.status === 'completed'; }).length,
            cancelled:        transfers.filter(function (t) { return t.status === 'cancelled'; }).length
        };
        document.getElementById('statTotal').textContent     = counts.all;
        document.getElementById('statPending').textContent   = counts.pending_approval;
        document.getElementById('statCompleted').textContent = counts.completed;
        document.getElementById('statDraft').textContent     = counts.draft;

        document.getElementById('badge-all').textContent       = counts.all;
        document.getElementById('badge-draft').textContent     = counts.draft;
        document.getElementById('badge-pending').textContent   = counts.pending_approval;
        document.getElementById('badge-completed').textContent = counts.completed;
        document.getElementById('badge-cancelled').textContent = counts.cancelled;

        // Filter
        var q = searchText.toLowerCase();
        var filtered = transfers.filter(function (t) {
            var matchTab  = activeTab === 'all' || t.status === activeTab;
            var matchSearch = !q ||
                t.id.toLowerCase().includes(q) ||
                t.skuCode.toLowerCase().includes(q) ||
                t.skuName.toLowerCase().includes(q) ||
                t.sourceWarehouseName.toLowerCase().includes(q) ||
                t.destWarehouseName.toLowerCase().includes(q);
            return matchTab && matchSearch;
        });

        if (filtered.length === 0) {
            trTableBody.innerHTML = '<tr><td colspan="8" class="tr-empty">Không tìm thấy phiếu chuyển kho nào phù hợp.</td></tr>';
            return;
        }

        trTableBody.innerHTML = filtered.map(function (t) {
            var actions = '';
            // Eye button
            actions += '<button class="tr-btn-icon" data-action="view" data-id="' + esc(t.id) + '" title="Xem chi tiết">' +
                       eyeSVG() + '</button>';
            if (t.status === 'pending_approval') {
                actions += '<span class="tr-badge-pending-row">Chờ duyệt</span>';
            }
            if (t.status === 'draft') {
                actions += '<button class="tr-btn-submit" data-action="submit" data-id="' + esc(t.id) + '">Gửi duyệt</button>' +
                           '<button class="tr-btn-icon tr-btn-icon--danger" data-action="delete" data-id="' + esc(t.id) + '" title="Xóa nháp">' +
                           trashSVG() + '</button>';
            }

            return '<tr>' +
                '<td><span class="tr-id">' + esc(t.id) + '</span></td>' +
                '<td><div class="tr-sku-name">' + esc(t.skuName) + '</div><div class="tr-sku-code">' + esc(t.skuCode) + '</div></td>' +
                '<td><div class="tr-wh-name">'  + esc(t.sourceWarehouseName) + '</div><div class="tr-zone-name">' + esc(t.sourceZoneName) + '</div></td>' +
                '<td><div class="tr-wh-name">'  + esc(t.destWarehouseName)   + '</div><div class="tr-zone-name">' + esc(t.destZoneName)   + '</div></td>' +
                '<td class="text-right"><span class="tr-qty">' + esc(t.qty) + '</span></td>' +
                '<td><div class="tr-creator">' + esc(t.createdBy) + '</div><div class="tr-created-at">' + esc(t.createdAt) + '</div></td>' +
                '<td>' + statusBadge(t.status) + '</td>' +
                '<td class="text-right"><div class="tr-actions">' + actions + '</div></td>' +
                '</tr>';
        }).join('');
    }

    // ─── Table action delegation ───
    trTableBody.addEventListener('click', function (e) {
        var btn = e.target.closest('[data-action]');
        if (!btn) return;
        var action = btn.dataset.action;
        var id     = btn.dataset.id;
        var doc    = transfers.find(function (t) { return t.id === id; });
        if (!doc) return;

        if (action === 'view') {
            openDetailModal(doc);
        } else if (action === 'submit') {
            doc.status = 'pending_approval';
            render();
        } else if (action === 'delete') {
            if (window.confirm('Bạn có chắc chắn muốn xóa bản nháp này?')) {
                transfers = transfers.filter(function (t) { return t.id !== id; });
                render();
            }
        }
    });

    // ─── Detail modal ───
    function openDetailModal(doc) {
        detailDoc = doc;

        var approvedSection = '';
        if (doc.approvedBy) {
            approvedSection = '<div class="tr-detail-section">' +
                '<div class="tr-detail-grid">' +
                '<div><div class="tr-detail-dl-label">Người duyệt:</div><div class="tr-detail-dl-val tr-detail-dl-val--sm">' + esc(doc.approvedBy) + '</div></div>' +
                '<div><div class="tr-detail-dl-label">Thời điểm duyệt:</div><div class="tr-detail-dl-val tr-detail-dl-val--muted">' + esc(doc.approvedAt || '') + '</div></div>' +
                '</div></div>';
        }

        var noteSection = '';
        if (doc.note) {
            noteSection = '<div class="tr-detail-section">' +
                '<div class="tr-detail-dl-label" style="margin-bottom:6px;">Ghi chú / Lý do:</div>' +
                '<div class="tr-detail-note">' + esc(doc.note) + '</div>' +
                '</div>';
        }

        detailBody.innerHTML =
            '<div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;padding-bottom:14px;border-bottom:1px solid var(--border);">' +
                '<div><div class="tr-detail-dl-label">Mã phiếu:</div><div style="font-weight:700;font-size:14px;color:var(--navy);margin-top:2px;">' + esc(doc.id) + '</div></div>' +
                '<div><div class="tr-detail-dl-label">Trạng thái:</div><div style="margin-top:4px;">' + statusBadge(doc.status) + '</div></div>' +
            '</div>' +
            '<div>' +
                '<div class="tr-detail-dl-label" style="margin-bottom:4px;">Sản phẩm:</div>' +
                '<div style="font-size:13px;font-weight:700;color:var(--navy);">' + esc(doc.skuName) + '</div>' +
                '<div style="font-size:11px;font-family:monospace;color:rgba(16,55,92,0.50);margin-top:2px;">SKU: ' + esc(doc.skuCode) + '</div>' +
            '</div>' +
            '<div class="tr-detail-flow">' +
                '<div>' +
                    '<div class="tr-detail-dl-label" style="font-size:9px;">Từ:</div>' +
                    '<div style="font-size:11px;font-weight:700;color:var(--navy);">' + esc(doc.sourceWarehouseName) + '</div>' +
                    '<div style="font-size:10px;color:rgba(16,55,92,0.50);margin-top:2px;">' + esc(doc.sourceZoneName) + '</div>' +
                '</div>' +
                '<div class="tr-detail-flow-arrow"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 1l4 4-4 4"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/><path d="M7 23l-4-4 4-4"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/></svg></div>' +
                '<div>' +
                    '<div class="tr-detail-dl-label" style="font-size:9px;">Đến:</div>' +
                    '<div style="font-size:11px;font-weight:700;color:var(--navy);">' + esc(doc.destWarehouseName) + '</div>' +
                    '<div style="font-size:10px;color:rgba(16,55,92,0.50);margin-top:2px;">' + esc(doc.destZoneName) + '</div>' +
                '</div>' +
            '</div>' +
            '<div class="tr-detail-section">' +
                '<div class="tr-detail-grid">' +
                    '<div><div class="tr-detail-dl-label">Số lượng chuyển:</div><div style="font-size:14px;font-weight:700;color:var(--navy);margin-top:2px;">' + esc(doc.qty) + ' sản phẩm</div></div>' +
                    '<div><div class="tr-detail-dl-label">Người tạo:</div><div style="font-size:12px;font-weight:600;color:var(--navy);margin-top:2px;">' + esc(doc.createdBy) + '</div><div style="font-size:10px;color:rgba(16,55,92,0.40);">' + esc(doc.createdAt) + '</div></div>' +
                '</div>' +
            '</div>' +
            approvedSection +
            noteSection;

        detailPendingNote.style.display = doc.status === 'pending_approval' ? 'inline-flex' : 'none';
        detailOverlay.style.display = 'flex';
    }

    window.closeDetailModal = function (e) {
        if (e.target === detailOverlay) detailOverlay.style.display = 'none';
    };

    // ─── SVG helpers ───
    function eyeSVG() {
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>';
    }
    function trashSVG() {
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:14px;height:14px;"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>';
    }
    function esc(v) {
        if (v == null) return '';
        return String(v)
            .replace(/&/g,'&amp;').replace(/</g,'&lt;')
            .replace(/>/g,'&gt;').replace(/"/g,'&quot;')
            .replace(/'/g,'&#039;');
    }

    // ─── Init ───
    render();

    // ─── DB-Side Transfer Table ───
    (function() {
        'use strict';

        var dbTransfers = [
            <c:forEach items="${transfers}" var="t" varStatus="s">
                {
                    transferId: ${t.transferId},
                    transferCode: "<c:out value='${t.transferCode}'/>",
                    fromWarehouseName: "<c:out value='${t.fromWarehouseName}'/>",
                    toWarehouseName: "<c:out value='${t.toWarehouseName}'/>",
                    status: "<c:out value='${t.status}'/>",
                    createdAt: "<c:out value='${t.createdAt}'/>"
                }${!s.last ? ',' : ''}
            </c:forEach>
        ];

        var dbWarehouses = [
            <c:forEach items="${warehouses}" var="w" varStatus="s">
                { warehouseId: ${w.warehouseId}, warehouseName: "<c:out value='${w.warehouseName}'/>" }${!s.last ? ',' : ''}
            </c:forEach>
        ];

        var dbProducts = [
            <c:forEach items="${products}" var="p" varStatus="s">
                { sku: "<c:out value='${p.sku}'/>", name: "<c:out value='${p.name}'/>" }${!s.last ? ',' : ''}
            </c:forEach>
        ];

        var dbActiveTab = 'all';

        function dbTrStatusCfg(status) {
            var m = {
                'DRAFT':     { label: 'Nháp',       cls: 'draft' },
                'IN_TRANSIT':{ label: 'Đang chuyển', cls: 'in_transit' },
                'RECEIVED':  { label: 'Đã nhận',    cls: 'received' },
                'CANCELLED': { label: 'Đã hủy',     cls: 'cancelled' }
            };
            return m[status] || { label: status, cls: 'draft' };
        }

        function esc(v) {
            if (v == null) return '';
            return String(v).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
        }

        function renderDbTrTable() {
            var counts = {
                all:        dbTransfers.length,
                DRAFT:      dbTransfers.filter(function(t){ return t.status==='DRAFT'; }).length,
                IN_TRANSIT: dbTransfers.filter(function(t){ return t.status==='IN_TRANSIT'; }).length,
                RECEIVED:   dbTransfers.filter(function(t){ return t.status==='RECEIVED'; }).length,
                CANCELLED:  dbTransfers.filter(function(t){ return t.status==='CANCELLED'; }).length
            };

            ['all','DRAFT','IN_TRANSIT','RECEIVED','CANCELLED'].forEach(function(k) {
                var el = document.getElementById('dbTr-' + k);
                if (el) el.textContent = counts[k] || 0;
            });

            var filtered = dbActiveTab === 'all'
                ? dbTransfers
                : dbTransfers.filter(function(t){ return t.status === dbActiveTab; });

            var tbody = document.getElementById('dbTrTableBody');
            if (!tbody) return;

            if (filtered.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" class="db-tr-empty">Không có phiếu chuyển kho nào.</td></tr>';
                return;
            }

            tbody.innerHTML = filtered.map(function(t) {
                var sc = dbTrStatusCfg(t.status);
                return '<tr>' +
                    '<td><span class="db-tr-code">' + esc(t.transferCode) + '</span></td>' +
                    '<td><span class="db-tr-wh">' + esc(t.fromWarehouseName || '—') + '</span></td>' +
                    '<td><span class="db-tr-wh">' + esc(t.toWarehouseName || '—') + '</span></td>' +
                    '<td style="font-size:12px; color:rgba(16,55,92,.5);">' + esc(t.createdAt) + '</td>' +
                    '<td><span class="db-tr-status-pill ' + sc.cls + '"><span class="db-tr-status-pill__dot"></span>' + sc.label + '</span></td>' +
                    '<td class="text-right">' +
                        '<button class="db-tr-action">Xem chi tiết</button>' +
                    '</td>' +
                '</tr>';
            }).join('');
        }

        var tabs = document.getElementById('dbTrTabs');
        if (tabs) {
            tabs.addEventListener('click', function(e) {
                var btn = e.target.closest('.db-tr-tab');
                if (!btn) return;
                dbActiveTab = btn.dataset.tab;
                tabs.querySelectorAll('.db-tr-tab').forEach(function(t){ t.classList.remove('active'); });
                btn.classList.add('active');
                renderDbTrTable();
            });
        }

        // Populate warehouse selects with DB warehouses
        var srcWH = document.getElementById('formSourceWH');
        var dstWH = document.getElementById('formDestWH');
        if (srcWH && dbWarehouses.length > 0) {
            var defOpt = '<option value="">— Chọn kho —</option>';
            srcWH.innerHTML = defOpt + dbWarehouses.map(function(w){
                return '<option value="' + w.warehouseId + '">' + esc(w.warehouseName) + '</option>';
            }).join('');
        }
        if (dstWH && dbWarehouses.length > 0) {
            var defOpt = '<option value="">— Chọn kho —</option>';
            dstWH.innerHTML = defOpt + dbWarehouses.map(function(w){
                return '<option value="' + w.warehouseId + '">' + esc(w.warehouseName) + '</option>';
            }).join('');
        }

        // Populate product select with DB products
        var skuSelect = document.getElementById('formSkuCode');
        if (skuSelect && dbProducts.length > 0) {
            var defOpt = '<option value="">— Chọn sản phẩm (SKU) —</option>';
            skuSelect.innerHTML = defOpt + dbProducts.map(function(p){
                return '<option value="' + esc(p.sku) + '">' + esc(p.sku) + ' - ' + esc(p.name) + '</option>';
            }).join('');
        }

        renderDbTrTable();
    })();
})();
</script>
