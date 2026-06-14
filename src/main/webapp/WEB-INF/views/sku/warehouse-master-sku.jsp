<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ page import="com.wms.model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="com.wms.util.JsonUtil" %>
<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    if (products == null) products = java.util.Collections.emptyList();

    String productsJson = JsonUtil.toJson(products);
    request.setAttribute("productsJson", productsJson);
%>

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
        max-width: 680px;
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
    
    /* ─── Tree Picker Styles ─── */
    .category-tree-picker-box {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: 6px;
        padding: 12px 16px;
        min-height: 180px;
        max-height: 280px;
        overflow-y: auto;
    }
    .tree-children-container {
        padding-left: 20px;
        margin-top: 0;
        display: flex;
        flex-direction: column;
        gap: 4px;
        position: relative;
    }
    .tree-node-wrapper {
        position: relative;
    }
    .tree-children-container > .tree-node-wrapper::before {
        content: '';
        position: absolute;
        top: 15px;
        left: -10px;
        width: 14px;
        height: 1px;
        border-top: 1px dashed rgba(16, 55, 92, 0.18);
        z-index: 1;
    }
    .tree-children-container > .tree-node-wrapper::after {
        content: '';
        position: absolute;
        left: -10px;
        top: -15px;
        width: 1px;
        height: calc(100% + 15px);
        border-left: 1px dashed rgba(16, 55, 92, 0.18);
    }
    .tree-children-container > .tree-node-wrapper:last-child::after {
        height: 30px;
    }
    .tree-row {
        display: flex;
        align-items: center;
        gap: 6px;
        padding: 4px 8px;
        background: transparent;
        border: none;
        border-radius: 4px;
        transition: background 0.12s, color 0.12s;
        min-height: 30px;
        cursor: pointer;
    }
    .tree-row:hover {
        background: rgba(16, 55, 92, 0.05);
    }
    .tree-row.selected {
        background: rgba(16, 55, 92, 0.08);
        border-left: 3px solid var(--orange);
        padding-left: 5px; /* Offset for border */
    }
    .tree-row.selected .node-name {
        font-weight: 700;
        color: var(--navy);
    }
    .btn-toggle-chevron {
        width: 18px;
        height: 18px;
        border-radius: 4px;
        border: none;
        background: none;
        color: rgba(16, 55, 92, 0.40);
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: color 0.15s, background 0.15s;
        padding: 0;
    }
    .btn-toggle-chevron:hover {
        color: rgba(16, 55, 92, 0.70);
        background: rgba(16, 55, 92, 0.05);
    }
    .bullet-dot {
        width: 18px;
        height: 18px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .bullet-dot span {
        width: 4px;
        height: 4px;
        border-radius: 50%;
        background: rgba(16, 55, 92, 0.30);
    }
    .folder-icon {
        width: 14px;
        height: 14px;
        flex-shrink: 0;
    }
    .folder-icon.level-1 {
        color: var(--orange);
    }
    .folder-icon.level-2 {
        color: #EB8317;
    }
    .folder-icon.level-3 {
        color: rgba(16, 55, 92, 0.40);
    }
    .node-name {
        font-size: 12.5px;
        color: var(--navy);
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
</style>

<!-- ══ STATS SECTION ═════════════════════════════════════════ -->
<div class="stats-grid-3">
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

    <!-- Card: Low Stock -->
    <div class="sku-card card-red">
        <div class="sku-card__icon">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
        </div>
        <div class="sku-card__info">
            <div class="sku-card__lbl">Sắp hết hàng</div>
            <div class="sku-card__val" id="stat-low-stock-skus">0</div>
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

    <!-- Zone Status Filter -->
    <div class="select-wrap">
        <select id="skuZoneStatusSelect">
            <option value="all">Tất cả trạng thái Zone</option>
            <option value="unassigned">Chưa gán Zone</option>
            <option value="assigned">Đã gán Zone</option>
        </select>
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></svg>
    </div>
    
    <!-- Fixed warehouse label -->
    <div id="myWarehouseLabel" style="margin-left: auto; display: flex; align-items: center; gap: 8px; padding: 8px 14px; background: rgba(16,55,92,0.05); border: 1px solid rgba(16,55,92,0.12); border-radius: calc(var(--radius-btn) - 2px); font-size: 13px; font-weight: 600; color: var(--navy);">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
        <span id="myWarehouseName">Kho của bạn</span>
    </div>
</div>

<!-- ══ TABLE SECTION ═════════════════════════════════════════ -->
<div class="table-card">
    <div class="table-scroll">
        <table class="sku-table">
            <thead>
                <tr>
                    <th style="width: 280px;">Sản phẩm (SKU & Tên)</th>
                    <th style="width: 130px;">Danh mục</th>
                    <th style="width: 150px; text-align: center;">Quy cách vật lý</th>
                    <th style="width: 180px;">Khu vực cất hàng (Zone)</th>
                    <th style="width: 110px; text-align: right;">Định mức (Min/Max)</th>
                    <th style="width: 150px; text-align: center;">Thao tác</th>
                </tr>
            </thead>
            <tbody id="skuTableBody"></tbody>
        </table>
    </div>
    
    <div class="table-footer">
        <span class="table-footer__info" id="skuTableInfo">Hiển thị 0 / 0 SKU</span>
        <span style="margin-right:auto; margin-left:12px; font-size:11px; color:rgba(16,55,92,0.4); font-style:italic;">Danh sách chỉ đọc · Liên hệ Manager để chỉnh sửa thông tin sản phẩm</span>
        <div class="pagination" id="skuPagination"></div>
    </div>
</div>

<!-- ══ ZONE CONFIG MODAL (for Warehouse Staff) ═════════════════ -->
<div class="modal-overlay" id="configModalOverlay">
    <div class="modal-box">
        <div class="modal-hdr">
            <div>
                <h2 class="modal-title">Cấu hình lưu trữ</h2>
                <p class="modal-subtitle" id="config-sku-label">SKU-XXXX</p>
            </div>
            <button class="modal-close" id="configModalClose">&times;</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="config-product-id"/>

            <!-- Locked warehouse badge -->
            <div style="display:flex; align-items:center; gap:8px; padding:10px 14px; background:rgba(16,55,92,0.04); border:1px solid rgba(16,55,92,0.12); border-radius:6px; margin-bottom:4px;">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="rgba(16,55,92,0.5)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                <span style="font-size:12px; color:rgba(16,55,92,0.6);">
                    Áp dụng cho kho: <strong id="config-warehouse-name" style="color:var(--navy);">—</strong>
                </span>
            </div>

            <div class="form-group">
                <label class="form-label" for="config-zone-select">Khu vực cất hàng (Zone)</label>
                <select id="config-zone-select" class="form-input" style="appearance:none; padding:10px 14px;">
                    <option value="">— Chọn khu vực trong kho —</option>
                </select>
                <span style="font-size:11px; color:rgba(16,55,92,0.4);">Chọn Zone nơi mã hàng này sẽ được lưu trữ tại kho của bạn</span>
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label" for="config-min">Tồn tối thiểu (Min)</label>
                    <input class="form-input" type="number" id="config-min" min="0" placeholder="VD: 10"/>
                    <span style="font-size:11px; color:rgba(16,55,92,0.4);">Báo động khi tổng tồn kho xuống dưới mức này</span>
                </div>
                <div class="form-group">
                    <label class="form-label" for="config-max">Tồn tối đa (Max)</label>
                    <input class="form-input" type="number" id="config-max" min="0" placeholder="VD: 200"/>
                    <span style="font-size:11px; color:rgba(16,55,92,0.4);">Ngưỡng tối đa cho phép tại kho này</span>
                </div>
            </div>
            
            <div class="modal-note">
                Cấu hình này chỉ áp dụng cho <strong>kho của bạn</strong>. Không ảnh hưởng đến các chi nhánh kho khác.
            </div>
        </div>
        <div class="modal-ftr">
            <button class="btn-toolbar" id="configModalCancel">Hủy</button>
            <button class="btn-add-sku" id="btnConfigSubmit">Lưu cấu hình</button>
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

<div id="productsJsonData" style="display:none;"><c:out value="${productsJson}"/></div>
<div id="warehousesJsonData" style="display:none;"><c:out value="${warehousesJson}"/></div>
<div id="zonesJsonData" style="display:none;"><c:out value="${zonesJson}"/></div>
<div id="categoriesJsonData" style="display:none;"><c:out value="${categoriesJson}"/></div>

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

/* ─── Data from server ─────────────────────────────────────── */
var skus = [];
try {
    var rawJsonEl = document.getElementById('productsJsonData');
    var rawJson = rawJsonEl ? rawJsonEl.textContent : '';
    if (rawJson && rawJson.trim()) {
        var SERVER_PRODUCTS = JSON.parse(rawJson);
        skus = SERVER_PRODUCTS.map(function(p) {
    return {
        id: 'p-' + p.productId,
        sku: p.skuCode || '',
        name: p.productName || '',
        category: p.categoryName || '',
        dimensions: p.attributesText || 'N/A',
        weight: p.weightKg ? p.weightKg + ' kg' : 'N/A',
                qtyOnHand: Number(p.qtyOnHand || 0),
                minStock: Number(p.minStock || 0),
                maxStock: Number(p.maxStock || 0),
        locationConfigs: p.locationConfigs || [],
                createdBy: p.creatorName || '',
        createdAt: p.createdAt || '',
                updatedBy: p.creatorName || '',
        lastUpdated: p.updatedAt || ''
    };
        });
    }
} catch (e) {
    console.warn('warehouse-master-sku: No server product data');
}

var LOCATIONS = [];
try {
    var rawWarehousesJsonEl = document.getElementById('warehousesJsonData');
    var rawWarehousesJson = rawWarehousesJsonEl ? rawWarehousesJsonEl.textContent : '';
    if (rawWarehousesJson && rawWarehousesJson.trim()) {
        LOCATIONS = JSON.parse(rawWarehousesJson).map(function(w) {
            return { id: w.warehouseId.toString(), name: w.warehouseName, code: w.warehouseCode };
        });
    }
} catch (e) { LOCATIONS = []; }

var ZONES = [];
try {
    var rawZonesJsonEl = document.getElementById('zonesJsonData');
    var rawZonesJson = rawZonesJsonEl ? rawZonesJsonEl.textContent : '';
    if (rawZonesJson && rawZonesJson.trim()) {
        ZONES = JSON.parse(rawZonesJson).map(function(z) {
            return {
                id: z.zoneId.toString(),
                locationId: z.warehouseId.toString(),
                code: z.zoneCode,
                name: z.zoneName,
                zoneType: z.zoneType
            };
        });
    }
} catch (e) { ZONES = []; }

var DB_CATEGORIES = [];
try {
    var rawCategoriesJsonEl = document.getElementById('categoriesJsonData');
    var rawCategoriesJson = rawCategoriesJsonEl ? rawCategoriesJsonEl.textContent : '';
    if (rawCategoriesJson && rawCategoriesJson.trim()) {
        DB_CATEGORIES = JSON.parse(rawCategoriesJson).map(function(c) {
            return { categoryId: c.id, categoryName: c.name, parentId: c.parentId };
        });
    }
} catch (e) {}

/* ─── Helpers ─────────────────────────────────────────────── */
function escapeHtml(str) {
    if (!str) return '';
    return str.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&#039;");
}

function buildCategoryTreeOptions(categories, isFilter) {
    var html = isFilter ? '<option value="Tất cả">Tất cả</option>' : '';
    function recurse(parentId, prefix) {
        categories.filter(function(c) {
            var p = c.parentId;
            return (parentId === null) ? (p === null || p === 0 || p === 'null') : (p == parentId);
        }).forEach(function(node) {
            html += '<option value="' + escapeHtml(node.categoryName) + '">' + prefix + escapeHtml(node.categoryName) + '</option>';
            recurse(node.categoryId, prefix + '    ');
        });
    }
    recurse(null, '');
    return html;
}

function padZero(n) { return n < 10 ? '0' + n : n; }

/* ─── State ──────────────────────────────────────────────── */
var search = '';
var selectedCategory = 'Tất cả';
var currentPage = 1;
var pageSize = 20;

/* ─── Init: set warehouse label ─ */
(function initMyWarehouse() {
    var label = document.getElementById('myWarehouseName');
    if (label && LOCATIONS.length > 0) {
        label.textContent = LOCATIONS[0].name;
    }
if (catSelect && DB_CATEGORIES.length > 0) {
    catSelect.innerHTML = buildCategoryTreeOptions(DB_CATEGORIES, true);
}
})();

/* ─── DOM Elements ───────────────────────────────────────── */
var tableBody  = document.getElementById('skuTableBody');
var tableInfo  = document.getElementById('skuTableInfo');
var pagination = document.getElementById('skuPagination');
var searchInput = document.getElementById('skuSearchInput');
var catSelect   = document.getElementById('skuCategorySelect');

/* Config Modal */
var configOverlay        = document.getElementById('configModalOverlay');
var btnConfigClose      = document.getElementById('configModalClose');
var btnConfigCancel     = document.getElementById('configModalCancel');
var btnConfigSubmit     = document.getElementById('btnConfigSubmit');
var configSkuLabel      = document.getElementById('config-sku-label');
var configProductId     = document.getElementById('config-product-id');
var configZoneSelect    = document.getElementById('config-zone-select');
var configWarehouseName  = document.getElementById('config-warehouse-name');
var configMinInput      = document.getElementById('config-min');
var configMaxInput      = document.getElementById('config-max');

/* View Modal */
var viewOverlay      = document.getElementById('viewModalOverlay');
var btnViewClose    = document.getElementById('viewModalClose');
var btnViewCloseBtn = document.getElementById('viewModalCloseBtn');

/* ─── Config Modal: populate zone select ─────────────────── */
function populateZoneSelect(warehouseId) {
    if (!configZoneSelect) return;
    var zones = ZONES.filter(function(z) { return z.locationId === warehouseId; });
    var html = '<option value="">— Chọn khu vực trong kho —</option>';
    zones.forEach(function(z) {
        html += '<option value="' + z.id + '">' + z.code + ' — ' + z.name + '</option>';
    });
    configZoneSelect.innerHTML = html;
}

/* ─── Config Modal: open & close ────────────────────────── */
window.triggerConfigSKU = function(id) {
    var item = skus.find(function(s) { return s.id === id; });
    if (!item) return;

    configSkuLabel.textContent = item.sku;
    configProductId.value = item.id;
    configMinInput.value = item.minStock || '';
    configMaxInput.value = item.maxStock || '';

    var myLoc = LOCATIONS[0] || null;
    configWarehouseName.textContent = myLoc ? myLoc.name : '—';
    populateZoneSelect(myLoc ? myLoc.id : null);

    if (myLoc && item.locationConfigs) {
        var existing = item.locationConfigs.find(function(c) {
            return c.locationId && c.locationId.toString() === myLoc.id;
        });
        configZoneSelect.value = (existing && existing.zoneId) ? existing.zoneId.toString() : '';
    } else {
        configZoneSelect.value = '';
    }

    configOverlay.classList.add('active');
};

function closeConfigModal() {
    configOverlay.classList.remove('active');
}

if (btnConfigClose) btnConfigClose.addEventListener('click', closeConfigModal);
if (btnConfigCancel) btnConfigCancel.addEventListener('click', closeConfigModal);
if (configOverlay) configOverlay.addEventListener('click', function(e) {
    if (e.target === configOverlay) closeConfigModal();
});

/* ─── Config Submit ──────────────────────────────────────── */
if (btnConfigSubmit) {
    btnConfigSubmit.addEventListener('click', function() {
        var id = configProductId.value;
        var zoneId = configZoneSelect.value;
        var min = parseInt(configMinInput.value) || 0;
        var max = parseInt(configMaxInput.value) || 100;
        var myLoc = LOCATIONS[0];

        if (!myLoc) {
            alert('Không xác định được kho của bạn. Vui lòng liên hệ quản trị.');
            return;
        }

        var item = skus.find(function(s) { return s.id === id; });
        var otherConfigs = [];
        if (item && item.locationConfigs) {
            otherConfigs = item.locationConfigs.filter(function(c) {
                return c.locationId && c.locationId.toString() !== myLoc.id.toString() && c.zoneId;
            });
        }
        var mergedConfigs = otherConfigs.slice();
        if (zoneId) {
            mergedConfigs.push({ locationId: myLoc.id, zoneId: zoneId });
        }

        submitPostAction('edit', {
            productId: id.replace('p-', ''),
            minStock: min,
            maxStock: max,
            locationConfigsJson: JSON.stringify(mergedConfigs)
        });
    });
}

/* ─── View Modal ─────────────────────────────────────────── */
window.triggerViewSKU = function(id) {
    var item = skus.find(function(s) { return s.id === id; });
    if (!item) return;

    document.getElementById('view-sku-code-label').textContent = item.sku;
    document.getElementById('view-name').textContent = item.name;
    document.getElementById('view-category').textContent = item.category;
    document.getElementById('view-dimensions').textContent = item.dimensions || 'N/A';
    document.getElementById('view-weight').textContent = item.weight || 'N/A';
    document.getElementById('view-min').textContent = item.minStock;
    document.getElementById('view-max').textContent = item.maxStock;
    document.getElementById('view-created-by').textContent = item.createdBy || 'N/A';
    document.getElementById('view-created-at').textContent = item.createdAt || 'N/A';
    document.getElementById('view-updated-by').textContent = item.updatedBy || item.createdBy || 'N/A';
    document.getElementById('view-updated-at').textContent = item.lastUpdated || item.createdAt || 'N/A';

    viewOverlay.classList.add('active');
};

if (btnViewClose) btnViewClose.addEventListener('click', function() { viewOverlay.classList.remove('active'); });
if (btnViewCloseBtn) btnViewCloseBtn.addEventListener('click', function() { viewOverlay.classList.remove('active'); });
if (viewOverlay) viewOverlay.addEventListener('click', function(e) {
    if (e.target === viewOverlay) viewOverlay.classList.remove('active');
});

/* ─── Search & Filter ────────────────────────────────────── */
if (searchInput) {
    searchInput.addEventListener('input', function(e) {
        search = e.target.value;
        currentPage = 1;
        renderAll();
    });
}
if (catSelect) {
    catSelect.addEventListener('change', function(e) {
        selectedCategory = e.target.value;
        currentPage = 1;
        renderAll();
    });
}
var zoneStatusSelect = document.getElementById('skuZoneStatusSelect');
if (zoneStatusSelect) {
    zoneStatusSelect.addEventListener('change', function(e) {
        currentPage = 1;
        renderAll();
    });
}

/* ─── Stats ──────────────────────────────────────────────── */
function updateStats(total, active, lowStock) {
    var t = document.getElementById('stat-total-skus');
    var a = document.getElementById('stat-active-skus');
    var l = document.getElementById('stat-low-stock-skus');
    if (t) t.textContent = total.toLocaleString();
    if (a) a.textContent = active.toLocaleString();
    if (l) l.textContent = lowStock.toLocaleString();
}

/* ─── Render Table ────────────────────────────────────────── */
function renderAll() {
    var myLoc = LOCATIONS[0];
    var myLocId = myLoc ? myLoc.id : null;

    var zoneStatusSelect = document.getElementById('skuZoneStatusSelect');
    var selectedZoneStatus = zoneStatusSelect ? zoneStatusSelect.value : 'all';

    var filtered = skus.filter(function(s) {
        var matchSearch = !search ||
            s.sku.toLowerCase().indexOf(search.toLowerCase()) > -1 ||
            s.name.toLowerCase().indexOf(search.toLowerCase()) > -1;
        var matchCat = selectedCategory === 'Tat ca' || selectedCategory === 'Tất cả' || s.category === selectedCategory;
        
        var myConfig = myLocId ? s.locationConfigs.find(function(c) {
            return c.locationId && c.locationId.toString() === myLocId;
        }) : null;
        var hasZone = !!(myConfig && myConfig.zoneId);

        var matchZoneStatus = true;
        if (selectedZoneStatus === 'unassigned') {
            matchZoneStatus = !hasZone;
        } else if (selectedZoneStatus === 'assigned') {
            matchZoneStatus = hasZone;
        }

        return matchSearch && matchCat && matchZoneStatus;
    });

    // Moi SKU do manager tao deu active — activeCount = tong so SKU trong view.
    var activeCount = filtered.length;
    var lowStock = filtered.filter(function(s) { return s.qtyOnHand < s.minStock; }).length;
    updateStats(filtered.length, activeCount, lowStock);
    
    var totalItems = filtered.length;
    var totalPages = Math.ceil(totalItems / pageSize) || 1;
    if (currentPage > totalPages) currentPage = totalPages;
    var startIdx = (currentPage - 1) * pageSize;
    var endIdx = Math.min(startIdx + pageSize, totalItems);
    var paginated = filtered.slice(startIdx, endIdx);
    
    tableInfo.textContent = 'Hiển thị ' + (totalItems > 0 ? startIdx + 1 : 0) + '–' + endIdx + ' / ' + totalItems + ' SKU';
    
    if (paginated.length === 0) {
        tableBody.innerHTML = '<tr><td colspan="6" style="text-align:center;padding:48px;color:rgba(16,55,92,0.4)">Không tìm thấy sản phẩm nào.</td></tr>';
        pagination.innerHTML = '';
        return;
    }
    
    var html = paginated.map(function(item, idx) {
        var isLow = item.qtyOnHand < item.minStock;
        var isOut = item.qtyOnHand === 0;

        var locHtml = '';
        if (myLocId && item.locationConfigs) {
            var myConfig = item.locationConfigs.find(function(c) {
                return c.locationId && c.locationId.toString() === myLocId;
            });
            if (myConfig && myConfig.zoneId) {
                var zone = ZONES.find(function(z) { return z.id === myConfig.zoneId.toString(); });
                if (zone) {
                    locHtml = '<span style="font-size: 13px; color: var(--navy); font-weight: 600;">' + escapeHtml(zone.name) + '</span>';
                }
            }
        }
        if (!locHtml) {
            locHtml = '<span class="loc-unassigned" style="background: rgba(245, 200, 66, 0.15); color: #d9a000; border: 1px solid rgba(245, 200, 66, 0.3); padding: 4px 8px; border-radius: 4px; display: inline-flex; align-items: center; gap: 4px; font-size: 11px; font-weight: 600;">' +
                '⚠️ Chưa cấu hình</span>';
        }

        var isLowOrOut = item.qtyOnHand === 0 || item.qtyOnHand < item.minStock;
        var inboundBtnStyle = isLowOrOut
            ? 'background: rgba(239, 68, 68, 0.1); color: #ef4444; border: 1px solid rgba(239, 68, 68, 0.2);'
            : 'background: rgba(16, 55, 92, 0.05); color: var(--navy); border: 1px solid rgba(16, 55, 92, 0.1);';

        var rowClass = (startIdx + idx) % 2 === 0 ? '' : 'style="background:rgba(240,244,250,0.3)"';

        return '<tr ' + rowClass + '>' +
            '<td>' +
                '<div class="sku-code-cell" style="font-weight: 700; margin-bottom: 2px;">' + escapeHtml(item.sku) + '</div>' +
                '<div class="sku-name-cell" style="font-weight: 700; font-size: 13px;" title="' + escapeHtml(item.name) + '">' + escapeHtml(item.name) + '</div>' +
            '</td>' +
            '<td><div style="font-size: 13px; color: var(--navy);">' + escapeHtml(item.category || '—') + '</div></td>' +
            '<td>' +
                '<div style="font-size: 12px; color: var(--navy); font-weight: 500; text-align: center;">' + escapeHtml(item.dimensions) + '</div>' +
                '<div style="font-size: 11px; color: rgba(16, 55, 92, 0.5); text-align: center;">' + escapeHtml(item.weight) + '</div>' +
            '</td>' +
            '<td>' + locHtml + '</td>' +
            '<td style="text-align: right;">' +
                '<div style="font-size: 13px; color: var(--navy); font-weight: 600;">' + item.minStock + ' / ' + item.maxStock + '</div>' +
            '</td>' +
            '<td style="text-align: center;">' +
                '<div style="display:flex;align-items:center;justify-content:center;gap:8px;">' +
                    '<button class="btn-act-circle edit" onclick="window.triggerConfigSKU(\'' + item.id + '\')" title="Cấu hình Kho" style="width:28px;height:28px;">' +
                        '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>' +
                    '</button>' +
                    '<button class="btn-act-circle" onclick="window.location.href=\'${pageContext.request.contextPath}/warehouse/inbound?action=create&sku=\' + encodeURIComponent(\'' + item.sku + '\')" title="Nhập hàng" style="width:28px;height:28px; ' + inboundBtnStyle + '">' +
                        '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>' +
                    '</button>' +
                '</div>' +
            '</td>' +
        '</tr>';
    }).join('');

    tableBody.innerHTML = html;

    var pageHtml = '';
    for (var p = 1; p <= totalPages; p++) {
        pageHtml += '<button class="page-btn' + (p === currentPage ? ' active' : '') + '" onclick="window.gotoSKUPage(' + p + ')">' + p + '</button>';
    }
    pagination.innerHTML = pageHtml;
}

window.gotoSKUPage = function(p) {
    currentPage = p;
    renderAll();
};

renderAll();

})();
</script>

