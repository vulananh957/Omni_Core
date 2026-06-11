<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<style>
    /* ─── Variables & Base Theme overrides for isolation ─── */
    :root {
        --color-emerald-700: #047857;
        --color-emerald-600: #059669;
        --color-emerald-50: #ecfdf5;
        --color-purple-700: #6d28d9;
        --color-purple-600: #7c3aed;
        --color-purple-50: #f5f3ff;
        --color-amber-700: #b45309;
        --color-amber-600: #d97706;
        --color-amber-50: #fffbeb;
        --color-orange-700: #c2410c;
        --color-orange-600: #ea580c;
        --color-orange-50: #fff7ed;
        --color-red-700: #b91c1c;
        --color-red-600: #dc2626;
        --color-red-50: #fef2f2;
    }

    /* ─── Layout & KPI Cards ─── */
    .doc-stats-grid {
        display: grid;
        grid-template-columns: repeat(5, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }
    @media (max-width: 1024px) {
        .doc-stats-grid { grid-template-columns: repeat(3, 1fr); }
    }
    @media (max-width: 768px) {
        .doc-stats-grid { grid-template-columns: repeat(2, 1fr); }
    }
    .doc-stat-card {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 16px 20px;
        display: flex;
        align-items: center;
        gap: 14px;
        transition: transform 0.2s, box-shadow 0.2s;
    }
    .doc-stat-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(16, 55, 92, 0.05);
    }
    .doc-stat-icon {
        width: 36px; height: 36px;
        border-radius: var(--radius-btn);
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .doc-stat-icon svg { width: 18px; height: 18px; }
    .doc-stat-value {
        font-size: 20px; font-weight: 800; color: var(--navy);
        letter-spacing: -0.02em; line-height: 1;
    }
    .doc-stat-label {
        font-size: 11px; color: rgba(16,55,92,0.50); font-weight: 600; margin-top: 3px;
    }

    /* ─── Attention Alert Banner ─── */
    .doc-alert-banner {
        display: none; align-items: center; gap: 12px;
        padding: 12px 16px; background: #FFFBEB;
        border: 1px solid #FDE68A;
        border-radius: var(--radius-card); margin-bottom: 20px;
        animation: fadeIn 0.3s ease;
    }
    .doc-alert-banner svg { width: 16px; height: 16px; color: #D97706; flex-shrink: 0; }
    .doc-alert-banner p { margin: 0; font-size: 12.5px; color: #92400E; font-weight: 500; }

    .doc-tabs-container {
        display: flex;
        align-items: center;
        gap: 6px;
        margin-bottom: 20px;
        background: #fff;
        border: 1px solid #E5EAF3;
        padding: 6px;
        border-radius: var(--radius-card);
        overflow-x: auto;
        white-space: nowrap;
    }
    .doc-tab-btn {
        position: relative;
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 14px;
        font-size: 12px;
        font-weight: 600;
        color: rgba(16,55,92,0.60);
        background: transparent;
        border: none;
        cursor: pointer;
        border-radius: calc(var(--radius-btn) - 2px);
        transition: all 0.2s;
    }
    .doc-tab-btn svg { width: 14px; height: 14px; }
    .doc-tab-btn:hover {
        color: var(--navy);
        background: rgba(16,55,92,0.03);
    }
    .doc-tab-btn.active {
        color: #fff;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }
    .doc-tab-btn.active.all { background: var(--navy); }
    .doc-tab-btn.active.grn { background: var(--color-emerald-600); }
    .doc-tab-btn.active.gi { background: var(--color-purple-600); }
    .doc-tab-btn.active.kk { background: var(--color-amber-600); }
    .doc-tab-btn.active.tr { background: var(--color-orange-600); }
    .doc-tab-btn.active.rma { background: var(--color-red-600); }

    .doc-tab-count {
        padding: 1px 6px;
        border-radius: 999px;
        font-size: 10px;
        font-weight: 700;
        margin-left: 2px;
    }
    .doc-tab-btn.active .doc-tab-count { background: rgba(255,255,255,0.25); color: #fff; }
    .doc-tab-btn:not(.active) .doc-tab-count { background: rgba(16,55,92,0.08); color: rgba(16,55,92,0.6); }

    .doc-tab-action-badge {
        position: absolute;
        top: -4px; right: -4px;
        width: 15px; height: 15px;
        background: var(--color-red-600);
        color: #fff;
        font-size: 9px;
        font-weight: 850;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 1px 3px rgba(0,0,0,0.2);
    }

    /* ─── Search & Toolbar ─── */
    .doc-toolbar {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 20px;
    }
    .doc-search-wrap {
        position: relative;
        flex: 1;
    }
    .doc-search-icon {
        position: absolute; left: 12px; top: 50%; transform: translateY(-50%);
        width: 15px; height: 15px; color: rgba(16,55,92,0.30); pointer-events: none;
    }
    .doc-search-input {
        width: 100%; padding: 10px 14px 10px 38px;
        background: #fff; border: 1px solid #E5EAF3;
        border-radius: var(--radius-btn);
        font-size: 13px; color: var(--navy); outline: none;
        transition: border-color 0.2s;
    }
    .doc-search-input::placeholder { color: rgba(16,55,92,0.30); }
    .doc-search-input:focus { border-color: rgba(16,55,92,0.40); }
    
    .doc-count-summary {
        font-size: 12.5px;
        color: rgba(16,55,92,0.50);
        white-space: nowrap;
    }

    .btn-doc-create {
        display: flex; align-items: center; gap: 8px;
        padding: 10px 18px;
        background: var(--orange); color: #fff;
        border: none; border-radius: var(--radius-btn);
        font-size: 13px; font-weight: 600; cursor: pointer; white-space: nowrap;
        transition: opacity 0.15s;
    }
    .btn-doc-create:hover { opacity: 0.9; }
    .btn-doc-create svg { width: 15px; height: 15px; }

    .doc-table-card {
        background: #fff;
        border: 1px solid #E5EAF3;
        border-radius: var(--radius-card);
        overflow: hidden;
    }
    .doc-table-wrapper {
        overflow-x: auto;
    }
    .doc-table {
        width: 100%;
        border-collapse: collapse;
        text-align: left;
    }
    .doc-table thead tr {
        background: var(--alice);
        border-bottom: 1px solid #E5EAF3;
    }
    .doc-table thead th {
        padding: 12px 18px;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: rgba(16,55,92,0.50);
        white-space: nowrap;
    }
    .doc-table thead th.text-right { text-align: right; }
    .doc-table thead th.text-center { text-align: center; }

    .doc-table tbody tr {
        border-bottom: 1px solid #E5EAF3;
        transition: background-color 0.15s;
    }
    .doc-table tbody tr:last-child { border-bottom: none; }
    
    .doc-table tbody tr.row-viewable { cursor: pointer; }
    .doc-table tbody tr.row-viewable:hover { background: rgba(240, 245, 250, 0.4); }
    
    .doc-table tbody tr.row-draft { background: rgba(16, 55, 92, 0.01); }
    .doc-table tbody tr.row-pending { background: rgba(217, 119, 6, 0.02); }
    .doc-table tbody tr.row-rejected { background: rgba(220, 38, 38, 0.02); }

    .doc-table tbody td {
        padding: 14px 18px;
        font-size: 13px;
        color: var(--navy);
        vertical-align: middle;
        white-space: nowrap;
    }
    .doc-table tbody td.text-right { text-align: right; }
    .doc-table tbody td.text-center { text-align: center; }

    /* Icons and Badges in Table */
    .doc-type-icon-wrapper {
        width: 32px; height: 32px;
        border-radius: var(--radius-btn);
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .doc-type-icon-wrapper.grn { background: var(--color-emerald-50); color: var(--color-emerald-700); }
    .doc-type-icon-wrapper.gi { background: var(--color-purple-50); color: var(--color-purple-700); }
    .doc-type-icon-wrapper.kk { background: var(--color-amber-50); color: var(--color-amber-700); }
    .doc-type-icon-wrapper.tr { background: var(--color-orange-50); color: var(--color-orange-700); }
    .doc-type-icon-wrapper.rma { background: var(--color-red-50); color: var(--color-red-700); }
    .doc-type-icon-wrapper svg { width: 14px; height: 14px; }

    .doc-id-text { font-family: monospace; font-weight: 700; color: var(--navy); font-size: 13px; }
    
    .doc-type-badge {
        padding: 3px 8px; border-radius: var(--radius-btn);
        font-size: 10px; font-weight: 700; color: #fff;
        display: inline-block; text-align: center;
    }
    .doc-type-badge.grn { background: var(--color-emerald-600); }
    .doc-type-badge.gi { background: var(--color-purple-600); }
    .doc-type-badge.kk { background: var(--color-amber-600); }
    .doc-type-badge.tr { background: var(--color-orange-600); }
    .doc-type-badge.rma { background: var(--color-red-600); }

    .doc-status-badge {
        display: inline-flex; align-items: center; gap: 5px;
        padding: 3px 10px; border-radius: var(--radius-btn);
        font-size: 11px; font-weight: 700;
    }
    .doc-status-dot { width: 6px; height: 6px; border-radius: 50%; }

    /* Action triggers in row */
    .btn-action-submit {
        display: inline-flex; align-items: center; gap: 5px;
        padding: 5px 10px; background: var(--navy); color: #fff;
        border: none; border-radius: calc(var(--radius-btn) - 2px);
        font-size: 11px; font-weight: 600; cursor: pointer;
        transition: opacity 0.15s;
    }
    .btn-action-submit:hover { opacity: 0.9; }
    .btn-action-submit svg { width: 11px; height: 11px; }

    .badge-action-awaiting {
        display: inline-flex; align-items: center; gap: 5px;
        padding: 4px 10px; background: var(--color-amber-50);
        color: var(--color-amber-700); border: 1px solid rgba(217, 119, 6, 0.25);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 11px; font-weight: 600;
    }
    .badge-action-awaiting svg { width: 11px; height: 11px; }

    .btn-action-rma-scan {
        display: inline-flex; align-items: center; gap: 5px;
        padding: 5px 10px; background: var(--color-red-600); color: #fff;
        border: none; border-radius: calc(var(--radius-btn) - 2px);
        font-size: 11px; font-weight: 600; cursor: pointer;
        transition: opacity 0.15s;
    }
    .btn-action-rma-scan:hover { opacity: 0.9; }
    .btn-action-rma-scan svg { width: 11px; height: 11px; }

    .btn-action-view-eye {
        display: inline-flex; align-items: center; justify-content: center;
        width: 28px; height: 28px; background: rgba(16, 55, 92, 0.05);
        color: rgba(16, 55, 92, 0.40); border-radius: calc(var(--radius-btn) - 2px);
        transition: all 0.15s; cursor: pointer;
    }
    .btn-action-view-eye:hover {
        background: rgba(16, 55, 92, 0.10);
        color: var(--navy);
    }
    .btn-action-view-eye svg { width: 14px; height: 14px; }

    .badge-action-rejected {
        display: inline-flex; align-items: center; gap: 4px;
        color: var(--color-red-600); font-weight: 700; font-size: 11px;
    }
    .badge-action-rejected svg { width: 13px; height: 13px; }

    .doc-table-footer {
        padding: 14px 20px;
        background: var(--alice);
        border-top: 1px solid #E5EAF3;
        font-size: 12px;
        color: rgba(16,55,92,0.50);
    }
    .doc-table-footer strong { color: var(--navy); }

    /* ─── Barcode Scan Modal & Standard Overlays ─── */
    .doc-overlay {
        position: fixed; inset: 0;
        background: rgba(16, 55, 92, 0.50);
        backdrop-filter: blur(2px);
        display: flex; align-items: center; justify-content: center;
        z-index: 1000; opacity: 0; pointer-events: none;
        transition: opacity 0.25s ease;
    }
    .doc-overlay.active { opacity: 1; pointer-events: auto; }

    .doc-modal {
        background: #fff;
        padding: 24px;
        width: 100%;
        max-width: 400px;
        box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04);
        border-radius: var(--radius-card);
        transform: translateY(20px);
        transition: transform 0.25s ease;
    }
    .doc-overlay.active .doc-modal { transform: translateY(0); }

    .doc-modal-header {
        display: flex; align-items: center; gap: 12px;
        margin-bottom: 20px;
    }
    .doc-modal-icon-box {
        width: 40px; height: 40px;
        display: flex; align-items: center; justify-content: center;
        border-radius: var(--radius-btn);
        flex-shrink: 0;
    }
    .doc-modal-icon-box.red { background: var(--color-red-50); color: var(--color-red-700); }
    .doc-modal-icon-box.orange { background: var(--color-orange-50); color: var(--color-orange-700); }
    .doc-modal-icon-box svg { width: 20px; height: 20px; }

    .doc-modal-title { font-size: 15px; font-weight: 700; color: var(--navy); margin: 0; }
    .doc-modal-subtitle { font-size: 11.5px; color: rgba(16,55,92,0.50); margin: 2px 0 0; }

    .doc-modal-summary-panel {
        background: var(--alice);
        padding: 12px 14px;
        border-radius: var(--radius-btn);
        margin-bottom: 16px;
    }
    .doc-modal-summary-lbl { font-size: 11px; color: rgba(16,55,92,0.5); margin-bottom: 2px; }
    .doc-modal-summary-id { font-family: monospace; font-size: 13px; font-weight: 700; color: var(--navy); }
    .doc-modal-summary-sub { font-size: 11.5px; color: rgba(16,55,92,0.60); margin-top: 2px; }

    .doc-form-group { margin-bottom: 16px; }
    .doc-form-label {
        display: block; font-size: 12px; font-weight: 600;
        color: rgba(16,55,92,0.60); margin-bottom: 6px;
    }
    .doc-input-wrapper { position: relative; }
    .doc-input-icon {
        position: absolute; left: 12px; top: 50%; transform: translateY(-50%);
        width: 14px; height: 14px; color: rgba(16,55,92,0.3); pointer-events: none;
    }
    .doc-input-field {
        width: 100%; padding: 10px 14px 10px 36px;
        background: #fff; border: 1px solid #E5EAF3;
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px; color: var(--navy); font-family: monospace; outline: none;
        transition: border-color 0.2s;
    }
    .doc-input-field:focus { border-color: rgba(220, 38, 38, 0.35); }

    .doc-modal-desc {
        font-size: 11px; color: rgba(16,55,92,0.40);
        line-height: 1.4; margin-bottom: 20px;
    }

    .doc-modal-actions { display: flex; gap: 8px; }
    .btn-modal-cancel {
        flex: 1; padding: 10px 16px;
        background: var(--alice); border: none;
        color: rgba(16,55,92,0.7); font-size: 13px; font-weight: 600;
        border-radius: calc(var(--radius-btn) - 2px); cursor: pointer;
        transition: background-color 0.15s;
    }
    .btn-modal-cancel:hover { background: rgba(16,55,92,0.06); color: var(--navy); }
    
    .btn-modal-confirm {
        flex: 1; padding: 10px 16px;
        background: var(--color-red-600); border: none;
        color: #fff; font-size: 13px; font-weight: 600;
        border-radius: calc(var(--radius-btn) - 2px); cursor: pointer;
        display: flex; align-items: center; justify-content: center; gap: 6px;
        transition: background-color 0.15s;
    }
    .btn-modal-confirm:hover { background: var(--color-red-700); }
    .btn-modal-confirm:disabled {
        background: #fca5a5; cursor: not-allowed;
    }

    /* ─── Detail Modals (Printable) ─── */
    .doc-detail-modal {
        background: #fff;
        width: 100%;
        max-width: 900px;
        max-h: 92vh;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
        border-radius: var(--radius-card);
        display: flex;
        flex-direction: column;
        overflow: hidden;
        transform: scale(0.95);
        transition: transform 0.2s ease;
    }
    .doc-overlay.active .doc-detail-modal { transform: scale(1); }

    .doc-detail-hdr {
        padding: 14px 20px;
        background: rgba(240, 244, 250, 0.30);
        border-bottom: 1px solid #E5EAF3;
        display: flex; align-items: center; justify-content: center;
        justify-content: space-between;
    }
    .doc-detail-title { font-size: 15px; font-weight: 700; color: var(--navy); margin: 0; }
    
    .doc-detail-actions { display: flex; align-items: center; gap: 8px; }
    .btn-detail-act {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 8px 14px; background: #fff; border: 1px solid #E5EAF3;
        border-radius: calc(var(--radius-btn) - 2px); font-size: 12.5px;
        font-weight: 600; color: var(--navy); cursor: pointer;
        transition: all 0.15s;
    }
    .btn-detail-act:hover { background: var(--alice); }
    .btn-detail-act svg { width: 14px; height: 14px; }
    .btn-detail-act.close {
        width: 32px; height: 32px; padding: 0; justify-content: center;
        border: none; background: transparent; color: rgba(16,55,92,0.40);
        border-radius: 50%;
    }
    .btn-detail-act.close:hover { background: rgba(16,55,92,0.06); color: var(--navy); }
    .btn-detail-act.close svg { width: 20px; height: 20px; }

    .doc-detail-body {
        flex: 1; overflow-y: auto; background: #fff;
    }

    /* ─── Create Document Modal Form ─── */
    .create-modal-layout {
        display: grid; grid-template-columns: 1fr 1fr; gap: 16px;
    }
    .create-modal-span-2 { grid-column: span 2; }
    .doc-select-field {
        width: 100%; padding: 10px 12px;
        background: #fff; border: 1px solid #E5EAF3;
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px; color: var(--navy); outline: none;
    }

    /* ─── PDF Printable CSS ─── */
    .pdf-print-area {
        background: #fff;
        color: var(--navy);
    }
    @media print {
        body * { visibility: hidden; }
        #detailModalOverlay, #detailModalOverlay * { visibility: visible; }
        #detailModalOverlay { position: fixed; inset: 0; width: 100vw; height: 100vh; background: #fff; z-index: 99999; }
        .doc-detail-modal { position: absolute; left: 0; top: 0; width: 100%; height: 100%; max-width: none; max-h: none; box-shadow: none; border-radius: 0; border: none; }
        .doc-detail-hdr, .modal-ftr { display: none !important; }
        .doc-detail-body { overflow: visible !important; }
    }
    
    /* Animation fade */
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(-5px); }
        to { opacity: 1; transform: translateY(0); }
    }

    /* Shipping Label CSS removed */
    .shipping-label-container-unused {
        background: #fff;
        border: 1px solid #E5EAF3;
        border-radius: var(--radius-card);
        padding: 24px;
        margin-bottom: 20px;
    }
    .shipping-label-card {
        border: 2px dashed #10375c;
        border-radius: 8px;
        padding: 24px;
        max-width: 480px;
        margin: 0 auto;
        background: #fff;
        font-family: 'Inter', sans-serif;
    }
    .shipping-label-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        border-bottom: 2px solid #10375c;
        padding-bottom: 12px;
        margin-bottom: 16px;
    }
    .shipping-label-from {
        font-size: 11px;
        color: rgba(16,55,92,0.6);
        line-height: 1.4;
    }
    .shipping-label-to {
        font-size: 13px;
        color: var(--navy);
        text-align: right;
    }
    .shipping-label-to-name {
        font-size: 16px;
        font-weight: 800;
        margin-bottom: 4px;
    }
    .shipping-label-to-addr {
        font-size: 12px;
        line-height: 1.5;
        color: rgba(16,55,92,0.7);
    }
    .shipping-label-ref {
        text-align: center;
        padding: 12px 0;
    }
    .shipping-label-order-id {
        font-size: 22px;
        font-weight: 900;
        color: var(--navy);
        letter-spacing: 0.05em;
    }
    .shipping-label-barcode-placeholder {
        font-family: monospace;
        font-size: 10px;
        color: rgba(16,55,92,0.4);
        text-align: center;
        padding: 8px;
        background: rgba(16,55,92,0.04);
        border-radius: 4px;
        letter-spacing: 3px;
        margin-top: 8px;
    }
    .shipping-label-footer {
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-top: 1px solid #E5EAF3;
        padding-top: 12px;
        margin-top: 16px;
        font-size: 11px;
        color: rgba(16,55,92,0.5);
    }

    /* Delivery Note CSS removed */
    .delivery-note-container-unused {
        background: #fff;
        border: 1px solid #E5EAF3;
        border-radius: var(--radius-card);
        padding: 24px;
        margin-bottom: 20px;
    }
    .delivery-note-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 20px;
        padding-bottom: 16px;
        border-bottom: 1px solid #E5EAF3;
    }
    .delivery-note-title {
        font-size: 18px;
        font-weight: 800;
        color: var(--navy);
    }
    .delivery-note-meta {
        text-align: right;
        font-size: 12px;
        color: rgba(16,55,92,0.6);
        line-height: 1.6;
    }
    .delivery-note-meta strong {
        color: var(--navy);
    }
    .delivery-note-parties {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        margin-bottom: 20px;
    }
    .delivery-note-party-box {
        border: 1px solid #E5EAF3;
        border-radius: 6px;
        padding: 14px;
    }
    .delivery-note-party-label {
        font-size: 10px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.08em;
        color: rgba(16,55,92,0.5);
        margin-bottom: 6px;
    }
    .delivery-note-party-name {
        font-size: 13px;
        font-weight: 700;
        color: var(--navy);
        margin-bottom: 2px;
    }
    .delivery-note-party-detail {
        font-size: 11px;
        color: rgba(16,55,92,0.6);
        line-height: 1.4;
    }
    .delivery-note-table {
        width: 100%;
        border-collapse: collapse;
        border: 1px solid #E5EAF3;
        border-radius: 6px;
        overflow: hidden;
        margin-bottom: 20px;
    }
    .delivery-note-table th {
        background: var(--alice);
        padding: 10px 14px;
        font-size: 10px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: rgba(16,55,92,0.5);
        text-align: left;
        border-bottom: 1px solid #E5EAF3;
    }
    .delivery-note-table td {
        padding: 10px 14px;
        border-bottom: 1px solid #E5EAF3;
        font-size: 12px;
        color: var(--navy);
        vertical-align: middle;
    }
    .delivery-note-table tr:last-child td { border-bottom: none; }
    .delivery-note-total {
        text-align: right;
        padding: 12px 14px;
        background: rgba(16,55,92,0.03);
        border-radius: 6px;
        font-size: 13px;
        font-weight: 700;
        color: var(--navy);
    }
    .delivery-note-sig-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 12px;
        margin-top: 32px;
    }
    .delivery-note-sig-box {
        text-align: center;
    }
    .delivery-note-sig-title {
        font-size: 10px;
        font-weight: 700;
        text-transform: uppercase;
        color: rgba(16,55,92,0.5);
        margin-bottom: 40px;
    }
    .delivery-note-sig-name {
        font-size: 10px;
        color: rgba(16,55,92,0.4);
        font-style: italic;
    }

    /* ─── Print Media for A5 Shipping/Delivery ─── */
    @media print {
        body * { visibility: hidden; }
        .shipping-label-container *,
        .delivery-note-container * { visibility: visible; }
        .shipping-label-container {
            position: absolute; left: 0; top: 0;
            width: 148mm; height: 210mm;
            border: none; border-radius: 0;
            padding: 10mm;
            page-break-inside: avoid;
        }
        .delivery-note-container {
            position: absolute; left: 0; top: 0;
            width: 148mm; height: 210mm;
            border: none; border-radius: 0;
            padding: 10mm;
            page-break-inside: avoid;
        }
        @page { size: A5 portrait; margin: 5mm; }
    }
