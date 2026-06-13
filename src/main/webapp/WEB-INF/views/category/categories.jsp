<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="com.wms.dao.CategoryDAO" %>
<%@ page import="com.wms.model.Category" %>
<%@ page import="java.util.List" %>
<%
    CategoryDAO categoryDAO = new CategoryDAO();
    List<Category> categoryList = categoryDAO.findAll();
    request.setAttribute("categories", categoryList);

    String categoryMessage = (String) session.getAttribute("categoryMessage");
    Boolean categorySuccess = (Boolean) session.getAttribute("categorySuccess");
    Boolean categoryDeactivated = (Boolean) session.getAttribute("categoryDeactivated");
    if (categoryMessage != null) {
        session.removeAttribute("categoryMessage");
        session.removeAttribute("categorySuccess");
        session.removeAttribute("categoryDeactivated");
    }
%>

<style>
    /* ─── Toast Notifications ─── */
    .toast-container {
        position: fixed;
        top: 24px;
        right: 24px;
        z-index: 9999;
        display: flex;
        flex-direction: column;
        gap: 10px;
        pointer-events: none;
    }

    .toast {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 12px 18px;
        border-radius: var(--radius-btn);
        font-size: 13px;
        font-weight: 600;
        min-width: 280px;
        max-width: 380px;
        pointer-events: auto;
        animation: toastSlideIn 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    }

    .toast.toast-success {
        background: #ECFDF5;
        border: 1px solid #A7F3D0;
        color: #065F46;
    }

    .toast.toast-error {
        background: #FEF2F2;
        border: 1px solid #FECACA;
        color: #991B1B;
    }

    .toast.toast-info {
        background: #EFF6FF;
        border: 1px solid #BFDBFE;
        color: #1E40AF;
    }

    .toast svg {
        width: 18px;
        height: 18px;
        flex-shrink: 0;
    }

    .toast.toast-success svg { color: #10B981; }
    .toast.toast-error svg { color: #EF4444; }
    .toast.toast-info svg { color: #3B82F6; }

    @keyframes toastSlideIn {
        from { transform: translateX(100%); opacity: 0; }
        to   { transform: translateX(0);    opacity: 1; }
    }

    @keyframes toastSlideOut {
        from { transform: translateX(0);    opacity: 1; }
        to   { transform: translateX(110%); opacity: 0; }
    }

    /* ─── Modal Overlay ─── */
    .modal-overlay {
        position: fixed;
        inset: 0;
        background: rgba(10, 25, 47, 0.45);
        z-index: 1000;
        display: flex;
        align-items: center;
        justify-content: center;
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
        border-radius: var(--radius-card);
        width: 100%;
        max-width: 480px;
        max-height: 90vh;
        overflow-y: auto;
        box-shadow: 0 20px 60px rgba(10, 25, 47, 0.2);
        transform: scale(0.92) translateY(12px);
        transition: transform 0.25s cubic-bezier(0.16, 1, 0.3, 1);
    }

    .modal-overlay.active .modal-box {
        transform: scale(1) translateY(0);
    }

    .modal-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 20px 24px 16px;
        border-bottom: 1px solid var(--border);
    }

    .modal-header h3 {
        color: var(--navy);
        font-size: 16px;
        font-weight: 700;
        display: flex;
        align-items: center;
        gap: 8px;
        margin: 0;
    }

    .modal-header h3 svg {
        width: 20px;
        height: 20px;
        color: var(--orange);
    }

    .modal-close-btn {
        width: 32px;
        height: 32px;
        border: 1px solid var(--border);
        background: #fff;
        border-radius: 6px;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        color: rgba(16, 55, 92, 0.5);
        transition: background 0.15s, color 0.15s;
    }

    .modal-close-btn:hover {
        background: var(--alice);
        color: var(--navy);
    }

    .modal-close-btn svg {
        width: 16px;
        height: 16px;
    }

    .modal-body {
        padding: 20px 24px;
    }

    .modal-footer {
        display: flex;
        justify-content: flex-end;
        gap: 10px;
        padding: 16px 24px 20px;
        border-top: 1px solid var(--border);
    }

    .btn-modal-cancel {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 9px 18px;
        background: #fff;
        border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
        color: var(--navy);
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.15s;
        font-family: inherit;
    }

    .btn-modal-cancel:hover {
        background: var(--alice);
    }

    .btn-modal-submit {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 9px 20px;
        background: var(--navy);
        border: none;
        border-radius: calc(var(--radius-btn) - 2px);
        color: #fff;
        font-size: 13px;
        font-weight: 700;
        cursor: pointer;
        transition: background 0.15s;
        font-family: inherit;
    }

    .btn-modal-submit:hover {
        background: #174e80;
    }

    .btn-modal-submit:disabled {
        opacity: 0.6;
        cursor: not-allowed;
    }

    .btn-modal-submit.danger {
        background: #b91c1c;
    }

    .btn-modal-submit.danger:hover {
        background: #991b1b;
    }

    /* ─── Grid & Column Layouts ─── */
    /* ─── Grid & Column Layouts ─── */
    .cat-layout-grid {
        display: grid;
        grid-template-columns: repeat(12, 1fr);
        gap: 24px;
        align-items: start;
    }

    .cat-panel-full {
        grid-column: span 12;
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 20px;
        box-shadow: 0 4px 20px rgba(16, 55, 92, 0.03);
    }

    .panel-hdr {
        display: flex;
        align-items: center;
        justify-content: space-between;
        border-bottom: 1px solid var(--border);
        padding-bottom: 16px;
        margin-bottom: 16px;
    }

    .panel-title {
        color: var(--navy);
        font-size: 15px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .panel-title svg {
        width: 20px;
        height: 20px;
    }

    .panel-subtitle {
        color: rgba(16, 55, 92, 0.50);
        font-size: 11.5px;
        margin-top: 2px;
        line-height: 1.4;
    }

    /* ─── Tree View Styles ─── */
    .tree-container {
        background: rgba(240, 244, 250, 0.25);
        border: 1px solid rgba(229, 234, 243, 0.8);
        border-radius: 8px;
        padding: 24px;
        min-height: 450px;
        max-height: 750px;
        overflow-y: auto;
    }

    .tree-children-container {
        padding-left: 28px;
        margin-top: 0;
        display: flex;
        flex-direction: column;
        gap: 8px;
        position: relative;
    }

    .tree-node-wrapper {
        position: relative;
    }

    /* Horizontal connector line for children */
    .tree-children-container > .tree-node-wrapper::before {
        content: '';
        position: absolute;
        top: 19px;
        left: -10px;
        width: 18px;
        height: 1px;
        border-top: 1px dashed rgba(16, 55, 92, 0.18);
        z-index: 1;
    }

    /* Vertical connector line for children */
    .tree-children-container > .tree-node-wrapper::after {
        content: '';
        position: absolute;
        left: -10px;
        top: -19px;
        width: 1px;
        height: calc(100% + 19px);
        border-left: 1px dashed rgba(16, 55, 92, 0.18);
    }

    /* Stop vertical line at the horizontal line of the last child */
    .tree-children-container > .tree-node-wrapper:last-child::after {
        height: 38px;
    }

    /* ─── Inline Interactive Forms & Inputs ─── */
    .inline-edit-form, .inline-create-form {
        display: flex;
        align-items: center;
        gap: 8px;
        width: 100%;
        background: #f8fafc;
        border: 1px solid var(--border);
        border-radius: 6px;
        padding: 6px 12px 6px 8px;
        animation: fadeIn 0.2s ease;
    }

    .inline-input {
        background: #ffffff !important;
        border: 1px solid var(--border) !important;
        border-radius: 4px !important;
        padding: 6px 12px !important;
        font-size: 13px !important;
        color: var(--navy) !important;
        outline: none !important;
        transition: border-color 0.15s, box-shadow 0.15s !important;
    }

    .inline-input:focus {
        border-color: var(--navy) !important;
        box-shadow: 0 0 0 2px rgba(16, 55, 92, 0.1) !important;
    }

    .inline-input.name-input {
        width: 220px !important;
        font-weight: 600;
    }

    .inline-input.desc-input {
        flex-grow: 1;
        min-width: 200px;
    }

    .inline-input.parent-select {
        width: 220px !important;
        height: 34px !important;
        cursor: pointer;
        padding: 4px 12px !important;
    }

    /* ─── Locked code input (immutable) ─── */
    .locked-code {
        background: #f3f4f6 !important;
        color: #6b7280 !important;
        cursor: not-allowed;
        border: 1px dashed #9ca3af !important;
    }

    .btn-action-sm-inline {
        width: 30px;
        height: 30px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 4px;
        border: 1px solid var(--border);
        cursor: pointer;
        transition: all 0.15s;
        background: #fff;
        flex-shrink: 0;
    }

    .btn-action-sm-inline.save {
        color: #059669;
        border-color: #A7F3D0;
        background: #ECFDF5;
    }

    .btn-action-sm-inline.save:hover {
        background: #D1FAE5;
        border-color: #34D399;
    }

    .btn-action-sm-inline.cancel {
        color: rgba(16, 55, 92, 0.6);
        border-color: var(--border);
        background: #fff;
    }

    .btn-action-sm-inline.cancel:hover {
        background: var(--alice);
        color: var(--navy);
    }

    .btn-inline-danger-confirm {
        padding: 5px 12px;
        font-size: 12px;
        font-weight: 700;
        border-radius: 4px;
        background: #DC2626;
        color: #fff;
        border: 1px solid #DC2626;
        cursor: pointer;
        transition: background 0.15s;
    }

    .btn-inline-danger-confirm:hover {
        background: #B91C1C;
    }

    .btn-inline-cancel {
        padding: 5px 12px;
        font-size: 12px;
        font-weight: 600;
        border-radius: 4px;
        background: #fff;
        color: rgba(16, 55, 92, 0.7);
        border: 1px solid var(--border);
        cursor: pointer;
        transition: background 0.15s;
    }

    .btn-inline-cancel:hover {
        background: var(--alice);
    }

    .new-node-row {
        background: #f8fafc;
        border: 1px dashed rgba(16, 55, 92, 0.3) !important;
        margin-bottom: 8px;
    }

    .delete-confirm-row {
        border-color: #FCA5A5 !important;
        background: #FEF2F2 !important;
        animation: fadeIn 0.2s ease;
    }

    .tree-row {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 6px 12px 6px 8px;
        background: transparent;
        border: none;
        border-radius: 4px;
        transition: background 0.15s, color 0.15s;
        min-height: 38px;
    }

    .tree-row:hover {
        background: rgba(16, 55, 92, 0.05);
    }

    .tree-row.root-row {
        padding: 8px 12px 8px 8px;
        box-shadow: none;
    }

    .btn-toggle-chevron {
        width: 20px;
        height: 20px;
        border-radius: 4px;
        border: none;
        background: none;
        color: rgba(16, 55, 92, 0.40);
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: color 0.15s, background 0.15s;
    }

    .btn-toggle-chevron:hover {
        color: rgba(16, 55, 92, 0.70);
        background: rgba(16, 55, 92, 0.05);
    }

    .btn-toggle-chevron svg {
        width: 16px;
        height: 16px;
        transition: transform 0.2s;
    }

    .bullet-dot {
        width: 20px;
        height: 20px;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .bullet-dot span {
        width: 6px;
        height: 6px;
        border-radius: 50%;
        background: rgba(16, 55, 92, 0.30);
    }

    .folder-icon {
        width: 16px;
        height: 16px;
        flex-shrink: 0;
    }

    .folder-icon.level-1 {
        color: var(--orange);
        width: 20px;
        height: 20px;
    }

    .folder-icon.level-2 { color: #EB8317; }
    .folder-icon.level-3 { color: rgba(16, 55, 92, 0.40); }

    .node-title-wrap {
        display: flex;
        align-items: center;
        gap: 8px;
        min-width: 0;
    }

    .node-name {
        font-size: 13px;
        font-weight: 600;
        color: var(--navy);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .root-row .node-name {
        font-size: 14px;
        font-weight: 700;
    }



    .node-actions {
        margin-left: auto;
        display: flex;
        align-items: center;
        gap: 6px;
        opacity: 0;
        transition: opacity 0.15s ease-in-out;
    }

    .tree-node-wrapper:hover>.tree-row .node-actions {
        opacity: 1;
    }

    .btn-action-sm {
        width: 28px;
        height: 28px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: transparent;
        border: none;
        border-radius: 4px;
        color: rgba(16, 55, 92, 0.50);
        cursor: pointer;
        transition: background 0.15s, color 0.15s;
    }

    .btn-action-sm:hover {
        color: var(--navy);
        background: rgba(16, 55, 92, 0.08);
    }

    .btn-action-sm.del:hover {
        color: #dc2626;
        background: #fef2f2;
    }

    .btn-action-sm svg {
        width: 14px;
        height: 14px;
    }

    /* ─── Forms & Controls ─── */
    .form-group {
        display: flex;
        flex-direction: column;
        gap: 6px;
        margin-bottom: 16px;
    }

    .form-label {
        color: rgba(16, 55, 92, 0.70);
        font-size: 11.5px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }

    .form-input {
        width: 100%;
        padding: 10px 14px;
        border: 1px solid var(--border);
        background: #fff;
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

    .select-wrap {
        position: relative;
        width: 100%;
    }

    .select-wrap select {
        appearance: none;
        padding-right: 36px;
        cursor: pointer;
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

    .level-preview {
        background: var(--alice);
        border: 1px solid var(--border);
        padding: 10px 14px;
        font-size: 13px;
        font-weight: 700;
        color: var(--navy);
        display: flex;
        align-items: center;
        gap: 8px;
        user-select: none;
    }

    .level-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: var(--orange);
    }

    .form-actions {
        display: flex;
        justify-content: flex-end;
        gap: 10px;
        padding-top: 16px;
        border-top: 1px solid var(--border);
        margin-top: 16px;
    }

    /* ─── Empty state & Banners ─── */
    .empty-state-card {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 64px 20px;
        text-align: center;
    }

    .empty-state-icon {
        width: 64px;
        height: 64px;
        background: var(--alice);
        border: 1px solid var(--border);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 16px;
        color: rgba(16, 55, 92, 0.30);
    }

    .empty-state-icon svg {
        width: 28px;
        height: 28px;
    }

    .empty-state-title {
        color: var(--navy);
        font-weight: 700;
        font-size: 14px;
        margin-bottom: 4px;
    }

    .empty-state-desc {
        color: rgba(16, 55, 92, 0.50);
        font-size: 12px;
        max-width: 280px;
        line-height: 1.5;
    }

    .btn-primary-sm {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 8px 12px;
        background: var(--navy);
        border: none;
        border-radius: calc(var(--radius-btn) - 2px);
        color: #fff;
        font-size: 12px;
        font-weight: 700;
        cursor: pointer;
        transition: background 0.15s;
    }

    .btn-primary-sm:hover { background: #174e80; }
    .btn-primary-sm svg { width: 16px; height: 16px; }

    .btn-outline-sm {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 8px 16px;
        background: #fff;
        border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
        color: var(--navy);
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.15s;
    }

    .btn-outline-sm:hover { background: var(--alice); }

    .btn-navy-action {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 8px 20px;
        background: var(--navy);
        border: none;
        border-radius: calc(var(--radius-btn) - 2px);
        color: #fff;
        font-size: 13px;
        font-weight: 700;
        cursor: pointer;
        transition: background 0.15s;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    }

    .btn-navy-action:hover { background: #174e80; }
    .btn-navy-action.danger { background: #DC2626; }
    .btn-navy-action.danger:hover { background: #B91C1C; }
    .btn-navy-action svg { width: 16px; height: 16px; }

    .feedback-banner {
        margin-top: 16px;
        padding: 12px 16px;
        background: #ECFDF5;
        border: 1px solid #A7F3D0;
        color: #065F46;
        font-size: 12px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 8px;
        border-radius: 4px;
        animation: slideUp 0.2s ease;
    }

    .feedback-banner svg {
        width: 16px;
        height: 16px;
        color: #10B981;
        flex-shrink: 0;
    }

    @keyframes slideUp {
        from { transform: translateY(8px); opacity: 0; }
        to   { transform: translateY(0);   opacity: 1; }
    }

    .animate-fadeIn { animation: fadeIn 0.25s ease; }

    @keyframes fadeIn {
        from { opacity: 0; }
        to   { opacity: 1; }
    }
</style>

<%-- Toast container (populated by JS) --%>
<div id="toastContainer" class="toast-container"></div>

<div class="cat-layout-grid">
    <!-- ══ FULL PANEL: TREE VIEW & INLINE OPERATIONS ════════════════════════ -->
    <div class="cat-panel-full">
        <div class="panel-hdr">
            <div>
                <h3 class="panel-title">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="3" width="7" height="9" rx="1" />
                        <rect x="14" y="3" width="7" height="5" rx="1" />
                        <rect x="14" y="12" width="7" height="9" rx="1" />
                        <rect x="3" y="16" width="7" height="5" rx="1" />
                    </svg>
                    Cơ cấu cây phân cấp danh mục sản phẩm
                </h3>
            </div>
            <button class="btn-primary-sm" id="btnRootCategoryTrigger">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                Thêm danh mục
            </button>
        </div>
        <div class="tree-container" id="treeContainer"></div>
        <div id="feedbackBannerWrap"></div>
    </div>
</div>

<!-- ══ JAVASCRIPT STATE & LOGIC ═════════════════════════════ -->
<script>
(function () {
    'use strict';

    /* ─── Server-side data ─────────────────────────────────── */
    var serverCategories = [];
    try {
        var rawCategories = '<c:out value="${categoriesJson}" escapeXml="false"/>';
        if (rawCategories && rawCategories.trim() && rawCategories.indexOf('categoriesJson') === -1) {
            serverCategories = JSON.parse(rawCategories);
        }
    } catch (e) {
        console.error('categories: Failed to parse categoriesJson', e);
    }

    var categories = serverCategories.slice();

    var expandedNodes = {};
    try {
        var saved = sessionStorage.getItem('wms_expanded_categories');
        if (saved) {
            expandedNodes = JSON.parse(saved);
        }
    } catch (e) {}

    function saveExpandedNodes() {
        try {
            sessionStorage.setItem('wms_expanded_categories', JSON.stringify(expandedNodes));
        } catch (e) {}
    }

    var activeForm = {
        mode: 'empty', // 'empty' | 'create' | 'edit' | 'delete'
        selectedCategory: null,
        parentId: null
    };

    /* ─── Toast notification system ─────────────────────────── */
    function showToast(message, type) {
        type = type || 'info';
        var icons = {
            success: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="9 12 12 15 16 10"/></svg>',
            error:   '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>',
            info:    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>'
        };

        var toast = document.createElement('div');
        toast.className = 'toast toast-' + type;
        toast.innerHTML = icons[type] + '<span>' + escapeHtml(message) + '</span>';

        var container = document.getElementById('toastContainer');
        container.appendChild(toast);

        setTimeout(function () {
            toast.style.animation = 'toastSlideOut 0.3s ease forwards';
            setTimeout(function () {
                if (toast.parentNode) toast.parentNode.removeChild(toast);
            }, 300);
        }, 3500);
    }

    /* Show server-side flash message on page load */
    <c:if test="${not empty categoryMessage}">
        <c:choose>
            <c:when test="${categoryDeactivated == true}">
        showToast("${categoryMessage}", "info");
            </c:when>
            <c:otherwise>
        showToast("${categoryMessage}", "${categorySuccess == true ? 'success' : 'error'}");
            </c:otherwise>
        </c:choose>
    </c:if>
    /* ─── Helper Functions for Hierarchy and Levels ─────────── */
    function getCategoryLevel(catId) {
        if (!catId) return 0;
        var cat = categories.find(function (c) { return c.id === catId; });
        if (!cat) return 0;
        if (cat.parentId === null) return 1;
        return 1 + getCategoryLevel(cat.parentId);
    }

    function getSubtreeDepth(catId) {
        var children = categories.filter(function (c) { return c.parentId === catId; });
        if (children.length === 0) return 0;
        var maxSubDepth = 0;
        children.forEach(function (child) {
            var d = getSubtreeDepth(child.id);
            if (d > maxSubDepth) maxSubDepth = d;
        });
        return 1 + maxSubDepth;
    }

    function isDescendant(parentId, childId) {
        if (!childId) return false;
        var child = categories.find(function (c) { return c.id === childId; });
        if (!child || child.parentId === null) return false;
        if (child.parentId === parentId) return true;
        return isDescendant(parentId, child.parentId);
    }

    /* ─── DOM Elements ───────────────────────────────────────── */
    var treeContainer = document.getElementById('treeContainer');
    var feedbackBanner = document.getElementById('feedbackBannerWrap');
    var btnAddRoot = document.getElementById('btnRootCategoryTrigger');

    /* ─── Handlers ───────────────────────────────────────────── */
    if (btnAddRoot) {
        btnAddRoot.addEventListener('click', function () {
            activeForm.mode = 'create';
            activeForm.selectedId = null;
            activeForm.parentId = null;
            renderTree();
        });
    }

    /* ─── UI Rendering ───────────────────────────────────────── */

    /* 1. Left Tree Column */
    function renderTree() {
        var roots = categories.filter(function (c) { return c.parentId === null; });
        var html = '';

        if (activeForm.mode === 'create' && activeForm.parentId === null) {
            html += buildInlineCreateFormHtml(null);
        }

        if (roots.length === 0 && html === '') {
            treeContainer.innerHTML =
                '<div class="empty-state-card">' +
                '<div class="empty-state-icon">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>' +
                '</div>' +
                '<h4 class="empty-state-title">Chưa có danh mục nào</h4>' +
                '<p class="empty-state-desc">Danh mục sản phẩm của bạn hiện đang trống. Hãy nhấn nút "+ Thêm danh mục" ở góc trên để tạo danh mục đầu tiên.</p>' +
                '</div>';
            return;
        }

        html += roots.map(function (root) {
            return buildNodeHtml(root, 1);
        }).join('');

        treeContainer.innerHTML = html;
    }

    function buildInlineCreateFormHtml(parentId) {
        var idSuffix = parentId === null ? 'root' : parentId;
        var rowClass = parentId === null ? 'inline-create-form' : 'inline-create-form new-node-row';
        var isRoot = parentId === null;
        
        return '<div class="tree-node-wrapper">' +
            '<form class="' + rowClass + '" onsubmit="WMS_SUBMIT_INLINE_CREATE(event, ' + (parentId === null ? 'null' : parentId) + ')">' +
            (parentId === null ? '' : '<div class="bullet-dot" style="opacity: 0; flex-shrink: 0;"></div>') +
            '<svg class="folder-icon" style="color: #cbd5e1; flex-shrink: 0;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>' +
            '<input type="text" class="inline-input" style="width: 70px; font-weight: 700; text-transform: uppercase;" id="createCode_' + idSuffix + '" maxlength="4" placeholder="Mã..." required title="Mã định danh 3-4 ký tự (VD: EYE)" oninput="this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, \'\')" />' +
            '<input type="text" class="inline-input name-input" id="createName_' + idSuffix + '" required placeholder="Tên danh mục mới..." />' +
            '<input type="text" class="inline-input desc-input" id="createDesc_' + idSuffix + '" placeholder="Mô tả..." />' +
            '<button type="submit" class="btn-action-sm-inline save" title="Lưu danh mục">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>' +
            '</button>' +
            '<button type="button" class="btn-action-sm-inline cancel" onclick="WMS_CANCEL_ACTION()" title="Hủy bỏ">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>' +
            '</button>' +
            '</form>' +
            '</div>';
    }

    function buildNodeHtml(node, level) {
        var children = categories.filter(function (c) { return c.parentId === node.id; });
        var hasChildren = children.length > 0;
        var isExpanded = !!expandedNodes[node.id];

        var toggleBtn;
        if (hasChildren) {
            var chevronSvg = isExpanded ?
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>' :
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>';
            toggleBtn = '<button class="btn-toggle-chevron" onclick="WMS_TOGGLE_NODE(' + node.id + ')">' + chevronSvg + '</button>';
        } else {
            toggleBtn = '<div class="bullet-dot"><span></span></div>';
        }

        var folderSvg = '';
        if (level >= 3) {
            folderSvg = '<svg class="folder-icon level-3" style="color: rgba(16, 55, 92, 0.40);" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>';
        } else {
            var color = (level === 1) ? 'var(--orange)' : '#EB8317';
            if (hasChildren && isExpanded) {
                folderSvg = '<svg class="folder-icon level-' + level + '" style="color: ' + color + '" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/><path d="M2 10h20"/></svg>';
            } else {
                folderSvg = '<svg class="folder-icon level-' + level + '" style="color: ' + color + '" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>';
            }
        }

        var addSubBtn = '';
        if (level < 3) {
            addSubBtn = '<button class="btn-action-sm" onclick="WMS_ADD_SUB(' + node.id + ')" title="Thêm thể loại con">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>' +
                '</button>';
        }

        var rowClass = level === 1 ? 'tree-row root-row' : 'tree-row';
        var badgeClass = 'node-level-badge level-' + (level > 2 ? '3' : level);

        var childrenHtml = '';
        if (isExpanded) {
            var childrenListHtml = '';
            
            if (activeForm.mode === 'create' && activeForm.parentId === node.id) {
                childrenListHtml += buildInlineCreateFormHtml(node.id);
            }
            
            if (hasChildren) {
                childrenListHtml += children.map(function (c) { return buildNodeHtml(c, level + 1); }).join('');
            }
            
            if (childrenListHtml !== '') {
                childrenHtml = '<div class="tree-children-container">' + childrenListHtml + '</div>';
            }
        }

        // Inline Delete Confirmation Row
        if (activeForm.mode === 'delete' && activeForm.selectedId === node.id) { 
            var deleteMsg = 'Xác nhận xóa danh mục <strong>' + escapeHtml(node.name) + '</strong>';
            if (node.isImmutable) {
                deleteMsg += '<br><span style="color: #dc2626; font-weight: 500;">Danh mục đã có sản phẩm. Chỉ có thể ngừng hoạt động.</span>';
            }
            return '<div class="tree-node-wrapper">' +
                '<div class="tree-row delete-confirm-row">' +
                '<svg style="width: 18px; height: 18px; color: #dc2626; flex-shrink: 0;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>' +
                '<span style="font-size: 13px; color: #991b1b; font-weight: 600;">' + deleteMsg + '</span>' +
                '<div style="margin-left: auto; display: flex; gap: 8px;">' +
                (node.isImmutable 
                    ? '<button type="button" class="btn-inline-danger-confirm" style="background: #f59e0b;" onclick="WMS_DEACTIVATE(' + node.id + ')">Ngung hoat dong</button>'
                    : '<button type="button" class="btn-inline-danger-confirm" onclick="WMS_CONFIRM_DELETE(' + node.id + ')">Xoa</button>') +
                '<button type="button" class="btn-inline-cancel" onclick="WMS_CANCEL_ACTION()">Huy</button>' +
                '</div>' +
                '</div>' +
                childrenHtml +
                '</div>';
        }

        // Inline Edit Form Row
        if (activeForm.mode === 'edit' && activeForm.selectedId === node.id) {
            var parentSelectOptions = buildParentSelectOptions(node.id, node.parentId);
            var codeReadonly = node.isImmutable ? 'readonly disabled' : '';
            var codeClass = node.isImmutable ? 'inline-input locked-code' : 'inline-input';
            
            return '<div class="tree-node-wrapper">' +
                '<form class="inline-edit-form" onsubmit="WMS_SUBMIT_INLINE_EDIT(event, ' + node.id + ')">' +
                toggleBtn +
                folderSvg +
                '<input type="text" class="' + codeClass + '" style="width: 70px; font-weight: 700; text-transform: uppercase;" id="editCode_' + node.id + '" value="' + escapeHtml(node.code) + '" ' + codeReadonly + ' placeholder="Ma..." title="' + (node.isImmutable ? 'Ma da bi khoa' : 'Ma dinh danh 3-4 ky tu') + '" ' + (node.isImmutable ? '' : 'oninput="this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, \'\')"') + ' />' +
                '<input type="text" class="inline-input name-input" id="editName_' + node.id + '" value="' + escapeHtml(node.name) + '" required placeholder="Ten danh muc..." />' +
                '<input type="text" class="inline-input desc-input" id="editDesc_' + node.id + '" value="' + escapeHtml(node.description || '') + '" placeholder="Mo ta danh muc..." />' +
                '<div style="display: flex; align-items: center; gap: 8px;">' +
                '<span style="font-size: 11.5px; color: rgba(16, 55, 92, 0.6); font-weight: 600; white-space: nowrap;">Cha:</span>' +
                '<select class="inline-input parent-select" id="editParent_' + node.id + '">' + parentSelectOptions + '</select>' +
                '</div>' +
                '<button type="submit" class="btn-action-sm-inline save" title="Luu thay doi">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>' +
                '</button>' +
                '<button type="button" class="btn-action-sm-inline cancel" onclick="WMS_CANCEL_ACTION()" title="Huy bo">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>' +
                '</button>' +
                '</form>' +
                childrenHtml +
                '</div>';
        }

        // Standard View Row
        var descSpan = node.description ? '<span style="font-size: 11.5px; color: rgba(16, 55, 92, 0.45); margin-left: 8px; font-weight: normal;">— ' + escapeHtml(node.description) + '</span>' : '';
        var codeBadge = '<span class="cat-code-badge" style="font-size: 11px; font-weight: 700; color: var(--orange); background: rgba(16, 55, 92, 0.08); padding: 2px 6px; border-radius: 4px; margin-left: 8px;">' + escapeHtml(node.code) + '</span>';
        var statusBadge = node.active ? '' : '<span style="font-size: 10px; font-weight: 600; color: #dc2626; background: #fef2f2; padding: 2px 6px; border-radius: 4px; margin-left: 6px;">Ngung</span>';
        
        return '<div class="tree-node-wrapper">' +
            '<div class="' + rowClass + '">' +
            toggleBtn +
            folderSvg +
            '<div class="node-title-wrap">' +
            '<span class="node-name">' + escapeHtml(node.name) + '</span>' +
            codeBadge +
            statusBadge +
            descSpan +
            '</div>' +
            '<div class="node-actions">' +
            addSubBtn +
            '<button class="btn-action-sm" onclick="WMS_EDIT_NODE(' + node.id + ')" title="Chinh sua">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>' +
            '</button>' +
            '<button class="btn-action-sm del" onclick="WMS_DEL_NODE(' + node.id + ')" title="Xoa danh muc">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>' +
            '</button>' +
            '</div>' +
            '</div>' +
            childrenHtml +
            '</div>';
    }

    function buildParentSelectOptions(nodeId, parentId) {
        var parentOptions = '<option value="none">Không có (Cấp cao nhất)</option>';
        categories.forEach(function (p) {
            if (nodeId) {
                if (p.id === nodeId) return;
                if (isDescendant(nodeId, p.id)) return;
                if (getCategoryLevel(p.id) + 1 + getSubtreeDepth(nodeId) > 3) return;
            } else {
                if (getCategoryLevel(p.id) >= 3) return;
            }

            var sel = (parentId !== null && parentId == p.id) ? 'selected' : '';
            parentOptions += '<option value="' + p.id + '" ' + sel + '>' + escapeHtml(p.name) + '</option>';
        });
        return parentOptions;
    }

    function showSuccessBanner() {
        if (!feedbackBanner) return;
        feedbackBanner.innerHTML =
            '<div class="feedback-banner">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 8 12 12 16 14"/></svg>' +
            '<span>Đồng bộ thành công! Cây danh mục sản phẩm đã được cập nhật.</span>' +
            '</div>';
        setTimeout(function () { feedbackBanner.innerHTML = ''; }, 3500);
    }

    /* ─── Helpers ─── */
    function escapeHtml(str) {
        if (!str) return '';
        return str
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    /* ─── Global Scope bindings ─── */
    window.WMS_TOGGLE_NODE = function (nodeId) {
        expandedNodes[nodeId] = !expandedNodes[nodeId];
        saveExpandedNodes();
        renderTree();
    };

    window.WMS_ADD_SUB = function (parentId) {
        activeForm.mode = 'create';
        activeForm.selectedId = null;
        activeForm.parentId = parentId;
        expandedNodes[parentId] = true;
        saveExpandedNodes();
        renderTree();
    };

    window.WMS_EDIT_NODE = function (categoryId) {
        var cat = categories.find(function (c) { return c.id === categoryId; });
        if (!cat) return;
        activeForm.mode = 'edit';
        activeForm.selectedId = categoryId;
        activeForm.parentId = cat.parentId;
        renderTree();
    };

    window.WMS_DEL_NODE = function (categoryId) {
        var cat = categories.find(function (c) { return c.id === categoryId; });
        if (!cat) return;
        activeForm.mode = 'delete';
        activeForm.selectedId = categoryId;
        renderTree();
    };

    window.WMS_CANCEL_ACTION = function () {
        activeForm.mode = 'empty';
        activeForm.selectedId = null;
        activeForm.parentId = null;
        renderTree();
    };

    window.WMS_SUBMIT_INLINE_CREATE = function (event, parentId) {
        event.preventDefault();
        var idSuffix = parentId === null ? 'root' : parentId;
        var codeInput = document.getElementById('createCode_' + idSuffix);
        var nameInput = document.getElementById('createName_' + idSuffix);
        var descInput = document.getElementById('createDesc_' + idSuffix);
        if (!codeInput || !nameInput) return;

        var code = codeInput.value.trim().toUpperCase();
        var name = nameInput.value.trim();
        if (!code || code.length < 3) {
            showToast('Ma dinh danh phai tu 3-4 ky tu!', 'error');
            return;
        }
        if (!name) {
            showToast('Vui long nhap ten danh muc!', 'error');
            return;
        }

        var description = descInput ? descInput.value.trim() : '';
        var params = new URLSearchParams();
        params.append('action', 'create');
        params.append('categoryCode', code);
        params.append('categoryName', name);
        if (parentId !== null) {
            params.append('parentId', parentId);
        }
        params.append('description', description);

        var form = event.target;
        var submitBtn = form.querySelector('button[type="submit"]');
        var originalText = submitBtn.innerHTML;
        submitBtn.disabled = true;
        submitBtn.innerHTML = '...';

        fetch('${pageContext.request.contextPath}/business/categories', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params.toString()
        })
        .then(function (resp) {
            if (resp.redirected) {
                window.location.href = resp.url;
            } else {
                submitBtn.disabled = false;
                submitBtn.innerHTML = originalText;
                showToast('Đã xảy ra lỗi khi tạo danh mục!', 'error');
            }
        })
        .catch(function () {
            submitBtn.disabled = false;
            submitBtn.innerHTML = originalText;
            showToast('Đã xảy ra lỗi kết nối!', 'error');
        });
    };

    window.WMS_SUBMIT_INLINE_EDIT = function (event, nodeId) {
        event.preventDefault();
        var codeInput = document.getElementById('editCode_' + nodeId);
        var nameInput = document.getElementById('editName_' + nodeId);
        var descInput = document.getElementById('editDesc_' + nodeId);
        var parentSelect = document.getElementById('editParent_' + nodeId);
        if (!nameInput) return;

        var name = nameInput.value.trim();
        if (!name) {
            showToast('Vui long nhap ten danh muc!', 'error');
            return;
        }

        // Lay code tu input hoac tu node goc (neu disabled)
        var code = codeInput ? codeInput.value.trim().toUpperCase() : '';
        if (codeInput && codeInput.disabled) {
            // Neu disabled, lay tu node goc
            var node = categories.find(function (c) { return c.id === nodeId; });
            code = node ? node.code : '';
        }
        if (!code || code.length < 3) {
            showToast('Ma dinh danh phai tu 3-4 ky tu!', 'error');
            return;
        }

        var description = descInput ? descInput.value.trim() : '';
        var parentVal = parentSelect ? parentSelect.value : 'none';

        var params = new URLSearchParams();
        params.append('action', 'update');
        params.append('categoryId', nodeId);
        params.append('categoryCode', code);
        params.append('categoryName', name);
        if (parentVal && parentVal !== 'none') {
            params.append('parentId', parentVal);
        }
        params.append('description', description);

        var form = event.target;
        var submitBtn = form.querySelector('button[type="submit"]');
        var originalText = submitBtn.innerHTML;
        submitBtn.disabled = true;
        submitBtn.innerHTML = '...';

        fetch('${pageContext.request.contextPath}/business/categories', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params.toString()
        })
        .then(function (resp) {
            if (resp.redirected) {
                window.location.href = resp.url;
            } else {
                submitBtn.disabled = false;
                submitBtn.innerHTML = originalText;
                showToast('Đã xảy ra lỗi khi cập nhật danh mục!', 'error');
            }
        })
        .catch(function () {
            submitBtn.disabled = false;
            submitBtn.innerHTML = originalText;
            showToast('Đã xảy ra lỗi kết nối!', 'error');
        });
    };

    window.WMS_DEACTIVATE = function (nodeId) {
        var params = new URLSearchParams();
        params.append('action', 'deactivate');
        params.append('categoryId', nodeId);

        fetch('${pageContext.request.contextPath}/business/categories', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params.toString()
        })
        .then(function (resp) {
            if (resp.redirected) {
                window.location.href = resp.url;
            } else {
                showToast('Da xay ra loi khi ngung hoat dong danh muc!', 'error');
            }
        })
        .catch(function () {
            showToast('Da xay ra loi khi ngung hoat dong danh muc!', 'error');
        });
    };

    window.WMS_CONFIRM_DELETE = function (nodeId) {
        var params = new URLSearchParams();
        params.append('action', 'delete');
        params.append('categoryId', nodeId);

        fetch('${pageContext.request.contextPath}/business/categories', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params.toString()
        })
        .then(function (resp) {
            if (resp.redirected) {
                window.location.href = resp.url;
            } else {
                showToast('Đã xảy ra lỗi khi xóa danh mục!', 'error');
            }
        })
        .catch(function () {
            showToast('Đã xảy ra lỗi kết nối!', 'error');
        });
    };

    /* ─── Bootstrap ─── */
    renderTree();
})();
</script>
