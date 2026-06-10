<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- ══════════════════════════════════════════════════════════════════
     Sales Staff — Quản Lý Sản Phẩm Theo Kênh & Cấu Hình Giá Bán
     JSP port of React: ChannelProducts.tsx & PricingConfiguration.tsx
     All logic is pure vanilla JS — no hardcoded data, no seed data.
     ══════════════════════════════════════════════════════════════════ --%>

<style>
/* ── Sub-tab navigation styling ────────── */
.cp-tab-bar {
    display: flex;
    align-items: center;
    border-bottom: 1px solid #E5EAF3;
    margin-bottom: 1.25rem;
    gap: 0.25rem;
}
.cp-tab-btn {
    padding: 0.625rem 1rem;
    font-size: 13px;
    font-weight: 700;
    color: rgba(16, 55, 92, 0.4);
    background: none;
    border: none;
    border-bottom: 2px solid transparent;
    cursor: pointer;
    transition: all 0.2s ease;
}
.cp-tab-btn:hover {
    color: rgba(16, 55, 92, 0.7);
}
.cp-tab-btn.active {
    color: var(--navy);
    border-bottom-color: var(--navy);
}

/* ── Tab 1: Stats Panel ────────── */
.cp-stats-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 1rem;
    margin-bottom: 1.5rem;
}
@media (max-width: 1024px) {
    .cp-stats-grid { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 640px) {
    .cp-stats-grid { grid-template-columns: 1fr; }
}
.cp-stat-card {
    background: #fff;
    border: 1px solid #E5EAF3;
    padding: 1.25rem;
    border-radius: var(--radius-card);
    transition: all 0.2s ease;
}
.cp-stat-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 25px rgba(16, 55, 92, 0.05);
}
.cp-stat-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 0.75rem;
}
.cp-stat-icon {
    width: 40px;
    height: 40px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: var(--radius-btn);
}
.cp-stat-icon.blue { background: rgba(16, 55, 92, 0.1); color: var(--navy); }
.cp-stat-icon.emerald { background: rgba(16, 185, 129, 0.1); color: #059669; }
.cp-stat-icon.red { background: rgba(239, 68, 68, 0.08); color: #ef4444; }
.cp-stat-icon.orange { background: rgba(235, 131, 23, 0.1); color: #eb8317; }
.cp-stat-icon svg { width: 20px; height: 20px; }

.cp-stat-label { font-size: 12px; color: rgba(16, 55, 92, 0.6); }
.cp-stat-val { font-size: 24px; font-weight: 800; color: var(--navy); margin-top: 0.25rem; }

/* ── Filter Toolbar ────────── */
.cp-filter-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 1rem;
    flex-wrap: wrap;
    gap: 1rem;
}
.cp-filter-left {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    flex-wrap: wrap;
}
.cp-select-wrapper {
    position: relative;
    display: inline-block;
}
.cp-select {
    padding: 0.5rem 2rem 0.5rem 1rem;
    background: #fff;
    border: 1px solid #E5EAF3;
    font-size: 13px;
    font-weight: 600;
    color: var(--navy);
    border-radius: calc(var(--radius-btn) - 2px);
    appearance: none;
    cursor: pointer;
    outline: none;
    min-width: 140px;
}
.cp-select-arrow {
    position: absolute;
    right: 0.75rem;
    top: 50%;
    transform: translateY(-50%);
    width: 16px;
    height: 16px;
    color: rgba(16, 55, 92, 0.4);
    pointer-events: none;
}
.cp-search {
    position: relative;
    width: 320px;
}
@media (max-width: 640px) {
    .cp-search { width: 100%; }
}
.cp-search-icon {
    position: absolute;
    left: 0.75rem;
    top: 50%;
    transform: translateY(-50%);
    width: 16px;
    height: 16px;
    color: rgba(16, 55, 92, 0.3);
    pointer-events: none;
}
.cp-search-input {
    width: 100%;
    padding: 0.5rem 1rem 0.5rem 2.25rem;
    background: #fff;
    border: 1px solid #E5EAF3;
    font-size: 13px;
    color: var(--navy);
    border-radius: calc(var(--radius-btn) - 2px);
    outline: none;
}
.cp-search-input::placeholder { color: rgba(16, 55, 92, 0.3); }

.cp-btn-push {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    background: var(--navy);
    color: #fff;
    font-size: 13px;
    font-weight: 700;
    border: none;
    border-radius: calc(var(--radius-btn) - 2px);
    cursor: pointer;
    transition: background 0.15s;
}
.cp-btn-push:hover { background: rgba(16, 55, 92, 0.9); }
.cp-btn-push svg { width: 15px; height: 15px; }

/* ── General Data Tables ────────── */
.cp-table-card {
    background: #fff;
    border: 1px solid #E5EAF3;
    border-radius: var(--radius-card);
    overflow: hidden;
}
.cp-table-scroll { overflow-x: auto; }
.cp-table { width: 100%; border-collapse: collapse; text-align: left; }
.cp-table th {
    background: var(--alice);
    color: rgba(16, 55, 92, 0.5);
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .05em;
    padding: 0.75rem 1rem;
    border-bottom: 1px solid #E5EAF3;
    white-space: nowrap;
}
.cp-table td {
    padding: 0.75rem 1rem;
    border-bottom: 1px solid #F0F3FA;
    font-size: 13px;
    color: var(--navy);
    vertical-align: middle;
}
.cp-table tr:hover { background: rgba(240, 245, 255, 0.3); }

/* Table utility styles */
.cp-font-mono { font-family: monospace; font-weight: 500; font-size: 12px; }
.cp-p-desc { font-size: 11px; color: rgba(16, 55, 92, 0.6); max-width: 440px; margin-top: 2px; }
.cp-p-id { font-size: 10px; color: rgba(16, 55, 92, 0.4); font-family: monospace; margin-top: 1px; }

.cp-badge-channel {
    color: #fff;
    border-radius: 4px;
    font-weight: 700;
    font-size: 11px;
    padding: 0.25rem 0.5rem;
    display: inline-block;
}
.cp-input-buffer {
    width: 64px;
    padding: 0.25rem 0.5rem;
    text-align: center;
    border: 1px solid #E5EAF3;
    border-radius: 4px;
    font-weight: 600;
    color: var(--navy);
    outline: none;
}
.cp-input-buffer:focus { border-color: rgba(16, 55, 92, 0.3); }

/* Table Badges */
.cp-sync-status {
    display: inline-flex;
    align-items: center;
    padding: 0.125rem 0.5rem;
    border-radius: 4px;
    font-size: 11px;
    font-weight: 700;
}
.cp-sync-status.success { color: #059669; background: #ecfdf5; }
.cp-sync-status.syncing { color: #d97706; background: #fffbeb; }
.cp-sync-status.failed { color: #ef4444; background: #fef2f2; cursor: pointer; }

.cp-status-pill {
    display: inline-flex;
    align-items: center;
    padding: 0.125rem 0.5rem;
    border-radius: 4px;
    font-size: 11px;
    font-weight: 700;
}
.cp-status-pill.active { color: #059669; background: rgba(5, 150, 105, 0.08); }
.cp-status-pill.out_of_stock { color: #ef4444; background: rgba(239, 68, 68, 0.08); }
.cp-status-pill.inactive { color: #64748b; background: rgba(100, 116, 139, 0.08); }

.cp-btn-edit {
    width: 32px;
    height: 32px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    color: rgba(16, 55, 92, 0.5);
    background: none;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    transition: all 0.15s;
}
.cp-btn-edit:hover {
    color: var(--navy);
    background: var(--alice);
}
.cp-btn-edit svg { width: 16px; height: 16px; }

/* ── Tab 2: Pricing configuration styling ────────── */
.pr-role-header {
    background: #fff;
    border: 1px solid #E5EAF3;
    padding: 1.25rem;
    border-radius: var(--radius-card);
    margin-bottom: 1.25rem;
}
.pr-role-tag {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.25rem 0.625rem;
    margin-bottom: 0.75rem;
    border: 1px solid rgba(235, 131, 23, 0.2);
    background: rgba(235, 131, 23, 0.06);
    color: #eb8317;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.02em;
    border-radius: 4px;
}
.pr-role-tag svg { width: 14px; height: 14px; }
.pr-role-title { font-size: 20px; font-weight: 800; color: var(--navy); }
.pr-role-subtitle { font-size: 13px; color: rgba(16, 55, 92, 0.6); margin-top: 0.25rem; }

.pr-channel-panel {
    background: #fff;
    border: 1px solid #E5EAF3;
    padding: 1rem;
    border-radius: var(--radius-card);
    margin-bottom: 1rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 1rem;
}
.pr-channel-pills { display: flex; flex-wrap: wrap; gap: 0.5rem; }
.pr-channel-pill {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 0.75rem;
    font-size: 13px;
    font-weight: 700;
    border: 1px solid #E5EAF3;
    background: #fff;
    color: rgba(16, 55, 92, 0.7);
    cursor: pointer;
    border-radius: calc(var(--radius-btn) - 2px);
    transition: all 0.15s;
}
.pr-channel-pill:hover { border-color: rgba(16, 55, 92, 0.2); color: var(--navy); }
.pr-channel-pill.active {
    background: var(--navy);
    color: #fff;
    border-color: var(--navy);
}
.pr-dot { width: 10px; height: 10px; border-radius: 50%; display: inline-block; }

.pr-active-indicator {
    padding: 0.5rem 0.75rem;
    background: var(--alice);
    border: 1px solid #E5EAF3;
    border-radius: calc(var(--radius-btn) - 2px);
}
.pr-active-ind-label { font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.4); }
.pr-active-ind-val { font-size: 13px; font-weight: 700; color: var(--navy); margin-top: 1px; }

.pr-price-input {
    width: 120px;
    padding: 0.5rem 0.75rem;
    border: 1px solid #E5EAF3;
    text-align: right;
    font-size: 13px;
    font-weight: 600;
    color: var(--navy);
    outline: none;
    border-radius: 4px;
}
.pr-price-input:focus { border-color: rgba(16, 55, 92, 0.3); }
.pr-price-input:disabled { background: var(--alice); color: rgba(16, 55, 92, 0.4); cursor: not-allowed; }

.pr-save-btn {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 0.75rem;
    background: var(--navy);
    color: #fff;
    border: none;
    font-size: 12px;
    font-weight: 700;
    cursor: pointer;
    border-radius: calc(var(--radius-btn) - 4px);
    transition: background 0.15s;
}
.pr-save-btn:hover { background: rgba(16, 55, 92, 0.9); }
.pr-save-btn:disabled { background: #f1f5f9; color: #94a3b8; cursor: not-allowed; border: 1px solid #E5EAF3; }
.pr-save-btn svg { width: 14px; height: 14px; }

.pr-footer-actions {
    margin-top: 1.25rem;
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 1rem;
}
.pr-save-status { font-size: 12px; color: rgba(16, 55, 92, 0.45); font-style: italic; }

.pr-btn-save-all {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.75rem 1.5rem;
    background: var(--navy);
    color: #fff;
    border: none;
    font-size: 13px;
    font-weight: 700;
    cursor: pointer;
    border-radius: calc(var(--radius-btn) - 2px);
    transition: background 0.15s;
}
.pr-btn-save-all:hover { background: rgba(16, 55, 92, 0.9); }
.pr-btn-save-all svg { width: 16px; height: 16px; }

/* ── Modals & Overlays ────────── */
.cp-modal-overlay {
    position: fixed;
    inset: 0;
    background: rgba(16, 55, 92, 0.4);
    backdrop-filter: blur(4px);
    z-index: 100;
    display: none;
    align-items: center;
    justify-content: center;
    padding: 1.5rem;
}
.cp-modal-overlay.open { display: flex; }

.cp-modal {
    width: 100%;
    max-width: 768px;
    background: #fff;
    border-radius: var(--radius-card);
    box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 8px 10px -6px rgba(0,0,0,0.1);
    overflow: hidden;
    display: flex;
    flex-direction: column;
    max-height: 85vh;
}
.cp-modal-header {
    padding: 1rem 1.5rem;
    border-bottom: 1px solid #F0F3FA;
    background: rgba(240, 245, 255, 0.3);
    display: flex;
    align-items: center;
    justify-content: space-between;
}
.cp-modal-title {
    font-size: 15px;
    font-weight: 900;
    color: var(--navy);
    text-transform: uppercase;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}
.cp-modal-title svg { width: 18px; height: 18px; }
.cp-modal-close {
    background: none;
    border: none;
    color: rgba(16, 55, 92, 0.4);
    cursor: pointer;
    width: 32px;
    height: 32px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.15s;
}
.cp-modal-close:hover { background: var(--alice); color: var(--navy); }
.cp-modal-close svg { width: 18px; height: 18px; }

.cp-modal-body { padding: 1.5rem; overflow-y: auto; flex: 1; }
.cp-modal-footer {
    padding: 1rem 1.5rem;
    border-top: 1px solid #F0F3FA;
    background: rgba(240, 245, 255, 0.3);
    display: flex;
    align-items: center;
    justify-content: space-between;
}

/* Form Styles */
.cp-form-group { margin-bottom: 1.25rem; }
.cp-form-label { display: block; font-size: 12px; font-weight: 600; color: rgba(16, 55, 92, 0.7); margin-bottom: 0.375rem; }
.cp-input-text {
    width: 100%;
    padding: 0.625rem 0.75rem;
    border: 1px solid #E5EAF3;
    font-size: 13px;
    color: var(--navy);
    outline: none;
    border-radius: calc(var(--radius-btn) - 2px);
}
.cp-input-text:focus { border-color: rgba(16, 55, 92, 0.3); }

/* Uploader Styles */
.cp-upload-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 0.75rem; margin-top: 0.5rem; }
.cp-upload-box {
    aspect-ratio: 1/1;
    border-radius: 6px;
    border: 1px solid #E5EAF3;
    background: var(--alice);
    overflow: hidden;
    position: relative;
}
.cp-upload-box img { width: 100%; height: 100%; object-fit: cover; }
.cp-upload-box-trash {
    position: absolute;
    inset: 0;
    background: rgba(16, 55, 92, 0.4);
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    transition: opacity 0.15s;
    cursor: pointer;
}
.cp-upload-box:hover .cp-upload-box-trash { opacity: 1; }
.cp-upload-box-trash svg { width: 16px; height: 16px; color: #fff; }
.cp-upload-box-label {
    position: absolute;
    bottom: 4px;
    left: 4px;
    background: var(--navy);
    color: #fff;
    font-size: 9px;
    font-weight: 800;
    padding: 2px 4px;
    border-radius: 3px;
}

.cp-upload-btn-card {
    aspect-ratio: 1/1;
    border-radius: 6px;
    border: 2px dashed rgba(16, 55, 92, 0.15);
    background: rgba(240, 245, 255, 0.2);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.15s;
    text-align: center;
    padding: 0.25rem;
}
.cp-upload-btn-card:hover {
    background: rgba(240, 245, 255, 0.5);
    border-color: rgba(16, 55, 92, 0.3);
}
.cp-upload-btn-card svg { width: 20px; height: 20px; color: rgba(16, 55, 92, 0.4); margin-bottom: 2px; }
.cp-upload-btn-card span.main { font-size: 9.5px; font-weight: 700; color: rgba(16, 55, 92, 0.6); }
.cp-upload-btn-card span.sub { font-size: 8.5px; color: rgba(16, 55, 92, 0.4); margin-top: 1px; }

/* ── Wizard Progress Checklist ────────── */
.cp-wiz-steps {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.375rem;
    max-width: 500px;
    margin: 0 auto 1rem;
}
.cp-wiz-step {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 12px;
    font-weight: 700;
    color: rgba(16, 55, 92, 0.4);
}
.cp-wiz-step.active { color: var(--navy); }
.cp-wiz-step-num {
    width: 20px;
    height: 20px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 10px;
    background: rgba(16, 55, 92, 0.08);
    color: rgba(16, 55, 92, 0.6);
}
.cp-wiz-step.active .cp-wiz-step-num {
    background: var(--navy);
    color: #fff;
}
.cp-wiz-step.done .cp-wiz-step-num {
    background: #10b981;
    color: #fff;
}
.cp-wiz-step-icon { width: 14px; height: 14px; color: rgba(16, 55, 92, 0.2); }

/* Step components */
.cp-wiz-list {
    border: 1px solid #E5EAF3;
    border-radius: var(--radius-btn);
    max-height: 200px;
    overflow-y: auto;
}
.cp-wiz-row {
    padding: 0.75rem;
    border-bottom: 1px solid #F0F3FA;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: justify;
    transition: background 0.15s;
}
.cp-wiz-row:hover { background: rgba(240, 245, 255, 0.3); }
.cp-wiz-row.selected { background: rgba(16, 55, 92, 0.04); color: var(--navy); font-weight: 600; }
.cp-wiz-row-radio {
    width: 18px;
    height: 18px;
    border-radius: 50%;
    border: 1px solid rgba(16, 55, 92, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
}
.cp-wiz-row.selected .cp-wiz-row-radio {
    border-color: var(--navy);
    background: var(--navy);
}
.cp-wiz-row-radio-inner { width: 8px; height: 8px; border-radius: 50%; background: #fff; display: none; }
.cp-wiz-row.selected .cp-wiz-row-radio-inner { display: block; }

.cp-spec-card {
    background: rgba(240, 245, 255, 0.4);
    border: 1px solid rgba(16, 55, 92, 0.08);
    padding: 1rem;
    border-radius: 8px;
    margin-top: 1rem;
}
.cp-spec-title {
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .04em;
    color: rgba(16, 55, 92, 0.55);
    border-bottom: 1px solid #E5EAF3;
    padding-bottom: 0.375rem;
    margin-bottom: 0.75rem;
}
.cp-spec-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1rem; font-size: 13px; }
@media (max-width: 640px) {
    .cp-spec-grid { grid-template-columns: repeat(2, 1fr); }
}
.cp-spec-label { font-size: 10.5px; color: rgba(16, 55, 92, 0.45); }
.cp-spec-val { font-weight: 600; margin-top: 2px; }

/* Platforms selection box */
.cp-platforms-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem; }
@media (max-width: 640px) {
    .cp-platforms-grid { grid-template-columns: 1fr; }
}
.cp-platform-card {
    border: 1px solid #E5EAF3;
    background: #fff;
    padding: 1rem;
    border-radius: var(--radius-card);
    cursor: pointer;
    display: flex;
    flex-direction: column;
    gap: 1rem;
    transition: all 0.15s;
    user-select: none;
}
.cp-platform-card.selected.shopee { border-color: #EE4D2D; background: rgba(238, 77, 45, 0.03); }
.cp-platform-card.selected.lazada { border-color: #0F146D; background: rgba(15, 20, 109, 0.03); }
.cp-platform-card.selected.tiktok { border-color: #69C9D0; background: rgba(105, 201, 208, 0.03); }

.cp-platform-header { display: flex; align-items: center; justify-content: space-between; }
.cp-platform-badge {
    color: #fff;
    font-size: 11px;
    font-weight: 800;
    padding: 0.25rem 0.5rem;
    border-radius: 4px;
}
.cp-platform-chk {
    width: 20px;
    height: 20px;
    border-radius: 50%;
    border: 1px solid rgba(16, 55, 92, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
}
.cp-platform-card.selected.shopee .cp-platform-chk { background: #EE4D2D; border-color: #EE4D2D; }
.cp-platform-card.selected.lazada .cp-platform-chk { background: #0F146D; border-color: #0F146D; }
.cp-platform-card.selected.tiktok .cp-platform-chk { background: #69C9D0; border-color: #69C9D0; }
.cp-platform-chk svg { width: 14px; height: 14px; color: #fff; display: none; }
.cp-platform-card.selected .cp-platform-chk svg { display: block; }
.cp-platform-desc { font-size: 11px; color: rgba(16, 55, 92, 0.4); line-height: 1.4; }

/* Platform Config Box */
.cp-platform-config-box {
    border: 1px solid #E5EAF3;
    border-radius: var(--radius-card);
    overflow: hidden;
    margin-bottom: 1.25rem;
}
.cp-platform-config-box.shopee { border-color: rgba(238, 77, 45, 0.2); }
.cp-platform-config-box.lazada { border-color: rgba(15, 20, 109, 0.2); }
.cp-platform-config-box.tiktok { border-color: rgba(105, 201, 208, 0.2); }

.cp-platform-config-hdr {
    padding: 0.5rem 1rem;
    font-size: 12.5px;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: space-between;
}
.cp-platform-config-hdr.shopee { background: rgba(238, 77, 45, 0.06); color: #EE4D2D; border-bottom: 1px solid rgba(238, 77, 45, 0.1); }
.cp-platform-config-hdr.lazada { background: rgba(15, 20, 109, 0.06); color: #0F146D; border-bottom: 1px solid rgba(15, 20, 109, 0.1); }
.cp-platform-config-hdr.tiktok { background: rgba(105, 201, 208, 0.06); color: #69C9D0; border-bottom: 1px solid rgba(105, 201, 208, 0.1); }

.cp-platform-config-body { padding: 1rem; }

/* ── API Sandbox Loader Overlay ────────── */
.cp-sandbox-overlay {
    position: absolute;
    inset: 0;
    background: rgba(255, 255, 255, 0.96);
    backdrop-filter: blur(8px);
    z-index: 200;
    display: none;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 2rem;
}
.cp-sandbox-overlay.open { display: flex; }

.cp-sandbox-spinner-container { width: 64px; height: 64px; position: relative; margin-bottom: 1.5rem; }
.cp-sandbox-spinner {
    width: 64px; height: 64px;
    border: 5px solid var(--alice);
    border-top: 5px solid var(--navy);
    border-radius: 50%;
    animation: spin 1s linear infinite;
}
.cp-sandbox-spinner-lbl {
    position: absolute;
    inset: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 11px;
    font-weight: 800;
    color: var(--navy);
}

.cp-sandbox-steps-card {
    width: 100%;
    max-width: 440px;
    background: var(--alice);
    border: 1px solid #E5EAF3;
    border-radius: 8px;
    padding: 1.25rem;
    margin-top: 1.5rem;
}
.cp-sandbox-step-row {
    display: flex;
    align-items: start;
    gap: 0.75rem;
    margin-bottom: 1rem;
    opacity: 0.35;
    transition: opacity 0.2s ease;
}
.cp-sandbox-step-row.active { opacity: 1; }
.cp-sandbox-step-row.done { opacity: 1; color: #047857; }
.cp-sandbox-step-row:last-child { margin-bottom: 0; }

.cp-sandbox-step-check {
    width: 16px;
    height: 16px;
    border-radius: 50%;
    border: 2px solid rgba(16, 55, 92, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    margin-top: 2px;
}
.cp-sandbox-step-row.done .cp-sandbox-step-check {
    background: #10b981;
    border-color: #10b981;
}
.cp-sandbox-step-row.active .cp-sandbox-step-check {
    border-color: var(--navy);
}
.cp-sandbox-step-check svg { width: 10px; height: 10px; color: #fff; display: none; }
.cp-sandbox-step-row.done .cp-sandbox-step-check svg { display: block; }
.cp-sandbox-step-check-spinner {
    width: 10px; height: 10px;
    border: 2px solid transparent;
    border-top: 2px solid var(--navy);
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
    display: none;
}
.cp-sandbox-step-row.active .cp-sandbox-step-check-spinner { display: block; }

.cp-sandbox-step-title { font-size: 12px; font-weight: 700; }
.cp-sandbox-step-desc { font-size: 10.5px; color: rgba(16, 55, 92, 0.45); margin-top: 1px; }
.cp-sandbox-step-row.done .cp-sandbox-step-desc { color: rgba(4, 120, 87, 0.7); }

/* General Empty State */
.op-empty {
    text-align: center !important;
    padding: 4rem 2rem !important;
    color: rgba(16, 55, 92, 0.4);
    font-size: 14px;
}
.op-empty svg { width: 44px; height: 44px; margin: 0 auto 0.75rem; color: rgba(16, 55, 92, 0.2); display: block; }
</style>

<%-- ── SUB-TABS NAVIGATION BAR ── --%>
<div class="cp-tab-bar">
    <button class="cp-tab-btn active" id="tabProductsBtn" onclick="switchMainTab('products')">Sản phẩm theo kênh</button>
    <button class="cp-tab-btn" id="tabPricingBtn" onclick="switchMainTab('pricing')">Cấu hình giá bán</button>
    <button class="cp-tab-btn" id="tabChannelsBtn" onclick="switchMainTab('channels')">Quản lý kênh bán</button>
</div>

<%-- ══════════════════════════════════════════════════════════════════
     TAB 1: SẢN PHẨM THEO KÊNH
     ══════════════════════════════════════════════════════════════════ --%>
<div id="tabProductsContent">
    <%-- Stats dashboard counters --%>
    <div class="cp-stats-grid">
        <div class="cp-stat-card">
            <div class="cp-stat-header">
                <div class="cp-stat-icon blue">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg>
                </div>
                <svg style="width:16px;height:16px;color:#059669" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 7 13.5 15.5 8.5 10.5 2 17"></polyline><polyline points="16 7 22 7 22 13"></polyline></svg>
            </div>
            <div class="cp-stat-label">Tổng sản phẩm sàn</div>
            <div class="cp-stat-val" id="statTotalProducts">0</div>
        </div>

        <div class="cp-stat-card">
            <div class="cp-stat-header">
                <div class="cp-stat-icon emerald">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                </div>
            </div>
            <div class="cp-stat-label">Đang bán trên sàn</div>
            <div class="cp-stat-val text-emerald-600" id="statActiveProducts" style="color: #059669">0</div>
        </div>

        <div class="cp-stat-card">
            <div class="cp-stat-header">
                <div class="cp-stat-icon red">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
                </div>
            </div>
            <div class="cp-stat-label">Hết hàng</div>
            <div class="cp-stat-val text-red-500" id="statOOSProducts" style="color:#ef4444">0</div>
        </div>

        <div class="cp-stat-card">
            <div class="cp-stat-header">
                <div class="cp-stat-icon orange">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
                </div>
            </div>
            <div class="cp-stat-label">Giá trị tồn kho sàn</div>
            <div class="cp-stat-val text-orange" id="statInventoryValue" style="color:#eb8317">0M</div>
        </div>
    </div>

    <%-- Filters Toolbar --%>
    <div class="cp-filter-bar">
        <div class="cp-filter-left">
            <div class="cp-select-wrapper">
                <select class="cp-select" id="filterChannelSelect" onchange="onChannelFilterChange(this.value)">
                    <option value="all">Tat ca kenh</option>
                    <c:forEach var="ch" items="${channelsList}">
                        <option value="${ch.channelName}">${ch.channelName}</option>
                    </c:forEach>
                </select>
                <svg class="cp-select-arrow" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7-7" /></svg>
            </div>

            <div class="cp-search">
                <svg class="cp-search-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                <input type="text" class="cp-search-input" placeholder="Tìm theo tên, SKU, SKU kênh..." id="cpSearchInp" oninput="onProductSearch(this.value)" />
            </div>
        </div>

        <button class="cp-btn-push" onclick="openPublishWizard()">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
            Đẩy sản phẩm lên sàn
        </button>
    </div>

    <%-- Data table list --%>
    <div class="cp-table-card">
        <div class="cp-table-scroll">
            <table class="cp-table">
                <thead>
                    <tr>
                        <th style="width: 12%;">Mã SKU</th>
                        <th style="width: 15%;">SKU kênh</th>
                        <th style="width: 32%;">Tên sản phẩm</th>
                        <th style="width: 8%;">Kênh</th>
                        <th style="width: 9%; text-align: right;">Giá sàn</th>
                        <th style="width: 8%; text-align: right;">Tồn vật lý</th>
                        <th style="width: 10%; text-align: center;">Hàng đệm</th>
                        <th style="width: 8%; text-align: right;">Tồn trên sàn</th>
                        <th style="width: 10%;">Đồng bộ</th>
                        <th style="width: 8%;">Trạng thái</th>
                        <th style="width: 5%; text-align: center;">Thao tác</th>
                    </tr>
                </thead>
                <tbody id="cpProductsTableBody">
                    <%-- Populated by JS --%>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════════════
     TAB 2: CẤU HÌNH GIÁ BÁN
     ══════════════════════════════════════════════════════════════════ --%>
<div id="tabPricingContent" style="display:none">
    <div class="pr-role-header">
        <div class="pr-role-tag">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 4 23 10 17 10"></polyline><polyline points="1 20 1 14 7 14"></polyline><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path></svg>
            Configure Pricing
        </div>
        <h2 class="pr-role-title">Cấu Hình Giá Bán</h2>
        <p class="pr-role-subtitle">Sales Staff cập nhật giá bán lẻ và giá khuyến mãi theo từng kênh bán riêng biệt. Mỗi kênh là một mặt bằng giá độc lập.</p>
    </div>

    <%-- Pricing Stats Cards --%>
    <div class="cp-stats-grid" style="grid-template-columns: repeat(3, 1fr); margin-bottom: 1rem">
        <div class="cp-stat-card">
            <div class="cp-stat-header">
                <div class="cp-stat-icon blue" style="background: rgba(16, 185, 129, 0.1); color: #059669;">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                </div>
            </div>
            <div class="cp-stat-label">SKU đang Active</div>
            <div class="cp-stat-val" id="prStatActiveSKUs">0</div>
        </div>

        <div class="cp-stat-card">
            <div class="cp-stat-header">
                <div class="cp-stat-icon blue" style="background: rgba(235, 131, 23, 0.1); color: #eb8317;">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 7 13.5 15.5 8.5 10.5 2 17"></polyline><polyline points="16 7 22 7 22 13"></polyline></svg>
                </div>
            </div>
            <div class="cp-stat-label">Kênh đang quản lý</div>
            <div class="cp-stat-val" id="prStatChannels">4</div>
        </div>

        <div class="cp-stat-card">
            <div class="cp-stat-header">
                <div class="cp-stat-icon blue" style="background: #f1f5f9; color: #64748b;">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
                </div>
            </div>
            <div class="cp-stat-label">SKU không cho sửa (Inactive)</div>
            <div class="cp-stat-val" id="prStatLockSKUs">0</div>
        </div>
    </div>

    <%-- Channel Selector Panel --%>
    <div class="pr-channel-panel">
        <div>
            <div style="font-size: 12px; font-weight: 600; color: rgba(16, 55, 92, 0.7); margin-bottom: 0.5rem">Chọn kênh bán</div>
            <div class="pr-channel-pills">
                <button class="pr-channel-pill active" id="prChannelShopee" onclick="setPricingChannel('shopee')">
                    <span class="pr-dot" style="background: #EE4D2D"></span>
                    Shopee
                </button>
                <button class="pr-channel-pill" id="prChannelTiktok" onclick="setPricingChannel('tiktok')">
                    <span class="pr-dot" style="background: #69C9D0"></span>
                    TikTok
                </button>
                <button class="pr-channel-pill" id="prChannelLazada" onclick="setPricingChannel('lazada')">
                    <span class="pr-dot" style="background: #0F146D"></span>
                    Lazada
                </button>
                <button class="pr-channel-pill" id="prChannelWebsite" onclick="setPricingChannel('website')">
                    <span class="pr-dot" style="background: #EB8317"></span>
                    Website
                </button>
            </div>
        </div>
        <div class="pr-active-indicator">
            <div class="pr-active-ind-label">Đang chỉnh</div>
            <div class="pr-active-ind-val" id="prActiveChannelLabel">Shopee</div>
        </div>
    </div>

    <%-- Pricing Data Table --%>
    <div class="cp-table-card">
        <div class="cp-table-scroll">
            <table class="cp-table">
                <thead>
                    <tr>
                        <th style="width: 15%;">Master SKU</th>
                        <th style="width: 25%;">Sản phẩm</th>
                        <th style="width: 10%; text-align: center;">Trạng thái</th>
                        <th style="width: 10%; text-align: right;">Giá nhập</th>
                        <th style="width: 12%; text-align: right;">Retail Price</th>
                        <th style="width: 12%; text-align: right;">Promo Price</th>
                        <th style="width: 10%; text-align: right;">Biên lợi nhuận</th>
                        <th style="width: 6%; text-align: right;">Hành động</th>
                    </tr>
                </thead>
                <tbody id="prPricingTableBody">
                    <%-- Populated by JS --%>
                </tbody>
            </table>
        </div>
    </div>

    </div>

<%-- ══════════════════════════════════════════════════════════════════
     TAB 3: QUẢN LÝ KÊNH BÁN
     ══════════════════════════════════════════════════════════════════ --%>
<div id="tabChannelsContent" style="display:none">
    <div class="pr-role-header" style="margin-bottom: 1.5rem;">
        <div class="pr-role-tag" style="background: rgba(16, 55, 92, 0.1); color: var(--navy);">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:14px;height:14px;"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect><line x1="8" y1="21" x2="16" y2="21"></line><line x1="12" y1="17" x2="12" y2="21"></line></svg>
            Channel Management
        </div>
        <h2 class="pr-role-title">Quản Lý Kênh Bán Hàng</h2>
        <p class="pr-role-subtitle">Cấu hình số lượng tồn đệm (Buffer Stock) cho từng kênh bán hàng tích hợp để tối ưu chiến lược bán hàng đa kênh.</p>
    </div>

    <!-- Channels List Card Grid -->
    <div id="channelsGrid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(22rem, 1fr)); gap: 1.25rem;">
        <!-- Rendered dynamically by JavaScript -->
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════════════
     MODAL: ĐẨY SẢN PHẨM LÊN SÀN (3-STEP PUBLISHING WIZARD)
     ══════════════════════════════════════════════════════════════════ --%>
<div class="cp-modal-overlay" id="publishWizardOverlay" onclick="closePublishWizard()">
    <div class="cp-modal" onclick="event.stopPropagation()">
        <%-- API Sandbox integration overlay --%>
        <div class="cp-sandbox-overlay" id="sandboxOverlay">
            <div class="cp-sandbox-spinner-container">
                <div class="cp-sandbox-spinner"></div>
                <div class="cp-sandbox-spinner-lbl">API</div>
            </div>

            <h3 style="font-weight: 800; font-size: 18px; color: var(--navy);">Đồng bộ Sandbox đa kênh bán hàng</h3>
            <p style="font-size: 12px; color: rgba(16,55,92,.5); text-align: center; max-width: 400px; margin-top: 0.25rem">
                Đang đẩy sản phẩm <strong id="sandboxProductTitle">-</strong> sang môi trường sandbox của các sàn TMĐT đã chọn...
            </p>

            <div class="cp-sandbox-steps-card">
                <div class="cp-sandbox-step-row" id="sStep1">
                    <div class="cp-sandbox-step-check">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" /></svg>
                        <div class="cp-sandbox-step-check-spinner"></div>
                    </div>
                    <div>
                        <div class="cp-sandbox-step-title">Đóng gói Payload sản phẩm gốc...</div>
                        <div class="cp-sandbox-step-desc">Tổng hợp dữ liệu tên, cân nặng, kích thước từ Master SKU</div>
                    </div>
                </div>

                <div class="cp-sandbox-step-row" id="sStep2">
                    <div class="cp-sandbox-step-check">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" /></svg>
                        <div class="cp-sandbox-step-check-spinner"></div>
                    </div>
                    <div>
                        <div class="cp-sandbox-step-title">Xác thực API Gateway Sandbox...</div>
                        <div class="cp-sandbox-step-desc">Chứng thực tài khoản của Sales Staff trên môi trường thử nghiệm</div>
                    </div>
                </div>

                <div class="cp-sandbox-step-row" id="sStep3">
                    <div class="cp-sandbox-step-check">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" /></svg>
                        <div class="cp-sandbox-step-check-spinner"></div>
                    </div>
                    <div>
                        <div class="cp-sandbox-step-title">Đồng bộ hóa hình ảnh lên máy chủ sàn...</div>
                        <div class="cp-sandbox-step-desc">Truyền tải và tối ưu hóa tài nguyên ảnh mô tả</div>
                    </div>
                </div>

                <div class="cp-sandbox-step-row" id="sStep4">
                    <div class="cp-sandbox-step-check">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" /></svg>
                        <div class="cp-sandbox-step-check-spinner"></div>
                    </div>
                    <div>
                        <div class="cp-sandbox-step-title">Truyền tải cấu hình đặc thù sàn...</div>
                        <div class="cp-sandbox-step-desc">Bắn dữ liệu phân loại danh mục và biểu phí giá sàn vừa cấu hình</div>
                    </div>
                </div>

                <div class="cp-sandbox-step-row" id="sStep5">
                    <div class="cp-sandbox-step-check">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" /></svg>
                        <div class="cp-sandbox-step-check-spinner"></div>
                    </div>
                    <div>
                        <div class="cp-sandbox-step-title">Sandbox API trả về mã thành công (200 OK)...</div>
                        <div class="cp-sandbox-step-desc">Xác thực sàn TMĐT đã duyệt và khởi tạo sản phẩm thành công</div>
                    </div>
                </div>

                <div class="cp-sandbox-step-row" id="sStep6">
                    <div class="cp-sandbox-step-check">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" /></svg>
                        <div class="cp-sandbox-step-check-spinner"></div>
                    </div>
                    <div>
                        <div class="cp-sandbox-step-title">Nhận ID và ghi nhận Ánh xạ Nhiều-Nhiều...</div>
                        <div class="cp-sandbox-step-desc">Tự động ghi nhận ánh xạ SKU và ID của sàn vào cơ sở dữ liệu</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="cp-modal-header">
            <div class="cp-modal-title">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" /></svg>
                Đồng bộ sản phẩm lên kênh bán (Publish to Channel)
            </div>
            <button class="cp-modal-close" onclick="closePublishWizard()">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" /></svg>
            </button>
        </div>

        <div class="cp-modal-body">
            <%-- Steps indicator --%>
            <div class="cp-wiz-steps">
                <div class="cp-wiz-step active" id="wizInd1">
                    <span class="cp-wiz-step-num" id="wizIndNum1">1</span>
                    <span>Chọn SKU gốc</span>
                </div>
                <svg class="cp-wiz-step-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"></polyline></svg>

                <div class="cp-wiz-step" id="wizInd2">
                    <span class="cp-wiz-step-num" id="wizIndNum2">2</span>
                    <span>Chọn Sàn bán</span>
                </div>
                <svg class="cp-wiz-step-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"></polyline></svg>

                <div class="cp-wiz-step" id="wizInd3">
                    <span class="cp-wiz-step-num" id="wizIndNum3">3</span>
                    <span>Cấu hình sàn</span>
                </div>
            </div>

            <%-- STEP 1: Chọn SKU gốc --%>
            <div id="wizStep1Content" class="cp-form-group">
                <div class="cp-form-group" style="position: relative">
                    <label class="cp-form-label">Tìm kiếm Master SKU đã duyệt (Active)</label>
                    <div style="position: relative">
                        <svg class="cp-search-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                        <input type="text" class="cp-search-input" style="width: 100%" placeholder="Nhập tên sản phẩm hoặc mã SKU..." id="wizStep1SearchInp" oninput="onWizMasterSearch(this.value)" />
                    </div>
                </div>

                <div class="cp-wiz-list" id="wizMasterSKUList">
                    <%-- Loaded by JS --%>
                </div>

                <div class="cp-spec-card" id="wizMasterSpecCard" style="display:none">
                    <div class="cp-spec-title">Thông tin trích xuất sản phẩm gốc (Chỉ xem)</div>
                    <div class="cp-spec-grid">
                        <div>
                            <div class="cp-spec-label">Tên SKU gốc</div>
                            <div class="cp-spec-val" id="wizSpecName">-</div>
                        </div>
                        <div>
                            <div class="cp-spec-label">Mã SKU gốc</div>
                            <div class="cp-spec-val cp-font-mono" id="wizSpecCode">-</div>
                        </div>
                        <div>
                            <div class="cp-spec-label">Khối lượng</div>
                            <div class="cp-spec-val" id="wizSpecWeight">-</div>
                        </div>
                        <div>
                            <div class="cp-spec-label">Kích thước (D×R×C)</div>
                            <div class="cp-spec-val" id="wizSpecDimensions">-</div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- STEP 2: Chọn Sàn bán --%>
            <div id="wizStep2Content" style="display:none" class="cp-form-group">
                <div style="background: rgba(240, 245, 255, 0.4); border: 1px solid #E5EAF3; padding: 0.75rem; border-radius: 8px; margin-bottom: 1rem; display: flex; align-items: center; gap: 0.5rem">
                    <svg style="width:18px;height:18px;color:var(--navy)" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg>
                    <div>
                        <div style="font-size:12px;font-weight:700">Sản phẩm chọn đồng bộ</div>
                        <div style="font-size:11px;color:rgba(16,55,92,.6)" id="wizStep2ProductLabel">-</div>
                    </div>
                </div>

                <label class="cp-form-label" style="font-weight:700;margin-bottom:0.75rem">Chọn sàn thương mại điện tử đích *</label>
                <div class="cp-platforms-grid">
                    <div class="cp-platform-card" onclick="toggleWizChannel('shopee')" id="pCardShopee">
                        <div class="cp-platform-header">
                            <span class="cp-platform-badge" style="background:#EE4D2D">Shopee</span>
                            <div class="cp-platform-chk">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3.5"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" /></svg>
                            </div>
                        </div>
                        <p class="cp-platform-desc">Đồng bộ sản phẩm qua API Sandbox Shopee v2. Quản lý danh mục ngành hàng chuyên nghiệp.</p>
                    </div>

                    <div class="cp-platform-card" onclick="toggleWizChannel('lazada')" id="pCardLazada">
                        <div class="cp-platform-header">
                            <span class="cp-platform-badge" style="background:#0F146D">Lazada</span>
                            <div class="cp-platform-chk">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3.5"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" /></svg>
                            </div>
                        </div>
                        <p class="cp-platform-desc">Kết nối cổng Lazada Sandbox Open Platform. Đồng bộ giá sàn bán lẻ tùy biến.</p>
                    </div>

                    <div class="cp-platform-card" onclick="toggleWizChannel('tiktok')" id="pCardTiktok">
                        <div class="cp-platform-header">
                            <span class="cp-platform-badge" style="background:#69C9D0">TikTok Shop</span>
                            <div class="cp-platform-chk">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3.5"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" /></svg>
                            </div>
                        </div>
                        <p class="cp-platform-desc">Giao tiếp nền tảng TikTok Shop API. Cho phép tạo SKU đa liên kết kênh.</p>
                    </div>
                </div>
            </div>

            <%-- STEP 3: Cấu hình sàn --%>
            <div id="wizStep3Content" style="display:none" class="cp-form-group">
                <div style="background: rgba(240, 245, 255, 0.4); border: 1px solid #E5EAF3; padding: 0.5rem 0.75rem; border-radius: 8px; margin-bottom: 1.25rem; font-size: 12px">
                    <span style="color:rgba(16,55,92,.6)">Sản phẩm đồng bộ: </span><strong id="wizStep3ProductLabel">-</strong>
                </div>

                <div id="wizStep3ChannelsContainer">
                    <%-- Populated by JS depending on selected platforms --%>
                </div>
            </div>
        </div>

        <div class="cp-modal-footer">
            <button class="cp-btn-edit" style="width:auto;padding:0.5rem 1rem;border:1px solid #E5EAF3" onclick="closePublishWizard()">HỦY BỎ</button>
            <div style="display:flex;gap:0.5rem">
                <button class="cp-btn-edit" style="width:auto;padding:0.5rem 1rem;border:1px solid #E5EAF3;display:none" id="btnWizPrev" onclick="wizNavigate(-1)">Quay lại</button>
                <button class="cp-btn-push" id="btnWizNext" onclick="wizNavigate(1)">Tiếp tục</button>
            </div>
        </div>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════════════
     MODAL: CẤU HÌNH LẠI SẢN PHẨM KÊNH (EDIT PRODUCT MODAL)
     ══════════════════════════════════════════════════════════════════ --%>
<div class="cp-modal-overlay" id="editProductOverlay" onclick="closeEditModal()">
    <div class="cp-modal" onclick="event.stopPropagation()" style="max-width: 600px">
        <div class="cp-modal-header">
            <div class="cp-modal-title">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" /></svg>
                Cấu hình lại sản phẩm kênh
            </div>
            <button class="cp-modal-close" onclick="closeEditModal()">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" /></svg>
            </button>
        </div>

        <div class="cp-modal-body" style="display:flex; flex-direction:column; gap:1rem">
            <div style="background: var(--alice); border: 1px solid #E5EAF3; padding: 0.75rem; border-radius: 6px; display:flex; justify-content:space-between; font-size:13px">
                <div>
                    <div style="color:rgba(16,55,92,.5);font-size:11px">Sản phẩm gốc</div>
                    <strong id="editProductMasterName">-</strong>
                </div>
                <div style="text-align:right">
                    <div style="color:rgba(16,55,92,.5);font-size:11px">Mã SKU gốc</div>
                    <strong class="cp-font-mono" id="editProductMasterSKU">-</strong>
                </div>
            </div>

            <%-- Image uploader --%>
            <div style="border-bottom:1px solid #F0F3FA; padding-bottom:1rem">
                <label class="cp-form-label" style="font-weight:700">Hình ảnh sản phẩm trên sàn *</label>
                <div class="cp-upload-grid" id="editImagesGrid">
                    <%-- Populated by JS --%>
                </div>
                <div style="font-size: 10px; color: rgba(16,55,92,.45); margin-top: 0.5rem">
                    * Khuyên dùng ảnh vuông 800x800px. Hỗ trợ JPG/PNG. Ảnh đầu tiên được dùng làm ảnh bìa khi đẩy lên kênh.
                </div>
            </div>

            <div class="cp-form-group">
                <label class="cp-form-label" style="font-weight:700">Giá bán trên sàn (VNĐ) *</label>
                <input type="number" class="cp-input-text" id="editProductPrice" min="0" required />
            </div>

            <div class="cp-form-group">
                <label class="cp-form-label" style="font-weight:700">Mô tả sản phẩm trên sàn</label>
                <textarea class="cp-input-text" style="height: 100px; resize: none" id="editProductDesc" required></textarea>
            </div>
        </div>

        <div class="cp-modal-footer">
            <span style="font-size:11px;color:rgba(16,55,92,.4)">* Bắt buộc</span>
            <div style="display:flex;gap:0.5rem">
                <button class="cp-btn-edit" style="width:auto;padding:0.5rem 1rem;border:1px solid #E5EAF3" onclick="closeEditModal()">Hủy</button>
                <button class="cp-btn-push" onclick="submitEditProduct()">Cập nhật</button>
            </div>
        </div>
    </div>
</div>

<%-- ── NOTIFICATION TOAST POPUP ── --%>
<div class="op-toast" id="opToast" style="position: fixed; top: 2rem; right: 2rem; background: var(--navy); color: #fff; padding: 1rem 1.5rem; border-radius: var(--radius-btn); box-shadow: 0 10px 25px rgba(0,0,0,.15); z-index: 150; font-size: 13px; font-weight: 700; display: flex; align-items: center; gap: 0.75rem; transform: translateY(-20px); opacity: 0; pointer-events: none; transition: all .25s ease-out;">
    <svg id="opToastIcon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="width:16px;height:16px"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
    <span id="opToastMsg">Thông báo hệ thống</span>
</div>

<div id="channelsDataContainer" style="display: none;">
    [
    <%
        java.util.List<com.wms.model.Channel> list = (java.util.List<com.wms.model.Channel>) request.getAttribute("channelsList");
        if (list != null) {
            for (int i = 0; i < list.size(); i++) {
                com.wms.model.Channel c = list.get(i);
    %>
    {
        "channelId": <%= c.getChannelId() %>,
        "channelName": "<%= c.getChannelName().replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r") %>",
        "platform": "<%= c.getPlatform() %>",
        "apiUrl": "<%= c.getApiUrl() != null ? c.getApiUrl().replace("\\", "\\\\").replace("\"", "\\\"") : "" %>",
        "bufferStock": <%= c.getBufferStock() %>,
        "active": <%= c.isActive() %>
    }<%= (i < list.size() - 1) ? "," : "" %>
    <%
            }
        }
    %>
    ]
</div>

<script>
// ── GLOBALS & STORE ──────────────────────────────────────────────────
let channelsList = [];
const channelsDataElem = document.getElementById("channelsDataContainer");
if (channelsDataElem) {
    try {
        channelsList = JSON.parse(channelsDataElem.textContent.trim());
    } catch (e) {
        console.error("Failed to parse channels data:", e);
    }
}
let mainTab = "products"; // products | pricing | channels
let filterChannel = "all";
let productSearchVal = "";

let channelProducts = [];
let pricingRecords = [];
let wmsSKUs = [];

// Wizard states
let wizStep = 1; // 1 | 2 | 3
let wizSelectedMasterSKU = null;
let wizSelectedChannels = []; // array of 'shopee', 'lazada', 'tiktok'
let wizMasterSearchQuery = "";
let wizChannelConfigs = {
    shopee: { category: "Đồ dùng học tập > Vở & Sổ chép", price: 150000, brand: "No Brand" },
    lazada: { category: "Văn phòng phẩm > Phụ kiện học sinh", price: 150000, brand: "" },
    tiktok: { category: "Phụ kiện cá nhân > Tiện ích", price: 150000, brand: "" }
};
let wizChannelImages = { shopee: [], lazada: [], tiktok: [] };

// Sandbox steps details
const sandboxStepsList = [
    { id: "sStep1" }, { id: "sStep2" }, { id: "sStep3" }, { id: "sStep4" }, { id: "sStep5" }, { id: "sStep6" }
];

// Edit states
let editTargetProductId = null;
let editImagesList = [];

// Pricing states
let pricingSelectedChannel = "shopee";
let pricingSaveStatusText = "Chưa lưu";

// Cron job sync states
let cronCountdown = 15;
let isCronSyncing = false;
let cronTimer = null;

// High-quality default covers to prevent placeholder look
const DYNAMIC_PRODUCT_COVERS = {
    "Vở": "https://images.unsplash.com/photo-1531346878377-a5be20888e57?auto=format&fit=crop&q=80&w=400",
    "Gương": "https://images.unsplash.com/photo-1595959183075-c1d09e7a9cf1?auto=format&fit=crop&q=80&w=400",
    "Lược": "https://images.unsplash.com/photo-1590156546746-c58d08593010?auto=format&fit=crop&q=80&w=400",
    "Bút": "https://images.unsplash.com/photo-1583485088034-697b5bc54ccd?auto=format&fit=crop&q=80&w=400",
    "Thước": "https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?auto=format&fit=crop&q=80&w=400",
    "Kéo": "https://images.unsplash.com/photo-1543002588-bfa74002ed7e?auto=format&fit=crop&q=80&w=400"
};

function getDynamicCover(name) {
    for (let key in DYNAMIC_PRODUCT_COVERS) {
        if (name.toLowerCase().includes(key.toLowerCase())) {
            return DYNAMIC_PRODUCT_COVERS[key];
        }
    }
    return "https://images.unsplash.com/photo-1543002588-bfa74002ed7e?auto=format&fit=crop&q=80&w=400";
}

// ── INIT DOMContentLoaded ──────────────────────────────────────────
document.addEventListener("DOMContentLoaded", function() {
    loadData();
    renderAll();
    setupCronSync();
});

function loadData() {
    // 1. Approved Master SKUs from wms_skus
    const storedWMS = localStorage.getItem("wms_skus");
    if (storedWMS) {
        try {
            wmsSKUs = JSON.parse(storedWMS).filter(s => s.approvalStatus === "approved");
        } catch(e) { wmsSKUs = []; }
    } else {
        wmsSKUs = [];
    }

    // 2. Channel Products
    const storedCP = localStorage.getItem("channel_products_v2");
    if (storedCP) {
        try { channelProducts = JSON.parse(storedCP); } catch(e) { channelProducts = []; }
    } else {
        // Zero hardcoded seed data fallback
        channelProducts = [];
        localStorage.setItem("channel_products_v2", JSON.stringify([]));
    }

    // 3. Pricing Configuration (sales pricing)
    const storedPricing = localStorage.getItem("wh_pricing_sales");
    if (storedPricing) {
        try { pricingRecords = JSON.parse(storedPricing); } catch(e) { pricingRecords = []; }
    } else {
        // Initialize pricingRecords dynamically based on approved WMS SKUs (no hardcoded templates)
        pricingRecords = wmsSKUs.map(sku => {
            const importP = sku.importPrice || 50000;
            const retailP = sku.price || (importP * 1.5);
            const promoP = Math.round(retailP * 0.9);
            const today = new Date().toISOString().slice(0,10);
            return {
                id: sku.id || "pr_" + sku.sku,
                sku: sku.sku,
                name: sku.name,
                category: sku.category || "General",
                status: "active",
                qtyOnHand: sku.qtyOnHand || 0,
                importPrice: importP,
                costOfGoodsSold: importP,
                importUpdatedAt: today + " 12:00",
                channelPrices: {
                    shopee: { retailPrice: retailP, promoPrice: promoP, effectiveDate: today },
                    tiktok: { retailPrice: retailP, promoPrice: promoP, effectiveDate: today },
                    lazada: { retailPrice: retailP, promoPrice: promoP, effectiveDate: today },
                    website: { retailPrice: retailP, promoPrice: promoP, effectiveDate: today }
                }
            };
        });
        localStorage.setItem("wh_pricing_sales", JSON.stringify(pricingRecords));
    }

    // Load last saved pricing timestamp
    const timestamp = localStorage.getItem("wh_pricing_sales_timestamp");
    pricingSaveStatusText = timestamp ? "Đã lưu lúc " + timestamp : "Chưa lưu";
}

function saveData() {
    localStorage.setItem("channel_products_v2", JSON.stringify(channelProducts));
    localStorage.setItem("wh_pricing_sales", JSON.stringify(pricingRecords));
    window.dispatchEvent(new CustomEvent("ORDER_STORE_UPDATED"));
}

// ── TOAST NOTIFICATIONS ──
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

// ── RENDER ROOT CONTROL ──────────────────────────────────────────────
function renderAll() {
    if (mainTab === "products") {
        renderProductsTab();
    } else if (mainTab === "pricing") {
        renderPricingTab();
    } else if (mainTab === "channels") {
        renderChannelsTab();
    }
}

function switchMainTab(tab) {
    mainTab = tab;
    document.getElementById("tabProductsBtn").classList.remove("active");
    document.getElementById("tabPricingBtn").classList.remove("active");
    document.getElementById("tabChannelsBtn").classList.remove("active");
    
    document.getElementById("tabProductsContent").style.display = "none";
    document.getElementById("tabPricingContent").style.display = "none";
    document.getElementById("tabChannelsContent").style.display = "none";
    
    if (tab === "products") {
        document.getElementById("tabProductsBtn").classList.add("active");
        document.getElementById("tabProductsContent").style.display = "block";
    } else if (tab === "pricing") {
        document.getElementById("tabPricingBtn").classList.add("active");
        document.getElementById("tabPricingContent").style.display = "block";
    } else {
        document.getElementById("tabChannelsBtn").classList.add("active");
        document.getElementById("tabChannelsContent").style.display = "block";
    }
    renderAll();
}

function escapeHtml(str) {
    if (!str) return "";
    return str.replace(/&/g, "&amp;")
              .replace(/</g, "&lt;")
              .replace(/>/g, "&gt;")
              .replace(/"/g, "&quot;")
              .replace(/'/g, "&#039;");
}

function renderChannelsTab() {
    const grid = document.getElementById("channelsGrid");
    if (!grid) return;
    
    if (!channelsList || channelsList.length === 0) {
        grid.innerHTML = `
            <div style="grid-column: 1 / -1; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 4rem 2rem; background: white; border: 1px solid #E5EAF3; border-radius: var(--radius-card); text-align: center;">
                <h4 style="color: var(--navy); font-size: 15px; font-weight: 700; margin: 0 0 0.5rem 0;">Chưa cấu hình kênh bán hàng nào</h4>
                <p style="color: rgba(16,55,92,0.45); font-size: 13px; margin: 0;">Vui lòng liên hệ Administrator để cấu hình kết nối kênh bán hàng.</p>
            </div>
        `;
        return;
    }
    
    grid.innerHTML = channelsList.map(chan => {
        const platformBadge = chan.platform === 'Lazada' 
            ? `<span style="background: rgba(16,115,230,0.1); color: #1073e6; padding: 0.25rem 0.5rem; font-size: 10px; font-weight: 800; border-radius: 4px; border: 1px solid rgba(16,115,230,0.2);">LAZADA</span>`
            : chan.platform === 'Shopee'
                ? `<span style="background: rgba(238,77,45,0.1); color: #ee4d2d; padding: 0.25rem 0.5rem; font-size: 10px; font-weight: 800; border-radius: 4px; border: 1px solid rgba(238,77,45,0.2);">SHOPEE</span>`
                : `<span style="background: rgba(0,0,0,0.08); color: #000000; padding: 0.25rem 0.5rem; font-size: 10px; font-weight: 800; border-radius: 4px; border: 1px solid rgba(0,0,0,0.15);">TIKTOK SHOP</span>`;
                
        const statusBadge = chan.active
            ? `<span style="display: inline-flex; align-items: center; gap: 0.25rem; padding: 0.125rem 0.5rem; background: #e6f7ed; color: #10b981; font-size: 11px; font-weight: 700; border-radius: 20px; border: 1px solid rgba(16,185,129,0.2);">Active</span>`
            : `<span style="display: inline-flex; align-items: center; gap: 0.25rem; padding: 0.125rem 0.5rem; background: #f3f5f8; color: rgba(16,55,92,0.4); font-size: 11px; font-weight: 700; border-radius: 20px; border: 1px solid #E5EAF3;">Inactive</span>`;

        return `
            <div style="background: white; border: 1px solid #E5EAF3; border-radius: var(--radius-card); padding: 1.5rem; display: flex; flex-direction: column; justify-content: space-between; transition: box-shadow 0.2s, transform 0.2s;">
                <div>
                    <!-- Header -->
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                        <div style="display: flex; align-items: center; gap: 0.75rem;">
                            \${platformBadge}
                            <h4 style="color: var(--navy); font-size: 15px; font-weight: 700; margin: 0;">\${escapeHtml(chan.channelName)}</h4>
                        </div>
                        \${statusBadge}
                    </div>

                    <!-- Config Details -->
                    <div style="font-size: 12px; color: rgba(16,55,92,0.70); margin-bottom: 1.25rem; display: flex; flex-direction: column; gap: 0.5rem;">
                        <div style="display: flex; justify-content: space-between;">
                            <span>API Endpoint:</span>
                            <span style="font-family: monospace; font-weight: 600; color: var(--navy); text-overflow: ellipsis; overflow: hidden; white-space: nowrap; max-width: 14rem;">\${escapeHtml(chan.apiUrl)}</span>
                        </div>
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <span>Webhook Status:</span>
                            <span style="color: #10b981; font-weight: 700; display: inline-flex; align-items: center; gap: 0.25rem;">
                                <span style="display: inline-block; width: 6px; height: 6px; border-radius: 50%; background: #10b981;"></span>Live
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Buffer Stock Edit Form -->
                <div style="border-top: 1px dashed #E5EAF3; padding-top: 0.75rem; display: flex; flex-direction: column; gap: 0.5rem;">
                    <label style="font-size: 12px; font-weight: 600; color: rgba(16,55,92,0.7);">Số lượng tồn đệm (Buffer Stock):</label>
                    <div style="display: flex; gap: 0.5rem; align-items: center;">
                        <input type="number" id="bufferStock_\${chan.channelId}" value="\${chan.bufferStock}" min="0" step="0.5"
                               style="flex: 1; padding: 0.5rem; background: var(--alice); border: 1px solid #E5EAF3; color: var(--navy); font-size: 13px; outline: none; border-radius: 4px;" />
                        <button type="button" onclick="updateChannelBufferStock('\${chan.channelId}')"
                                style="padding: 0.5rem 1rem; background: var(--orange); color: white; border: none; font-size: 12px; font-weight: 700; border-radius: 4px; cursor: pointer; box-shadow: 0 4px 10px rgba(235,131,23,0.15);">
                            Cập nhật
                        </button>
                    </div>
                </div>
            </div>
        `;
    }).join("");
}

function updateChannelBufferStock(channelId) {
    const bufferStockInput = document.getElementById("bufferStock_" + channelId);
    if (!bufferStockInput) return;
    const value = parseFloat(bufferStockInput.value);
    if (isNaN(value) || value < 0) {
        showToast("Vui lòng nhập số lượng tồn đệm hợp lệ!", "error");
        return;
    }

    const params = new URLSearchParams();
    params.append("action", "updateBufferStock");
    params.append("channelId", channelId);
    params.append("bufferStock", value);

    fetch('<%= request.getContextPath() %>/sales/channel-products', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            showToast("Đã cập nhật tồn đệm của kênh thành công!");
            const chan = channelsList.find(c => c.channelId == channelId);
            if (chan) {
                chan.bufferStock = value;
            }
            renderChannelsTab();
        } else {
            showToast("Cập nhật thất bại: " + data.message, "error");
        }
    })
    .catch(err => {
        console.error(err);
        showToast("Không thể kết nối đến server. Thử lại sau!", "error");
    });
}

// ── TAB 1: PRODUCTS LISTING & HANDLERS ────────────────────────────────
function renderProductsTab() {
    // 1. Filter products
    const filtered = channelProducts.filter(p => {
        const matchChannel = filterChannel === "all" || p.channel.toLowerCase() === filterChannel.toLowerCase();
        const matchSearch = !productSearchVal ||
            p.productName.toLowerCase().includes(productSearchVal.toLowerCase()) ||
            p.masterSKU.toLowerCase().includes(productSearchVal.toLowerCase()) ||
            p.channelSKU.toLowerCase().includes(productSearchVal.toLowerCase());
        return matchChannel && matchSearch;
    });

    // 2. Calculate Stats
    const statsTotal = filtered.length;
    const statsActive = filtered.filter(p => p.status === "active").length;
    const statsOOS = filtered.filter(p => p.stock - (p.bufferStock || 0) <= 0).length;
    const totalValVal = filtered.reduce((sum, p) => sum + (p.price * p.stock), 0);

    document.getElementById("statTotalProducts").textContent = statsTotal;
    document.getElementById("statActiveProducts").textContent = statsActive;
    document.getElementById("statOOSProducts").textContent = statsOOS;
    document.getElementById("statInventoryValue").textContent = (totalValVal / 1000000).toFixed(1) + "M";

    // 3. Render Table
    const tbody = document.getElementById("cpProductsTableBody");
    tbody.innerHTML = "";

    if (filtered.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="11" class="op-empty">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" /></svg>
                    Chưa có sản phẩm nào được đồng bộ lên sàn. Bấm 'Đẩy sản phẩm lên sàn' để bắt đầu.
                </td>
            </tr>
        `;
        return;
    }

    filtered.forEach(p => {
        const tr = document.createElement("tr");

        // Sync connection state UI
        let syncHtml = "";
        if (p.syncStatus === "syncing") {
            syncHtml = `<span class="cp-sync-status syncing">Đang đồng bộ...</span>`;
        } else if (p.syncStatus === "failed") {
            syncHtml = `<span class="cp-sync-status failed" onclick="alert('LỖI ĐỒNG BỘ: Mất kết nối API Gateway đến sàn TMĐT hoặc Token của Shop đã hết hạn. Vui lòng kiểm tra lại cấu hình kết nối sàn ở cài đặt hệ thống.')">Lỗi kết nối</span>`;
        } else {
            syncHtml = `<span class="cp-sync-status success">Thành công</span>`;
        }

        // Status badge config
        let statusClass = "active";
        let statusLabel = "Đang bán";
        if (p.status === "out_of_stock" || p.stock === 0) {
            statusClass = "out_of_stock";
            statusLabel = "Hết hàng";
        } else if (p.status === "inactive") {
            statusClass = "inactive";
            statusLabel = "Ngừng bán";
        }

        // Channel styling color map
        const chColors = { shopee: "#EE4D2D", tiktok: "#69C9D0", lazada: "#0F146D", website: "#EB8317" };
        const chNames = { shopee: "Shopee", tiktok: "TikTok", lazada: "Lazada", website: "Website" };
        const chCol = chColors[p.channel] || "#64748b";
        const chName = chNames[p.channel] || p.channel;

        tr.innerHTML = `
            <td><span class="cp-font-mono" style="color:rgba(16, 55, 92, 0.7)">\${p.masterSKU}</span></td>
            <td><span class="cp-font-mono" style="color:var(--navy);font-weight:700">\${p.channelSKU}</span></td>
            <td>
                <div style="min-width: 220px; max-width: 320px;">
                    <div style="font-weight: 700; color: var(--navy); font-size: 13px">\${p.productName}</div>
                    <div class="cp-p-desc">\${p.description || ""}</div>
                    \${p.channelItemId ? '<div class="cp-p-id">ID Sàn: ' + p.channelItemId + '</div>' : ""}
                </div>
            </td>
            <td>
                <span class="cp-badge-channel" style="background:\${chCol}">\${chName}</span>
            </td>
            <td style="text-align: right; font-weight: 700; font-size: 13px; white-space:nowrap">\${Number(p.price).toLocaleString()}đ</td>
            <td style="text-align: right; font-weight: 600; color: \${p.stock === 0 ? "#ef4444" : "#059669"}">\${p.stock}</td>
            <td style="text-align: center;">
                <input type="number" class="cp-input-text cp-input-buffer" min="0" value="\${p.bufferStock || 0}" onchange="onBufferStockInput('\${p.id}', this.value)" title="Cài đặt hàng đệm an toàn để tránh bán lố (Overselling)" />
            </td>
            <td style="text-align: right; font-weight: 700; font-family: monospace; font-size: 13px">
                \${Math.max(0, p.stock - (p.bufferStock || 0))}
            </td>
            <td>\${syncHtml}</td>
            <td>
                <span class="cp-status-pill \${statusClass}">\${statusLabel}</span>
            </td>
            <td>
                <div style="display:flex; justify-content:center">
                    <button class="cp-btn-edit" onclick="openEditModal('\${p.id}')" title="Sửa sản phẩm">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" /></svg>
                    </button>
                </div>
            </td>
        `;
        tbody.appendChild(tr);
    });
}

function onChannelFilterChange(val) {
    filterChannel = val;
    renderProductsTab();
}

function onProductSearch(val) {
    productSearchVal = val;
    renderProductsTab();
}

// ── BUFFER STOCK CHANGE WITH SIMULATED SYNC ──
function onBufferStockInput(productId, value) {
    const nextVal = Math.max(0, parseInt(value) || 0);

    // Update locally to "syncing"
    channelProducts = channelProducts.map(p => {
        if (p.id === productId) {
            return { ...p, bufferStock: nextVal, syncStatus: "syncing" };
        }
        return p;
    });
    saveData();
    renderProductsTab();

    // Trigger simulated success push
    setTimeout(() => {
        channelProducts = channelProducts.map(p => {
            if (p.id === productId) {
                return { ...p, syncStatus: "success" };
            }
            return p;
        });
        saveData();
        renderProductsTab();
        showToast("Đã đồng bộ cài đặt Hàng đệm an toàn lên sàn thành công!");
    }, 1500);
}

// ── BACKGROUND INVENTORY SYNC CRONJOB SIMULATION ──
function setupCronSync() {
    if (cronTimer) clearInterval(cronTimer);
    cronCountdown = 15;

    cronTimer = setInterval(() => {
        if (mainTab !== "products") return;
        
        cronCountdown--;
        if (cronCountdown <= 0) {
            // Run cron sync execution
            isCronSyncing = true;
            
            // Set all active channel products to syncing visual state
            channelProducts = channelProducts.map(p => {
                if (p.syncStatus !== "failed") {
                    return { ...p, syncStatus: "syncing" };
                }
                return p;
            });
            renderProductsTab();

            setTimeout(() => {
                isCronSyncing = false;
                channelProducts = channelProducts.map(p => {
                    if (p.syncStatus !== "failed") {
                        return { ...p, syncStatus: "success" };
                    }
                    return p;
                });
                saveData();
                renderProductsTab();
                
                const nowText = new Date().toLocaleTimeString("vi-VN", { hour: "2-digit", minute: "2-digit", second: "2-digit" });
                showToast("Cronjob: Tự động đồng bộ tồn kho vật lý của WMS sang các sàn thành công (" + nowText + ")");
            }, 1200);

            cronCountdown = 15;
        }
    }, 1000);
}

// ── TAB 2: PRICING CONFIGURATION & HANDLERS ──────────────────────────
function renderPricingTab() {
    const activeCount = pricingRecords.filter(r => r.status === "active").length;
    const inactiveCount = pricingRecords.filter(r => r.status === "inactive").length;

    document.getElementById("prStatActiveSKUs").textContent = activeCount;
    document.getElementById("prStatLockSKUs").textContent = inactiveCount;

    // Highlight active Channel Pill
    document.querySelectorAll(".pr-channel-pill").forEach(p => p.classList.remove("active"));
    const selectedBtnId = "prChannel" + pricingSelectedChannel.charAt(0).toUpperCase() + pricingSelectedChannel.slice(1);
    const activeBtn = document.getElementById(selectedBtnId);
    if (activeBtn) activeBtn.classList.add("active");

    const channelLabels = { shopee: "Shopee", tiktok: "TikTok", lazada: "Lazada", website: "Website" };
    document.getElementById("prActiveChannelLabel").textContent = channelLabels[pricingSelectedChannel] || pricingSelectedChannel;
    document.getElementById("prSaveStatus").textContent = pricingSaveStatusText;

    const tbody = document.getElementById("prPricingTableBody");
    tbody.innerHTML = "";

    if (pricingRecords.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="8" class="op-empty">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
                    Không tìm thấy Master SKU nào đã duyệt để cấu hình giá bán.
                </td>
            </tr>
        `;
        return;
    }

    pricingRecords.forEach(r => {
        const editable = r.status === "active";
        const channelPrice = r.channelPrices[pricingSelectedChannel] || { retailPrice: 0, promoPrice: 0 };
        const retailMargin = channelPrice.retailPrice - r.importPrice;
        const promoMargin = channelPrice.promoPrice - r.importPrice;

        // Badge config
        let badgeHtml = "";
        if (r.status === "active") {
            badgeHtml = `<span class="cp-status-pill active">Active</span>`;
        } else if (r.status === "low_stock") {
            badgeHtml = `<span class="cp-status-pill out_of_stock" style="background:rgba(245,158,11,.15);color:#d97706">Sắp hết</span>`;
        } else {
            badgeHtml = `<span class="cp-status-pill inactive">Inactive</span>`;
        }

        const tr = document.createElement("tr");
        tr.innerHTML = `
            <td>
                <div class="cp-font-mono" style="color:var(--navy);font-weight:700">\${r.sku}</div>
                <div style="font-size:11px;color:rgba(16,55,92,.45);margin-top:2px">\${r.category || ""}</div>
            </td>
            <td>
                <div style="font-weight: 600; color: var(--navy)">\${r.name}</div>
                <div style="font-size:11px;color:rgba(16,55,92,.45);margin-top:2px">Chỉ áp dụng cho kênh \${channelLabels[pricingSelectedChannel]}</div>
            </td>
            <td style="text-align: center">\${badgeHtml}</td>
            <td style="text-align: right; font-weight: 700">\${Number(r.importPrice).toLocaleString()}đ</td>
            <td style="text-align: right">
                <input type="number" class="pr-price-input" min="0" value="\${channelPrice.retailPrice}" oninput="onPricingPriceChange('\${r.id}', 'retailPrice', this.value)" \${editable ? "" : "disabled"} />
            </td>
            <td style="text-align: right">
                <input type="number" class="pr-price-input" min="0" value="\${channelPrice.promoPrice}" oninput="onPricingPriceChange('\${r.id}', 'promoPrice', this.value)" \${editable ? "" : "disabled"} />
            </td>
            <td style="text-align: right">
                <div style="font-weight: 700; color: var(--navy)">\${Math.max(retailMargin, promoMargin).toLocaleString()}đ</div>
                <div style="font-size:11px;color:rgba(16,55,92,.45);margin-top:1px">Promo: \${promoMargin.toLocaleString()}đ</div>
            </td>
            <td style="text-align: right">
                <button class="pr-save-btn" onclick="savePricingRecord('\${r.id}')" \${editable ? "" : "disabled"}>
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4" /></svg>
                    Lưu
                </button>
            </td>
        `;
        tbody.appendChild(tr);
    });
}

function setPricingChannel(channel) {
    pricingSelectedChannel = channel;
    renderPricingTab();
}

function onPricingPriceChange(recordId, field, value) {
    const nextVal = Math.max(0, Number(value) || 0);
    pricingRecords = pricingRecords.map(r => {
        if (r.id === recordId) {
            const updatedChannelPrices = { ...r.channelPrices };
            updatedChannelPrices[pricingSelectedChannel] = {
                ...updatedChannelPrices[pricingSelectedChannel],
                [field]: nextVal
            };
            return { ...r, channelPrices: updatedChannelPrices };
        }
        return r;
    });
    pricingSaveStatusText = "Có thay đổi chưa lưu";
    document.getElementById("prSaveStatus").textContent = pricingSaveStatusText;
}

function savePricingRecord(recordId) {
    const today = new Date().toISOString().slice(0, 10);
    pricingRecords = pricingRecords.map(r => {
        if (r.id === recordId) {
            const updatedChannelPrices = { ...r.channelPrices };
            updatedChannelPrices[pricingSelectedChannel] = {
                ...updatedChannelPrices[pricingSelectedChannel],
                effectiveDate: today
            };
            return { ...r, channelPrices: updatedChannelPrices };
        }
        return r;
    });

    // Also update any matching product in channelProducts list
    const record = pricingRecords.find(r => r.id === recordId);
    if (record) {
        channelProducts = channelProducts.map(p => {
            if (p.masterSKU === record.sku && p.channel === pricingSelectedChannel) {
                const specConfig = record.channelPrices[pricingSelectedChannel];
                return { ...p, price: specConfig.retailPrice };
            }
            return p;
        });
    }

    saveData();
    const timeStr = new Date().toLocaleTimeString("vi-VN");
    pricingSaveStatusText = "Đã lưu lúc " + timeStr;
    localStorage.setItem("wh_pricing_sales_timestamp", timeStr);
    renderPricingTab();
    showToast("Cập nhật giá bán thành công cho SKU!");
}

function saveAllPricingRecords() {
    const today = new Date().toISOString().slice(0, 10);
    pricingRecords = pricingRecords.map(r => {
        const updatedChannelPrices = { ...r.channelPrices };
        for (let ch in updatedChannelPrices) {
            updatedChannelPrices[ch] = {
                ...updatedChannelPrices[ch],
                effectiveDate: today
            };
        }
        return { ...r, channelPrices: updatedChannelPrices };
    });

    // Sync all channel products prices
    channelProducts = channelProducts.map(p => {
        const record = pricingRecords.find(r => r.sku === p.masterSKU);
        if (record && record.channelPrices[p.channel]) {
            return { ...p, price: record.channelPrices[p.channel].retailPrice };
        }
        return p;
    });

    saveData();
    const timeStr = new Date().toLocaleTimeString("vi-VN");
    pricingSaveStatusText = "Đã lưu tất cả - " + timeStr;
    localStorage.setItem("wh_pricing_sales_timestamp", timeStr);
    renderPricingTab();
    showToast("Đã lưu bảng cấu hình giá bán của tất cả sản phẩm!");
}

// ── TAB 1 MODAL: PUBLISH NEW WIZARD ──────────────────────────────────
function openPublishWizard() {
    if (wmsSKUs.length === 0) {
        alert("Không tìm thấy Master SKU nào đã duyệt trong hệ thống. Vui lòng phê duyệt Master SKU tại trung tâm SKU trước khi đồng bộ lên sàn!");
        return;
    }

    wizStep = 1;
    wizSelectedMasterSKU = null;
    wizSelectedChannels = [];
    wizMasterSearchQuery = "";
    wizChannelConfigs = {
        shopee: { category: "Đồ dùng học tập > Vở & Sổ chép", price: 150000, brand: "No Brand" },
        lazada: { category: "Văn phòng phẩm > Phụ kiện học sinh", price: 150000, brand: "" },
        tiktok: { category: "Phụ kiện cá nhân > Tiện ích", price: 150000, brand: "" }
    };
    
    // Clear wizard image states
    wizChannelImages = { shopee: [], lazada: [], tiktok: [] };

    document.getElementById("publishWizardOverlay").classList.add("open");
    document.getElementById("wizStep1SearchInp").value = "";
    
    renderWizStep1();
    renderWizProgress();
}

function closePublishWizard() {
    document.getElementById("publishWizardOverlay").classList.remove("open");
    document.getElementById("sandboxOverlay").classList.remove("open");
}

function renderWizProgress() {
    const list = [1, 2, 3];
    list.forEach(s => {
        const ind = document.getElementById("wizInd" + s);
        const num = document.getElementById("wizIndNum" + s);

        ind.classList.remove("active", "done");
        if (s < wizStep) {
            ind.classList.add("done");
            num.textContent = "✓";
        } else if (s === wizStep) {
            ind.classList.add("active");
            num.textContent = s;
        } else {
            num.textContent = s;
        }
    });

    // Toggle navigation buttons
    document.getElementById("btnWizPrev").style.display = (wizStep > 1) ? "inline-flex" : "none";
    document.getElementById("btnWizNext").textContent = (wizStep < 3) ? "Tiếp tục" : "ĐỒNG BỘ LÊN SÀN (PUBLISH)";
}

function onWizMasterSearch(val) {
    wizMasterSearchQuery = val;
    renderWizMasterList();
}

function renderWizMasterList() {
    const listDiv = document.getElementById("wizMasterSKUList");
    listDiv.innerHTML = "";

    const query = wizMasterSearchQuery.toLowerCase().trim();
    const filtered = wmsSKUs.filter(s =>
        s.name.toLowerCase().includes(query) ||
        s.sku.toLowerCase().includes(query)
    );

    if (filtered.length === 0) {
        listDiv.innerHTML = `<div style="padding: 1.5rem; text-align: center; color: rgba(16, 55, 92, 0.45); font-size:13px">Không tìm thấy Master SKU nào khớp với từ khóa</div>`;
        return;
    }

    filtered.forEach(sku => {
        const isSelected = wizSelectedMasterSKU && wizSelectedMasterSKU.sku === sku.sku;
        const row = document.createElement("div");
        row.className = "cp-wiz-row" + (isSelected ? " selected" : "");
        row.onclick = () => {
            selectWizMasterSKU(sku);
        };
        row.innerHTML = `
            <div style="flex: 1">
                <div style="font-weight:700;font-size:13px;color:var(--navy)">\${sku.name}</div>
                <div style="font-size:11px;color:rgba(16, 55, 92, 0.45);margin-top:2px;font-family:monospace">
                    SKU: \${sku.sku} | Phân loại: \${sku.category || "Chưa phân loại"}
                </div>
            </div>
            <div style="display:flex;align-items:center;gap:0.75rem">
                <span class="cp-status-pill active" style="font-size:10px">Đã duyệt</span>
                <div class="cp-wiz-row-radio">
                    <div class="cp-wiz-row-radio-inner"></div>
                </div>
            </div>
        `;
        listDiv.appendChild(row);
    });
}

function selectWizMasterSKU(sku) {
    wizSelectedMasterSKU = sku;
    renderWizMasterList();

    // Fill specifications details card
    document.getElementById("wizSpecName").textContent = sku.name;
    document.getElementById("wizSpecCode").textContent = sku.sku;
    document.getElementById("wizSpecWeight").textContent = sku.weight || "0.1 kg";
    document.getElementById("wizSpecDimensions").textContent = sku.dimensions || "10x10x10 cm";
    document.getElementById("wizMasterSpecCard").style.display = "block";

    // Set default covers in Step 3 based on name mapping
    const defaultImg = getDynamicCover(sku.name);
    wizChannelImages = {
        shopee: [defaultImg],
        lazada: [defaultImg],
        tiktok: [defaultImg]
    };
}

function renderWizStep1() {
    document.getElementById("wizStep1Content").style.display = "block";
    document.getElementById("wizStep2Content").style.display = "none";
    document.getElementById("wizStep3Content").style.display = "none";
    
    document.getElementById("wizMasterSpecCard").style.display = wizSelectedMasterSKU ? "block" : "none";
    renderWizMasterList();
}

function renderWizStep2() {
    document.getElementById("wizStep1Content").style.display = "none";
    document.getElementById("wizStep2Content").style.display = "block";
    document.getElementById("wizStep3Content").style.display = "none";

    document.getElementById("wizStep2ProductLabel").innerHTML = `
        <strong>\${wizSelectedMasterSKU.name}</strong> (SKU: \${wizSelectedMasterSKU.sku})
    `;

    // Highlight selected platform cards
    const chs = ["shopee", "lazada", "tiktok"];
    chs.forEach(ch => {
        const card = document.getElementById("pCard" + ch.charAt(0).toUpperCase() + ch.slice(1));
        card.classList.remove("selected");
        if (wizSelectedChannels.includes(ch)) {
            card.classList.add("selected");
        }
    });
}

function toggleWizChannel(channel) {
    if (wizSelectedChannels.includes(channel)) {
        wizSelectedChannels = wizSelectedChannels.filter(c => c !== channel);
    } else {
        wizSelectedChannels.push(channel);
    }
    renderWizStep2();
}

function renderWizStep3() {
    document.getElementById("wizStep1Content").style.display = "none";
    document.getElementById("wizStep2Content").style.display = "none";
    document.getElementById("wizStep3Content").style.display = "block";

    document.getElementById("wizStep3ProductLabel").innerHTML = `
        <strong>\${wizSelectedMasterSKU.name}</strong> (SKU: \${wizSelectedMasterSKU.sku})
    `;

    const container = document.getElementById("wizStep3ChannelsContainer");
    container.innerHTML = "";

    // Shopee section
    if (wizSelectedChannels.includes("shopee")) {
        const box = document.createElement("div");
        box.className = "cp-platform-config-box shopee";
        box.innerHTML = `
            <div class="cp-platform-config-hdr shopee">
                <span>CẤU HÌNH TRÊN KÊNH: SHOPEE</span>
                <span>API v2 Sandbox</span>
            </div>
            <div class="cp-platform-config-body">
                <div style="display:grid; grid-template-columns: repeat(3, 1fr); gap: 0.75rem">
                    <div class="cp-form-group">
                        <label class="cp-form-label">Danh mục Shopee *</label>
                        <select class="cp-input-text" style="padding:0.5rem" onchange="wizChannelConfigs.shopee.category = this.value">
                            <option \${wizChannelConfigs.shopee.category === 'Đồ dùng học tập > Vở & Sổ chép' ? 'selected' : ''}>Đồ dùng học tập &gt; Vở &amp; Sổ chép</option>
                            <option \${wizChannelConfigs.shopee.category === 'Dụng cụ viết > Bút các loại' ? 'selected' : ''}>Dụng cụ viết &gt; Bút các loại</option>
                            <option \${wizChannelConfigs.shopee.category === 'Phụ kiện cá nhân > Gương, lược' ? 'selected' : ''}>Phụ kiện cá nhân &gt; Gương, lược</option>
                            <option \${wizChannelConfigs.shopee.category === 'Thiết bị văn phòng > Tiện ích' ? 'selected' : ''}>Thiết bị văn phòng &gt; Tiện ích</option>
                        </select>
                    </div>
                    <div class="cp-form-group">
                        <label class="cp-form-label">Giá bán lẻ (Retail Price) *</label>
                        <input type="number" class="cp-input-text" style="padding:0.5rem; text-align:right" value="\${wizChannelConfigs.shopee.price}" oninput="wizChannelConfigs.shopee.price = Math.max(0, Number(this.value) || 0)" />
                    </div>
                    <div class="cp-form-group">
                        <label class="cp-form-label">Thương hiệu (Brand) *</label>
                        <input type="text" class="cp-input-text" style="padding:0.5rem; background:var(--alice); cursor:not-allowed" value="No Brand" disabled />
                    </div>
                </div>
                <div style="margin-top: 0.5rem" id="uploaderWizShopee">
                    <%-- Render image uploader dynamically --%>
                </div>
            </div>
        `;
        container.appendChild(box);
        renderWizUploader("shopee");
    }

    // Lazada section
    if (wizSelectedChannels.includes("lazada")) {
        const box = document.createElement("div");
        box.className = "cp-platform-config-box lazada";
        box.innerHTML = `
            <div class="cp-platform-config-hdr lazada">
                <span>CẤU HÌNH TRÊN KÊNH: LAZADA</span>
                <span>Open Platform API</span>
            </div>
            <div class="cp-platform-config-body">
                <div style="display:grid; grid-template-columns: repeat(2, 1fr); gap: 0.75rem">
                    <div class="cp-form-group">
                        <label class="cp-form-label">Danh mục Lazada *</label>
                        <select class="cp-input-text" style="padding:0.5rem" onchange="wizChannelConfigs.lazada.category = this.value">
                            <option \${wizChannelConfigs.lazada.category === 'Vở & Sổ chép > Học tập' ? 'selected' : ''}>Vở &amp; Sổ chép &gt; Học tập</option>
                            <option \${wizChannelConfigs.lazada.category === 'Dụng cụ viết > Vẽ & Mỹ thuật' ? 'selected' : ''}>Dụng cụ viết &gt; Vẽ &amp; Mỹ thuật</option>
                            <option \${wizChannelConfigs.lazada.category === 'Phụ kiện cá nhân > Tiện ích gia đình' ? 'selected' : ''}>Phụ kiện cá nhân &gt; Tiện ích gia đình</option>
                            <option \${wizChannelConfigs.lazada.category === 'Dụng cụ học tập & Tiện ích' ? 'selected' : ''}>Dụng cụ học tập &amp; Tiện ích</option>
                        </select>
                    </div>
                    <div class="cp-form-group">
                        <label class="cp-form-label">Giá bán lẻ (Retail Price) *</label>
                        <input type="number" class="cp-input-text" style="padding:0.5rem; text-align:right" value="\${wizChannelConfigs.lazada.price}" oninput="wizChannelConfigs.lazada.price = Math.max(0, Number(this.value) || 0)" />
                    </div>
                </div>
                <div style="margin-top: 0.5rem" id="uploaderWizLazada">
                    <%-- Render image uploader dynamically --%>
                </div>
            </div>
        `;
        container.appendChild(box);
        renderWizUploader("lazada");
    }

    // TikTok section
    if (wizSelectedChannels.includes("tiktok")) {
        const box = document.createElement("div");
        box.className = "cp-platform-config-box tiktok";
        box.innerHTML = `
            <div class="cp-platform-config-hdr tiktok">
                <span>CẤU HÌNH TRÊN KÊNH: TIKTOK SHOP</span>
                <span>TTS API Sandbox</span>
            </div>
            <div class="cp-platform-config-body">
                <div style="display:grid; grid-template-columns: repeat(2, 1fr); gap: 0.75rem">
                    <div class="cp-form-group">
                        <label class="cp-form-label">Danh mục TikTok Shop *</label>
                        <select class="cp-input-text" style="padding:0.5rem" onchange="wizChannelConfigs.tiktok.category = this.value">
                            <option \${wizChannelConfigs.tiktok.category === 'Văn phòng phẩm & Đồ dùng học tập' ? 'selected' : ''}>Văn phòng phẩm &amp; Đồ dùng học tập</option>
                            <option \${wizChannelConfigs.tiktok.category === 'Dụng cụ học sinh & Sáng tạo' ? 'selected' : ''}>Dụng cụ học sinh &amp; Sáng tạo</option>
                            <option \${wizChannelConfigs.tiktok.category === 'Phụ kiện cá nhân & Tiện ích' ? 'selected' : ''}>Phụ kiện cá nhân &amp; Tiện ích</option>
                            <option \${wizChannelConfigs.tiktok.category === 'Thiết bị văn phòng học tập' ? 'selected' : ''}>Thiết bị văn phòng học tập</option>
                        </select>
                    </div>
                    <div class="cp-form-group">
                        <label class="cp-form-label">Giá bán lẻ (Retail Price) *</label>
                        <input type="number" class="cp-input-text" style="padding:0.5rem; text-align:right" value="\${wizChannelConfigs.tiktok.price}" oninput="wizChannelConfigs.tiktok.price = Math.max(0, Number(this.value) || 0)" />
                    </div>
                </div>
                <div style="margin-top: 0.5rem" id="uploaderWizTiktok">
                    <%-- Render image uploader dynamically --%>
                </div>
            </div>
        `;
        container.appendChild(box);
        renderWizUploader("tiktok");
    }
}

function renderWizUploader(channel) {
    const parent = document.getElementById("uploaderWiz" + channel.charAt(0).toUpperCase() + channel.slice(1));
    if (!parent) return;

    const currentImgs = wizChannelImages[channel] || [];

    let gridHtml = `<div class="cp-upload-grid">`;
    currentImgs.forEach((img, idx) => {
        gridHtml += `
            <div class="cp-upload-box">
                <img src="\${img}" />
                <div class="cp-upload-box-trash" onclick="removeWizImage('\${channel}', \${idx})">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
                </div>
                \${idx === 0 ? '<span class="cp-upload-box-label">Ảnh bìa</span>' : ""}
            </div>
        `;
    });

    if (currentImgs.length < 5) {
        gridHtml += `
            <label class="cp-upload-btn-card">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12" /></svg>
                <span class="main">Thêm ảnh</span>
                <span class="sub">(Tối đa 5)</span>
                <input type="file" accept="image/*" multiple style="display:none" onchange="uploadWizImage('\${channel}', this.files)" />
            </label>
        `;
    }
    gridHtml += `</div>`;
    parent.innerHTML = `<label class="cp-form-label">Hình ảnh sản phẩm trên sàn (\${channel.toUpperCase()}) *</label>` + gridHtml;
}

function uploadWizImage(channel, files) {
    if (!files || files.length === 0) return;
    const currentList = wizChannelImages[channel] || [];

    Array.from(files).forEach(file => {
        if (currentList.length >= 5) return;
        const reader = new FileReader();
        reader.onload = function(e) {
            currentList.push(e.target.result);
            wizChannelImages[channel] = currentList;
            renderWizUploader(channel);
        };
        reader.readAsDataURL(file);
    });
}

function removeWizImage(channel, idx) {
    wizChannelImages[channel] = wizChannelImages[channel].filter((_, i) => i !== idx);
    renderWizUploader(channel);
}

function wizNavigate(dir) {
    if (dir === 1) {
        if (wizStep === 1) {
            if (!wizSelectedMasterSKU) {
                alert("Vui lòng chọn một Master SKU gốc để tiếp tục!");
                return;
            }
            wizStep = 2;
            renderWizStep2();
        } else if (wizStep === 2) {
            if (wizSelectedChannels.length === 0) {
                alert("Vui lòng chọn ít nhất một sàn thương mại điện tử để tiếp tục!");
                return;
            }
            wizStep = 3;
            renderWizStep3();
        } else {
            // Clicked Publish trigger sandbox sync logic
            executePublishSandbox();
        }
    } else {
        wizStep--;
        if (wizStep === 1) renderWizStep1();
        if (wizStep === 2) renderWizStep2();
    }
    renderWizProgress();
}

// ── SANDBOX SIMULATED API CALL SEQUENCE ──
function executePublishSandbox() {
    document.getElementById("sandboxProductTitle").textContent = wizSelectedMasterSKU.name;
    const overlay = document.getElementById("sandboxOverlay");
    overlay.classList.add("open");

    // Initialize loader visual states
    sandboxStepsList.forEach(s => {
        const row = document.getElementById(s.id);
        row.classList.remove("active", "done");
    });

    let currentStep = 0;
    
    function runNextStep() {
        if (currentStep > 0) {
            document.getElementById(sandboxStepsList[currentStep - 1].id).classList.remove("active");
            document.getElementById(sandboxStepsList[currentStep - 1].id).classList.add("done");
        }
        if (currentStep >= sandboxStepsList.length) {
            setTimeout(finalizePublishData, 450);
            return;
        }

        document.getElementById(sandboxStepsList[currentStep].id).classList.add("active");
        currentStep++;
        setTimeout(runNextStep, 550);
    }
    runNextStep();
}

function finalizePublishData() {
    const today = new Date().toISOString().slice(0, 10);
    
    // Many-to-many list update helper matching React's updateSKUMappings logic
    let storedMapList = [];
    const savedMapStr = localStorage.getItem("sku_mappings_v2");
    if (savedMapStr) {
        try { storedMapList = JSON.parse(savedMapStr); } catch(e) { storedMapList = []; }
    }

    let rawMappings = [];
    const savedRawStr = localStorage.getItem("sku_raw_mappings_v2");
    if (savedRawStr) {
        try { rawMappings = JSON.parse(savedRawStr); } catch(e) { rawMappings = []; }
    }

    // Loop through selected platforms
    wizSelectedChannels.forEach(ch => {
        const config = wizChannelConfigs[ch];
        const uniqueSuffix = Math.floor(100 + Math.random() * 900);
        const skuNoDash = wizSelectedMasterSKU.sku.replace(/-/g, "");
        const chSKU = `\${ch.toUpperCase()}-\${skuNoDash}-\${uniqueSuffix}`;
        const itemId = `\${ch.toUpperCase().toUpperCase().slice(0, 3)}-ITEM-\${Math.floor(100000 + Math.random() * 900000)}`;

        const defaultCover = getDynamicCover(wizSelectedMasterSKU.name);
        const imagesList = wizChannelImages[ch] && wizChannelImages[ch].length > 0
            ? wizChannelImages[ch]
            : [defaultCover];

        // 1. Add to Channel Products list
        channelProducts.push({
            id: "p_" + Date.now() + "_" + ch,
            masterSKU: wizSelectedMasterSKU.sku,
            channelSKU: chSKU,
            channel: ch,
            channelName: ch.charAt(0).toUpperCase() + ch.slice(1),
            channelColor: ch === "shopee" ? "#EE4D2D" : ch === "lazada" ? "#0F146D" : "#69C9D0",
            productName: wizSelectedMasterSKU.name,
            description: `\${wizSelectedMasterSKU.name} - Đồng bộ bán trên sàn \${ch.toUpperCase()}. Danh mục: \${config.category}`,
            images: imagesList,
            price: Number(config.price) || 150000,
            status: "active",
            stock: wizSelectedMasterSKU.qtyOnHand || 0,
            channelItemId: itemId,
            bufferStock: 0,
            syncStatus: "success"
        });

        // 2. Add to raw mappings v2 table (unlinked items helper in sku-mapping)
        rawMappings.push({
            id: "raw_" + Date.now() + "_" + ch,
            channelItemId: itemId,
            channelSKU: chSKU,
            channelItemName: wizSelectedMasterSKU.name,
            channel: ch.charAt(0).toUpperCase() + ch.slice(1),
            syncStatus: "success"
        });

        // 3. Update or append in sku_mappings_v2 (linked table)
        const chNameFormatted = ch.charAt(0).toUpperCase() + ch.slice(1);
        const existingIdx = storedMapList.findIndex(m => m.masterSKU === wizSelectedMasterSKU.sku);
        if (existingIdx > -1) {
            const chanMappings = storedMapList[existingIdx].channelMappings || [];
            const idx = chanMappings.findIndex(cm => cm.channel.toLowerCase() === ch.toLowerCase());
            if (idx > -1) {
                chanMappings[idx].channelSKU = chSKU;
                chanMappings[idx].status = "mapped";
            } else {
                const chColors = { Shopee: "#EE4D2D", TikTok: "#69C9D0", Lazada: "#0F146D", Website: "#EB8317" };
                chanMappings.push({
                    channel: chNameFormatted,
                    channelSKU: chSKU,
                    status: "mapped",
                    channelColor: chColors[chNameFormatted] || "#64748b"
                });
            }
            storedMapList[existingIdx].channelMappings = chanMappings;
            storedMapList[existingIdx].stock = wizSelectedMasterSKU.qtyOnHand || 0;
        } else {
            const defaultChans = [
                { channel: "Shopee", channelSKU: "", status: "unmapped", channelColor: "#EE4D2D" },
                { channel: "TikTok", channelSKU: "", status: "unmapped", channelColor: "#69C9D0" },
                { channel: "Lazada", channelSKU: "", status: "unmapped", channelColor: "#0F146D" },
                { channel: "Website", channelSKU: "", status: "unmapped", channelColor: "#EB8317" }
            ];
            const idx = defaultChans.findIndex(cm => cm.channel.toLowerCase() === ch.toLowerCase());
            if (idx > -1) {
                defaultChans[idx].channelSKU = chSKU;
                defaultChans[idx].status = "mapped";
            }
            storedMapList.push({
                id: String(storedMapList.length + 1),
                masterSKU: wizSelectedMasterSKU.sku,
                masterName: wizSelectedMasterSKU.name,
                channelMappings: defaultChans,
                stock: wizSelectedMasterSKU.qtyOnHand || 0
            });
        }

        // 4. Update pricing configuration retail/promo targets
        const existPriceIdx = pricingRecords.findIndex(r => r.sku === wizSelectedMasterSKU.sku);
        if (existPriceIdx > -1) {
            const recordPrices = pricingRecords[existPriceIdx].channelPrices;
            if (recordPrices[ch]) {
                recordPrices[ch].retailPrice = Number(config.price) || 150000;
                recordPrices[ch].promoPrice = Math.round((Number(config.price) || 150000) * 0.95);
                recordPrices[ch].effectiveDate = today;
            }
        }
    });

    localStorage.setItem("sku_mappings_v2", JSON.stringify(storedMapList));
    localStorage.setItem("sku_raw_mappings_v2", JSON.stringify(rawMappings));

    saveData();
    closePublishWizard();
    renderProductsTab();
    showToast("Đã publish đồng bộ sản phẩm lên các sàn Sandbox thành công!");
}

// ── TAB 1 MODAL: EDIT PRODUCT DETAILS ───────────────────────────────
function openEditModal(productId) {
    const p = channelProducts.find(item => item.id === productId);
    if (!p) return;

    editTargetProductId = productId;
    editImagesList = p.images ? [...p.images] : [];

    document.getElementById("editProductMasterName").textContent = p.productName;
    document.getElementById("editProductMasterSKU").textContent = p.masterSKU;
    document.getElementById("editProductPrice").value = p.price;
    document.getElementById("editProductDesc").value = p.description || "";

    document.getElementById("editProductOverlay").classList.add("open");
    renderEditUploader();
}

function closeEditModal() {
    document.getElementById("editProductOverlay").classList.remove("open");
    editTargetProductId = null;
    editImagesList = [];
}

function renderEditUploader() {
    const parent = document.getElementById("editImagesGrid");
    if (!parent) return;

    let gridHtml = "";
    editImagesList.forEach((img, idx) => {
        gridHtml += `
            <div class="cp-upload-box">
                <img src="\${img}" />
                <div class="cp-upload-box-trash" onclick="removeEditImage(\${idx})">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
                </div>
                \${idx === 0 ? '<span class="cp-upload-box-label">Ảnh bìa</span>' : ""}
            </div>
        `;
    });

    if (editImagesList.length < 5) {
        gridHtml += `
            <label class="cp-upload-btn-card">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12" /></svg>
                <span class="main">Thêm ảnh</span>
                <span class="sub">(Tối đa 5)</span>
                <input type="file" accept="image/*" multiple style="display:none" onchange="uploadEditImage(this.files)" />
            </label>
        `;
    }
    parent.innerHTML = gridHtml;
}

function uploadEditImage(files) {
    if (!files || files.length === 0) return;
    Array.from(files).forEach(file => {
        if (editImagesList.length >= 5) return;
        const reader = new FileReader();
        reader.onload = function(e) {
            editImagesList.push(e.target.result);
            renderEditUploader();
        };
        reader.readAsDataURL(file);
    });
}

function removeEditImage(idx) {
    editImagesList = editImagesList.filter((_, i) => i !== idx);
    renderEditUploader();
}

function submitEditProduct() {
    const price = Number(document.getElementById("editProductPrice").value) || 0;
    const desc = document.getElementById("editProductDesc").value;

    if (editImagesList.length === 0) {
        alert("Vui lòng tải lên ít nhất 1 hình ảnh sản phẩm!");
        return;
    }

    channelProducts = channelProducts.map(p => {
        if (p.id === editTargetProductId) {
            return {
                ...p,
                price: price,
                description: desc,
                images: editImagesList
            };
        }
        return p;
    });

    // Also sync price to pricing configuration channel price
    const prod = channelProducts.find(item => item.id === editTargetProductId);
    if (prod) {
        const today = new Date().toISOString().slice(0, 10);
        pricingRecords = pricingRecords.map(r => {
            if (r.sku === prod.masterSKU) {
                const updatedChannelPrices = { ...r.channelPrices };
                if (updatedChannelPrices[prod.channel]) {
                    updatedChannelPrices[prod.channel].retailPrice = price;
                    updatedChannelPrices[prod.channel].effectiveDate = today;
                }
                return { ...r, channelPrices: updatedChannelPrices };
            }
            return r;
        });
    }

    saveData();
    closeEditModal();
    renderProductsTab();
    showToast("Cập nhật thông tin sản phẩm kênh thành công!");
}
</script>