</style>

<!-- ══ Alert Banner ══ -->
<div class="doc-alert-banner" id="docAlertBanner">
    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
    </svg>
    <p id="docAlertBannerText">Bạn đang có 0 phiếu nháp cần trình duyệt và 0 phiếu hoàn hàng cần quét xác nhận nhập zone.</p>
</div>

<!-- ══ Tabs ══ -->
<div class="doc-tabs-container" id="docTabsContainer">
    <button class="doc-tab-btn active all" data-tab="all">
        Tất cả
        <span class="doc-tab-count" id="count-all">0</span>
    </button>
    <button class="doc-tab-btn grn" data-tab="Phiếu Nhập Kho">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M19 13l-7 7-7-7m14-6l-7 7-7-7"/>
        </svg>
        Nhập Kho
        <span class="doc-tab-count" id="count-grn">0</span>
    </button>
    <button class="doc-tab-btn gi" data-tab="Phiếu Xuất Kho">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M5 11l7-7 7 7M5 19l7-7 7 7"/>
        </svg>
        Xuất Kho
        <span class="doc-tab-count" id="count-gi">0</span>
    </button>
    <button class="doc-tab-btn kk" data-tab="Phiếu Kiểm Kê">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"/>
        </svg>
        Kiểm Kê
        <span class="doc-tab-count" id="count-kk">0</span>
    </button>
    <button class="doc-tab-btn tr" data-tab="Phiếu Chuyển Kho">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"/>
        </svg>
        Chuyển Kho
        <span class="doc-tab-count" id="count-tr">0</span>
    </button>
    <button class="doc-tab-btn rma" data-tab="Phiếu Hoàn Hàng">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/>
            <path stroke-linecap="round" stroke-linejoin="round" d="M3 3v5h5"/>
        </svg>
        Hoàn Hàng
        <span class="doc-tab-count" id="count-rma">0</span>
    </button>

</div>

<!-- ══ Search & Toolbar ══ -->
<div class="doc-toolbar">
    <div class="doc-search-wrap">
        <svg class="doc-search-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
        </svg>
        <input type="text" class="doc-search-input" id="docSearchInput" placeholder="Tìm mã phiếu, loại chứng từ, người tạo..." />
    </div>
    <div class="doc-count-summary" id="docCountSummary">0 / 0 phiếu</div>
</div>

<!-- Shipping Label section removed -->
<div id="shippingLabelSection" style="display:none;">
    <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom: 20px;">
        <h3 style="font-size:15px; font-weight:800; color:var(--navy); margin:0;">Shipping Label</h3>
        <button onclick="window.printShippingLabel()" class="btn-doc-create" style="padding: 8px 14px; font-size:12px;">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/>
                <rect x="6" y="14" width="12" height="8"/>
            </svg>
            In / Print
        </button>
    </div>
    <div class="shipping-label-card" id="shippingLabelCard">
        <div class="shipping-label-header">
            <div class="shipping-label-from">
                <strong>TỪ / FROM:</strong><br/>
                Công Ty TNHH ABC<br/>
                123 Đường Nguyễn Huệ, Quận 1<br/>
                TP. Hồ Chí Minh, Việt Nam<br/>
                Tel: (028) 1234 5678
            </div>
            <div style="text-align:right;">
                <div style="font-size:10px; color:rgba(16,55,92,0.5); text-transform:uppercase; letter-spacing:0.1em; margin-bottom:4px;">Mã vận đơn</div>
                <div id="shippingLabelOrderId" style="font-size:16px; font-weight:900; color:var(--navy);">SOUT-2026XXXX-001</div>
            </div>
        </div>
        <div class="shipping-label-header" style="border-bottom:none; padding-bottom:0; margin-bottom:0;">
            <div style="flex:1;">
                <div style="font-size:10px; color:rgba(16,55,92,0.5); text-transform:uppercase; letter-spacing:0.1em; margin-bottom:4px;">ĐẾN / TO:</div>
                <div id="shippingLabelToName" class="shipping-label-to-name">Nguyễn Văn Khách Hàng</div>
                <div id="shippingLabelToAddr" class="shipping-label-to-addr">Chưa có địa chỉ giao hàng</div>
                <div id="shippingLabelToTel" style="font-size:11px; color:rgba(16,55,92,0.5); margin-top:4px;">Tel: —</div>
            </div>
        </div>
        <div class="shipping-label-ref">
            <div id="shippingLabelBarcodeRef" class="shipping-label-barcode-placeholder">|||| |||| |||| |||| ||||</div>
        </div>
        <div class="shipping-label-footer">
            <span>Ngày gửi: <strong id="shippingLabelDate">—</strong></span>
            <span>Cân nặng: <strong>—</strong></span>
            <span>Số kiện: <strong>1</strong></span>
        </div>
    </div>
