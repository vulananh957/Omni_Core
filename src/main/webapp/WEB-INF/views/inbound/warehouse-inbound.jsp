<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    /* ─── Inbound DB Section ─── */
    .db-section-header {
        display: flex; align-items: center; justify-content: space-between;
        margin-bottom: 12px;
    }
    .db-section-title {
        font-size: 15px; font-weight: 800; color: var(--navy); letter-spacing: -0.02em;
    }
    .db-badge {
        display: inline-flex; align-items: center; gap: 4px;
        padding: 3px 10px; border-radius: 20px;
        font-size: 10px; font-weight: 700;
        background: rgba(6, 182, 212, 0.1); color: #0891b2;
        border: 1px solid rgba(6, 182, 212, 0.2);
    }
    .db-table-card {
        background: #fff; border: 1px solid var(--border);
        border-radius: var(--radius-card); overflow: hidden; margin-bottom: 20px;
    }
    .db-table { width: 100%; border-collapse: collapse; }
    .db-table thead tr { background: var(--alice); border-bottom: 1px solid var(--border); }
    .db-table thead th {
        padding: 10px 16px;
        font-size: 10px; font-weight: 700; text-transform: uppercase;
        letter-spacing: .08em; color: rgba(16,55,92,0.40);
    }
    .db-table thead th:first-child { padding-left: 20px; }
    .db-table thead th.text-right { text-align: right; }
    .db-table tbody tr { border-bottom: 1px solid var(--border); transition: background .12s; }
    .db-table tbody tr:last-child { border-bottom: none; }
    .db-table tbody tr:hover { background: rgba(240,244,250,0.50); }
    .db-table tbody td { padding: 12px 16px; font-size: 13px; color: var(--navy); }
    .db-table tbody td:first-child { padding-left: 20px; }
    .db-table tbody td.text-right { text-align: right; }
    .db-inbound-code { font-family: monospace; font-weight: 700; color: var(--navy); font-size: 12px; }
    .db-supplier { font-weight: 500; }
    .db-warehouse { font-size: 12px; color: rgba(16,55,92,0.60); }
    .db-empty-row td { text-align: center; padding: 32px !important; color: rgba(16,55,92,0.40); }

    .status-pill {
        display: inline-flex; align-items: center; gap: 4px;
        padding: 3px 10px; border-radius: 20px; font-size: 10px; font-weight: 700;
    }
    .status-pill__dot { width: 5px; height: 5px; border-radius: 50%; }
    .status-pill.pending   { background: #eff6ff; color: #1d4ed8; }
    .status-pill.pending .status-pill__dot { background: #3b82f6; }
    .status-pill.confirmed { background: rgba(245,200,66,0.15); color: #d97706; }
    .status-pill.confirmed .status-pill__dot { background: #f5c842; }
    .status-pill.received  { background: #ecfdf5; color: #047857; }
    .status-pill.received .status-pill__dot { background: #10b981; }
    .status-pill.cancelled { background: #fef2f2; color: #b91c1c; }
    .status-pill.cancelled .status-pill__dot { background: #ef4444; }

    .db-filter-tabs {
        display: flex; flex-wrap: wrap; gap: 4px;
        background: #fff; border: 1px solid var(--border);
        border-radius: var(--radius-card); padding: 4px;
        margin-bottom: 16px;
    }
    .db-filter-btn {
        display: flex; align-items: center; gap: 6px;
        padding: 6px 14px; font-size: 12px; font-weight: 600;
        border: none; background: none; cursor: pointer;
        color: rgba(16,55,92,0.50); border-radius: calc(var(--radius-btn) - 4px);
        transition: all .15s;
    }
    .db-filter-btn.active { background: var(--navy); color: #fff; }
    .db-filter-btn:not(.active):hover { color: var(--navy); }
    .db-filter-count {
        font-size: 9px; font-weight: 700; padding: 1px 5px;
        border-radius: 9999px;
    }
    .db-filter-btn.active .db-filter-count { background: rgba(255,255,255,.20); color: #fff; }
    .db-filter-btn:not(.active) .db-filter-count { background: rgba(16,55,92,.08); color: rgba(16,55,92,.50); }

    .db-action-btn {
        display: inline-flex; align-items: center; gap: 4px;
        padding: 5px 12px; border: none; border-radius: calc(var(--radius-btn) - 4px);
        font-size: 11px; font-weight: 700; cursor: pointer; white-space: nowrap;
        transition: opacity .12s;
    }
    .db-action-btn:hover { opacity: .88; }
    .db-action-btn--orange { background: var(--orange); color: #fff; }
    .db-action-btn--navy  { background: var(--navy); color: #fff; }
    .db-action-btn--emerald { background: #059669; color: #fff; }
    .db-action-btn--white  { background: #fff; border: 1px solid var(--border); color: rgba(16,55,92,.7); }

    /* Toast Notification */
    .toast-container { position: fixed; top: 20px; right: 20px; z-index: 9999; display: flex; flex-direction: column; gap: 8px; }
    .toast {
        display: flex; align-items: center; gap: 10px;
        padding: 12px 16px; background: #fff; border-radius: var(--radius-card);
        box-shadow: 0 10px 25px rgba(16,55,92,.15);
        font-size: 13px; font-weight: 500; color: var(--navy);
        border-left: 4px solid var(--navy);
        animation: slideInToast .2s ease;
        max-width: 360px;
    }
    .toast.success { border-left-color: #10b981; }
    .toast.error   { border-left-color: #ef4444; }
    .toast__icon { width: 18px; height: 18px; flex-shrink: 0; }
    @keyframes slideInToast { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
    /* ─── Tabs & Layout ─── */
    .tabs-wrap {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 20px;
        border-bottom: 1px solid var(--border);
    }
    .tab-btn {
        padding: 10px 16px;
        font-size: 13px;
        font-weight: 600;
        background: none;
        border: none;
        color: rgba(16, 55, 92, 0.4);
        cursor: pointer;
        transition: color 0.15s, border-color 0.15s;
        border-bottom: 2px solid transparent;
        position: relative;
        bottom: -1px;
    }
    .tab-btn:hover {
        color: rgba(16, 55, 92, 0.7);
    }
    .tab-btn.active {
        color: var(--navy);
        border-bottom-color: var(--navy);
    }

    /* ─── Summary Grid ─── */
    .inbound-stats-grid-4 {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }
    @media (max-width: 1024px) {
        .inbound-stats-grid-4 {
            grid-template-columns: repeat(2, 1fr);
        }
    }
    @media (max-width: 640px) {
        .inbound-stats-grid-4 {
            grid-template-columns: 1fr;
        }
    }

    .inbound-kpi-card {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 16px 20px;
        display: flex !important;
        flex-direction: row !important;
        align-items: center !important;
        gap: 16px !important;
    }
    .inbound-kpi-card__icon-box {
        width: 40px;
        height: 40px;
        border-radius: var(--radius-btn);
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }
    .inbound-kpi-card__icon-box svg {
        width: 20px;
        height: 20px;
    }
    .inbound-kpi-card__info {
        flex: 1;
        min-width: 0;
        display: flex;
        flex-direction: column;
        align-items: flex-start;
    }
    .inbound-kpi-card__val {
        font-size: 22px;
        font-weight: 800;
        color: var(--navy);
        line-height: 1.1;
        letter-spacing: -0.03em;
        margin-bottom: 2px;
    }
    .inbound-kpi-card__lbl {
        color: rgba(16, 55, 92, 0.50);
        font-size: 11px;
        font-weight: 500;
    }

    .tone-blue .inbound-kpi-card__icon-box { background: rgba(59, 130, 246, 0.1); }
    .tone-blue .inbound-kpi-card__icon-box svg { color: #2563eb; }
    
    .tone-orange .inbound-kpi-card__icon-box { background: rgba(235, 131, 23, 0.1); }
    .tone-orange .inbound-kpi-card__icon-box svg { color: var(--orange); }
    .tone-orange .inbound-kpi-card__val { color: var(--orange); }

    .tone-emerald .inbound-kpi-card__icon-box { background: rgba(16, 185, 129, 0.1); }
    .tone-emerald .inbound-kpi-card__icon-box svg { color: #059669; }

    .tone-navy .inbound-kpi-card__icon-box { background: rgba(16, 55, 92, 0.08); }
    .tone-navy .inbound-kpi-card__icon-box svg { color: var(--navy); }

    .tone-cyan .inbound-kpi-card__icon-box { background: rgba(6, 182, 212, 0.1); }
    .tone-cyan .inbound-kpi-card__icon-box svg { color: #0891b2; }

    .tone-slate .inbound-kpi-card__icon-box { background: rgba(100, 116, 139, 0.1); }
    .tone-slate .inbound-kpi-card__icon-box svg { color: #475569; }

    /* ─── Toolbar ─── */
    .toolbar {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 14px 16px;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .search-wrap {
        position: relative;
        flex: 1;
    }
    .search-wrap svg {
        position: absolute;
        left: 12px;
        top: 50%;
        transform: translateY(-50%);
        width: 14px;
        height: 14px;
        color: rgba(16, 55, 92, 0.3);
    }
    .search-wrap input {
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
    .search-wrap input::placeholder {
        color: rgba(16, 55, 92, 0.3);
    }
    .search-wrap input:focus {
        border-color: rgba(16, 55, 92, 0.3);
    }
    .btn-create {
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
    }
    .btn-create:hover {
        background: #ea580c;
    }
    .btn-create svg {
        width: 14px;
        height: 14px;
    }

    /* ─── Status Filter Nav ─── */
    .status-tabs {
        display: flex;
        flex-wrap: wrap;
        gap: 4px;
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 4px;
        margin-bottom: 16px;
    }
    .status-tab-btn {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 16px;
        font-size: 12px;
        font-weight: 600;
        border: none;
        background: none;
        cursor: pointer;
        color: rgba(16, 55, 92, 0.5);
        border-radius: calc(var(--radius-btn) - 4px);
        transition: all 0.15s;
    }
    .status-tab-btn:hover {
        color: var(--navy);
    }
    .status-tab-btn.active {
        background: var(--navy);
        color: #fff;
    }
    .status-tab-badge {
        font-size: 10px;
        font-weight: 700;
        padding: 1px 6px;
        border-radius: 9999px;
        background: rgba(16, 55, 92, 0.08);
        color: rgba(16, 55, 92, 0.6);
        transition: background 0.15s, color 0.15s;
    }
    .status-tab-btn.active .status-tab-badge {
        background: rgba(255, 255, 255, 0.20);
        color: #fff;
    }

    /* ─── Collapsible GRN List ─── */
    .grn-list {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    .grn-item {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        overflow: hidden;
        transition: all 0.15s;
    }
    .grn-hdr {
        display: flex;
        align-items: center;
        gap: 16px;
        padding: 16px 20px;
        cursor: pointer;
        transition: background 0.12s;
    }
    .grn-hdr:hover {
        background: rgba(240, 244, 250, 0.40);
    }
    .grn-hdr__icon {
        width: 40px;
        height: 40px;
        border-radius: var(--radius-btn);
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }
    .grn-hdr__icon svg {
        width: 18px;
        height: 18px;
    }
    .grn-hdr__info {
        flex: 1;
        min-width: 0;
    }
    .grn-meta-row {
        display: flex;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
    }
    .grn-id {
        font-size: 14px;
        font-weight: 800;
        color: var(--navy);
    }
    
    /* Badges */
    .pill-badge {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 2px 10px;
        font-size: 10px;
        font-weight: 700;
        border-radius: 20px;
        text-transform: capitalize;
        white-space: nowrap;
    }
    .pill-badge__dot {
        width: 6px;
        height: 6px;
        border-radius: 50%;
    }
    
    .pill-badge.draft { background: rgba(16, 55, 92, 0.08); color: rgba(16, 55, 92, 0.6); }
    .pill-badge.draft .pill-badge__dot { background: rgba(16, 55, 92, 0.3); }

    .pill-badge.pending_bm { background: #FEF3C7; color: #b45309; }
    .pill-badge.pending_bm .pill-badge__dot { background: #f59e0b; }

    .pill-badge.pending { background: #eff6ff; color: #1d4ed8; }
    .pill-badge.pending .pill-badge__dot { background: #3b82f6; }

    .pill-badge.in_progress { background: rgba(245, 200, 66, 0.15); color: #d97706; }
    .pill-badge.in_progress .pill-badge__dot { background: #f5c842; }

    .pill-badge.completed { background: #ECFDF5; color: #047857; }
    .pill-badge.completed .pill-badge__dot { background: #10b981; }

    .pill-badge.cancelled { background: #FEF2F2; color: #b91c1c; }
    .pill-badge.cancelled .pill-badge__dot { background: #ef4444; }

    .grn-supplier-row {
        display: flex;
        align-items: center;
        gap: 16px;
        margin-top: 4px;
        color: rgba(16, 55, 92, 0.50);
        font-size: 12px;
    }
    .grn-supplier-cell {
        display: flex;
        align-items: center;
        gap: 4px;
        font-weight: 500;
    }
    .grn-supplier-cell svg {
        width: 12px;
        height: 12px;
    }
    
    .grn-stats-row {
        display: flex;
        align-items: center;
        gap: 24px;
        flex-shrink: 0;
    }
    .grn-stat {
        text-align: right;
    }
    .grn-stat__lbl {
        color: rgba(16, 55, 92, 0.40);
        font-size: 9px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        margin-bottom: 2px;
    }
    .grn-stat__val {
        font-size: 14px;
        font-weight: 800;
        color: var(--navy);
    }
    
    .btn-action-icon {
        width: 32px;
        height: 32px;
        border-radius: var(--radius-btn);
        background: var(--alice);
        border: none;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        color: rgba(16, 55, 92, 0.5);
        transition: background 0.15s, color 0.15s;
    }
    .btn-action-icon:hover {
        background: rgba(16, 55, 92, 0.08);
        color: var(--navy);
    }
    .btn-action-icon svg {
        width: 16px;
        height: 16px;
    }

    .btn-action-grn {
        padding: 8px 16px;
        background: var(--orange);
        color: #fff;
        font-size: 12px;
        font-weight: 700;
        border: none;
        border-radius: calc(var(--radius-btn) - 2px);
        cursor: pointer;
        transition: background 0.12s;
    }
    .btn-action-grn:hover {
        background: #ea580c;
    }
    
    .grn-chevron {
        width: 16px;
        height: 16px;
        color: rgba(16, 55, 92, 0.3);
        transition: transform 0.2s ease;
    }
    .grn-item.expanded .grn-chevron {
        transform: rotate(180deg);
    }

    /* Action Dropdown Menu */
    .dropdown-wrap {
        position: relative;
        display: inline-block;
    }
    .dropdown-menu {
        position: absolute;
        right: 0;
        top: 100%;
        margin-top: 8px;
        width: 180px;
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-btn);
        box-shadow: 0 10px 15px -3px rgba(16, 55, 92, 0.1);
        z-index: 50;
        display: none;
        overflow: hidden;
    }
    .dropdown-menu.active {
        display: block;
    }
    .dropdown-btn {
        width: 100%;
        padding: 8px 12px;
        font-size: 12px;
        font-weight: 600;
        text-align: left;
        background: none;
        border: none;
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 8px;
        color: rgba(16, 55, 92, 0.7);
        transition: background 0.12s, color 0.12s;
    }
    .dropdown-btn:hover {
        background: var(--alice);
        color: var(--navy);
    }
    .dropdown-btn svg {
        width: 14px;
        height: 14px;
    }

    /* Expanded Content */
    .grn-body {
        border-top: 1px solid var(--border);
        display: none;
    }
    .grn-item.expanded .grn-body {
        display: block;
    }
    .grn-body-table {
        width: 100%;
        border-collapse: collapse;
    }
    .grn-body-table th {
        background: var(--alice);
        padding: 10px 16px;
        font-size: 10px;
        font-weight: 700;
        color: rgba(16, 55, 92, 0.40);
        text-transform: uppercase;
        letter-spacing: 0.05em;
        border-bottom: 1px solid var(--border);
    }
    .grn-body-table th:first-child { padding-left: 20px; }
    .grn-body-table th:last-child { padding-right: 20px; }
    
    .grn-body-table td {
        padding: 12px 16px;
        border-bottom: 1px solid var(--border);
        font-size: 12px;
    }
    .grn-body-table td:first-child { padding-left: 20px; }
    .grn-body-table td:last-child { padding-right: 20px; }
    .grn-body-table tr:last-child td {
        border-bottom: none;
    }
    
    .progress-bar-wrap {
        width: 80px;
        height: 6px;
        background: var(--border);
        border-radius: 9999px;
        overflow: hidden;
    }
    .progress-bar-fill {
        height: 100%;
        border-radius: 9999px;
    }
    
    .grn-notes-bar {
        background: rgba(245, 200, 66, 0.08);
        border-top: 1px solid var(--border);
        padding: 10px 20px;
        font-size: 12px;
        color: rgba(16, 55, 92, 0.7);
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .grn-notes-bar svg {
        width: 14px;
        height: 14px;
        color: var(--orange);
    }

    .grn-user-bar {
        border-top: 1px solid var(--border);
        padding: 10px 20px;
        font-size: 11px;
        color: rgba(16, 55, 92, 0.4);
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .grn-user-bar svg {
        width: 13px;
        height: 13px;
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
        max-width: 560px;
        border-radius: var(--radius-card);
        box-shadow: 0 20px 25px -5px rgba(16, 55, 92, 0.15);
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
    .form-textarea {
        width: 100%;
        padding: 10px 14px;
        border: 1px solid var(--border);
        background: var(--alice);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        font-family: inherit;
        color: var(--navy);
        outline: none;
        resize: none;
        transition: border-color 0.15s;
    }
    .form-textarea:focus {
        border-color: rgba(16, 55, 92, 0.40);
    }
    
    .modal-ftr {
        padding: 16px 24px;
        border-top: 1px solid var(--border);
        background: var(--alice);
        display: flex;
        justify-content: flex-end;
        gap: 12px;
    }

    .modal-btn-cancel {
        padding: 10px 18px;
        border: 1px solid var(--border);
        background: var(--alice);
        color: rgba(16, 55, 92, 0.7);
        font-size: 13px;
        font-weight: 500;
        border-radius: calc(var(--radius-btn) - 2px);
        cursor: pointer;
        transition: all 0.15s;
    }
    .modal-btn-cancel:hover {
        color: var(--navy);
        background: #e2eaf5;
    }
    
    .modal-btn-submit {
        padding: 10px 20px;
        background: var(--orange);
        color: #fff;
        border: none;
        font-size: 13px;
        font-weight: 600;
        border-radius: calc(var(--radius-btn) - 2px);
        cursor: pointer;
        transition: background 0.15s;
    }
    .modal-btn-submit:hover {
        background: #ea580c;
    }
    
    .modal-btn-emerald {
        background: #059669;
    }
    .modal-btn-emerald:hover {
        background: #047857;
    }

    .receive-item-card {
        display: flex;
        align-items: center;
        gap: 16px;
        padding: 12px 16px;
        background: var(--alice);
        border-radius: calc(var(--radius-btn) - 2px);
        border: 1px solid var(--border);
    }
    
    /* ─── Pricing view styles ─── */
    .config-header {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 20px;
        margin-bottom: 20px;
    }
    .config-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 4px 10px;
        font-size: 11px;
        font-weight: 600;
        background: rgba(6, 182, 212, 0.1);
        color: #0891b2;
        border: 1px solid rgba(6, 182, 212, 0.2);
        border-radius: calc(var(--radius-btn) - 2px);
        margin-bottom: 12px;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }
    .config-badge svg {
        width: 14px;
        height: 14px;
    }
    .config-title {
        font-size: 22px;
        font-weight: 800;
        color: var(--navy);
        letter-spacing: -0.03em;
        margin-bottom: 4px;
    }
    .config-desc {
        font-size: 13px;
        color: rgba(16, 55, 92, 0.6);
        max-width: 800px;
    }

    .pricing-table-card {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        overflow: hidden;
    }
    .pricing-table {
        width: 100%;
        border-collapse: collapse;
    }
    .pricing-table th {
        background: var(--alice);
        padding: 12px 16px;
        font-size: 11px;
        font-weight: 700;
        color: rgba(16, 55, 92, 0.50);
        text-transform: uppercase;
        letter-spacing: 0.05em;
        border-bottom: 1px solid var(--border);
        text-align: left;
    }
    .pricing-table td {
        padding: 14px 16px;
        border-bottom: 1px solid var(--border);
        vertical-align: middle;
        font-size: 13px;
    }
    .pricing-table tr:hover td {
        background: rgba(240, 244, 250, 0.50);
    }
    .pricing-table tr:last-child td {
        border-bottom: none;
    }
    
    .price-input {
        width: 140px;
        padding: 8px 12px;
        border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
        outline: none;
        text-align: right;
        font-size: 13px;
        color: var(--navy);
        font-family: inherit;
        background: #fff;
        transition: border-color 0.15s;
    }
    .price-input:focus {
        border-color: rgba(16, 55, 92, 0.3);
    }
    .price-input:disabled {
        background: var(--alice);
        color: rgba(16, 55, 92, 0.40);
        cursor: not-allowed;
    }

    .btn-save-inline {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 8px 14px;
        background: var(--navy);
        color: #fff;
        font-size: 12px;
        font-weight: 600;
        border: none;
        border-radius: calc(var(--radius-btn) - 2px);
        cursor: pointer;
        transition: background 0.15s;
    }
    .btn-save-inline:hover {
        background: #0d2e4e;
    }
    .btn-save-inline:disabled {
        background: #f1f5f9;
        color: #cbd5e1;
        cursor: not-allowed;
    }
    .btn-save-inline svg {
        width: 14px;
        height: 14px;
    }

    .pricing-bottom-bar {
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 16px;
        margin-top: 20px;
    }
    .pricing-status-text {
        font-size: 12px;
        color: rgba(16, 55, 92, 0.4);
        font-style: italic;
    }

    /* ─── Draft creation item table ─── */
    .draft-items-box {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        overflow: hidden;
    }
    .draft-items-hdr {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 12px 16px;
        border-bottom: 1px solid var(--border);
    }
    .draft-items-title {
        font-size: 13px;
        font-weight: 600;
        color: var(--navy);
    }
    .btn-add-row {
        padding: 6px 12px;
        background: var(--orange);
        color: #fff;
        border: none;
        font-size: 12px;
        font-weight: 600;
        border-radius: calc(var(--radius-btn) - 2px);
        cursor: pointer;
        transition: background 0.12s;
    }
    .btn-add-row:hover {
        background: #ea580c;
    }
    .draft-row {
        display: grid;
        grid-template-columns: 1.2fr 2fr 120px 40px;
        gap: 12px;
        padding: 12px 16px;
        border-bottom: 1px solid var(--border);
        align-items: center;
    }
    .draft-row:last-child {
        border-bottom: none;
    }
    .btn-del-row {
        width: 32px;
        height: 32px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        background: none;
        border: none;
        color: #ef4444;
        cursor: pointer;
        font-size: 20px;
        border-radius: 4px;
        transition: background 0.15s;
    }
    .btn-del-row:hover {
        background: #fef2f2;
    }

    .sku-select-input {
        width: 100%;
        padding: 10px 14px;
        border: 1px solid var(--border);
        background: var(--alice);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        color: var(--navy);
        outline: none;
    }
</style>

<!-- ══ MAIN TAB NAVIGATION ══════════════════════════════════ -->
<div class="tabs-wrap">
    <button class="tab-btn active" id="tab-btn-receipts" onclick="switchMainTab('receipts')">Phiếu nhập kho</button>
    <button class="tab-btn" id="tab-btn-pricing" onclick="switchMainTab('pricing')">Cấu hình giá nhập</button>
</div>

<!-- ══ VIEW 1: RECEIPTS TAB ══════════════════════════════════ -->
<div id="view-receipts">
    <!-- Summary Cards -->
    <div class="inbound-stats-grid-4">
        <!-- Card: Pending Items -->
        <div class="inbound-kpi-card tone-blue">
            <div class="inbound-kpi-card__icon-box">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            </div>
            <div class="inbound-kpi-card__info">
                <div class="inbound-kpi-card__val" id="stat-pending">0</div>
                <div class="inbound-kpi-card__lbl">Phiếu chờ hàng</div>
            </div>
        </div>

        <!-- Card: In Progress -->
        <div class="inbound-kpi-card tone-orange">
            <div class="inbound-kpi-card__icon-box">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 17V3"/><path d="m6 11 6 6 6-6"/><path d="M19 21H5"/></svg>
            </div>
            <div class="inbound-kpi-card__info">
                <div class="inbound-kpi-card__val" id="stat-in-progress">0</div>
                <div class="inbound-kpi-card__lbl">Đang nhập kho</div>
            </div>
        </div>

        <!-- Card: Completed Weekly -->
        <div class="inbound-kpi-card tone-emerald">
            <div class="inbound-kpi-card__icon-box">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            </div>
            <div class="inbound-kpi-card__info">
                <div class="inbound-kpi-card__val" id="stat-completed">0</div>
                <div class="inbound-kpi-card__lbl">Hoàn thành tuần này</div>
            </div>
        </div>

        <!-- Card: SKU Received -->
        <div class="inbound-kpi-card tone-violet">
            <div class="inbound-kpi-card__icon-box">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m7.5 4.27 9 5.15"/><path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"/><path d="m3.3 7 8.7 5 8.7-5"/><path d="M12 22V12"/></svg>
            </div>
            <div class="inbound-kpi-card__info">
                <div class="inbound-kpi-card__val" id="stat-sku-received">0</div>
                <div class="inbound-kpi-card__lbl">SKU đã nhập</div>
            </div>
        </div>
    </div>

    <!-- GRN List Container (rendered by JavaScript) -->
    <!-- Toolbar -->
    <div class="toolbar" style="margin-bottom:12px;">
        <div class="search-wrap">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"></svg>
            <input type="text" placeholder="Tìm mã phiếu hoặc nhà cung cấp..." id="grnSearchInput"/>
        </div>
        <button class="btn-create" onclick="openCreatePOModal()">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
            Tạo phiếu nhập
        </button>
    </div>

    <!-- Status Filter Tabs -->
    <div class="status-tabs" id="statusTabsContainer"></div>

    <!-- GRN Table (unified) -->
    <div class="grn-list" id="grnListContainer"></div>
</div>

<!-- ══ VIEW 2: PRICING TAB ═══════════════════════════════════ -->
<div id="view-pricing" style="display: none;">
    <div class="config-header">
        <div class="config-badge">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m17 2 4 4-4 4"/><path d="M3 11v-1a4 4 0 0 1 4-4h14"/><path d="m7 22-4-4 4-4"/><path d="M21 13v-1a4 4 0 0 1-4-4H3"/></svg>
            Configure Pricing
        </div>
        <h2 class="config-title">Cấu Hình Giá Nhập</h2>
        <p class="config-desc">Nhân viên kho cập nhật giá nhập mua (Import Price) của từng sản phẩm. Hệ thống sử dụng giá này để tính COGS hàng tồn kho và hoạch định báo cáo tài chính.</p>
    </div>

    <!-- Active stats for pricing -->
    <div class="inbound-stats-grid-4" style="grid-template-columns: repeat(3, 1fr); margin-bottom: 20px;">
        <div class="inbound-kpi-card tone-emerald">
            <div class="inbound-kpi-card__icon-box">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            </div>
            <div class="inbound-kpi-card__info">
                <div class="inbound-kpi-card__val" id="price-stat-active">0</div>
                <div class="inbound-kpi-card__lbl">SKU đang kinh doanh (Active)</div>
            </div>
        </div>
        <div class="inbound-kpi-card tone-cyan">
            <div class="inbound-kpi-card__icon-box">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" x2="12" y1="1" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
            </div>
            <div class="inbound-kpi-card__info">
                <div class="inbound-kpi-card__val" id="price-stat-avg">0đ</div>
                <div class="inbound-kpi-card__lbl">Giá nhập bình quân</div>
            </div>
        </div>
        <div class="inbound-kpi-card tone-navy">
            <div class="inbound-kpi-card__icon-box">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg>
            </div>
            <div class="inbound-kpi-card__info">
                <div class="inbound-kpi-card__val" id="price-stat-total-cogs">0đ</div>
                <div class="inbound-kpi-card__lbl">Tồn kho quy đổi (COGS)</div>
            </div>
        </div>
    </div>

    <!-- Pricing Table -->
    <div class="pricing-table-card">
        <table class="pricing-table">
            <thead>
                <tr>
                    <th style="width: 140px;">Master SKU</th>
                    <th>Sản phẩm</th>
                    <th style="width: 120px; text-align: center;">Trạng thái</th>
                    <th style="width: 160px; text-align: right;">Giá nhập</th>
                    <th style="width: 180px; text-align: right;">COGS tồn kho</th>
                    <th style="width: 160px;">Cập nhật</th>
                    <th style="width: 120px; text-align: right;">Hành động</th>
                </tr>
            </thead>
            <tbody id="pricingTableBody">
                <!-- Rendered dynamically -->
            </tbody>
        </table>
    </div>

    <div class="pricing-bottom-bar">
        <span class="pricing-status-text" id="pricingSaveStatus">Chưa lưu thay đổi</span>
        <button class="modal-btn-submit" onclick="saveAllPrices()">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:14px;height:14px;margin-right:6px;vertical-align:middle;"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
            Lưu tất cả
        </button>
    </div>
</div>

<!-- ══ MODAL: CREATE / DUPLICATE DRAFT GRN ════════════════════ -->
<div class="modal-overlay" id="draftModalOverlay">
    <div class="modal-box" style="max-width: 800px;">
        <div class="modal-hdr">
            <div>
                <h2 class="modal-title" id="draftModalTitle">Tạo phiếu nhập nháp</h2>
                <p class="modal-subtitle">Lưu cục bộ ở trạng thái DRAFT, chưa ghi nhận tồn kho.</p>
            </div>
            <button class="modal-close" onclick="closeDraftModal()">&times;</button>
        </div>
        <div class="modal-body" style="background: rgba(240, 244, 250, 0.25);">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                <div class="form-group">
                    <label class="form-label" for="draft-supplier">Nhà cung cấp *</label>
                    <input class="form-input" style="background:#fff;" type="text" id="draft-supplier" placeholder="Tên nhà cung cấp"/>
                </div>
                <div class="form-group">
                    <label class="form-label" for="draft-date">Ngày dự kiến *</label>
                    <input class="form-input" style="background:#fff;" type="date" id="draft-date"/>
                </div>
            </div>
            <div class="form-group">
                <label class="form-label" for="draft-note">Ghi chú</label>
                <textarea class="form-textarea" style="background:#fff;" id="draft-note" rows="3" placeholder="Ghi chú cho phiếu nhập nháp..."></textarea>
            </div>

            <!-- Draft Items grid -->
            <div class="draft-items-box">
                <div class="draft-items-hdr">
                    <span class="draft-items-title">Danh sách SKU</span>
                    <button class="btn-add-row" onclick="addDraftItemRow()">Thêm dòng</button>
                </div>
                <div id="draftRowsContainer">
                    <!-- Rendered dynamically -->
                </div>
            </div>
        </div>
        <div class="modal-ftr" style="background:#fff;">
            <button class="modal-btn-cancel" onclick="closeDraftModal()">Hủy</button>
            <button class="modal-btn-submit" onclick="submitDraftGRN()">Lưu nháp</button>
        </div>
    </div>
</div>

<!-- ══ MODAL: RECEIVE GOODS (XÁC NHẬN NHẬP KHO) ══════════════ -->
<div class="modal-overlay" id="receiveModalOverlay">
    <div class="modal-box">
        <div class="modal-hdr">
            <div>
                <h2 class="modal-title">Xác nhận nhập thực tế</h2>
                <p class="modal-subtitle" id="receiveModalSubtitle">Mã phiếu: GRN-XXXX · NCC: ABC</p>
            </div>
            <button class="modal-close" onclick="closeReceiveModal()">&times;</button>
        </div>
        <div class="modal-body">
            <p style="font-size: 12px; color: rgba(16, 55, 92, 0.6); margin-bottom: 8px;">Nhập số lượng thực tế kiểm đếm được cho từng SKU. Hệ thống sẽ tăng lượng tồn kho khả dụng ngay lập tức.</p>
            <input type="hidden" id="receive-grn-id"/>
            <div id="receiveItemsContainer" style="display:flex; flex-direction:column; gap:12px;">
                <!-- Populate items with number input -->
            </div>
        </div>
        <div class="modal-ftr">
            <button class="modal-btn-cancel" onclick="closeReceiveModal()">Hủy</button>
            <button class="modal-btn-submit modal-btn-emerald" onclick="submitConfirmReceive()">Xác nhận nhập kho</button>
        </div>
    </div>
</div>

<!-- ══ MODAL: CREATE PO (Server-side) ════════════════════════════════ -->
<div class="modal-overlay" id="createPOModal">
    <div class="modal-box" style="max-width:560px;">
        <div class="modal-hdr">
            <div>
                <h2 class="modal-title">Tạo phiếu nhập mới</h2>
                <p class="modal-subtitle">Tạo đơn nhập hàng từ nhà cung cấp</p>
            </div>
            <button class="modal-close" onclick="closeCreatePOModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/warehouse/inbound" id="createPOForm">
            <input type="hidden" name="action" value="create"/>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label" for="po-supplier">Nhà cung cấp *</label>
                    <input class="form-input" style="background:#fff;" type="text" id="po-supplier" name="supplierName" placeholder="Tên nhà cung cấp..." required/>
                </div>
                <div class="form-group">
                    <label class="form-label" for="po-warehouse">Kho nhập *</label>
                    <select class="form-input" style="background:#fff;" id="po-warehouse" name="warehouseId" required>
                        <option value="">— Chọn kho —</option>
                        <c:forEach items="${warehouses}" var="w">
                            <option value="${w.warehouseId}">${w.warehouseName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" for="po-date">Ngày dự kiến nhận</label>
                    <input class="form-input" style="background:#fff;" type="date" id="po-date" name="expectedDate"/>
                </div>
                <div class="form-group">
                    <label class="form-label" for="po-notes">Ghi chú</label>
                    <textarea class="form-textarea" style="background:#fff;" id="po-notes" name="notes" rows="3" placeholder="Ghi chú thêm (nếu có)..."></textarea>
                </div>
            </div>
            <div class="modal-ftr" style="background:#fff;">
                <button type="button" class="modal-btn-cancel" onclick="closeCreatePOModal()">Hủy</button>
                <button type="submit" class="modal-btn-submit">Tạo phiếu nhập</button>
            </div>
        </form>
    </div>
</div>

<!-- ══ MODAL: CONFIRM RECEIVE (Server-side) ═════════════════════════ -->
<div class="modal-overlay" id="receiveDBModal">
    <div class="modal-box" style="max-width:600px;">
        <div class="modal-hdr">
            <div>
                <h2 class="modal-title">Xác nhận nhập kho thực tế</h2>
                <p class="modal-subtitle" id="receiveDB-subtitle">Mã phiếu: ...</p>
            </div>
            <button class="modal-close" onclick="closeReceiveDBModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/warehouse/inbound" id="receiveDBForm">
            <input type="hidden" name="action" value="receive"/>
            <input type="hidden" name="inboundId" id="receiveDB-inboundId"/>
            <div class="modal-body">
                <p style="font-size:12px; color:rgba(16,55,92,0.60); margin-bottom:8px;">
                    Nhập số lượng thực tế cho từng sản phẩm. Hệ thống sẽ cộng tồn kho khả dụng và tạo ledger entry.
                </p>
                <div id="receiveDBItemsContainer" style="display:flex; flex-direction:column; gap:10px;">
                    <!-- Dynamic items -->
                </div>
            </div>
            <div class="modal-ftr" style="background:#fff;">
                <button type="button" class="modal-btn-cancel" onclick="closeReceiveDBModal()">Hủy</button>
                <button type="submit" class="modal-btn-submit modal-btn-emerald">Xác nhận nhập kho</button>
            </div>
        </form>
    </div>
</div>

<!-- ══ MODAL: DETAIL VIEW ═══════════════════════════════════ -->
<div class="modal-overlay" id="detailModalOverlay">
    <div class="modal-box" style="max-width: 680px;">
        <div class="modal-hdr">
            <div>
                <h2 class="modal-title">Chi tiết Phiếu nhập kho</h2>
                <p class="modal-subtitle" id="detailModalSubtitle">GRN-XXXX</p>
            </div>
            <button class="modal-close" onclick="closeDetailModal()">&times;</button>
        </div>
        <div class="modal-body" style="gap: 16px;">
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:16px; font-size:13px; color:var(--navy);">
                <div><strong>Nhà cung cấp:</strong> <span id="detail-supplier">NCC</span></div>
                <div><strong>Trạng thái:</strong> <span id="detail-status-badge">Badge</span></div>
                <div><strong>Ngày tạo:</strong> <span id="detail-created-at">Date</span></div>
                <div><strong>Ngày nhận hàng:</strong> <span id="detail-expected-date">Date</span></div>
            </div>
            <div class="draft-items-box">
                <div class="draft-items-hdr" style="background:var(--alice);">
                    <span class="draft-items-title" style="font-weight:700;">Danh sách mặt hàng nhập kho</span>
                </div>
                <table class="grn-body-table">
                    <thead>
                        <tr style="background:#fff;">
                            <th style="padding-left:16px;">SKU</th>
                            <th>Sản phẩm</th>
                            <th style="text-align:right;">Yêu cầu</th>
                            <th style="text-align:right; padding-right:16px;">Thực nhận</th>
                        </tr>
                    </thead>
                    <tbody id="detailItemsTableBody">
                        <!-- Populate -->
                    </tbody>
                </table>
            </div>
            <div class="modal-note" id="detail-notes-box" style="display:none; padding:12px; border:1px solid #ffebc2; background:#fffcf5; border-radius:6px; font-size:12px; color:rgba(16, 55, 92, 0.75);">
                <strong>Ghi chú:</strong> <span id="detail-note-content">Note</span>
            </div>
        </div>
        <div class="modal-ftr">
            <button class="modal-btn-cancel" onclick="closeDetailModal()">Đóng</button>
        </div>
    </div>
</div>

<script id="db-products-data" type="application/json"><c:out value="${productsJson}" escapeXml="true"/></script>
<script id="db-page-flags-data" type="application/json">{"hasInboundList": ${not empty inboundList ? 'true' : 'false'}}</script>
<script id="db-user-data" type="application/json">{"fullName":"<c:out value='${loggedInUser.fullName}'/>","role":"<c:out value='${loggedInUser.role}'/>"}</script>
<script id="db-inbound-list-data" type="application/json">[
<c:forEach items="${inboundList}" var="io" varStatus="s">{"inboundId":${io.inboundId},"inboundCode":"<c:out value='${io.inboundCode}'/>","supplierName":"<c:out value='${io.supplierName}'/>","warehouseName":"<c:out value='${io.warehouseName}'/>","status":"<c:out value='${io.status}'/>","createdAt":"<c:out value='${io.createdAt}'/>","items":${io.itemsJson}}${!s.last ? ',' : ''}
</c:forEach>]
</script>

<script>
(function () {
'use strict';

function safeJsonParse(rawValue, fallbackValue) {
    if (!rawValue) {
        return fallbackValue;
    }
    try {
        return JSON.parse(rawValue);
    } catch (error) {
        return fallbackValue;
    }
}

var WMS_USER_DATA = safeJsonParse(document.getElementById('db-user-data') && document.getElementById('db-user-data').textContent, {});
var PAGE_FLAGS = safeJsonParse(document.getElementById('db-page-flags-data') && document.getElementById('db-page-flags-data').textContent, {});
var DB_PRODUCTS = safeJsonParse(document.getElementById('db-products-data') && document.getElementById('db-products-data').textContent, []);

window.WMS_USER = {
    fullName: WMS_USER_DATA.fullName || 'Guest',
    role: WMS_USER_DATA.role || 'Guest'
};

// Inbound Receipts (from server database)
var savedGRNs = localStorage.getItem('wh_inbound_grns');
var grns = safeJsonParse(savedGRNs, []);

// Load from server data if available
var serverInboundList = safeJsonParse(document.getElementById('db-inbound-list-data') && document.getElementById('db-inbound-list-data').textContent, []);
console.log('[INBOUND] serverInboundList:', serverInboundList.length, serverInboundList);
if (serverInboundList && serverInboundList.length > 0) {
    grns = serverInboundList.map(function(o) {
        var mappedStatus = o.status;
        if (o.status === 'PENDING') mappedStatus = 'pending';
        else if (o.status === 'IN_PROGRESS') mappedStatus = 'in_progress';
        else if (o.status === 'RECEIVED') mappedStatus = 'completed';
        else if (o.status === 'CANCELLED') mappedStatus = 'cancelled';
        else mappedStatus = 'draft';

        return {
            id: o.inboundId,
            inboundCode: o.inboundCode,
            supplier: o.supplierName,
            warehouseName: o.warehouseName,
            status: mappedStatus,
            createdAt: o.createdAt,
            items: (o.items || []).map(function(item) {
                return {
                    skuCode: item.skuCode || item.sku || '',
                    skuName: item.skuName || item.productName || '',
                    orderedQty: parseFloat(item.orderedQty || item.expectedQty || 0),
                    receivedQty: parseFloat(item.receivedQty || 0)
                };
            })
        };
    });
    console.log('[INBOUND] grns after server mapping:', grns.length, grns);
}
console.log('[INBOUND] final grns:', grns.length, grns);

// Master SKUs
var savedSKUs = localStorage.getItem('wms_skus');
var skus = safeJsonParse(savedSKUs, []);
if ((!skus || skus.length === 0) && DB_PRODUCTS.length > 0) {
    skus = DB_PRODUCTS.map(function(p) {
        return {
            id: p.productId || p.id,
            sku: p.skuCode || p.sku,
            name: p.productName || p.name,
            category: p.categoryName || p.category || 'Chưa phân loại',
            status: p.status || 'PENDING',
            qtyOnHand: p.qtyOnHand || 0
        };
    });
}

// Pricing configuration
var savedPricing = localStorage.getItem('wh_pricing_warehouse');
var pricingRecords = safeJsonParse(savedPricing, []);

// If pricing is empty, initialize it from wms_skus
if (pricingRecords.length === 0 && skus.length > 0) {
    pricingRecords = skus.map(function(s, idx) {
        return {
            id: s.id || ('price-' + idx),
            sku: s.sku,
            name: s.name,
            category: s.category || 'Chưa phân loại',
            status: s.status || 'active',
            qtyOnHand: s.qtyOnHand || 0,
            importPrice: 0,
            importUpdatedAt: 'Chưa cập nhật',
            costOfGoodsSold: 0
        };
    });
    localStorage.setItem('wh_pricing_warehouse', JSON.stringify(pricingRecords));
}

// ─── STATE VARIABLES ───
var currentMainTab = 'receipts'; // 'receipts' or 'pricing'
var activeStatusTab = 'all'; // 'all', 'draft', 'pending_bm', 'pending', 'in_progress', 'completed', 'cancelled'
var searchKeyword = '';
var expandedGrnId = null;

// Modal forms state
var draftMode = 'create'; // 'create' or 'duplicate'
var draftSourceId = null;
var draftForm = {
    supplier: '',
    expectedDate: '',
    note: '',
    items: []
};

// ─── TABS SWITCHING ───
window.switchMainTab = function(tabId) {
    currentMainTab = tabId;
    document.getElementById('tab-btn-receipts').classList.toggle('active', tabId === 'receipts');
    document.getElementById('tab-btn-pricing').classList.toggle('active', tabId === 'pricing');
    
    document.getElementById('view-receipts').style.display = tabId === 'receipts' ? 'block' : 'none';
    document.getElementById('view-pricing').style.display = tabId === 'pricing' ? 'block' : 'none';
    
    if (tabId === 'pricing') {
        syncPricingWithSkus();
        renderPricing();
    } else {
        renderReceipts();
    }
};

function syncPricingWithSkus() {
    // Sync current quantities from DB-backed products or localStorage fallback to pricing records
    var currentSKUs = skus && skus.length > 0
        ? skus
        : safeJsonParse(localStorage.getItem('wms_skus'), []);
    var priceRecords = safeJsonParse(localStorage.getItem('wh_pricing_warehouse'), []);
    
    // Update existing or add new ones
    var updated = currentSKUs.map(function(s) {
        var match = priceRecords.find(function(pr) { return pr.sku === s.sku; });
        return {
            id: s.id,
            sku: s.sku,
            name: s.name,
            category: s.category || 'Chưa phân loại',
            status: s.status || 'active',
            qtyOnHand: s.qtyOnHand || 0,
            importPrice: match ? match.importPrice : 0,
            importUpdatedAt: match ? match.importUpdatedAt : 'Chưa cập nhật',
            costOfGoodsSold: (match ? match.importPrice : 0) * (s.qtyOnHand || 0)
        };
    });
    pricingRecords = updated;
    localStorage.setItem('wh_pricing_warehouse', JSON.stringify(pricingRecords));
}

// ─── VIEW 1: RECEIPTS LOGIC ───
// Search handler
var searchInput = document.getElementById('grnSearchInput');
if (searchInput) {
    searchInput.addEventListener('input', function(e) {
        searchKeyword = e.target.value;
        renderReceipts();
    });
}

function getFilteredGRNs() {
    return grns.filter(function (g) {
        var matchTab = activeStatusTab === 'all' || g.status === activeStatusTab;
        var matchSearch = g.id.toString().toLowerCase().indexOf(searchKeyword.toLowerCase()) > -1 || 
                          (g.supplier && g.supplier.toLowerCase().indexOf(searchKeyword.toLowerCase()) > -1) ||
                          (g.inboundCode && g.inboundCode.toLowerCase().indexOf(searchKeyword.toLowerCase()) > -1);
        return matchTab && matchSearch;
    });
}

function updateReceiptsKPIs() {
    var pendingCount = grns.filter(function(g) { return g.status === 'pending'; }).length;
    var inProgressCount = grns.filter(function(g) { return g.status === 'in_progress'; }).length;
    var completedCount = grns.filter(function(g) { return g.status === 'completed'; }).length;
    
    // Sum total received qty of all completed GRN items
    var skuReceivedCount = 0;
    grns.forEach(function(g) {
        if (g.status === 'completed') {
            g.items.forEach(function(item) {
                skuReceivedCount += (item.receivedQty || 0);
            });
        }
    });

    document.getElementById('stat-pending').textContent = pendingCount;
    document.getElementById('stat-in-progress').textContent = inProgressCount;
    document.getElementById('stat-completed').textContent = completedCount;
    document.getElementById('stat-sku-received').textContent = skuReceivedCount.toLocaleString();
}

function renderStatusTabs() {
    var counts = {
        all: grns.length,
        pending: grns.filter(function(g) { return g.status === 'pending'; }).length,
        in_progress: grns.filter(function(g) { return g.status === 'in_progress'; }).length,
        completed: grns.filter(function(g) { return g.status === 'completed'; }).length,
        cancelled: grns.filter(function(g) { return g.status === 'cancelled'; }).length
    };

    var tabsData = [
        { id: 'all', label: 'Tất cả' },
        { id: 'pending', label: 'Chờ' },
        { id: 'in_progress', label: 'Đang nhập' },
        { id: 'completed', label: 'Đã nhập' },
        { id: 'cancelled', label: 'Đã hủy' }
    ];

    var html = tabsData.map(function(tab) {
        var act = tab.id === activeStatusTab ? 'active' : '';
        return '<button class="status-tab-btn ' + act + '" onclick="window.selectStatusTab(\'' + tab.id + '\')">' +
            tab.label +
            '<span class="status-tab-badge">' + counts[tab.id] + '</span>' +
            '</button>';
    }).join('');

    var tabsContainer = document.getElementById('statusTabsContainer');
    if (tabsContainer) tabsContainer.innerHTML = html;
}

window.selectStatusTab = function(statusId) {
    activeStatusTab = statusId;
    renderReceipts();
};

window.toggleGrnExpand = function(grnId) {
    expandedGrnId = expandedGrnId === grnId ? null : grnId;
    renderReceipts();
};

window.toggleDropdownMenu = function(grnId, event) {
    if (event) event.stopPropagation();
    var menu = document.getElementById('dropdown-' + grnId);
    var wasActive = menu.classList.contains('active');
    
    // Close all menus
    var allMenus = document.querySelectorAll('.dropdown-menu');
    allMenus.forEach(function(m) { m.classList.remove('active'); });

    if (!wasActive) {
        menu.classList.add('active');
    }
};

// Close menus when clicking outside
document.addEventListener('click', function(e) {
    if (!e.target.closest('.dropdown-wrap')) {
        var allMenus = document.querySelectorAll('.dropdown-menu');
        allMenus.forEach(function(m) { m.classList.remove('active'); });
    }
});

function getStatusConfig(status) {
    var configs = {
        draft: { label: "Bản nháp", bg: "draft", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="8" height="4" x="8" y="2" rx="1" ry="1"/><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><path d="M9 9h6"/><path d="M9 13h6"/><path d="M9 17h6"/></svg>' },
        pending_bm: { label: "Chờ duyệt", bg: "pending_bm", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>' },
        pending: { label: "Chờ hàng về", bg: "pending", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>' },
        in_progress: { label: "Đang nhập kho", bg: "in_progress", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 17V3"/><path d="m6 11 6 6 6-6"/><path d="M19 21H5"/></svg>' },
        completed: { label: "Hoàn thành", bg: "completed", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>' },
        cancelled: { label: "Đã hủy", bg: "cancelled", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>' }
    };
    return configs[status] || configs.draft;
}

function renderReceipts() {
    localStorage.setItem('wh_inbound_grns', JSON.stringify(grns));
    updateReceiptsKPIs();
    renderStatusTabs();

    var filtered = getFilteredGRNs();
    var listContainer = document.getElementById('grnListContainer');
    
    if (filtered.length === 0) {
        listContainer.innerHTML = '<div style="background:#fff; border:1px dashed var(--border); border-radius:12px; padding:48px; text-align:center; color:rgba(16, 55, 92, 0.40); font-weight:500; font-size:13px;">Không tìm thấy phiếu nhập kho nào.</div>';
        return;
    }

    var html = filtered.map(function(grn) {
        var sc = getStatusConfig(grn.status);
        var isExpanded = expandedGrnId === grn.id;
        var totalOrdered = grn.items.reduce(function(sum, i) { return sum + i.orderedQty; }, 0);
        var totalReceived = grn.items.reduce(function(sum, i) { return sum + i.receivedQty; }, 0);

        var expandedClass = isExpanded ? 'expanded' : '';
        
        // Locked indicator
        var lockHtml = (grn.isLocked && grn.status === 'draft') ?
            '<span class="pill-badge draft" style="margin-left:8px;">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:10px;height:10px;margin-right:2px;"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>' +
            'Khóa</span>' : '';

        // Eye action button (only completed)
        var detailBtn = grn.status === 'completed' ?
            '<button class="btn-action-icon" onclick="openDetailModal(\'' + grn.id + '\', event)" title="Xem chi tiết">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/></svg>' +
            '</button>' : '';

        // Inbound action button (pending / in_progress)
        var receiveBtn = (grn.status === 'pending' || grn.status === 'in_progress') ?
            '<button class="btn-action-grn" onclick="openReceiveModal(\'' + grn.id + '\', event)">Nhập kho</button>' : '';

        // Pending BM badge
        var pendingBmLabel = grn.status === 'pending_bm' ?
            '<span class="pill-badge pending_bm" style="border:1px solid #fde68a; padding:6px 12px; font-size:11px;">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:12px;height:12px;margin-right:4px;vertical-align:middle;"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>' +
            'Chờ duyệt</span>' : '';

        // Dropdown actions menu
        var dropdownHtml = '';
        if (grn.status === 'draft' && !grn.isLocked) {
            dropdownHtml = 
                '<button class="dropdown-btn" onclick="submitForBMAvailability(\'' + grn.id + '\', event)">' +
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>' +
                    'Trình duyệt BM' +
                '</button>' +
                '<button class="dropdown-btn" style="color:#b91c1c;" onclick="cancelDraftGRN(\'' + grn.id + '\', event)">' +
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/></svg>' +
                    'Hủy nháp' +
                '</button>';
        }

        var menuActions = 
            '<div class="dropdown-wrap">' +
                '<button class="btn-action-icon" onclick="window.toggleDropdownMenu(\'' + grn.id + '\', event)" title="Thao tác">' +
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"/><circle cx="12" cy="5" r="1"/><circle cx="12" cy="19" r="1"/></svg>' +
                '</button>' +
                '<div class="dropdown-menu" id="dropdown-' + grn.id + '">' +
                    '<button class="dropdown-btn" onclick="window.duplicateGRN(\'' + grn.id + '\', event)">' +
                        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="14" height="14" x="8" y="8" rx="2" ry="2"/><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/></svg>' +
                        'Nhân bản' +
                    '</button>' +
                    dropdownHtml +
                '</div>' +
            '</div>';

        // Expanded table rows
        var itemsRows = grn.items.map(function(item) {
            var pct = Math.round((item.receivedQty / item.orderedQty) * 100);
            var remaining = item.orderedQty - item.receivedQty;
            var barColor = pct === 100 ? '#10b981' : pct > 0 ? '#F5C842' : 'var(--border)';
            var remainingClass = remaining > 0 ? 'color: var(--orange); font-weight:600;' : 'color: #047857; font-weight:600;';

            return '<tr>' +
                '<td><div style="display:flex; align-items:center; gap:8px;">' +
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:14px; height:14px; color:rgba(16, 55, 92, 0.3);"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path></svg>' +
                    '<span style="font-family:monospace; color:rgba(16, 55, 92, 0.6);">' + item.skuCode + '</span>' +
                '</div></td>' +
                '<td><span style="color:var(--navy); font-weight:600;">' + item.skuName + '</span></td>' +
                '<td style="text-align:right; font-weight:600; color:var(--navy);">' + item.orderedQty + '</td>' +
                '<td style="text-align:right; font-weight:600; color:#047857;">' + item.receivedQty + '</td>' +
                '<td style="text-align:right; ' + remainingClass + '">' + remaining + '</td>' +
                '<td><div style="display:flex; align-items:center; gap:8px;">' +
                    '<div class="progress-bar-wrap"><div class="progress-bar-fill" style="width:' + pct + '%; background:' + barColor + ';"></div></div>' +
                    '<span style="font-size:10px; color:rgba(16, 55, 92, 0.4); min-width:24px; text-align:right;">' + pct + '%</span>' +
                '</div></td>' +
            '</tr>';
        }).join('');

        // Notes box
        var notesBox = grn.note ? 
            '<div class="grn-notes-bar">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="4" x2="20" y1="9" y2="9"/><line x1="4" x2="20" y1="15" y2="15"/><line x1="10" x2="8" y1="3" y2="21"/><line x1="16" x2="14" y1="3" y2="21"/></svg>' +
                '<span>' + grn.note + '</span>' +
            '</div>' : '';

        // Receiver bar
        var receiverBox = grn.receivedBy ?
            '<div class="grn-user-bar">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>' +
                '<span>Người nhập kho: <span style="font-weight:600; color:var(--navy);">' + grn.receivedBy + '</span></span>' +
            '</div>' : '';

        return '<div class="grn-item ' + expandedClass + '">' +
            '<!-- Header -->' +
            '<div class="grn-hdr" onclick="window.toggleGrnExpand(\'' + grn.id + '\')">' +
                '<div class="grn-hdr__icon ' + 'tone-' + (grn.status === 'completed' ? 'emerald' : grn.status === 'in_progress' ? 'orange' : grn.status === 'pending' ? 'blue' : 'navy') + '">' +
                    sc.icon +
                '</div>' +
                '<div class="grn-hdr__info">' +
                    '<div class="grn-meta-row">' +
                        '<span class="grn-id">' + grn.inboundCode + '</span>' +
                        '<span class="pill-badge ' + grn.status + '"><span class="pill-badge__dot"></span>' + sc.label + '</span>' +
                        lockHtml +
                    '</div>' +
                    '<div class="grn-supplier-row">' +
                        '<span class="grn-supplier-cell">' +
                            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 22V4a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v18Z"/><path d="M6 12H4a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h2Z"/><path d="M18 9h2a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2h-2Z"/></svg>' +
                            grn.supplier +
                        '</span>' +
                        '<span>' + grn.createdAt + '</span>' +
                    '</div>' +
                '</div>' +
                '<div class="grn-stats-row">' +
                    '<div class="grn-stat">' +
                        '<div class="grn-stat__lbl">SKU</div>' +
                        '<div class="grn-stat__val">' + grn.items.length + '</div>' +
                    '</div>' +
                    '<div class="grn-stat">' +
                        '<div class="grn-stat__lbl">Nhập / Đặt</div>' +
                        '<div class="grn-stat__val">' +
                            '<span style="' + (totalReceived === totalOrdered ? 'color:#059669;' : '') + '">' + totalReceived + '</span>' +
                            '<span style="font-size:11px; color:rgba(16, 55, 92, 0.3);">/' + totalOrdered + '</span>' +
                        '</div>' +
                    '</div>' +
                    detailBtn +
                    receiveBtn +
                    pendingBmLabel +
                    menuActions +
                    '<svg class="grn-chevron" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>' +
                '</div>' +
            '</div>' +
            
            '<!-- Expanded Body -->' +
            '<div class="grn-body">' +
                '<table class="grn-body-table">' +
                    '<thead>' +
                        '<tr>' +
                            '<th style="width: 140px;">SKU</th>' +
                            '<th>Tên sản phẩm</th>' +
                            '<th style="width: 100px; text-align: right;">Đặt</th>' +
                            '<th style="width: 100px; text-align: right;">Đã nhập</th>' +
                            '<th style="width: 100px; text-align: right;">Còn lại</th>' +
                            '<th style="width: 160px;">Tiến độ</th>' +
                        '</tr>' +
                    '</thead>' +
                    '<tbody>' +
                        itemsRows +
                    '</tbody>' +
                '</table>' +
                notesBox +
                receiverBox +
            '</div>' +
        '</div>';
    }).join('');

    listContainer.innerHTML = html;
}

// ─── DRAFT MODAL ACTIONS ───
var draftOverlay = document.getElementById('draftModalOverlay');

window.openDraftModal = function(mode, sourceId) {
    draftMode = mode;
    draftSourceId = sourceId || null;
    
    var titleEl = document.getElementById('draftModalTitle');
    var supplierInput = document.getElementById('draft-supplier');
    var dateInput = document.getElementById('draft-date');
    var noteInput = document.getElementById('draft-note');
    
    if (mode === 'create') {
        titleEl.textContent = 'Tạo phiếu nhập nháp';
        draftForm = {
            supplier: '',
            expectedDate: '',
            note: '',
            items: [{ skuCode: '', skuName: '', orderedQty: 10 }]
        };
    } else { // duplicate
        var source = grns.find(function(g) { return g.id === sourceId; });
        titleEl.textContent = 'Nhân bản phiếu nhập';
        draftForm = {
            supplier: source ? source.supplier : '',
            expectedDate: source ? source.expectedDate : '',
            note: source ? (source.note || '') : '',
            items: source ? source.items.map(function(item) {
                return { skuCode: item.skuCode, skuName: item.skuName, orderedQty: item.orderedQty };
            }) : []
        };
    }
    
    // Fill values
    supplierInput.value = draftForm.supplier;
    dateInput.value = draftForm.expectedDate;
    noteInput.value = draftForm.note;
    
    renderDraftRows();
    draftOverlay.classList.add('active');
};

window.closeDraftModal = function() {
    draftOverlay.classList.remove('active');
};

window.duplicateGRN = function(grnId, event) {
    if (event) event.stopPropagation();
    openDraftModal('duplicate', grnId);
};

window.addDraftItemRow = function() {
    draftForm.items.push({ skuCode: '', skuName: '', orderedQty: 10 });
    renderDraftRows();
};

window.removeDraftItemRow = function(index) {
    if (draftForm.items.length > 1) {
        draftForm.items.splice(index, 1);
        renderDraftRows();
    }
};

window.updateDraftRowSku = function(index, skuCode) {
    var item = skus.find(function(s) { return s.sku === skuCode; });
    draftForm.items[index].skuCode = skuCode;
    draftForm.items[index].skuName = item ? item.name : '';
    
    // Re-render only inputs names to prevent focus loss, or re-render fully
    renderDraftRows();
};

window.updateDraftRowQty = function(index, qty) {
    draftForm.items[index].orderedQty = parseInt(qty) || 0;
};

function renderDraftRows() {
    var container = document.getElementById('draftRowsContainer');
    
    // Build select options of approved SKUs
    var approvedSkus = skus.filter(function(s) { return s.approvalStatus === 'approved'; });
    
    var html = draftForm.items.map(function(rowItem, index) {
        var skuOptions = approvedSkus.map(function(s) {
            var selected = rowItem.skuCode === s.sku ? 'selected' : '';
            return '<option value="' + s.sku + '" ' + selected + '>' + s.sku + ' (' + s.name.substring(0, 20) + '...)</option>';
        }).join('');
        
        var selectHtml = 
            '<select class="sku-select-input" onchange="window.updateDraftRowSku(' + index + ', this.value)">' +
                '<option value="">-- Chọn SKU --</option>' +
                skuOptions +
            '</select>';

        return '<div class="draft-row">' +
            '<div>' + selectHtml + '</div>' +
            '<div><input class="form-input" style="background:#f1f5f9; border-color:var(--border);" type="text" readonly value="' + rowItem.skuName + '" placeholder="Tên sản phẩm tự điền"/></div>' +
            '<div><input class="form-input" style="text-align:center; background:#fff;" type="number" min="1" value="' + rowItem.orderedQty + '" onchange="window.updateDraftRowQty(' + index + ', this.value)"/></div>' +
            '<div style="text-align:right;"><button class="btn-del-row" onclick="window.removeDraftItemRow(' + index + ')">&times;</button></div>' +
        '</tr>';
    }).join('');
    
    container.innerHTML = html;
}

window.submitDraftGRN = function() {
    var supplierInput = document.getElementById('draft-supplier').value.trim();
    var dateInput = document.getElementById('draft-date').value;
    var noteInput = document.getElementById('draft-note').value.trim();
    
    if (!supplierInput || !dateInput) {
        alert('Vui lòng nhập đầy đủ Nhà cung cấp và Ngày dự kiến!');
        return;
    }
    
    // Filter out invalid items
    var validItems = draftForm.items.filter(function(i) {
        return i.skuCode && i.orderedQty > 0;
    }).map(function(i) {
        return {
            skuCode: i.skuCode,
            skuName: i.skuName,
            orderedQty: i.orderedQty,
            receivedQty: 0
        };
    });
    
    if (validItems.length === 0) {
        alert('Vui lòng chọn ít nhất một SKU hợp lệ với số lượng lớn hơn 0!');
        return;
    }
    
    // Generate GRN ID
    var maxSequence = 0;
    grns.forEach(function(g) {
        var match = g.id.match(/GRN-2026-(\d+)/);
        if (match) {
            var seq = parseInt(match[1]);
            if (seq > maxSequence) maxSequence = seq;
        }
    });
    var nextSeq = String(maxSequence + 1).padStart(4, '0');
    var newId = 'GRN-2026-' + nextSeq;
    
    var now = new Date();
    var createdAtStr = now.getFullYear() + '-' + 
                       padZero(now.getMonth()+1) + '-' + 
                       padZero(now.getDate()) + ' ' + 
                       padZero(now.getHours()) + ':' + 
                       padZero(now.getMinutes());

    var newGRN = {
        id: newId,
        supplier: supplierInput,
        createdAt: createdAtStr,
        expectedDate: dateInput,
        status: 'draft',
        isLocked: false,
        items: validItems,
        note: noteInput || undefined
    };
    
    grns.unshift(newGRN);
    closeDraftModal();
    renderReceipts();
    alert('Tạo phiếu nhập nháp thành công!');
};

// ─── ACTION BUTTONS ───
window.submitForBMAvailability = function(grnId, event) {
    if (event) event.stopPropagation();
    var grn = grns.find(function(g) { return g.id === grnId; });
    if (grn) {
        grn.status = 'pending_bm';
        grn.isLocked = true;
        renderReceipts();
        alert('Đã gửi phiếu nhập ' + grnId + ' lên Quản lý kinh doanh để phê duyệt!');
    }
};

window.cancelDraftGRN = function(grnId, event) {
    if (event) event.stopPropagation();
    if (confirm('Bạn có chắc chắn muốn hủy bản nháp phiếu nhập này không?')) {
        var grn = grns.find(function(g) { return g.id === grnId; });
        if (grn) {
            grn.status = 'cancelled';
            grn.isLocked = true;
            renderReceipts();
        }
    }
};

// ─── RECEIVE GOODS MODAL ───
var receiveOverlay = document.getElementById('receiveModalOverlay');
var receiveQuantities = {};

window.openReceiveModal = function(grnId, event) {
    if (event) event.stopPropagation();
    var grn = grns.find(function(g) { return g.id === grnId; });
    if (!grn) return;
    
    document.getElementById('receive-grn-id').value = grnId;
    document.getElementById('receiveModalSubtitle').textContent = grnId + ' · ' + grn.supplier;
    
    receiveQuantities = {};
    
    var container = document.getElementById('receiveItemsContainer');
    var html = grn.items.map(function(item) {
        // Preset with remaining ordered quantity
        var defaultVal = item.orderedQty - item.receivedQty;
        receiveQuantities[item.skuCode] = defaultVal;
        
        return '<div class="receive-item-card">' +
            '<div style="flex:1;">' +
                '<div style="font-weight:700; color:var(--navy); font-size:13px;">' + item.skuName + '</div>' +
                '<div style="font-family:monospace; color:rgba(16, 55, 92, 0.5); font-size:11px;">' + item.skuCode + '</div>' +
                '<div style="font-size:11px; color:rgba(16, 55, 92, 0.4); margin-top:2px;">Số lượng đặt: <strong style="color:var(--navy);">' + item.orderedQty + '</strong> (Đã nhận: ' + item.receivedQty + ')</div>' +
            '</div>' +
            '<div style="display:flex; align-items:center; gap:8px;">' +
                '<label style="font-size:11px; font-weight:700; color:rgba(16, 55, 92, 0.6);">NHẬP THỰC TẾ:</label>' +
                '<input class="price-input" style="width:90px;" type="number" min="0" max="' + defaultVal + '" value="' + defaultVal + '" onchange="window.updateReceiveQty(\'' + item.skuCode + '\', this.value)"/>' +
            '</div>' +
        '</div>';
    }).join('');
    
    container.innerHTML = html;
    receiveOverlay.classList.add('active');
};

window.updateReceiveQty = function(skuCode, value) {
    receiveQuantities[skuCode] = parseInt(value) || 0;
};

window.closeReceiveModal = function() {
    receiveOverlay.classList.remove('active');
};

window.submitConfirmReceive = function() {
    var grnId = document.getElementById('receive-grn-id').value;
    var grn = grns.find(function(g) { return g.id === grnId; });
    if (!grn) return;
    
    var now = new Date();
    var timeStr = now.getFullYear() + '-' + padZero(now.getMonth()+1) + '-' + padZero(now.getDate()) + ' ' + padZero(now.getHours()) + ':' + padZero(now.getMinutes());

    // Update quantities on items
    grn.items.forEach(function(item) {
        var addedQty = receiveQuantities[item.skuCode] || 0;
        item.receivedQty = (item.receivedQty || 0) + addedQty;
        
        if (addedQty > 0) {
            // 1. Create ledger entry
            logInventoryLedger(item.skuCode, 'inbound', addedQty, grnId, 'GRN', 'Nhập thực tế từ ' + grn.supplier);
            
            // 2. Update stock in wms_skus
            updateMasterSkuQty(item.skuCode, addedQty);
            
            // 3. Update pricing records quantities
            updatePricingQty(item.skuCode, addedQty);
        }
    });
    
    // Check if fully received
    var allCompleted = grn.items.every(function(item) {
        return item.receivedQty >= item.orderedQty;
    });
    
    grn.status = allCompleted ? 'completed' : 'in_progress';
    grn.receivedBy = window.WMS_USER.fullName || 'Nhân viên kho';
    
    closeReceiveModal();
    renderReceipts();
    alert('Xác nhận nhập kho phiếu ' + grnId + ' thành công! Số lượng tồn kho đã được cộng thêm.');
};

function updateMasterSkuQty(skuCode, addedQty) {
    var currentSKUs = safeJsonParse(localStorage.getItem('wms_skus'), []);
    var index = currentSKUs.findIndex(function(s) { return s.sku === skuCode; });
    if (index > -1) {
        currentSKUs[index].qtyOnHand = (currentSKUs[index].qtyOnHand || 0) + addedQty;
        currentSKUs[index].lastUpdated = new Date().toISOString().slice(0, 16).replace("T", " ");
        currentSKUs[index].updatedBy = window.WMS_USER.fullName || 'Nhân viên kho';
        localStorage.setItem('wms_skus', JSON.stringify(currentSKUs));
        skus = currentSKUs; // sync local variable
    }
}

function updatePricingQty(skuCode, addedQty) {
    // Pricing warehouse
    var pw = safeJsonParse(localStorage.getItem('wh_pricing_warehouse'), []);
    var idxW = pw.findIndex(function(p) { return p.sku === skuCode; });
    if (idxW > -1) {
        pw[idxW].qtyOnHand = (pw[idxW].qtyOnHand || 0) + addedQty;
        pw[idxW].costOfGoodsSold = pw[idxW].qtyOnHand * pw[idxW].importPrice;
        localStorage.setItem('wh_pricing_warehouse', JSON.stringify(pw));
    }
    
    // Pricing sales (if exists, sync it too)
    var ps = safeJsonParse(localStorage.getItem('wh_pricing_sales'), []);
    var idxS = ps.findIndex(function(p) { return p.sku === skuCode; });
    if (idxS > -1) {
        ps[idxS].qtyOnHand = (ps[idxS].qtyOnHand || 0) + addedQty;
        localStorage.setItem('wh_pricing_sales', JSON.stringify(ps));
    }
}

function logInventoryLedger(sku, type, quantity, referenceId, referenceType, notes) {
    var ledgerStr = localStorage.getItem('wh_inventory_ledger');
    var ledger = safeJsonParse(ledgerStr, []);
    
    var entry = {
        id: 'LEG-' + Date.now() + '-' + Math.random().toString(36).substring(2, 9),
        sku: sku,
        type: type,
        quantity: quantity,
        warehouseId: 'WH001',
        zone: '',
        location: '',
        referenceId: referenceId,
        referenceType: referenceType,
        notes: notes,
        createdAt: new Date().toISOString(),
        createdBy: window.WMS_USER.fullName || 'Nhân viên kho'
    };
    
    ledger.push(entry);
    localStorage.setItem('wh_inventory_ledger', JSON.stringify(ledger));
}

// ─── DETAIL MODAL VIEW ───
var detailOverlay = document.getElementById('detailModalOverlay');

window.openDetailModal = function(grnId, event) {
    if (event) event.stopPropagation();
    var grn = grns.find(function(g) { return g.id === grnId; });
    if (!grn) return;
    
    document.getElementById('detailModalSubtitle').textContent = grn.inboundCode;
    document.getElementById('detail-supplier').textContent = grn.supplier;
    document.getElementById('detail-created-at').textContent = grn.createdAt;
    document.getElementById('detail-expected-date').textContent = grn.expectedDate;
    
    // Status badge
    var sc = getStatusConfig(grn.status);
    document.getElementById('detail-status-badge').innerHTML = 
        '<span class="pill-badge ' + grn.status + '"><span class="pill-badge__dot"></span>' + sc.label + '</span>';
        
    // Notes block
    var notesBox = document.getElementById('detail-notes-box');
    if (grn.note) {
        document.getElementById('detail-note-content').textContent = grn.note;
        notesBox.style.display = 'block';
    } else {
        notesBox.style.display = 'none';
    }
    
    // Items table
    var tbody = document.getElementById('detailItemsTableBody');
    var html = grn.items.map(function(item) {
        return '<tr>' +
            '<td><span style="font-family:monospace; color:rgba(16, 55, 92, 0.6);">' + item.skuCode + '</span></td>' +
            '<td><span style="font-weight:600; color:var(--navy);">' + item.skuName + '</span></td>' +
            '<td style="text-align:right; font-weight:600;">' + item.orderedQty + '</td>' +
            '<td style="text-align:right; font-weight:600; color:#047857;">' + item.receivedQty + '</td>' +
        '</tr>';
    }).join('');
    tbody.innerHTML = html;
    
    detailOverlay.classList.add('active');
};

window.closeDetailModal = function() {
    detailOverlay.classList.remove('active');
};

// Close detail and other overlays when clicking background
[draftOverlay, receiveOverlay, detailOverlay].forEach(function(ov) {
    if (ov) {
        ov.addEventListener('click', function(e) {
            if (e.target === ov) {
                ov.classList.remove('active');
            }
        });
    }
});

// ─── VIEW 2: PRICING LOGIC ───
window.updatePriceField = function(sku, value) {
    var val = parseFloat(value) || 0;
    var idx = pricingRecords.findIndex(function(p) { return p.sku === sku; });
    if (idx > -1) {
        pricingRecords[idx].importPrice = val;
        pricingRecords[idx].costOfGoodsSold = val * pricingRecords[idx].qtyOnHand;
        document.getElementById('cogs-val-' + sku).textContent = (val * pricingRecords[idx].qtyOnHand).toLocaleString('vi-VN') + 'đ';
        document.getElementById('pricingSaveStatus').textContent = 'Có thay đổi chưa lưu';
    }
};

window.saveSinglePrice = function(sku) {
    var rec = pricingRecords.find(function(p) { return p.sku === sku; });
    if (!rec) return;
    
    var now = new Date();
    var timeStr = now.getFullYear() + '-' + padZero(now.getMonth()+1) + '-' + padZero(now.getDate()) + ' ' + padZero(now.getHours()) + ':' + padZero(now.getMinutes());
    
    rec.importUpdatedAt = timeStr;
    
    // Save to localstorage
    localStorage.setItem('wh_pricing_warehouse', JSON.stringify(pricingRecords));
    renderPricing();
    
    document.getElementById('pricingSaveStatus').textContent = 'Đã lưu lúc ' + now.toLocaleTimeString('vi-VN');
    alert('Đã cập nhật giá nhập cho SKU ' + sku + ' thành công!');
};

window.saveAllPrices = function() {
    var now = new Date();
    var timeStr = now.getFullYear() + '-' + padZero(now.getMonth()+1) + '-' + padZero(now.getDate()) + ' ' + padZero(now.getHours()) + ':' + padZero(now.getMinutes());

    pricingRecords.forEach(function(rec) {
        rec.importUpdatedAt = timeStr;
    });

    localStorage.setItem('wh_pricing_warehouse', JSON.stringify(pricingRecords));
    renderPricing();

    document.getElementById('pricingSaveStatus').textContent = 'Đã lưu tất cả - ' + now.toLocaleTimeString('vi-VN');
    alert('Đã lưu thành công bảng giá nhập cho toàn bộ SKU!');
};

function renderPricing() {
    var tbody = document.getElementById('pricingTableBody');
    var activeCount = pricingRecords.filter(function(p) { return p.status === 'active'; }).length;
    
    var avgImportPrice = 0;
    var totalImportVal = 0;
    var sumPrice = 0;
    
    pricingRecords.forEach(function(p) {
        sumPrice += p.importPrice;
        totalImportVal += (p.importPrice * p.qtyOnHand);
    });
    
    avgImportPrice = pricingRecords.length > 0 ? Math.round(sumPrice / pricingRecords.length) : 0;
    
    document.getElementById('price-stat-active').textContent = activeCount;
    document.getElementById('price-stat-avg').textContent = avgImportPrice.toLocaleString('vi-VN') + 'đ';
    document.getElementById('price-stat-total-cogs').textContent = totalImportVal.toLocaleString('vi-VN') + 'đ';
    
    if (pricingRecords.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:48px;color:rgba(16, 55, 92, 0.4)">Không có sản phẩm nào để cấu hình giá.</td></tr>';
        return;
    }
    
    var html = pricingRecords.map(function(item) {
        var isEditable = item.status === 'active';
        var badgeLabel = item.status === 'active' ? 'Active' : item.status === 'low_stock' ? 'Sắp hết' : 'Inactive';
        var badgeClass = item.status === 'active' ? 'approved' : item.status === 'low_stock' ? 'pending' : 'rejected';
        
        var disabledAttr = isEditable ? '' : 'disabled';
        var rowStyle = isEditable ? '' : 'style="background:rgba(240, 244, 250, 0.25);"';
        
        return '<tr ' + rowStyle + '>' +
            '<td>' +
                '<div style="font-family:monospace; font-weight:700; color:var(--navy);">' + item.sku + '</div>' +
                '<div style="color:rgba(16, 55, 92, 0.4); font-size:11px; margin-top:2px;">' + item.category + '</div>' +
            '</td>' +
            '<td>' +
                '<div style="font-weight:600; color:var(--navy);">' + item.name + '</div>' +
                '<div style="color:rgba(16, 55, 92, 0.4); font-size:11px; margin-top:2px;">Tồn hiện có: ' + item.qtyOnHand.toLocaleString() + '</div>' +
            '</td>' +
            '<td style="text-align:center;">' +
                '<span class="pill-badge ' + (item.status === 'active' ? 'completed' : item.status === 'low_stock' ? 'in_progress' : 'cancelled') + '">' +
                    '<span class="pill-badge__dot"></span>' + badgeLabel +
                '</span>' +
            '</td>' +
            '<td style="text-align:right;">' +
                '<input class="price-input" type="number" min="0" value="' + item.importPrice + '" ' + disabledAttr + ' onchange="window.updatePriceField(\'' + item.sku + '\', this.value)"/>' +
            '</td>' +
            '<td style="text-align:right; font-weight:700; color:var(--navy);" id="cogs-val-' + item.sku + '">' +
                (item.importPrice * item.qtyOnHand).toLocaleString('vi-VN') + 'đ' +
            '</td>' +
            '<td style="color:rgba(16, 55, 92, 0.5); font-size:12px;">' + item.importUpdatedAt + '</td>' +
            '<td style="text-align:right;">' +
                '<button class="btn-save-inline" ' + disabledAttr + ' onclick="window.saveSinglePrice(\'' + item.sku + '\')">' +
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>' +
                    'Lưu' +
                '</button>' +
            '</td>' +
        '</tr>';
    }).join('');
    
    tbody.innerHTML = html;
}

// ─── HELPERS ───
function padZero(n) { return n < 10 ? '0' + n : n; }

// ─── INIT ───
renderReceipts();

// ─── DB-SIDE INBOUND TABLE (from WarehouseInboundServlet) ───
function dbStatusLabel(status) {
    var m = {
        'PENDING':    { label: 'Chờ',        cls: 'pending' },
        'IN_PROGRESS':{ label: 'Đang nhập',   cls: 'confirmed' },
        'CONFIRMED':  { label: 'Đã xác nhận', cls: 'confirmed' },
        'RECEIVED':   { label: 'Đã nhập',     cls: 'received' },
        'CANCELLED':  { label: 'Đã hủy',      cls: 'cancelled' }
    };
    var c = m[status] || { label: status, cls: 'pending' };
    return '<span class="status-pill ' + c.cls + '"><span class="status-pill__dot"></span>' + c.label + '</span>';
}

// DB Inbound counts (for filter tabs)
function dbCounts() {
    return {
        all:         grns.length,
        pending:     grns.filter(function(o){ return o.status === 'pending'; }).length,
        in_progress: grns.filter(function(o){ return o.status === 'in_progress'; }).length,
        completed:   grns.filter(function(o){ return o.status === 'completed'; }).length,
        cancelled:   grns.filter(function(o){ return o.status === 'cancelled'; }).length
    };
}

// Update filter tab counts
var counts = dbCounts();
document.getElementById('db-count-all').textContent = counts.all;
document.getElementById('db-count-pending').textContent = counts.pending;
document.getElementById('db-count-in_progress').textContent = counts.in_progress;
document.getElementById('db-count-completed').textContent = counts.completed;
document.getElementById('db-count-cancelled').textContent = counts.cancelled;

function esc(v) {
    if (v == null) return '';
    return String(v).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

var tabs = document.getElementById('dbFilterTabs');
if (tabs) {
    tabs.addEventListener('click', function(e) {
        var btn = e.target.closest('.db-filter-btn');
        if (!btn) return;
        activeStatusTab = btn.dataset.filter;
        tabs.querySelectorAll('.db-filter-btn').forEach(function(b) { b.classList.remove('active'); });
        btn.classList.add('active');
        renderReceipts();
    });
}

window.openCreatePOModal = function() {
    document.getElementById('createPOModal').classList.add('active');
};
window.closeCreatePOModal = function() {
    document.getElementById('createPOModal').classList.remove('active');
};

window.dbConfirmInbound = function(id, code) {
    if (confirm('Xác nhận phiếu ' + code + '? Trạng thái sẽ chuyển sang Đã xác nhận.')) {
        var form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/warehouse/inbound';
        var actionInput = document.createElement('input');
        actionInput.type = 'hidden';
        actionInput.name = 'action';
        actionInput.value = 'confirm';
        var inboundIdInput = document.createElement('input');
        inboundIdInput.type = 'hidden';
        inboundIdInput.name = 'inboundId';
        inboundIdInput.value = id;
        form.appendChild(actionInput);
        form.appendChild(inboundIdInput);
        document.body.appendChild(form);
        form.submit();
    }
};

window.dbOpenReceiveModal = function(id, code) {
    document.getElementById('receiveDB-inboundId').value = id;
    document.getElementById('receiveDB-subtitle').textContent = 'Mã phiếu: ' + code;

    var container = document.getElementById('receiveDBItemsContainer');
    container.innerHTML =
        '<div class="receive-item-card">' +
            '<div style="flex:1; font-weight:600; color:var(--navy); font-size:13px;">Nhập thông tin nhập kho</div>' +
        '</div>' +
        '<div style="padding:12px; background:var(--alice); border-radius:8px; border:1px solid var(--border);">' +
            '<div class="form-group">' +
                '<label class="form-label">Ghi chú nhập kho</label>' +
                '<input class="form-input" style="background:#fff;" type="text" placeholder="Ghi chú (tùy chọn)"/>' +
            '</div>' +
        '</div>';

    document.getElementById('receiveDBModal').classList.add('active');
};

window.closeReceiveDBModal = function() {
    document.getElementById('receiveDBModal').classList.remove('active');
};

['createPOModal', 'receiveDBModal'].forEach(function(id) {
    var el = document.getElementById(id);
    if (el) {
        el.addEventListener('click', function(e) {
            if (e.target === el) {
                el.classList.remove('active');
            }
        });
    }
});

renderDbTable();

var hasInboundList = !!PAGE_FLAGS.hasInboundList;
var createBtn = document.getElementById('btnCreateGRNTrigger');
if (createBtn) {
    createBtn.addEventListener('click', function() {
        if (hasInboundList) {
            openCreatePOModal();
        } else {
            openDraftModal('create');
        }
    });
}

// Auto-open create modal if action=create parameter is found
var params = new URLSearchParams(window.location.search);
if (params.get('action') === 'create') {
    var prefilledSku = params.get('sku') || '';
    setTimeout(function() {
        if (hasInboundList) {
            if (typeof openCreatePOModal === 'function') openCreatePOModal();
        } else {
            if (typeof openDraftModal === 'function') {
                openDraftModal('create');
                if (prefilledSku && draftForm && draftForm.items && draftForm.items[0]) {
                    var foundItem = skus.find(function(s) { return s.sku === prefilledSku; });
                    draftForm.items[0].skuCode = prefilledSku;
                    draftForm.items[0].skuName = foundItem ? foundItem.name : '';
                    if (typeof renderDraftRows === 'function') renderDraftRows();
                }
            }
        }
    }, 300);
}
})();

</script>
