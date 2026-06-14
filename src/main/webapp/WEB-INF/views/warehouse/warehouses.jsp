<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    /* ─── Grid & Column Layouts ─── */
    .stats-grid-3 {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }
    @media (max-width: 768px) {
        .stats-grid-3 {
            grid-template-columns: 1fr;
        }
    }

    /* ─── Stats Card Styles ─── */
    .stat-card {
        background: #fff;
        border: 1px solid var(--border);
        padding: 20px;
        border-radius: var(--radius-card);
        display: flex;
        align-items: center;
        gap: 16px;
        box-shadow: 0 1px 3px rgba(16, 55, 92, 0.02);
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    .stat-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(16, 55, 92, 0.05);
    }
    .stat-card__icon {
        width: 44px;
        height: 44px;
        border-radius: var(--radius-btn);
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        transition: transform 0.2s ease;
    }
    .stat-card:hover .stat-card__icon {
        transform: scale(1.05);
    }
    .stat-card__icon svg {
        width: 20px;
        height: 20px;
    }
    .stat-card__info {
        flex: 1;
        min-width: 0;
    }
    .stat-card__val {
        font-size: 24px;
        font-weight: 800;
        color: var(--navy);
        line-height: 1.1;
    }
    .stat-card__lbl {
        color: rgba(16, 55, 92, 0.50);
        font-size: 11.5px;
        font-weight: 500;
        margin-top: 4px;
    }

    /* Stats color themes */
    .theme-navy .stat-card__icon {
        background: rgba(16, 55, 92, 0.08);
        color: var(--navy);
    }
    .theme-emerald .stat-card__icon {
        background: #ECFDF5;
        color: #059669;
    }
    .theme-emerald .stat-card__val {
        color: #059669;
    }
    .theme-orange .stat-card__icon {
        background: rgba(235, 131, 23, 0.10);
        color: var(--orange);
    }
    .theme-orange .stat-card__val {
        color: var(--orange);
    }

    /* ─── Actions Bar ─── */
    .action-bar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 16px;
        gap: 16px;
    }
    .search-input-wrap {
        position: relative;
        flex: 1;
        max-width: 448px;
    }
    .search-input-wrap svg {
        position: absolute;
        left: 12px;
        top: 50%;
        transform: translateY(-50%);
        width: 15px;
        height: 15px;
        color: rgba(16, 55, 92, 0.35);
        pointer-events: none;
    }
    .search-input {
        width: 100%;
        padding: 9px 12px 9px 36px;
        background: #fff;
        border: 1px solid var(--border);
        font-size: 13px;
        color: var(--navy);
        outline: none;
        transition: border-color 0.15s, box-shadow 0.15s;
        border-radius: calc(var(--radius-btn) - 2px);
    }
    .search-input::placeholder {
        color: rgba(16, 55, 92, 0.30);
    }
    .search-input:focus {
        border-color: rgba(16, 55, 92, 0.40);
        box-shadow: 0 0 0 3px rgba(16, 55, 92, 0.05);
    }
    .btn-add {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 9px 18px;
        background: var(--navy);
        color: #fff;
        font-size: 13px;
        font-weight: 600;
        border: none;
        cursor: pointer;
        transition: background 0.15s, transform 0.1s;
        border-radius: calc(var(--radius-btn) - 2px);
        box-shadow: 0 2px 4px rgba(16, 55, 92, 0.08);
    }
    .btn-add:hover {
        background: #0d2c4b;
    }
    .btn-add:active {
        transform: scale(0.98);
    }
    .btn-add svg {
        width: 16px;
        height: 16px;
    }

    /* ─── Data Table Card ─── */
    .table-card {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        overflow: hidden;
        box-shadow: 0 1px 3px rgba(16, 55, 92, 0.02);
    }
    .table-responsive {
        width: 100%;
        overflow-x: auto;
    }
    .wms-table {
        width: 100%;
        border-collapse: collapse;
        text-align: left;
    }
    .wms-table th {
        background: var(--alice);
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: rgba(16, 55, 92, 0.50);
        padding: 12px 16px;
        border-bottom: 1px solid var(--border);
        white-space: nowrap;
        user-select: none;
    }
    .wms-table td {
        padding: 14px 16px;
        border-bottom: 1px solid #F0F3FA;
        vertical-align: top;
        font-size: 13px;
        color: var(--navy);
    }
    .wms-table tbody tr {
        transition: background 0.15s;
    }
    .wms-table tbody tr:hover {
        background: rgba(240, 244, 250, 0.40);
    }

    /* Cell styles */
    .code-cell-wrapper {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-top: 2px;
    }
    .code-cell-wrapper svg {
        width: 15px;
        height: 15px;
        color: rgba(16, 55, 92, 0.40);
        flex-shrink: 0;
    }
    .warehouse-code {
        font-family: monospace;
        font-weight: 600;
        color: var(--navy);
        font-size: 13px;
    }
    .name-cell {
        font-weight: 500;
        margin-top: 2px;
        line-height: 1.4;
    }
    .address-row {
        display: flex;
        align-items: start;
        gap: 6px;
        color: rgba(16, 55, 92, 0.70);
        font-size: 12.5px;
        margin-bottom: 8px;
        line-height: 1.4;
    }
    .address-row svg {
        width: 14px;
        height: 14px;
        color: rgba(16, 55, 92, 0.40);
        margin-top: 2px;
        flex-shrink: 0;
    }
    .zones-row {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: 6px;
        padding-top: 2px;
    }
    .zones-label {
        font-size: 10px;
        font-weight: 700;
        text-transform: uppercase;
        color: rgba(16, 55, 92, 0.40);
        display: inline-flex;
        align-items: center;
        gap: 4px;
        margin-right: 4px;
    }
    .zones-label svg {
        width: 12px;
        height: 12px;
    }
    .zone-tag {
        font-size: 10.5px;
        font-weight: 500;
        padding: 2.5px 8px;
        border-radius: 4px;
        border: 1px solid transparent;
        white-space: nowrap;
    }
    .zone-tag-normal {
        background: #ECFDF5;
        color: #047857;
        border-color: rgba(16, 185, 129, 0.15);
    }
    .zone-tag-defect {
        background: #FEF2F2;
        color: #B91C1C;
        border-color: rgba(239, 68, 68, 0.15);
    }
    .zone-tag-dispute {
        background: #FFFBEB;
        color: #B45309;
        border-color: rgba(245, 158, 11, 0.15);
    }
    .zone-tag-custom {
        background: var(--alice);
        color: rgba(16, 55, 92, 0.60);
        border-color: #DDE4F0;
    }

    .phone-cell {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        color: rgba(16, 55, 92, 0.70);
        margin-top: 2px;
    }
    .phone-cell svg {
        width: 14px;
        height: 14px;
        color: rgba(16, 55, 92, 0.40);
    }

    /* Status Badge */
    .status-badge {
        display: inline-flex;
        align-items: center;
        padding: 4px 10px;
        font-size: 11px;
        font-weight: 600;
        border: 1px solid transparent;
        border-radius: calc(var(--radius-btn) - 4px);
        white-space: nowrap;
        margin-top: 2px;
    }
    .status-badge-active {
        background: #ECFDF5;
        color: #047857;
        border-color: rgba(16, 185, 129, 0.20);
    }
    .status-badge-closed {
        background: rgba(16, 55, 92, 0.08);
        color: rgba(16, 55, 92, 0.60);
        border-color: rgba(16, 55, 92, 0.20);
    }

    /* Table Actions */
    .actions-wrap {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        margin-top: 2px;
    }
    .btn-edit {
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        border: none;
        background: none;
        color: rgba(16, 55, 92, 0.45);
        cursor: pointer;
        border-radius: calc(var(--radius-btn) - 4px);
        transition: color 0.15s, background 0.15s;
    }
    .btn-edit:hover {
        color: var(--navy);
        background: var(--alice);
    }
    .btn-edit svg {
        width: 16px;
        height: 16px;
    }
    .btn-status-toggle {
        padding: 6px 12px;
        font-size: 11px;
        font-weight: 600;
        border: none;
        cursor: pointer;
        border-radius: calc(var(--radius-btn) - 4px);
        transition: background 0.15s, color 0.15s;
        white-space: nowrap;
    }
    .btn-status-toggle-active {
        background: rgba(235, 131, 23, 0.08);
        color: var(--orange);
    }
    .btn-status-toggle-active:hover {
        background: rgba(235, 131, 23, 0.15);
    }
    .btn-status-toggle-closed {
        background: #ECFDF5;
        color: #059669;
    }
    .btn-status-toggle-closed:hover {
        background: #D1FAE5;
    }

    .table-footer {
        padding: 16px 24px;
        background: var(--alice);
        border-top: 1px solid #F0F3FA;
        font-size: 12px;
        color: rgba(16, 55, 92, 0.60);
    }

    /* ─── Empty State ─── */
    .empty-state {
        padding: 64px 24px;
        text-align: center;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
    }
    .empty-state svg {
        width: 48px;
        height: 48px;
        color: rgba(16, 55, 92, 0.20);
        margin-bottom: 16px;
    }
    .empty-state-title {
        font-size: 15px;
        font-weight: 700;
        color: var(--navy);
        margin-bottom: 4px;
    }
    .empty-state-desc {
        font-size: 12px;
        color: rgba(16, 55, 92, 0.45);
        max-width: 320px;
        line-height: 1.5;
    }

    /* ─── Modals ─── */
    .modal-overlay {
        position: fixed;
        inset: 0;
        background: rgba(16, 55, 92, 0.45);
        backdrop-filter: blur(4px);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;
        opacity: 0;
        pointer-events: none;
        transition: opacity 0.25s ease;
        padding: 24px 16px;
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
        box-shadow: 0 20px 25px -5px rgba(16, 55, 92, 0.15), 0 10px 10px -5px rgba(16, 55, 92, 0.05);
        transform: translateY(24px);
        transition: transform 0.25s ease;
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
    .modal-title-group {
        display: flex;
        flex-direction: column;
    }
    .modal-title {
        color: var(--navy);
        font-size: 16px;
        font-weight: 800;
    }
    .modal-subtitle {
        color: rgba(16, 55, 92, 0.40);
        font-size: 11.5px;
        margin-top: 3px;
        line-height: 1.4;
    }
    .modal-close {
        background: none;
        border: none;
        cursor: pointer;
        font-size: 24px;
        line-height: 1;
        color: rgba(16, 55, 92, 0.35);
        transition: color 0.15s, background-color 0.15s;
        width: 32px;
        height: 32px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .modal-close:hover {
        color: var(--navy);
        background: var(--alice);
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
        background: var(--white);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        font-family: inherit;
        color: var(--navy);
        outline: none;
        transition: border-color 0.15s, box-shadow 0.15s;
    }
    .form-input::placeholder {
        color: rgba(16, 55, 92, 0.30);
    }
    .form-input:focus {
        border-color: rgba(16, 55, 92, 0.40);
        box-shadow: 0 0 0 3px rgba(16, 55, 92, 0.05);
    }
    textarea.form-input {
        resize: none;
    }
    
    .form-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 12px;
    }
    @media (max-width: 480px) {
        .form-grid {
            grid-template-columns: 1fr;
        }
    }

    .section-title-row {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 4px;
    }
    .section-title {
        color: var(--navy);
        font-size: 12.5px;
        font-weight: 750;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .section-title svg {
        width: 16px;
        height: 16px;
        color: rgba(16, 55, 92, 0.40);
    }
    .section-desc {
        color: rgba(16, 55, 92, 0.40);
        font-size: 11px;
        line-height: 1.4;
        margin-bottom: 12px;
    }

    /* Status Toggle inside Form */
    .status-toggle-container {
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .status-toggle-lbl {
        font-size: 12px;
        font-weight: 600;
        color: rgba(16, 55, 92, 0.60);
    }
    .btn-switch {
        background: none;
        border: none;
        cursor: pointer;
        padding: 0;
        display: inline-flex;
        align-items: center;
        color: rgba(16, 55, 92, 0.30);
        transition: color 0.15s;
        outline: none;
    }
    .btn-switch svg {
        width: 28px;
        height: 28px;
    }
    .btn-switch.active {
        color: #10B981;
    }
    .status-text-indicator {
        font-size: 12px;
        font-weight: 700;
    }
    .status-text-indicator.active {
        color: #059669;
    }
    .status-text-indicator.closed {
        color: rgba(16, 55, 92, 0.40);
    }

    /* Modal Checklist */
    .modal-checklist {
        background: rgba(240, 244, 250, 0.50);
        border: 1px solid var(--border);
        border-radius: var(--radius-btn);
        padding: 16px;
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    .checklist-item {
        display: flex;
        align-items: start;
        gap: 10px;
        cursor: pointer;
        user-select: none;
    }
    .checklist-checkbox {
        width: 15px;
        height: 15px;
        border-radius: 4px;
        border: 1px solid #C8D3E8;
        accent-color: var(--navy);
        margin-top: 2px;
        cursor: pointer;
    }
    .checklist-info {
        flex: 1;
        min-width: 0;
    }
    .checklist-title-line {
        display: flex;
        align-items: center;
        gap: 6px;
        font-weight: 700;
        font-size: 12px;
        color: var(--navy);
    }
    .checklist-badge {
        font-size: 9px;
        font-weight: 700;
        text-transform: uppercase;
        padding: 1.5px 5px;
        border-radius: 3px;
        border: 1px solid transparent;
        line-height: 1;
    }
    .checklist-badge-normal {
        background: #ECFDF5;
        color: #047857;
        border-color: #A7F3D0;
    }
    .checklist-badge-defect {
        background: #FEF2F2;
        color: #B91C1C;
        border-color: #FCA5A5;
    }
    .checklist-badge-dispute {
        background: #FFFBEB;
        color: #B45309;
        border-color: #FDE68A;
    }
    .checklist-desc {
        font-size: 11px;
        color: rgba(16, 55, 92, 0.50);
        margin-top: 3px;
        line-height: 1.4;
    }

    /* Custom Zones Configuration */
    .custom-zones-box {
        display: flex;
        flex-direction: column;
        gap: 10px;
    }
    .custom-zones-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .custom-zones-lbl {
        font-size: 12px;
        font-weight: 700;
        color: rgba(16, 55, 92, 0.70);
    }
    .btn-add-cz {
        background: none;
        border: none;
        cursor: pointer;
        font-size: 12px;
        font-weight: 700;
        color: var(--navy);
        display: inline-flex;
        align-items: center;
        gap: 4px;
        outline: none;
        transition: color 0.15s;
    }
    .btn-add-cz:hover {
        color: var(--orange);
    }
    .btn-add-cz svg {
        width: 14px;
        height: 14px;
    }
    .cz-row {
        display: flex;
        align-items: center;
        gap: 8px;
        background: rgba(240, 244, 250, 0.35);
        padding: 6px 8px;
        border-radius: var(--radius-btn);
        border: 1px solid var(--border);
        transition: transform 0.15s ease;
    }
    .cz-label {
        font-family: monospace;
        font-size: 10px;
        font-weight: 700;
        color: rgba(16, 55, 92, 0.40);
        width: 60px;
        text-align: center;
    }
    .cz-input {
        flex: 1;
        padding: 6px 10px;
        border: 1px solid var(--border);
        background: #fff;
        font-size: 12.5px;
        color: var(--navy);
        outline: none;
        border-radius: calc(var(--radius-btn) - 4px);
    }
    .cz-input:focus {
        border-color: rgba(16, 55, 92, 0.40);
    }
    .btn-remove-cz {
        background: none;
        border: none;
        cursor: pointer;
        color: #fca5a5;
        padding: 6px;
        border-radius: 4px;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: color 0.15s, background-color 0.15s;
    }
    .btn-remove-cz:hover {
        color: #ef4444;
        background: #fef2f2;
    }
    .btn-remove-cz svg {
        width: 14px;
        height: 14px;
    }

    /* DB Sync Card */
    .sync-card {
        background: #EFF6FF;
        border: 1px solid #BFDBFE;
        border-radius: var(--radius-btn);
        padding: 12px;
        display: flex;
        align-items: start;
        gap: 10px;
        font-size: 11.5px;
        color: #1E40AF;
        line-height: 1.5;
    }
    .sync-card svg {
        width: 16px;
        height: 16px;
        color: #3B82F6;
        margin-top: 1.5px;
        flex-shrink: 0;
    }
    .sync-card-title {
        font-weight: 700;
        display: block;
        margin-bottom: 2px;
    }
    .sync-card code {
        background: rgba(255, 255, 255, 0.80);
        padding: 1px 4px;
        border-radius: 3px;
        font-family: monospace;
        font-size: 10.5px;
    }

    .modal-ftr {
        padding: 16px 24px;
        border-top: 1px solid var(--border);
        background: var(--alice);
        display: flex;
        justify-content: flex-end;
        gap: 12px;
    }
    .btn-modal-cancel {
        padding: 9px 18px;
        background: #fff;
        border: 1px solid var(--border);
        color: rgba(16, 55, 92, 0.70);
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        border-radius: calc(var(--radius-btn) - 2px);
        transition: background 0.15s, color 0.15s;
    }
    .btn-modal-cancel:hover {
        background: var(--alice);
        color: var(--navy);
    }
    .btn-modal-save {
        padding: 9px 18px;
        background: var(--navy);
        border: none;
        color: #fff;
        font-size: 13px;
        font-weight: 700;
        cursor: pointer;
        border-radius: calc(var(--radius-btn) - 2px);
        transition: background 0.15s, opacity 0.15s;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        box-shadow: 0 1px 2px rgba(16, 55, 92, 0.05);
    }
    .btn-modal-save:hover {
        background: #0d2c4b;
    }
    .btn-modal-save:disabled {
        opacity: 0.40;
        cursor: not-allowed;
    }
    .btn-modal-save svg {
        width: 14px;
        height: 14px;
    }
</style>

<!-- Stats Grid -->
<div class="stats-grid-3">
    <!-- Stat card 1: Total Warehouses -->
    <div class="stat-card theme-navy">
        <div class="stat-card__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M22 8.35V20a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V8.35A2 2 0 0 1 3.26 6.5l8-3.2a2 2 0 0 1 1.48 0l8 3.2A2 2 0 0 1 22 8.35Z"/>
                <path d="M6 18h12"/>
                <path d="M6 14h12"/>
                <rect width="4" height="6" x="10" y="18" rx="0"/>
            </svg>
        </div>
        <div class="stat-card__info">
            <div class="stat-card__val" id="totalCountEl">0</div>
            <div class="stat-card__lbl">Tổng số chi nhánh kho</div>
        </div>
    </div>

    <!-- Stat card 2: Active Warehouses -->
    <div class="stat-card theme-emerald">
        <div class="stat-card__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/>
                <path d="m9 12 2 2 4-4"/>
            </svg>
        </div>
        <div class="stat-card__info">
            <div class="stat-card__val" id="activeCountEl">0</div>
            <div class="stat-card__lbl">Đang hoạt động</div>
        </div>
    </div>

    <!-- Stat card 3: Closed Warehouses -->
    <div class="stat-card theme-orange">
        <div class="stat-card__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/>
                <line x1="12" x2="12" y1="8" y2="12"/>
                <line x1="12" x2="12.01" y1="16" y2="16"/>
            </svg>
        </div>
        <div class="stat-card__info">
            <div class="stat-card__val" id="closedCountEl">0</div>
            <div class="stat-card__lbl">Tạm đóng cửa</div>
        </div>
    </div>
</div>

<!-- Actions Toolbar -->
<div class="action-bar">
    <div class="search-input-wrap">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="11" cy="11" r="8"/>
            <path d="m21 21-4.3-4.3"/>
        </svg>
        <input class="search-input" type="text" id="warehouseSearch" placeholder="Tìm mã kho, tên kho, địa chỉ..."/>
    </div>
    <button class="btn-add" id="btnAddNewWarehouse">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M5 12h14"/>
            <path d="M12 5v14"/>
        </svg>
        Thêm kho mới
    </button>
</div>

<!-- Table Card wrapper -->
<div class="table-card">
    <div class="table-responsive">
        <table class="wms-table">
            <thead>
                <tr>
                    <th style="width: 130px;">Mã kho</th>
                    <th style="width: 200px;">Tên kho</th>
                    <th>Địa chỉ & Các phân khu (Zones)</th>
                    <th style="width: 130px; text-align: center;">Số điện thoại</th>
                    <th style="width: 140px; text-align: center;">Trạng thái</th>
                    <th style="width: 155px; text-align: center;">Hành động</th>
                </tr>
            </thead>
            <tbody id="warehouseTableBody">
                <!-- Will be dynamically populated -->
            </tbody>
        </table>
    </div>
    <div class="table-footer">
        <span id="showingCountEl">Hiển thị 0 / 0 kho hàng</span>
    </div>
</div>

<!-- ════════════════════════════════════════════════════
    ADD / EDIT MODAL — identical to React WarehouseList modal
    ════════════════════════════════════════════════════ -->
<div class="modal-overlay" id="warehouseModalOverlay">
    <div class="modal-box">
        <!-- Header -->
        <div class="modal-hdr">
            <div class="modal-title-group">
                <h3 class="modal-title" id="modalTitleText">Thêm kho mới (Chi nhánh vật lý)</h3>
                <p class="modal-subtitle">Cấu hình các thông số định danh và phân khu mặc định của kho</p>
            </div>
            <button class="modal-close" id="btnModalClose">&times;</button>
        </div>

        <!-- Body -->
        <div class="modal-body">
            <!-- SECTION 1: BASIC INFORMATION -->
            <div class="section-title-row">
                <h4 class="section-title">Thông tin cơ bản</h4>
                
                <!-- Status Switch -->
                <div class="status-toggle-container">
                    <span class="status-toggle-lbl">Trạng thái:</span>
                    <button type="button" class="btn-switch active" id="btnSwitchStatus" aria-label="Status Toggle">
                        <svg id="toggleIcon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect width="20" height="12" x="2" y="6" rx="6" ry="6"/>
                            <circle cx="16" cy="12" r="2"/>
                        </svg>
                    </button>
                    <span class="status-text-indicator active" id="statusTextIndicator">Đang hoạt động</span>
                </div>
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label" for="whCode">Mã kho *</label>
                    <input class="form-input" type="text" id="whCode" placeholder="VD: WH-HCM-01"/>
                </div>
                <div class="form-group">
                    <label class="form-label" for="whPhone">Số điện thoại *</label>
                    <input class="form-input" type="text" id="whPhone" placeholder="VD: 028 3823 4567"/>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="whName">Tên kho *</label>
                <input class="form-input" type="text" id="whName" placeholder="VD: Kho HCM - Quận 1"/>
            </div>

            <div class="form-group">
                <label class="form-label" for="whAddress">Địa chỉ *</label>
                <textarea class="form-input" id="whAddress" rows="2" placeholder="VD: 123 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM"></textarea>
            </div>

            <!-- Separator line -->
            <div style="border-top: 1px solid var(--border); margin: 4px 0;"></div>

            <!-- SECTION 2: ZONES CONFIGURATION -->
            <div>
                <h4 class="section-title">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="m12 3-10 5L12 13l10-5-10-5Z"/>
                        <path d="m2 17 10 5 10-5"/>
                        <path d="m2 12 10 5 10-5"/>
                    </svg>
                    Thiết lập phân khu lưu trữ (Zones) trong kho
                </h4>
                <p class="section-desc">
                    Theo quy chuẩn vận hành hệ thống WMS, chi nhánh kho mới khởi tạo sẽ tự động được gán các phân khu tiêu chuẩn để phục vụ đúng luồng các Use Cases (nhập hàng mới, hoàn trả, khiếu nại).
                </p>
            </div>

            <!-- Default checklist -->
            <div class="modal-checklist">
                <!-- Normal Zone -->
                <label class="checklist-item">
                    <input type="checkbox" class="checklist-checkbox" id="chkNormal" checked/>
                    <div class="checklist-info">
                        <div class="checklist-title-line">
                            Khu Hàng Thường (Normal Zone)
                            <span class="checklist-badge checklist-badge-normal">Tiêu chuẩn</span>
                        </div>
                        <p class="checklist-desc">Chứa hàng hóa đạt tiêu chuẩn chất lượng, sẵn sàng phục vụ xuất kho bán hàng.</p>
                    </div>
                </label>

                <!-- Defect Zone -->
                <label class="checklist-item" style="border-top: 1px solid rgba(229, 234, 243, 0.6); padding-top: 10px;">
                    <input type="checkbox" class="checklist-checkbox" id="chkDefect" checked/>
                    <div class="checklist-info">
                        <div class="checklist-title-line">
                            Khu Hàng Hỏng (Defect Zone)
                            <span class="checklist-badge checklist-badge-defect">Bắt buộc</span>
                        </div>
                        <p class="checklist-desc">Lưu trữ hàng hóa bị hư hỏng, lỗi ngoại quan chờ phê duyệt thanh lý hủy bỏ.</p>
                    </div>
                </label>

                <!-- Dispute Zone -->
                <label class="checklist-item" style="border-top: 1px solid rgba(229, 234, 243, 0.6); padding-top: 10px;">
                    <input type="checkbox" class="checklist-checkbox" id="chkDispute" checked/>
                    <div class="checklist-info">
                        <div class="checklist-title-line">
                            Khu Hàng Khiếu Nại (Dispute Zone)
                            <span class="checklist-badge checklist-badge-dispute">Hoàn trả</span>
                        </div>
                        <p class="checklist-desc">Phục vụ cách ly kiện hàng bị khách trả về, chờ nhân viên QC kiểm định chất lượng.</p>
                    </div>
                </label>
            </div>

            <!-- Custom Zones -->
            <div class="custom-zones-box">
                <div class="custom-zones-header">
                    <span class="custom-zones-lbl">Các phân khu tùy chỉnh thêm (Tùy chọn)</span>
                    <button type="button" class="btn-add-cz" id="btnAddCustomZone">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="12" cy="12" r="10"/>
                            <path d="M8 12h8"/>
                            <path d="M12 8v8"/>
                        </svg>
                        Thêm khu vực tùy chỉnh
                    </button>
                </div>
                
                <!-- Custom zone list placeholder -->
                <div id="customZonesContainer" style="display: flex; flex-direction: column; gap: 8px;"></div>
            </div>

            <!-- DB Sync Info Callout -->
            <div class="sync-card">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"/>
                    <path d="M12 16v-4"/>
                    <path d="M12 8h.01"/>
                </svg>
                <div>
                    <span class="sync-card-title">Đồng bộ kiến trúc CSDL (Database Architecture)</span>
                    Khi bạn nhấn lưu kho, hệ thống sẽ thực hiện đồng thời: khởi tạo 1 bản ghi <code>location</code> mới và tự động chèn liên kết khóa ngoại <code>location_id</code> vào bảng <code>zone</code>.
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class="modal-ftr">
            <button class="btn-modal-cancel" id="btnModalCancel">Hủy</button>
            <button class="btn-modal-save" id="btnModalSave" disabled>
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/>
                    <polyline points="17 21 17 13 7 13 7 21"/>
                    <polyline points="7 3 7 8 15 8"/>
                </svg>
                Lưu thông tin kho
            </button>
        </div>
    </div>
</div>

<!-- ════════════════════════════════════════════════════
    JAVASCRIPT LOGIC
    ════════════════════════════════════════════════════ -->
<script>
    // In-memory data store. Starts empty and populated from backend.
    window.WMS_WAREHOUSE_DATA = [];

    (function() {
        'use strict';

        // DOM caching
        var totalCountEl = document.getElementById('totalCountEl');
        var activeCountEl = document.getElementById('activeCountEl');
        var closedCountEl = document.getElementById('closedCountEl');
        var warehouseSearch = document.getElementById('warehouseSearch');
        var btnAddNewWarehouse = document.getElementById('btnAddNewWarehouse');
        var warehouseTableBody = document.getElementById('warehouseTableBody');
        var showingCountEl = document.getElementById('showingCountEl');

        // Modal DOM Elements
        var modalOverlay = document.getElementById('warehouseModalOverlay');
        var modalTitleText = document.getElementById('modalTitleText');
        var btnModalClose = document.getElementById('btnModalClose');
        var btnModalCancel = document.getElementById('btnModalCancel');
        var btnModalSave = document.getElementById('btnModalSave');
        var btnSwitchStatus = document.getElementById('btnSwitchStatus');
        var toggleIcon = document.getElementById('toggleIcon');
        var statusTextIndicator = document.getElementById('statusTextIndicator');
        var whCode = document.getElementById('whCode');
        var whPhone = document.getElementById('whPhone');
        var whName = document.getElementById('whName');
        var whAddress = document.getElementById('whAddress');
        
        // Checklist Checkboxes
        var chkNormal = document.getElementById('chkNormal');
        var chkDefect = document.getElementById('chkDefect');
        var chkDispute = document.getElementById('chkDispute');

        // Custom zones DOM
        var btnAddCustomZone = document.getElementById('btnAddCustomZone');
        var customZonesContainer = document.getElementById('customZonesContainer');

        // Local state variables for form
        var editingWarehouseId = null; // null means adding new, otherwise ID of edited
        var currentFormStatus = "active"; // "active" | "closed"
        var currentCustomZones = []; // list of { id: string, name: string }

        // Filter text
        var searchText = "";

        // Bind standard event listeners
        warehouseSearch.addEventListener('input', function(e) {
            searchText = e.target.value;
            renderWarehouses();
        });

        btnAddNewWarehouse.addEventListener('click', function() {
            openModal(null);
        });

        btnModalClose.addEventListener('click', closeModal);
        btnModalCancel.addEventListener('click', closeModal);

        // Status switch logic
        btnSwitchStatus.addEventListener('click', function() {
            if (currentFormStatus === "active") {
                setFormStatus("closed");
            } else {
                setFormStatus("active");
            }
        });

        // Add custom zone
        btnAddCustomZone.addEventListener('click', function() {
            var newId = 'cz-' + Math.random().toString(36).substring(2, 9);
            currentCustomZones.push({ id: newId, name: "" });
            renderCustomZonesForm();
        });

        // Form Validation triggers
        var formFields = [whCode, whPhone, whName, whAddress];
        formFields.forEach(function(field) {
            field.addEventListener('input', validateForm);
        });

        btnModalSave.addEventListener('click', saveForm);

        // Function to update Form Toggle buttons state visually
        function setFormStatus(status) {
            currentFormStatus = status;
            if (status === "active") {
                btnSwitchStatus.classList.add('active');
                statusTextIndicator.className = "status-text-indicator active";
                statusTextIndicator.textContent = "Đang hoạt động";
                // SVG for ToggleRight
                toggleIcon.innerHTML = '<rect width="20" height="12" x="2" y="6" rx="6" ry="6"/><circle cx="16" cy="12" r="2"/>';
            } else {
                btnSwitchStatus.classList.remove('active');
                statusTextIndicator.className = "status-text-indicator closed";
                statusTextIndicator.textContent = "Tạm ngưng";
                // SVG for ToggleLeft
                toggleIcon.innerHTML = '<rect width="20" height="12" x="2" y="6" rx="6" ry="6"/><circle cx="8" cy="12" r="2"/>';
            }
        }

        // Custom zones rendering in Form modal
        function renderCustomZonesForm() {
            customZonesContainer.innerHTML = "";
            currentCustomZones.forEach(function(cz, index) {
                var rowDiv = document.createElement('div');
                rowDiv.className = "cz-row";

                var numSpan = document.createElement('span');
                numSpan.className = "cz-label";
                numSpan.textContent = "ZONE #" + (index + 1);

                var input = document.createElement('input');
                input.className = "cz-input";
                input.type = "text";
                input.value = cz.name;
                input.placeholder = "Ví dụ: Khu Hàng Dự Trữ, Khu Hàng Khuyến Mãi...";
                input.addEventListener('input', function(e) {
                    cz.name = e.target.value;
                });

                var removeBtn = document.createElement('button');
                removeBtn.type = "button";
                removeBtn.className = "btn-remove-cz";
                removeBtn.title = "Xóa khu vực này";
                removeBtn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/><line x1="10" x2="10" y1="11" y2="17"/><line x1="14" x2="14" y1="11" y2="17"/></svg>';
                removeBtn.addEventListener('click', function() {
                    currentCustomZones = currentCustomZones.filter(function(item) {
                        return item.id !== cz.id;
                    });
                    renderCustomZonesForm();
                });

                rowDiv.appendChild(numSpan);
                rowDiv.appendChild(input);
                rowDiv.appendChild(removeBtn);
                customZonesContainer.appendChild(rowDiv);
            });
        }

        // Form fields validator
        function validateForm() {
            var codeVal = whCode.value.trim();
            var phoneVal = whPhone.value.trim();
            var nameVal = whName.value.trim();
            var addressVal = whAddress.value.trim();

            var isValid = codeVal && phoneVal && nameVal && addressVal;
            btnModalSave.disabled = !isValid;
        }

        // Open Modal Handler
        function openModal(warehouse) {
            if (warehouse) {
                // Edit mode
                editingWarehouseId = warehouse.id;
                modalTitleText.textContent = "Sửa thông tin kho chi nhánh";
                
                whCode.value = warehouse.code;
                whPhone.value = warehouse.phone;
                whName.value = warehouse.name;
                whAddress.value = warehouse.address;

                setFormStatus(warehouse.status);

                // Detect check status of standard zones
                var hasNormal = warehouse.zones.some(function(z) { return z.name.indexOf("Normal") !== -1 || z.name.indexOf("Thường") !== -1; });
                var hasDefect = warehouse.zones.some(function(z) { return z.name.indexOf("Defect") !== -1 || z.name.indexOf("Hỏng") !== -1; });
                var hasDispute = warehouse.zones.some(function(z) { return z.name.indexOf("Dispute") !== -1 || z.name.indexOf("Khiếu Nại") !== -1; });

                chkNormal.checked = hasNormal;
                chkDefect.checked = hasDefect;
                chkDispute.checked = hasDispute;

                // Load custom zones
                currentCustomZones = [];
                warehouse.zones.forEach(function(z) {
                    if (!z.isDefault) {
                        currentCustomZones.push({ id: z.id, name: z.name });
                    }
                });
            } else {
                // Add new mode
                editingWarehouseId = null;
                modalTitleText.textContent = "Thêm kho mới (Chi nhánh vật lý)";

                whCode.value = "";
                whPhone.value = "";
                whName.value = "";
                whAddress.value = "";

                setFormStatus("active");

                chkNormal.checked = true;
                chkDefect.checked = true;
                chkDispute.checked = true;

                currentCustomZones = [];
            }

            renderCustomZonesForm();
            validateForm();
            modalOverlay.classList.add('active');
        }

        function closeModal() {
            modalOverlay.classList.remove('active');
            editingWarehouseId = null;
        }

        // Save Modal Form
        function saveForm() {
            var codeVal = whCode.value.trim().toUpperCase();
            var phoneVal = whPhone.value.trim();
            var nameVal = whName.value.trim();
            var addressVal = whAddress.value.trim();

            var generatedZones = [];

            // Add standard default zones if checked
            if (chkNormal.checked) {
                generatedZones.push({
                    id: 0,
                    code: codeVal + '-NORM',
                    name: "Khu Hàng Thường (Normal Zone)",
                    zoneType: "NORMAL",
                    isDefault: true
                });
            }
            if (chkDefect.checked) {
                generatedZones.push({
                    id: 0,
                    code: codeVal + '-DEFC',
                    name: "Khu Hàng Hỏng (Defect Zone)",
                    zoneType: "DAMAGED",
                    isDefault: true
                });
            }
            if (chkDispute.checked) {
                generatedZones.push({
                    id: 0,
                    code: codeVal + '-DISP',
                    name: "Khu Hàng Khiếu Nại (Dispute Zone)",
                    zoneType: "RETURN",
                    isDefault: true
                });
            }

            // Add custom zones
            currentCustomZones.forEach(function(cz, idx) {
                if (cz.name.trim()) {
                    var isNew = cz.id.toString().indexOf('cz-') === 0;
                    generatedZones.push({
                        id: isNew ? 0 : parseInt(cz.id),
                        code: codeVal + '-CUST-' + (idx + 1),
                        name: cz.name.trim(),
                        zoneType: "NORMAL",
                        isDefault: false
                    });
                }
            });

            var payload = {
                id: editingWarehouseId ? parseInt(editingWarehouseId) : 0,
                code: codeVal,
                phone: phoneVal,
                name: nameVal,
                address: addressVal,
                status: currentFormStatus,
                zones: generatedZones
            };

            fetch(window.location.pathname + '?action=save', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload)
            })
            .then(function(res) { return res.json(); })
            .then(function(resData) {
                if (resData.success) {
                    closeModal();
                    fetchWarehouses();
                } else {
                    alert(resData.message || 'Lỗi khi lưu kho hàng.');
                }
            })
            .catch(function(err) {
                console.error('Error saving warehouse:', err);
                alert('Có lỗi mạng xảy ra khi lưu kho hàng.');
            });
        }

        // Fetch warehouses from backend API
        function fetchWarehouses() {
            fetch(window.location.pathname + '?action=list')
                .then(function(res) { return res.json(); })
                .then(function(data) {
                    window.WMS_WAREHOUSE_DATA = data;
                    renderWarehouses();
                })
                .catch(function(err) {
                    console.error('Error fetching warehouses:', err);
                });
        }

        // Render function
        function renderWarehouses() {
            var list = window.WMS_WAREHOUSE_DATA;
            
            // Search filters
            var filtered = list.filter(function(w) {
                var term = searchText.toLowerCase();
                return w.code.toLowerCase().indexOf(term) !== -1 ||
                       w.name.toLowerCase().indexOf(term) !== -1 ||
                       w.address.toLowerCase().indexOf(term) !== -1;
            });

            // Calculate KPIs
            var totalCount = list.length;
            var activeCount = list.filter(function(w) { return w.status === 'active'; }).length;
            var closedCount = list.filter(function(w) { return w.status === 'closed'; }).length;

            totalCountEl.textContent = totalCount;
            activeCountEl.textContent = activeCount;
            closedCountEl.textContent = closedCount;

            showingCountEl.textContent = "Hiển thị " + filtered.length + " / " + totalCount + " kho hàng";

            // Clear table
            warehouseTableBody.innerHTML = "";

            if (filtered.length === 0) {
                // Empty state rendering
                var tr = document.createElement('tr');
                var td = document.createElement('td');
                td.colSpan = 6;
                td.style.padding = "0";

                var emptyDiv = document.createElement('div');
                emptyDiv.className = "empty-state";
                emptyDiv.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 8.35V20a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V8.35A2 2 0 0 1 3.26 6.5l8-3.2a2 2 0 0 1 1.48 0l8 3.2A2 2 0 0 1 22 8.35Z"/><rect width="4" height="6" x="10" y="18" rx="0"/></svg>' +
                                     '<div class="empty-state-title">Chưa có chi nhánh kho nào</div>' +
                                     '<div class="empty-state-desc">Hãy nhấn nút "Thêm kho mới" ở góc trên bên phải để bắt đầu thiết lập chi nhánh kho hàng đầu tiên.</div>';
                
                td.appendChild(emptyDiv);
                tr.appendChild(td);
                warehouseTableBody.appendChild(tr);
                return;
            }

            // Populate rows
            filtered.forEach(function(warehouse) {
                var tr = document.createElement('tr');

                // Column 1: Code
                var tdCode = document.createElement('td');
                tdCode.innerHTML = '<div class="code-cell-wrapper">' +
                                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 8.35V20a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V8.35A2 2 0 0 1 3.26 6.5l8-3.2a2 2 0 0 1 1.48 0l8 3.2A2 2 0 0 1 22 8.35Z"/><path d="M6 18h12"/><path d="M6 14h12"/><rect width="4" height="6" x="10" y="18" rx="0"/></svg>' +
                                    '<span class="warehouse-code">' + escapeHtml(warehouse.code) + '</span>' +
                                   '</div>';
                tr.appendChild(tdCode);

                // Column 2: Name
                var tdName = document.createElement('td');
                tdName.innerHTML = '<div class="name-cell">' + escapeHtml(warehouse.name) + '</div>';
                tr.appendChild(tdName);

                // Column 3: Address & Zones
                var tdAddress = document.createElement('td');
                var addressHtml = '<div class="address-row">' +
                                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/></svg>' +
                                    '<span>' + escapeHtml(warehouse.address) + '</span>' +
                                  '</div>';

                if (warehouse.zones && warehouse.zones.length > 0) {
                    addressHtml += '<div class="zones-row">' +
                                     '<span class="zones-label">' +
                                       '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m12 3-10 5L12 13l10-5-10-5Z"/><path d="m2 17 10 5 10-5"/><path d="m2 12 10 5 10-5"/></svg>' +
                                       'Zones (' + warehouse.zones.length + '):' +
                                     '</span>';
                    
                    warehouse.zones.forEach(function(zone) {
                        var tagStyleClass = "zone-tag-custom";
                        var nameLower = zone.name.toLowerCase();
                        if (nameLower.indexOf("normal") !== -1 || nameLower.indexOf("thường") !== -1) {
                            tagStyleClass = "zone-tag-normal";
                        } else if (nameLower.indexOf("defect") !== -1 || nameLower.indexOf("hỏng") !== -1) {
                            tagStyleClass = "zone-tag-defect";
                        } else if (nameLower.indexOf("dispute") !== -1 || nameLower.indexOf("khiếu nại") !== -1) {
                            tagStyleClass = "zone-tag-dispute";
                        }

                        // Remove standard subtitle " (Normal Zone)" etc. for tag visual cleanliness
                        var displayName = zone.name.split(" (")[0];

                        addressHtml += '<span class="zone-tag ' + tagStyleClass + '" title="' + escapeHtml(zone.code) + '">' +
                                         escapeHtml(displayName) +
                                       '</span>';
                    });
                    addressHtml += '</div>';
                }

                tdAddress.innerHTML = addressHtml;
                tr.appendChild(tdAddress);

                // Column 4: Phone
                var tdPhone = document.createElement('td');
                tdPhone.style.textAlign = "center";
                tdPhone.innerHTML = '<div class="phone-cell">' +
                                      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>' +
                                      escapeHtml(warehouse.phone) +
                                    '</div>';
                tr.appendChild(tdPhone);

                // Column 5: Status
                var tdStatus = document.createElement('td');
                tdStatus.style.textAlign = "center";
                if (warehouse.status === "active") {
                    tdStatus.innerHTML = '<span class="status-badge status-badge-active">Đang hoạt động</span>';
                } else {
                    tdStatus.innerHTML = '<span class="status-badge status-badge-closed">Tạm đóng cửa</span>';
                }
                tr.appendChild(tdStatus);

                // Column 6: Actions
                var tdActions = document.createElement('td');
                tdActions.style.textAlign = "center";
                
                var actionWrapper = document.createElement('div');
                actionWrapper.className = "actions-wrap";

                var editBtn = document.createElement('button');
                editBtn.className = "btn-edit";
                editBtn.title = "Sửa thông tin & Zones";
                editBtn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>';
                editBtn.addEventListener('click', function() {
                    openModal(warehouse);
                });

                var statusBtn = document.createElement('button');
                if (warehouse.status === "active") {
                    statusBtn.className = "btn-status-toggle btn-status-toggle-active";
                    statusBtn.textContent = "Đóng cửa";
                } else {
                    statusBtn.className = "btn-status-toggle btn-status-toggle-closed";
                    statusBtn.textContent = "Mở lại";
                }
                statusBtn.addEventListener('click', function() {
                    toggleWarehouseStatus(warehouse.id);
                });

                actionWrapper.appendChild(editBtn);
                actionWrapper.appendChild(statusBtn);
                tdActions.appendChild(actionWrapper);
                tr.appendChild(tdActions);

                warehouseTableBody.appendChild(tr);
            });
        }

        // Toggle status handler
        function toggleWarehouseStatus(id) {
            var currentWh = window.WMS_WAREHOUSE_DATA.find(function(w) { return w.id === id; });
            if (!currentWh) return;
            
            var nextActive = currentWh.status !== 'active';
            
            fetch(window.location.pathname + '?action=toggleStatus&id=' + id + '&active=' + nextActive, {
                method: 'POST'
            })
            .then(function(res) { return res.json(); })
            .then(function(resData) {
                if (resData.success) {
                    fetchWarehouses();
                } else {
                    alert(resData.message || 'Không thể thay đổi trạng thái kho hàng.');
                }
            })
            .catch(function(err) {
                console.error('Error toggling status:', err);
                alert('Có lỗi mạng xảy ra khi cập nhật trạng thái.');
            });
        }

        // Helper: Escape HTML to avoid XSS injections
        function escapeHtml(text) {
            if (!text) return "";
            return text.toString()
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#039;");
        }

        // Initialize table render from backend
        fetchWarehouses();
    })();
</script>
