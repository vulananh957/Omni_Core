<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    /* ─── Stats Grid & Cards ─── */
    .outbound-stats-grid-4 {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }
    @media (max-width: 1024px) {
        .outbound-stats-grid-4 {
            grid-template-columns: repeat(2, 1fr);
        }
    }
    @media (max-width: 640px) {
        .outbound-stats-grid-4 {
            grid-template-columns: 1fr;
        }
    }

    .outbound-kpi-card {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 16px 20px;
        display: flex !important;
        flex-direction: row !important;
        align-items: center !important;
        gap: 16px !important;
        box-shadow: 0 1px 3px rgba(0,0,0,0.02);
    }
    .outbound-kpi-card__icon-box {
        width: 40px;
        height: 40px;
        border-radius: var(--radius-btn);
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }
    .outbound-kpi-card__icon-box svg {
        width: 20px;
        height: 20px;
    }
    .outbound-kpi-card__info {
        flex: 1;
        min-width: 0;
        display: block !important;
    }
    .outbound-kpi-card__val {
        font-size: 22px;
        font-weight: 800;
        color: var(--navy);
        line-height: 1.1;
        letter-spacing: -0.03em;
        margin-bottom: 2px;
    }
    .outbound-kpi-card__lbl {
        color: rgba(16, 55, 92, 0.50);
        font-size: 11px;
        font-weight: 500;
    }

    .tone-blue .outbound-kpi-card__icon-box { background: rgba(59, 130, 246, 0.1); }
    .tone-blue .outbound-kpi-card__icon-box svg { color: #2563eb; }
    
    .tone-orange .outbound-kpi-card__icon-box { background: rgba(235, 131, 23, 0.1); }
    .tone-orange .outbound-kpi-card__icon-box svg { color: var(--orange); }
    .tone-orange .outbound-kpi-card__val { color: var(--orange); }

    .tone-purple .outbound-kpi-card__icon-box { background: rgba(147, 51, 234, 0.1); }
    .tone-purple .outbound-kpi-card__icon-box svg { color: #9333ea; }
    .tone-purple .outbound-kpi-card__val { color: #9333ea; }

    .tone-emerald .outbound-kpi-card__icon-box { background: rgba(16, 185, 129, 0.1); }
    .tone-emerald .outbound-kpi-card__icon-box svg { color: #059669; }
    .tone-emerald .outbound-kpi-card__val { color: #059669; }

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
        pointer-events: none;
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
    .btn-action-primary {
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
    .btn-action-primary:hover {
        background: #ea580c;
    }
    .btn-action-primary:disabled {
        background: rgba(16, 55, 92, 0.10);
        color: rgba(16, 55, 92, 0.3);
        cursor: not-allowed;
    }
    .btn-action-red {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 8px 16px;
        background: #dc2626;
        border: none;
        border-radius: calc(var(--radius-btn) - 2px);
        color: #fff;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.15s;
    }
    .btn-action-red:hover {
        background: #b91c1c;
    }
    .btn-action-secondary {
        display: inline-flex;
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
        transition: all 0.15s;
    }
    .btn-action-secondary:hover {
        color: var(--navy);
        background: rgba(16, 55, 92, 0.05);
    }

    /* ─── Status Tabs ─── */
    .status-tabs-wrap {
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
    }
    .status-tab-btn.active .status-tab-badge {
        background: rgba(255, 255, 255, 0.20);
        color: #fff;
    }

    /* ─── Pick Orders List ─── */
    .outbound-list {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    .outbound-item {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        overflow: hidden;
        transition: all 0.15s;
    }
    .outbound-hdr {
        display: flex;
        align-items: center;
        gap: 16px;
        padding: 16px 20px;
        cursor: pointer;
        transition: background 0.12s;
    }
    .outbound-hdr:hover {
        background: rgba(240, 244, 250, 0.40);
    }
    .outbound-channel-badge {
        width: 40px;
        height: 40px;
        border-radius: var(--radius-btn);
        display: flex;
        align-items: center;
        justify-content: center;
        color: #fff;
        font-size: 10px;
        font-weight: bold;
        flex-shrink: 0;
    }
    .outbound-hdr__info {
        flex: 1;
        min-width: 0;
    }
    .outbound-meta-row {
        display: flex;
        align-items: center;
        gap: 10px;
        flex-wrap: wrap;
    }
    .outbound-id {
        font-size: 14px;
        font-weight: 800;
        color: var(--navy);
    }
    .outbound-ref {
        color: rgba(16, 55, 92, 0.3);
        font-size: 11px;
    }
    .outbound-extra-badge {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 2px 8px;
        font-size: 10px;
        font-weight: 700;
        border-radius: 20px;
        border: 1px solid transparent;
    }
    .outbound-extra-badge.disposal {
        background: #fee2e2;
        color: #b91c1c;
        border-color: #fecaca;
    }
    .outbound-extra-badge.rejected {
        background: #fef2f2;
        color: #dc2626;
        border-color: #fee2e2;
    }
    .outbound-extra-badge.draft-unapproved {
        background: rgba(16, 55, 92, 0.10);
        color: rgba(16, 55, 92, 0.6);
    }
    
    .outbound-courier-row {
        display: flex;
        align-items: center;
        gap: 16px;
        margin-top: 4px;
        color: rgba(16, 55, 92, 0.40);
        font-size: 11px;
    }
    .outbound-courier-cell {
        display: flex;
        align-items: center;
        gap: 4px;
    }
    .outbound-courier-cell svg {
        width: 12px;
        height: 12px;
    }
    .outbound-disposal-reason {
        color: #dc2626;
        font-weight: 600;
    }
    .outbound-reject-reason-box {
        margin-top: 6px;
        font-size: 11px;
        color: #b91c1c;
        background: #fef2f2;
        padding: 10px;
        border: 1px solid #fee2e2;
        border-radius: 6px;
        display: flex;
        align-items: flex-start;
        gap: 8px;
    }
    .outbound-reject-reason-box svg {
        width: 14px;
        height: 14px;
        flex-shrink: 0;
        margin-top: 1px;
    }

    .outbound-actions-row {
        display: flex;
        align-items: center;
        gap: 16px;
        flex-shrink: 0;
    }
    .outbound-stat {
        text-align: right;
    }
    .outbound-stat__lbl {
        color: rgba(16, 55, 92, 0.40);
        font-size: 9px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        margin-bottom: 2px;
    }
    .outbound-stat__val {
        font-size: 14px;
        font-weight: 800;
        color: var(--navy);
    }
    .btn-view-doc {
        width: 32px;
        height: 32px;
        border-radius: var(--radius-btn);
        background: var(--alice);
        border: none;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        color: rgba(16, 55, 92, 0.4);
        transition: all 0.15s;
    }
    .btn-view-doc:hover {
        background: rgba(16, 55, 92, 0.08);
        color: var(--navy);
    }
    .btn-view-doc svg {
        width: 16px;
        height: 16px;
    }
    .btn-workflow-step {
        padding: 6px 12px;
        font-size: 12px;
        font-weight: 700;
        border: none;
        border-radius: calc(var(--radius-btn) - 4px);
        color: #fff;
        cursor: pointer;
        transition: background 0.12s;
    }
    .btn-workflow-step.blue { background: var(--navy); }
    .btn-workflow-step.blue:hover { background: #112d4a; }
    .btn-workflow-step.purple { background: #9333ea; }
    .btn-workflow-step.purple:hover { background: #7e22ce; }
    .btn-workflow-step.orange { background: var(--orange); }
    .btn-workflow-step.orange:hover { background: #ea580c; }
    .btn-workflow-step.amber { background: #d97706; }
    .btn-workflow-step.amber:hover { background: #b45309; }
    
    .label-checker-status {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 12px;
        background: #fef3c7;
        color: #b45309;
        font-size: 12px;
        font-weight: 700;
        border: 1px solid #fde68a;
        border-radius: calc(var(--radius-btn) - 4px);
    }

    .chevron-arrow {
        width: 16px;
        height: 16px;
        color: rgba(16, 55, 92, 0.3);
        transition: transform 0.2s ease;
    }
    .outbound-item.expanded .chevron-arrow {
        transform: rotate(180deg);
    }

    /* Expanded Content */
    .outbound-body {
        border-top: 1px solid var(--border);
        display: none;
    }
    .outbound-item.expanded .outbound-body {
        display: block;
    }
    .outbound-address-bar {
        background: var(--alice);
        border-bottom: 1px solid var(--border);
        padding: 12px 20px;
        font-size: 12px;
        color: rgba(16, 55, 92, 0.6);
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .outbound-address-bar svg {
        width: 12px;
        height: 12px;
        color: rgba(16, 55, 92, 0.4);
    }
    .outbound-table {
        width: 100%;
        border-collapse: collapse;
    }
    .outbound-table th {
        background: #fff;
        padding: 10px 16px;
        font-size: 10px;
        font-weight: 700;
        color: rgba(16, 55, 92, 0.40);
        text-transform: uppercase;
        letter-spacing: 0.05em;
        border-bottom: 1px solid var(--border);
    }
    .outbound-table th:first-child { padding-left: 20px; }
    .outbound-table th:last-child { padding-right: 20px; }
    .outbound-table td {
        padding: 12px 16px;
        border-bottom: 1px solid var(--border);
        font-size: 12px;
    }
    .outbound-table td:first-child { padding-left: 20px; }
    .outbound-table td:last-child { padding-right: 20px; }
    .outbound-table tr:last-child td { border-bottom: none; }

    /* SKU Location Badges */
    .sku-loc-badges {
        display: inline-flex;
        align-items: center;
        gap: 2px;
        font-size: 11px;
        font-weight: 600;
    }
    .sku-loc-left {
        padding: 3px 8px;
        background: rgba(16, 55, 92, 0.08);
        color: rgba(16, 55, 92, 0.7);
        border-radius: 4px 0 0 4px;
    }
    .sku-loc-divider {
        color: rgba(16, 55, 92, 0.3);
    }
    .sku-loc-right {
        padding: 3px 8px;
        background: var(--navy);
        color: #fff;
        border-radius: 0 4px 4px 0;
    }

    /* ─── Modals ─── */
    .overlay-backdrop {
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
    .overlay-backdrop.active {
        opacity: 1;
        pointer-events: auto;
    }
    .modal-shell {
        background: #fff;
        border-radius: var(--radius-card);
        box-shadow: 0 20px 25px -5px rgba(16, 55, 92, 0.15);
        transform: translateY(24px);
        transition: transform 0.2s ease;
        overflow: hidden;
    }
    .overlay-backdrop.active .modal-shell {
        transform: translateY(0);
    }

    /* Modal Layouts */
    .modal-size-sm { width: 440px; max-width: 95vw; }
    .modal-size-md { width: 500px; max-width: 95vw; }
    .modal-size-xl { width: 1000px; max-width: 95vw; height: 85vh; display: flex; flex-direction: column; }
    
    .modal-header-section {
        padding: 16px 24px;
        border-bottom: 1px solid var(--border);
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .modal-hdr-title {
        color: var(--navy);
        font-size: 16px;
        font-weight: 800;
    }
    .modal-hdr-desc {
        color: rgba(16, 55, 92, 0.40);
        font-size: 12px;
        margin-top: 2px;
    }
    .btn-modal-close-icon {
        background: none;
        border: none;
        cursor: pointer;
        font-size: 24px;
        line-height: 1;
        color: rgba(16, 55, 92, 0.4);
        transition: color 0.15s;
    }
    .btn-modal-close-icon:hover {
        color: var(--navy);
    }
    .modal-body-section {
        padding: 24px;
        overflow-y: auto;
        flex: 1;
    }
    .modal-footer-section {
        padding: 16px 24px;
        border-top: 1px solid var(--border);
        background: var(--alice);
        display: flex;
        justify-content: flex-end;
        gap: 12px;
    }

    /* ─── Draft Creation Layout ─── */
    .draft-split-view {
        display: grid;
        grid-template-columns: 1.1fr 1.4fr;
        height: 100%;
        min-height: 0;
    }
    .draft-left-pane {
        border-right: 1px solid var(--border);
        background: rgba(240, 244, 250, 0.20);
        overflow-y: auto;
        padding: 20px;
    }
    .draft-right-pane {
        overflow-y: auto;
        padding: 24px;
        background: #fff;
    }
    .draft-item-select-btn {
        width: 100%;
        text-align: left;
        padding: 14px;
        border: 1px solid var(--border);
        background: #fff;
        border-radius: var(--radius-card);
        cursor: pointer;
        transition: all 0.15s;
        margin-bottom: 10px;
    }
    .draft-item-select-btn:hover {
        border-color: rgba(16, 55, 92, 0.2);
    }
    .draft-item-select-btn.active {
        border-color: var(--orange);
        box-shadow: 0 4px 6px -1px rgba(235,131,23,0.1);
    }
    .draft-item-select-btn.incoming-new {
        background: #ecfdf5;
        border-color: #a7f3d0;
    }

    /* Form Fields */
    .outbound-form-group {
        display: flex;
        flex-direction: column;
        gap: 6px;
        margin-bottom: 16px;
    }
    .outbound-form-label {
        color: rgba(16, 55, 92, 0.60);
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }
    .outbound-form-input {
        width: 100%;
        padding: 10px 14px;
        border: 1px solid var(--border);
        background: var(--alice);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        color: var(--navy);
        outline: none;
        transition: border-color 0.15s;
    }
    .outbound-form-input:focus {
        border-color: rgba(16, 55, 92, 0.40);
    }
    .outbound-form-input:disabled {
        background: rgba(16, 55, 92, 0.05);
        color: rgba(16, 55, 92, 0.4);
        cursor: not-allowed;
    }
    .outbound-form-textarea {
        width: 100%;
        padding: 10px 14px;
        border: 1px solid var(--border);
        background: var(--alice);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        color: var(--navy);
        outline: none;
        resize: none;
        transition: border-color 0.15s;
    }
    .outbound-form-textarea:focus {
        border-color: rgba(16, 55, 92, 0.40);
    }

    /* Image Upload evidence */
    .scrap-upload-box {
        border: 1px dashed var(--border);
        padding: 20px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 12px;
        background: rgba(240, 244, 250, 0.1);
        border-radius: var(--radius-card);
        text-align: center;
    }
    .scrap-upload-icon {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: rgba(16, 55, 92, 0.05);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 18px;
        color: rgba(16, 55, 92, 0.4);
    }
    .scrap-evidence-preview {
        position: relative;
        width: 100%;
        height: 150px;
        overflow: hidden;
        border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
    }
    .scrap-evidence-preview img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
    .btn-remove-evidence {
        position: absolute;
        top: 8px;
        right: 8px;
        width: 24px;
        height: 24px;
        border-radius: 50%;
        background: rgba(16, 55, 92, 0.8);
        border: none;
        color: #fff;
        font-size: 12px;
        font-weight: bold;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: background 0.15s;
    }
    .btn-remove-evidence:hover {
        background: var(--navy);
    }

    /* ─── IssueNoteDetail print layout ─── */
    .print-receipt-container {
        font-family: 'Inter', sans-serif;
        color: var(--navy);
        line-height: 1.5;
    }
    .print-table {
        width: 100%;
        border-collapse: collapse;
        border: 2px solid rgba(16, 55, 92, 0.2);
        margin-top: 16px;
    }
    .print-table th {
        background: var(--alice);
        border: 1px solid rgba(16, 55, 92, 0.2);
        padding: 10px 8px;
        font-size: 10px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: rgba(16, 55, 92, 0.5);
    }
    .print-table td {
        border: 1px solid rgba(16, 55, 92, 0.2);
        padding: 8px 10px;
        font-size: 12px;
        vertical-align: middle;
    }
    .print-sign-grid {
        display: grid;
        grid-template-columns: repeat(5, 1fr);
        gap: 12px;
        text-align: center;
        margin-top: 32px;
    }
    .print-sign-title {
        font-size: 10px;
        font-weight: 700;
        text-transform: uppercase;
        color: rgba(16, 55, 92, 0.6);
        margin-bottom: 30px;
    }
    .print-sign-desc {
        font-size: 10px;
        font-style: italic;
        color: rgba(16, 55, 92, 0.4);
    }
    /* Alert Banners */
    .outbound-alert-banner {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 12px 16px;
        margin-bottom: 16px;
        border: 1px solid transparent;
        border-radius: var(--radius-card);
    }
    .outbound-alert-banner.success {
        background: rgba(16, 185, 129, 0.08);
        border-color: rgba(16, 185, 129, 0.35);
    }
    .outbound-alert-banner.warning {
        background: rgba(245, 200, 66, 0.15);
        border-color: rgba(245, 200, 66, 0.40);
    }
    .outbound-alert-banner svg {
        width: 18px;
        height: 18px;
        flex-shrink: 0;
    }
    .outbound-alert-banner.success svg {
        color: #059669;
    }
    .outbound-alert-banner.warning svg {
        color: var(--orange);
    }
    .outbound-alert-banner.warning p span, .outbound-alert-banner.warning p strong {
        color: var(--orange) !important;
        font-weight: 700;
    }
    .outbound-alert-banner p {
        margin: 0;
        font-size: 12px;
        font-weight: 500;
        color: var(--navy);
        flex: 1;
    }
    .outbound-alert-banner p strong, .outbound-alert-banner p span {
        font-weight: 700;
    }
    .outbound-alert-banner button {
        padding: 6px 12px;
        font-size: 12px;
        font-weight: 600;
        color: #fff;
        border: none;
        border-radius: calc(var(--radius-btn) - 4px);
        cursor: pointer;
        transition: background 0.12s;
    }

    /* ─── Pill Badges & Status ─── */
    .pill-badge {
        display: inline-flex !important;
        align-items: center !important;
        gap: 6px !important;
        padding: 4px 10px !important;
        font-size: 11px !important;
        font-weight: 700 !important;
        border-radius: 20px !important;
        text-transform: none !important;
    }
    .pill-badge__dot {
        width: 6px !important;
        height: 6px !important;
        border-radius: 50% !important;
        display: inline-block !important;
        flex-shrink: 0 !important;
    }

    .pill-badge.draft {
        background: rgba(16, 55, 92, 0.08) !important;
        color: rgba(16, 55, 92, 0.6) !important;
    }
    .pill-badge.draft .pill-badge__dot {
        background: rgba(16, 55, 92, 0.3) !important;
    }

    .pill-badge.pending_bm {
        background: #fef3c7 !important;
        color: #b45309 !important;
        border: 1px solid #fde68a !important;
    }
    .pill-badge.pending_bm .pill-badge__dot {
        background: #f59e0b !important;
    }

    .pill-badge.pending_pick {
        background: #eff6ff !important;
        color: #1d4ed8 !important;
    }
    .pill-badge.pending_pick .pill-badge__dot {
        background: #3b82f6 !important;
    }

    .pill-badge.picking {
        background: rgba(245, 200, 66, 0.15) !important;
        color: #d97706 !important;
    }
    .pill-badge.picking .pill-badge__dot {
        background: #f5c842 !important;
    }

    .pill-badge.packed {
        background: #f3e8ff !important;
        color: #7e22ce !important;
    }
    .pill-badge.packed .pill-badge__dot {
        background: #a855f7 !important;
    }

    .pill-badge.dispatched {
        background: #ecfdf5 !important;
        color: #047857 !important;
    }
    .pill-badge.dispatched .pill-badge__dot {
        background: #10b981 !important;
    }
</style>

<!-- ══ SUMMARY STATS CARDS ════════════════════════════════════ -->
<div class="outbound-stats-grid-4">
    <!-- Pending Prepare -->
    <div class="outbound-kpi-card tone-blue">
        <div class="outbound-kpi-card__icon-box">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
            </svg>
        </div>
        <div class="outbound-kpi-card__info">
            <div class="outbound-kpi-card__val" id="stat-pending-pick">0</div>
            <div class="outbound-kpi-card__lbl">Chờ chuẩn bị hàng</div>
        </div>
    </div>
    
    <!-- Picking -->
    <div class="outbound-kpi-card tone-orange">
        <div class="outbound-kpi-card__icon-box">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path d="M12 3v12m-4-4 4 4 4-4"/>
            </svg>
        </div>
        <div class="outbound-kpi-card__info">
            <div class="outbound-kpi-card__val" id="stat-picking-pack">0</div>
            <div class="outbound-kpi-card__lbl">Đang pick/pack</div>
        </div>
    </div>
    
    <!-- Packed -->
    <div class="outbound-kpi-card tone-purple">
        <div class="outbound-kpi-card__icon-box">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/>
                <polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/>
            </svg>
        </div>
        <div class="outbound-kpi-card__info">
            <div class="outbound-kpi-card__val" id="stat-packed">0</div>
            <div class="outbound-kpi-card__lbl">Chờ vận chuyển</div>
        </div>
    </div>

    <!-- Dispatched -->
    <div class="outbound-kpi-card tone-emerald">
        <div class="outbound-kpi-card__icon-box">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <rect x="1" y="3" width="15" height="13"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/>
                <circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/>
            </svg>
        </div>
        <div class="outbound-kpi-card__info">
            <div class="outbound-kpi-card__val" id="stat-dispatched">0</div>
            <div class="outbound-kpi-card__lbl">Đã xuất hôm nay</div>
        </div>
    </div>
</div>

<!-- ══ DYNAMIC ALERTS BANNER ══════════════════════════════════ -->
<!-- Auto-created Fulfillment alert -->
<div id="fulfillment-alert-banner" class="outbound-alert-banner success" style="display:none;">
    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
    </svg>
    <p>
        <span id="fulfillment-alert-count">0 lệnh xuất mới</span> vừa được Sales duyệt và đẩy xuống tự động. Nhấn <strong>"Tạo phiếu xuất"</strong> để xử lý ngay.
    </p>
</div>

<!-- Pending pick alert -->
<div id="pending-pick-alert-banner" class="outbound-alert-banner warning" style="display:none;">
    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
    </svg>
    <p>
        Có <span id="pending-pick-alert-count">0</span> phiếu xuất đang chờ được xử lý. Vui lòng phân công ngay.
    </p>
</div>

<!-- ══ TOOLBAR ════════════════════════════════════════════════ -->
<div class="toolbar">
    <div class="search-wrap">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
        </svg>
        <input type="text" id="outboundSearch" placeholder="Tìm mã phiếu xuất, mã SO..." oninput="window.handleSearch()"/>
    </div>
    
    <button id="btn-open-draft-creator" onclick="window.openDraftModal()" class="btn-action-primary">
        <svg style="width: 14px; height: 14px;" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
        </svg>
        Tạo phiếu xuất
    </button>
    
    <button onclick="window.openDisposalModal()" class="btn-action-red">
        <svg style="width: 14px; height: 14px;" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
        </svg>
        Tạo Phiếu Xuất Hủy
    </button>
    
    <button class="btn-action-secondary">
        <svg style="width: 14px; height: 14px;" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <rect x="3" y="4" width="18" height="16" rx="2"/><path d="M7 8h10M7 12h10M7 16h6"/>
        </svg>
        Quét mã
    </button>
</div>

<!-- ══ STATUS FILTER TABS ═════════════════════════════════════ -->
<div class="status-tabs-wrap" id="statusTabsContainer">
    <!-- Rendered dynamically -->
</div>

<!-- ══ OUTBOUND RECEIPTS LIST ═════════════════════════════════ -->
<div class="outbound-list" id="outboundOrdersContainer">
    <!-- Rendered dynamically -->
</div>


<!-- ══════════════════════════════════════════════════════════
     MODALS SECTION
     ══════════════════════════════════════════════════════════ -->

<!-- 1. Confirmation Dispatch Modal -->
<div class="overlay-backdrop" id="confirmDispatchOverlay">
    <div class="modal-shell modal-size-sm">
        <div class="modal-body-section" style="text-align:center; padding: 24px 24px 16px 24px;">
            <input type="hidden" id="confirm-dispatch-order-id"/>
            <div style="width: 56px; height: 56px; background: rgba(235,131,23,0.1); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px auto;">
                <svg style="width: 24px; height: 24px; color: var(--orange);" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <rect x="1" y="3" width="15" height="13"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/>
                </svg>
            </div>
            <h2 class="modal-hdr-title" style="font-size: 16px; font-weight:800; margin-bottom:4px;">Xác nhận xuất kho</h2>
            <p class="modal-hdr-desc" style="font-size:13px; margin-bottom:2px;"><strong id="confirm-do-id">DO-2026-XXXX</strong> · <span id="confirm-so-id">SO-XXXX</span></p>
            <p class="modal-hdr-desc" style="font-size:13px; margin-bottom:16px;">Khách: <strong id="confirm-customer-id" style="color:var(--navy);">Khách hàng</strong></p>
            
            <div style="background: var(--alice); padding: 12px; border-radius: calc(var(--radius-btn) - 2px); text-align: left;">
                <p style="font-size:12px; color:rgba(16, 55, 92, 0.6); line-height: 1.4; margin: 0;">
                    Hành động này sẽ trừ <strong style="color:var(--navy);">qty_on_hand</strong> khỏi kho và cập nhật trạng thái đơn hàng thành "Đang giao".
                </p>
            </div>
        </div>
        <div class="modal-footer-section" style="padding: 16px 24px;">
            <button onclick="window.closeConfirmDispatch()" class="btn-action-secondary" style="flex:1; justify-content:center;">Hủy</button>
            <button onclick="window.submitConfirmDispatch()" class="btn-action-primary" style="flex:1; justify-content:center; background: var(--orange);">Xác nhận xuất kho</button>
        </div>
    </div>
</div>

<!-- 2. Draft Outbound Creator Modal (xl side-by-side select) -->
<div class="overlay-backdrop" id="draftCreatorOverlay">
    <div class="modal-shell modal-size-xl">
        <div class="modal-header-section">
            <div>
                <h2 class="modal-hdr-title">Tạo phiếu xuất nháp</h2>
                <p class="modal-hdr-desc">Chọn một yêu cầu xuất từ Sales để map SKU và lưu ở trạng thái DRAFT.</p>
            </div>
            <button onclick="window.closeDraftModal()" class="btn-modal-close-icon">&times;</button>
        </div>
        <div class="draft-split-view" style="flex:1; min-height:0;">
            <!-- Left pane: fulfillment requests list -->
            <div class="draft-left-pane" id="fulfillmentRequestsContainer">
                <!-- Rendered dynamically -->
            </div>
            <!-- Right pane: selected request details -->
            <div class="draft-right-pane">
                <div id="selectedRequestDetailsBox" style="display:none;" class="space-y-4">
                    <div style="display:flex; align-items:center; justify-content:between; justify-content: space-between; margin-bottom: 16px;">
                        <div>
                            <div class="modal-hdr-title" style="font-size: 15px;" id="selected-req-id">FR-2026-XXXX</div>
                            <div class="modal-hdr-desc">Map sang phiếu xuất nháp và lưu `mappedOrderId` để truy vết.</div>
                        </div>
                        <span style="background: rgba(235,131,23,0.1); color: var(--orange); font-size:11px; font-weight:700; padding:4px 10px; border-radius:20px;">
                            Sẽ lưu DRAFT
                        </span>
                    </div>

                    <div class="outbound-form-group">
                        <label class="outbound-form-label">Ghi chú</label>
                        <textarea id="draft-memo" rows="3" class="outbound-form-textarea" placeholder="Ghi chú cho phiếu xuất nháp"></textarea>
                    </div>

                    <!-- Items table preview -->
                    <div style="border:1px solid var(--border); border-radius: var(--radius-card); overflow:hidden; margin-bottom: 16px;">
                        <div style="background: rgba(240,244,250,0.4); padding: 10px 16px; font-size: 13px; font-weight:600; color:var(--navy); border-bottom:1px solid var(--border);">
                            SKU sẽ được map tự động
                        </div>
                        <table class="outbound-table">
                            <thead>
                                <tr style="background:#fff; border-bottom:1px solid var(--border);">
                                    <th style="text-align: left; font-size:10px;">SKU</th>
                                    <th style="text-align: left; font-size:10px;">Tên sản phẩm</th>
                                    <th style="text-align: right; font-size:10px;">SL</th>
                                </tr>
                            </thead>
                            <tbody id="draftPreviewItemsTableBody">
                                <!-- Dynamic rows -->
                            </tbody>
                        </table>
                    </div>

                    <!-- Meta info summary -->
                    <div style="background: var(--alice); padding:16px; border-radius: var(--radius-btn);">
                        <div style="display:grid; grid-template-columns: 1fr 1fr; gap:16px;">
                            <div>
                                <div class="outbound-form-label" style="font-size: 9px; color:rgba(16, 55, 92, 0.4);">Issue Document ID</div>
                                <div style="font-family: monospace; font-weight:700; font-size:13px;" class="text-navy">Sẽ sinh khi lưu</div>
                            </div>
                            <div>
                                <div class="outbound-form-label" style="font-size: 9px; color:rgba(16, 55, 92, 0.4);">Mapped Order ID</div>
                                <div style="font-family: monospace; font-weight:700; font-size:13px;" class="text-navy" id="selected-mapped-order-id">SO-XXXX</div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div id="noSelectedRequestBox" style="height: 100%; display:flex; align-items:center; justify-content:center; color:rgba(16, 55, 92, 0.4); font-size: 13px;">
                    Không còn request nào để tạo phiếu xuất nháp.
                </div>
            </div>
        </div>
        <div class="modal-footer-section">
            <button onclick="window.closeDraftModal()" class="btn-action-secondary">Hủy</button>
            <button id="btn-submit-draft-do" onclick="window.submitDraftDO()" class="btn-action-primary">Lưu nháp</button>
        </div>
    </div>
</div>

<!-- 3. Disposal Note Creator Modal -->
<div class="overlay-backdrop" id="disposalModalOverlay">
    <div class="modal-shell modal-size-md">
        <div class="modal-header-section">
            <div>
                <h2 class="modal-hdr-title">➕ Tạo Phiếu Xuất Hủy</h2>
                <p class="modal-hdr-desc">Lập phiếu tiêu hủy sản phẩm bị hỏng trong quá trình lưu trữ.</p>
            </div>
            <button onclick="window.closeDisposalModal()" class="btn-modal-close-icon">&times;</button>
        </div>
        <div class="modal-body-section" style="display:flex; flex-direction:column; gap:14px; max-height:60vh;">
            <!-- Select SKU -->
            <div class="outbound-form-group">
                <label class="outbound-form-label">Mã sản phẩm (SKU) *</label>
                <select id="disposal-sku" class="outbound-form-input" style="font-weight:600; cursor:pointer;" onchange="window.handleDisposalSkuSelect(this.value)">
                    <option value="" disabled selected>-- Chọn sản phẩm hỏng --</option>
                    <!-- Populated dynamically from SKUs -->
                </select>
            </div>
            
            <div style="display:grid; grid-template-columns: 1.2fr 0.8fr; gap:16px;">
                <!-- Pick Area -->
                <div class="outbound-form-group" style="margin-bottom:0;">
                    <label class="outbound-form-label">Khu vực lấy hàng *</label>
                    <input type="text" value="Zone Hàng Hỏng" disabled class="outbound-form-input" style="font-weight:700; background:rgba(16, 55, 92, 0.05); color:var(--navy);"/>
                </div>
                
                <!-- Qty -->
                <div class="outbound-form-group" style="margin-bottom:0;">
                    <label class="outbound-form-label">Số lượng tiêu hủy *</label>
                    <input type="number" id="disposal-qty" min="1" value="1" class="outbound-form-input" style="font-weight:700; text-align:right;"/>
                </div>
            </div>

            <!-- Reason -->
            <div class="outbound-form-group">
                <label class="outbound-form-label">Lý do tiêu hủy *</label>
                <input type="text" id="disposal-reason" placeholder="Ví dụ: Sản phẩm bị ngấm nước, trầy xước nặng..." class="outbound-form-input" style="font-weight: 600;"/>
            </div>

            <!-- Evidence Picture Upload -->
            <div class="outbound-form-group">
                <label class="outbound-form-label">Bằng chứng hình ảnh *</label>
                <div class="scrap-upload-box" id="scrapUploadBox">
                    <!-- Dynamic state based on file -->
                </div>
            </div>
        </div>
        <div class="modal-footer-section">
            <button onclick="window.closeDisposalModal()" class="btn-action-secondary">Hủy</button>
            <button id="btn-submit-disposal" onclick="window.submitDisposalNote()" class="btn-action-red" style="padding:10px 20px;">Trình quản lý duyệt</button>
        </div>
    </div>
</div>

<!-- 4. Print-Ready Goods Issue Note Modal (VAT Template) -->
<div class="overlay-backdrop" id="receiptDetailOverlay">
    <div class="modal-shell modal-size-xl">
        <div class="modal-header-section" style="background: rgba(240, 244, 250, 0.3);">
            <h3 class="modal-hdr-title" style="font-size: 16px;">Chi tiết Phiếu Xuất Kho</h3>
            <div style="display:flex; align-items:center; gap:8px;">
                <button onclick="window.printPDF()" class="btn-action-secondary" style="padding: 6px 12px; font-size:12px;">
                    <svg style="width: 14px; height: 14px; margin-right: 4px; vertical-align:middle;" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/>
                    </svg>In PDF
                </button>
                <button class="btn-action-secondary" style="padding: 6px 12px; font-size:12px;">
                    <svg style="width: 14px; height: 14px; margin-right: 4px; vertical-align:middle;" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
                    </svg>Xuất Excel
                </button>
                <button onclick="window.closeReceiptDetail()" class="btn-modal-close-icon" style="margin-left: 8px;">&times;</button>
            </div>
        </div>
        <div class="modal-body-section" style="padding: 40px; background:#fff;">
            <div class="print-receipt-container" id="receiptPrintArea">
                <!-- Header details -->
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:16px; margin-bottom: 24px;">
                    <div>
                        <div style="font-size: 11px; font-weight:500;">
                            Đơn vị: <strong style="font-size: 12px;">Hệ thống Bán hàng Đa kênh ABC</strong>
                        </div>
                        <div style="font-size: 11px; color:rgba(16,55,92,0.6); margin-top:2px;">
                            Bộ phận: Kho Trung Tâm
                        </div>
                    </div>
                    <div style="text-align: right; font-size: 10px; color:rgba(16,55,92,0.6);">
                        <div>Mẫu số 02-VT</div>
                        <div style="margin-top:2px;">(Ban hành theo Thông tư số 200/2014/TT-BTC)</div>
                    </div>
                </div>

                <!-- Central Title -->
                <div style="text-align: center; margin-bottom: 24px;">
                    <h1 style="font-size: 20px; font-weight:900; margin:0; letter-spacing: -0.01em;">PHIẾU XUẤT KHO</h1>
                    <div style="font-size:13px; color:rgba(16,55,92,0.6); font-weight:500; margin-top:2px;">GOODS ISSUE NOTE</div>
                    <div style="font-size: 12px; color:rgba(16,55,92,0.6); margin-top:8px;">
                        Ngày <span id="print-date-day" style="border-bottom: 1px dashed rgba(16,55,92,0.3); padding:0 8px;">28</span> 
                        tháng <span id="print-date-month" style="border-bottom: 1px dashed rgba(16,55,92,0.3); padding:0 8px;">05</span> 
                        năm <span id="print-date-year" style="border-bottom: 1px dashed rgba(16,55,92,0.3); padding:0 8px;">2026</span>
                    </div>
                </div>

                <!-- Ledger Accounts info -->
                <div style="display:grid; grid-template-columns: repeat(3, 1fr); gap:20px; margin-bottom: 24px;">
                    <div>
                        <div class="outbound-form-label" style="font-size: 10px; color:rgba(16,55,92,0.5);">Số Phiếu (No.)</div>
                        <div style="display:flex; align-items:center; gap:12px; margin-top:4px;">
                            <span style="font-size: 16px; font-weight:800;" id="print-receipt-id">DO-2026-XXXX</span>
                            <div style="border: 1px solid var(--border); padding: 4px 8px; background:rgba(16,55,92,0.02); border-radius: 2px;">
                                <div style="height: 24px; width:80px; font-family:monospace; font-size:9px; display:flex; align-items:center; justify-content:center; color:rgba(16,55,92,0.4); border: 1px solid rgba(16,55,92,0.1);">
                                    ||||||||||||||
                                </div>
                            </div>
                        </div>
                    </div>
                    <div>
                        <div class="outbound-form-label" style="font-size: 10px; color:rgba(16,55,92,0.5);">Nợ (Debit)</div>
                        <div style="border-bottom: 2px dashed rgba(16,55,92,0.2); padding-bottom:4px; margin-top:6px;">
                            <strong style="font-size:12px;">TK 632</strong>
                        </div>
                    </div>
                    <div>
                        <div class="outbound-form-label" style="font-size: 10px; color:rgba(16,55,92,0.5);">Có (Credit)</div>
                        <div style="border-bottom: 2px dashed rgba(16,55,92,0.2); padding-bottom:4px; margin-top:6px;">
                            <strong style="font-size:12px;">TK 156</strong>
                        </div>
                    </div>
                </div>

                <!-- Background profile info -->
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:16px 24px; margin-bottom: 24px;">
                    <div>
                        <div class="outbound-form-label" style="font-size:10px; color:rgba(16,55,92,0.5);">Họ Tên Người Nhận Hàng</div>
                        <div style="border-bottom:1px solid rgba(16,55,92,0.2); padding-bottom:2px; margin-top:4px;">
                            <span style="font-size:13px; font-weight:600;" id="print-customer">Khách hàng</span>
                        </div>
                    </div>
                    <div>
                        <div class="outbound-form-label" style="font-size:10px; color:rgba(16,55,92,0.5);">Địa Chỉ / Đơn Vị Người Nhận</div>
                        <div style="border-bottom:1px solid rgba(16,55,92,0.2); padding-bottom:2px; margin-top:4px;">
                            <span style="font-size:12px; color:var(--navy);" class="truncate block" id="print-address">Địa chỉ giao hàng</span>
                        </div>
                    </div>
                    <div>
                        <div class="outbound-form-label" style="font-size:10px; color:rgba(16,55,92,0.5);">Lý Do Xuất Kho</div>
                        <div style="border-bottom:1px solid rgba(16,55,92,0.2); padding-bottom:2px; margin-top:4px;">
                            <span style="font-size:13px; font-weight:500;" id="print-reason">Xuất bán hàng theo đơn hàng SO-XXXX</span>
                        </div>
                    </div>
                    <div>
                        <div class="outbound-form-label" style="font-size:10px; color:rgba(16,55,92,0.5);">Xuất Tại Kho</div>
                        <div style="border-bottom:1px solid rgba(16,55,92,0.2); padding-bottom:2px; margin-top:4px;">
                            <span style="font-size:13px;" id="print-warehouse">Kho HCM - Quận 1 → Khu Hàng Thường</span>
                        </div>
                    </div>
                </div>

                <!-- Print line items table -->
                <table class="print-table">
                    <thead>
                        <tr>
                            <th style="width:40px; text-align:center;">STT</th>
                            <th style="text-align:left;">Tên/Quy Cách Vật Tư</th>
                            <th style="width:120px; text-align:left;">Mã Số (SKU)</th>
                            <th style="width:50px; text-align:center;">ĐVT</th>
                            <th style="width:130px; text-align:center;">Số Lô / HSD</th>
                            <th style="width:80px; text-align:center;">SL Yêu Cầu</th>
                            <th style="width:80px; text-align:center; background:rgba(16,55,92,0.03);">SL Thực Xuất</th>
                            <th style="width:90px; text-align:right;">Đơn Giá</th>
                            <th style="width:110px; text-align:right;">Thành Tiền</th>
                        </tr>
                    </thead>
                    <tbody id="printTableItemsBody">
                        <!-- Dynamic items -->
                    </tbody>
                </table>

                <!-- Verbal Currency Statement -->
                <div style="margin-top: 16px; border:1px solid rgba(16,55,92,0.2); padding:10px 16px; border-radius: 4px;">
                    <span style="font-size:11px; font-weight:700; text-transform:uppercase; color:rgba(16,55,92,0.5);">Tổng Số Tiền (Viết bằng chữ): </span>
                    <strong style="font-size:13px; margin-left:4px;" id="print-amount-words">Không đồng chẵn</strong>
                </div>

                <!-- Signatures -->
                <div class="print-sign-grid">
                    <div>
                        <div class="print-sign-title">Người Lập Phiếu</div>
                        <div style="border-bottom: 1px dashed rgba(16,55,92,0.2); margin-bottom: 8px; height: 35px;"></div>
                        <div class="print-sign-desc">(Ký, họ tên)</div>
                    </div>
                    <div>
                        <div class="print-sign-title">Người Nhận Hàng</div>
                        <div style="border-bottom: 1px dashed rgba(16,55,92,0.2); margin-bottom: 8px; height: 35px;"></div>
                        <div class="print-sign-desc">(Ký, họ tên)</div>
                    </div>
                    <div>
                        <div class="print-sign-title">Thủ Kho</div>
                        <div style="border-bottom: 1px dashed rgba(16,55,92,0.2); margin-bottom: 8px; height: 35px;"></div>
                        <div class="print-sign-desc">(Ký, họ tên)</div>
                    </div>
                    <div>
                        <div class="print-sign-title">Kế Toán Trưởng</div>
                        <div style="border-bottom: 1px dashed rgba(16,55,92,0.2); margin-bottom: 8px; height: 35px;"></div>
                        <div class="print-sign-desc">(Ký, họ tên)</div>
                    </div>
                    <div>
                        <div class="print-sign-title">Giám Đốc</div>
                        <div style="border-bottom: 1px dashed rgba(16,55,92,0.2); margin-bottom: 8px; height: 35px;"></div>
                        <div class="print-sign-desc">(Ký, họ tên)</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════════════════════════
     DYNAMIC JAVASCRIPT STATE CONTROLLER
     ══════════════════════════════════════════════════════════ -->
<script>
(function() {
    // Shared WMS logged-in user profile
    window.WMS_USER = {
        fullName: '${loggedInUser != null ? loggedInUser.fullName : "Nhân viên kho"}'
    };

    // Constant keys for state syncing
    var DO_STORAGE_KEY = "wh_outbound_dos";
    var FULFILLMENT_STORAGE_KEY = "wh_fulfillment_requests";
    var SKUS_STORAGE_KEY = "wms_skus";
    var LEDGER_STORAGE_KEY = "wh_inventory_ledger";
    var PRICING_WAREHOUSE_KEY = "wh_pricing_warehouse";
    var PRICING_SALES_KEY = "wh_pricing_sales";

    // Products list loaded dynamically from local storage / database
    var AVAILABLE_SKUS = [];
    var savedSkus = localStorage.getItem(SKUS_STORAGE_KEY);
    if (savedSkus) {
        try {
            var parsedSkus = JSON.parse(savedSkus);
            AVAILABLE_SKUS = parsedSkus.map(function(s) {
                return { sku: s.skuCode || s.sku, name: s.productName || s.name };
            });
        } catch(e) {
            console.error(e);
        }
    }

    // Seed mock data for first bootstrap
    var mockFulfillmentRequests = [];
    var mockPickOrders = [];

    // Status Tab mapping configuration
    var STATUS_CONFIG = {
        draft: { label: "Bản nháp", iconName: "ClipboardList", bg: "rgba(16, 55, 92, 0.08)", text: "rgba(16, 55, 92, 0.6)", dot: "rgba(16, 55, 92, 0.3)", color: "#64748b" },
        pending_bm: { label: "Chờ duyệt", iconName: "Lock", bg: "#fef3c7", text: "#b45309", dot: "#f59e0b", color: "#d97706" },
        pending_pick: { label: "Chờ chuẩn bị hàng", iconName: "Clock", bg: "#eff6ff", text: "#1d4ed8", dot: "#3b82f6", color: "#2563eb" },
        picking: { label: "Đang pick", iconName: "ArrowUpFromLine", bg: "rgba(245, 200, 66, 0.15)", text: "#d97706", dot: "#f5c842", color: "#eb8317" },
        packed: { label: "Đã đóng gói", iconName: "Package", bg: "#f3e8ff", text: "#7e22ce", dot: "#a855f7", color: "#9333ea" },
        dispatched: { label: "Đã xuất kho", iconName: "Truck", bg: "#ecfdf5", text: "#047857", dot: "#10b981", color: "#059669" }
    };

    var STATUS_TABS = [
        { id: "all", label: "Tất cả" },
        { id: "draft", label: "Bản nháp" },
        { id: "pending_bm", label: "Chờ duyệt" },
        { id: "pending_pick", label: "Chờ chuẩn bị hàng" },
        { id: "picking", label: "Đang pick" },
        { id: "packed", label: "Đã đóng gói" },
        { id: "dispatched", label: "Đã xuất kho" }
    ];

    // Local controller states
    var pickOrders = [];
    var fulfillmentRequests = [];
    var activeTab = "all";
    var searchStr = "";
    var expandedOrderId = null;
    
    // Draft creator state
    var selectedRequestId = null;

    // Disposal Creator state
    var selectedDisposalSku = "";
    var disposalEvidence = "";

    // Bootstrap data initialization
    function initLocalStorageData() {
        var hasMockData = localStorage.getItem(DO_STORAGE_KEY) && 
                          localStorage.getItem(DO_STORAGE_KEY).indexOf("DO-2026-0892") > -1;
                          
        if (!localStorage.getItem(DO_STORAGE_KEY) || hasMockData) {
            localStorage.setItem(DO_STORAGE_KEY, JSON.stringify([]));
        }
        if (!localStorage.getItem(FULFILLMENT_STORAGE_KEY) || hasMockData) {
            localStorage.setItem(FULFILLMENT_STORAGE_KEY, JSON.stringify([]));
        }
        
        pickOrders = JSON.parse(localStorage.getItem(DO_STORAGE_KEY));
        fulfillmentRequests = JSON.parse(localStorage.getItem(FULFILLMENT_STORAGE_KEY));
    }

    initLocalStorageData();

    // Render counts and update UI statistics
    function renderStatistics() {
        var counts = {
            draft: 0, pending_bm: 0, pending_pick: 0, picking: 0, packed: 0, dispatched: 0
        };
        pickOrders.forEach(function(o) {
            if (counts[o.status] !== undefined) {
                counts[o.status]++;
            }
        });

        document.getElementById('stat-pending-pick').textContent = counts.pending_pick;
        document.getElementById('stat-picking-pack').textContent = counts.picking;
        document.getElementById('stat-packed').textContent = counts.packed;
        document.getElementById('stat-dispatched').textContent = counts.dispatched;

        // Alerts banners visibility (mutually exclusive)
        var newAlert = document.getElementById('fulfillment-alert-banner');
        var pickAlert = document.getElementById('pending-pick-alert-banner');
        if (fulfillmentRequests.length > 0) {
            newAlert.style.display = 'flex';
            document.getElementById('fulfillment-alert-count').textContent = fulfillmentRequests.length + " lệnh xuất mới";
            pickAlert.style.display = 'none';
        } else {
            newAlert.style.display = 'none';
            if (counts.pending_pick > 0) {
                pickAlert.style.display = 'flex';
                document.getElementById('pending-pick-alert-count').textContent = counts.pending_pick;
            } else {
                pickAlert.style.display = 'none';
            }
        }

        // Render Tabs bar counts
        var tabsContainer = document.getElementById('statusTabsContainer');
        var tabsHtml = STATUS_TABS.map(function(tab) {
            var countVal = tab.id === 'all' ? pickOrders.length : (counts[tab.id] || 0);
            var activeClass = activeTab === tab.id ? 'active' : '';
            return '<button class="status-tab-btn ' + activeClass + '" onclick="window.handleSelectTab(\'' + tab.id + '\')">' +
                tab.label +
                '<span class="status-tab-badge">' + countVal + '</span>' +
            '</button>';
        }).join('');
        tabsContainer.innerHTML = tabsHtml;
    }

    // Main orders list render
    function renderOrders() {
        var container = document.getElementById('outboundOrdersContainer');
        
        var filtered = pickOrders.filter(function(o) {
            var matchTab = activeTab === 'all' || o.status === activeTab;
            var matchSearch = o.id.toLowerCase().indexOf(searchStr.toLowerCase()) > -1 ||
                              o.soRef.toLowerCase().indexOf(searchStr.toLowerCase()) > -1;
            return matchTab && matchSearch;
        });

        if (filtered.length === 0) {
            container.innerHTML = '<div style="background:#fff; border: 1px solid var(--border); padding: 48px; text-align:center; color:rgba(16,55,92,0.4); font-size:13px; border-radius:var(--radius-card);">' +
                'Không tìm thấy phiếu xuất kho phù hợp.' +
            '</div>';
            return;
        }

        var html = filtered.map(function(order) {
            var sc = STATUS_CONFIG[order.status] || STATUS_CONFIG.draft;
            var isExpanded = expandedOrderId === order.id;
            var totalQty = 0;
            var pickedQty = 0;
            order.items.forEach(function(i) {
                totalQty += i.qty;
                if (i.picked) pickedQty += i.qty;
            });

            // Action button state machine
            var actionBtnHtml = '';
            if (order.status === 'pending_pick') {
                actionBtnHtml = '<button class="btn-workflow-step blue" onclick="window.handleStartPicking(\'' + order.id + '\', event)">Bắt đầu Pick</button>';
            } else if (order.status === 'picking') {
                actionBtnHtml = '<button class="btn-workflow-step purple" onclick="window.handleConfirmPacking(\'' + order.id + '\', event)">Xác nhận đóng gói</button>';
            } else if (order.status === 'packed') {
                actionBtnHtml = '<button class="btn-workflow-step orange" onclick="window.openConfirmDispatch(\'' + order.id + '\', event)">Xuất kho</button>';
            } else if (order.status === 'draft') {
                actionBtnHtml = '<button class="btn-workflow-step amber" onclick="window.handleSubmitForBM(\'' + order.id + '\', event)">Trình duyệt BM</button>';
            } else if (order.status === 'pending_bm') {
                actionBtnHtml = '<span class="label-checker-status">Chờ duyệt</span>';
            }

            // Document details viewer icon
            var detailBtnHtml = '';
            if (order.status === 'dispatched') {
                detailBtnHtml = '<button class="btn-view-doc" title="Xem chi tiết" onclick="window.openReceiptDetail(\'' + order.id + '\', event)">' +
                    '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">' +
                        '<circle cx="12" cy="12" r="3"/><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>' +
                    '</svg>' +
                '</button>';
            }

            // Collapsible items rows
            var itemsRows = order.items.map(function(item) {
                var locationHtml = '';
                if (item.location === "—" || !item.location) {
                    locationHtml = '<span style="color:rgba(16, 55, 92, 0.3);">—</span>';
                } else {
                    var parts = item.location.split('→');
                    var leftPart = parts[0] ? parts[0].trim() : '';
                    var rightPart = parts[1] ? parts[1].trim() : item.location;
                    locationHtml = '<div class="sku-loc-badges">' +
                        '<span class="sku-loc-left">' + leftPart + '</span>' +
                        '<span class="sku-loc-divider">→</span>' +
                        '<span class="sku-loc-right">' + rightPart + '</span>' +
                    '</div>';
                }

                var checkedIcon = item.picked ? 
                    '<svg style="width:18px; height:18px; color:#10b981; margin:0 auto;" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>' :
                    '<div style="width:16px; height:16px; border:2px solid rgba(16, 55, 92, 0.2); border-radius:3px; margin:0 auto;"></div>';

                return '<tr>' +
                    '<td>' +
                        '<div style="display:flex; align-items:center; gap:8px;">' +
                            '<svg style="width:14px; height:14px; color:rgba(16, 55, 92, 0.3);" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" /></svg>' +
                            '<span style="font-family:monospace; color:rgba(16, 55, 92, 0.6); font-size:10px;">' + item.skuCode + '</span>' +
                        '</div>' +
                    '</td>' +
                    '<td><span style="font-weight:600; color:var(--navy);">' + item.skuName + '</span></td>' +
                    '<td style="text-align:center;">' + locationHtml + '</td>' +
                    '<td style="text-align:right; font-weight:800; font-size:13px; color:var(--navy);">' + item.qty + '</td>' +
                    '<td style="text-align:center;">' + checkedIcon + '</td>' +
                '</tr>';
            }).join('');

            // Render tags/badges on order ID row
            var badgesHtml = '';
            if (order.isDisposal) {
                badgesHtml += '<span class="outbound-extra-badge disposal">🗑️ Phiếu Xuất Hủy</span> ';
            }
            
            badgesHtml += '<span class="pill-badge ' + order.status + '">' +
                '<span class="pill-badge__dot"></span>' +
                sc.label +
            '</span>';
            
            if (order.status === 'draft' && !order.isDisposal) {
                badgesHtml += ' <span class="outbound-extra-badge draft-unapproved">📋 Chưa duyệt</span>';
            }
            if (order.isDisposal && order.status === 'draft' && order.disposalRejectReason) {
                badgesHtml += ' <span class="outbound-extra-badge rejected">⚠️ Bị từ chối</span>';
            }

            var assignedHtml = order.assignedTo ? 
                '<span>Phụ trách: <strong style="color:rgba(16, 55, 92, 0.7);">' + order.assignedTo + '</strong></span>' : '';

            var disposalDetails = '';
            if (order.isDisposal) {
                disposalDetails = '<span>Lý do hỏng: <strong class="outbound-disposal-reason">' + (order.disposalReason || '') + ' (' + (order.disposalZone || '') + ')</strong></span>';
            }

            var rejectionAlert = '';
            if (order.isDisposal && order.status === 'draft' && order.disposalRejectReason) {
                rejectionAlert = '<div class="outbound-reject-reason-box">' +
                    '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">' +
                        '<path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />' +
                    '</svg>' +
                    '<div><strong>Quản lý từ chối duyệt:</strong> "' + order.disposalRejectReason + '" (Nhân viên vui lòng kiểm tra lại)</div>' +
                '</div>';
            }

            return '<div class="outbound-item ' + (isExpanded ? 'expanded' : '') + '">' +
                '<!-- Header -->' +
                '<div class="outbound-hdr" onclick="window.handleToggleExpand(\'' + order.id + '\')">' +
                    '<div class="outbound-channel-badge" style="background:' + (order.channelColor || '#64748b') + '">' +
                        order.channel.slice(0, 2).toUpperCase() +
                    '</div>' +
                    '<div class="outbound-hdr__info">' +
                        '<div class="outbound-meta-row">' +
                            '<span class="outbound-id">' + order.id + '</span>' +
                            '<span class="outbound-ref">← ' + (order.mappedOrderId || order.soRef) + '</span>' +
                            badgesHtml +
                        '</div>' +
                        '<div class="outbound-courier-row">' +
                            '<span class="outbound-courier-cell">' +
                                '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" /></svg>' +
                                order.courier +
                            '</span>' +
                            assignedHtml +
                            disposalDetails +
                        '</div>' +
                        rejectionAlert +
                    '</div>' +
                    '<div class="outbound-actions-row">' +
                        detailBtnHtml +
                        '<div class="outbound-stat">' +
                            '<div class="outbound-stat__lbl">Pick</div>' +
                            '<div class="outbound-stat__val">' +
                                '<span style="' + (pickedQty === totalQty ? 'color:#10b981;' : '') + '">' + pickedQty + '</span>' +
                                '<span style="font-size:11px; color:rgba(16, 55, 92, 0.3);">/' + totalQty + '</span>' +
                            '</div>' +
                        '</div>' +
                        actionBtnHtml +
                        '<svg class="chevron-arrow" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">' +
                            '<polyline points="6 9 12 15 18 9"/>' +
                        '</svg>' +
                    '</div>' +
                '</div>' +

                '<!-- Expanded body -->' +
                '<div class="outbound-body">' +
                    '<div class="outbound-address-bar">' +
                        '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" /><path stroke-linecap="round" stroke-linejoin="round" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />' +
                        '</svg>' +
                        '<span>' + order.address + '</span>' +
                    '</div>' +
                    '<table class="outbound-table">' +
                        '<thead>' +
                            '<tr>' +
                                '<th style="text-align: left;">SKU</th>' +
                                '<th style="text-align: left;">Tên sản phẩm</th>' +
                                '<th style="text-align: center;">Vị trí kho</th>' +
                                '<th style="text-align: right;">SL cần pick</th>' +
                                '<th style="text-align: center;">Đã pick</th>' +
                            '</tr>' +
                        '</thead>' +
                        '<tbody>' +
                            itemsRows +
                        '</tbody>' +
                    '</table>' +
                '</div>' +
            '</div>';
        }).join('');

        container.innerHTML = html;
    }

    function saveState() {
        localStorage.setItem(DO_STORAGE_KEY, JSON.stringify(pickOrders));
        localStorage.setItem(FULFILLMENT_STORAGE_KEY, JSON.stringify(fulfillmentRequests));
        renderStatistics();
        renderOrders();
    }

    // Toggle list collapse state
    window.handleToggleExpand = function(orderId) {
        if (expandedOrderId === orderId) {
            expandedOrderId = null;
        } else {
            expandedOrderId = orderId;
        }
        renderOrders();
    };

    // Toolbar search triggers
    window.handleSearch = function() {
        searchStr = document.getElementById('outboundSearch').value.trim();
        renderOrders();
    };

    // Filter tabs click
    window.handleSelectTab = function(tabId) {
        activeTab = tabId;
        renderOrders();
        renderStatistics();
    };

    // Transition: Pending Pick -> Picking
    window.handleStartPicking = function(orderId, event) {
        if (event) event.stopPropagation();
        var index = pickOrders.findIndex(function(o) { return o.id === orderId; });
        if (index > -1) {
            pickOrders[index].status = 'picking';
            pickOrders[index].assignedTo = window.WMS_USER.fullName || 'Nhân viên kho';
            saveState();
        }
    };

    // Transition: Picking -> Packed
    window.handleConfirmPacking = function(orderId, event) {
        if (event) event.stopPropagation();
        var index = pickOrders.findIndex(function(o) { return o.id === orderId; });
        if (index > -1) {
            pickOrders[index].status = 'packed';
            
            // Mark all items as picked
            pickOrders[index].items.forEach(function(item) {
                item.picked = true;
            });
            saveState();
        }
    };

    // Transition: Draft -> Pending BM
    window.handleSubmitForBM = function(orderId, event) {
        if (event) event.stopPropagation();
        var index = pickOrders.findIndex(function(o) { return o.id === orderId; });
        if (index > -1) {
            pickOrders[index].status = 'pending_bm';
            saveState();
            alert('Đã gửi phiếu xuất ' + orderId + ' lên Business Manager phê duyệt!');
        }
    };

    // ─── STOCKS VALIDATION RULES ───
    function validateStockAvailability(items) {
        var errors = [];
        var currentSKUs = JSON.parse(localStorage.getItem(SKUS_STORAGE_KEY) || '[]');
        
        items.forEach(function(item) {
            // Find SKU quantity from local storage wms_skus
            var found = currentSKUs.find(function(s) { return s.sku === item.skuCode; });
            var qtyAvailable = found ? (found.qtyOnHand || 0) : 0;
            
            if (qtyAvailable < item.qty) {
                errors.push(item.skuName + ': Tồn kho không đủ (cần ' + item.qty + ', có ' + qtyAvailable + ')');
            }
        });

        return {
            valid: errors.length === 0,
            errors: errors
        };
    }

    // ─── OUTBOUND LEAVE LEDGER WRITERS ───
    function logOutboundInventoryLedger(sku, quantity, referenceId, customerName) {
        var ledgerStr = localStorage.getItem(LEDGER_STORAGE_KEY);
        var ledger = ledgerStr ? JSON.parse(ledgerStr) : [];
        
        var entry = {
            id: 'LEG-' + Date.now() + '-' + Math.random().toString(36).substring(2, 9),
            sku: sku,
            type: 'outbound',
            quantity: -quantity, // Negative for dispatch
            warehouseId: 'WH001',
            zone: '',
            location: '',
            referenceId: referenceId,
            referenceType: 'DO',
            notes: 'Xuất cho khách hàng: ' + customerName,
            createdAt: new Date().toISOString(),
            createdBy: window.WMS_USER.fullName || 'Nhân viên kho'
        };
        
        ledger.push(entry);
        localStorage.setItem(LEDGER_STORAGE_KEY, JSON.stringify(ledger));
    }

    function decrementMasterSkuQty(skuCode, qty) {
        var currentSKUs = JSON.parse(localStorage.getItem(SKUS_STORAGE_KEY) || '[]');
        var index = currentSKUs.findIndex(function(s) { return s.sku === skuCode; });
        if (index > -1) {
            currentSKUs[index].qtyOnHand = Math.max(0, (currentSKUs[index].qtyOnHand || 0) - qty);
            currentSKUs[index].lastUpdated = new Date().toISOString().slice(0, 16).replace("T", " ");
            currentSKUs[index].updatedBy = window.WMS_USER.fullName || 'Nhân viên kho';
            localStorage.setItem(SKUS_STORAGE_KEY, JSON.stringify(currentSKUs));
        }
    }

    function decrementPricingQty(skuCode, qty) {
        [PRICING_WAREHOUSE_KEY, PRICING_SALES_KEY].forEach(function(key) {
            var stored = localStorage.getItem(key);
            if (stored) {
                var records = JSON.parse(stored);
                var updated = records.map(function(r) {
                    if (r.sku === skuCode) {
                        var nextQty = Math.max(0, (r.qtyOnHand || 0) - qty);
                        var importPriceVal = r.importPrice || 0;
                        return Object.assign({}, r, {
                            qtyOnHand: nextQty,
                            costOfGoodsSold: nextQty * importPriceVal
                        });
                    }
                    return r;
                });
                localStorage.setItem(key, JSON.stringify(updated));
            }
        });
    }

    // ─── CONFIRM DISPATCH MODAL ───
    var confirmOverlay = document.getElementById('confirmDispatchOverlay');

    window.openConfirmDispatch = function(orderId, event) {
        if (event) event.stopPropagation();
        var order = pickOrders.find(function(o) { return o.id === orderId; });
        if (!order) return;

        document.getElementById('confirm-dispatch-order-id').value = order.id;
        document.getElementById('confirm-do-id').textContent = order.id;
        document.getElementById('confirm-so-id').textContent = order.mappedOrderId || order.soRef;
        document.getElementById('confirm-customer-id').textContent = order.customer;

        confirmOverlay.classList.add('active');
    };

    window.closeConfirmDispatch = function() {
        confirmOverlay.classList.remove('active');
    };

    window.submitConfirmDispatch = function() {
        var orderId = document.getElementById('confirm-dispatch-order-id').value;
        var order = pickOrders.find(function(o) { return o.id === orderId; });
        if (!order) return;

        // Perform stock availability verification
        var validation = validateStockAvailability(order.items);
        if (!validation.valid) {
            alert('❌ Không thể xuất kho do thiếu hụt tồn vật lý:\n\n' + validation.errors.join('\n'));
            confirmOverlay.classList.remove('active');
            return;
        }

        // Apply dynamic stock updates and ledger entries
        order.items.forEach(function(item) {
            // 1. Ledger Entry
            logOutboundInventoryLedger(item.skuCode, item.qty, order.id, order.customer);
            
            // 2. Decrement from physical wms_skus stock
            decrementMasterSkuQty(item.skuCode, item.qty);
            
            // 3. Decrement asset balances from wh_pricing
            decrementPricingQty(item.skuCode, item.qty);
        });

        // Update DO status to dispatched
        order.status = 'dispatched';
        order.assignedTo = order.assignedTo || window.WMS_USER.fullName || 'Nhân viên kho';

        closeConfirmDispatch();
        saveState();
        alert('🎉 Đã xác nhận xuất kho thành công cho phiếu ' + orderId + '!');
    };

    // ─── DRAFT OUTBOUND DO CREATOR MODAL ───
    var draftOverlay = document.getElementById('draftCreatorOverlay');

    window.openDraftModal = function() {
        // Re-render fulfillment requests panel list
        renderFulfillmentRequestsList();
        
        // Auto select first request if exists
        if (fulfillmentRequests.length > 0) {
            window.handleSelectFulfillmentRequest(fulfillmentRequests[0].requestId);
        } else {
            selectedRequestId = null;
            document.getElementById('selectedRequestDetailsBox').style.display = 'none';
            document.getElementById('noSelectedRequestBox').style.display = 'flex';
            document.getElementById('btn-submit-draft-do').disabled = true;
        }

        document.getElementById('draft-memo').value = '';
        draftOverlay.classList.add('active');
    };

    window.closeDraftModal = function() {
        draftOverlay.classList.remove('active');
    };

    function renderFulfillmentRequestsList() {
        var container = document.getElementById('fulfillmentRequestsContainer');
        var listHeader = '<div class="outbound-form-label" style="margin-bottom:8px;">Yêu cầu xuất hàng pending (' + fulfillmentRequests.length + ')</div>';
        
        if (fulfillmentRequests.length === 0) {
            container.innerHTML = listHeader + '<div style="background:#fff; border:1px solid var(--border); padding: 16px; font-size:12px; color:rgba(16,55,92,0.4); text-align:center; border-radius:var(--radius-card);">Không có yêu cầu xuất hàng nào từ Sales.</div>';
            return;
        }

        var listHtml = fulfillmentRequests.map(function(req) {
            var activeClass = selectedRequestId === req.requestId ? 'active' : '';
            return '<button class="draft-item-select-btn ' + activeClass + '" onclick="window.handleSelectFulfillmentRequest(\'' + req.requestId + '\')">' +
                '<div style="display:flex; align-items:center; justify-content:space-between; justify-content: space-between;">' +
                    '<div>' +
                        '<div style="font-weight:800; color:var(--navy); font-size:13px;">' + req.requestId + '</div>' +
                        '<div style="font-size:11px; color:rgba(16, 55, 92, 0.4); margin-top:2px;">Order: ' + req.orderId + '</div>' +
                    '</div>' +
                    '<span style="background:rgba(16, 55, 92, 0.08); color:rgba(16, 55, 92, 0.6); font-size:10px; font-weight:700; padding:2px 8px; border-radius:20px;">' +
                        req.items.length + ' SKU' +
                    '</span>' +
                '</div>' +
            '</button>';
        }).join('');

        container.innerHTML = listHeader + listHtml;
    }

    window.handleSelectFulfillmentRequest = function(reqId) {
        selectedRequestId = reqId;
        
        // Re-render select state highlights
        renderFulfillmentRequestsList();

        var req = fulfillmentRequests.find(function(r) { return r.requestId === reqId; });
        if (!req) return;

        document.getElementById('noSelectedRequestBox').style.display = 'none';
        document.getElementById('selectedRequestDetailsBox').style.display = 'block';
        document.getElementById('btn-submit-draft-do').disabled = false;

        document.getElementById('selected-req-id').textContent = req.requestId;
        document.getElementById('selected-mapped-order-id').textContent = req.orderId;

        // Render preview lines
        var tbody = document.getElementById('draftPreviewItemsTableBody');
        var previewHtml = req.items.map(function(item) {
            return '<tr>' +
                '<td style="font-family:monospace; font-size:11px; color:rgba(16,55,92,0.7);">' + item.skuCode + '</td>' +
                '<td><span style="font-size:13px; color:var(--navy);">' + item.skuName + '</span></td>' +
                '<td style="text-align:right; font-weight:700; color:var(--navy);">' + item.qty + '</td>' +
            '</tr>';
        }).join('');
        tbody.innerHTML = previewHtml;
    };

    window.submitDraftDO = function() {
        if (!selectedRequestId) return;
        var req = fulfillmentRequests.find(function(r) { return r.requestId === selectedRequestId; });
        if (!req) return;

        // Generate next ID sequence DO-2026-XXXX
        var maxSequence = 0;
        pickOrders.forEach(function(o) {
            var match = o.id.match(/DO-2026-(\d+)/);
            if (match) {
                var seq = parseInt(match[1]);
                if (seq > maxSequence) maxSequence = seq;
            }
        });
        var nextSeq = String(maxSequence + 1).padStart(4, '0');
        var nextDoId = 'DO-2026-' + nextSeq;

        var memoVal = document.getElementById('draft-memo').value.trim();
        var now = new Date();
        var createdAtStr = now.getFullYear() + '-' + 
                           padZero(now.getMonth()+1) + '-' + 
                           padZero(now.getDate()) + ' ' + 
                           padZero(now.getHours()) + ':' + 
                           padZero(now.getMinutes());

        // Create draft PickOrder
        var newDraftDO = {
            id: nextDoId,
            issueDocumentId: nextDoId,
            mappedOrderId: req.orderId,
            soRef: req.orderId,
            channel: "Sales",
            channelColor: "#64748b",
            customer: "Đơn nháp từ Sales",
            address: "Chưa xác định",
            status: "draft",
            courier: "Chưa xác định",
            createdAt: createdAtStr,
            note: memoVal || undefined,
            items: req.items.map(function(item) {
                return {
                    skuCode: item.skuCode,
                    skuName: item.skuName,
                    qty: item.qty,
                    location: "—",
                    picked: false
                };
            })
        };

        // Prepend to list
        pickOrders.unshift(newDraftDO);

        // Remove from pending fulfillment requests
        fulfillmentRequests = fulfillmentRequests.filter(function(r) {
            return r.requestId !== selectedRequestId;
        });

        closeDraftModal();
        saveState();
        alert('Tạo phiếu xuất nháp ' + nextDoId + ' thành công!');
    };

    // ─── DISPOSAL note CREATOR MODAL ───
    var disposalOverlay = document.getElementById('disposalModalOverlay');

    window.openDisposalModal = function() {
        // Read skus options from localStorage
        var currentSKUs = JSON.parse(localStorage.getItem(SKUS_STORAGE_KEY) || '[]');
        var skuSelect = document.getElementById('disposal-sku');
        
        var selectOptions = currentSKUs.map(function(s) {
            return '<option value="' + s.sku + '">' + s.name + ' (' + s.sku + ')</option>';
        }).join('');
        skuSelect.innerHTML = '<option value="" disabled selected>-- Chọn sản phẩm hỏng --</option>' + selectOptions;

        selectedDisposalSku = "";
        disposalEvidence = "";
        
        document.getElementById('disposal-qty').value = "1";
        document.getElementById('disposal-reason').value = "";
        
        renderEvidenceUploadBox();
        disposalOverlay.classList.add('active');
    };

    window.closeDisposalModal = function() {
        disposalOverlay.classList.remove('active');
    };

    window.handleDisposalSkuSelect = function(sku) {
        selectedDisposalSku = sku;
    };

    function renderEvidenceUploadBox() {
        var box = document.getElementById('scrapUploadBox');
        if (disposalEvidence) {
            box.innerHTML = '<div style="width:100%; display:flex; flex-direction:column; gap:8px;">' +
                '<div class="scrap-evidence-preview">' +
                    '<img src="' + disposalEvidence + '" alt="Bằng chứng hỏng"/>' +
                    '<button class="btn-remove-evidence" onclick="window.removeDisposalEvidence(event)">&times;</button>' +
                '</div>' +
                '<div style="font-size:11px; color:rgba(16,55,92,0.6); display:flex; align-items:center; justify-content:space-between;">' +
                    '<span>📷 IMG_4892_SCRAP.JPG</span>' +
                    '<span style="font-family:monospace;">1.2 MB</span>' +
                '</div>' +
            '</div>';
        } else {
            box.innerHTML = '<div class="scrap-upload-icon">📷</div>' +
                '<div>' +
                    '<div style="font-size:12px; font-weight:800; color:var(--navy);">Chưa có ảnh bằng chứng thực tế</div>' +
                    '<div style="font-size:10px; color:rgba(16,55,92,0.4); margin-top:2px;">Bắt buộc để chống gian lận tiêu hủy</div>' +
                '</div>' +
                '<button onclick="window.triggerMockUpload(event)" class="btn-action-primary" style="padding:6px 12px; font-size:11px;">' +
                    'Tải ảnh bằng chứng hỏng' +
                '</button>';
        }
    }

    window.triggerMockUpload = function(event) {
        if (event) event.preventDefault();
        // Set mock evidence URL from Unsplash
        disposalEvidence = "https://images.unsplash.com/photo-1588580000645-4562a6d2c839?auto=format&fit=crop&w=400&q=80";
        renderEvidenceUploadBox();
    };

    window.removeDisposalEvidence = function(event) {
        if (event) event.stopPropagation();
        disposalEvidence = "";
        renderEvidenceUploadBox();
    };

    window.submitDisposalNote = function() {
        if (!selectedDisposalSku) {
            alert('Vui lòng chọn sản phẩm cần xuất hủy!');
            return;
        }
        var qty = parseInt(document.getElementById('disposal-qty').value) || 0;
        if (qty <= 0) {
            alert('Số lượng tiêu hủy phải lớn hơn 0!');
            return;
        }
        var reason = document.getElementById('disposal-reason').value.trim();
        if (!reason) {
            alert('Vui lòng nhập lý do tiêu hủy!');
            return;
        }
        if (!disposalEvidence) {
            alert('Vui lòng tải lên ảnh bằng chứng thực tế!');
            return;
        }

        // Generate ID: DISP-2026-XXXX
        var maxSequence = 0;
        pickOrders.forEach(function(o) {
            if (o.id.indexOf('DISP-') === 0) {
                var match = o.id.match(/DISP-2026-(\d+)/);
                if (match) {
                    var seq = parseInt(match[1]);
                    if (seq > maxSequence) maxSequence = seq;
                }
            }
        });
        var nextSeq = String(maxSequence + 1).padStart(4, '0');
        var disposalId = 'DISP-2026-' + nextSeq;

        var currentSKUs = JSON.parse(localStorage.getItem(SKUS_STORAGE_KEY) || '[]');
        var matched = currentSKUs.find(function(s) { return s.sku === selectedDisposalSku; });
        var skuName = matched ? matched.name : 'Sản phẩm tiêu hủy';

        var now = new Date();
        var createdAtStr = now.getFullYear() + '-' + 
                           padZero(now.getMonth()+1) + '-' + 
                           padZero(now.getDate()) + ' ' + 
                           padZero(now.getHours()) + ':' + 
                           padZero(now.getMinutes());

        // Create disposal DO targetting pending_bm status
        var createdDisposalDO = {
            id: disposalId,
            issueDocumentId: disposalId,
            soRef: "Lệnh xuất hủy",
            channel: "Disposal",
            channelColor: "#ef4444",
            customer: "Xuất hủy hàng hỏng",
            address: "Khu vực tiêu hủy vật lý",
            status: "pending_bm", // Requires Checker Approval
            createdAt: createdAtStr,
            courier: "Nhân viên kho",
            note: "Lý do tiêu hủy: " + reason,
            isDisposal: true,
            disposalReason: reason,
            disposalZone: "Zone Hàng Hỏng",
            disposalEvidence: disposalEvidence,
            items: [
                {
                    skuCode: selectedDisposalSku,
                    skuName: skuName,
                    qty: qty,
                    location: "Kho HCM - Quận 1 → Zone Hàng Hỏng",
                    picked: true
                }
            ]
        };

        pickOrders.unshift(createdDisposalDO);
        closeDisposalModal();
        saveState();
        alert('🎉 Đã tạo thành công phiếu xuất hủy ' + disposalId + ' và trình duyệt lên Business Manager!');
    };

    // ─── PRINT-READY Goods Issue Note Modal ───
    var receiptDetailOverlay = document.getElementById('receiptDetailOverlay');
    var activePrintNote = null;

    window.openReceiptDetail = function(orderId, event) {
        if (event) event.stopPropagation();
        var order = pickOrders.find(function(o) { return o.id === orderId; });
        if (!order) return;

        activePrintNote = order;

        // Parse date details
        var dateVal = order.createdAt || '';
        var day = '28', month = '05', year = '2026';
        if (dateVal) {
            var splitted = dateVal.split(' ')[0];
            if (splitted.indexOf('/') > -1) {
                var pts = splitted.split('/');
                if (pts.length === 3) { day = pts[0]; month = pts[1]; year = pts[2]; }
            } else if (splitted.indexOf('-') > -1) {
                var pts = splitted.split('-');
                if (pts.length === 3) { year = pts[0]; month = pts[1]; day = pts[2]; }
            }
        }

        document.getElementById('print-date-day').textContent = day;
        document.getElementById('print-date-month').textContent = month;
        document.getElementById('print-date-year').textContent = year;
        
        document.getElementById('print-receipt-id').textContent = order.id;
        document.getElementById('print-customer').textContent = order.customer;
        document.getElementById('print-address').textContent = order.address;
        document.getElementById('print-reason').textContent = order.note || ('Xuất bán hàng theo đơn hàng ' + (order.mappedOrderId || order.soRef));
        document.getElementById('print-warehouse').textContent = order.items[0]?.location || 'Kho HCM - Quận 1 → Khu Hàng Thường';

        // Render table rows and sum amounts
        var totalAmount = 0;
        var totalQty = 0;

        var itemsHtml = order.items.map(function(item, idx) {
            totalQty += item.qty;
            // Get price from wh_pricing_warehouse dynamic storage or fallback
            var unitPrice = 15000;
            var pricingList = JSON.parse(localStorage.getItem(PRICING_WAREHOUSE_KEY) || '[]');
            var matchedPrice = pricingList.find(function(p) { return p.sku === item.skuCode; });
            if (matchedPrice && matchedPrice.importPrice) {
                unitPrice = matchedPrice.importPrice;
            }
            var subtotal = item.qty * unitPrice;
            totalAmount += subtotal;

            var lotCode = 'LOT-2026-' + String(idx + 1).padStart(2, '0');

            return '<tr>' +
                '<td style="text-align:center;">' + (idx + 1) + '</td>' +
                '<td><strong>' + item.skuName + '</strong></td>' +
                '<td><span style="font-family:monospace;">' + item.skuCode + '</span></td>' +
                '<td style="text-align:center;">Cái</td>' +
                '<td style="text-align:center;"><div style="font-family:monospace; font-size:10px;">' + lotCode + '</div><div style="font-size:9px; color:rgba(16,55,92,0.4)">HSD: 31/12/2028</div></td>' +
                '<td style="text-align:center; color:rgba(16,55,92,0.5);">' + item.qty + '</td>' +
                '<td style="text-align:center; font-weight:800; background:rgba(16,55,92,0.03);">' + item.qty + '</td>' +
                '<td style="text-align:right;">' + unitPrice.toLocaleString('vi-VN') + '</td>' +
                '<td style="text-align:right; font-weight:600;">' + subtotal.toLocaleString('vi-VN') + '</td>' +
            '</tr>';
        }).join('');

        // Sum row append
        itemsHtml += '<tr style="background:rgba(240,244,250,0.4); font-weight:bold; border-top:2px solid rgba(16,55,92,0.3);">' +
            '<td colspan="5" style="text-align:right;">CỘNG:</td>' +
            '<td style="text-align:center; color:rgba(16,55,92,0.5);">' + totalQty + '</td>' +
            '<td style="text-align:center; background:rgba(16,55,92,0.03); font-size:14px; font-weight:900;">' + totalQty + '</td>' +
            '<td></td>' +
            '<td style="text-align:right; font-size:13px;">' + totalAmount.toLocaleString('vi-VN') + '</td>' +
        '</tr>';

        document.getElementById('printTableItemsBody').innerHTML = itemsHtml;
        document.getElementById('print-amount-words').textContent = numberToVietnameseWords(totalAmount);

        receiptDetailOverlay.classList.add('active');
    };

    window.closeReceiptDetail = function() {
        receiptDetailOverlay.classList.remove('active');
    };

    window.printPDF = function() {
        var printContents = document.getElementById('receiptPrintArea').innerHTML;
        var originalContents = document.body.innerHTML;
        
        // Open print window safely
        var printWin = window.open('', '_blank');
        printWin.document.write('<html><head><title>Phiếu Xuất Kho - ' + (activePrintNote ? activePrintNote.id : '') + '</title>');
        printWin.document.write('<link rel="stylesheet" href="' + window.location.origin + '${pageContext.request.contextPath}/assets/css/dashboard.css" type="text/css" />');
        printWin.document.write('<style>body { padding:40px; background:#fff; color:#10375c; } .print-table { width:100%; border-collapse:collapse; border:2px solid rgba(16,55,92,0.2); margin-top:16px; } .print-table th { background:#f4f7f6; border:1px solid rgba(16,55,92,0.2); padding:10px 8px; font-size:10px; font-weight:700; text-transform:uppercase; } .print-table td { border:1px solid rgba(16,55,92,0.2); padding:8px 10px; font-size:12px; } .print-sign-grid { display:grid; grid-template-columns:repeat(5, 1fr); gap:12px; text-align:center; margin-top:32px; } .print-sign-title { font-size:10px; font-weight:700; text-transform:uppercase; } .print-sign-desc { font-size:10px; font-style:italic; color:rgba(16,55,92,0.4); }</style>');
        printWin.document.write('</head><body>');
        printWin.document.write(printContents);
        printWin.document.write('</body></html>');
        printWin.document.close();
        printWin.print();
    };

    // ─── HELPERS ───
    function padZero(n) { return n < 10 ? '0' + n : n; }

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

    // Dismiss overlays when clicking backdrop
    [confirmOverlay, draftOverlay, disposalOverlay, receiptDetailOverlay].forEach(function(ov) {
        if (ov) {
            ov.addEventListener('click', function(e) {
                if (e.target === ov) {
                    ov.classList.remove('active');
                }
            });
        }
    });

    // Bootstrapped execution
    renderStatistics();
    renderOrders();
})();
</script>