</div>

<!-- Delivery Note section removed -->
<div id="deliveryNoteSection" style="display:none;">
    <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom: 20px;">
        <h3 style="font-size:15px; font-weight:800; color:var(--navy); margin:0;">Delivery Note — Phiếu Giao Hàng</h3>
        <button onclick="window.printDeliveryNote()" class="btn-doc-create" style="padding: 8px 14px; font-size:12px;">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/>
                <rect x="6" y="14" width="12" height="8"/>
            </svg>
            In / Print
        </button>
    </div>
    <div id="deliveryNoteCard">
        <div class="delivery-note-header">
            <div>
                <div class="delivery-note-title">PHIẾU GIAO HÀNG</div>
                <div style="font-size:11px; color:rgba(16,55,92,0.5); margin-top:4px;">Delivery Note</div>
            </div>
            <div class="delivery-note-meta">
                <div>Số phiếu: <strong id="dnOrderId">—</strong></div>
                <div>Ngày: <strong id="dnDate">—</strong></div>
                <div>Kho xuất: <strong id="dnWarehouse">—</strong></div>
            </div>
        </div>
        <div class="delivery-note-parties">
            <div class="delivery-note-party-box">
                <div class="delivery-note-party-label">Người gửi</div>
                <div class="delivery-note-party-name">Công Ty TNHH ABC</div>
                <div class="delivery-note-party-detail">123 Nguyễn Huệ, Q.1, TP.HCM</div>
            </div>
            <div class="delivery-note-party-box">
                <div class="delivery-note-party-label">Người nhận</div>
                <div class="delivery-note-party-name" id="dnReceiverName">—</div>
                <div class="delivery-note-party-detail" id="dnReceiverAddr">—</div>
            </div>
        </div>
        <table class="delivery-note-table">
            <thead>
                <tr>
                    <th style="width:40px;">STT</th>
                    <th>Tên sản phẩm</th>
                    <th style="width:80px; text-align:center;">Đơn vị</th>
                    <th style="width:100px; text-align:right;">Số lượng</th>
                </tr>
            </thead>
            <tbody id="dnItemsBody">
                <tr><td colspan="4" style="text-align:center; color:rgba(16,55,92,0.4); padding:32px;">Chưa có dữ liệu sản phẩm</td></tr>
            </tbody>
        </table>
        <div class="delivery-note-total">
            Tổng cộng: <span id="dnTotalQty">0</span> sản phẩm
        </div>
        <div class="delivery-note-sig-grid">
            <div class="delivery-note-sig-box">
                <div class="delivery-note-sig-title">Người giao hàng</div>
                <div class="delivery-note-sig-name">(Ký, ghi rõ họ tên)</div>
            </div>
            <div class="delivery-note-sig-box">
                <div class="delivery-note-sig-title">Người nhận hàng</div>
                <div class="delivery-note-sig-name">(Ký, ghi rõ họ tên)</div>
            </div>
            <div class="delivery-note-sig-box">
                <div class="delivery-note-sig-title">Thủ kho xác nhận</div>
                <div class="delivery-note-sig-name">(Ký, ghi rõ họ tên)</div>
            </div>
        </div>
    </div>
</div>

<!-- ══ Table ══ -->
<div class="doc-table-card" id="documentsTableSection">
    <div class="doc-table-wrapper">
        <table class="doc-table">
            <thead>
                <tr>
                    <th style="padding-left: 20px;">Mã Phiếu</th>
                    <th>Loại Chứng Từ</th>
                    <th>Khu Vực / Kho</th>
                    <th>Người Tạo</th>
                    <th>Ngày Tạo</th>
                    <th class="text-right">Số Mặt Hàng</th>
                    <th class="text-center">Trạng Thái</th>
                    <th class="text-center" style="padding-right: 20px;">Thao Tác</th>
                </tr>
            </thead>
            <tbody id="docTableBody">
                <!-- Javascript will inject table rows dynamically -->
            </tbody>
        </table>
    </div>
    <div class="doc-table-footer" id="docTableFooter">
        Hiển thị <strong>0</strong> / 0 chứng từ • Click vào dòng đã hoàn thành để xem phiếu chi tiết
    </div>
</div>

<!-- ════════════════════════════════════════════════════
     MODALS SECTION
     ════════════════════════════════════════════════════ -->

<!-- 1. Barcode Scanning Modal (RMA Zone) -->
<div class="doc-overlay" id="rmaScanOverlay">
    <div class="doc-modal">
        <div class="doc-modal-header">
            <div class="doc-modal-icon-box red">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v1m0 11v.01M5.938 18h12.124c1.347 0 2.19-1.458 1.516-2.625L13.516 6.125c-.673-1.167-2.358-1.167-3.031 0L4.422 15.375c-.674 1.167.168 2.625 1.516 2.625z"/>
                </svg>
            </div>
            <div>
                <h3 class="doc-modal-title">Xác nhận nhận hàng hoàn</h3>
                <p class="doc-modal-subtitle">Quét mã vận đơn kiện hàng vừa về kho</p>
            </div>
        </div>

        <div class="doc-modal-summary-panel">
            <div class="doc-modal-summary-lbl">Phiếu hoàn hàng</div>
            <div class="doc-modal-summary-id" id="rmaModalDocId">RMA-2026-008</div>
            <div class="doc-modal-summary-sub" id="rmaModalSummarySub">5 kiện hàng · Khu Hoàn Hàng</div>
        </div>

        <div class="doc-form-group">
            <label class="doc-form-label">Mã vận đơn hoàn (quét hoặc nhập tay)</label>
            <div class="doc-input-wrapper">
                <svg class="doc-input-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v1m0 11v.01M5.938 18h12.124c1.347 0 2.19-1.458 1.516-2.625L13.516 6.125c-.673-1.167-2.358-1.167-3.031 0L4.422 15.375c-.674 1.167.168 2.625 1.516 2.625z"/>
                </svg>
                <input type="text" class="doc-input-field" id="rmaBarcodeInput" placeholder="VD: GHTK-2026-005ABC..." autofocus />
            </div>
        </div>

        <p class="doc-modal-desc">
            Sau khi xác nhận, kiện hàng sẽ được ghi nhận vào <strong style="color: var(--color-red-600);">Zone Khiếu Nại</strong> và <em>không</em> tự động cộng lại tồn kho khả dụng.
        </p>

        <div class="doc-modal-actions">
            <button class="btn-modal-cancel" id="btnCancelRmaModal">Hủy</button>
            <button class="btn-modal-confirm" id="btnConfirmRmaModal" disabled>Xác nhận cất Zone</button>
        </div>
    </div>
</div>

<!-- 2. Create Document Modal -->
<div class="doc-overlay" id="createDocOverlay">
    <div class="doc-modal" style="max-width: 500px;">
        <div class="doc-modal-header">
            <div class="doc-modal-icon-box orange">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/>
                </svg>
            </div>
            <div>
                <h3 class="doc-modal-title">Tạo chứng từ kho mới</h3>
                <p class="doc-modal-subtitle">Ghi nhận thông tin phiếu kho trực tiếp vào sổ kho</p>
            </div>
        </div>

        <div class="create-modal-layout">
            <div class="doc-form-group create-modal-span-2">
                <label class="doc-form-label">Loại Chứng Từ</label>
                <select class="doc-select-field" id="createDocType">
                    <option value="Phiếu Nhập Kho">Phiếu Nhập Kho (GRN)</option>
                    <option value="Phiếu Xuất Kho">Phiếu Xuất Kho (GI)</option>
                    <option value="Phiếu Kiểm Kê">Phiếu Kiểm Kê (Physical Check)</option>
                    <option value="Phiếu Chuyển Kho">Phiếu Chuyển Kho (Transfer)</option>
                    <option value="Phiếu Hoàn Hàng">Phiếu Hoàn Hàng (RMA)</option>
                </select>
            </div>

            <div class="doc-form-group">
                <label class="doc-form-label">Mã Phiếu (Auto)</label>
                <input type="text" class="doc-select-field" id="createDocId" style="font-family: monospace; font-weight: 700;" placeholder="GRN-2026-XXXX" />
            </div>

            <div class="doc-form-group">
                <label class="doc-form-label">Trạng Thái Ban Đầu</label>
                <select class="doc-select-field" id="createDocStatus">
                    <!-- Loaded dynamically based on Doc Type -->
                </select>
            </div>

            <div class="doc-form-group create-modal-span-2">
                <label class="doc-form-label">Khu Vực / Kho</label>
                <select class="doc-select-field" id="createDocWarehouse">
                    <!-- Populated dynamically from localStorage `wms_warehouses` or defaults -->
                </select>
            </div>

            <div class="doc-form-group create-modal-span-2" id="createDocPartyGroup">
                <label class="doc-form-label" id="createDocPartyLabel">Đối Tác</label>
                <input type="text" class="doc-select-field" id="createDocParty" placeholder="Nhập tên đối tác hoặc để trống..." />
            </div>

            <div class="doc-form-group">
                <label class="doc-form-label">Người Tạo</label>
                <input type="text" class="doc-select-field" id="createDocCreator" value="Nguyễn Văn An" readonly />
            </div>

            <div class="doc-form-group">
                <label class="doc-form-label">Số Mặt Hàng</label>
                <input type="number" class="doc-select-field" id="createDocItems" value="10" min="1" max="1000" />
            </div>
        </div>

        <div class="doc-modal-actions" style="margin-top: 10px;">
            <button class="btn-modal-cancel" id="btnCancelCreateModal">Hủy</button>
            <button class="btn-doc-create" id="btnConfirmCreateModal" style="flex: 1; justify-content: center;">Tạo Phiếu</button>
        </div>
    </div>
</div>

<!-- 3. Printable Detail Modal Viewer -->
<div class="doc-overlay" id="detailModalOverlay">
    <div class="doc-detail-modal">
        <div class="doc-detail-hdr">
            <h3 class="doc-detail-title" id="detailModalTitle">Chi tiết Phiếu Kho</h3>
            <div class="doc-detail-actions">
                <button class="btn-detail-act" id="btnDetailPrint">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
                    </svg>
                    In PDF
                </button>
                <button class="btn-detail-act" id="btnDetailExcel">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
                    </svg>
                    Xuất Excel
                </button>
                <button class="btn-detail-act close" id="btnDetailClose" aria-label="Đóng chi tiết">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
                    </svg>
                </button>
            </div>
        </div>
        <div class="doc-detail-body" id="detailModalBody">
            <!-- Dynamically populated detail template -->
        </div>
        <div class="modal-ftr" style="background: rgba(240, 244, 250, 0.30); border-top: 1px solid var(--border); padding: 16px 24px; display: flex; justify-content: flex-end;">
            <button class="btn-modal-cancel" id="btnDetailCloseFooter">Đóng cửa sổ</button>
        </div>
    </div>
</div>

<!-- ════════════════════════════════════════════════════
     JAVASCRIPT LOGIC & STATE ENGINE
     ════════════════════════════════════════════════════ -->
