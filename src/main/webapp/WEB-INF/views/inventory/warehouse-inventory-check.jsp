<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    /* ─── Stats Grid ─── */
    .ic-stats-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }
    @media (max-width: 900px) {
        .ic-stats-grid { grid-template-columns: repeat(2, 1fr); }
    }
    .ic-stat-card {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 16px 20px;
        display: flex;
        align-items: center;
        gap: 16px;
    }
    .ic-stat-icon {
        width: 40px; height: 40px;
        border-radius: var(--radius-btn);
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .ic-stat-icon svg { width: 20px; height: 20px; }
    .ic-stat-value {
        font-size: 22px; font-weight: 800; color: var(--navy);
        letter-spacing: -0.03em; line-height: 1;
    }
    .ic-stat-label {
        font-size: 11px; color: rgba(16,55,92,0.50); font-weight: 500; margin-top: 2px;
    }

    /* ─── Toolbar ─── */
    .ic-toolbar {
        background: #fff; border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 14px 16px;
        display: flex; align-items: center; gap: 12px;
        margin-bottom: 16px;
    }
    .ic-search-wrap { position: relative; flex: 1; }
    .ic-search-icon {
        position: absolute; left: 12px; top: 50%; transform: translateY(-50%);
        width: 14px; height: 14px; color: rgba(16,55,92,0.30); pointer-events: none;
    }
    .ic-search-input {
        width: 100%; padding: 8px 14px 8px 36px;
        background: var(--alice); border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px; color: var(--navy); outline: none;
    }
    .ic-search-input::placeholder { color: rgba(16,55,92,0.30); }
    .ic-search-input:focus { border-color: rgba(16,55,92,0.30); }
    .btn-create-check {
        display: flex; align-items: center; gap: 8px;
        padding: 8px 16px;
        background: var(--orange); color: #fff;
        border: none; border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px; font-weight: 600; cursor: pointer; white-space: nowrap;
        transition: opacity .15s;
    }
    .btn-create-check:hover { opacity: .88; }
    .btn-create-check svg { width: 14px; height: 14px; }
    
    .btn-export-report {
        display: flex; align-items: center; gap: 8px;
        padding: 8px 16px;
        background: var(--alice); color: rgba(16,55,92,0.7);
        border: 1px solid var(--border); border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px; font-weight: 600; cursor: pointer; white-space: nowrap;
        transition: all .15s;
    }
    .btn-export-report:hover { color: var(--navy); background: rgba(16,55,92,0.04); }
    .btn-export-report svg { width: 14px; height: 14px; }

    /* ─── Status Tabs ─── */
    .ic-tabs {
        background: #fff; border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 4px; display: flex; gap: 4px;
        margin-bottom: 16px;
    }
    .ic-tab {
        display: flex; align-items: center; gap: 8px;
        padding: 8px 16px;
        border: none; background: none; cursor: pointer;
        font-size: 12px; font-weight: 600; color: rgba(16,55,92,0.50);
        border-radius: calc(var(--radius-btn) - 4px);
        transition: all .15s;
    }
    .ic-tab.active { background: var(--navy); color: #fff; }
    .ic-tab:not(.active):hover { color: var(--navy); }
    .ic-tab-badge {
        padding: 1px 6px; border-radius: 999px;
        font-size: 10px; font-weight: 700;
    }
    .ic-tab.active .ic-tab-badge { background: rgba(255,255,255,.20); color: #fff; }
    .ic-tab:not(.active) .ic-tab-badge { background: rgba(16,55,92,0.08); color: rgba(16,55,92,0.60); }

    /* ─── Collapsible Sheet List ─── */
    .ic-list-container {
        display: flex; flex-direction: column; gap: 12px;
    }
    .ic-sheet-card {
        background: #fff; border: 1px solid var(--border);
        border-radius: var(--radius-card); overflow: hidden;
        transition: border-color .15s;
    }
    .ic-sheet-hd {
        display: flex; align-items: center; gap: 16px;
        padding: 16px 20px; cursor: pointer;
        transition: background .12s;
    }
    .ic-sheet-hd:hover { background: rgba(var(--alice-rgb, 240,245,250), .4); }
    .ic-sheet-icon {
        width: 40px; height: 40px; border-radius: var(--radius-btn);
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .ic-sheet-icon svg { width: 18px; height: 18px; }
    .ic-sheet-info { flex: 1; min-w: 0; }
    .ic-sheet-info-row { display: flex; align-items: center; gap: 8px; }
    .ic-sheet-id { font-size: 13px; font-weight: 700; color: var(--navy); }
    .ic-sheet-title { font-size: 12px; color: rgba(16,55,92,0.60); margin-top: 2px; text-overflow: ellipsis; white-space: nowrap; overflow: hidden; }
    .ic-sheet-meta { font-size: 11px; color: rgba(16,55,92,0.35); margin-top: 2px; }
    
    .ic-sheet-stats {
        display: flex; align-items: center; gap: 24px; flex-shrink: 0;
        margin-right: 16px;
    }
    .ic-sheet-stat { text-align: right; }
    .ic-sheet-stat-lbl { font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.40); }
    .ic-sheet-stat-val { font-size: 14px; font-weight: 700; color: var(--navy); margin-top: 2px; }
    
    /* Badges */
    .ic-badge {
        display: inline-flex; align-items: center; gap: 5px;
        padding: 3px 10px; border-radius: 20px;
        font-size: 10px; font-weight: 700;
    }
    .ic-badge__dot { width: 5px; height: 5px; border-radius: 50%; }
    .ic-badge--draft { background: rgba(16,55,92,.08); color: rgba(16,55,92,.60); }
    .ic-badge--draft .ic-badge__dot { background: rgba(16,55,92,.30); }
    .ic-badge--progress { background: rgba(255,186,8,.20); color: #c2410c; }
    .ic-badge--progress .ic-badge__dot { background: #fbbf24; }
    .ic-badge--completed { background: rgba(26,115,232,0.08); color: #1a73e8; }
    .ic-badge--completed .ic-badge__dot { background: #1a73e8; }
    .ic-badge--approved { background: #ecfdf5; color: #065f46; }
    .ic-badge--approved .ic-badge__dot { background: #10b981; }

    .ic-badge--discrepancy {
        background: #fef2f2; color: #991b1b; border: 1px solid #fee2e2;
    }
    
    .ic-btn-action {
        padding: 6px 12px; border: none; cursor: pointer;
        background: var(--navy); color: #fff;
        font-size: 12px; font-weight: 700;
        border-radius: calc(var(--radius-btn) - 4px);
        transition: opacity .12s;
        white-space: nowrap;
    }
    .ic-btn-action:hover { opacity: .88; }
    .ic-btn-action--orange { background: #d97706; }
    .ic-btn-action--blue { background: #1a73e8; }
    
    .ic-chevron {
        width: 16px; height: 16px; color: rgba(16,55,92,0.30);
        transition: transform .15s;
    }
    .ic-sheet-card.expanded .ic-chevron { transform: rotate(180deg); }

    /* Collapsible Body / Table */
    .ic-sheet-body { border-top: 1px solid var(--border); display: none; }
    .ic-sheet-card.expanded .ic-sheet-body { display: block; }
    
    .ic-table { width: 100%; border-collapse: collapse; }
    .ic-table thead tr { background: var(--alice); border-bottom: 1px solid var(--border); }
    .ic-table thead th {
        padding: 8px 16px;
        font-size: 10px; font-weight: 700; text-transform: uppercase;
        letter-spacing: .08em; color: rgba(16,55,92,0.40);
        white-space: nowrap;
    }
    .ic-table thead th.text-right { text-align: right; }
    .ic-table thead th.text-center { text-align: center; }
    .ic-table tbody tr { border-bottom: 1px solid var(--border); transition: background .12s; }
    .ic-table tbody tr.row-discrepancy { background: rgba(254,242,242,0.4); }
    .ic-table tbody tr:last-child { border-bottom: none; }
    .ic-table tbody td { padding: 10px 16px; font-size: 12px; color: var(--navy); }
    
    .ic-sku-code { font-family: monospace; font-size: 10px; color: rgba(16,55,92,0.60); display: flex; align-items: center; gap: 6px; }
    .ic-sku-name { font-weight: 600; color: var(--navy); }
    .ic-system-qty { font-weight: 700; }
    
    .ic-input-count {
        width: 80px; padding: 4px 8px; border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 4px); text-align: center;
        font-size: 12px; color: var(--navy); font-weight: 700; outline: none;
    }
    .ic-input-count:focus { border-color: var(--orange); }

    /* Deltas */
    .ic-delta-badge {
        display: inline-flex; align-items: center; gap: 4px; font-weight: 700; font-size: 12px;
    }
    .ic-delta-badge--zero { color: #059669; }
    .ic-delta-badge--plus { color: #1a73e8; }
    .ic-delta-badge--minus { color: #ef4444; }
    .ic-delta-badge svg { width: 12px; height: 12px; }

    /* Adjust status banner */
    .ic-adjusted-banner {
        display: flex; align-items: center; justify-content: space-between;
        padding: 10px 20px; background: #ecfdf5; border-top: 1px solid var(--border);
        color: #065f46; font-size: 12px;
    }

    /* ─── Modals ─── */
    .ic-overlay {
        position: fixed; inset: 0;
        background: rgba(16,55,92,0.40);
        backdrop-filter: blur(4px);
        display: flex; align-items: center; justify-content: center;
        z-index: 1000; padding: 16px;
    }
    .ic-modal {
        background: #fff; width: 100%; max-width: 580px;
        border-radius: var(--radius-card);
        box-shadow: 0 25px 50px rgba(16,55,92,.20);
        display: flex; flex-direction: column;
        max-height: 92vh; overflow: hidden;
    }
    .ic-modal-hd {
        display: flex; align-items: center; justify-content: space-between;
        padding: 18px 24px; border-bottom: 1px solid var(--border);
    }
    .ic-modal-hd h2 {
        font-size: 16px; font-weight: 800; color: var(--navy);
        text-transform: uppercase; letter-spacing: .04em; margin: 0;
    }
    .ic-modal-close {
        background: none; border: none; cursor: pointer;
        font-size: 22px; line-height: 1; color: rgba(16,55,92,0.40);
    }
    .ic-modal-close:hover { color: var(--navy); }
    
    .ic-modal-body {
        padding: 24px; overflow-y: auto; flex: 1;
        display: flex; flex-direction: column; gap: 20px;
    }
    .ic-form-section-title {
        font-size: 11px; font-weight: 700; text-transform: uppercase;
        letter-spacing: .08em; color: rgba(16,55,92,0.40);
        padding-bottom: 6px; border-bottom: 1px solid rgba(16,55,92,0.10);
        margin-bottom: 12px;
    }
    .ic-form-group { display: flex; flex-direction: column; gap: 6px; }
    .ic-form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
    .ic-form-label {
        font-size: 11px; font-weight: 600; text-transform: uppercase;
        color: rgba(16,55,92,0.60); letter-spacing: .04em;
    }
    .ic-input, .ic-select, .ic-textarea {
        padding: 8px 12px;
        border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px; color: var(--navy);
        background: var(--alice); outline: none; width: 100%;
        font-family: inherit;
    }
    .ic-input:focus, .ic-select:focus, .ic-textarea:focus { border-color: rgba(16,55,92,0.30); }
    .ic-textarea { resize: none; }
    
    /* Scope radio buttons */
    .ic-radio-group { display: flex; flex-direction: column; gap: 14px; }
    .ic-radio-item { display: flex; align-items: flex-start; gap: 10px; cursor: pointer; }
    .ic-radio-input { margin-top: 3px; accent-color: var(--orange); }
    .ic-radio-title { font-size: 13px; font-weight: 600; color: var(--navy); }
    .ic-radio-desc { font-size: 11px; color: rgba(16,55,92,0.40); margin-top: 1px; }

    .ic-modal-ft {
        display: flex; align-items: center; justify-content: flex-end;
        gap: 10px; padding: 14px 24px;
        border-top: 1px solid var(--border); background: var(--alice);
    }
    .ic-btn { padding: 8px 16px; border-radius: calc(var(--radius-btn) - 2px); font-size: 13px; font-weight: 600; cursor: pointer; border: none; transition: opacity .15s; }
    .ic-btn--cancel  { background: #fff; border: 1px solid var(--border); color: rgba(16,55,92,0.70); }
    .ic-btn--cancel:hover  { color: var(--navy); }
    .ic-btn--submit  { background: var(--orange); color: #fff; }
    .ic-btn--submit:hover  { opacity: .88; }

    .ic-empty {
        text-align: center; padding: 50px 20px;
        font-size: 13px; color: rgba(16,55,92,0.40);
        background: #fff; border: 1px solid var(--border);
        border-radius: var(--radius-card);
    }
</style>

<!-- ═══ STATS ROW ═══ -->
<div class="ic-stats-grid" id="icStatsGrid">
    <!-- Tổng phiếu -->
    <div class="ic-stat-card">
        <div class="ic-stat-icon" style="background: rgba(16,55,92,0.08);">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                 stroke="rgba(16,55,92,1)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                <line x1="16" y1="2" x2="16" y2="6"/>
                <line x1="8" y1="2" x2="8" y2="6"/>
                <line x1="3" y1="10" x2="21" y2="10"/>
            </svg>
        </div>
        <div>
            <div class="ic-stat-value" id="statTotal">0</div>
            <div class="ic-stat-label">Tổng số phiếu</div>
        </div>
    </div>
    <!-- Đang kiểm đếm -->
    <div class="ic-stat-card">
        <div class="ic-stat-icon" style="background: rgba(255,186,8,0.20);">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                 stroke="var(--orange)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/>
                <polyline points="12 6 12 12 16 14"/>
            </svg>
        </div>
        <div>
            <div class="ic-stat-value" id="statPending" style="color: var(--orange);">0</div>
            <div class="ic-stat-label">Đang kiểm đếm</div>
        </div>
    </div>
    <!-- Chờ phê duyệt -->
    <div class="ic-stat-card">
        <div class="ic-stat-icon" style="background: rgba(26,115,232,0.08);">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                 stroke="#1a73e8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                <polyline points="22 4 12 14.01 9 11.01"/>
            </svg>
        </div>
        <div>
            <div class="ic-stat-value" id="statCompleted" style="color: #1a73e8;">0</div>
            <div class="ic-stat-label">Chờ phê duyệt</div>
        </div>
    </div>
    <!-- Đã duyệt & Cân bằng -->
    <div class="ic-stat-card">
        <div class="ic-stat-icon" style="background: #ecfdf5;">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                 stroke="#059669" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="20 6 9 17 4 12"/>
            </svg>
        </div>
        <div>
            <div class="ic-stat-value" id="statApproved" style="color: #059669;">0</div>
            <div class="ic-stat-label">Đã duyệt & Cân bằng</div>
        </div>
    </div>
</div>

<!-- ═══ TOOLBAR ═══ -->
<div class="ic-toolbar">
    <div class="ic-search-wrap">
        <svg class="ic-search-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
             fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
        </svg>
        <input class="ic-search-input" type="text" id="icSearch"
               placeholder="Tìm mã phiếu hoặc tiêu đề kiểm kê..."/>
    </div>
    <button class="btn-export-report" id="btnExport">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
        </svg>
        Xuất báo cáo
    </button>
    <button class="btn-create-check" id="btnOpenCreate">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
        </svg>
        Tạo phiếu kiểm kê
    </button>
</div>

<!-- ═══ STATUS TABS ═══ -->
<div class="ic-tabs" id="icTabs">
    <button class="ic-tab active" data-tab="all">
        Tất cả <span class="ic-tab-badge" id="badge-all">0</span>
    </button>
    <button class="ic-tab" data-tab="in_progress">
        Đang kiểm đếm <span class="ic-tab-badge" id="badge-progress">0</span>
    </button>
    <button class="ic-tab" data-tab="completed">
        Chờ phê duyệt <span class="ic-tab-badge" id="badge-completed">0</span>
    </button>
    <button class="ic-tab" data-tab="approved">
        Đã duyệt & Cân bằng <span class="ic-tab-badge" id="badge-approved">0</span>
    </button>
</div>

<!-- ═══ SHEETS CONTAINER ═══ -->
<div class="ic-list-container" id="sheetsContainer">
    <!-- Rendered by JS -->
</div>

<!-- ═══ MODAL: TẠO PHIẾU KIỂM KÊ ═══ -->
<div class="ic-overlay" id="createOverlay" style="display:none;">
    <div class="ic-modal" id="createModal">
        <div class="ic-modal-hd">
            <h2>Tạo Phiếu Kiểm Kê Kho</h2>
            <button class="ic-modal-close" id="btnCloseCreate">×</button>
        </div>
        <form id="frmCreateCheck">
            <div class="ic-modal-body">
                <!-- THÔNG TIN CHUNG -->
                <div class="ic-form-group">
                    <div class="ic-form-section-title">Thông tin chung</div>
                    <div class="ic-form-group">
                        <label class="ic-form-label">Tiêu đề phiếu *</label>
                        <input class="ic-input" type="text" id="formTitle" required placeholder="VD: Kiểm kê định kỳ tháng 6/2026"/>
                    </div>
                    <div class="ic-form-row">
                        <div class="ic-form-group">
                            <label class="ic-form-label">Chi nhánh kho *</label>
                            <select class="ic-select" id="formWarehouse">
                                <option value="">— Chọn chi nhánh kho —</option>
                            </select>
                        </div>
                        <div class="ic-form-group">
                            <label class="ic-form-label">Khu vực kiểm kê (Zone) *</label>
                            <select class="ic-select" id="formZone">
                                <option value="">— Chọn khu vực (Zone) —</option>
                            </select>
                        </div>
                    </div>
                    <div class="ic-form-group">
                        <label class="ic-form-label">Người kiểm đếm *</label>
                        <select class="ic-select" id="formAssignee">
                            <option value="">— Chọn người kiểm đếm —</option>
                        </select>
                    </div>
                </div>

                <!-- PHẠM VI SẢN PHẨM KIỂM KÊ -->
                <div class="ic-form-group">
                    <div class="ic-form-section-title">Phạm vi sản phẩm kiểm kê</div>
                    <div class="ic-radio-group">
                        <!-- Option 1: All -->
                        <label class="ic-radio-item">
                            <input class="ic-radio-input" type="radio" name="scopeType" value="all" checked/>
                            <div>
                                <div class="ic-radio-title">Tất cả sản phẩm trong Khu vực</div>
                                <div class="ic-radio-desc">Hệ thống tự động chốt tồn kho của tất cả sản phẩm thuộc Zone được chỉ định.</div>
                            </div>
                        </label>

                        <!-- Option 2: Category -->
                        <div style="display:flex; flex-direction:column; gap:8px;">
                            <label class="ic-radio-item">
                                <input class="ic-radio-input" type="radio" name="scopeType" value="category"/>
                                <div>
                                    <div class="ic-radio-title">Kiểm kê theo Danh mục</div>
                                    <div class="ic-radio-desc">Chỉ kiểm kê các sản phẩm thuộc một nhóm ngành hàng cụ thể.</div>
                                </div>
                            </label>
                            <div class="pl-6" id="categorySelectWrap" style="display:none; padding-left:24px;">
                                <select class="ic-select" id="formCategory">
                                    <option value="">— Chọn danh mục sản phẩm —</option>
                                </select>
                            </div>
                        </div>

                        <!-- Option 3: SKU -->
                        <div style="display:flex; flex-direction:column; gap:8px;">
                            <label class="ic-radio-item">
                                <input class="ic-radio-input" type="radio" name="scopeType" value="sku"/>
                                <div>
                                    <div class="ic-radio-title">Kiểm kê theo SKU cụ thể</div>
                                    <div class="ic-radio-desc">Chọn mã sản phẩm SKU chính xác cần đối soát.</div>
                                </div>
                            </label>
                            <div class="pl-6" id="skuSelectWrap" style="display:none; padding-left:24px;">
                                <select class="ic-select" id="formSKU">
                                    <!-- populated by JS -->
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- GHI CHÚ -->
                <div class="ic-form-group">
                    <div class="ic-form-section-title">Ghi chú</div>
                    <textarea class="ic-textarea" id="formNote" rows="3" placeholder="Ghi chú lý do kiểm kê, yêu cầu đặc biệt..."></textarea>
                </div>
            </div>
            <div class="ic-modal-ft">
                <button type="button" class="ic-btn ic-btn--cancel" id="btnCancelCreate">HỦY</button>
                <button type="submit" class="ic-btn ic-btn--submit">TẠO PHIẾU & GIAO VIỆC</button>
            </div>
        </form>
    </div>
</div>

<!-- ═══ JAVASCRIPT ═══ -->
<script>
(function () {
    'use strict';

    // ─── Master Data ───
    var WAREHOUSES = [];
    var ZONES = [];
    var WH_STAFF_MEMBERS = [];
    var CATEGORIES = [];

    // Master Product List (Empty as requested by the user, but ready for future use)
    var PRODUCTS = [];

    // ─── State ───
    var sheets = [];
    var activeTab = 'all';
    var searchText = '';
    var expandedSheetId = null;

    // ─── DOM refs ───
    var sheetsContainer = document.getElementById('sheetsContainer');
    var icSearch        = document.getElementById('icSearch');
    var icTabs          = document.getElementById('icTabs');
    var createOverlay   = document.getElementById('createOverlay');
    var frmCreateCheck  = document.getElementById('frmCreateCheck');
    var formTitle       = document.getElementById('formTitle');
    var formWarehouse   = document.getElementById('formWarehouse');
    var formZone        = document.getElementById('formZone');
    var formAssignee    = document.getElementById('formAssignee');
    var formCategory    = document.getElementById('formCategory');
    var formSKU         = document.getElementById('formSKU');
    var formNote        = document.getElementById('formNote');
    var categorySelectWrap = document.getElementById('categorySelectWrap');
    var skuSelectWrap   = document.getElementById('skuSelectWrap');

    var statTotal       = document.getElementById('statTotal');
    var statPending     = document.getElementById('statPending');
    var statCompleted   = document.getElementById('statCompleted');
    var statApproved    = document.getElementById('statApproved');

    // ─── Initialize master selects ───
    function populateWarehouseSelect() {
        formWarehouse.innerHTML = '<option value="">— Chọn chi nhánh kho —</option>';
        WAREHOUSES.forEach(function (w) {
            var opt = document.createElement('option');
            opt.value = w; opt.textContent = w;
            formWarehouse.appendChild(opt);
        });
    }
    populateWarehouseSelect();

    function populateZoneSelect() {
        formZone.innerHTML = '<option value="">— Chọn khu vực (Zone) —</option>';
        ZONES.forEach(function (z) {
            var opt = document.createElement('option');
            opt.value = z; opt.textContent = z;
            formZone.appendChild(opt);
        });
    }
    populateZoneSelect();

    function populateAssigneeSelect() {
        formAssignee.innerHTML = '<option value="">— Chọn người kiểm đếm —</option>';
        WH_STAFF_MEMBERS.forEach(function (s) {
            var opt = document.createElement('option');
            opt.value = s; opt.textContent = s;
            formAssignee.appendChild(opt);
        });
    }
    populateAssigneeSelect();

    function populateCategorySelect() {
        formCategory.innerHTML = '<option value="">— Chọn danh mục sản phẩm —</option>';
        CATEGORIES.forEach(function (c) {
            var opt = document.createElement('option');
            opt.value = c; opt.textContent = c;
            formCategory.appendChild(opt);
        });
    }
    populateCategorySelect();

    function populateSkuDropdown() {
        formSKU.innerHTML = '<option value="">— Chọn sản phẩm (SKU) —</option>';
        PRODUCTS.forEach(function (p) {
            var opt = document.createElement('option');
            opt.value = p.sku;
            opt.textContent = p.sku + ' - ' + p.name;
            formSKU.appendChild(opt);
        });
    }
    populateSkuDropdown();

    // ─── Listeners for radio scopes ───
    document.querySelectorAll('input[name="scopeType"]').forEach(function (radio) {
        radio.addEventListener('change', function () {
            var val = this.value;
            categorySelectWrap.style.display = val === 'category' ? 'block' : 'none';
            skuSelectWrap.style.display      = val === 'sku'      ? 'block' : 'none';
        });
    });

    // ─── Open / Close Modal ───
    document.getElementById('btnOpenCreate').addEventListener('click', function () {
        formTitle.value = '';
        formNote.value = '';
        document.querySelector('input[name="scopeType"][value="all"]').click();
        createOverlay.style.display = 'flex';
    });
    document.getElementById('btnCloseCreate').addEventListener('click', function () { createOverlay.style.display = 'none'; });
    document.getElementById('btnCancelCreate').addEventListener('click', function () { createOverlay.style.display = 'none'; });
    createOverlay.addEventListener('click', function (e) { if (e.target === createOverlay) createOverlay.style.display = 'none'; });

    // ─── Form submit (Tạo phiếu) ───
    frmCreateCheck.addEventListener('submit', function (e) {
        e.preventDefault();
        var title = formTitle.value.trim();
        if (!title) { alert('Vui lòng nhập Tiêu đề phiếu'); return; }

        var scopeType = document.querySelector('input[name="scopeType"]:checked').value;
        var selectedItems = [];

        if (scopeType === 'all') {
            selectedItems = PRODUCTS.map(function (p) {
                return { skuCode: p.sku, skuName: p.name, systemQty: p.systemQty, countedQty: null };
            });
        } else if (scopeType === 'category') {
            var cat = formCategory.value;
            var filtered = PRODUCTS.filter(function (p) { return p.category === cat; });
            selectedItems = filtered.map(function (p) {
                return { skuCode: p.sku, skuName: p.name, systemQty: p.systemQty, countedQty: null };
            });
        } else if (scopeType === 'sku') {
            var sku = formSKU.value;
            if (!sku) { alert('Vui lòng chọn sản phẩm (SKU) cần kiểm kê'); return; }
            var prod = PRODUCTS.find(function (p) { return p.sku === sku; });
            selectedItems = [{
                skuCode: prod.sku,
                skuName: prod.name,
                systemQty: prod.systemQty,
                countedQty: null
            }];
        }

        var nextNum = String(sheets.length + 1).padStart(3, '0');
        var now = new Date();
        var nowStr = now.getFullYear() + '-' +
                      String(now.getMonth() + 1).padStart(2, '0') + '-' +
                      String(now.getDate()).padStart(2, '0') + ' ' +
                      String(now.getHours()).padStart(2, '0') + ':' +
                      String(now.getMinutes()).padStart(2, '0');

        var newSheet = {
            id: 'IC-2026-' + nextNum,
            title: title + ' [' + formWarehouse.value + ' — ' + formZone.value + ']',
            createdAt: nowStr,
            status: 'in_progress',
            createdBy: 'Nhân viên kiểm đếm: ' + formAssignee.value,
            items: selectedItems,
            note: formNote.value.trim() || null
        };

        sheets.unshift(newSheet);
        expandedSheetId = newSheet.id; // Auto expand new sheet
        createOverlay.style.display = 'none';
        render();
    });

    // ─── Tab switching ───
    icTabs.addEventListener('click', function (e) {
        var btn = e.target.closest('.ic-tab');
        if (!btn) return;
        activeTab = btn.dataset.tab;
        icTabs.querySelectorAll('.ic-tab').forEach(function (t) { t.classList.remove('active'); });
        btn.classList.add('active');
        render();
    });

    // ─── Search ───
    icSearch.addEventListener('input', function () { searchText = this.value; render(); });

    // ─── Inline edit quantity ───
    window.handleUpdateCountedQty = function (sheetId, skuCode, value) {
        var sheet = sheets.find(function (s) { return s.id === sheetId; });
        if (!sheet) return;
        var item = sheet.items.find(function (i) { return i.skuCode === skuCode; });
        if (!item) return;

        item.countedQty = value === '' ? null : parseInt(value, 10);
        
        // Re-render only statistical/state values or full table seamlessly
        updateCountsAndDeltas(sheet);
    };

    function updateCountsAndDeltas(sheet) {
        var countedItems = sheet.items.filter(function (i) { return i.countedQty !== null; }).length;
        var totalDelta = sheet.items.reduce(function (sum, i) {
            var d = i.countedQty !== null ? (i.countedQty - i.systemQty) : 0;
            return sum + d;
        }, 0);

        var badgeCounted = document.getElementById('counted-' + sheet.id);
        if (badgeCounted) {
            badgeCounted.textContent = countedItems;
            if (countedItems === sheet.items.length) {
                badgeCounted.className = 'text-emerald-600';
            } else {
                badgeCounted.className = 'text-navy';
            }
        }

        var badgeDelta = document.getElementById('delta-' + sheet.id);
        if (badgeDelta) {
            badgeDelta.textContent = totalDelta > 0 ? ('+' + totalDelta) : totalDelta;
            if (totalDelta < 0) {
                badgeDelta.className = 'ic-sheet-stat-val text-red-600';
            } else if (totalDelta > 0) {
                badgeDelta.className = 'ic-sheet-stat-val text-blue-600';
            } else {
                badgeDelta.className = 'ic-sheet-stat-val text-emerald-600';
            }
        }

        // Check if discrepancy exists
        var hasDiscrepancy = sheet.items.some(function (i) {
            return i.countedQty !== null && (i.countedQty - i.systemQty) !== 0;
        });
        var alertBadge = document.getElementById('alert-' + sheet.id);
        if (alertBadge) {
            alertBadge.style.display = hasDiscrepancy ? 'inline-flex' : 'none';
        }

        // Update single row badge & input delta
        sheet.items.forEach(function (item) {
            var row = document.getElementById('row-' + sheet.id + '-' + item.skuCode);
            var deltaCell = document.getElementById('dtcell-' + sheet.id + '-' + item.skuCode);
            var iconCell = document.getElementById('iconcell-' + sheet.id + '-' + item.skuCode);
            
            if (row && deltaCell && iconCell) {
                var d = item.countedQty !== null ? (item.countedQty - item.systemQty) : null;
                if (d !== null && d !== 0) {
                    row.classList.add('row-discrepancy');
                } else {
                    row.classList.remove('row-discrepancy');
                }

                // Render delta badge
                deltaCell.innerHTML = renderDeltaBadge(d);

                // Render icon
                if (item.countedQty !== null) {
                    if (d === 0) {
                        iconCell.innerHTML = '<svg class="text-emerald-500 mx-auto" style="width:16px;height:16px;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';
                    } else {
                        iconCell.innerHTML = '<svg class="text-orange mx-auto" style="width:16px;height:16px;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
                    }
                } else {
                    iconCell.innerHTML = '<div class="w-4 h-4 border-2 border-navy/20 rounded mx-auto"></div>';
                }
            }
        });
    }

    function renderDeltaBadge(d) {
        if (d === null) return '<span style="color:rgba(16,55,92,0.30);">—</span>';
        if (d === 0) return '<span class="ic-delta-badge ic-delta-badge--zero"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/></svg>0</span>';
        if (d > 0) return '<span class="ic-delta-badge ic-delta-badge--plus"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>+' + d + '</span>';
        return '<span class="ic-delta-badge ic-delta-badge--minus"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 18 13.5 8.5 8.5 13.5 1 6"/><polyline points="17 18 23 18 23 12"/></svg>' + d + '</span>';
    }

    // ─── Status badge helper ───
    function getStatusConfig(status) {
        var cfg = {
            in_progress: { label: "Đang kiểm đếm", cls: "ic-badge--progress", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>' },
            completed:   { label: "Chờ phê duyệt", cls: "ic-badge--completed", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>' },
            approved:    { label: "Đã duyệt", cls: "ic-badge--approved", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>' },
            adjusted:    { label: "Đã điều chỉnh", cls: "ic-badge--approved", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>' }
        };
        return cfg[status] || cfg.in_progress;
    }

    // ─── Action triggers ───
    window.toggleExpand = function (id) {
        expandedSheetId = expandedSheetId === id ? null : id;
        render();
    };

    window.triggerComplete = function (e, id) {
        e.stopPropagation();
        var sheet = sheets.find(function (s) { return s.id === id; });
        if (sheet) {
            sheet.status = 'completed';
            render();
        }
    };

    window.triggerAdjust = function (e, id) {
        e.stopPropagation();
        var sheet = sheets.find(function (s) { return s.id === id; });
        if (sheet) {
            sheet.status = 'adjusted';
            render();
        }
    };

    // ─── Render ───
    function render() {
        // Stats
        var counts = {
            all:        sheets.length,
            progress:   sheets.filter(function (s) { return s.status === 'in_progress'; }).length,
            completed:  sheets.filter(function (s) { return s.status === 'completed'; }).length,
            approved:   sheets.filter(function (s) { return s.status === 'approved' || s.status === 'adjusted'; }).length
        };

        statTotal.textContent     = counts.all;
        statPending.textContent   = counts.progress;
        statCompleted.textContent = counts.completed;
        statApproved.textContent  = counts.approved;

        document.getElementById('badge-all').textContent      = counts.all;
        document.getElementById('badge-progress').textContent = counts.progress;
        document.getElementById('badge-completed').textContent= counts.completed;
        document.getElementById('badge-approved').textContent = counts.approved;

        // Filter
        var q = searchText.toLowerCase();
        var filtered = sheets.filter(function (s) {
            var matchTab = activeTab === 'all' ||
                (activeTab === 'in_progress' && s.status === 'in_progress') ||
                (activeTab === 'completed' && s.status === 'completed') ||
                (activeTab === 'approved' && (s.status === 'approved' || s.status === 'adjusted'));
            
            var matchSearch = !q || s.id.toLowerCase().includes(q) || s.title.toLowerCase().includes(q);
            return matchTab && matchSearch;
        });

        if (filtered.length === 0) {
            sheetsContainer.innerHTML = '<div class="ic-empty">Không tìm thấy phiếu kiểm kê nào phù hợp.</div>';
            return;
        }

        sheetsContainer.innerHTML = filtered.map(function (sheet) {
            var sc = getStatusConfig(sheet.status);
            var isExpanded = expandedSheetId === sheet.id;
            var countedItems = sheet.items.filter(function (i) { return i.countedQty !== null; }).length;
            var totalDelta = sheet.items.reduce(function (sum, i) {
                var d = i.countedQty !== null ? (i.countedQty - i.systemQty) : 0;
                return sum + d;
            }, 0);
            var hasDiscrepancy = sheet.items.some(function (i) {
                return i.countedQty !== null && (i.countedQty - i.systemQty) !== 0;
            });

            // Action button
            var actionBtn = '';
            if (sheet.status === 'in_progress') {
                actionBtn = '<button class="ic-btn-action ic-btn-action--orange" onclick="triggerComplete(event, \'' + sheet.id + '\')">' +
                            'Hoàn tất & Trình duyệt</button>';
            } else if (sheet.status === 'completed') {
                actionBtn = '<span class="ic-badge ic-badge--completed"><span class="ic-badge__dot"></span>Chờ duyệt</span>';
            } else if (sheet.status === 'approved') {
                actionBtn = '<button class="ic-btn-action ic-btn-action--blue" onclick="triggerAdjust(event, \'' + sheet.id + '\')">' +
                            'Điều chỉnh</button>';
            }

            // Delta text styling
            var deltaClass = 'ic-sheet-stat-val text-emerald-600';
            if (totalDelta < 0) deltaClass = 'ic-sheet-stat-val text-red-600';
            else if (totalDelta > 0) deltaClass = 'ic-sheet-stat-val text-blue-600';

            // Items table rows
            var tableRows = sheet.items.map(function (item) {
                var d = item.countedQty !== null ? (item.countedQty - item.systemQty) : null;
                var rowClass = (d !== null && d !== 0) ? 'row-discrepancy' : '';
                
                var countField = '';
                if (item.countedQty !== null) {
                    countField = '<span style="font-size:13px; font-weight:700;">' + item.countedQty.toLocaleString() + '</span>';
                } else if (sheet.status === 'in_progress') {
                    countField = '<input class="ic-input-count" type="number" placeholder="Nhập..." ' +
                                 'oninput="handleUpdateCountedQty(\'' + sheet.id + '\', \'' + item.skuCode + '\', this.value)"/>';
                } else {
                    countField = '<span style="color:rgba(16,55,92,0.30);">—</span>';
                }

                var statusIcon = '';
                if (item.countedQty !== null) {
                    if (d === 0) {
                        statusIcon = '<svg class="text-emerald-500 mx-auto" style="width:16px;height:16px;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';
                    } else {
                        statusIcon = '<svg class="text-orange mx-auto" style="width:16px;height:16px;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
                    }
                } else {
                    statusIcon = '<div class="w-4 h-4 border-2 border-navy/20 rounded mx-auto"></div>';
                }

                return '<tr id="row-' + sheet.id + '-' + item.skuCode + '" class="' + rowClass + '">' +
                       '<td><div class="ic-sku-code"><svg style="width:14px;height:14px;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>' + esc(item.skuCode) + '</div></td>' +
                       '<td><div class="ic-sku-name">' + esc(item.skuName) + '</div></td>' +
                       '<td class="text-right ic-system-qty">' + item.systemQty.toLocaleString() + '</td>' +
                       '<td class="text-right">' + countField + '</td>' +
                       '<td class="text-right" id="dtcell-' + sheet.id + '-' + item.skuCode + '">' + renderDeltaBadge(d) + '</td>' +
                       '<td class="text-center" id="iconcell-' + sheet.id + '-' + item.skuCode + '">' + statusIcon + '</td>' +
                       '</tr>';
            }).join('');

            var expandedClass = isExpanded ? 'expanded' : '';
            var expandSection = '';
            if (isExpanded) {
                var adjustedBanner = '';
                if (sheet.status === 'adjusted') {
                    adjustedBanner = '<div class="ic-adjusted-banner">' +
                                     '<span><svg style="width:12px;height:12px;margin-right:6px;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.5 2v6h-6M21.34 15.57a10 10 0 1 1-.57-8.38l5.67-5.67"/></svg>Phiếu đã được điều chỉnh và áp dụng vào hệ thống</span>' +
                                     '<span style="font-weight:700;"><svg style="width:12px;height:12px;margin-right:6px;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>Đã cân bằng tồn kho</span>' +
                                     '</div>';
                }

                expandSection = '<div class="ic-sheet-body">' +
                                '<table class="ic-table">' +
                                '<thead>' +
                                '<tr>' +
                                '<th class="text-left">SKU</th>' +
                                '<th class="text-left">Tên sản phẩm</th>' +
                                '<th class="text-right">Hệ thống</th>' +
                                '<th class="text-right">Đếm thực tế</th>' +
                                '<th class="text-right">Delta (Δ)</th>' +
                                '<th class="text-center">Trạng thái</th>' +
                                '</tr>' +
                                '</thead>' +
                                '<tbody>' + tableRows + '</tbody>' +
                                '</table>' +
                                adjustedBanner +
                                '</div>';
            }

            return '<div class="ic-sheet-card ' + expandedClass + '">' +
                   '  <div class="ic-sheet-hd" onclick="toggleExpand(\'' + sheet.id + '\')">' +
                   '    <div class="ic-sheet-icon" style="background: rgba(16,55,92,0.05);">' +
                   '      <svg class="text-navy" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>' +
                   '    </div>' +
                   '    <div class="ic-sheet-info">' +
                   '      <div class="ic-sheet-info-row">' +
                   '        <span class="ic-sheet-id">' + esc(sheet.id) + '</span>' +
                   '        <span class="ic-badge ' + sc.cls + '"><span class="ic-badge__dot"></span>' + esc(sc.label) + '</span>' +
                   '        <span class="ic-badge ic-badge--discrepancy" id="alert-' + sheet.id + '" style="display:' + (hasDiscrepancy ? 'inline-flex' : 'none') + ';"><svg style="width:10px;height:10px;margin-right:4px;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>Có lệch</span>' +
                   '      </div>' +
                   '      <div class="ic-sheet-title">' + esc(sheet.title) + '</div>' +
                   '      <div class="ic-sheet-meta">' + esc(sheet.createdBy) + ' · ' + esc(sheet.createdAt) + '</div>' +
                   '    </div>' +
                   '    <div class="ic-sheet-stats">' +
                   '      <div class="ic-sheet-stat">' +
                   '        <div class="ic-sheet-stat-lbl">Đã đếm</div>' +
                   '        <div class="ic-sheet-stat-val">' +
                   '          <span id="counted-' + sheet.id + '" class="' + (countedItems === sheet.items.length ? 'text-emerald-600' : 'text-navy') + '">' + countedItems + '</span>' +
                   '          <span style="color:rgba(16,55,92,0.30); font-size:12px;">/' + sheet.items.length + '</span>' +
                   '        </div>' +
                   '      </div>' +
                   '      <div class="ic-sheet-stat">' +
                   '        <div class="ic-sheet-stat-lbl">Tổng lệch</div>' +
                   '        <div id="delta-' + sheet.id + '" class="' + deltaClass + '">' + (totalDelta > 0 ? ('+' + totalDelta) : totalDelta) + '</div>' +
                   '      </div>' +
                   '    </div>' +
                   '    <div style="margin-right:16px; flex-shrink:0;">' + actionBtn + '</div>' +
                   '    <svg class="ic-chevron" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg>' +
                   '  </div>' +
                      expandSection +
                   '</div>';
        }).join('');
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
})();
</script>
