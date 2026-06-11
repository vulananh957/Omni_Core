<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- ══════════════════════════════════════════════════════════════════
     Sales Staff — Trung Tâm Ánh Xạ SKU Đa Sàn (SKU Mapping Center)
     JSP port of React: SKUMapping.tsx
     All logic is pure vanilla JS — no hardcoded data, no seed data.
     ══════════════════════════════════════════════════════════════════ --%>

<style>
/* ── Page-scoped styles mirroring React SKUMapping ────────── */

/* Stats cards grid */
.sm-stats-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 1rem;
    margin-bottom: 1.5rem;
}
@media (max-width: 768px) {
    .sm-stats-grid { grid-template-columns: 1fr; }
}

.sm-stat-card {
    background: #fff;
    border: 1px solid #E5EAF3;
    padding: 1.25rem;
    border-radius: var(--radius-card);
    display: flex;
    align-items: center;
    gap: 1rem;
    transition: all .2s ease;
}
.sm-stat-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 25px rgba(16,55,92,.05);
}
.sm-stat-icon-wrapper {
    width: 48px;
    height: 48px;
    border-radius: var(--radius-btn);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}
.sm-stat-icon-wrapper.blue { background: rgba(16,55,92,.1); color: var(--navy); }
.sm-stat-icon-wrapper.orange { background: rgba(245,158,11,.15); color: #d97706; }
.sm-stat-icon-wrapper.emerald { background: rgba(16,185,129,.1); color: #059669; }
.sm-stat-icon-wrapper svg { width: 22px; height: 22px; }

.sm-stat-num { font-size: 24px; font-weight: 800; color: var(--navy); line-height: 1.2; }
.sm-stat-label { font-size: 12px; color: rgba(16,55,92,.5); font-weight: 600; margin-top: 2px; }

/* Tabs Bar */
.sm-tab-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid #E5EAF3;
    margin-bottom: 1.25rem;
    flex-wrap: wrap;
    gap: 1rem;
}
.sm-tab-buttons { display: flex; overflow-x: auto; white-space: nowrap; }
.sm-tab-buttons::-webkit-scrollbar { height: 0; }

.sm-tab {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.75rem 1.25rem;
    font-size: 13px;
    font-weight: 700;
    border-bottom: 2px solid transparent;
    background: none;
    border-top: none;
    border-left: none;
    border-right: none;
    cursor: pointer;
    transition: all .15s;
    color: rgba(16,55,92,.4);
    white-space: nowrap;
}
.sm-tab:hover { color: var(--navy); }
.sm-tab.active { color: var(--navy); border-bottom-color: var(--navy); font-weight: 800; }

.sm-tab-badge {
    display: inline-block;
    padding: 0.125rem 0.4rem;
    font-size: 10px;
    font-weight: 700;
    border-radius: 9999px;
    background: var(--orange);
    color: #fff;
}

/* Pull sandbox button */
.sm-btn-pull {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    background: var(--navy);
    color: #fff;
    font-size: 12px;
    font-weight: 700;
    border: none;
    cursor: pointer;
    border-radius: var(--radius-btn);
    transition: background .15s;
    margin-bottom: 6px;
}
.sm-btn-pull:hover { background: rgba(16,55,92,.9); }
.sm-btn-pull svg { width: 14px; height: 14px; }
.sm-btn-pull:disabled { opacity: 0.6; cursor: not-allowed; }

/* Filter bar */
.sm-filter-bar {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin-bottom: 1rem;
}
.sm-search {
    position: relative;
    width: 100%;
    max-width: 320px;
}
.sm-search-icon {
    position: absolute;
    left: 0.75rem;
    top: 50%;
    transform: translateY(-50%);
    width: 16px;
    height: 16px;
    color: rgba(16,55,92,.3);
    pointer-events: none;
}
.sm-search input {
    width: 100%;
    padding: 0.5rem 1rem 0.5rem 2.25rem;
    background: #fff;
    border: 1px solid #E5EAF3;
    font-size: 13px;
    color: var(--navy);
    border-radius: calc(var(--radius-btn) - 2px);
    outline: none;
    transition: border-color .15s;
}
.sm-search input:focus { border-color: rgba(16,55,92,.3); }
.sm-search input::placeholder { color: rgba(16,55,92,.3); }

/* Table container */
.sm-table-card {
    background: #fff;
    border: 1px solid #E5EAF3;
    border-radius: var(--radius-card);
    overflow: hidden;
    position: relative;
}
.sm-table-scroll { overflow-x: auto; }
.sm-table { width: 100%; border-collapse: collapse; text-align: left; }
.sm-table th {
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
.sm-table td {
    padding: 0.875rem 1.25rem;
    border-bottom: 1px solid #F0F3FA;
    font-size: 13px;
    color: var(--navy);
    vertical-align: middle;
}
.sm-table tr:hover { background: rgba(240,245,255,.3); }

/* Pull loader overlay */
.sm-pull-overlay {
    position: absolute;
    inset: 0;
    background: rgba(255,255,255,.85);
    backdrop-filter: blur(4px);
    z-index: 10;
    display: none;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 2rem;
    transition: opacity 0.25s ease;
}
.sm-pull-overlay.open { display: flex; }
.sm-loader-spinner {
    width: 40px; height: 40px;
    border: 4px solid var(--alice);
    border-top: 4px solid var(--navy);
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin-bottom: 0.75rem;
}
@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }

/* Table badges */
.sm-badge-channel {
    color: #fff;
    border-radius: 4px;
    font-weight: 700;
    font-size: 11px;
    padding: 0.25rem 0.5rem;
    display: inline-block;
}

/* Sync status badge variants */
.sm-badge-sync {
    color: #fff;
    border-radius: 4px;
    font-weight: 700;
    font-size: 11px;
    padding: 0.25rem 0.5rem;
    display: inline-block;
}
.sm-badge-sync.synced  { background: #059669; }
.sm-badge-sync.error   { background: #dc2626; }
.sm-badge-sync.pending { background: #d97706; }

/* Mapped channel pills with hoverable delete cross */
.sm-mapped-pill {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: rgba(240,244,250,0.8);
    border: 1px solid rgba(16,55,92,0.08);
    padding: 4px 8px;
    border-radius: 6px;
    font-size: 11px;
    font-weight: 600;
    transition: all 0.15s ease;
    color: var(--navy);
}
.sm-mapped-pill:hover {
    background: #fee2e2;
    border-color: #fca5a5;
    color: #dc2626;
}
.sm-mapped-sku {
    font-family: monospace;
    font-weight: 700;
}
.sm-unlink-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 14px;
    height: 14px;
    border-radius: 50%;
    color: rgba(16,55,92,0.3);
    cursor: pointer;
    transition: all 0.15s;
    font-size: 10px;
    line-height: 1;
}
.sm-mapped-pill:hover .sm-unlink-btn {
    color: #dc2626;
    background: rgba(220,38,38,0.1);
}
.sm-conversion-tag {
    font-size: 9px;
    background: rgba(245,158,11,.1);
    color: #d97706;
    padding: 1px 4px;
    font-weight: 700;
    border-radius: 3px;
}

.sm-btn-action {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 0.4rem 0.75rem;
    background: var(--navy);
    color: #fff;
    font-size: 12px;
    font-weight: 700;
    border: none;
    cursor: pointer;
    border-radius: calc(var(--radius-btn) - 4px);
    transition: background .15s;
}
.sm-btn-action:hover { background: rgba(16,55,92,.85); }
.sm-btn-action svg { width: 13px; height: 13px; }

/* Modals overlays */
.sm-modal-overlay {
    position: fixed;
    inset: 0;
    background: rgba(16,55,92,.4);
    backdrop-filter: blur(4px);
    z-index: 100;
    display: none;
    align-items: center;
    justify-content: center;
    padding: 1.5rem;
}
.sm-modal-overlay.open { display: flex; }

.sm-modal {
    width: 100%;
    max-width: 500px;
    background: #fff;
    box-shadow: 0 25px 50px -12px rgba(16,55,92,.25);
    border-radius: var(--radius-card);
    overflow: hidden;
    display: flex;
    flex-direction: column;
}
.sm-modal-header {
    background: rgba(240,245,255,.3);
    border-bottom: 1px solid #F0F3FA;
    padding: 1rem 1.5rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
}
.sm-modal-title {
    font-size: 14px;
    font-weight: 900;
    text-transform: uppercase;
    color: var(--navy);
    letter-spacing: .02em;
    display: flex;
    align-items: center;
    gap: 8px;
}
.sm-modal-title svg { width: 18px; height: 18px; color: var(--navy); }
.sm-modal-close {
    width: 32px; height: 32px;
    border-radius: 50%;
    border: none;
    background: none;
    color: rgba(16,55,92,.4);
    cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    transition: all .15s;
}
.sm-modal-close:hover { background: var(--alice); color: var(--navy); }

.sm-modal-body {
    padding: 1.5rem;
    overflow-y: auto;
    max-height: 70vh;
    display: flex;
    flex-direction: column;
    gap: 1.25rem;
}
.sm-modal-footer {
    padding: 1rem 1.5rem;
    background: rgba(240,245,255,.3);
    border-top: 1px solid #F0F3FA;
    display: flex;
    justify-content: flex-end;
    gap: 0.5rem;
}

/* Modal channel info box */
.sm-channel-box {
    background: rgba(240,245,255,.6);
    border: 1px solid #E5EAF3;
    padding: 1rem;
    border-radius: 8px;
}
.sm-channel-box-title {
    font-size: 11px;
    font-weight: 700;
    color: rgba(16,55,92,.6);
    text-transform: uppercase;
    letter-spacing: .04em;
    margin-bottom: 8px;
}

/* Modal relational forms lists */
.sm-mapping-section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid #F0F3FA;
    padding-bottom: 6px;
    margin-bottom: 8px;
}
.sm-mapping-section-title {
    font-size: 11px;
    font-weight: 700;
    color: rgba(16,55,92,.6);
    text-transform: uppercase;
    letter-spacing: .04em;
}
.sm-btn-add-row {
    background: var(--alice);
    color: var(--navy);
    font-size: 11.5px;
    font-weight: 700;
    padding: 3px 8px;
    border: none;
    cursor: pointer;
    border-radius: 4px;
    display: flex;
    align-items: center;
    gap: 4px;
    transition: all .15s;
}
.sm-btn-add-row:hover { background: rgba(16,55,92,.1); }
.sm-btn-add-row svg { width: 12px; height: 12px; }

.sm-row-card {
    background: rgba(240,245,255,.35);
    border: 1px solid #E5EAF3;
    padding: 0.75rem;
    border-radius: 8px;
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 8px;
}
.sm-row-card:last-child { margin-bottom: 0; }
.sm-field-label { display: block; font-size: 10px; color: rgba(16,55,92,.4); margin-bottom: 3px; font-weight: 700; text-transform: uppercase; }
.sm-select {
    width: 100%;
    padding: 4px 6px;
    border: 1px solid #E5EAF3;
    background: #fff;
    color: var(--navy);
    font-size: 12.5px;
    font-weight: 600;
    border-radius: 4px;
    outline: none;
}
.sm-input {
    width: 100%;
    padding: 4px 6px;
    border: 1px solid #E5EAF3;
    background: #fff;
    color: var(--navy);
    font-size: 12.5px;
    font-weight: 700;
    text-align: center;
    border-radius: 4px;
    outline: none;
}
.sm-btn-remove {
    width: 28px; height: 28px;
    border-radius: 4px;
    background: #fef2f2;
    color: #ef4444;
    border: none;
    cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    transition: all .15s;
}
.sm-btn-remove:hover { background: #ef4444; color: #fff; }
.sm-btn-remove svg { width: 14px; height: 14px; }

/* General button */
.sm-btn {
    padding: 0.5rem 1rem;
    font-size: 13px;
    font-weight: 700;
    border-radius: calc(var(--radius-btn) - 2px);
    cursor: pointer;
    border: 1px solid transparent;
    transition: all .15s;
}
.sm-btn.primary { background: var(--navy); color: #fff; }
.sm-btn.primary:hover { background: rgba(16,55,92,.9); }
.sm-btn.white { background: #fff; border-color: #E5EAF3; color: rgba(16,55,92,.7); }
.sm-btn.white:hover { background: var(--alice); color: var(--navy); }

.op-empty {
    text-align: center !important;
    padding: 4rem 2rem !important;
    color: rgba(16,55,92,.4);
    font-size: 14px;
}
.op-empty svg { width: 36px; height: 36px; margin: 0 auto 0.75rem; color: rgba(16,55,92,.2); display: block; }

.sm-form-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
}
</style>

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
        <button class="sm-tab" id="tabDb" onclick="switchTab('db')">
            ÁNH XẠ TỪ DATABASE
        </button>
    </div>
    <div>
        <button class="sm-btn-pull" onclick="syncAllMappings()" id="btnSyncAll" title="Đồng bộ tất cả ánh xạ đang PENDING/ERROR">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.5 2v6h-6M21.34 15.57a10 10 0 1 1-.57-8.38l5.67-5.67"></path></svg>
            Sync All
        </button>
        <button class="sm-btn-pull" onclick="pullMarketplaceProducts()" id="btnPullProducts" style="margin-left:0.5rem">
            <svg id="pullSpinnerIcon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.5 2v6h-6M21.34 15.57a10 10 0 1 1-.57-8.38l5.67-5.67"></path></svg>
            Kéo sản phẩm từ Sàn
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
    <button class="sm-btn-action" id="btnCreateMapping" onclick="openCreateModal()" style="margin-left: auto">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
        Tạo ánh xạ mới
    </button>
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
                    <%-- Populated server-side for db tab --%>
                </tr>
            </thead>
            <tbody id="smTableBody">
                <%-- Populated by JS for unmapped/mapped tabs --%>
            </tbody>
            <tbody id="smDbTableBody" style="display:none">
                <%-- Server-rendered: SKU mappings from database --%>
                <c:choose>
                    <c:when test="${empty skuMappings}">
                        <tr>
                            <td colspan="7" class="op-empty">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><line x1="9" y1="9" x2="15" y2="15"></line><line x1="15" y1="9" x2="9" y2="15"></line></svg>
                                Chưa có ánh xạ SKU nào trong cơ sở dữ liệu.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="m" items="${skuMappings}">
                            <tr data-mapping-id="${m.mappingId}" data-channel-id="${m.channelId}" data-sku-id="${m.skuId}">
                                <td><span style="font-family:monospace;font-weight:700">${m.skuCode}</span></td>
                                <td><strong style="color:var(--navy)">${m.productName}</strong></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${m.channelPlatform == 'Lazada'}">
                                            <span class="sm-badge-channel" style="background:#0F146D">${m.channelName}</span>
                                        </c:when>
                                        <c:when test="${m.channelPlatform == 'Shopee'}">
                                            <span class="sm-badge-channel" style="background:#EE4D2D">${m.channelName}</span>
                                        </c:when>
                                        <c:when test="${m.channelPlatform == 'TikTok'}">
                                            <span class="sm-badge-channel" style="background:#69C9D0">${m.channelName}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="sm-badge-channel" style="background:#64748b">${m.channelName}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td><span style="font-family:monospace;font-weight:700">${m.externalSku}</span></td>
                                <td><span style="font-family:monospace">${m.sellerSku}</span></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${m.syncStatus == 'SYNCED'}">
                                            <span class="sm-badge-sync synced">${m.syncStatus}</span>
                                        </c:when>
                                        <c:when test="${m.syncStatus == 'ERROR'}">
                                            <span class="sm-badge-sync error">${m.syncStatus}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="sm-badge-sync pending">${m.syncStatus}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div style="display:flex;gap:6px;align-items:center">
                                        <button class="sm-btn-action" onclick="openDbEditModal('${m.mappingId}')" title="Sửa">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                        </button>
                                        <button class="sm-btn-action" onclick="syncSingleMapping('${m.mappingId}')" title="Sync">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.5 2v6h-6M21.34 15.57a10 10 0 1 1-.57-8.38l5.67-5.67"></path></svg>
                                        </button>
                                        <button class="sm-btn-action" onclick="deleteDbMapping('${m.mappingId}')" style="background:#dc2626" title="Xóa">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>

<%-- ── CRUD / SYNC MODAL FOR DATABASE MAPPINGS ── --%>
<div class="sm-modal-overlay" id="smCrudModalOverlay" onclick="closeCrudModal()">
    <div class="sm-modal" onclick="event.stopPropagation()">
        <div class="sm-modal-header">
            <div class="sm-modal-title">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path></svg>
                <span id="smCrudModalTitle">Tạo Ánh Xạ SKU</span>
            </div>
            <button class="sm-modal-close" onclick="closeCrudModal()">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
            </button>
        </div>
        <form method="post" id="smCrudForm">
            <input type="hidden" name="action" id="smCrudAction" value="create" />
            <input type="hidden" name="mappingId" id="smCrudMappingId" value="" />
            <div class="sm-modal-body">
                <div class="sm-form-group">
                    <label class="sm-field-label">Sản phẩm Master SKU *</label>
                    <select class="sm-select" name="productId" id="smCrudProductId" required style="width:100%">
                        <option value="">-- Chọn Master SKU --</option>
                        <c:forEach var="p" items="${products}">
                            <option value="${p.productId}">${p.skuCode} - ${p.productName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="sm-form-group">
                    <label class="sm-field-label">Kênh bán hàng *</label>
                    <select class="sm-select" name="channelId" id="smCrudChannelId" required style="width:100%">
                        <option value="">-- Chọn kênh --</option>
                        <c:forEach var="ch" items="${channels}">
                            <option value="${ch.channelId}">${ch.channelName} (${ch.platform})</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="sm-form-group">
                    <label class="sm-field-label">Mã SKU Sàn (Channel SKU) *</label>
                    <input type="text" class="sm-input" name="channelSku" id="smCrudChannelSku" placeholder="VD: LZD-SET5-SKU001" required style="text-align:left;padding:0.4rem 0.6rem" />
                </div>
                <div class="sm-form-group">
                    <label class="sm-field-label">Mã Seller SKU (tùy chọn)</label>
                    <input type="text" class="sm-input" name="sellerSku" id="smCrudSellerSku" placeholder="Mã SKU của người bán" style="text-align:left;padding:0.4rem 0.6rem" />
                </div>
                <div class="sm-form-group">
                    <label class="sm-field-label">Trạng thái Sync</label>
                    <select class="sm-select" name="syncStatus" id="smCrudSyncStatus" style="width:100%">
                        <option value="PENDING">PENDING</option>
                        <option value="SYNCED">SYNCED</option>
                        <option value="ERROR">ERROR</option>
                    </select>
                </div>
            </div>
            <div class="sm-modal-footer">
                <button type="button" class="sm-btn white" onclick="closeCrudModal()">HỦY</button>
                <button type="submit" class="sm-btn primary">LƯU</button>
            </div>
        </form>
    </div>
</div>

<%-- ── SYNC SINGLE CONFIRM MODAL ── --%>
<div class="sm-modal-overlay" id="smSyncModalOverlay" onclick="closeSyncModal()">
    <div class="sm-modal" style="max-width:400px" onclick="event.stopPropagation()">
        <div class="sm-modal-header">
            <div class="sm-modal-title">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.5 2v6h-6M21.34 15.57a10 10 0 1 1-.57-8.38l5.67-5.67"></path></svg>
                Đồng bộ Ánh Xạ SKU
            </div>
            <button class="sm-modal-close" onclick="closeSyncModal()">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
            </button>
        </div>
        <form method="post" id="smSyncForm">
            <input type="hidden" name="action" value="sync" />
            <input type="hidden" name="channelProductId" id="smSyncChannelProductId" value="" />
            <div class="sm-modal-body">
                <p style="font-size:13px;color:var(--navy);line-height:1.6">
                    Xác nhận đồng bộ trạng thái <strong>SYNCED</strong> cho ánh xạ này?
                </p>
                <div style="margin-top:1rem">
                    <label class="sm-field-label">Giá mới (VNĐ)</label>
                    <input type="number" class="sm-input" name="price" id="smSyncPrice" placeholder="Giá mới" style="text-align:left;padding:0.4rem 0.6rem;width:100%" />
                </div>
                <div style="margin-top:0.75rem">
                    <label class="sm-field-label">Tồn kho mới</label>
                    <input type="number" class="sm-input" name="stock" id="smSyncStock" placeholder="Tồn kho mới" style="text-align:left;padding:0.4rem 0.6rem;width:100%" />
                </div>
            </div>
            <div class="sm-modal-footer">
                <button type="button" class="sm-btn white" onclick="closeSyncModal()">HỦY</button>
                <button type="submit" class="sm-btn primary">ĐỒNG BỘ</button>
            </div>
        </form>
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
    const savedSKUs = localStorage.getItem("wms_skus");
    if (savedSKUs) {
        try {
            const parsed = JSON.parse(savedSKUs);
            APPROVED_MASTER_SKUS = parsed.filter(s => s.approvalStatus === 'approved');
        } catch(e) {
            APPROVED_MASTER_SKUS = [];
        }
    } else {
        APPROVED_MASTER_SKUS = [];
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
    if (tabId === "db") document.getElementById("tabDb").classList.add("active");

    const searchInp = document.getElementById("smSearchInput");
    const createBtn = document.getElementById("btnCreateMapping");
    if (tabId === "unmapped") {
        searchInp.placeholder = "Tìm theo mã sàn, tên SP trên sàn...";
        createBtn.style.display = "none";
    } else if (tabId === "mapped") {
        searchInp.placeholder = "Tìm theo Master SKU, tên SP gốc WMS...";
        createBtn.style.display = "none";
    } else {
        searchInp.placeholder = "Tìm theo SKU, kênh...";
        createBtn.style.display = "flex";
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
    if (activeTab === "db") {
        filterDbTable();
    } else {
        renderAll();
    }
}

function onChannelFilterChange(val) {
    channelFilter = val;
    if (activeTab === "db") {
        filterDbTable();
    }
}

function filterDbTable() {
    const rows = document.querySelectorAll("#smDbTableBody tr[data-mapping-id]");
    rows.forEach(function(row) {
        const sku = (row.getAttribute("data-sku-id") || "").toLowerCase();
        const channelId = row.getAttribute("data-channel-id") || "";
        const skuCode = row.querySelector("td") ? row.querySelector("td").textContent.toLowerCase() : "";
        const externalSku = row.querySelectorAll("td")[3] ? row.querySelectorAll("td")[3].textContent.toLowerCase() : "";

        let show = true;
        if (searchQuery && !(skuCode.includes(searchQuery) || externalSku.includes(searchQuery))) {
            show = false;
        }
        if (channelFilter && channelId !== channelFilter) {
            show = false;
        }
        row.style.display = show ? "" : "none";
    });
}

// ── MARKETPLACE SANDBOX API PULL SIMULATION ─────────────────────────
function pullMarketplaceProducts() {
    if (APPROVED_MASTER_SKUS.length === 0) {
        showToast("Không tìm thấy Master SKU nào đã duyệt trong hệ thống. Vui lòng tạo và duyệt sản phẩm trước!", "error");
        return;
    }

    const overlay = document.getElementById("smPullOverlay");
    const icon = document.getElementById("pullSpinnerIcon");
    const btn = document.getElementById("btnPullProducts");
    
    overlay.classList.add("open");
    icon.style.animation = "spin 1s linear infinite";
    btn.disabled = true;
    
    setTimeout(() => {
        overlay.classList.remove("open");
        icon.style.animation = "none";
        btn.disabled = false;
        
        let pool = [];
        // Generate set products dynamically using names and code values of approved WMS SKUs
        APPROVED_MASTER_SKUS.forEach((item, index) => {
            const cleanSku = item.sku.replace(/[^a-zA-Z0-9]/g, "").substring(0, 10).toUpperCase();
            if (index % 3 === 0) {
                pool.push({
                    id: "un_combo_" + Date.now() + "_" + index,
                    channel: "Shopee",
                    channelSKU: "SHP-CB2-" + cleanSku,
                    channelItemName: "Combo 2x " + item.name + " - Hộp Combo tiết kiệm",
                    channelColor: "#EE4D2D",
                    desc: "Gói combo bộ 2 sản phẩm " + item.name + " chính hãng."
                });
            } else if (index % 3 === 1) {
                pool.push({
                    id: "un_set5_" + Date.now() + "_" + index,
                    channel: "Lazada",
                    channelSKU: "LZD-SET5-" + cleanSku,
                    channelItemName: "Set 5x " + item.name + " - Bộ sản phẩm tiện lợi",
                    channelColor: "#0F146D",
                    desc: "Bộ 5 sản phẩm " + item.name + " đóng gói tiện lợi cho người dùng."
                });
            } else {
                pool.push({
                    id: "un_single_" + Date.now() + "_" + index,
                    channel: "TikTok Shop",
                    channelSKU: "TT-SG-" + cleanSku,
                    channelItemName: item.name + " chính hãng phân phối",
                    channelColor: "#69C9D0",
                    desc: "Sản phẩm " + item.name + " phân phối chính thức trên gian hàng TikTok Shop."
                });
            }
        });
        
        unmappedList = pool;
        localStorage.setItem("sku_unmapped_pool_v2", JSON.stringify(unmappedList));
        renderAll();
        showToast("Đã kết nối API Gateway Sandbox thành công! Tải về " + unmappedList.length + " sản phẩm chưa ánh xạ dựa trên Master SKU hiện có.", "success");
    }, 1500);
}

// ── RENDER DYNAMIC TABLES ────────────────────────────────────────────
function renderTableHeader() {
    const header = document.getElementById("smTableHeader");
    const dbTbody = document.getElementById("smDbTableBody");
    const smTbody = document.getElementById("smTableBody");

    if (activeTab === "db") {
        dbTbody.style.display = "";
        smTbody.style.display = "none";
        header.innerHTML = `
            <th style="width: 144px">Master SKU</th>
            <th style="width: 220px">Tên sản phẩm</th>
            <th style="width: 120px">Kênh</th>
            <th style="width: 160px">Channel SKU</th>
            <th style="width: 140px">Seller SKU</th>
            <th style="width: 100px">Trạng thái</th>
            <th style="width: 150px; text-align: center">Hành động</th>
        `;
        return;
    }

    smTbody.style.display = "";
    dbTbody.style.display = "none";

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
            <th style="width: 128px; text-align: center">Shopee</th>
            <th style="width: 128px; text-align: center">TikTok Shop</th>
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

    if (activeTab === "db") {
        filterDbTable();
        return;
    } else if (activeTab === "unmapped") {
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
                '<td style="text-align:center">' + getChannelRelsHtml('shopee') + '</td>' +
                '<td style="text-align:center">' + getChannelRelsHtml('tiktok') + '</td>' +
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

// ── DATABASE CRUD / SYNC MODAL CONTROLS ─────────────────────────────

function openCreateModal() {
    document.getElementById("smCrudModalTitle").textContent = "Tạo Ánh Xạ SKU Mới";
    document.getElementById("smCrudAction").value = "create";
    document.getElementById("smCrudMappingId").value = "";
    document.getElementById("smCrudProductId").value = "";
    document.getElementById("smCrudChannelId").value = "";
    document.getElementById("smCrudChannelSku").value = "";
    document.getElementById("smCrudSellerSku").value = "";
    document.getElementById("smCrudSyncStatus").value = "PENDING";
    document.getElementById("smCrudModalOverlay").classList.add("open");
}

function openDbEditModal(mappingId) {
    const row = document.querySelector('tr[data-mapping-id="' + mappingId + '"]');
    if (!row) return;

    const tds = row.querySelectorAll("td");
    document.getElementById("smCrudModalTitle").textContent = "Sửa Ánh Xạ SKU";
    document.getElementById("smCrudAction").value = "update";
    document.getElementById("smCrudMappingId").value = mappingId;
    document.getElementById("smCrudProductId").value = row.getAttribute("data-sku-id");
    document.getElementById("smCrudChannelId").value = row.getAttribute("data-channel-id");
    document.getElementById("smCrudChannelSku").value = tds[3] ? tds[3].textContent.trim() : "";
    document.getElementById("smCrudSellerSku").value = tds[4] ? tds[4].textContent.trim() : "";
    document.getElementById("smCrudSyncStatus").value = tds[5] ? tds[5].textContent.trim() : "PENDING";
    document.getElementById("smCrudModalOverlay").classList.add("open");
}

function closeCrudModal() {
    document.getElementById("smCrudModalOverlay").classList.remove("open");
}

function deleteDbMapping(mappingId) {
    if (!confirm("Bạn có chắc chắn muốn xóa ánh xạ SKU này không?")) return;

    const form = document.createElement("form");
    form.method = "post";
    form.action = "";
    const actionInput = document.createElement("input");
    actionInput.type = "hidden";
    actionInput.name = "action";
    actionInput.value = "delete";
    const idInput = document.createElement("input");
    idInput.type = "hidden";
    idInput.name = "mappingId";
    idInput.value = mappingId;
    form.appendChild(actionInput);
    form.appendChild(idInput);
    document.body.appendChild(form);
    form.submit();
}

function syncSingleMapping(mappingId) {
    document.getElementById("smSyncChannelProductId").value = mappingId;
    document.getElementById("smSyncPrice").value = "";
    document.getElementById("smSyncStock").value = "";
    document.getElementById("smSyncModalOverlay").classList.add("open");
}

function closeSyncModal() {
    document.getElementById("smSyncModalOverlay").classList.remove("open");
}

function syncAllMappings() {
    if (!confirm("Xác nhận đồng bộ tất cả ánh xạ đang PENDING / ERROR?")) return;

    const form = document.createElement("form");
    form.method = "post";
    form.action = "";
    const actionInput = document.createElement("input");
    actionInput.type = "hidden";
    actionInput.name = "action";
    actionInput.value = "syncAll";
    form.appendChild(actionInput);
    document.body.appendChild(form);
    form.submit();
}
</script>
