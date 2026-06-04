<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- ══════════════════════════════════════════════════════════════════
     Sales Staff — Xử Lý Đơn Hàng (Order Processing)
     JSP port of React: OrderProcessing.tsx
     All logic is pure vanilla JS — no hardcoded data, no seed data.
     ══════════════════════════════════════════════════════════════════ --%>

<style>
/* ── Page-scoped styles mirroring React OrderProcessing ─────────── */

/* Tabs switcher */
.op-tab-bar {
    display: flex;
    border-bottom: 1px solid #E5EAF3;
    margin-bottom: 1.25rem;
    overflow-x: auto;
    white-space: nowrap;
}
.op-tab-bar::-webkit-scrollbar { height: 0; }

.op-tab {
    display: inline-flex;
    align-items: center;
    gap: 0.625rem;
    padding: 0.75rem 1.5rem;
    font-size: 14px;
    font-weight: 700;
    border-bottom: 2px solid transparent;
    background: none;
    border-top: none;
    border-left: none;
    border-right: none;
    cursor: pointer;
    transition: all .15s;
    color: rgba(16,55,92,.4);
    text-decoration: none;
}
.op-tab:hover { color: var(--navy); }
.op-tab.active { font-weight: 800; }
.op-tab.active.tab-review { color: #dc2626; border-bottom-color: #ef4444; }
.op-tab.active.tab-waybill { color: #059669; border-bottom-color: #10b981; }
.op-tab.active.tab-rts { color: #0d9488; border-bottom-color: #0f766e; }
.op-tab.active.tab-rma { color: #d97706; border-bottom-color: #f59e0b; }

.op-tab-badge {
    display: inline-block;
    padding: 0.125rem 0.5rem;
    font-size: 11px;
    font-weight: 700;
    border-radius: 9999px;
    background: var(--alice);
    color: rgba(16,55,92,.5);
}
.op-tab.active .op-tab-badge { color: #fff; }
.op-tab.active.tab-review .op-tab-badge { background: #fee2e2; color: #dc2626; animation: pulse 2s infinite; }
.op-tab.active.tab-waybill .op-tab-badge { background: #d1fae5; color: #059669; }
.op-tab.active.tab-rts .op-tab-badge { background: #ccfbf1; color: #0f766e; }
.op-tab.active.tab-rma .op-tab-badge { background: #fef3c7; color: #d97706; }

@keyframes pulse {
    0%, 100% { opacity: 1; transform: scale(1); }
    50% { opacity: .7; transform: scale(1.05); }
}

/* Filter bar */
.op-filter-bar {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 0.75rem;
    background: #fff;
    border: 1px solid #E5EAF3;
    padding: 1rem;
    margin-bottom: 1rem;
    border-radius: var(--radius-card);
}
.op-search {
    position: relative;
    flex: 1;
    min-width: 280px;
}
.op-search-icon {
    position: absolute;
    left: 0.75rem;
    top: 50%;
    transform: translateY(-50%);
    width: 16px;
    height: 16px;
    color: rgba(16,55,92,.3);
    pointer-events: none;
}
.op-search input {
    width: 100%;
    padding: 0.5rem 1rem 0.5rem 2.25rem;
    background: var(--alice);
    border: 1px solid #E5EAF3;
    font-size: 13px;
    color: var(--navy);
    border-radius: calc(var(--radius-btn) - 2px);
    outline: none;
    transition: border-color .15s;
}
.op-search input:focus { border-color: rgba(16,55,92,.4); }
.op-search input::placeholder { color: rgba(16,55,92,.3); }

/* Filter dropdown button */
.op-filter-btn {
    display: inline-flex;
    align-items: center;
    justify-content: space-between;
    gap: 0.5rem;
    padding: 0.5rem 0.875rem;
    background: #fff;
    border: 1px solid #E5EAF3;
    color: rgba(16,55,92,.7);
    font-size: 13px;
    font-weight: 600;
    border-radius: calc(var(--radius-btn) - 2px);
    cursor: pointer;
    transition: all .15s;
    white-space: nowrap;
}
.op-filter-btn:hover { color: var(--navy); border-color: rgba(16,55,92,.2); }
.op-filter-btn svg.f-icon { width: 14px; height: 14px; color: rgba(16,55,92,.4); }
.op-filter-btn svg.clear-x { width: 12px; height: 12px; cursor: pointer; color: rgba(16,55,92,.3); }
.op-filter-btn svg.clear-x:hover { color: #ef4444; }

.op-dropdown {
    position: absolute;
    top: calc(100% + 6px);
    left: 0;
    min-width: 192px;
    background: #fff;
    border: 1px solid #E5EAF3;
    box-shadow: 0 10px 30px rgba(16,55,92,.1);
    border-radius: var(--radius-btn);
    z-index: 50;
    padding: 4px;
    display: none;
    max-height: 250px;
    overflow-y: auto;
}
.op-dropdown.right { left: auto; right: 0; }
.op-dropdown.open { display: block; }
.op-dropdown button {
    display: block;
    width: 100%;
    text-align: left;
    padding: 0.5rem 0.75rem;
    background: none;
    border: none;
    font-size: 12px;
    color: rgba(16,55,92,.8);
    cursor: pointer;
    border-radius: 4px;
    transition: all .15s;
    white-space: nowrap;
    text-overflow: ellipsis;
    overflow: hidden;
}
.op-dropdown button:hover { background: var(--alice); color: var(--navy); }
.op-dropdown button.selected { background: var(--alice); color: var(--navy); font-weight: 700; }

/* Data card / Table */
.op-table-card {
    background: #fff;
    border: 1px solid #E5EAF3;
    border-radius: var(--radius-card);
    overflow: hidden;
    margin-bottom: 2rem;
}
.op-table-scroll { overflow-x: auto; }
.op-table { width: 100%; border-collapse: collapse; text-align: left; }
.op-table th {
    background: var(--alice);
    color: rgba(16,55,92,.5);
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .05em;
    padding: 0.75rem 1.25rem;
    border-bottom: 1px solid #E5EAF3;
    white-space: nowrap;
}
.op-table td {
    padding: 0.875rem 1.25rem;
    border-bottom: 1px solid #F0F3FA;
    font-size: 13px;
    color: var(--navy);
    vertical-align: middle;
}
.op-table tr:hover { background: rgba(240,245,255,.3); }
.op-table tr.pending-row { background: rgba(239,68,68,.02); }

.op-empty {
    text-align: center !important;
    padding: 4rem 2rem !important;
    color: rgba(16,55,92,.4);
    font-size: 14px;
}
.op-empty svg { width: 36px; height: 36px; margin: 0 auto 0.75rem; color: rgba(16,55,92,.2); display: block; }

/* Custom badges */
.op-badge {
    display: inline-flex;
    align-items: center;
    gap: 0.35rem;
    padding: 0.25rem 0.625rem;
    font-size: 11px;
    font-weight: 700;
    border-radius: 9999px;
    border: 1px solid transparent;
}
.op-badge-dot { width: 6px; height: 6px; border-radius: 50%; }

.badge-channel {
    color: #fff;
    border-radius: 4px;
    font-weight: 700;
    font-size: 11px;
    padding: 0.25rem 0.5rem;
    display: inline-flex;
    align-items: center;
    gap: 4px;
}

.op-btn-detail {
    width: 32px; height: 32px;
    border-radius: calc(var(--radius-btn) - 4px);
    background: var(--alice);
    color: var(--navy);
    border: none;
    cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    transition: all .15s;
    margin: 0 auto;
}
.op-btn-detail:hover { background: var(--navy); color: #fff; }
.op-btn-detail svg { width: 14px; height: 14px; }

/* Table pagination footer */
.op-table-footer {
    padding: 1rem 1.5rem;
    background: var(--alice);
    color: rgba(16,55,92,.5);
    font-size: 12px;
    border-top: 1px solid #F0F3FA;
    font-weight: 600;
}

/* Modal overlays */
.op-modal-overlay {
    position: fixed;
    inset: 0;
    background: rgba(16,55,92,.6);
    backdrop-filter: blur(4px);
    z-index: 100;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 1.5rem;
    opacity: 0;
    pointer-events: none;
    transition: opacity .2s ease-out;
}
.op-modal-overlay.open { opacity: 1; pointer-events: auto; }

.op-modal {
    width: 100%;
    max-width: 900px;
    background: #fff;
    max-height: 90vh;
    display: flex;
    flex-direction: column;
    box-shadow: 0 25px 50px -12px rgba(16,55,92,.25);
    border-radius: var(--radius-card);
    transform: translateY(20px);
    transition: transform .2s ease-out;
    overflow: hidden;
}
.op-modal-overlay.open .op-modal { transform: translateY(0); }

.op-modal-header {
    background: #fff;
    border-bottom: 1px solid #E5EAF3;
    padding: 1.25rem 1.5rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-shrink: 0;
}
.op-modal-title { font-size: 18px; font-weight: 900; color: var(--navy); letter-spacing: -.02em; }
.op-modal-close {
    width: 32px; height: 32px;
    border-radius: 50%;
    border: none;
    background: none;
    color: rgba(16,55,92,.4);
    cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    transition: all .15s;
    font-size: 24px;
    line-height: 1;
}
.op-modal-close:hover { background: var(--alice); color: var(--navy); }

.op-modal-body {
    flex: 1;
    overflow-y: auto;
    padding: 1.5rem;
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
}
.op-modal-footer {
    padding: 1rem 1.5rem;
    background: var(--alice);
    border-top: 1px solid #E5EAF3;
    display: flex;
    justify-content: flex-end;
    gap: 0.5rem;
    flex-shrink: 0;
}

/* Info cards section */
.op-section-box {
    background: rgba(240,245,255,.4);
    border: 1px solid #E5EAF3;
    border-radius: var(--radius-card);
    padding: 1rem;
}
.op-section-title {
    font-size: 13px;
    font-weight: 900;
    text-transform: uppercase;
    letter-spacing: .05em;
    color: var(--navy);
    display: flex;
    align-items: center;
    gap: 0.5rem;
    border-bottom: 1px solid #E5EAF3;
    padding-bottom: 6px;
    margin-bottom: 0.75rem;
}
.op-section-title svg { width: 16px; height: 16px; color: rgba(16,55,92,.4); }

.op-info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; }
@media (max-width: 600px) { .op-info-grid { grid-template-columns: 1fr; } }
.op-info-row { display: flex; font-size: 13px; margin-bottom: 6px; }
.op-info-label { color: rgba(16,55,92,.5); font-weight: 500; width: 150px; flex-shrink: 0; }
.op-info-val { font-weight: 700; color: var(--navy); }

/* Product listing table inside details */
.op-detail-item {
    border: 1px solid #E5EAF3;
    border-radius: var(--radius-card);
    background: #fff;
    padding: 1rem;
    margin-bottom: 0.75rem;
}
.op-detail-item:last-child { margin-bottom: 0; }
.op-detail-item-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid #F0F3FA;
    padding-bottom: 0.5rem;
    margin-bottom: 0.75rem;
}
.op-detail-item-name { font-size: 13.5px; font-weight: 700; color: var(--navy); display: flex; align-items: center; gap: 6px; }
.op-detail-item-name svg { width: 16px; height: 16px; color: rgba(16,55,92,.3); }

/* Stock split matrix */
.op-stock-matrix {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 0.75rem;
    margin-top: 0.5rem;
}
@media (max-width: 600px) { .op-stock-matrix { grid-template-columns: 1fr; } }
.op-stock-box {
    padding: 0.5rem 0.75rem;
    border-radius: 4px;
    border: 1px solid #E5EAF3;
    display: flex;
    flex-direction: column;
    justify-content: center;
}
.op-stock-box-label { font-size: 9px; text-transform: uppercase; font-weight: 700; color: rgba(16,55,92,.4); margin-bottom: 2px; }
.op-stock-box-value { font-size: 12.5px; font-weight: 700; display: flex; align-items: center; gap: 4px; }
.op-stock-box.enough { background: rgba(16,185,129,.05); border-color: rgba(16,185,129,.2); color: #047857; }
.op-stock-box.warning { background: rgba(245,158,11,.05); border-color: rgba(245,158,11,.2); color: #b45309; }
.op-stock-box.empty { background: rgba(239,68,68,.05); border-color: rgba(239,68,68,.2); color: #b91c1c; }

/* Timeline vertical line */
.op-timeline {
    padding-left: 32px;
    margin-left: 16px;
    border-left: 1px solid #E5EAF3;
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
    position: relative;
}
.op-timeline-step { position: relative; }
.op-timeline-step-dot {
    position: absolute;
    left: -41px;
    top: 0px;
    width: 18px;
    height: 18px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    border: 4px solid #fff;
    box-shadow: 0 0 0 1px #E5EAF3;
}
.op-timeline-step-dot.active-ok { background: #10b981; box-shadow: 0 0 0 1px #10b981; }
.op-timeline-step-dot.active-warn { background: #f59e0b; box-shadow: 0 0 0 1px #f59e0b; }
.op-timeline-step-dot.active-err { background: #ef4444; box-shadow: 0 0 0 1px #ef4444; }
.op-timeline-step-dot.inactive { background: #e5eaf3; box-shadow: 0 0 0 1px #e5eaf3; color: rgba(16,55,92,.3); }
.op-timeline-step-dot svg { width: 9px; height: 9px; }

.op-timeline-title { font-size: 13px; font-weight: 700; color: var(--navy); }
.op-timeline-title.warning { color: #b45309; }
.op-timeline-title.error { color: #b91c1c; }
.op-timeline-desc { font-size: 11px; color: rgba(16,55,92,.4); margin-top: 2px; }

/* Active action box inside details modal */
.op-action-box {
    border: 2px solid #ef4444;
    background: rgba(239,68,68,.02);
    border-radius: var(--radius-card);
    padding: 1.25rem;
    margin-top: 1rem;
}
.op-action-box.rma { border-color: #f59e0b; background: rgba(245,158,11,.02); }
.op-action-title { font-size: 13.5px; font-weight: 800; text-transform: uppercase; margin-bottom: 1rem; display: flex; align-items: center; gap: 8px; }

.op-action-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem; }
@media (max-width: 600px) { .op-action-grid { grid-template-columns: 1fr; } }
.op-field-label { display: block; font-size: 11.5px; font-weight: 700; color: rgba(16,55,92,.7); margin-bottom: 4px; }
.op-select {
    width: 100%;
    padding: 0.5rem 0.75rem;
    border: 1px solid #E5EAF3;
    font-size: 13px;
    background: #fff;
    color: var(--navy);
    border-radius: calc(var(--radius-btn) - 4px);
    outline: none;
}
.op-select:focus { border-color: rgba(16,55,92,.4); }

.op-input {
    width: 100%;
    padding: 0.5rem 0.75rem;
    border: 1px solid #E5EAF3;
    font-size: 13px;
    background: #fff;
    color: var(--navy);
    border-radius: calc(var(--radius-btn) - 4px);
    outline: none;
}
.op-input:focus { border-color: rgba(16,55,92,.4); }

.op-btn {
    padding: 0.5rem 1.25rem;
    font-size: 13px;
    font-weight: 700;
    border-radius: calc(var(--radius-btn) - 2px);
    cursor: pointer;
    border: 1px solid transparent;
    transition: all .15s;
}
.op-btn.primary { background: var(--navy); color: #fff; }
.op-btn.primary:hover { background: rgba(16,55,92,.9); }
.op-btn.success { background: #059669; color: #fff; }
.op-btn.success:hover { background: #047857; }
.op-btn.danger { background: none; border-color: #f87171; color: #dc2626; }
.op-btn.danger:hover { background: #dc2626; color: #fff; }
.op-btn.warning { background: #d97706; color: #fff; }
.op-btn.warning:hover { background: #b45309; }

.op-btn:disabled { background: #e5eaf3; border-color: transparent; color: rgba(16,55,92,.3); cursor: not-allowed; }

/* Sticky batch bar */
.op-sticky-bar {
    position: fixed;
    bottom: 1.5rem;
    left: 50%;
    transform: translateX(-50%);
    background: var(--navy);
    color: #fff;
    padding: 1rem 1.5rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1.5rem;
    box-shadow: 0 20px 40px rgba(16,55,92,.3);
    border-radius: var(--radius-card);
    z-index: 80;
    width: calc(100% - 3rem);
    max-width: 800px;
    border: 1px solid rgba(255,255,255,.1);
    opacity: 0;
    pointer-events: none;
    transition: all .2s ease-out;
}
.op-sticky-bar.open { opacity: 1; pointer-events: auto; }

.op-sticky-bar-btn {
    padding: 0.5rem 1rem;
    font-size: 12px;
    font-weight: 700;
    border-radius: calc(var(--radius-btn) - 2px);
    border: none;
    cursor: pointer;
    transition: all .15s;
    white-space: nowrap;
}
.op-sticky-bar-btn.amber { background: #f59e0b; color: var(--navy); }
.op-sticky-bar-btn.amber:hover { background: #d97706; }
.op-sticky-bar-btn.emerald { background: #10b981; color: #fff; }
.op-sticky-bar-btn.emerald:hover { background: #059669; }
.op-sticky-bar-btn.teal { background: #0d9488; color: #fff; }
.op-sticky-bar-btn.teal:hover { background: #0f766e; }

/* Shipping Labels preview */
.op-labels-grid {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 1.5rem;
    width: 100%;
}
.op-label-a6 {
    background: #fff;
    width: 100%;
    max-width: 420px;
    min-height: 560px;
    border: 2px dashed rgba(16,55,92,.3);
    padding: 1.25rem;
    box-shadow: 0 4px 15px rgba(0,0,0,.05);
    color: var(--navy);
    font-family: sans-serif;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
}
.op-label-top { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid var(--navy); padding-bottom: 0.5rem; }
.op-label-carrier { font-size: 16px; font-weight: 950; color: #ee4d2d; text-transform: uppercase; }
.op-label-barcode { display: flex; flex-direction: column; align-items: flex-end; }
.barcode-lines { height: 32px; width: 128px; border: 1px solid rgba(16,55,92,.1); display: flex; gap: 1px; padding: 2px; align-items: stretch; background: #fff; }
.barcode-lines div { background: var(--navy); }

.op-label-info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem; border-bottom: 1px solid rgba(16,55,92,.1); padding-bottom: 0.5rem; font-size: 11px; }
.op-label-info-col.border-r { border-right: 1px solid rgba(16,55,92,.1); padding-right: 0.5rem; }

.op-label-middle { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(16,55,92,.1); padding-bottom: 0.5rem; gap: 1rem; font-size: 11px; }
.op-label-qr { width: 64px; height: 64px; border: 1px solid rgba(16,55,92,.2); padding: 2px; display: flex; flex-wrap: wrap; gap: 1px; }
.op-label-qr div { width: 6px; height: 6px; }

.op-label-bottom { flex: 1; display: flex; flex-direction: column; justify-content: space-between; }
.op-label-picking-title { font-size: 10px; font-weight: 900; text-transform: uppercase; color: rgba(16,55,92,.4); border-bottom: 1px solid rgba(16,55,92,.1); padding-bottom: 2px; margin-bottom: 0.5rem; display: flex; align-items: center; gap: 4px; }
.op-label-picking-table { width: 100%; border-collapse: collapse; font-size: 10.5px; }
.op-label-picking-table td { padding: 3px 0; border-bottom: 1px solid rgba(16,55,92,.05); font-weight: 600; }
.op-label-picking-table td.qty-col { text-align: right; font-weight: 900; color: var(--orange); }

.op-label-marker { text-align: center; font-size: 9px; font-weight: 900; color: rgba(16,55,92,.3); border-top: 1px solid rgba(16,55,92,.1); pt: 0.5rem; margin-top: auto; }

/* Toast Notifications */
.op-toast {
    position: fixed;
    top: 2rem;
    right: 2rem;
    background: var(--navy);
    color: #fff;
    padding: 1rem 1.5rem;
    border-radius: var(--radius-btn);
    box-shadow: 0 10px 25px rgba(0,0,0,.15);
    z-index: 120;
    font-size: 13px;
    font-weight: 700;
    display: flex;
    align-items: center;
    gap: 0.75rem;
    transform: translateY(-20px);
    opacity: 0;
    pointer-events: none;
    transition: all .25s ease-out;
}
.op-toast.open { transform: translateY(0); opacity: 1; pointer-events: auto; }
.op-toast.success { background: #059669; }
.op-toast.error { background: #dc2626; }
</style>

<%-- ── ENTERPRISE TAB SWITCHER BAR ── --%>
<div class="op-tab-bar">
    <button class="op-tab tab-review" id="tabReview" onclick="switchTab('pending_review')">
        Đơn cần duyệt
        <span class="op-tab-badge" id="badgeReview">0</span>
    </button>
    <button class="op-tab tab-waybill" id="tabWaybill" onclick="switchTab('pending_waybill')">
        Chờ in mã vận đơn
        <span class="op-tab-badge" id="badgeWaybill">0</span>
    </button>
    <button class="op-tab tab-rts" id="tabRTS" onclick="switchTab('pending_rts')">
        Chờ bàn giao ĐVVC
        <span class="op-tab-badge" id="badgeRTS">0</span>
    </button>
    <button class="op-tab tab-rma" id="tabRMA" onclick="switchTab('rma_dispute')">
        Hàng Hoàn &amp; Khiếu Nại
        <span class="op-tab-badge" id="badgeRMA">0</span>
    </button>
</div>

<%-- ── ENTERPRISE FILTER BAR ── --%>
<div class="op-filter-bar">
    <%-- Search input --%>
    <div class="op-search">
        <svg class="op-search-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line>
        </svg>
        <input type="text" placeholder="Tìm theo Mã đơn, Mã vận đơn, Tên khách, SKU, Tên sản phẩm..." id="opSearchInput" oninput="onSearchInput(this.value)" />
    </div>

    <%-- Filter 1: Kênh Bán --%>
    <div style="position:relative">
        <button class="op-filter-btn" onclick="toggleDropdown('ddChannel', event)">
            <span style="display:flex;align-items:center;gap:6px">
                <svg class="f-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="2" y1="12" x2="22" y2="12"></line><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path></svg>
                Kênh bán: <strong id="lblChannel" style="color:var(--navy)">Tất cả</strong>
            </span>
            <svg class="clear-x" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" onclick="clearFilter('channel', event)"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
        </button>
        <div id="ddChannel" class="op-dropdown">
            <button class="selected" onclick="selectChannel('all')">Tất cả các kênh</button>
            <button onclick="selectChannel('Shopee')">Shopee</button>
            <button onclick="selectChannel('TikTok')">TikTok</button>
            <button onclick="selectChannel('Lazada')">Lazada</button>
            <button onclick="selectChannel('Website')">Website</button>
        </div>
    </div>

    <%-- Filter 2: Sản Phẩm --%>
    <div style="position:relative">
        <button class="op-filter-btn" onclick="toggleDropdown('ddProduct', event)">
            <span style="display:flex;align-items:center;gap:6px">
                <svg class="f-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path><line x1="3" y1="6" x2="21" y2="6"></line><path d="M16 10a4 4 0 0 1-8 0"></path></svg>
                Sản phẩm: <strong id="lblProduct" style="color:var(--navy);max-width:140px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">Tất cả</strong>
            </span>
            <svg class="clear-x" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" onclick="clearFilter('product', event)"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
        </button>
        <div id="ddProduct" class="op-dropdown right" style="min-width:240px">
            <button class="selected" onclick="selectProduct('all')">Tất cả sản phẩm</button>
            <%-- populated dynamically --%>
        </div>
    </div>

    <%-- Filter 3: Đơn vị vận chuyển --%>
    <div style="position:relative">
        <button class="op-filter-btn" onclick="toggleDropdown('ddCarrier', event)">
            <span style="display:flex;align-items:center;gap:6px">
                <svg class="f-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="3" width="15" height="13"></rect><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"></polygon><circle cx="5.5" cy="18.5" r="2.5"></circle><circle cx="18.5" cy="18.5" r="2.5"></circle></svg>
                ĐVVC: <strong id="lblCarrier" style="color:var(--navy)">Tất cả</strong>
            </span>
            <svg class="clear-x" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" onclick="clearFilter('carrier', event)"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
        </button>
        <div id="ddCarrier" class="op-dropdown right">
            <button class="selected" onclick="selectCarrier('all')">Tất cả ĐVVC</button>
            <button onclick="selectCarrier('SPX Express')">SPX Express</button>
            <button onclick="selectCarrier('Lazada Express')">Lazada Express</button>
            <button onclick="selectCarrier('TikTok Express')">TikTok Express</button>
            <button onclick="selectCarrier('Viettel Post')">Viettel Post</button>
        </div>
    </div>

    <%-- Filter 4: Thời gian đóng gói (Chỉ hiện ở Tab Chờ bàn giao ĐVVC) --%>
    <div style="position:relative;display:none" id="opTimeFilterContainer">
        <button class="op-filter-btn" onclick="toggleDropdown('ddTime', event)">
            <span style="display:flex;align-items:center;gap:6px">
                <svg class="f-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                Đóng gói: <strong id="lblTime" style="color:var(--navy)">Tất cả</strong>
            </span>
            <svg class="clear-x" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" onclick="clearFilter('time', event)"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
        </button>
        <div id="ddTime" class="op-dropdown right">
            <button class="selected" onclick="selectTime('all')">Tất cả thời gian</button>
            <button onclick="selectTime('today')">Hôm nay</button>
            <button onclick="selectTime('yesterday')">Hôm qua</button>
            <button onclick="selectTime('7days')">7 ngày qua</button>
        </div>
    </div>
</div>

<%-- ── ENTERPRISE DATA GRID/TABLE ── --%>
<div class="op-table-card">
    <div class="op-table-scroll">
        <table class="op-table">
            <thead>
                <tr id="opTableHeader">
                    <%-- Populated by JS dynamic header columns --%>
                </tr>
            </thead>
            <tbody id="opTableBody">
                <%-- Populated by JS rows --%>
            </tbody>
        </table>
    </div>
    <div class="op-table-footer" id="opTableFooter">
        Hiển thị 0 / 0 đơn hàng
    </div>
</div>

<%-- ── ENTERPRISE DETAIL MODAL ── --%>
<div class="op-modal-overlay" id="opDetailModalOverlay" onclick="closeDetailModal()">
    <div class="op-modal" onclick="event.stopPropagation()">
        <div class="op-modal-header">
            <div style="display:flex;align-items:center;gap:12px">
                <span class="op-modal-title" id="mdTitle">CHI TIẾT ĐƠN HÀNG</span>
                <span class="badge-channel" id="mdChannel" style="background:#ee4d2d">Shopee</span>
                <span class="op-badge" id="mdWarehouse" style="background:var(--alice);color:var(--navy);border-color:#E5EAF3">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:12px;height:12px"><path d="M3 21h18"></path><path d="M5 21V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16"></path><path d="M9 9h1"></path><path d="M9 13h1"></path><path d="M14 9h1"></path><path d="M14 13h1"></path></svg>
                    <span id="mdWarehouseName">Chưa chỉ định</span>
                </span>
            </div>
            <button class="op-modal-close" onclick="closeDetailModal()">&times;</button>
        </div>

        <div class="op-modal-body">
            <%-- PART 1: CLIENT INFO --%>
            <div class="op-section-box">
                <div class="op-section-title">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                    Phần 1: Thông tin khách hàng &amp; Vận chuyển
                </div>
                <div class="op-info-grid">
                    <div>
                        <div class="op-info-row">
                            <span class="op-info-label">Người nhận:</span>
                            <span class="op-info-val" id="mdCustName">-</span>
                        </div>
                        <div class="op-info-row">
                            <span class="op-info-label">Điện thoại:</span>
                            <span class="op-info-val" id="mdCustPhone" style="font-family:monospace">-</span>
                        </div>
                        <div class="op-info-row" style="align-items:flex-start">
                            <span class="op-info-label">Địa chỉ giao:</span>
                            <span class="op-info-val" id="mdCustAddr">-</span>
                        </div>
                    </div>
                    <div>
                        <div class="op-info-row">
                            <span class="op-info-label">Đơn vị vận chuyển:</span>
                            <span class="op-info-val" id="mdCarrierName">-</span>
                        </div>
                        <div class="op-info-row">
                            <span class="op-info-label">Mã vận đơn:</span>
                            <span class="op-info-val" id="mdTrackingNo" style="font-family:monospace">-</span>
                        </div>
                        <div class="op-info-row">
                            <span class="op-info-label">Thời gian đồng bộ:</span>
                            <span class="op-info-val" id="mdSyncTime" style="font-family:monospace">-</span>
                        </div>
                    </div>
                </div>
            </div>

            <%-- PART 2: PRODUCT LIST & WAREHOUSE CROSS-STOCK LOOKUP --%>
            <div>
                <div class="op-section-title" style="margin-bottom:0.75rem">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="2" width="20" height="8" rx="2" ry="2"></rect><rect x="2" y="14" width="20" height="8" rx="2" ry="2"></rect><line x1="6" y1="6" x2="6.01" y2="6"></line><line x1="6" y1="18" x2="6.01" y2="18"></line></svg>
                    Phần 2: Danh sách sản phẩm &amp; Kiểm tra tồn kho chéo nhánh (Cross-branch Inventory)
                </div>
                <div id="mdProductList">
                    <%-- Rendered by JS --%>
                </div>
            </div>

            <%-- PART 3: ACTION PROGRESS TIMELINE --%>
            <div>
                <div class="op-section-title" style="margin-bottom:1rem">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg>
                    Phần 3: Tiến trình xử lý (Timeline)
                </div>
                <div class="op-timeline" id="mdTimeline">
                    <%-- Rendered dynamically by JS --%>
                </div>
            </div>

            <%-- PART 4: TAB-SPECIFIC ACTION PANELS --%>
            <div id="mdActionPanelContainer">
                <%-- Rendered dynamically by JS (e.g. Approve Form or RMA Form) --%>
            </div>
        </div>

        <div class="op-modal-footer">
            <button class="op-btn" style="background:#fff;border-color:#E5EAF3;color:rgba(16,55,92,.6)" onclick="closeDetailModal()">Đóng</button>
        </div>
    </div>
</div>

<%-- ── STICKY BATCH ACTIONS BAR (BOTTOM) ── --%>
<div class="op-sticky-bar" id="opStickyBar">
    <div style="display:flex;align-items:center;gap:8px">
        <span style="width:8px;height:8px;background:#34d399;border-radius:50%;display:inline-block" id="stickyPulseDot"></span>
        <span style="font-size:13px;font-weight:700">Đã chọn: <strong id="stickyCount" style="color:#fbbf24;font-size:15px">0</strong> đơn hàng</span>
    </div>
    <div style="display:flex;gap:8px" id="stickyActionsContainer">
        <%-- Populated by JS based on active tab --%>
    </div>
</div>

<%-- ── MERGED SHIPPING LABELS PRINT PREVIEW MODAL ── --%>
<div class="op-modal-overlay" id="opPrintModalOverlay" onclick="closePrintModal()">
    <div class="op-modal" onclick="event.stopPropagation()" style="max-width:550px">
        <div class="op-modal-header">
            <div>
                <span class="op-modal-title" style="display:flex;align-items:center;gap:6px">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:20px;height:20px;color:#10b981"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
                    XEM TRƯỚC TEM VẬN CHUYỂN A6
                </span>
                <p style="font-size:11px;color:rgba(16,55,92,.4);margin-top:2px">Hệ thống đã gộp các trang nhãn dán Base64 nhận từ sàn thành 1 tệp in duy nhất</p>
            </div>
            <button class="op-modal-close" onclick="closePrintModal()">&times;</button>
        </div>
        <div class="op-modal-body" style="background:#f3f4f6;padding:1.5rem;overflow-y:auto" id="printModalBody">
            <%-- Populated dynamically --%>
        </div>
        <div class="op-modal-footer" style="background:#fff;border-top:1px solid #E5EAF3">
            <span style="font-size:12px;color:rgba(16,55,92,.5);margin-right:auto;display:flex;align-items:center;gap:4px">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:14px;height:14px"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
                Ghép thành công <strong id="lblPrintLabelsCount" style="color:var(--navy)">0</strong> nhãn in
            </span>
            <button class="op-btn" style="background:#fff;border-color:#E5EAF3;color:rgba(16,55,92,.6)" onclick="closePrintModal()">Đóng</button>
            <button class="op-btn success" onclick="executeSimulatedPrint()" id="btnExecutePrint">Tiến hành in tem vật lý</button>
        </div>
    </div>
</div>

<%-- ── TOAST NOTIFICATIONS POPUP ── --%>
<div class="op-toast" id="opToast">
    <svg id="opToastIcon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="width:16px;height:16px"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
    <span id="opToastMsg">Thông báo hệ thống</span>
</div>

<script>
// ── CONSTANTS & GLOBALS ──────────────────────────────────────────────
const WAREHOUSES = [
    { name: "Kho Hà Nội", code: "HN" },
    { name: "Kho TP.HCM", code: "HCM" },
    { name: "Kho Đà Nẵng", code: "DN" }
];

const STATUS_CONFIG = {
    pending_review: { label: "Chờ duyệt", bg: "background:#fee2e2", text: "color:#dc2626;border-color:#fca5a5", dot: "background:#ef4444" },
    confirmed: { label: "Chờ xử lý", bg: "background:#fef3c7", text: "color:#d97706;border-color:#fcd34d", dot: "background:#f59e0b" },
    packing: { label: "Đang đóng gói", bg: "background:#f3e8ff", text: "color:#7e22ce;border-color:#d8b4fe", dot: "background:#a855f7" },
    packed: { label: "Đã đóng gói", bg: "background:#ccfbf1", text: "color:#0f766e;border-color:#99f6e4", dot: "background:#0d9488" },
    shipping: { label: "Đang giao", bg: "background:#dbeafe", text: "color:#2563eb;border-color:#bfdbfe", dot: "background:#3b82f6" },
    delivered: { label: "Đã giao", bg: "background:#d1fae5", text: "color:#059669;border-color:#6ee7b7", dot: "background:#10b981" },
    completed: { label: "Hoàn thành", bg: "background:#dcfce7", text: "color:#15803d;border-color:#86efac", dot: "background:#16a34a" },
    returned: { label: "Trả hàng", bg: "background:#f3f4f6", text: "color:#4b5563;border-color:#d1d5db", dot: "background:#6b7280" },
    disputed: { label: "Đang khiếu nại", bg: "background:#fef3c7", text: "color:#b45309;border-color:#fcd34d", dot: "background:#f59e0b" },
    dispute_success: { label: "Khiếu nại thành công", bg: "background:#d1fae5", text: "color:#047857;border-color:#6ee7b7", dot: "background:#10b981" },
    cancelled: { label: "Đã hủy", bg: "background:#ffe4e6", text: "color:#be123c;border-color:#fecdd3", dot: "background:#f43f5e" }
};

let allOrders = [
    <c:forEach var="order" items="${orderList}" varStatus="status">
    <c:set var="totalQty" value="0"/>
    <c:forEach var="item" items="${order.items}">
        <c:set var="totalQty" value="${totalQty + item.quantity}"/>
    </c:forEach>
    {
        id: "${order.orderCode}",
        channel: "${order.channel == 'ONLINE' ? 'Lazada' : order.channel}",
        customerName: "Khách hàng #${order.customerId != null ? order.customerId : 'N/A'}",
        customerPhone: "090xxxxxxx",
        totalItems: ${totalQty},
        totalAmount: ${order.totalAmount},
        status: "${order.status == 'PENDING' ? 'pending_review' : (order.status == 'CONFIRMED' ? 'confirmed' : (order.status == 'PACKING' ? 'packing' : (order.status == 'PACKED' ? 'packed' : (order.status == 'SHIPPED' ? 'shipping' : (order.status == 'DELIVERED' ? 'delivered' : (order.status == 'COMPLETED' ? 'completed' : (order.status == 'RETURNED' ? 'returned' : (order.status == 'DISPUTED' ? 'disputed' : (order.status == 'DISPUTE_SUCCESS' ? 'dispute_success' : (order.status == 'CANCELLED' ? 'cancelled' : order.status.toLowerCase()))))))))))}",
        warehouse: "${order.warehouseName != null ? order.warehouseName : 'Chưa chỉ định kho'}",
        trackingNo: "LHD-${order.orderCode}",
        createdAt: "${order.createdAt}",
        items: [
            <c:forEach var="item" items="${order.items}" varStatus="itemStatus">
            <%
               com.wms.model.OrderItem it = (com.wms.model.OrderItem) pageContext.getAttribute("item");
               String escName = it.getProductName() != null ? it.getProductName().replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "") : "";
               String escSku = it.getSkuCode() != null ? it.getSkuCode().replace("\\", "\\\\").replace("\"", "\\\"") : "";
             %>
            {
                sku: "<%= escSku %>",
                name: "<%= escName %>",
                quantity: ${item.quantity},
                price: ${item.unitPrice}
            }${!itemStatus.last ? ',' : ''}
            </c:forEach>
        ]
    }${!status.last ? ',' : ''}
    </c:forEach>
];
let activeTab = "pending_review";
let searchQuery = "";
let selectedChannel = "all";
let selectedProduct = "all";
let selectedCarrier = "all";
let selectedTime = "all";

let activeDetailOrder = null;
let selectedBatchIds = [];

// Simulation State variables
let isSubmitting = false;
let isGeneratingTracking = false;
let isGeneratingPDF = false;
let isSubmittingRTS = false;
let isSubmittingDispute = false;

// Webhook simulation timer
let webhookCountdown = null;
let countdownOrderId = null;
let countdownInterval = null;

// ── INIT DOMContentLoaded ───────────────────────────────────────────
document.addEventListener("DOMContentLoaded", function() {
    loadOrdersFromStorage();
    
    // React interop sync
    window.addEventListener("ORDER_STORE_UPDATED", function() {
        loadOrdersFromStorage();
        renderAll();
    });

    // Populate products dropdown based on SKU mapping or present orders
    buildProductDropdown();
    
    // Check initial search params
    const urlParams = new URLSearchParams(window.location.search);
    const tabParam = urlParams.get("tab");
    if (tabParam && ["pending_review", "pending_waybill", "pending_rts", "rma_dispute"].includes(tabParam)) {
        activeTab = tabParam;
    }

    renderAll();
    
    // Global body click to hide dropdowns
    document.addEventListener("click", function() {
        hideAllDropdowns();
    });
});

function loadOrdersFromStorage() {
    const data = localStorage.getItem("b2c_orders_v2");
    if (data) {
        try {
            allOrders = JSON.parse(data);
        } catch(e) {
            console.error("Failed to parse local storage orders:", e);
        }
    }
}

function saveOrdersToStorage() {
    localStorage.setItem("b2c_orders_v2", JSON.stringify(allOrders));
    // Trigger event for cross-component sync
    window.dispatchEvent(new CustomEvent("ORDER_STORE_UPDATED"));
}

function getWarehouseStock(sku, wname) {
    var ps = JSON.parse(localStorage.getItem('wh_pricing_sales') || '[]');
    var record = ps.find(function(p) { return p.sku === sku; });
    if (!record) return 0;
    
    if (record.warehouseStock && record.warehouseStock[wname] !== undefined) {
        return record.warehouseStock[wname];
    }
    
    var totalQty = record.qtyAvailable !== undefined ? record.qtyAvailable : (record.qtyOnHand || 0);
    if (wname === "Kho Hà Nội" || wname.indexOf("Hà Nội") > -1) {
        return Math.floor(totalQty * 0.6);
    }
    if (wname === "Kho TP.HCM" || wname === "Kho TP. Hồ Chí Minh" || wname.indexOf("HCM") > -1) {
        return Math.floor(totalQty * 0.3);
    }
    if (wname === "Kho Đà Nẵng" || wname.indexOf("Đà Nẵng") > -1) {
        return Math.max(0, totalQty - Math.floor(totalQty * 0.6) - Math.floor(totalQty * 0.3));
    }
    return 0;
}

function resolvePhysicalItems(itemSku, itemQuantity) {
    const stored = localStorage.getItem("sku_raw_mappings_v2");
    if (!stored) return [{ sku: itemSku, name: null, quantity: itemQuantity, conversionRate: 1, isComboSplit: false }];
    try {
        const mappings = JSON.parse(stored);
        const relations = mappings.filter(m => m.channelSKU === itemSku);
        if (relations.length === 0) {
            return [{ sku: itemSku, name: null, quantity: itemQuantity, conversionRate: 1, isComboSplit: false }];
        }
        return relations.map(m => ({
            sku: m.masterSKU,
            name: m.masterName,
            quantity: itemQuantity * m.conversionRate,
            conversionRate: m.conversionRate,
            isComboSplit: true
        }));
    } catch (e) {
        console.error(e);
        return [{ sku: itemSku, name: null, quantity: itemQuantity, conversionRate: 1, isComboSplit: false }];
    }
}

function getShippingCarrierOfOrder(order) {
    if (order.channel === "Shopee") return "SPX Express";
    if (order.channel === "Lazada") return "Lazada Express";
    if (order.channel === "TikTok") return "TikTok Express";
    return "Viettel Post";
}

function getOrderShippingCarrier(order) {
    return getShippingCarrierOfOrder(order);
}

// ── TOAST HELPER ─────────────────────────────────────────────────────
function showToast(msg, type = "info") {
    const toast = document.getElementById("opToast");
    const label = document.getElementById("opToastMsg");
    const icon = document.getElementById("opToastIcon");
    
    toast.className = "op-toast " + type;
    label.textContent = msg;
    
    // Update SVG icon
    if (type === "success") {
        icon.innerHTML = `<path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline>`;
    } else if (type === "error") {
        icon.innerHTML = `<circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line>`;
    } else {
        icon.innerHTML = `<circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line>`;
    }
    
    toast.classList.add("open");
    setTimeout(() => {
        toast.classList.remove("open");
    }, 4500);
}

// ── RENDER & SWITCH TAB ──────────────────────────────────────────────
function switchTab(tabId) {
    activeTab = tabId;
    selectedBatchIds = [];
    hideAllDropdowns();
    
    // Sync URL parameter
    const url = new URL(window.location);
    url.searchParams.set("tab", tabId);
    window.history.pushState({}, '', url);
    
    // Toggle active tab class
    document.querySelectorAll(".op-tab").forEach(btn => btn.classList.remove("active"));
    if (tabId === "pending_review") document.getElementById("tabReview").classList.add("active");
    if (tabId === "pending_waybill") document.getElementById("tabWaybill").classList.add("active");
    if (tabId === "pending_rts") document.getElementById("tabRTS").classList.add("active");
    if (tabId === "rma_dispute") document.getElementById("tabRMA").classList.add("active");
    
    // Toggle time filter visibility (only in RTS tab)
    const timeFilter = document.getElementById("opTimeFilterContainer");
    if (tabId === "pending_rts") {
        timeFilter.style.display = "block";
    } else {
        timeFilter.style.display = "none";
        selectedTime = "all";
        document.getElementById("lblTime").textContent = "Tất cả";
    }
    
    renderAll();
}

function renderAll() {
    renderTabBadges();
    renderTableHeader();
    renderTableBody();
    renderStickyBar();
}

function renderTabBadges() {
    const reviewCnt = allOrders.filter(o => o.status === "pending_review").length;
    const waybillCnt = allOrders.filter(o => o.status === "confirmed").length;
    const rtsCnt = allOrders.filter(o => o.status === "packed").length;
    const rmaCnt = allOrders.filter(o => {
        return (o.status === "returned" || o.status === "disputed" || o.status === "dispute_success") 
            && o.rmaPhysicalStatus === "Đã nhập Zone Khiếu Nại";
    }).length;
    
    document.getElementById("badgeReview").textContent = reviewCnt;
    document.getElementById("badgeWaybill").textContent = waybillCnt;
    document.getElementById("badgeRTS").textContent = rtsCnt;
    document.getElementById("badgeRMA").textContent = rmaCnt;
}

// ── DROPDOWNS ────────────────────────────────────────────────────────
function toggleDropdown(ddId, event) {
    event.stopPropagation();
    const dropdown = document.getElementById(ddId);
    const isOpen = dropdown.classList.contains("open");
    hideAllDropdowns();
    if (!isOpen) dropdown.classList.add("open");
}

function hideAllDropdowns() {
    document.querySelectorAll(".op-dropdown").forEach(dd => dd.classList.remove("open"));
}

function buildProductDropdown() {
    const drop = document.getElementById("ddProduct");
    // Clear dynamic options
    while (drop.childNodes.length > 2) {
        drop.removeChild(drop.lastChild);
    }
    
    // Find all distinct item names
    const names = [];
    allOrders.forEach(o => {
        if (o.items) {
            o.items.forEach(i => {
                if (i.name && names.indexOf(i.name) === -1) {
                    names.push(i.name);
                }
            });
        }
    });
    
    names.forEach(name => {
        const btn = document.createElement("button");
        btn.textContent = name;
        btn.onclick = () => selectProduct(name);
        drop.appendChild(btn);
    });
}

function selectChannel(val) {
    selectedChannel = val;
    document.getElementById("lblChannel").textContent = val === "all" ? "Tất cả" : val;
    // highlight selected option
    document.querySelectorAll("#ddChannel button").forEach(btn => {
        btn.className = (btn.textContent.indexOf(val) > -1 || (val === "all" && btn.textContent.indexOf("Tất cả") > -1)) ? "selected" : "";
    });
    renderAll();
}

function selectProduct(val) {
    selectedProduct = val;
    const labelText = val === "all" ? "Tất cả" : (val.length > 15 ? val.slice(0, 15) + "..." : val);
    document.getElementById("lblProduct").textContent = labelText;
    document.querySelectorAll("#ddProduct button").forEach(btn => {
        btn.className = (btn.textContent === val || (val === "all" && btn.textContent.indexOf("Tất cả") > -1)) ? "selected" : "";
    });
    renderAll();
}

function selectCarrier(val) {
    selectedCarrier = val;
    document.getElementById("lblCarrier").textContent = val === "all" ? "Tất cả" : val;
    document.querySelectorAll("#ddCarrier button").forEach(btn => {
        btn.className = (btn.textContent.indexOf(val) > -1 || (val === "all" && btn.textContent.indexOf("Tất cả") > -1)) ? "selected" : "";
    });
    renderAll();
}

function selectTime(val) {
    selectedTime = val;
    let label = "Tất cả";
    if (val === "today") label = "Hôm nay";
    if (val === "yesterday") label = "Hôm qua";
    if (val === "7days") label = "7 ngày qua";
    document.getElementById("lblTime").textContent = label;
    document.querySelectorAll("#ddTime button").forEach(btn => {
        btn.className = (btn.textContent.indexOf(label) > -1 || (val === "all" && btn.textContent.indexOf("Tất cả") > -1)) ? "selected" : "";
    });
    renderAll();
}

function clearFilter(type, event) {
    event.stopPropagation();
    if (type === "channel") selectChannel("all");
    if (type === "product") selectProduct("all");
    if (type === "carrier") selectCarrier("all");
    if (type === "time") selectTime("all");
}

function onSearchInput(val) {
    searchQuery = val.trim();
    renderAll();
}

// ── DYNAMIC TABLE RENDER ─────────────────────────────────────────────
function getFilteredOrders() {
    return allOrders.filter(order => {
        // Tab mapping filter
        let matchTab = false;
        if (activeTab === "pending_review") {
            matchTab = order.status === "pending_review";
        } else if (activeTab === "pending_waybill") {
            matchTab = order.status === "confirmed";
        } else if (activeTab === "pending_rts") {
            matchTab = order.status === "packed";
        } else if (activeTab === "rma_dispute") {
            matchTab = (order.status === "returned" || order.status === "disputed" || order.status === "dispute_success") 
                && order.rmaPhysicalStatus === "Đã nhập Zone Khiếu Nại";
        }
        
        if (!matchTab) return false;
        
        // Channel filter
        if (selectedChannel !== "all" && order.channel !== selectedChannel) return false;
        
        // Carrier filter
        if (selectedCarrier !== "all" && getShippingCarrierOfOrder(order) !== selectedCarrier) return false;
        
        // Time filter (updatedAt)
        if (activeTab === "pending_rts" && selectedTime !== "all") {
            const todayStr = new Date().toLocaleDateString("sv-SE"); // YYYY-MM-DD
            const yesterday = new Date();
            yesterday.setDate(yesterday.getDate() - 1);
            const yesterdayStr = yesterday.toLocaleDateString("sv-SE");
            
            const orderDateStr = order.updatedAt ? order.updatedAt.slice(0, 10) : "";
            if (selectedTime === "today" && orderDateStr !== todayStr) return false;
            if (selectedTime === "yesterday" && orderDateStr !== yesterdayStr) return false;
            if (selectedTime === "7days") {
                if (!orderDateStr) return false;
                const orderDate = new Date(orderDateStr);
                const diffTime = Math.abs(new Date().getTime() - orderDate.getTime());
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                if (diffDays > 7) return false;
            }
        }
        
        // Product filter
        if (selectedProduct !== "all") {
            const hasProd = order.items && order.items.some(i => i.name === selectedProduct);
            if (!hasProd) return false;
        }
        
        // Search query
        if (searchQuery) {
            const q = searchQuery.toLowerCase();
            const idMatch = order.id && order.id.toLowerCase().indexOf(q) > -1;
            const trackMatch = order.trackingNo && order.trackingNo.toLowerCase().indexOf(q) > -1;
            const nameMatch = order.customerName && order.customerName.toLowerCase().indexOf(q) > -1;
            const skuMatch = order.items && order.items.some(i => {
                return (i.sku && i.sku.toLowerCase().indexOf(q) > -1) || 
                       (i.name && i.name.toLowerCase().indexOf(q) > -1);
            });
            
            if (!idMatch && !trackMatch && !nameMatch && !skuMatch) return false;
        }
        
        return true;
    });
}

function renderTableHeader() {
    const header = document.getElementById("opTableHeader");
    
    // Checkbox column for batch actions tabs
    const isBatchTab = (activeTab === "pending_waybill" || activeTab === "pending_rts");
    
    let html = "";
    if (isBatchTab) {
        html += `<th style="width: 48px; text-align: center">
            <input type="checkbox" id="selectAllCheckbox" onchange="toggleSelectAll(this.checked)" style="width:16px;height:16px;cursor:pointer"/>
        </th>`;
    }
    
    html += `<th style="width: 56px">STT</th>
    <th style="width: 144px">Mã đơn hàng</th>
    <th style="width: 128px">Kênh bán</th>
    <th style="width: 192px">Khách hàng</th>`;
    
    if (activeTab === "pending_waybill") {
        html += `<th style="width: 176px">Trạng thái Tracking</th>`;
    } else if (activeTab === "pending_rts") {
        html += `<th style="width: 144px">ĐVVC</th>
        <th style="width: 176px">Thời gian đóng gói</th>`;
    } else if (activeTab === "rma_dispute") {
        html += `<th style="width: 192px">Lý do khách trả</th>
        <th style="width: 144px">Trạng thái vật lý</th>
        <th style="width: 144px">Trạng thái Sàn</th>`;
    } else { // pending_review
        html += `<th style="width: 96px; text-align: right">Số lượng</th>
        <th style="width: 128px; text-align: right">Tổng tiền</th>
        <th style="width: 144px">Trạng thái</th>`;
    }
    
    html += `<th style="width: 160px">Kho xử lý</th>
    <th style="width: 96px; text-align: center">Chi tiết</th>`;
    
    header.innerHTML = html;
}

function renderTableBody() {
    const tbody = document.getElementById("opTableBody");
    const filtered = getFilteredOrders();
    
    // Sync selectAll checkbox state
    const selectAllCheck = document.getElementById("selectAllCheckbox");
    if (selectAllCheck) {
        selectAllCheck.checked = (filtered.length > 0 && selectedBatchIds.length === filtered.length);
    }
    
    if (filtered.length === 0) {
        tbody.innerHTML = `<tr>
            <td colspan="${activeTab === 'pending_waybill' ? 8 : activeTab === 'pending_rts' ? 9 : activeTab === 'rma_dispute' ? 9 : 8}" class="op-empty">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><line x1="9" y1="9" x2="15" y2="15"></line><line x1="15" y1="9" x2="9" y2="15"></line></svg>
                Không tìm thấy đơn hàng nào khớp với bộ lọc
            </td>
        </tr>`;
        document.getElementById("opTableFooter").textContent = `Hiển thị 0 / ${allOrders.length} đơn hàng`;
        return;
    }
    
    let html = "";
    filtered.forEach((order, idx) => {
        const isBatchTab = (activeTab === "pending_waybill" || activeTab === "pending_rts");
        const isChecked = selectedBatchIds.indexOf(order.id) > -1;
        const cfg = STATUS_CONFIG[order.status] || { label: order.status, bg: "background:#e5eaf3", text: "color:#10375c", dot: "background:#10375c" };
        const carrier = getShippingCarrierOfOrder(order);
        const channelColor = order.channelColor || "#10375c";
        
        html += `<tr class="${order.status === 'pending_review' ? 'pending-row' : ''}" onclick="openDetailModal('${order.id}')" style="cursor:pointer">`;
        
        if (isBatchTab) {
            html += `<td style="text-align: center" onclick="event.stopPropagation()">
                <input type="checkbox" style="width:16px;height:16px;cursor:pointer" ${isChecked ? 'checked' : ''} onchange="toggleSelectOrder('${order.id}', this.checked)" />
            </td>`;
        }
        
        html += `<td><span style="color:rgba(16,55,92,.4);font-weight:700;font-size:12px">${idx + 1}</span></td>
        <td>
            <div style="font-weight:700;font-family:monospace">${order.id}</div>
            ${order.trackingNo ? `<div style="font-size:10px;color:rgba(16,55,92,.4);font-family:monospace;margin-top:2px">${order.trackingNo}</div>` : `<div style="font-size:9.5px;color:#d97706;font-style:italic;font-weight:700;margin-top:2px">Chưa cấp tracking</div>`}
        </td>
        <td>
            <span class="badge-channel" style="background:${channelColor}">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:11px;height:11px"><circle cx="12" cy="12" r="10"></circle><line x1="2" y1="12" x2="22" y2="12"></line><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path></svg>
                ${order.channel}
            </span>
        </td>
        <td>
            <div style="font-weight:600">${order.customerName}</div>
            <div style="font-size:11px;color:rgba(16,55,92,.4)">${order.customerPhone}</div>
        </td>`;
        
        if (activeTab === "pending_waybill") {
            html += `<td>
                ${order.trackingNo ? `
                    <span class="op-badge" style="background:#ecfdf5;color:#047857;border-color:#a7f3d0">
                        <span class="op-badge-dot" style="background:#10b981"></span>
                        ĐÃ CÓ: ${order.trackingNo}
                    </span>
                ` : `
                    <span class="op-badge" style="background:#fef2f2;color:#b91c1c;border-color:#fecaca">
                        <span class="op-badge-dot" style="background:#ef4444"></span>
                        YÊU CẦU SINH MÃ
                    </span>
                `}
                <div style="font-size:9.5px;color:rgba(16,55,92,.4);font-weight:700;margin-top:4px;display:flex;align-items:center;gap:3px">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:11px;height:11px"><rect x="1" y="3" width="15" height="13"></rect><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"></polygon><circle cx="5.5" cy="18.5" r="2.5"></circle><circle cx="18.5" cy="18.5" r="2.5"></circle></svg>
                    ĐVVC: ${carrier}
                </div>
            </td>`;
        } else if (activeTab === "pending_rts") {
            html += `<td>
                <span style="font-weight:600;display:flex;align-items:center;gap:4px">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:12px;height:12px;color:rgba(16,55,92,.3)"><rect x="1" y="3" width="15" height="13"></rect><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"></polygon><circle cx="5.5" cy="18.5" r="2.5"></circle><circle cx="18.5" cy="18.5" r="2.5"></circle></svg>
                    ${carrier}
                </span>
            </td>
            <td>
                <span style="font-weight:600;font-size:12px;display:flex;align-items:center;gap:4px">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:12px;height:12px;color:rgba(16,55,92,.3)"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                    ${order.updatedAt}
                </span>
            </td>`;
        } else if (activeTab === "rma_dispute") {
            html += `<td><span style="font-weight:600">${order.rmaReason || "Chưa rõ lý do"}</span></td>
            <td>
                <span class="op-badge" style="background:#fffbeb;color:#b45309;border-color:#fde68a">
                    ${order.rmaPhysicalStatus || "Đã nhập Zone Khiếu Nại"}
                </span>
            </td>
            <td>
                <span class="op-badge" style="${order.status === 'dispute_success' ? 'background:#ecfdf5;color:#047857;border-color:#a7f3d0' : order.status === 'disputed' ? 'background:#eff6ff;color:#1d4ed8;border-color:#bfdbfe' : 'background:#f9fafb;color:#374151;border-color:#e5e7eb'}">
                    ${order.status === 'dispute_success' ? 'Bồi thường thành công' : order.status === 'disputed' ? 'Đang xử lý khiếu nại' : 'Chờ xử lý'}
                </span>
            </td>`;
        } else {
            html += `<td style="text-align:right;font-weight:700">${order.totalItems}</td>
            <td style="text-align:right;font-weight:800;font-family:monospace">${order.totalAmount.toLocaleString()}đ</td>
            <td>
                <span class="op-badge" style="${cfg.bg};${cfg.text}">
                    <span class="op-badge-dot" style="${cfg.dot}"></span>
                    ${cfg.label}
                </span>
            </td>`;
        }
        
        html += `<td>
            ${order.warehouse ? `
                <span style="font-weight:600;display:flex;align-items:center;gap:4px">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:12px;height:12px;color:rgba(16,55,92,.3)"><path d="M3 21h18"></path><path d="M5 21V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16"></path></svg>
                    ${order.warehouse}
                </span>
            ` : `
                <span style="color:#d97706;font-style:italic;font-weight:600">Chưa chỉ định</span>
            `}
        </td>
        <td onclick="event.stopPropagation()">
            <button class="op-btn-detail" onclick="openDetailModal('${order.id}')" title="Xem chi tiết">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0z"/><path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
            </button>
        </td>
        </tr>`;
    });
    
    tbody.innerHTML = html;
    document.getElementById("opTableFooter").textContent = `Hiển thị ${filtered.length} / ${allOrders.length} đơn hàng`;
}

// ── BATCH SELECTION HANDLERS ──────────────────────────────────────────
function toggleSelectAll(checked) {
    const filtered = getFilteredOrders();
    if (checked) {
        selectedBatchIds = filtered.map(o => o.id);
    } else {
        selectedBatchIds = [];
    }
    renderTableBody();
    renderStickyBar();
}

function toggleSelectOrder(id, checked) {
    if (checked) {
        if (selectedBatchIds.indexOf(id) === -1) {
            selectedBatchIds.push(id);
        }
    } else {
        selectedBatchIds = selectedBatchIds.filter(x => x !== id);
    }
    renderTableBody();
    renderStickyBar();
}

// ── STICKY ACTIONS BAR ───────────────────────────────────────────────
function renderStickyBar() {
    const bar = document.getElementById("opStickyBar");
    const count = document.getElementById("stickyCount");
    const container = document.getElementById("stickyActionsContainer");
    
    if (selectedBatchIds.length === 0) {
        bar.classList.remove("open");
        return;
    }
    
    count.textContent = selectedBatchIds.length;
    let html = "";
    
    if (activeTab === "pending_waybill") {
        // Check if any of selected orders don't have tracking code
        const hasUnallocated = allOrders.some(o => selectedBatchIds.indexOf(o.id) > -1 && !o.trackingNo);
        
        html += `<button class="op-sticky-bar-btn amber" onclick="executeBatchGenerateTracking()" ${isGeneratingTracking ? 'disabled' : ''} ${!hasUnallocated ? 'disabled' : ''}>
            ${isGeneratingTracking ? 'Đang sinh mã...' : '⚙️ 1. SINH MÃ TRACKING'}
        </button>
        <button class="op-sticky-bar-btn emerald" onclick="openPrintModal()" ${hasUnallocated || isGeneratingPDF ? 'disabled' : ''}>
            ${isGeneratingPDF ? 'Đang gộp PDF...' : '🖨️ 2. IN TEM VẬN ĐƠN (PDF)'}
        </button>`;
    } else if (activeTab === "pending_rts") {
        html += `<button class="op-sticky-bar-btn teal" onclick="executeBatchRTS()" ${isSubmittingRTS ? 'disabled' : ''}>
            ${isSubmittingRTS ? 'Đang truyền tin RTS...' : '🚚 XÁC NHẬN READY TO SHIP (BÁO SÀN)'}
        </button>`;
    }
    
    container.innerHTML = html;
    bar.classList.add("open");
}

// ── BATCH API SIMULATION METHODS ──────────────────────────────────────
function executeBatchGenerateTracking() {
    isGeneratingTracking = true;
    renderStickyBar();
    
    setTimeout(() => {
        let cnt = 0;
        allOrders = allOrders.map(o => {
            if (selectedBatchIds.indexOf(o.id) > -1 && !o.trackingNo) {
                let pref = "GHN";
                if (o.channel === "Shopee") pref = "SPX";
                else if (o.channel === "Lazada") pref = "LZE";
                else if (o.channel === "TikTok") pref = "TKT";
                else if (o.channel === "Website") pref = "VTP";
                
                const rand = Math.floor(100000000 + Math.random() * 900000000);
                o.trackingNo = pref + "-" + rand;
                o.updatedAt = new Date().toLocaleString("sv-SE").replace("T", " ").slice(0, 16);
                cnt++;
            }
            return o;
        });
        
        saveOrdersToStorage();
        isGeneratingTracking = false;
        renderAll();
        showToast(`Tạo mã vận đơn thành công cho ${cnt} đơn hàng!`, "success");
    }, 1200);
}

function executeBatchRTS() {
    isSubmittingRTS = true;
    renderStickyBar();
    
    setTimeout(() => {
        allOrders = allOrders.map(o => {
            if (selectedBatchIds.indexOf(o.id) > -1) {
                o.status = "shipping";
                o.updatedAt = new Date().toLocaleString("sv-SE").replace("T", " ").slice(0, 16);
                o.reviewNote = "Ready to Ship (Đồng bộ RTS API thành công). Đang chờ bưu tá lấy hàng.";
            }
            return o;
        });
        
        saveOrdersToStorage();
        isSubmittingRTS = false;
        selectedBatchIds = [];
        renderAll();
        showToast("Đã đồng bộ Ready to Ship! Trạng thái chuyển sang Đang giao (Chờ lấy hàng)", "success");
    }, 1200);
}

// ── WEBHOOK SIMULATOR ────────────────────────────────────────────────
function triggerWebhook(orderId, type) {
    const order = allOrders.find(o => o.id === orderId);
    if (!order) return;
    
    const nowStr = new Date().toLocaleString("sv-SE").replace("T", " ").slice(0, 16);
    if (!order.webhookEvents) order.webhookEvents = [];
    
    if (type === "pickup") {
        order.status = "shipping";
        order.updatedAt = nowStr;
        order.webhookEvents.push({
            time: nowStr,
            eventName: "Lấy hàng thành công",
            description: "Shipper của ĐVVC đã bốc hàng ra khỏi kho và quét mã vạch thành công."
        });
        showToast("Webhook nhận: Đã lấy hàng thành công!", "success");
    } else if (type === "transit") {
        order.status = "shipping";
        order.updatedAt = nowStr;
        order.webhookEvents.push({
            time: nowStr,
            eventName: "Đang giao hàng",
            description: "Đơn hàng đang trên xe trung chuyển của bưu cục phát đến địa chỉ người nhận."
        });
        showToast("Webhook nhận: Đang vận chuyển...", "info");
    } else if (type === "delivered") {
        order.status = "delivered";
        order.updatedAt = nowStr;
        order.webhookEvents.push({
            time: nowStr,
            eventName: "Giao hàng thành công",
            description: "Bưu tá đã giao hàng thành công tới tay khách hàng. Bắt đầu tính 3 ngày đối soát ví."
        });
        showToast("Webhook nhận: Giao hàng thành công!", "success");
        
        // Start 5s countdown simulation of 3-day completion auto-disbursement
        startDisbursementCountdown(orderId);
    } else if (type === "return") {
        order.status = "returned";
        order.updatedAt = nowStr;
        order.webhookEvents.push({
            time: nowStr,
            eventName: "Yêu cầu Trả hàng (Return Request)",
            description: "Khách hàng bấm yêu cầu Trả hàng/Hoàn tiền trên App Sàn TMĐT do sản phẩm lỗi hoặc không đúng hình ảnh."
        });
        order.rmaReason = "Khách hàng báo sản phẩm bị lỗi hoặc không khớp mô tả";
        order.rmaPhysicalStatus = "Đã nhập Zone Khiếu Nại";
        order.rmaPlatformStatus = "Chờ xử lý";
        order.rmaCustomerImages = ["https://images.unsplash.com/photo-1597843798940-023a85055b8e?w=500&auto=format&fit=crop"];
        
        showToast("Webhook nhận: Khách hàng yêu cầu Trả hàng/Hoàn tiền!", "error");
    }
    
    saveOrdersToStorage();
    renderAll();
    
    // Refresh details modal if currently looking at this order
    if (activeDetailOrder && activeDetailOrder.id === orderId) {
        openDetailModal(orderId);
    }
}

function startDisbursementCountdown(orderId) {
    if (countdownInterval) clearInterval(countdownInterval);
    countdownOrderId = orderId;
    webhookCountdown = 5;
    
    // Redraw details modal immediately if open to show countdown badge
    if (activeDetailOrder && activeDetailOrder.id === orderId) {
        renderModal(activeDetailOrder);
    }
    
    countdownInterval = setInterval(() => {
        webhookCountdown--;
        if (webhookCountdown <= 0) {
            clearInterval(countdownInterval);
            countdownInterval = null;
            
            // Auto complete order
            allOrders = allOrders.map(o => {
                if (o.id === countdownOrderId) {
                    o.status = "completed";
                    const nowStr = new Date().toLocaleString("sv-SE").replace("T", " ").slice(0, 16);
                    o.updatedAt = nowStr;
                    if (!o.webhookEvents) o.webhookEvents = [];
                    o.webhookEvents.push({
                        time: nowStr,
                        eventName: "Đơn hàng Hoàn thành",
                        description: "Hệ thống tự động hoàn thành đơn hàng sau 3 ngày kể từ lúc giao hàng thành công (Khách không khiếu nại)."
                    });
                }
                return o;
            });
            
            saveOrdersToStorage();
            webhookCountdown = null;
            countdownOrderId = null;
            renderAll();
            
            // Update modal if open
            if (activeDetailOrder && activeDetailOrder.id === orderId) {
                openDetailModal(orderId);
            }
            
            showToast("Giao dịch hoàn thành! Hệ thống tự động giải ngân ví sàn.", "success");
        } else {
            // Update details modal countdown digits if looking at the active order
            if (activeDetailOrder && activeDetailOrder.id === orderId) {
                renderModal(activeDetailOrder);
            }
        }
    }, 1000);
}

// ── DETAIL MODAL FUNCTIONS ───────────────────────────────────────────
function openDetailModal(id) {
    const order = allOrders.find(o => o.id === id);
    if (!order) return;
    
    activeDetailOrder = order;
    renderModal(order);
    document.getElementById("opDetailModalOverlay").classList.add("open");
}

function closeDetailModal() {
    document.getElementById("opDetailModalOverlay").classList.remove("open");
    activeDetailOrder = null;
}

function renderModal(order) {
    const channelColor = order.channelColor || "#10375c";
    
    // Header
    document.getElementById("mdTitle").textContent = `CHI TIẾT ĐƠN HÀNG: #${order.id}`;
    
    const mdChan = document.getElementById("mdChannel");
    mdChan.textContent = `Kênh: ${order.channel}`;
    mdChan.style.background = channelColor;
    
    const mdWhName = document.getElementById("mdWarehouseName");
    mdWhName.textContent = order.warehouse || "Chưa chỉ định";
    
    // Info Columns
    document.getElementById("mdCustName").textContent = order.customerName || "-";
    document.getElementById("mdCustPhone").textContent = order.customerPhone || "-";
    document.getElementById("mdCustAddr").textContent = order.customerAddress || "-";
    
    document.getElementById("mdCarrierName").textContent = getShippingCarrierOfOrder(order);
    document.getElementById("mdTrackingNo").textContent = order.trackingNo || "Chưa cấp";
    document.getElementById("mdSyncTime").textContent = order.createdAt || "-";
    
    // Items & stock chéo
    const container = document.getElementById("mdProductList");
    let itemsHtml = "";
    
    if (order.items) {
        order.items.forEach(item => {
            const resolved = resolvePhysicalItems(item.sku, item.quantity);
            
            itemsHtml += `<div class="op-detail-item">
                <div class="op-detail-item-header">
                    <span class="op-detail-item-name">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:14px;height:14px"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path></svg>
                        ${item.name}
                    </span>
                    <span style="font-size:12px;color:rgba(16,55,92,.6);font-weight:600">SL đặt trên sàn: <strong style="color:var(--navy);font-size:14px">${item.quantity}</strong></span>
                </div>
                <div style="font-size:11px;color:rgba(16,55,92,.4);font-family:monospace;margin-bottom:8px">Mã SKU trên sàn: ${item.sku}</div>
                
                <div style="padding-left:12px;border-left:2px solid rgba(16,55,92,.1)">`;
            
            resolved.forEach(phy => {
                const totalStock = getWarehouseStock(phy.sku, "Kho Hà Nội") + getWarehouseStock(phy.sku, "Kho TP.HCM") + getWarehouseStock(phy.sku, "Kho Đà Nẵng");
                
                itemsHtml += `<div style="margin-bottom:12px">
                    <div style="display:flex;justify-content:between;align-items:center;margin-bottom:6px;font-size:12.5px">
                        <span style="display:flex;align-items:center;gap:4px">
                            <span style="font-size:9.5px;padding:2px 4px;font-weight:800;border-radius:3px;${phy.isComboSplit ? 'background:#fef3c7;color:#d97706' : 'background:#dbeafe;color:#2563eb'}">${phy.isComboSplit ? 'Combo quy đổi' : 'Sản phẩm đơn'}</span>
                            <strong>${phy.name || item.name}</strong>
                            <span style="font-family:monospace;font-size:11px;color:rgba(16,55,92,.4)">(${phy.sku})</span>
                        </span>
                        <span style="font-weight:700;margin-left:auto">SL quy đổi: <strong style="color:var(--orange)">${phy.quantity}</strong></span>
                    </div>
                    
                    <div class="op-stock-matrix">
                        <div class="op-stock-box ${totalStock > 0 ? 'enough' : 'empty'}">
                            <span class="op-stock-box-label">Tổng khả dụng</span>
                            <span class="op-stock-box-value">${totalStock} chiếc</span>
                        </div>`;
                        
                WAREHOUSES.forEach(wh => {
                    const qty = getWarehouseStock(phy.sku, wh.name);
                    const sufficient = qty >= phy.quantity;
                    let boxClass = "empty";
                    if (qty > 0) {
                        boxClass = sufficient ? "enough" : "warning";
                    }
                    
                    itemsHtml += `<div class="op-stock-box ${boxClass}">
                        <span class="op-stock-box-label">${wh.name}</span>
                        <span class="op-stock-box-value">
                            ${qty > 0 ? `${qty} chiếc` : 'Hết hàng'}
                            ${sufficient ? `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:12px;height:12px"><polyline points="20 6 9 17 4 12"></polyline></svg>` : ''}
                        </span>
                    </div>`;
                });
                
                itemsHtml += `</div></div>`;
            });
            
            itemsHtml += `</div></div>`;
        });
    }
    container.innerHTML = itemsHtml;
    
    // Timeline Action list
    const timeline = document.getElementById("mdTimeline");
    let timeHtml = "";
    
    // Dot Step 1: Synced
    timeHtml += `<div class="op-timeline-step">
        <div class="op-timeline-step-dot active-ok">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
        </div>
        <div class="op-timeline-title">Đơn hàng ghi nhận từ sàn (Order Synced)</div>
        <div class="op-timeline-desc">Đồng bộ thành công từ hệ thống kênh bán của ${order.channel}. Thời gian: ${order.createdAt}</div>
    </div>`;
    
    // Dot Step 2: Phê duyệt
    let dot2 = "inactive";
    let statusTitle = "Chờ phê duyệt và chỉ định kho (Duyệt tay)";
    let statusDesc = "Yêu cầu Sales Staff kiểm tra tồn kho chéo nhánh bên trên và chọn kho duyệt đơn";
    let dot2Icon = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>`;
    
    if (order.status !== "pending_review") {
        if (order.status === "cancelled") {
            dot2 = "active-err";
            statusTitle = "Đơn hàng bị từ chối / Hủy duyệt";
            statusDesc = `Từ chối bởi Sales Staff lúc ${order.updatedAt}. Ghi chú: ${order.reviewNote || "Không có lý do"}`;
            dot2Icon = `&times;`;
        } else {
            dot2 = "active-ok";
            statusTitle = `Đã duyệt & Phân bổ tồn kho tại ${order.warehouse || "Kho xuất hàng"}`;
            statusDesc = `Phê duyệt bởi Sales Staff lúc ${order.updatedAt}. Ghi chú: ${order.reviewNote || "Tự động phân bổ tồn kho thành công"}`;
            dot2Icon = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>`;
        }
    }
    
    timeHtml += `<div class="op-timeline-step">
        <div class="op-timeline-step-dot ${dot2}">${dot2Icon}</div>
        <div class="op-timeline-title ${order.status === 'cancelled' ? 'error' : ''}">${statusTitle}</div>
        <div class="op-timeline-desc">${statusDesc}</div>
    </div>`;
    
    // Dot Step 3: Đóng gói
    if (order.status !== "cancelled") {
        let dot3 = "inactive";
        let title3 = "Đóng gói hàng hóa (Pick & Pack)";
        let desc3 = "Chờ duyệt đơn để chuyển lệnh xuống kho";
        let dot3Icon = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>`;
        
        if (order.status === "confirmed") {
            dot3 = "active-warn";
            desc3 = "Đang chờ nhân viên kho nhặt hàng và đóng gói tem in";
        } else if (["packing", "packed", "shipping", "delivered", "completed", "returned", "disputed", "dispute_success"].indexOf(order.status) > -1) {
            dot3 = "active-ok";
            desc3 = `Đóng gói hoàn tất lúc ${order.updatedAt} tại ${order.warehouse}`;
            dot3Icon = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>`;
        }
        
        timeHtml += `<div class="op-timeline-step">
            <div class="op-timeline-step-dot ${dot3}">${dot3Icon}</div>
            <div class="op-timeline-title">${title3}</div>
            <div class="op-timeline-desc">${desc3}</div>
        </div>`;
    }
    
    // Dot Step 4: Giao hàng
    if (order.status !== "cancelled") {
        let dot4 = "inactive";
        let title4 = "Vận chuyển & Bàn giao";
        let desc4 = "Chờ đóng gói xong bàn giao vận chuyển";
        let dot4Icon = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>`;
        
        if (order.status === "shipping") {
            dot4 = "active-warn";
            title4 = "Đang giao hàng";
            desc4 = `Đơn vị vận chuyển đang phát hàng đến tay khách hàng. Mã vận đơn: ${order.trackingNo}`;
        } else if (order.status === "delivered") {
            dot4 = "active-warn";
            title4 = "Giao hàng thành công (Đang chờ đối soát ví)";
            desc4 = `Đơn hàng đã được bưu tá phát thành công. Đang chờ hết thời hạn 3 ngày khiếu nại.`;
            dot4Icon = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>`;
            
            // Render Webhook countdown indicator
            if (countdownOrderId === order.id && webhookCountdown !== null) {
                desc4 += `<div style="margin-top:6px;padding:6px;background:#fef3c7;border:1px solid #fcd34d;border-radius:4px;color:#b45309;font-weight:700;display:inline-block;animation:pulse 1s infinite">
                    [GIẢ LẬP WEBHOOK] Hệ thống đang đếm ngược (giả lập 3 ngày thành ${webhookCountdown}s) để chuyển trạng thái sang [Hoàn thành]...
                </div>`;
            }
        } else if (order.status === "completed") {
            dot4 = "active-ok";
            title4 = "Đơn hàng hoàn thành (Đã đối soát)";
            desc4 = `Đơn hàng chính thức hoàn thành. Tiền đã giải ngân thành công vào ví bán hàng của doanh nghiệp.`;
            dot4Icon = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>`;
        } else if (["returned", "disputed", "dispute_success"].indexOf(order.status) > -1) {
            dot4 = "active-err";
            title4 = "Đơn hàng bị hoàn trả (Return & Refund)";
            desc4 = `Hàng hoàn đã trả về kho. Trạng thái: "${order.rmaPhysicalStatus || 'Đã nhập Zone Khiếu Nại'}". Lý do: "${order.rmaReason || 'Chưa rõ lý do'}"`;
            dot4Icon = `&times;`;
        }
        
        timeHtml += `<div class="op-timeline-step">
            <div class="op-timeline-step-dot ${dot4}">${dot4Icon}</div>
            <div class="op-timeline-title">${title4}</div>
            <div class="op-timeline-desc">${desc4}</div>
        </div>`;
    }
    
    // Dot Step 5: RMA Dispute (Only for RMA/Disputed orders)
    if (order.status === "disputed" || order.status === "dispute_success") {
        timeHtml += `<div class="op-timeline-step">
            <div class="op-timeline-step-dot active-ok">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
            </div>
            <div class="op-timeline-title">Đã gửi hồ sơ khiếu nại lên Sàn</div>
            <div class="op-timeline-desc">Shop trích xuất video CCTCC đóng gói và gửi nội dung khiếu nại thành công.</div>
        </div>`;
    }
    if (order.status === "dispute_success") {
        timeHtml += `<div class="op-timeline-step">
            <div class="op-timeline-step-dot active-ok">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
            </div>
            <div class="op-timeline-title" style="color:#047857">Khiếu nại thành công (Sàn đền bù 100%)</div>
            <div class="op-timeline-desc">Sàn đối soát video và xác định lỗi do đơn vị vận chuyển. Tiền đền bù đã cộng vào ví người bán.</div>
        </div>`;
    }
    
    // Realtime Webhook Logs (if any)
    if (order.webhookEvents && order.webhookEvents.length > 0) {
        timeHtml += `<div style="border-top:1px solid #E5EAF3;padding-top:12px;margin-top:16px">
            <div style="font-size:10px;font-weight:900;color:rgba(16,55,92,.4);text-transform:uppercase;margin-bottom:8px;display:flex;align-items:center;gap:6px">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:12px;height:12px;color:#2563eb"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg>
                Nhật ký hành trình ĐVVC (Real-time Webhook Logs)
            </div>
            <div style="display:flex;flex-direction:column;gap:8px">`;
            
        order.webhookEvents.forEach(evt => {
            timeHtml += `<div style="font-size:11px;background:var(--alice);border:1px solid rgba(16,55,92,.05);padding:8px;border-radius:4px;display:flex;gap:8px">
                <div style="width:6px;height:6px;border-radius:50%;background:#2563eb;margin-top:5px;flex-shrink:0;animation:pulse 1s infinite"></div>
                <div style="flex:1">
                    <div style="display:flex;justify-content:between">
                        <strong>${evt.eventName}</strong>
                        <span style="font-family:monospace;font-size:10px;color:rgba(16,55,92,.4);margin-left:auto">${evt.time}</span>
                    </div>
                    <p style="font-size:10.5px;color:rgba(16,55,92,.6);margin-top:2px">${evt.description}</p>
                </div>
            </div>`;
        });
        
        timeHtml += `</div></div>`;
    }
    
    timeline.innerHTML = timeHtml;
    
    // Part 4: Dynamic Action Panel
    const actionContainer = document.getElementById("mdActionPanelContainer");
    let actionHtml = "";
    
    if (order.status === "pending_review") {
        actionHtml += `<div class="op-action-box">
            <div class="op-action-title" style="color:#dc2626">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:18px;height:18px"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
                Hành động: Phê duyệt đơn hàng &amp; Chỉ định kho vận hành
            </div>
            <div class="op-action-grid">
                <div>
                    <label class="op-field-label">Chọn Chi nhánh Kho xuất hàng *</label>
                    <select class="op-select" id="actSelectWarehouse">
                        <option value="">-- Chọn kho xuất hàng --</option>`;
                        
        WAREHOUSES.forEach(w => {
            // Check if sufficient stock for ALL items in order
            let sufficient = true;
            if (order.items) {
                order.items.forEach(i => {
                    const resolvedItems = resolvePhysicalItems(i.sku, i.quantity);
                    resolvedItems.forEach(phy => {
                        if (getWarehouseStock(phy.sku, w.name) < phy.quantity) {
                            sufficient = false;
                        }
                    });
                });
            }
            actionHtml += `<option value="${w.name}">${w.name} ${sufficient ? '(Đủ hàng)' : '(Thiếu hàng)'}</option>`;
        });
        
        actionHtml += `</select>
                </div>
                <div>
                    <label class="op-field-label">Ghi chú phê duyệt / Từ chối lý do</label>
                    <input type="text" class="op-input" placeholder="Ví dụ: Đã gọi điện xác nhận..." id="actReviewNote" />
                </div>
            </div>
            <div style="display:flex;justify-content:flex-end;gap:10px">
                <button class="op-btn danger" onclick="submitApprove(false)">[ TỪ CHỐI ĐƠN ]</button>
                <button class="op-btn success" onclick="submitApprove(true)">[ DUYỆT ĐƠN &amp; PHÂN BỔ KHO ]</button>
            </div>
        </div>`;
    } else if (order.status === "shipping" || order.status === "delivered" || order.status === "packed") {
        // Render Webhook Simulator Actions
        actionHtml += `<div class="op-action-box rma" style="border-color:#2563eb;background:rgba(37,99,235,.02)">
            <div class="op-action-title" style="color:#2563eb">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:18px;height:18px"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
                Trình giả lập hành trình đơn vị vận chuyển (Webhook Simulator)
            </div>
            <p style="font-size:12px;color:rgba(16,55,92,.6);margin-bottom:1rem">Mô phỏng bưu tá của ĐVVC truyền tín hiệu Webhook về hệ thống OmniCore</p>
            <div style="display:flex;flex-wrap:wrap;gap:8px">`;
            
        if (order.status === "packed") {
            actionHtml += `<button class="op-btn" style="background:#2563eb;color:#fff" onclick="triggerWebhook('${order.id}', 'pickup')">Shipper đã lấy hàng (Pickup API)</button>`;
        } else if (order.status === "shipping") {
            actionHtml += `<button class="op-btn" style="background:#2563eb;color:#fff" onclick="triggerWebhook('${order.id}', 'transit')">Đang giao hàng (Transit API)</button>
            <button class="op-btn success" onclick="triggerWebhook('${order.id}', 'delivered')">Giao thành công (Delivered API)</button>
            <button class="op-btn danger" onclick="triggerWebhook('${order.id}', 'return')">Khách trả hàng quay đầu (Return API)</button>`;
        } else if (order.status === "delivered") {
            actionHtml += `<span style="font-size:12.5px;font-weight:700;color:#059669;display:flex;align-items:center;gap:6px">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:16px;height:16px"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                Giao hàng thành công. Bạn có thể click giả lập trả hàng nếu khách khiếu nại trong 3 ngày:
            </span>
            <button class="op-btn danger" onclick="triggerWebhook('${order.id}', 'return')" style="margin-left:8px">Khách trả hàng (RMA Return)</button>`;
        }
        
        actionHtml += `</div>
        </div>`;
    } else if (order.rmaPhysicalStatus === "Đã nhập Zone Khiếu Nại") {
        // RMA Dispute form
        actionHtml += `<div class="op-action-box rma">
            <div class="op-action-title" style="color:#d97706">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:18px;height:18px"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                Hồ Sơ Khiếu Nại RMA với Sàn TMĐT (Dispute Platform RMA)
            </div>
            <div class="op-info-grid" style="margin-bottom:12px">
                <div style="background:#fff;border:1px solid #E5EAF3;padding:12px;border-radius:4px">
                    <span style="font-size:11px;font-weight:700;color:rgba(16,55,92,.4);text-transform:uppercase;border-bottom:1px solid #F0F3FA;padding-bottom:4px;display:block;margin-bottom:8px">1. Minh chứng từ Khách hàng</span>
                    <div style="font-size:12.5px">
                        <strong>Lý do trả hàng:</strong>
                        <p style="margin-top:4px;color:rgba(16,55,92,.8)">${order.rmaReason || 'Chưa có'}</p>
                        ${order.rmaCustomerImages && order.rmaCustomerImages.length > 0 ? `
                            <div style="display:flex;gap:8px;margin-top:8px">
                                ${order.rmaCustomerImages.map(img => `<img src="${img}" style="width:72px;height:72px;object-fit:cover;border:1px solid #E5EAF3;border-radius:3px" />`).join('')}
                            </div>
                        ` : ''}
                    </div>
                </div>
                <div style="background:#fff;border:1px solid #E5EAF3;padding:12px;border-radius:4px" id="mdDisputeShopPanel">
                    <span style="font-size:11px;font-weight:700;color:rgba(16,55,92,.4);text-transform:uppercase;border-bottom:1px solid #F0F3FA;padding-bottom:4px;display:block;margin-bottom:8px">2. Hồ sơ khiếu nại của Shop (Video đóng gói)</span>`;
                    
        if (order.status === "returned") {
            actionHtml += `<div style="display:flex;flex-direction:column;gap:8px">
                <div>
                    <label class="op-field-label">Tải lên bằng chứng video đóng gói (Video Packing) *</label>
                    <div style="display:flex;gap:6px">
                        <input type="text" class="op-input" id="inpDisputeVideo" placeholder="Chưa chọn tệp video..." readonly style="background:#f3f4f6;flex:1"/>
                        <button class="op-btn primary" onclick="simulateVideoUpload()" style="padding:0.4rem 1rem">Tải Video</button>
                    </div>
                    <span style="font-size:9.5px;color:rgba(16,55,92,.4);margin-top:2px;display:block">* Trích xuất CCTCV tại bàn đóng gói của Warehouse Staff để làm bằng chứng gửi sàn.</span>
                </div>
                <div>
                    <label class="op-field-label">Nội dung khiếu nại *</label>
                    <textarea class="op-input" id="inpDisputeNote" rows="2" placeholder="VD: Shop đóng bọc xốp bóng khí 3 lớp đầy đủ, lỗi nứt vỡ do vận chuyển quăng quật..."></textarea>
                </div>
                <div style="display:flex;justify-content:flex-end;margin-top:4px">
                    <button class="op-btn warning" onclick="submitRMADispute('${order.id}')">[ GỬI KHIẾU NẠI LÊN SÀN ]</button>
                </div>
            </div>`;
        } else {
            actionHtml += `<div style="font-size:12.5px;display:flex;flex-direction:column;gap:8px">
                <div>
                    <span style="color:rgba(16,55,92,.5)">Tệp video bằng chứng:</span>
                    <div style="background:#ecfdf5;color:#047857;padding:6px;border:1px solid #a7f3d0;border-radius:4px;font-weight:700;display:flex;align-items:center;gap:4px;margin-top:4px">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:14px;height:14px"><polyline points="20 6 9 17 4 12"></polyline></svg>
                        ${order.disputeEvidenceVideo || 'cctv_packing_proof.mp4'}
                    </div>
                </div>
                <div>
                    <span style="color:rgba(16,55,92,.5)">Nội dung khiếu nại đã gửi:</span>
                    <p style="background:var(--alice);padding:6px;border:1px solid #E5EAF3;border-radius:4px;font-style:italic;margin-top:4px;font-weight:600">"${order.disputeNote || ''}"</p>
                </div>
                <div style="border-top:1px solid #F0F3FA;padding-top:6px;margin-top:4px">
                    <span style="color:rgba(16,55,92,.5)">Trạng thái Sàn:</span>
                    ${order.status === 'dispute_success' ? `
                        <div style="color:#047857;font-weight:700;display:flex;align-items:center;gap:4px;margin-top:2px">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:14px;height:14px"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                            KHIẾU NẠI THÀNH CÔNG — Sàn đã hoàn trả tiền đền bù
                        </div>
                    ` : `
                        <div style="color:#1d4ed8;font-weight:700;display:flex;align-items:center;gap:4px;margin-top:2px">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:14px;height:14px"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                            ĐANG XỬ LÝ KHIẾU NẠI — Sàn đang đối soát bằng chứng video
                        </div>
                    `}
                </div>
            </div>`;
        }
        
        actionHtml += `</div>
            </div>
        </div>`;
    }
    
    actionContainer.innerHTML = actionHtml;
}

function submitApprove(approve) {
    if (!activeDetailOrder) return;
    
    const note = document.getElementById("actReviewNote").value.trim();
    const whSelect = document.getElementById("actSelectWarehouse");
    const wh = whSelect ? whSelect.value : "";
    
    if (approve && !wh) {
        alert("Vui lòng chọn Kho xuất hàng để duyệt!");
        return;
    }
    
    isSubmitting = true;
    
    setTimeout(() => {
        allOrders = allOrders.map(o => {
            if (o.id === activeDetailOrder.id) {
                if (approve) {
                    o.status = "confirmed";
                    o.warehouse = wh;
                    o.reviewedBy = "${loggedInUser.fullName}";
                    o.reviewNote = note || "Phê duyệt đơn hàng thành công và bàn giao chỉ định kho.";
                    o.qtyAllocated = true;
                } else {
                    o.status = "cancelled";
                    o.reviewedBy = "${loggedInUser.fullName}";
                    o.reviewNote = note || "Từ chối duyệt đơn do phát hiện dấu hiệu gian lận hoặc thiếu thông tin.";
                    o.qtyAllocated = false;
                }
                o.updatedAt = new Date().toLocaleString("sv-SE").replace("T", " ").slice(0, 16);
            }
            return o;
        });
        
        saveOrdersToStorage();
        isSubmitting = false;
        closeDetailModal();
        renderAll();
        showToast(approve ? "Đã duyệt đơn và chuyển giao việc kho thành công!" : "Đã từ chối đơn hàng thành công!", "success");
    }, 600);
}

// RMA Video upload simulations
function simulateVideoUpload() {
    const vids = [
        "cctv_pack_camera_3_line2_shp_123.mp4",
        "packing_evidence_operator_ha.mov",
        "shipper_handover_cctv_backyard.mp4",
        "cctv_shopee_packing_line5_operator_binh.mp4"
    ];
    const rand = vids[Math.floor(Math.random() * vids.length)];
    const inp = document.getElementById("inpDisputeVideo");
    if (inp) inp.value = rand;
}

function submitRMADispute(orderId) {
    const video = document.getElementById("inpDisputeVideo").value;
    const note = document.getElementById("inpDisputeNote").value.trim();
    
    if (!video || video.indexOf("Chưa chọn") > -1) {
        alert("Vui lòng tải lên video bằng chứng đóng gói để đối soát!");
        return;
    }
    if (!note) {
        alert("Vui lòng nhập nội dung khiếu nại để gửi lên Sàn!");
        return;
    }
    
    isSubmittingDispute = true;
    
    setTimeout(() => {
        const nowStr = new Date().toLocaleString("sv-SE").replace("T", " ").slice(0, 16);
        allOrders = allOrders.map(o => {
            if (o.id === orderId) {
                o.status = "dispute_success";
                o.disputeEvidenceVideo = video;
                o.disputeNote = note;
                o.rmaPlatformStatus = "Đã bồi thường";
                o.updatedAt = nowStr;
                if (!o.webhookEvents) o.webhookEvents = [];
                
                o.webhookEvents.push({
                    time: nowStr,
                    eventName: "Khiếu nại RMA lên Sàn",
                    description: `Shop gửi khiếu nại lên sàn kèm video bằng chứng: ${video}. Nội dung: "${note}"`
                });
                o.webhookEvents.push({
                    time: nowStr,
                    eventName: "Khiếu nại thành công (Sàn hoàn tiền)",
                    description: "Sàn TMĐT đối soát bằng chứng video đóng gói của Shop và xác nhận lỗi do ĐVVC quăng quật gây hư hỏng. Sàn đã duyệt đền bù 100%."
                });
            }
            return o;
        });
        
        saveOrdersToStorage();
        isSubmittingDispute = false;
        closeDetailModal();
        renderAll();
        showToast("Gửi hồ sơ khiếu nại thành công! Sàn đã duyệt đền bù 100% tiền hàng.", "success");
    }, 1200);
}

// ── MERGED A6 THERMAL SHIPPING LABELS PRINT PREVIEW MODAL ──
function openPrintModal() {
    isGeneratingPDF = true;
    renderStickyBar();
    
    setTimeout(() => {
        isGeneratingPDF = false;
        renderStickyBar();
        
        // Build label previews
        const body = document.getElementById("printModalBody");
        let html = `<div class="op-labels-grid">`;
        
        selectedBatchIds.forEach((id, idx) => {
            const order = allOrders.find(o => o.id === id);
            if (!order) return;
            
            const carrier = getShippingCarrierOfOrder(order);
            
            html += `<div class="op-label-a6">
                <%-- Top bar --%>
                <div class="op-label-top">
                    <span class="op-label-carrier">${carrier}</span>
                    <div class="op-label-barcode">
                        <div class="barcode-lines">
                            <div style="width: 2px"></div>
                            <div style="width: 4px"></div>
                            <div style="width: 1px"></div>
                            <div style="width: 2px"></div>
                            <div style="width: 5px"></div>
                            <div style="width: 1px"></div>
                            <div style="width: 3px"></div>
                            <div style="width: 2px"></div>
                            <div style="width: 4px"></div>
                            <div style="width: 1px"></div>
                            <div style="width: 2px"></div>
                            <div style="width: 5px"></div>
                            <div style="width: 1px"></div>
                            <div style="width: 2px"></div>
                            <div style="width: 1px"></div>
                        </div>
                        <span style="font-size:9.5px;font-family:monospace;font-weight:700;margin-top:2px">${order.trackingNo}</span>
                    </div>
                </div>
                
                <%-- Shipping details --%>
                <div class="op-label-info-grid">
                    <div class="op-label-info-col border-r">
                        <span style="font-size:8px;font-weight:800;color:rgba(16,55,92,.4);display:block">TỪ:</span>
                        <strong style="font-size:11px;display:block">OMNICORE ERP STORE</strong>
                        <span style="display:block;margin-top:2px;font-weight:700">Kho 1 - Hà Nội</span>
                        <span style="display:block;font-size:9.5px">Hotline: 1900-5678</span>
                    </div>
                    <div class="op-label-info-col" style="padding-left:4px">
                        <span style="font-size:8px;font-weight:800;color:rgba(16,55,92,.4);display:block">ĐẾN:</span>
                        <strong style="font-size:11px;display:block">${order.customerName}</strong>
                        <span style="display:block;font-weight:700;margin-top:2px">${order.customerPhone}</span>
                        <span style="display:block;font-size:10px;line-height:1.2;margin-top:2px">${order.customerAddress}</span>
                    </div>
                </div>
                
                <%-- Middle details --%>
                <div class="op-label-middle">
                    <div style="display:flex;flex-direction:column;gap:2px">
                        <div>Mã đơn sàn: <strong style="font-family:monospace;font-size:11.5px">${order.id}</strong></div>
                        <div>Kênh bán: <strong>${order.channel}</strong></div>
                        <div>Ngày đồng bộ: <span style="font-family:monospace">${order.createdAt}</span></div>
                        <div style="margin-top:3px;background:var(--alice);border:1px solid #E5EAF3;padding:2px 4px;font-size:8.5px;border-radius:3px;font-weight:700">Hình thức: THANH TOÁN KHI NHẬN HÀNG (COD)</div>
                    </div>
                    
                    <%-- QR Code --%>
                    <div class="op-label-qr">`;
                    
            for (let qi = 0; qi < 64; qi++) {
                html += `<div style="background:${Math.random() > 0.45 ? 'var(--navy)' : '#fff'}"></div>`;
            }
                    
            html += `</div>
                </div>
                
                <%-- Bottom Picking list --%>
                <div class="op-label-bottom">
                    <div>
                        <div class="op-label-picking-title">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:11px;height:11px"><rect x="2" y="2" width="20" height="8" rx="2" ry="2"></rect><rect x="2" y="14" width="20" height="8" rx="2" ry="2"></rect><line x1="6" y1="6" x2="6.01" y2="6"></line><line x1="6" y1="18" x2="6.01" y2="18"></line></svg>
                            Danh sách nhặt hàng (Warehouse Picking List)
                        </div>
                        <table class="op-label-picking-table">
                            <thead>
                                <tr style="border-bottom:1px solid rgba(16,55,92,.1);font-size:8.5px;color:rgba(16,55,92,.4)">
                                    <th style="text-align:left;padding-bottom:2px">Sản phẩm (Master SKU)</th>
                                    <th style="text-align:right;padding-bottom:2px">SL</th>
                                </tr>
                            </thead>
                            <tbody>`;
                            
            if (order.items) {
                order.items.forEach(item => {
                    const resolved = resolvePhysicalItems(item.sku, item.quantity);
                    resolved.forEach(phy => {
                        html += `<tr>
                            <td style="padding:3px 0">
                                <div>${phy.name || item.name}</div>
                                <div style="font-family:monospace;font-size:9.5px;color:rgba(16,55,92,.4)">(${phy.sku})</div>
                            </td>
                            <td class="qty-col">${phy.quantity}</td>
                        </tr>`;
                    });
                });
            }
                            
            html += `</tbody>
                        </table>
                    </div>
                    
                    <%-- Page marker footer --%>
                    <div class="op-label-marker">Trang ${idx + 1} / ${selectedBatchIds.length} — TEM IN VẬN ĐƠN NỘI BỘ</div>
                </div>
            </div>`;
        });
        
        html += `</div>`;
        body.innerHTML = html;
        
        document.getElementById("lblPrintLabelsCount").textContent = selectedBatchIds.length;
        document.getElementById("opPrintModalOverlay").classList.add("open");
    }, 1200);
}

function closePrintModal() {
    document.getElementById("opPrintModalOverlay").classList.remove("open");
}

function executeSimulatedPrint() {
    const btn = document.getElementById("btnExecutePrint");
    btn.disabled = true;
    btn.textContent = "Đang gửi lệnh in...";
    
    setTimeout(() => {
        allOrders = allOrders.map(o => {
            if (selectedBatchIds.indexOf(o.id) > -1) {
                o.status = "packing";
                o.updatedAt = new Date().toLocaleString("sv-SE").replace("T", " ").slice(0, 16);
            }
            return o;
        });
        
        saveOrdersToStorage();
        btn.disabled = false;
        btn.textContent = "Tiến hành in tem vật lý";
        
        closePrintModal();
        selectedBatchIds = [];
        renderAll();
        showToast("Đã gửi lệnh in tem hàng loạt xuống kho! Trạng thái chuyển sang [Đang đóng gói]", "success");
    }, 1200);
}
</script>
