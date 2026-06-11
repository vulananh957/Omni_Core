<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
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
<style>
    /* ─── Tabs Styling ─── */
    .tabs-wrap {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 24px;
        overflow-x: auto;
        padding-bottom: 4px;
    }
    .tab-btn {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 10px 16px;
        font-size: 13px;
        font-weight: 600;
        border: 1px solid var(--border);
        background: #fff;
        color: rgba(16, 55, 92, 0.60);
        cursor: pointer;
        transition: all 0.15s ease;
        border-radius: var(--radius-btn);
        white-space: nowrap;
    }
    .tab-btn:hover {
        border-color: rgba(16, 55, 92, 0.20);
        color: var(--navy);
    }
    .tab-btn.active {
        background: #fff;
        color: var(--navy);
        border-color: rgba(16, 55, 92, 0.20);
        box-shadow: 0 1px 3px rgba(16, 55, 92, 0.05);
    }
    .tab-badge {
        padding: 2px 6px;
        font-size: 10px;
        font-weight: 700;
        border-radius: 4px;
        background: var(--alice);
        color: rgba(16, 55, 92, 0.60);
    }
    .tab-btn.active .tab-badge {
        background: rgba(16, 55, 92, 0.10);
        color: var(--navy);
    }

    /* ─── Toolbar & Filters ─── */
    .toolbar-wrap {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 16px;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        flex-wrap: wrap;
    }
    .filters-left {
        display: flex;
        align-items: center;
        gap: 12px;
        flex: 1;
        min-width: 280px;
    }
    .search-input-wrap {
        position: relative;
        flex: 1;
        max-width: 320px;
        min-width: 200px;
    }
    .search-input-wrap svg {
        position: absolute;
        left: 12px;
        top: 50%;
        transform: translateY(-50%);
        width: 15px;
        height: 15px;
        color: rgba(16, 55, 92, 0.3);
    }
    .search-input-wrap input {
        width: 100%;
        padding: 8px 16px 8px 36px;
        background: #fff;
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
        border-color: rgba(16, 55, 92, 0.40);
    }
    
    .select-wrap {
        position: relative;
    }
    .select-wrap select {
        appearance: none;
        padding: 8px 36px 8px 16px;
        background: #fff;
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

    .btn-export {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 16px;
        background: var(--navy);
        border: none;
        border-radius: calc(var(--radius-btn) - 2px);
        color: #fff;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.15s;
    }
    .btn-export:hover {
        background: #0d2c4b;
    }
    .btn-export svg {
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
    .sku-table th:last-child { padding-right: 20px; text-align: center; }
    
    .sku-table td {
        padding: 14px 16px;
        border-bottom: 1px solid #F0F3FA;
        vertical-align: middle;
    }
    .sku-table td:first-child { padding-left: 20px; }
    .sku-table td:last-child { padding-right: 20px; text-align: center; }
    
    .sku-table tr {
        transition: background 0.12s;
    }
    .sku-table tr:hover td {
        background: rgba(240, 244, 250, 0.40);
    }

    /* Table elements */
    .sku-code-cell {
        font-size: 13px;
        font-family: monospace;
        color: var(--navy);
        font-weight: 600;
    }
    .sku-name-cell {
        font-size: 13px;
        font-weight: 500;
        color: var(--navy);
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
        max-width: 180px;
    }
    .sku-cat-cell {
        font-size: 12px;
        color: rgba(16, 55, 92, 0.60);
    }

    /* Dimension & weight details */
    .detail-icon-wrap {
        display: flex;
        flex-direction: column;
        gap: 3px;
    }
    .detail-icon-row {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        font-size: 12px;
        color: rgba(16, 55, 92, 0.60);
        white-space: nowrap;
    }
    .detail-icon-row svg {
        width: 12px;
        height: 12px;
        flex-shrink: 0;
    }

    /* Stock value & Warning */
    .stock-val-wrap {
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 6px;
    }
    .stock-val-wrap svg {
        width: 14px;
        height: 14px;
        color: var(--orange);
        flex-shrink: 0;
    }
    .stock-qty {
        font-size: 13px;
        font-weight: 600;
    }
    .stock-qty.low-stock {
        color: var(--orange);
    }
    .stock-qty.normal-stock {
        color: var(--navy);
    }

    /* Storage Locations mapping */
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
        color: #1d4ed8;
    }
    .loc-unassigned {
        color: var(--orange);
        font-size: 12px;
        font-weight: 500;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        white-space: nowrap;
    }
    .loc-unassigned svg {
        width: 14px;
        height: 14px;
    }

    /* Info cell */
    .info-lbl {
        font-size: 12px;
        color: rgba(16, 55, 92, 0.85);
    }
    .info-lbl-inner {
        font-weight: 500;
    }
    .info-time {
        font-size: 10.5px;
        color: rgba(16, 55, 92, 0.60);
    }

    /* Status Pills */
    .pill-badge {
        display: inline-flex;
        align-items: center;
        padding: 4px 10px;
        font-size: 11px;
        font-weight: 600;
        border-radius: 4px;
        white-space: nowrap;
    }
    .pill-badge.approved {
        background: #ECFDF5;
        color: #047857;
        border: 1px solid rgba(16, 185, 129, 0.20);
    }
    .pill-badge.pending {
        background: #fffbeb;
        color: #b45309;
        border: 1px solid rgba(245, 158, 11, 0.30);
    }
    .pill-badge.rejected {
        background: #fef2f2;
        color: #b91c1c;
        border: 1px solid rgba(239, 68, 68, 0.20);
    }

    /* Action buttons (Approve / Reject) */
    .btn-action {
        width: 32px;
        height: 32px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        transition: background 0.15s;
    }
    .btn-action.approve {
        color: #059669;
        background: none;
    }
    .btn-action.approve:hover {
        background: #ECFDF5;
    }
    .btn-action.reject {
        color: #ef4444;
        background: none;
    }
    .btn-action.reject:hover {
        background: #FEF2F2;
    }
    .btn-action svg {
        width: 16px;
        height: 16px;
    }

    /* Table Footer */
    .table-footer {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 14px 24px;
        background: var(--alice);
        font-size: 12px;
        color: rgba(16, 55, 92, 0.60);
        border-top: 1px solid #F0F3FA;
    }

    /* ─── Modals ─── */
    .modal-overlay {
        position: fixed;
        inset: 0;
        background: rgba(16, 55, 92, 0.50);
        backdrop-filter: blur(4px);
        display: flex;
        align-items: start;
        justify-content: center;
        z-index: 1000;
        opacity: 0;
        pointer-events: none;
        transition: opacity 0.2s ease;
        overflow-y: auto;
        padding: 32px 16px;
    }
    .modal-overlay.active {
        opacity: 1;
        pointer-events: auto;
    }
    .modal-box {
        background: #fff;
        width: 100%;
        max-width: 680px;
        border-radius: var(--radius-card);
        box-shadow: 0 20px 25px -5px rgba(16, 55, 92, 0.15), 0 10px 10px -5px rgba(16, 55, 92, 0.1);
        transform: translateY(24px);
        transition: transform 0.2s ease;
        display: flex;
        flex-direction: column;
    }
    .modal-overlay.active .modal-box {
        transform: translateY(0);
    }

    .modal-hdr {
        padding: 20px 24px;
        border-bottom: 1px solid var(--border);
    }
    .modal-hdr-top {
        display: flex;
        align-items: start;
        justify-content: space-between;
    }
    .modal-title {
        color: var(--navy);
        font-size: 18px;
        font-weight: 800;
        line-height: 1.25;
    }
    .modal-subtitle {
        color: rgba(16, 55, 92, 0.50);
        font-size: 13px;
        margin-top: 4px;
    }
    .modal-close {
        background: none;
        border: none;
        cursor: pointer;
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        color: rgba(16, 55, 92, 0.3);
        font-size: 20px;
        transition: color 0.15s, background-color 0.15s;
    }
    .modal-close:hover {
        color: rgba(16, 55, 92, 0.7);
        background-color: var(--alice);
    }

    /* Product preview card in modal */
    .sku-preview-card {
        margin-top: 16px;
        display: flex;
        align-items: start;
        gap: 12px;
        background: var(--alice);
        padding: 12px 16px;
        border-radius: 8px;
        border: 1px solid var(--border);
    }
    .sku-preview-icon {
        color: rgba(16, 55, 92, 0.40);
        margin-top: 2px;
        flex-shrink: 0;
    }
    .sku-preview-icon svg {
        width: 20px;
        height: 20px;
    }
    .sku-preview-meta {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 12px;
        font-family: monospace;
        color: rgba(16, 55, 92, 0.50);
    }
    .sku-preview-tag {
        padding: 2px 6px;
        background: #fff;
        border: 1px solid var(--border);
        border-radius: 4px;
        font-family: var(--font-main);
    }
    .sku-preview-name {
        color: var(--navy);
        font-weight: 600;
        font-size: 14px;
        margin-top: 2px;
    }
    .sku-preview-specs {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-top: 4px;
        font-size: 11px;
        color: rgba(16, 55, 92, 0.40);
    }
    .sku-preview-specs span {
        display: flex;
        align-items: center;
        gap: 4px;
    }
    .sku-preview-specs svg {
        width: 12px;
        height: 12px;
    }

    /* Multi-Location Matrix inside body */
    .matrix-title {
        color: var(--navy);
        font-weight: 700;
        font-size: 13px;
    }
    .matrix-desc {
        color: rgba(16, 55, 92, 0.40);
        font-size: 12px;
        margin-top: 2px;
    }
    .matrix-headers {
        display: grid;
        grid-template-columns: 1fr 1fr auto;
        gap: 12px;
        font-size: 10px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: rgba(16, 55, 92, 0.40);
        padding: 0 4px;
        margin-top: 16px;
    }
    .matrix-headers-col {
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .matrix-headers-col svg {
        width: 12px;
        height: 12px;
    }

    .matrix-rows-container {
        display: flex;
        flex-direction: column;
        gap: 10px;
        margin-top: 8px;
    }
    .matrix-row {
        display: grid;
        grid-template-columns: 1fr 1fr auto;
        gap: 12px;
        align-items: start;
        padding: 12px;
        border-radius: 8px;
        border: 1px solid var(--border);
        background: rgba(240, 244, 250, 0.4);
        transition: border-color 0.15s, background-color 0.15s;
    }
    .matrix-row.duplicate {
        border-color: rgba(239, 68, 68, 0.3);
        background-color: #fef2f2;
    }
    .matrix-row-select-wrap {
        position: relative;
    }
    .matrix-row-select-wrap svg.prefix-icon {
        position: absolute;
        left: 12px;
        top: 50%;
        transform: translateY(-50%);
        width: 14px;
        height: 14px;
        color: rgba(16, 55, 92, 0.30);
        pointer-events: none;
    }
    .matrix-row-select-wrap select {
        width: 100%;
        appearance: none;
        padding: 8px 32px 8px 34px;
        background: #fff;
        border: 1px solid #D8E1F0;
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        outline: none;
        color: var(--navy);
        cursor: pointer;
        transition: border-color 0.15s;
    }
    .matrix-row-select-wrap select:focus {
        border-color: rgba(16, 55, 92, 0.40);
    }
    .matrix-row-select-wrap select:disabled {
        background: var(--alice);
        color: rgba(16, 55, 92, 0.3);
        cursor: not-allowed;
        border-color: var(--border);
    }
    .matrix-row-select-wrap svg.suffix-icon {
        position: absolute;
        right: 10px;
        top: 50%;
        transform: translateY(-50%);
        width: 14px;
        height: 14px;
        color: rgba(16, 55, 92, 0.30);
        pointer-events: none;
    }
    .matrix-row.duplicate select {
        border-color: #ef4444;
        background-color: #fef2f2;
        color: #b91c1c;
    }
    .matrix-row-err {
        color: #ef4444;
        font-size: 10px;
        margin-top: 4px;
        padding-left: 4px;
    }

    .btn-row-delete {
        width: 32px;
        height: 36px;
        display: flex;
        align-items: center;
        justify-content: center;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        transition: background 0.15s, color 0.15s;
        background: none;
        color: rgba(239, 68, 68, 0.50);
    }
    .btn-row-delete:hover:not(:disabled) {
        background: #fef2f2;
        color: #ef4444;
    }
    .btn-row-delete:disabled {
        color: rgba(16, 55, 92, 0.15);
        cursor: not-allowed;
    }
    .btn-row-delete svg {
        width: 14px;
        height: 14px;
    }

    .btn-add-row {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        padding: 10px 16px;
        font-size: 13px;
        font-weight: 600;
        background: #fff;
        color: rgba(16, 55, 92, 0.60);
        border: 1px dashed #C8D3E8;
        border-radius: calc(var(--radius-btn) - 2px);
        width: 100%;
        cursor: pointer;
        transition: all 0.15s ease;
        margin-top: 12px;
    }
    .btn-add-row:hover {
        color: var(--navy);
        border-color: rgba(16, 55, 92, 0.40);
        background: var(--alice);
    }
    .btn-add-row svg {
        width: 16px;
        height: 16px;
    }

    /* Modal footer */
    .modal-ftr {
        padding: 16px 24px;
        border-top: 1px solid var(--border);
        background: var(--alice);
        display: flex;
        justify-content: flex-end;
        gap: 12px;
        border-bottom-left-radius: var(--radius-card);
        border-bottom-right-radius: var(--radius-card);
    }
    .btn-cancel {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 8px 16px;
        background: #fff;
        border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        font-weight: 500;
        color: rgba(16, 55, 92, 0.70);
        cursor: pointer;
        transition: color 0.15s, border-color 0.15s;
    }
    .btn-cancel:hover {
        color: var(--navy);
        border-color: rgba(16, 55, 92, 0.30);
    }
    .btn-submit {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 8px 20px;
        background: var(--navy);
        border: none;
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        font-weight: 600;
        color: #fff;
        cursor: pointer;
        transition: background 0.15s;
    }
    .btn-submit:hover:not(:disabled) {
        background: #0d2c4b;
    }
    .btn-submit:disabled {
        background: rgba(16, 55, 92, 0.15);
        color: rgba(16, 55, 92, 0.30);
        cursor: not-allowed;
    }

    /* ─── Reject Modal Box ─── */
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
    .form-textarea {
        width: 100%;
        min-height: 100px;
        padding: 10px 14px;
        border: 1px solid var(--border);
        background: var(--alice);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        font-family: inherit;
        color: var(--navy);
        outline: none;
        resize: vertical;
        transition: border-color 0.15s;
    }
    .form-textarea:focus {
        border-color: rgba(16, 55, 92, 0.40);
    }

    /* ─── Toast Notification CSS ─── */
    .toast-notification {
        position: fixed;
        top: 24px;
        right: 24px;
        z-index: 9999;
        background: #10B981;
        color: #fff;
        padding: 12px 24px;
        border-radius: 8px;
        box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        display: none;
        align-items: center;
        gap: 8px;
        font-weight: 500;
        transition: all 0.3s ease-in-out;
    }
    .toast-notification.show {
        display: flex;
        animation: toastSlideIn 0.3s forwards;
    }
    .toast-notification.error {
        background: #EF4444;
    }
    @keyframes toastSlideIn {
        from { transform: translateY(-20px); opacity: 0; }
        to { transform: translateY(0); opacity: 1; }
    }
</style>

<!-- Toast Notification Element -->
<div id="skuToast" class="toast-notification">
    <span id="skuToastIcon">✓</span>
    <span id="skuToastMsg">Cập nhật thành công!</span>
</div>

<!-- ══ TABS FILTER SECTION ════════════════════════════════════ -->
<div class="tabs-wrap">
    <button class="tab-btn active" id="tab-all" onclick="window.setSKUTab('all')">
        Tất cả <span class="tab-badge" id="badge-all">0</span>
    </button>
    <button class="tab-btn" id="tab-pending" onclick="window.setSKUTab('pending')">
        Chờ duyệt <span class="tab-badge" id="badge-pending">0</span>
    </button>
    <button class="tab-btn" id="tab-approved" onclick="window.setSKUTab('approved')">
        Đã duyệt <span class="tab-badge" id="badge-approved">0</span>
    </button>
    <button class="tab-btn" id="tab-rejected" onclick="window.setSKUTab('rejected')">
        Từ chối <span class="tab-badge" id="badge-rejected">0</span>
    </button>
</div>

<!-- ══ TOOLBAR SECTION ═══════════════════════════════════════ -->
<div class="toolbar-wrap">
    <div class="filters-left">
        <!-- Search -->
        <div class="search-input-wrap">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"></svg>
            <input type="text" placeholder="Tìm mã SKU, tên sản phẩm..." id="skuSearchInput"/>
        </div>
        
        <!-- Category Select -->
        <div class="select-wrap">
            <select id="skuCategorySelect">
                <option>Tất cả</option>
                <option>Vở & Sổ chép</option>
                <option>Phụ kiện cá nhân</option>
                <option>Dụng cụ viết & Vẽ</option>
                <option>Thiết bị văn phòng tiện ích</option>
            </select>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></svg>
        </div>
    </div>
    
    <button class="btn-export" id="btnExportCSV">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
        Xuất CSV
    </button>
</div>

<!-- ══ TABLE SECTION ═════════════════════════════════════════ -->
<div class="table-card">
    <div class="table-scroll">
        <table class="sku-table">
            <thead>
                <tr>
                    <th style="width: 130px;">Mã SKU</th>
                    <th style="width: 180px;">Tên sản phẩm</th>
                    <th style="width: 90px;">Danh mục</th>
                    <th style="width: 140px; text-align: center;">KL / Kích thước</th>
                    <th style="width: 90px; text-align: right;">Tồn kho</th>
                    <th style="width: 200px;">Vị trí lưu trữ</th>
                    <th style="width: 185px;">Thông tin</th>
                    <th style="width: 110px; text-align: center;">Phê duyệt</th>
                </tr>
            </thead>
            <tbody id="skuTableBody"></tbody>
        </table>
    </div>
    
    <div class="table-footer">
        <span id="skuTableInfo">Hiển thị 0 / 0 SKU</span>
    </div>
</div>

<!-- ══ APPROVE MODAL (MULTI-LOCATION MATRIX) ════════════════ -->
<div class="modal-overlay" id="approveModalOverlay">
    <div class="modal-box">
        <div class="modal-hdr">
            <div class="modal-hdr-top">
                <div>
                    <h2 class="modal-title">Phê duyệt và Gán vị trí Master SKU</h2>
                    <p class="modal-subtitle">Cấu hình vị trí lưu trữ mặc định cho từng chi nhánh kho</p>
                </div>
                <button class="modal-close" id="approveModalClose">&times;</button>
            </div>
            
            <div class="sku-preview-card" id="approve-sku-preview">
                <!-- Populated dynamically -->
            </div>
        </div>
        
        <div class="modal-body" style="padding-top: 12px;">
            <div>
                <h3 class="matrix-title">Cấu hình vị trí lưu trữ mặc định</h3>
                <p class="matrix-desc">Hệ thống sẽ dùng cấu hình này để hướng dẫn nhân viên khi có lô hàng mới nhập về từng chi nhánh.</p>
            </div>
            
            <div class="matrix-headers">
                <div class="matrix-headers-col">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="9" y1="3" x2="9" y2="21"/><line x1="15" y1="3" x2="15" y2="21"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="3" y1="15" x2="21" y2="15"/></svg>
                    Chi nhánh Kho (Location)
                </div>
                <div class="matrix-headers-col">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/><path d="M19 12a7 7 0 1 1-14 0 7 7 0 0 1 14 0Z"/></svg>
                    Khu vực trong kho (Zone)
                </div>
                <div style="width: 32px;"></div>
            </div>
            
            <div class="matrix-rows-container" id="matrixRowsContainer">
                <!-- Dynamically populated -->
            </div>
            
            <button class="btn-add-row" id="btnAddMatrixRow">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                Thêm cấu hình kho khác
            </button>
        </div>
        
        <div class="modal-ftr">
            <button class="btn-cancel" id="approveModalCancel">Hủy</button>
            <button class="btn-submit" id="btnApproveSubmit">Phê duyệt</button>
        </div>
    </div>
</div>

<!-- ══ REJECT MODAL ═════════════════════════════════════════ -->
<div class="modal-overlay" id="rejectModalOverlay">
    <div class="modal-box" style="max-width: 480px;">
        <div class="modal-hdr">
            <div class="modal-hdr-top">
                <div>
                    <h2 class="modal-title">Từ chối Master SKU</h2>
                    <p class="modal-subtitle" id="reject-sku-code-label">SKU-XXXX</p>
                </div>
                <button class="modal-close" id="rejectModalClose">&times;</button>
            </div>
        </div>
        
        <div class="modal-body">
            <input type="hidden" id="reject-item-id"/>
            <div class="form-group">
                <label class="form-label" for="reject-reason">Lý do từ chối *</label>
                <textarea class="form-textarea" id="reject-reason" placeholder="Nhập lý do từ chối sản phẩm này..."></textarea>
            </div>
        </div>
        
        <div class="modal-ftr">
            <button class="btn-cancel" id="rejectModalCancel">Hủy</button>
            <button class="btn-submit" id="btnRejectSubmit" style="background-color: #ef4444;">Từ chối</button>
        </div>
    </div>
</div>

<!-- ══ SCRIPT LOGIC ══════════════════════════════════════════ -->
<script>
// Expose JSTL session user details to client-side
window.WMS_USER = {
    fullName: "${fn:escapeXml(not empty loggedInUser.fullName ? loggedInUser.fullName : 'Guest')}",
    role: "${fn:escapeXml(not empty loggedInUser.role ? loggedInUser.role : 'Guest')}"
};

function showToast(message, isError) {
    var toast = document.getElementById("skuToast");
    var msgSpan = document.getElementById("skuToastMsg");
    var iconSpan = document.getElementById("skuToastIcon");
    if (!toast || !msgSpan || !iconSpan) return;

    msgSpan.textContent = message;
    iconSpan.textContent = isError ? "✕" : "✓";
    toast.className = "toast-notification show";
    if (isError) {
        toast.classList.add("error");
    }

    setTimeout(function() {
        toast.classList.remove("show");
    }, 4000);
}

// Check for flash messages from Servlet
(function() {
    var errorMsg = "${fn:escapeXml(errorMessage)}";
    var successMsg = "${fn:escapeXml(successMessage)}";
    if (errorMsg && errorMsg.trim() !== "" && errorMsg.indexOf('errorMessage') === -1) {
        showToast(errorMsg, true);
    } else if (successMsg && successMsg.trim() !== "" && successMsg.indexOf('successMessage') === -1) {
        showToast(successMsg, false);
    }
})();

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
    console.warn('master-sku: No server product data, using localStorage fallback');
}

// Shared localStorage database
var savedSKUs = localStorage.getItem('wms_skus');
var localSKUs = savedSKUs ? JSON.parse(savedSKUs) : [];

function hasVisibleMojibake(text) {
    if (!text) return false;
    return /Ã.|Æ.|áº|á»|Ä‘|á¸/i.test(String(text));
}

function shouldUseLocalFallback(serverProducts, localProducts) {
    if (serverProducts.length > 0) {
        return false;
    }
    return localProducts.length > 0;
}

/* ─── State ──────────────────────────────────────────────── */
var skus = shouldUseLocalFallback(SERVER_PRODUCTS, localSKUs) ? localSKUs : SERVER_PRODUCTS.map(function(p) {
    return {
        id: p.id || ('p-' + p.productId),
        sku: p.sku || p.skuCode || '',
        name: p.name || p.productName || '',
        category: p.category || p.categoryName || '',
        dimensions: p.dimensions || p.attributesText || 'N/A',
        weight: p.weight || (p.weightKg ? p.weightKg + ' kg' : 'N/A'),
        qtyOnHand: typeof p.qtyOnHand !== 'undefined' ? p.qtyOnHand : 0,
        minStock: p.minStock || 0,
        maxStock: p.maxStock || 0,
        status: p.status || 'pending',
        approvalStatus: p.approvalStatus || (p.status === 'APPROVED' ? 'approved' : p.status === 'REJECTED' ? 'rejected' : 'pending'),
        locationConfigs: p.locationConfigs || [],
        createdBy: p.creatorName || p.createdBy || '',
        createdAt: p.createdAt || '',
        updatedBy: p.approverName || p.updatedBy || '',
        lastUpdated: p.lastUpdated || p.updatedAt || '',
        reviewNote: p.reviewNote || ''
    };
});

if (SERVER_PRODUCTS.length > 0 && skus.some(function (item) { return hasVisibleMojibake(item.name); })) {
    console.warn('master-sku: Server product data still contains mojibake product names');
}


// Bind dynamic warehouses and zones from servlet
var DB_WAREHOUSES = [];
try {
    var rawWhJson = '<c:out value="${warehousesJson}" escapeXml="false"/>';
    if (rawWhJson && rawWhJson.trim() && rawWhJson.indexOf('warehousesJson') === -1) {
        DB_WAREHOUSES = JSON.parse(rawWhJson);
    }
} catch (e) {
    console.warn('master-sku: No server warehouse data');
}

var LOCATIONS = [];
var ZONES = [];
if (DB_WAREHOUSES.length > 0) {
    DB_WAREHOUSES.forEach(function(wh) {
        LOCATIONS.push({
            id: wh.warehouseId.toString(),
            name: wh.warehouseName,
            code: wh.warehouseCode,
            city: wh.address || ""
        });
        if (wh.zones) {
            wh.zones.forEach(function(z) {
                ZONES.push({
                    id: z.zoneId.toString(),
                    locationId: wh.warehouseId.toString(),
                    code: z.zoneCode,
                    name: z.zoneName,
                    allowForNew: z.zoneType === 'NORMAL' || z.zoneType === 'RETURN'
                });
            });
        }
    });
} else {
    // Fallback to static
    LOCATIONS = [
        { id: "loc-hn",  name: "Kho Hà Nội",      code: "HN",  city: "Hà Nội" },
        { id: "loc-dn",  name: "Kho Đà Nẵng",     code: "DN",  city: "Đà Nẵng" },
        { id: "loc-hcm", name: "Kho TP. Hồ Chí Minh", code: "HCM", city: "TP.HCM" }
    ];
    ZONES = [
        { id: "z-hn-regular",   locationId: "loc-hn",  code: "HN-A1", name: "Khu Hàng Thường",          allowForNew: true  },
        { id: "z-hn-cold",      locationId: "loc-hn",  code: "HN-B1", name: "Khu Hàng Lạnh / Giá trị cao", allowForNew: true  },
        { id: "z-hn-promo",     locationId: "loc-hn",  code: "HN-C1", name: "Khu Hàng Khuyến Mãi",      allowForNew: true  },
        { id: "z-hn-damaged",   locationId: "loc-hn",  code: "HN-D1", name: "Khu Hàng Hỏng",            allowForNew: false },
        { id: "z-hn-complaint", locationId: "loc-hn",  code: "HN-D2", name: "Khu Hàng Khiếu Nại",       allowForNew: false },
        { id: "z-dn-regular",   locationId: "loc-dn",  code: "DN-A1", name: "Khu Hàng Thường",          allowForNew: true  },
        { id: "z-dn-cold",      locationId: "loc-dn",  code: "DN-B1", name: "Khu Hàng Lạnh / Giá trị cao", allowForNew: true  },
        { id: "z-dn-damaged",   locationId: "loc-dn",  code: "DN-D1", name: "Khu Hàng Hỏng",            allowForNew: false },
        { id: "z-dn-complaint", locationId: "loc-dn",  code: "DN-D2", name: "Khu Hàng Khiếu Nại",       allowForNew: false },
        { id: "z-hcm-regular",  locationId: "loc-hcm", code: "HCM-A1", name: "Khu Hàng Thường",         allowForNew: true  },
        { id: "z-hcm-cold",     locationId: "loc-hcm", code: "HCM-B1", name: "Khu Hàng Lạnh / Giá trị cao", allowForNew: true },
        { id: "z-hcm-promo",    locationId: "loc-hcm", code: "HCM-C1", name: "Khu Hàng Khuyến Mãi",     allowForNew: true  },
        { id: "z-hcm-damaged",  locationId: "loc-hcm", code: "HCM-D1", name: "Khu Hàng Hỏng",           allowForNew: false },
        { id: "z-hcm-complaint",locationId: "loc-hcm", code: "HCM-D2", name: "Khu Hàng Khiếu Nại",      allowForNew: false }
    ];
}

var search = '';
var selectedCategory = 'Tất cả';
var activeTab = 'all'; // 'all', 'pending', 'approved', 'rejected'

// Active modals states
var currentApprovingItem = null;
var matrixRows = []; // Array of { id, locationId, zoneId }

/* ─── DOM Elements ───────────────────────────────────────── */
var tableBody   = document.getElementById('skuTableBody');
var tableInfo   = document.getElementById('skuTableInfo');
var searchInput = document.getElementById('skuSearchInput');
var catSelect   = document.getElementById('skuCategorySelect');

/* Modals */
var approveOverlay = document.getElementById('approveModalOverlay');
var btnApproveClose   = document.getElementById('approveModalClose');
var btnApproveCancel  = document.getElementById('approveModalCancel');
var btnApproveSubmit  = document.getElementById('btnApproveSubmit');
var addMatrixRowBtn   = document.getElementById('btnAddMatrixRow');
var matrixContainer   = document.getElementById('matrixRowsContainer');
var skuPreviewCard    = document.getElementById('approve-sku-preview');

var rejectOverlay = document.getElementById('rejectModalOverlay');
var btnRejectClose   = document.getElementById('rejectModalClose');
var btnRejectCancel  = document.getElementById('rejectModalCancel');
var btnRejectSubmit  = document.getElementById('btnRejectSubmit');
var rejectIdInput    = document.getElementById('reject-item-id');
var rejectReasonInput = document.getElementById('reject-reason');
var rejectCodeLabel  = document.getElementById('reject-sku-code-label');

/* ─── Handlers ───────────────────────────────────────────── */
if (searchInput) {
    searchInput.addEventListener('input', function (e) {
        search = e.target.value;
        renderAll();
    });
}
if (catSelect) {
    catSelect.addEventListener('change', function (e) {
        selectedCategory = e.target.value;
        renderAll();
    });
}

window.setSKUTab = function (tabId) {
    activeTab = tabId;
    // Highlight button
    ['all', 'pending', 'approved', 'rejected'].forEach(function (t) {
        var btn = document.getElementById('tab-' + t);
        if (btn) {
            if (t === tabId) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        }
    });
    renderAll();
};

/* ─── Approve Matrix Logic ──────────────────────────────── */
function openApproveModal(item) {
    currentApprovingItem = item;
    matrixRows = [{ id: 'row-' + Date.now(), locationId: '', zoneId: '' }];
    
    // Fill preview card
    skuPreviewCard.innerHTML = 
        '<div class="sku-preview-icon">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path></svg>' +
        '</div>' +
        '<div>' +
            '<div class="sku-preview-meta">' +
                '<span>' + item.sku + '</span>' +
                '<span class="sku-preview-tag">' + item.category + '</span>' +
            '</div>' +
            '<div class="sku-preview-name">' + item.name + '</div>' +
            '<div class="sku-preview-specs">' +
                '<span><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 3v18M12 3L7 8m5-5 5 5"/></svg> ' + item.weight + '</span>' +
                '<span><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="9" y1="3" x2="9" y2="21"/></svg> ' + item.dimensions + '</span>' +
            '</div>' +
        '</div>';

    renderMatrixRows();
    approveOverlay.classList.add('active');
}

function closeApproveModal() {
    approveOverlay.classList.remove('active');
    currentApprovingItem = null;
    matrixRows = [];
}

[btnApproveClose, btnApproveCancel].forEach(function (btn) {
    if (btn) btn.addEventListener('click', closeApproveModal);
});

if (addMatrixRowBtn) {
    addMatrixRowBtn.addEventListener('click', function () {
        if (matrixRows.length < LOCATIONS.length) {
            matrixRows.push({ id: 'row-' + Date.now(), locationId: '', zoneId: '' });
            renderMatrixRows();
        }
    });
}

function deleteMatrixRow(rowId) {
    if (matrixRows.length > 1) {
        matrixRows = matrixRows.filter(function (r) { return r.id !== rowId; });
        renderMatrixRows();
    }
}

function updateMatrixRowLocation(rowId, locationId) {
    matrixRows = matrixRows.map(function (row) {
        if (row.id === rowId) {
            return { id: row.id, locationId: locationId, zoneId: '' }; // reset zone on location change
        }
        return row;
    });
    renderMatrixRows();
}

function updateMatrixRowZone(rowId, zoneId) {
    matrixRows = matrixRows.map(function (row) {
        if (row.id === rowId) {
            return { id: row.id, locationId: row.locationId, zoneId: zoneId };
        }
        return row;
    });
    renderMatrixRows();
}

function checkDuplicateLocations() {
    var locs = matrixRows.map(function (r) { return r.locationId; }).filter(function (id) { return !!id; });
    var duplicates = locs.filter(function (id, idx) { return locs.indexOf(id) !== idx; });
    return duplicates;
}

function renderMatrixRows() {
    var duplicates = checkDuplicateLocations();
    var isAllSelected = matrixRows.length > 0 && matrixRows.every(function (r) { return r.locationId && r.zoneId; });
    var hasDuplicates = duplicates.length > 0;
    
    // Toggle approve submit state
    btnApproveSubmit.disabled = !isAllSelected || hasDuplicates;

    // Show/hide add row button if max limit reached
    if (matrixRows.length >= LOCATIONS.length) {
        addMatrixRowBtn.style.display = 'none';
    } else {
        addMatrixRowBtn.style.display = 'flex';
    }

    matrixContainer.innerHTML = matrixRows.map(function (row, index) {
        var availableZones = row.locationId 
            ? ZONES.filter(function (z) { return z.locationId === row.locationId && z.allowForNew; })
            : [];
            
        var isDup = duplicates.indexOf(row.locationId) > -1 && !!row.locationId;
        var usedLocations = matrixRows.filter(function (r) { return r.id !== row.id && r.locationId; }).map(function (r) { return r.locationId; });

        var locOptions = LOCATIONS.map(function (loc) {
            var disabled = usedLocations.indexOf(loc.id) > -1 ? 'disabled' : '';
            var selected = row.locationId === loc.id ? 'selected' : '';
            var suffix = usedLocations.indexOf(loc.id) > -1 ? ' (đã chọn)' : '';
            return '<option value="' + loc.id + '" ' + selected + ' ' + disabled + '>' + loc.name + suffix + '</option>';
        }).join('');

        var zoneOptions = availableZones.map(function (zone) {
            var selected = row.zoneId === zone.id ? 'selected' : '';
            return '<option value="' + zone.id + '" ' + selected + '>' + zone.name + '</option>';
        }).join('');

        var zoneDisabled = !row.locationId ? 'disabled' : '';
        var deleteDisabled = matrixRows.length === 1 ? 'disabled' : '';
        
        var duplicateErr = isDup ? '<p class="matrix-row-err">⚠ Chi nhánh đã được cấu hình ở hàng khác</p>' : '';
        var rowClass = isDup ? 'matrix-row duplicate' : 'matrix-row';

        return '<div class="' + rowClass + '">' +
            '<div>' +
                '<div class="matrix-row-select-wrap">' +
                    '<svg class="prefix-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/></svg>' +
                    '<select onchange="window.handleMatrixLocChange(\'' + row.id + '\', this.value)">' +
                        '<option value="">-- Chọn kho --</option>' +
                        locOptions +
                    '</select>' +
                    '<svg class="suffix-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>' +
                '</div>' +
                duplicateErr +
            '</div>' +
            
            '<div>' +
                '<div class="matrix-row-select-wrap">' +
                    '<svg class="prefix-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/><path d="M19 12a7 7 0 1 1-14 0 7 7 0 0 1 14 0Z"/></svg>' +
                    '<select ' + zoneDisabled + ' onchange="window.handleMatrixZoneChange(\'' + row.id + '\', this.value)">' +
                        '<option value="">' + (row.locationId ? '-- Chọn khu vực --' : '← Chọn kho trước') + '</option>' +
                        zoneOptions +
                    '</select>' +
                    '<svg class="suffix-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>' +
                '</div>' +
            '</div>' +
            
            '<button class="btn-row-delete" ' + deleteDisabled + ' onclick="window.handleMatrixRowDelete(\'' + row.id + '\')" title="Xóa dòng này">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>' +
            '</button>' +
        '</div>';
    }).join('');
}

window.handleMatrixLocChange = function (rowId, locationId) {
    updateMatrixRowLocation(rowId, locationId);
};
window.handleMatrixZoneChange = function (rowId, zoneId) {
    updateMatrixRowZone(rowId, zoneId);
};
window.handleMatrixRowDelete = function (rowId) {
    deleteMatrixRow(rowId);
};

/* Approve Submit */
if (btnApproveSubmit) {
    btnApproveSubmit.addEventListener('click', function () {
        if (!currentApprovingItem) return;
        
        var id = currentApprovingItem.id;
        var productId = id;
        if (id.indexOf('p-') === 0) {
            productId = id.substring(2);
        }
        
        var formattedConfigs = matrixRows.map(function (row) {
            return {
                locationId: row.locationId,
                zoneId: row.zoneId
            };
        });

        closeApproveModal();
        submitPostAction('approve', {
            productId: productId,
            locationConfigsJson: JSON.stringify(formattedConfigs)
        });
    });
}

/* ─── Reject Modal Logic ───────────────────────────────── */
function openRejectModal(item) {
    rejectIdInput.value = item.id;
    rejectCodeLabel.textContent = item.sku;
    rejectReasonInput.value = '';
    rejectOverlay.classList.add('active');
}

function closeRejectModal() {
    rejectOverlay.classList.remove('active');
}

[btnRejectClose, btnRejectCancel].forEach(function (btn) {
    if (btn) btn.addEventListener('click', closeRejectModal);
});

if (btnRejectSubmit) {
    btnRejectSubmit.addEventListener('click', function () {
        var reason = rejectReasonInput.value.trim();
        if (!reason) {
            alert('Vui lòng nhập lý do từ chối!');
            return;
        }

        var id = rejectIdInput.value;
        var productId = id;
        if (id.indexOf('p-') === 0) {
            productId = id.substring(2);
        }

        closeRejectModal();
        submitPostAction('reject', {
            productId: productId,
            rejectReason: reason
        });
    });
}

/* Click backdrop overlay to close modals */
[approveOverlay, rejectOverlay].forEach(function (overlay) {
    if (overlay) {
        overlay.addEventListener('click', function (e) {
            if (e.target === overlay) {
                overlay.classList.remove('active');
                if (overlay === approveOverlay) closeApproveModal();
                if (overlay === rejectOverlay) closeRejectModal();
            }
        });
    }
});

/* Trigger global approvals */
window.triggerApproveSKU = function (id) {
    var item = skus.find(function (s) { return s.id === id; });
    if (item) openApproveModal(item);
};

window.triggerRejectSKU = function (id) {
    var item = skus.find(function (s) { return s.id === id; });
    if (item) openRejectModal(item);
};

/* CSV Export */
var btnExportCSV = document.getElementById('btnExportCSV');
if (btnExportCSV) {
    btnExportCSV.addEventListener('click', function () {
        var filteredList = getFilteredList();
        var headers = ["Mã SKU", "Tên sản phẩm", "Danh mục", "Khối lượng", "Kích thước", "Tồn kho", "Cấu hình kho", "Trạng thái", "Tạo bởi", "Cập nhật"];
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
                '"' + item.category.replace(/"/g, '""') + '"',
                '"' + item.weight.replace(/"/g, '""') + '"',
                '"' + item.dimensions.replace(/"/g, '""') + '"',
                item.qtyOnHand,
                '"' + locs.replace(/"/g, '""') + '"',
                '"' + statusStr.replace(/"/g, '""') + '"',
                '"' + (item.createdBy || '').replace(/"/g, '""') + '"',
                '"' + (item.lastUpdated || '').replace(/"/g, '""') + '"'
            ];
            csvContent += row.join(",") + "\n";
        });
        
        var blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        var link = document.createElement("a");
        link.href = URL.createObjectURL(blob);
        link.setAttribute("download", "master_sku_approval_" + activeTab + "_" + new Date().toISOString().slice(0, 10) + ".csv");
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    });
}

/* ─── Helpers ─── */
function padZero(n) { return n < 10 ? '0' + n : n; }

function getFilteredList() {
    return skus.filter(function (s) {
        var matchSearch = s.sku.toLowerCase().indexOf(search.toLowerCase()) > -1 || 
                          s.name.toLowerCase().indexOf(search.toLowerCase()) > -1;
        var matchCat    = selectedCategory === 'Tất cả' || s.category === selectedCategory;
        var matchTab    = activeTab === 'all' || s.approvalStatus === activeTab;
        return matchSearch && matchCat && matchTab;
    });
}

function updateTabBadges() {
    var counts = {
        all: skus.length,
        pending: skus.filter(function (s) { return s.approvalStatus === 'pending'; }).length,
        approved: skus.filter(function (s) { return s.approvalStatus === 'approved'; }).length,
        rejected: skus.filter(function (s) { return s.approvalStatus === 'rejected'; }).length
    };
    
    ['all', 'pending', 'approved', 'rejected'].forEach(function (tab) {
        var b = document.getElementById('badge-' + tab);
        if (b) b.textContent = counts[tab];
    });
}

/* ══ RENDER TABLE ══════════════════════════════════════════ */
function renderAll() {
    localStorage.setItem('wms_skus', JSON.stringify(skus));
    updateTabBadges();
    
    var filtered = getFilteredList();

    tableInfo.textContent = 'Hiển thị ' + filtered.length + ' / ' + skus.length + ' SKU';

    if (filtered.length === 0) {
        tableBody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:48px;color:rgba(16, 55, 92, 0.4)">Không tìm thấy sản phẩm SKU nào.</td></tr>';
        return;
    }

    var html = filtered.map(function (item, idx) {
        var acLabel = item.approvalStatus === 'approved' ? 'Đã duyệt' : item.approvalStatus === 'pending' ? 'Chờ duyệt' : 'Từ chối';
        var acClass = item.approvalStatus;

        var isLowStock = item.qtyOnHand < item.minStock;
        var qtyTextClass = isLowStock ? 'stock-qty low-stock' : 'stock-qty normal-stock';

        var specHtml = '<div class="detail-icon-wrap">' +
            '<div class="detail-icon-row">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 3v18M12 3L7 8m5-5 5 5"/></svg>' + item.weight +
            '</div>' +
            '<div class="detail-icon-row">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="9" y1="3" x2="9" y2="21"/></svg>' + item.dimensions +
            '</div>' +
        '</div>';

        var stockHtml = '<div class="stock-val-wrap">';
        if (isLowStock) {
            stockHtml += '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
        }
        stockHtml += '<span class="' + qtyTextClass + '">' + item.qtyOnHand.toLocaleString() + '</span></div>';

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
                    return '<div class="loc-tag">' +
                           '<span class="loc-tag-code">' + (loc ? loc.code : '?') + '</span>' +
                           '<span style="color: rgba(16, 55, 92, 0.3); margin: 0 6px;">→</span>' +
                           '<span>' + (zone ? zone.name : '?') + '</span>' +
                           '</div>';
                }).join('') +
                '</div>';
        }

        var infoHtml = '<div class="info-lbl"><span class="info-lbl-inner">Tạo:</span> ' + item.createdBy + '</div>' +
                       '<div class="info-time">' + item.createdAt + '</div>';
        if (item.updatedBy) {
            infoHtml += '<div class="info-lbl" style="margin-top:4px"><span class="info-lbl-inner">Cập nhật:</span> ' + item.updatedBy + '</div>' +
                        '<div class="info-time">' + item.lastUpdated + '</div>';
        }

        var approvalHtml = '';
        if (item.approvalStatus === 'pending') {
            approvalHtml = '<div style="display:flex;align-items:center;justify-content:center;gap:4px">' +
                '<button class="btn-action approve" onclick="window.triggerApproveSKU(\'' + item.id + '\')" title="Phê duyệt">' +
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M20 6 9 17l-5-5"/></svg>' +
                '</button>' +
                '<button class="btn-action reject" onclick="window.triggerRejectSKU(\'' + item.id + '\')" title="Từ chối">' +
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>' +
                '</button>' +
            '</div>';
        } else {
            approvalHtml = '<span class="pill-badge ' + acClass + '">' + acLabel + '</span>';
            if (item.approvalStatus === 'rejected' && item.reviewNote) {
                approvalHtml += '<div class="review-note" title="' + item.reviewNote + '" style="font-size: 11px; color: #dc2626; margin-top: 4px; max-width: 120px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; text-align: center;">Lý do: ' + item.reviewNote + '</div>';
            }
        }

        var rowClass = idx % 2 === 0 ? '' : 'style="background:rgba(240, 244, 250, 0.25)"';

        return '<tr ' + rowClass + '>' +
            '<td><span class="sku-code-cell">' + item.sku + '</span></td>' +
            '<td><div class="sku-name-cell" title="' + item.name + '">' + item.name + '</div></td>' +
            '<td><span class="sku-cat-cell">' + item.category + '</span></td>' +
            '<td>' + specHtml + '</td>' +
            '<td>' + stockHtml + '</td>' +
            '<td>' + locHtml + '</td>' +
            '<td>' + infoHtml + '</td>' +
            '<td>' + approvalHtml + '</td>' +
        '</tr>';
    }).join('');

    tableBody.innerHTML = html;
}

/* ─── Bootstrap ─── */
renderAll();

})();
</script>