<script>
    (function() {
        'use strict';

        // ─── Data Initialization (no seed/hardcoded records initially) ───
        var savedDocs = localStorage.getItem('wms_ledger_docs');
        var docs = savedDocs ? JSON.parse(savedDocs) : [];

        var savedSKUs = localStorage.getItem('wms_skus');
        var PRODUCTS = savedSKUs ? JSON.parse(savedSKUs) : [];

        var savedWarehouses = localStorage.getItem('wms_warehouses');
        var WAREHOUSES = savedWarehouses ? JSON.parse(savedWarehouses) : [];

        // Constants matching React
        var DOC_TYPE_CONFIG = {
            "Phiếu Nhập Kho": {
                icon: '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 13l-7 7-7-7m14-6l-7 7-7-7"/></svg>',
                color: "text-emerald-700",
                bg: "grn",
                shortName: "Nhập kho"
            },
            "Phiếu Xuất Kho": {
                icon: '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M5 11l7-7 7 7M5 19l7-7 7 7"/></svg>',
                color: "text-purple-700",
                bg: "gi",
                shortName: "Xuất kho"
            },
            "Phiếu Kiểm Kê": {
                icon: '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><rect width="8" height="4" x="8" y="2" rx="1" ry="1"/><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><path d="m9 14 2 2 4-4"/></svg>',
                color: "text-amber-700",
                bg: "kk",
                shortName: "Kiểm kê"
            },
            "Phiếu Chuyển Kho": {
                icon: '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"/></svg>',
                color: "text-orange-700",
                bg: "tr",
                shortName: "Chuyển kho"
            },
            "Phiếu Hoàn Hàng": {
                icon: '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/><path stroke-linecap="round" stroke-linejoin="round" d="M3 3v5h5"/></svg>',
                color: "text-red-700",
                bg: "rma",
                shortName: "Hoàn hàng"
            }
        };

        // State variables
        var activeTab = "all";
        var searchQuery = "";
        var selectedDoc = null;
        var rmaDoc = null;

        // Logged-in user fallback
        var loggedInUserFullName = "${fn:escapeXml(not empty loggedInUser ? loggedInUser.fullName : 'Nguyen Van An')}";

        // DOM elements
        var docTableBody = document.getElementById('docTableBody');
        var docSearchInput = document.getElementById('docSearchInput');
        var docCountSummary = document.getElementById('docCountSummary');
        var docTableFooter = document.getElementById('docTableFooter');
        var docAlertBanner = document.getElementById('docAlertBanner');
        var docAlertBannerText = document.getElementById('docAlertBannerText');

        // Tab badge counters DOM
        var countAll = document.getElementById('count-all');
        var countGrn = document.getElementById('count-grn');
        var countGi = document.getElementById('count-gi');
        var countKk = document.getElementById('count-kk');
        var countTr = document.getElementById('count-tr');
        var countRma = document.getElementById('count-rma');

        // Overlay Modals
        var rmaScanOverlay = document.getElementById('rmaScanOverlay');
        var rmaModalDocId = document.getElementById('rmaModalDocId');
        var rmaModalSummarySub = document.getElementById('rmaModalSummarySub');
        var rmaBarcodeInput = document.getElementById('rmaBarcodeInput');
        var btnConfirmRmaModal = document.getElementById('btnConfirmRmaModal');
        var btnCancelRmaModal = document.getElementById('btnCancelRmaModal');

        var createDocOverlay = document.getElementById('createDocOverlay');
        var btnOpenCreateModal = document.getElementById('btnOpenCreateModal');
        var btnCancelCreateModal = document.getElementById('btnCancelCreateModal');
        var btnConfirmCreateModal = document.getElementById('btnConfirmCreateModal');

        var createDocType = document.getElementById('createDocType');
        var createDocId = document.getElementById('createDocId');
        var createDocStatus = document.getElementById('createDocStatus');
        var createDocWarehouse = document.getElementById('createDocWarehouse');
        var createDocPartyGroup = document.getElementById('createDocPartyGroup');
        var createDocPartyLabel = document.getElementById('createDocPartyLabel');
        var createDocParty = document.getElementById('createDocParty');
        var createDocCreator = document.getElementById('createDocCreator');
        var createDocItems = document.getElementById('createDocItems');

        var detailModalOverlay = document.getElementById('detailModalOverlay');
        var detailModalTitle = document.getElementById('detailModalTitle');
        var detailModalBody = document.getElementById('detailModalBody');
        var btnDetailPrint = document.getElementById('btnDetailPrint');
        var btnDetailExcel = document.getElementById('btnDetailExcel');
        var btnDetailClose = document.getElementById('btnDetailClose');
        var btnDetailCloseFooter = document.getElementById('btnDetailCloseFooter');

        // ─── Event Listeners ───
        
        // Search Input
        docSearchInput.addEventListener('input', function(e) {
            searchQuery = e.target.value.trim().toLowerCase();
            renderDocs();
        });

        // Tabs Click
        var tabButtons = document.querySelectorAll('.doc-tab-btn');
        tabButtons.forEach(function(btn) {
            btn.addEventListener('click', function() {
                tabButtons.forEach(function(b) { b.classList.remove('active'); });
                btn.classList.add('active');
                activeTab = btn.getAttribute('data-tab');

                // Show/hide Shipping Label and Delivery Note sections
                var shippingSection = document.getElementById('shippingLabelSection');
                var deliverySection = document.getElementById('deliveryNoteSection');
                var tableSection = document.getElementById('documentsTableSection');

                if (activeTab === 'Shipping Label') {
                    if (shippingSection) shippingSection.style.display = 'block';
                    if (deliverySection) deliverySection.style.display = 'none';
                    if (tableSection) tableSection.style.display = 'none';
                    // Populate from the first GI-type document if available
                    var firstGI = docs.find(function(d) { return d.type === 'Phiếu Xuất Kho'; });
                    if (firstGI) populateShippingLabel(firstGI);
                } else if (activeTab === 'Delivery Note') {
                    if (shippingSection) shippingSection.style.display = 'none';
                    if (deliverySection) deliverySection.style.display = 'block';
                    if (tableSection) tableSection.style.display = 'none';
                    var firstGI = docs.find(function(d) { return d.type === 'Phiếu Xuất Kho'; });
                    if (firstGI) populateDeliveryNote(firstGI);
                } else {
                    if (shippingSection) shippingSection.style.display = 'none';
                    if (deliverySection) deliverySection.style.display = 'none';
                    if (tableSection) tableSection.style.display = 'block';
                }

                renderDocs();
            });
        });

        // ─── Modal Open/Close handlers ───
        
        // RMA Scan Confirm
        rmaBarcodeInput.addEventListener('input', function() {
            btnConfirmRmaModal.disabled = !rmaBarcodeInput.value.trim();
        });
        rmaBarcodeInput.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && rmaBarcodeInput.value.trim()) {
                confirmRmaPackage();
            }
        });
        btnConfirmRmaModal.addEventListener('click', confirmRmaPackage);
        btnCancelRmaModal.addEventListener('click', function() {
            rmaScanOverlay.classList.remove('active');
            rmaDoc = null;
        });

        // Create Modal Open
        if (btnOpenCreateModal) {
            btnOpenCreateModal.addEventListener('click', function() {
                // Setup creator name
                createDocCreator.value = loggedInUserFullName;
                
                // Populating warehouses dynamic select dropdown
                createDocWarehouse.innerHTML = '';
                if (WAREHOUSES.length > 0) {
                    WAREHOUSES.forEach(function(w) {
                        var opt = document.createElement('option');
                        opt.value = w.name;
                        opt.textContent = w.name + " (" + w.code + ")";
                        createDocWarehouse.appendChild(opt);
                    });
                } else {
                    var defaults = ["Khu A - Hàng Thường", "Khu B - Hàng Lạnh", "Khu Hoàn Hàng", "Kho HCM - Quận 1", "Kho HCM - Quận 7", "Kho Đà Nẵng", "Kho Hà Nội"];
                    defaults.forEach(function(d) {
                        var opt = document.createElement('option');
                        opt.value = d;
                        opt.textContent = d;
                        createDocWarehouse.appendChild(opt);
                    });
                }

                // Sync type changes immediately
                handleCreateTypeChange();
                createDocOverlay.classList.add('active');
            });
        }

        if (btnCancelCreateModal) {
            btnCancelCreateModal.addEventListener('click', function() {
                createDocOverlay.classList.remove('active');
            });
        }

        if (createDocType) {
            createDocType.addEventListener('change', handleCreateTypeChange);
        }

        if (btnConfirmCreateModal) {
            btnConfirmCreateModal.addEventListener('click', createNewDocument);
        }

        // Details Closures
        btnDetailClose.addEventListener('click', closeDetails);
        btnDetailCloseFooter.addEventListener('click', closeDetails);
        detailModalOverlay.addEventListener('click', function(e) {
            if (e.target === detailModalOverlay) closeDetails();
        });

        btnDetailPrint.addEventListener('click', function() {
            window.print();
        });
        btnDetailExcel.addEventListener('click', function() {
            alert('Xuất excel chứng từ thành công!');
        });

        // ─── State Modifiers & Core Logic ───

        function isDraft(doc) {
            return doc.type !== "Phiếu Hoàn Hàng" && doc.status === "Nháp";
        }

        function isAwaitingBM(doc) {
            return doc.type !== "Phiếu Hoàn Hàng" && doc.status === "Chờ duyệt";
        }

        function isRMAPendingWH(doc) {
            return doc.type === "Phiếu Hoàn Hàng" && doc.status === "Chờ xác nhận WH";
        }

        function isViewable(doc) {
            return ["Hoàn thành", "Đã duyệt", "Đã xuất", "Đã xử lý", "WH đã xác nhận"].indexOf(doc.status) !== -1;
        }

        function isRejected(doc) {
            return doc.status === "Từ chối";
        }

        function handleCreateTypeChange() {
            var type = createDocType.value;
            var rand = Math.floor(1000 + Math.random() * 9000);
            
            // Prefill ID
            if (type === "Phiếu Nhập Kho") {
                createDocId.value = "GRN-2026-" + rand;
                createDocStatus.innerHTML = '<option value="Nháp">Nháp</option><option value="Chờ duyệt">Chờ duyệt</option><option value="Hoàn thành">Hoàn thành</option>';
                createDocPartyGroup.style.display = 'block';
                createDocPartyLabel.textContent = "Nhà Cung Cấp (Supplier)";
                createDocParty.placeholder = "Tên nhà cung cấp...";
            } else if (type === "Phiếu Xuất Kho") {
                createDocId.value = "GI-2026-" + rand;
                createDocStatus.innerHTML = '<option value="Nháp">Nháp</option><option value="Chờ duyệt">Chờ duyệt</option><option value="Đã duyệt">Đã duyệt</option>';
                createDocPartyGroup.style.display = 'block';
                createDocPartyLabel.textContent = "Khách Hàng (Customer)";
                createDocParty.placeholder = "Tên người nhận...";
            } else if (type === "Phiếu Kiểm Kê") {
                createDocId.value = "KK-2026-" + rand;
                createDocStatus.innerHTML = '<option value="Nháp">Nháp</option><option value="Chờ duyệt">Chờ duyệt</option><option value="Hoàn thành">Hoàn thành</option>';
                createDocPartyGroup.style.display = 'none';
            } else if (type === "Phiếu Chuyển Kho") {
                createDocId.value = "TR-2026-" + rand;
                createDocStatus.innerHTML = '<option value="Nháp">Nháp</option><option value="Hoàn thành">Hoàn thành</option>';
                createDocPartyGroup.style.display = 'none';
            } else if (type === "Phiếu Hoàn Hàng") {
                createDocId.value = "RMA-2026-" + rand;
                createDocStatus.innerHTML = '<option value="Chờ xác nhận WH">Chờ xác nhận WH</option><option value="Đã xử lý">Đã xử lý</option>';
                createDocPartyGroup.style.display = 'block';
                createDocPartyLabel.textContent = "Khách Hàng Hoàn Trả (Customer)";
                createDocParty.placeholder = "Tên khách hàng trả hàng...";
            }
        }

        // Tạo phiếu mới
        function createNewDocument() {
            var id = createDocId.value.trim().toUpperCase();
            if (!id) {
                alert('Vui lòng nhập hoặc sử dụng mã phiếu tự động!');
                return;
            }

            // Check duplicate
            var duplicate = docs.some(function(d) { return d.id === id; });
            if (duplicate) {
                alert('Mã phiếu này đã tồn tại trong hệ thống!');
                return;
            }

            var type = createDocType.value;
            var status = createDocStatus.value;
            var warehouse = createDocWarehouse.value;
            var party = createDocParty.value.trim();
            var itemsCount = parseInt(createDocItems.value) || 1;
            
            // Set status color
            var statusColor = "#6b7280"; // Draft gray
            if (status === "Hoàn thành" || status === "Đã duyệt" || status === "Đã xử lý" || status === "WH đã xác nhận") {
                statusColor = "var(--color-green)";
            } else if (status === "Chờ duyệt" || status === "Chờ xác nhận WH") {
                statusColor = "var(--color-orange)";
            }

            // Generate date string
            var now = new Date();
            var dateString = pad(now.getDate()) + "/" + pad(now.getMonth()+1) + "/" + now.getFullYear() + " " + pad(now.getHours()) + ":" + pad(now.getMinutes());

            // Build mock items array
            var docItems = [];
            for (var i = 0; i < itemsCount; i++) {
                var lotRand = Math.floor(10 + Math.random() * 90);
                var qtyRand = Math.floor(5 + Math.random() * 195);
                var priceRand = Math.random() > 0.5 ? 150000 : 95000;
                
                // Select dynamic SKU if available
                var sku = "SKU-TEMP-" + lotRand;
                var name = "Sản phẩm thử nghiệm " + (i + 1);
                
                if (PRODUCTS.length > 0) {
                    var pIndex = i % PRODUCTS.length;
                    sku = PRODUCTS[pIndex].skuCode || PRODUCTS[pIndex].sku || sku;
                    name = PRODUCTS[pIndex].skuName || PRODUCTS[pIndex].name || name;
                }

                docItems.push({
                    stt: i + 1,
                    sku: sku,
                    name: name,
                    uom: "Cái",
                    lot: "LOT-2026-05-" + lotRand,
                    hsd: "31/12/2028",
                    ordered: qtyRand,
                    received: qtyRand,
                    accepted: qtyRand,
                    rejected: 0,
                    remarks: "",
                    price: priceRand
                });
            }

            var newDoc = {
                id: id,
                type: type,
                date: dateString,
                warehouse: warehouse,
                createdBy: createDocCreator.value,
                items: itemsCount,
                itemsList: docItems,
                status: status,
                statusColor: statusColor,
                supplier: type === "Phiếu Nhập Kho" ? party : undefined,
                customer: (type === "Phiếu Xuất Kho" || type === "Phiếu Hoàn Hàng") ? party : undefined
            };

            docs.unshift(newDoc);
            localStorage.setItem('wms_ledger_docs', JSON.stringify(docs));
            
            // Sync counts immediately
            createDocOverlay.classList.remove('active');
            renderDocs();
        }

        // Trình duyệt phiếu (Draft -> Awaiting Approval)
        window.submitForApproval = function(id, event) {
            if (event) event.stopPropagation();
            docs = docs.map(function(d) {
                if (d.id === id) {
                    d.status = "Chờ duyệt";
                    d.statusColor = "var(--color-orange)";
                }
                return d;
            });
            localStorage.setItem('wms_ledger_docs', JSON.stringify(docs));
            renderDocs();
        };

        // Nhập Zone scan modal open trigger
        window.triggerRmaZoneScan = function(id, event) {
            if (event) event.stopPropagation();
            var target = docs.find(function(d) { return d.id === id; });
            if (!target) return;
            
            rmaDoc = target;
            rmaModalDocId.textContent = rmaDoc.id;
            rmaModalSummarySub.textContent = rmaDoc.items + " kiện hàng · " + rmaDoc.warehouse;
            rmaBarcodeInput.value = "";
            btnConfirmRmaModal.disabled = true;
            
            rmaScanOverlay.classList.add('active');
            setTimeout(function() { rmaBarcodeInput.focus(); }, 100);
        };

        // Xác nhận cất Zone RMA
        function confirmRmaPackage() {
            if (!rmaDoc) return;
            var barcode = rmaBarcodeInput.value.trim();
            if (!barcode) return;

            docs = docs.map(function(d) {
                if (d.id === rmaDoc.id) {
                    d.status = "WH đã xác nhận";
                    d.statusColor = "var(--color-green)";
                    d.remarks = "Mã vận đơn hoàn: " + barcode;
                }
                return d;
            });
            
            localStorage.setItem('wms_ledger_docs', JSON.stringify(docs));
            rmaScanOverlay.classList.remove('active');
            rmaDoc = null;
            renderDocs();
        }

        // Close details modal
        function closeDetails() {
            detailModalOverlay.classList.remove('active');
            selectedDoc = null;
        }

        // Open details modal and build layouts
        window.viewDocDetails = function(id) {
            var target = docs.find(function(d) { return d.id === id; });
            if (!target || !isViewable(target)) return;

            selectedDoc = target;
            detailModalTitle.textContent = "Chi tiết " + selectedDoc.type + " (" + selectedDoc.id + ")";
            
            // Build body content
            detailModalBody.innerHTML = compileDetailTemplate(selectedDoc);
            detailModalOverlay.classList.add('active');
        };

        // ─── Detail Modals HTML Compilers ───
        function compileDetailTemplate(doc) {
            var items = doc.itemsList || [];
            
            // Build date parts
            var day = "29", month = "05", year = "2026", time = "15:30";
            if (doc.date) {
                var dtParts = doc.date.split(" ");
                if (dtParts[0] && dtParts[0].includes("/")) {
                    var parts = dtParts[0].split("/");
                    day = parts[0]; month = parts[1]; year = parts[2];
                }
                if (dtParts[1]) time = dtParts[1];
            }

            if (doc.type === "Phiếu Nhập Kho") {
                var totalOrdered = 0, totalReceived = 0, totalAccepted = 0, totalRejected = 0, totalVal = 0;
                var rowMarkup = "";
                items.forEach(function(it) {
                    totalOrdered += it.ordered || 0;
                    totalReceived += it.received || 0;
                    totalAccepted += it.accepted || 0;
                    totalRejected += it.rejected || 0;
                    totalVal += (it.accepted || 0) * (it.price || 0);

                    rowMarkup += '<tr style="line-height: 2.0;">' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 13px;">' + it.stt + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-family: monospace; font-size: 11px;">' + escapeHtml(it.sku) + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-weight: 600; font-size: 13px;">' + escapeHtml(it.name) + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 12.5px;">' + escapeHtml(it.uom) + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center;">' +
                            '<div style="font-family: monospace; font-size: 11px;">' + escapeHtml(it.lot) + '</div>' +
                            '<div style="font-size: 10.5px; color: rgba(16,55,92,0.4);">HSD: ' + escapeHtml(it.hsd) + '</div>' +
                        '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; color: rgba(16,55,92,0.6);">' + it.ordered + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-weight: 600;">' + it.received + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-weight: 800; background: rgba(16, 185, 129, 0.05); color: #059669;">' + it.accepted + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; background: rgba(239, 68, 68, 0.05); color: ' + (it.rejected > 0 ? '#dc2626' : 'rgba(16, 55, 92, 0.3)') + ';">' + (it.rejected > 0 ? it.rejected : '—') + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 12px; color: rgba(16,55,92,0.6);">' + (it.remarks ? escapeHtml(it.remarks) : '<div style="border-bottom: 1px dashed rgba(16,55,92,0.15); height: 10px;"></div>') + '</td>' +
                    '</tr>';
                });

                var supplier = doc.supplier || "Đối tác bán hàng";

                return '<div class="pdf-print-area" style="padding: 32px; background: #fff; font-family: \'Inter\', sans-serif;">' +
                    '<div style="margin-bottom: 24px;">' +
                        '<h1 style="margin: 0 0 2px; font-size: 24px; font-weight: 850; color: var(--navy); letter-spacing: -0.02em;">PHIẾU NHẬP KHO</h1>' +
                        '<div style="font-size: 13.5px; font-weight: 500; color: rgba(16, 55, 92, 0.50); text-transform: uppercase; letter-spacing: 0.05em;">GOODS RECEIPT NOTE (GRN)</div>' +
                    '</div>' +
                    '<div style="display: flex; align-items: center; gap: 16px; margin-bottom: 24px;">' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Mã Phiếu Nhập (GRN No.)</label>' +
                            '<span style="font-size: 18px; font-weight: 700; color: var(--navy); font-family: monospace;">' + escapeHtml(doc.id) + '</span>' +
                        '</div>' +
                        '<div style="border: 1px solid #E5EAF3; border-radius: var(--radius-btn); padding: 8px 16px; background: #fff; display: flex; flex-direction: column; align-items: center;">' +
                            '<div style="height: 48px; width: 180px; background: rgba(16, 55, 92, 0.05); display: flex; align-items: center; justify-content: center; font-family: monospace; font-size: 10px; color: rgba(16, 55, 92, 0.35); margin-top: 4px;">||||| ' + escapeHtml(doc.id) + ' |||||</div>' +
                        '</div>' +
                    '</div>' +
                    '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px; border-bottom: 1px solid #E5EAF3; padding-bottom: 24px;">' +
                        '<div style="display: flex; flex-direction: column; gap: 16px;">' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Nhà Cung Cấp (Supplier)</label>' +
                                '<div style="font-size: 14px; font-weight: 600; color: var(--navy);">' + escapeHtml(supplier) + '</div>' +
                                '<div style="font-size: 12px; color: rgba(16, 55, 92, 0.60); margin-top: 2px;">Địa chỉ: Khu công nghiệp VSIP, Bình Dương</div>' +
                                '<div style="font-size: 12px; color: rgba(16, 55, 92, 0.60); margin-top: 2px;">SĐT: 028 3823 4567</div>' +
                            '</div>' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Mã Đơn Đặt Hàng (PO Ref.) <span style="color: #ef4444;">*</span></label>' +
                                '<div style="font-size: 16px; font-weight: 700; color: var(--navy);">PO-2026-05-' + Math.floor(100+Math.random()*900) + '</div>' +
                            '</div>' +
                        '</div>' +
                        '<div style="display: flex; flex-direction: column; gap: 16px;">' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Ngày Nhập Kho (GRN Date)</label>' +
                                '<div style="font-size: 14px; color: var(--navy);">' + day + '/' + month + '/' + year + ' - ' + time + '</div>' +
                            '</div>' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Trạng Thái (Status)</label>' +
                                '<span style="display: inline-block; padding: 4px 10px; font-size: 12px; font-weight: 700; color: #047857; background: #ECFDF5; border: 1px solid #A7F3D0; border-radius: var(--radius-btn);">' + escapeHtml(doc.status) + '</span>' +
                            '</div>' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Giá Trị Lô Hàng (Document Value)</label>' +
                                '<div style="font-size: 15px; font-weight: 700; color: var(--navy);">' + totalVal.toLocaleString('vi-VN') + ' VNĐ</div>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                    '<div style="margin-bottom: 24px;">' +
                        '<h2 style="font-size: 15px; font-weight: 700; color: var(--navy); margin-bottom: 16px;">Chi Tiết Hàng Hóa Nhập Kho (Phân Cấp Chất Lượng)</h2>' +
                        '<table style="width: 100%; border-collapse: collapse; border: 2px solid rgba(16, 55, 92, 0.15); margin-bottom: 24px;">' +
                            '<thead>' +
                                '<tr style="background: var(--alice); border-bottom: 2px solid rgba(16, 55, 92, 0.15);">' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; width: 35px;">STT</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Mã SKU</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Tên Sản Phẩm</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">ĐVT</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">Số Lô / HSD</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">SL Đặt Hàng</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">SL Thực Nhận</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; background: rgba(16, 185, 129, 0.05);">SL Chấp Nhận</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; background: rgba(239, 68, 68, 0.05);">SL Từ Chối</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Ghi Chú / Mã Lỗi</th>' +
                                	'</tr>' +
                            '</thead>' +
                            '<tbody>' + rowMarkup +
                                '<tr style="background: rgba(240, 244, 250, 0.5); font-weight: 700; border-t: 2px solid rgba(16, 55, 92, 0.3);">' +
                                    '<td colspan="5" style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 12px; text-align: right;">TỔNG CỘNG:</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 12px; text-align: center;">' + totalOrdered + '</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 12px; text-align: center;">' + totalReceived + '</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 12px; text-align: center; color: #059669; background: rgba(16, 185, 129, 0.05);">' + totalAccepted + '</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 12px; text-align: center; color: #dc2626; background: rgba(239, 68, 68, 0.05);">' + totalRejected + '</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 12px;"></td>' +
                                '</tr>' +
                            '</tbody>' +
                        '</table>' +
                        '<div style="margin-top: 16px; border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 16px; border-radius: var(--radius-btn); display: inline-block;">' +
                            '<span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em;">Tổng Số Bao Kiện/Pallet: </span>' +
                            '<span style="font-size: 13px; font-weight: 700; color: var(--navy);">' + Math.ceil(totalAccepted / 100) + ' Pallet, ' + Math.ceil(totalAccepted / 20) + ' Thùng lớn</span>' +
                        '</div>' +
                    '</div>' +
                    '<div style="margin-top: 24px; display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; text-align: center;">' +
                        '<div>' +
                            '<div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 40px;">Đại Diện Giao Hàng</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 10px; color: rgba(16,55,92,0.40); italic">(Ký, ghi rõ họ tên)</span>' +
                        '</div>' +
                        '<div>' +
                            '<div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 40px;">Nhân Viên QA/QC</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 10px; color: rgba(16,55,92,0.40); italic">(Ký, ghi rõ họ tên)</span>' +
                        '</div>' +
                        '<div>' +
                            '<div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 40px;">Quản Đốc Kho</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 10px; color: rgba(16,55,92,0.40); italic">(Ký, ghi rõ họ tên)</span>' +
                        '</div>' +
                    '</div>' +
                '</div>';
            }

            if (doc.type === "Phiếu Xuất Kho") {
                var totalQty = 0, totalVal = 0;
                var rowMarkup = "";
                items.forEach(function(it) {
                    totalQty += it.received || it.qtyIssued || 0;
                    totalVal += (it.received || it.qtyIssued || 0) * (it.price || 0);

                    rowMarkup += '<tr style="line-height: 1.8;">' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px 12px; text-align: center; font-size: 13px;">' + it.stt + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px 12px; font-weight: 600; font-size: 13px;">' + escapeHtml(it.name) + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px 12px; font-family: monospace; font-size: 11px;">' + escapeHtml(it.sku) + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px 12px; text-align: center; font-size: 12.5px;">' + escapeHtml(it.uom) + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px 12px; text-align: center;">' +
                            '<div style="font-family: monospace; font-size: 11px;">' + escapeHtml(it.lot) + '</div>' +
                            '<div style="font-size: 10.5px; color: rgba(16,55,92,0.4);">HSD: ' + escapeHtml(it.hsd) + '</div>' +
                        '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px 12px; text-align: center; color: rgba(16,55,92,0.6);">' + it.ordered + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px 12px; text-align: center; font-weight: 800; background: rgba(16, 55, 92, 0.05);">' + (it.received || it.qtyIssued) + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px 12px; text-align: right;">' + it.price.toLocaleString('vi-VN') + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px 12px; text-align: right; font-weight: 600;">' + ((it.received || it.qtyIssued) * it.price).toLocaleString('vi-VN') + '</td>' +
                    '</tr>';
                });

                var customer = doc.customer || "Khách hàng mua lẻ";

                return '<div class="pdf-print-area" style="padding: 32px; background: #fff; font-family: \'Inter\', sans-serif;">' +
                    '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 20px;">' +
                        '<div>' +
                            '<div style="font-size: 11.5px; font-weight: 550;">Đơn vị: <span style="font-weight: 750;">Hệ thống Bán hàng Đa kênh ABC</span></div>' +
                            '<div style="font-size: 11.5px; color: rgba(16,55,92,0.60);">Bộ phận: Kho Trung Tâm</div>' +
                        '</div>' +
                        '<div style="text-align: right;">' +
                            '<div style="font-size: 10.5px; color: rgba(16,55,92,0.60);">Mẫu số 02-VT</div>' +
                            '<div style="font-size: 10.5px; color: rgba(16,55,92,0.50);">(Ban hành theo Thông tư số 200/2014/TT-BTC)</div>' +
                        '</div>' +
                    '</div>' +
                    '<div style="text-align: center; margin-bottom: 18px;">' +
                        '<h1 style="margin: 0 0 2px; font-size: 20px; font-weight: 850; color: var(--navy); letter-spacing: -0.01em;">PHIẾU XUẤT KHO</h1>' +
                        '<div style="font-size: 13px; font-weight: 500; color: rgba(16,55,92,0.50); text-transform: uppercase;">GOODS ISSUE NOTE</div>' +
                    '</div>' +
                    '<div style="text-align: center; font-size: 12.5px; color: rgba(16,55,92,0.60); margin-bottom: 24px;">' +
                        'Ngày <span style="border-bottom: 1px dashed rgba(16,55,92,0.3); padding: 0 8px;">' + day + '</span> ' +
                        'tháng <span style="border-bottom: 1px dashed rgba(16,55,92,0.3); padding: 0 8px;">' + month + '</span> ' +
                        'năm <span style="border-bottom: 1px dashed rgba(16,55,92,0.3); padding: 0 8px;">' + year + '</span>' +
                    '</div>' +
                    '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 24px;">' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Số Phiếu (No.)</label>' +
                            '<div style="display: flex; align-items: center; gap: 10px;">' +
                                '<span style="font-size: 16px; font-weight: 700; color: var(--navy); font-family: monospace;">' + escapeHtml(doc.id) + '</span>' +
                            '</div>' +
                        '</div>' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Nợ (Debit)</label>' +
                            '<div style="border-bottom: 1px dashed rgba(16,55,92,0.3); padding-bottom: 2px; font-weight: 700; font-size: 12.5px;">TK 632</div>' +
                        '</div>' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Có (Credit)</label>' +
                            '<div style="border-bottom: 1px dashed rgba(16,55,92,0.3); padding-bottom: 2px; font-weight: 700; font-size: 12.5px;">TK 156</div>' +
                        '</div>' +
                    '</div>' +
                    '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 24px;">' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Họ Tên Người Nhận Hàng</label>' +
                            '<div style="border-bottom: 1px solid rgba(16,55,92,0.15); padding-bottom: 3px; font-weight: 600; font-size: 13.5px;">' + escapeHtml(customer) + '</div>' +
                        '</div>' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Địa Chỉ / Đơn Vị Người Nhận</label>' +
                            '<div style="border-bottom: 1px solid rgba(16,55,92,0.15); padding-bottom: 3px; font-size: 13px;">Hệ thống bán lẻ đa kênh ABC</div>' +
                        '</div>' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Lý Do Xuất Kho</label>' +
                            '<div style="border-bottom: 1px solid rgba(16,55,92,0.15); padding-bottom: 3px; font-weight: 550; font-size: 13px;">Xuất kho phục vụ bán hàng theo vận đơn ' + escapeHtml(doc.id) + '</div>' +
                        '</div>' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Xuất Tại Kho</label>' +
                            '<div style="border-bottom: 1px solid rgba(16,55,92,0.15); padding-bottom: 3px; font-size: 13.5px;">' + escapeHtml(doc.warehouse) + '</div>' +
                        '</div>' +
                    '</div>' +
                    '<div style="margin-bottom: 24px;">' +
                        '<table style="width: 100%; border-collapse: collapse; border: 2px solid rgba(16, 55, 92, 0.15);">' +
                            '<thead>' +
                                '<tr style="background: var(--alice); border-bottom: 2px solid rgba(16, 55, 92, 0.15);">' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; width: 40px;">STT</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Tên/Quy Cách Vật Tư</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Mã Số (SKU)</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">ĐVT</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">Số Lô / HSD</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">SL Yêu Cầu</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; background: rgba(16,55,92,0.05);">SL Thực Xuất</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: right;">Đơn Giá</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 8px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: right;">Thành Tiền</th>' +
                                '</tr>' +
                            '</thead>' +
                            '<tbody>' + rowMarkup +
                                '<tr style="background: rgba(240, 244, 250, 0.5); font-weight: 700; border-t: 2px solid rgba(16, 55, 92, 0.3);">' +
                                    '<td colspan="5" style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px; text-align: right;">CỘNG:</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px; text-align: center;">' + totalQty + '</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px; text-align: center; background: rgba(16,55,92,0.05);">' + totalQty + '</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px;"></td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px; text-align: right;">' + totalVal.toLocaleString('vi-VN') + '</td>' +
                                '</tr>' +
                            '</tbody>' +
                        '</table>' +
                        '<div style="margin-top: 16px; border: 1px solid rgba(16, 55, 92, 0.15); padding: 12px 16px; border-radius: var(--radius-btn);">' +
                            '<span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em;">Tổng Số Tiền (Viết bằng chữ): </span>' +
                            '<span style="font-size: 13px; font-weight: 700; color: var(--navy);">' + numberToVietnameseWords(totalVal) + '</span>' +
                        '</div>' +
                    '</div>' +
                    '<div style="margin-top: 24px; display: grid; grid-template-columns: repeat(5, 1fr); gap: 12px; text-align: center;">' +
                        '<div>' +
                            '<div style="font-size: 10.5px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 30px;">Người Lập Phiếu</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 9px; color: rgba(16,55,92,0.40); italic">(Ký, họ tên)</span>' +
                        '</div>' +
                        '<div>' +
                            '<div style="font-size: 10.5px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 30px;">Người Nhận Hàng</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 9px; color: rgba(16,55,92,0.40); italic">(Ký, họ tên)</span>' +
                        '</div>' +
                        '<div>' +
                            '<div style="font-size: 10.5px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 30px;">Thủ Kho</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 9px; color: rgba(16,55,92,0.40); italic">(Ký, họ tên)</span>' +
                        '</div>' +
                        '<div>' +
                            '<div style="font-size: 10.5px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 30px;">Kế Toán Trưởng</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 9px; color: rgba(16,55,92,0.40); italic">(Ký, họ tên)</span>' +
                        '</div>' +
                        '<div>' +
                            '<div style="font-size: 10.5px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 30px;">Giám Đốc</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 9px; color: rgba(16,55,92,0.40); italic">(Ký, họ tên)</span>' +
                        '</div>' +
                    '</div>' +
                '</div>';
            }

            if (doc.type === "Phiếu Kiểm Kê") {
                var bookTotal = 0, actualTotal = 0, deltaTotal = 0;
                var rowMarkup = "";
                items.forEach(function(it) {
                    var bookVal = it.ordered || 100;
                    var actualVal = it.received || 100;
                    var diffVal = actualVal - bookVal;
                    
                    bookTotal += bookVal;
                    actualTotal += actualVal;
                    deltaTotal += diffVal;

                    var diffText = diffVal === 0 ? "±0" : (diffVal > 0 ? "+" + diffVal : diffVal);
                    var diffColor = diffVal === 0 ? "#059669" : (diffVal > 0 ? "#059669" : "#dc2626");

                    rowMarkup += '<tr style="line-height: 2.0;">' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 13px;">' + it.stt + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-family: monospace; font-size: 11px;">' + escapeHtml(it.sku) + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; font-weight: 600;">' + escapeHtml(it.name) + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 12px;">' + escapeHtml(it.uom) + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; background: rgba(59, 130, 246, 0.05); color: #1d4ed8; font-weight: 600;">' + bookVal + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; background: rgba(249, 115, 22, 0.05); font-weight: 800; font-size: 15px;">' + actualVal + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-weight: 800; color: ' + diffColor + ';">' + diffText + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11.5px; color: rgba(16,55,92,0.6);">' + (diffVal !== 0 ? 'Sai lệch kiểm đếm thực tế' : '<div style="border-bottom: 1px dashed rgba(16,55,92,0.15); height: 10px;"></div>') + '</td>' +
                    '</tr>';
                });

                return '<div class="pdf-print-area" style="padding: 32px; background: #fff; font-family: \'Inter\', sans-serif;">' +
                    '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 16px;">' +
                        '<div>' +
                            '<div style="font-size: 11.5px; font-weight: 550;">Đơn vị: <span style="font-weight: 750;">Công ty TNHH Thương Mại ABC</span></div>' +
                            '<div style="font-size: 11.5px; color: rgba(16,55,92,0.60);">Bộ phận: Kho Trung Tâm</div>' +
                        '</div>' +
                        '<div style="text-align: right;">' +
                            '<div style="font-size: 10.5px; color: rgba(16,55,92,0.60);">Mẫu số 08-VT</div>' +
                            '<div style="font-size: 10.5px; color: rgba(16,55,92,0.50);">(Ban hành theo Thông tư số 200/2014/TT-BTC)</div>' +
                        '</div>' +
                    '</div>' +
                    '<div style="text-align: center; margin-bottom: 18px;">' +
                        '<h1 style="margin: 0 0 2px; font-size: 22px; font-weight: 850; color: var(--navy); letter-spacing: -0.01em;">PHIẾU KIỂM KÊ KHO</h1>' +
                        '<div style="font-size: 13px; font-weight: 500; color: rgba(16,55,92,0.50); text-transform: uppercase;">PHYSICAL INVENTORY COUNT SHEET</div>' +
                    '</div>' +
                    '<div style="text-align: center; font-size: 12px; color: rgba(16,55,92,0.60); margin-bottom: 24px;">' +
                        'Ngày <span style="border-bottom: 1px dashed rgba(16,55,92,0.3); padding: 0 8px;">24</span> ' +
                        'tháng <span style="border-bottom: 1px dashed rgba(16,55,92,0.3); padding: 0 8px;">05</span> ' +
                        'năm <span style="border-bottom: 1px dashed rgba(16,55,92,0.3); padding: 0 8px;">2026</span>' +
                    '</div>' +
                    '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 24px;">' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Số Phiếu Kiểm Kê</label>' +
                            '<div style="font-size: 16px; font-weight: 700; color: var(--navy); font-family: monospace;">' + escapeHtml(doc.id) + '</div>' +
                        '</div>' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Khu Vực Kiểm Kê</label>' +
                            '<div style="font-size: 13.5px; font-weight: 600; color: var(--navy);">' + escapeHtml(doc.warehouse) + '</div>' +
                        '</div>' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Trạng Thái</label>' +
                            '<span style="display: inline-block; padding: 2px 8px; font-size: 11.5px; font-weight: 700; color: #1d4ed8; background: #eff6ff; border: 1px solid #bfdbfe; border-radius: var(--radius-btn);">' + escapeHtml(doc.status) + '</span>' +
                        '</div>' +
                    '</div>' +
                    '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 24px;">' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Người Phụ Trách Kiểm Kê</label>' +
                            '<div style="border-bottom: 1px solid rgba(16,55,92,0.15); padding-bottom: 3px;">' + escapeHtml(doc.createdBy) + '</div>' +
                        '</div>' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Phương Pháp Kiểm Kê</label>' +
                            '<div style="border-bottom: 1px solid rgba(16,55,92,0.15); padding-bottom: 3px; font-weight: 550;">Kiểm kê định kỳ toàn bộ</div>' +
                        '</div>' +
                    '</div>' +
                    '<div style="margin-bottom: 24px;">' +
                        '<h2 style="font-size: 15px; font-weight: 700; color: var(--navy); margin-bottom: 12px;">Bảng Kiểm Kê Hàng Hóa (Phân Tích Chênh Lệch)</h2>' +
                        '<table style="width: 100%; border-collapse: collapse; border: 2px solid rgba(16, 55, 92, 0.15);">' +
                            '<thead>' +
                                '<tr style="background: var(--alice); border-bottom: 2px solid rgba(16, 55, 92, 0.15);">' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; width: 35px;">STT</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Mã SKU</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Tên Sản Phẩm</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">ĐVT</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; background: rgba(59, 130, 246, 0.05); color: #1d4ed8;">SL Sổ Sách</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; background: rgba(249, 115, 22, 0.05); color: #c2410c;">SL Thực Tế</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">Chênh Lệch</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Ghi Chú / Nguyên Nhân</th>' +
                                '</tr>' +
                            '</thead>' +
                            '<tbody>' + rowMarkup +
                                '<tr style="background: rgba(240, 244, 250, 0.5); font-weight: 700; border-t: 2px solid rgba(16, 55, 92, 0.3);">' +
                                    '<td colspan="4" style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px; text-align: right;">TỔNG CỘNG:</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px; text-align: center; color: #1d4ed8; background: rgba(59, 130, 246, 0.05);">' + bookTotal + '</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px; text-align: center; color: var(--navy); background: rgba(249, 115, 22, 0.05);">' + actualTotal + '</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px; text-align: center; color: ' + (deltaTotal < 0 ? '#dc2626' : '#059669') + ';">' + (deltaTotal >= 0 ? "+" + deltaTotal : deltaTotal) + '</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px;"></td>' +
                                '</tr>' +
                            '</tbody>' +
                        '</table>' +
                    '</div>' +
                    '<div style="margin-top: 24px; display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; text-align: center;">' +
                        '<div>' +
                            '<div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 40px;">Người Kiểm Kê</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 9.5px; color: rgba(16,55,92,0.40); italic">(Ký, họ tên)</span>' +
                        '</div>' +
                        '<div>' +
                            '<div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 40px;">Thủ Kho</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 9.5px; color: rgba(16,55,92,0.40); italic">(Ký, họ tên)</span>' +
                        '</div>' +
                        '<div>' +
                            '<div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 40px;">Kế Toán Kho</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 9.5px; color: rgba(16,55,92,0.40); italic">(Ký, họ tên)</span>' +
                        '</div>' +
                        '<div>' +
                            '<div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 40px;">Quản Lý Kho</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 9.5px; color: rgba(16,55,92,0.40); italic">(Ký, họ tên)</span>' +
                        '</div>' +
                    '</div>' +
                '</div>';
            }

            if (doc.type === "Phiếu Chuyển Kho") {
                var reqTotal = 0, transTotal = 0;
                var rowMarkup = "";
                items.forEach(function(it) {
                    reqTotal += it.ordered || 100;
                    transTotal += it.received || 100;

                    rowMarkup += '<tr style="line-height: 2.0;">' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 13px;">' + it.stt + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-family: monospace; font-size: 11px;">' + escapeHtml(it.sku) + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; font-weight: 600;">' + escapeHtml(it.name) + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 12px;">' + escapeHtml(it.uom) + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-family: monospace; font-size: 10px;">' + escapeHtml(it.lot) + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; background: rgba(59, 130, 246, 0.05); color: #1d4ed8; font-weight: 600;">' + it.ordered + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; background: rgba(16, 185, 129, 0.05); color: #059669; font-weight: 800; font-size: 15px;">' + it.received + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11.5px; color: rgba(16,55,92,0.6);">' + (it.remarks ? escapeHtml(it.remarks) : '<div style="border-bottom: 1px dashed rgba(16,55,92,0.15); height: 10px;"></div>') + '</td>' +
                    '</tr>';
                });

                return '<div class="pdf-print-area" style="padding: 32px; background: #fff; font-family: \'Inter\', sans-serif;">' +
                    '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 16px;">' +
                        '<div>' +
                            '<div style="font-size: 11.5px; font-weight: 550;">Đơn vị: <span style="font-weight: 750;">Công ty TNHH Thương Mại ABC</span></div>' +
                            '<div style="font-size: 11.5px; color: rgba(16,55,92,0.60);">Bộ phận: Vận Hành Kho</div>' +
                        '</div>' +
                        '<div style="text-align: right;">' +
                            '<div style="font-size: 10.5px; color: rgba(16,55,92,0.60);">Mẫu số TR-WMS</div>' +
                            '<div style="font-size: 10.5px; color: rgba(16,55,92,0.50);">Internal Transfer Note</div>' +
                        '</div>' +
                    '</div>' +
                    '<div style="text-align: center; margin-bottom: 18px;">' +
                        '<h1 style="margin: 0 0 2px; font-size: 22px; font-weight: 850; color: var(--navy); letter-spacing: -0.01em;">PHIẾU CHUYỂN KHO</h1>' +
                        '<div style="font-size: 13px; font-weight: 500; color: rgba(16,55,92,0.50); text-transform: uppercase;">INTERNAL STOCK TRANSFER NOTE (STN)</div>' +
                    '</div>' +
                    '<div style="text-align: center; font-size: 12px; color: rgba(16,55,92,0.60); margin-bottom: 24px;">' +
                        'Ngày <span style="border-bottom: 1px dashed rgba(16,55,92,0.3); padding: 0 8px;">24</span> ' +
                        'tháng <span style="border-bottom: 1px dashed rgba(16,55,92,0.3); padding: 0 8px;">05</span> ' +
                        'năm <span style="border-bottom: 1px dashed rgba(16,55,92,0.3); padding: 0 8px;">2026</span>' +
                    '</div>' +
                    '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 24px;">' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Số Phiếu Chuyển Kho</label>' +
                            '<div style="font-size: 16px; font-weight: 700; color: var(--navy); font-family: monospace;">' + escapeHtml(doc.id) + '</div>' +
                        '</div>' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Trạng Thái</label>' +
                            '<span style="display: inline-block; padding: 2px 8px; font-size: 11.5px; font-weight: 700; color: #c2410c; background: #fff7ed; border: 1px solid #ffedd5; border-radius: var(--radius-btn);">' + escapeHtml(doc.status) + '</span>' +
                        '</div>' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Ngày Yêu Cầu Hoàn Thành</label>' +
                            '<div style="font-size: 13.5px; font-weight: 600;">25/05/2026</div>' +
                        '</div>' +
                    '</div>' +
                    '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px;">' +
                        '<div style="background: #f0f7ff; border: 1px solid #c2e0ff; padding: 14px; border-radius: var(--radius-btn);">' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: #1d4ed8; letter-spacing: 0.05em; margin-bottom: 6px;">🏭 KHO NGUỒN (From)</label>' +
                            '<div style="font-size: 15px; font-weight: 700; color: var(--navy);">Kho HCM - Quận 1</div>' +
                            '<div style="font-family: monospace; font-size: 11px; color: rgba(16,55,92,0.6); margin-top: 2px;">WH-HCM-01</div>' +
                            '<div style="font-size: 12px; color: rgba(16,55,92,0.5); margin-top: 4px;">Khu A - Hàng Thường</div>' +
                        '</div>' +
                        '<div style="background: #ecfdf5; border: 1px solid #a7f3d0; padding: 14px; border-radius: var(--radius-btn);">' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: #047857; letter-spacing: 0.05em; margin-bottom: 6px;">🎯 KHO ĐÍCH (To)</label>' +
                            '<div style="font-size: 15px; font-weight: 700; color: var(--navy);">' + escapeHtml(doc.warehouse) + '</div>' +
                            '<div style="font-family: monospace; font-size: 11px; color: rgba(16,55,92,0.6); margin-top: 2px;">WH-HCM-07</div>' +
                            '<div style="font-size: 12px; color: rgba(16,55,92,0.5); margin-top: 4px;">Khu B - Hàng Thường</div>' +
                        '</div>' +
                    '</div>' +
                    '<div style="margin-bottom: 24px;">' +
                        '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Lý Do / Ghi Chú Điều Chuyển</label>' +
                        '<div style="border-bottom: 1px solid rgba(16,55,92,0.15); padding-bottom: 3px; font-size: 13.5px; font-weight: 550;">Điều chuyển nội bộ cân bằng tồn kho chi nhánh</div>' +
                    '</div>' +
                    '<div style="margin-bottom: 24px;">' +
                        '<h2 style="font-size: 15px; font-weight: 700; color: var(--navy); margin-bottom: 12px;">Danh Sách Hàng Hóa Điều Chuyển</h2>' +
                        '<table style="width: 100%; border-collapse: collapse; border: 2px solid rgba(16, 55, 92, 0.15);">' +
                            '<thead>' +
                                '<tr style="background: var(--alice); border-bottom: 2px solid rgba(16, 55, 92, 0.15);">' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; width: 35px;">STT</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Mã SKU</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Tên Sản Phẩm</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">ĐVT</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">Số Lô</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; background: rgba(59, 130, 246, 0.05); color: #1d4ed8;">SL Yêu Cầu</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; background: rgba(16, 185, 129, 0.05); color: #059669;">SL Thực Chuyển</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Ghi Chú</th>' +
                                '</tr>' +
                            '</thead>' +
                            '<tbody>' + rowMarkup +
                                '<tr style="background: rgba(240, 244, 250, 0.5); font-weight: 700; border-t: 2px solid rgba(16, 55, 92, 0.3);">' +
                                    '<td colspan="5" style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px; text-align: right;">TỔNG CỘNG:</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px; text-align: center; color: #1d4ed8; background: rgba(59, 130, 246, 0.05);">' + reqTotal + '</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px; text-align: center; color: #059669; background: rgba(16, 185, 129, 0.05);">' + transTotal + '</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px;"></td>' +
                                '</tr>' +
                            '</tbody>' +
                        '</table>' +
                    '</div>' +
                    '<div style="margin-top: 24px; display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; text-align: center;">' +
                        '<div>' +
                            '<div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 40px;">Người Lập Phiếu</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 9.5px; color: rgba(16,55,92,0.40); italic">(Ký, họ tên)</span>' +
                        '</div>' +
                        '<div>' +
                            '<div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 40px;">Thủ Kho Xuất</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 9.5px; color: rgba(16,55,92,0.40); italic">(Ký, họ tên)</span>' +
                        '</div>' +
                        '<div>' +
                            '<div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 40px;">Thủ Kho Nhận</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 9.5px; color: rgba(16,55,92,0.40); italic">(Ký, họ tên)</span>' +
                        '</div>' +
                        '<div>' +
                            '<div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 40px;">Quản Lý Duyệt</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 9.5px; color: rgba(16,55,92,0.40); italic">(Ký, họ tên)</span>' +
                        '</div>' +
                    '</div>' +
                '</div>';
            }

            if (doc.type === "Phiếu Hoàn Hàng") {
                var totalRet = 0, totalVal = 0;
                var rowMarkup = "";
                items.forEach(function(it) {
                    totalRet += it.ordered || 5;
                    totalVal += (it.ordered || 5) * (it.price || 95000);

                    rowMarkup += '<tr style="line-height: 2.0;">' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 13px;">' + it.stt + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-family: monospace; font-size: 11px;">' + escapeHtml(it.sku) + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; font-weight: 600;">' + escapeHtml(it.name) + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 12px;">' + escapeHtml(it.uom) + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-weight: 700; font-size: 14px;">' + it.ordered + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; background: rgba(16, 185, 129, 0.05); color: #059669; font-weight: 700;">' + it.received + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; background: rgba(239, 68, 68, 0.05); color: #dc2626; font-weight: 700;">' + it.rejected + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: right;">' + (it.ordered * it.price).toLocaleString("vi-VN") + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; color: rgba(16,55,92,0.60);">' + (doc.remarks ? escapeHtml(doc.remarks) : 'Trả hàng hoàn QC phân cấp') + '</td>' +
                    '</tr>';
                });

                var customer = doc.customer || "Khách hàng mua lẻ";

                return '<div class="pdf-print-area" style="padding: 32px; background: #fff; font-family: \'Inter\', sans-serif;">' +
                    '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 16px;">' +
                        '<div>' +
                            '<div style="font-size: 11.5px; font-weight: 550;">Đơn vị: <span style="font-weight: 750;">Hệ thống Bán hàng Đa kênh ABC</span></div>' +
                            '<div style="font-size: 11.5px; color: rgba(16,55,92,0.60);">Bộ phận: Kho / Dịch Vụ Khách Hàng</div>' +
                        '</div>' +
                        '<div style="text-align: right;">' +
                            '<div style="font-size: 10.5px; color: rgba(16,55,92,0.60);">Mẫu số RMA-VN</div>' +
                            '<div style="font-size: 10.5px; color: rgba(16,55,92,0.50);">Return Merchandise Authorization</div>' +
                        '</div>' +
                    '</div>' +
                    '<div style="text-align: center; margin-bottom: 18px;">' +
                        '<h1 style="margin: 0 0 2px; font-size: 22px; font-weight: 850; color: var(--navy); letter-spacing: -0.01em;">PHIẾU NHẬN HÀNG HOÀN / YÊU CẦU RMA</h1>' +
                        '<div style="font-size: 13px; font-weight: 500; color: rgba(16,55,92,0.50); text-transform: uppercase;">RETURN MERCHANDISE AUTHORIZATION (RMA)</div>' +
                    '</div>' +
                    '<div style="text-align: center; font-size: 12px; color: rgba(16,55,92,0.60); margin-bottom: 24px;">' +
                        'Ngày <span style="border-bottom: 1px dashed rgba(16,55,92,0.3); padding: 0 8px;">24</span> ' +
                        'tháng <span style="border-bottom: 1px dashed rgba(16,55,92,0.3); padding: 0 8px;">05</span> ' +
                        'năm <span style="border-bottom: 1px dashed rgba(16,55,92,0.3); padding: 0 8px;">2026</span>' +
                    '</div>' +
                    '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 24px;">' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Số Phiếu RMA</label>' +
                            '<div style="font-size: 16px; font-weight: 700; color: var(--navy); font-family: monospace;">' + escapeHtml(doc.id) + '</div>' +
                        '</div>' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Mã Đơn Hàng Gốc (SO Ref.)</label>' +
                            '<div style="font-size: 15px; font-weight: 700; color: var(--navy);">SO-2026-' + Math.floor(100000+Math.random()*900000) + '</div>' +
                        '</div>' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Trạng Trạng Thái</label>' +
                            '<span style="display: inline-block; padding: 2px 8px; font-size: 11.5px; font-weight: 700; color: #b91c1c; background: #fef2f2; border: 1px solid #fca5a5; border-radius: var(--radius-btn);">' + escapeHtml(doc.status) + '</span>' +
                        '</div>' +
                    '</div>' +
                    '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px;">' +
                        '<div style="background: #fef2f2; border: 1px solid #fca5a5; padding: 14px; border-radius: var(--radius-btn);">' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: #b91c1c; letter-spacing: 0.05em; margin-bottom: 6px;">👤 KHÁCH HÀNG HOÀN TRẢ</label>' +
                            '<div style="font-size: 15px; font-weight: 700; color: var(--navy);">' + escapeHtml(customer) + '</div>' +
                            '<div style="font-size: 12px; color: rgba(16,55,92,0.6); margin-top: 2px;">SĐT: 0901 234 567</div>' +
                            '<div style="font-size: 12px; color: rgba(16,55,92,0.5); margin-top: 2px;">Email: ' + customer.toLowerCase().replace(/\s+/g, '') + '@email.com</div>' +
                        '</div>' +
                        '<div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Lý Do Hoàn Trả (Return Reason)</label>' +
                            '<div style="font-size: 13.5px; font-weight: 550;">Khách yêu cầu hoàn trả do hàng bị lỗi QC</div>' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); letter-spacing: 0.05em; margin-top: 14px; margin-bottom: 4px;">Hướng Xử Lý</label>' +
                            '<span style="display: inline-block; padding: 2px 8px; font-size: 11.5px; font-weight: 700; color: #c2410c; background: #fff7ed; border: 1px solid #ffedd5; border-radius: var(--radius-btn);">Hoàn trả cất zone khiếu nại</span>' +
                        '</div>' +
                    '</div>' +
                    '<div style="margin-bottom: 24px;">' +
                        '<h2 style="font-size: 15px; font-weight: 700; color: var(--navy); margin-bottom: 12px;">Danh Sách Hàng Hóa Hoàn Trả (Phân Cấp QC)</h2>' +
                        '<table style="width: 100%; border-collapse: collapse; border: 2px solid rgba(16, 55, 92, 0.15);">' +
                            '<thead>' +
                                '<tr style="background: var(--alice); border-bottom: 2px solid rgba(16, 55, 92, 0.15);">' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; width: 35px;">STT</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Mã SKU</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Tên Sản Phẩm</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">ĐVT</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">SL Hoàn</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; background: rgba(16, 185, 129, 0.05); color: #059669;">SL Dùng Lại</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; background: rgba(239, 68, 68, 0.05); color: #dc2626;">SL Tiêu Hủy</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: right;">Giá Trị Hoàn</th>' +
                                    '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Lý Do / Mã Lỗi</th>' +
                                '</tr>' +
                            '</thead>' +
                            '<tbody>' + rowMarkup +
                                '<tr style="background: rgba(240, 244, 250, 0.5); font-weight: 700; border-t: 2px solid rgba(16, 55, 92, 0.3);">' +
                                    '<td colspan="4" style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px; text-align: right;">TỔNG CỘNG:</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px; text-align: center;">' + totalRet + '</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px; text-align: center; color: #059669; background: rgba(16, 185, 129, 0.05);">—</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px; text-align: center; color: #dc2626; background: rgba(239, 68, 68, 0.05);">' + totalRet + '</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px; text-align: right;">' + totalVal.toLocaleString("vi-VN") + '</td>' +
                                    '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px;"></td>' +
                                '</tr>' +
                            '</tbody>' +
                        '</table>' +
                        '<div style="margin-top: 16px; border: 1px solid rgba(16, 55, 92, 0.15); padding: 12px 16px; border-radius: var(--radius-btn);">' +
                            '<span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em;">Tổng Giá Trị Hoàn Trả (Viết bằng chữ): </span>' +
                            '<span style="font-size: 13px; font-weight: 700; color: var(--navy);">' + numberToVietnameseWords(totalVal) + '</span>' +
                        '</div>' +
                    '</div>' +
                    '<div style="margin-top: 24px; display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; text-align: center;">' +
                        '<div>' +
                            '<div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 40px;">Khách Hàng Ký Nhận</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 9.5px; color: rgba(16,55,92,0.40); italic">(Ký, họ tên)</span>' +
                        '</div>' +
                        '<div>' +
                            '<div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 40px;">Nhân Viên Tiếp Nhận</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 9.5px; color: rgba(16,55,92,0.40); italic">(Ký, họ tên)</span>' +
                        '</div>' +
                        '<div>' +
                            '<div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 40px;">QC Kiểm Duyệt</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 9.5px; color: rgba(16,55,92,0.40); italic">(Ký, họ tên)</span>' +
                        '</div>' +
                        '<div>' +
                            '<div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16,55,92,0.50); margin-bottom: 40px;">Kế Toán Xác Nhận</div>' +
                            '<div style="border-bottom: 2px solid rgba(16,55,92,0.15); width: 80%; margin: 0 auto 4px;"></div>' +
                            '<span style="font-size: 9.5px; color: rgba(16,55,92,0.40); italic">(Ký, họ tên)</span>' +
                        '</div>' +
                    '</div>' +
                '</div>';
            }

            return '<div style="padding: 24px; text-align: center; color: rgba(16,55,92,0.4);">Không thể nhận dạng loại chứng từ hoặc chưa có thông tin hiển thị.</div>';
        }

        // Core Render List & stats logic
        function renderDocs() {
            var html = "";
            var actionableDraft = 0;
            var actionableRma = 0;

            // Counts of each type
            var countMap = {
                all: docs.length,
                grn: 0,
                gi: 0,
                kk: 0,
                tr: 0,
                rma: 0
            };

            docs.forEach(function(d) {
                if (d.type === "Phiếu Nhập Kho") countMap.grn++;
                if (d.type === "Phiếu Xuất Kho") countMap.gi++;
                if (d.type === "Phiếu Kiểm Kê") countMap.kk++;
                if (d.type === "Phiếu Chuyển Kho") countMap.tr++;
                if (d.type === "Phiếu Hoàn Hàng") countMap.rma++;

                if (isDraft(d) || isRejected(d)) actionableDraft++;
                if (isRMAPendingWH(d)) actionableRma++;
            });

            // Update DOM Counts
            countAll.textContent = countMap.all;
            countGrn.textContent = countMap.grn;
            countGi.textContent = countMap.gi;
            countKk.textContent = countMap.kk;
            countTr.textContent = countMap.tr;
            countRma.textContent = countMap.rma;

            // Filter by Tab and Search Query
            var filtered = docs.filter(function(d) {
                var matchesTab = activeTab === "all" || d.type === activeTab;
                var matchesSearch = true;
                if (searchQuery) {
                    var idMatch = d.id.toLowerCase().indexOf(searchQuery) !== -1;
                    var typeMatch = d.type.toLowerCase().indexOf(searchQuery) !== -1;
                    var creatorMatch = d.createdBy.toLowerCase().indexOf(searchQuery) !== -1;
                    matchesSearch = idMatch || typeMatch || creatorMatch;
                }
                return matchesTab && matchesSearch;
            });

            // Update Summary Text
            docCountSummary.textContent = filtered.length + " / " + docs.length + " phiếu";
            docTableFooter.innerHTML = "Hiển thị <strong>" + filtered.length + "</strong> / " + docs.length + " chứng từ • Click vào dòng đã hoàn thành để xem phiếu chi tiết";

            // Action banner visibility
            var totalActionable = actionableDraft + actionableRma;
            if (totalActionable > 0) {
                docAlertBannerText.innerHTML = "Bạn đang có <strong>" + actionableDraft + "</strong> phiếu nháp/bị từ chối cần trình duyệt và <strong>" + actionableRma + "</strong> phiếu hoàn hàng cần quét xác nhận nhập zone.";
                docAlertBanner.style.display = 'flex';
            } else {
                docAlertBanner.style.display = 'none';
            }

            // Render Tab Badges (Notification dots for non-active tabs)
            updateTabActionBadges(actionableDraft, actionableRma);

            // Table Rows Generation
            if (filtered.length === 0) {
                html = '<tr>' +
                    '<td colspan="8" style="padding: 48px 0; text-align: center;">' +
                        '<div style="display: flex; flex-direction: column; align-items: center; gap: 12px; color: rgba(16, 55, 92, 0.2);">' +
                            '<svg style="width: 48px; height: 48px;" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">' +
                                '<path stroke-linecap="round" stroke-linejoin="round" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>' +
                            '</svg>' +
                            '<div style="font-size: 14px; color: rgba(16, 55, 92, 0.40);">' +
                                (searchQuery ? "Không tìm thấy phiếu nào phù hợp" : "Chưa có phiếu nào") +
                            '</div>' +
                        '</div>' +
                    '</td>' +
                '</tr>';
            } else {
                filtered.forEach(function(d) {
                    var cfg = DOC_TYPE_CONFIG[d.type];
                    var draft = isDraft(d);
                    var awaitingBM = isAwaitingBM(d);
                    var rmaPending = isRMAPendingWH(d);
                    var viewable = isViewable(d);
                    var rejected = isRejected(d);

                    var rowClass = "row-normal";
                    if (viewable) rowClass = "row-viewable";
                    else if (draft) rowClass = "row-draft";
                    else if (awaitingBM) rowClass = "row-pending";
                    else if (rejected) rowClass = "row-rejected";

                    var rowOnClickAttr = viewable ? 'onclick="viewDocDetails(\'' + d.id + '\')"' : '';

                    // Build operations markup
                    var actionHtml = "";
                    if (draft) {
                        actionHtml = '<button class="btn-action-submit" onclick="submitForApproval(\'' + d.id + '\', event)">' +
                            '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">' +
                                '<path stroke-linecap="round" stroke-linejoin="round" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/>' +
                            '</svg>' +
                            'Trình duyệt' +
                            '</button>';
                    } else if (awaitingBM) {
                        actionHtml = '<span class="badge-action-awaiting">' +
                            '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">' +
                                '<path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>' +
                            '</svg>' +
                            'Chờ duyệt' +
                            '</span>';
                    } else if (rmaPending) {
                        actionHtml = '<button class="btn-action-rma-scan" onclick="triggerRmaZoneScan(\'' + d.id + '\', event)">' +
                            '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">' +
                                '<path stroke-linecap="round" stroke-linejoin="round" d="M12 4v1m0 11v.01M5.938 18h12.124c1.347 0 2.19-1.458 1.516-2.625L13.516 6.125c-.673-1.167-2.358-1.167-3.031 0L4.422 15.375c-.674 1.167.168 2.625 1.516 2.625z"/>' +
                            '</svg>' +
                            'Nhập Zone' +
                            '</button>';
                    } else if (viewable) {
                        actionHtml = '<div class="btn-action-view-eye" title="Xem chứng từ chi tiết">' +
                            '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">' +
                                '<path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>' +
                                '<path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>' +
                            '</svg>' +
                            '</div>';
                    } else if (rejected) {
                        actionHtml = '<span class="badge-action-rejected">' +
                            '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">' +
                                '<path stroke-linecap="round" stroke-linejoin="round" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"/>' +
                            '</svg>' +
                            'Từ chối' +
                            '</span>';
                    } else {
                        actionHtml = '<span style="color: rgba(16, 55, 92, 0.20);">—</span>';
                    }

                    html += '<tr class="' + rowClass + '" ' + rowOnClickAttr + '>' +
                        '<td style="padding-left: 20px;">' +
                            '<div style="display: flex; align-items: center; gap: 10px;">' +
                                '<div class="doc-type-icon-wrapper ' + cfg.bg + '">' + cfg.icon + '</div>' +
                                '<span class="doc-id-text">' + escapeHtml(d.id) + '</span>' +
                            '</div>' +
                        '</td>' +
                        '<td>' +
                            '<span class="doc-type-badge ' + cfg.bg + '">' + cfg.shortName + '</span>' +
                        '</td>' +
                        '<td>' +
                            '<div style="display: flex; align-items: center; gap: 6px; color: rgba(16,55,92,0.70); max-width: 220px; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;">' +
                                '<svg style="width: 14px; height: 14px; flex-shrink: 0;" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">' +
                                    '<path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/>' +
                                '</svg>' +
                                '<span title="' + escapeHtml(d.warehouse) + '">' + escapeHtml(d.warehouse) + '</span>' +
                            '</div>' +
                        '</td>' +
                        '<td>' + escapeHtml(d.createdBy) + '</td>' +
                        '<td>' +
                            '<div style="display: flex; align-items: center; gap: 6px; color: rgba(16,55,92,0.70);">' +
                                '<svg style="width: 14px; height: 14px;" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">' +
                                    '<path stroke-linecap="round" stroke-linejoin="round" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>' +
                                '</svg>' +
                                '<span>' + escapeHtml(d.date) + '</span>' +
                            '</div>' +
                        '</td>' +
                        '<td class="text-right" style="font-weight: 700;">' + d.items + '</td>' +
                        '<td class="text-center">' +
                            '<span class="doc-status-badge" style="background: color-mix(in srgb, ' + d.statusColor + ' 12%, transparent); color: ' + d.statusColor + ';">' +
                                '<div class="doc-status-dot" style="background: ' + d.statusColor + ';"></div>' +
                                escapeHtml(d.status) +
                            '</span>' +
                        '</td>' +
                        '<td class="text-center" style="padding-right: 20px;" onclick="event.stopPropagation()">' + actionHtml + '</td>' +
                    '</tr>';
                });
            }

            docTableBody.innerHTML = html;
        }

        // Render tab badges for notifications on non-active tabs
        function updateTabActionBadges(drafts, rmas) {
            tabButtons.forEach(function(btn) {
                var tabId = btn.getAttribute('data-tab');
                
                // Remove existing badge first
                var existing = btn.querySelector('.doc-tab-action-badge');
                if (existing) existing.remove();

                var actionable = 0;
                docs.forEach(function(d) {
                    var matchesTab = tabId === "all" || d.type === tabId;
                    if (matchesTab && (isDraft(d) || isRMAPendingWH(d) || isRejected(d))) {
                        actionable++;
                    }
                });

                if (actionable > 0 && activeTab !== tabId) {
                    var badge = document.createElement('span');
                    badge.className = "doc-tab-action-badge";
                    badge.textContent = actionable;
                    btn.appendChild(badge);
                }
            });
        }

        // Helper to convert number to Vietnamese words
        function numberToVietnameseWords(num) {
            if (num === 0) return "Không đồng";
            var units = ["", "một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín"];
            var tens = ["", "mười", "hai mươi", "ba mươi", "bốn mươi", "năm mươi", "sáu mươi", "bảy mươi", "tám mươi", "chín mươi"];
            var blocks = ["", "nghìn", "triệu", "tỷ"];

            var readThreeDigits = function(n, showZero) {
                var hundred = Math.floor(n / 100);
                var ten = Math.floor((n % 100) / 10);
                var unit = n % 10;
                var res = "";

                if (hundred > 0 || showZero) {
                    res += units[hundred] + " trăm ";
                }

                if (ten > 0) {
                    if (ten === 1) {
                        res += "mười ";
                    } else {
                        res += tens[ten] + " ";
                    }
                } else if (unit > 0 && (hundred > 0 || showZero)) {
                    res += "lẻ ";
                }

                if (unit > 0) {
                    if (unit === 1 && ten > 1) {
                        res += "mốt ";
                    } else if (unit === 5 && ten > 0) {
                        res += "lăm ";
                    } else {
                        res += units[unit] + " ";
                    }
                }
                return res;
            };

            var str = "";
            var blockIdx = 0;
            var temp = num;

            while (temp > 0) {
                var part = temp % 1000;
                if (part > 0) {
                    var partStr = readThreeDigits(part, temp > 1000).trim();
                    str = partStr + " " + blocks[blockIdx] + " " + str;
                }
                temp = Math.floor(temp / 1000);
                blockIdx++;
            }

            str = str.replace(/\s+/g, " ").trim();
            if (str) {
                str = str.charAt(0).toUpperCase() + str.slice(1);
            }
            return str + " đồng chẵn";
        }

        // Utilities
        function pad(n) { return n < 10 ? '0' + n : n; }
        
        function escapeHtml(str) {
            if (!str) return '';
            return str.replace(/&/g, "&amp;")
                      .replace(/</g, "&lt;")
                      .replace(/>/g, "&gt;")
                      .replace(/"/g, "&quot;")
                      .replace(/'/g, "&#039;");
        }

        // ─── Shipping Label functions ────────────────────────────
        function populateShippingLabel(doc) {
            document.getElementById('shippingLabelOrderId').textContent = doc.id || '—';
            document.getElementById('shippingLabelToName').textContent = doc.receiverName || doc.receiver || '—';
            document.getElementById('shippingLabelToAddr').textContent = doc.address || doc.receiverAddress || '—';
            document.getElementById('shippingLabelToTel').textContent = 'Tel: ' + (doc.receiverTel || doc.tel || '—');
            document.getElementById('shippingLabelDate').textContent = doc.date || '—';
            document.getElementById('shippingLabelBarcodeRef').textContent = (doc.barcode || doc.id || '').replace(/./g, '| ');
        }

        window.printShippingLabel = function() {
            window.print();
        };

        // ─── Delivery Note functions ─────────────────────────────
        function populateDeliveryNote(doc) {
            document.getElementById('dnOrderId').textContent = doc.id || '—';
            document.getElementById('dnDate').textContent = doc.date || '—';
            document.getElementById('dnWarehouse').textContent = doc.warehouse || '—';
            document.getElementById('dnReceiverName').textContent = doc.receiverName || doc.receiver || '—';
            document.getElementById('dnReceiverAddr').textContent = doc.address || doc.receiverAddress || '—';

            var tbody = document.getElementById('dnItemsBody');
            if (doc.items && doc.items > 0) {
                var rows = '';
                for (var i = 0; i < Math.min(doc.items, 10); i++) {
                    rows += '<tr>' +
                        '<td style="text-align:center;">' + (i + 1) + '</td>' +
                        '<td>SP-' + String(i + 1).padStart(3, '0') + '</td>' +
                        '<td style="text-align:center;">Cái</td>' +
                        '<td style="text-align:right; font-weight:600;">' + doc.items + '</td>' +
                    '</tr>';
                }
                tbody.innerHTML = rows;
                document.getElementById('dnTotalQty').textContent = doc.items;
            } else {
                tbody.innerHTML = '<tr><td colspan="4" style="text-align:center; color:rgba(16,55,92,0.4); padding:32px;">Chưa có dữ liệu sản phẩm</td></tr>';
                document.getElementById('dnTotalQty').textContent = '0';
            }
        }

        window.printDeliveryNote = function() {
            window.print();
        };

        // ─── Start engine ─────────────────────────────────────────
        renderDocs();

    })();
</script>
