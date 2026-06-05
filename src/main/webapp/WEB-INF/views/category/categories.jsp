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
    if (categoryMessage != null) {
        session.removeAttribute("categoryMessage");
        session.removeAttribute("categorySuccess");
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
    .cat-layout-grid {
        display: grid;
        grid-template-columns: repeat(12, 1fr);
        gap: 24px;
        align-items: start;
    }

    @media (max-width: 1024px) {
        .cat-layout-grid {
            grid-template-columns: 1fr;
        }
    }

    .cat-panel-left {
        grid-column: span 7;
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 20px;
    }

    .cat-panel-right {
        grid-column: span 5;
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 20px;
    }

    @media (max-width: 1024px) {
        .cat-panel-left,
        .cat-panel-right {
            grid-column: span 12;
        }
    }

    .panel-hdr {
        display: flex;
        align-items: center;
        justify-content: space-between;
        border-b: 1px solid var(--border);
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
        border-radius: var(--radius-btn);
        padding: 16px;
        min-height: 300px;
        max-height: 550px;
        overflow-y: auto;
    }

    .tree-children-container {
        padding-left: 24px;
        border-left: 1px solid var(--border);
        margin-left: 10px;
        margin-top: 4px;
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    .tree-node-wrapper {
        position: relative;
    }

    .tree-row {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 12px;
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-btn);
        transition: background 0.15s, border-color 0.15s;
        min-height: 44px;
    }

    .tree-row:hover {
        background: rgba(240, 244, 250, 0.60);
    }

    .tree-row.root-row {
        padding: 10px 14px;
        box-shadow: 0 1px 2px rgba(16, 55, 92, 0.05);
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

    .node-level-badge {
        font-size: 10px;
        font-weight: 700;
        padding: 2px 6px;
        border-radius: 4px;
        font-family: monospace;
        text-transform: uppercase;
        flex-shrink: 0;
    }

    .node-level-badge.level-1 { background: rgba(235, 131, 23, 0.10); color: var(--orange); }
    .node-level-badge.level-2 { background: rgba(16, 55, 92, 0.05); color: rgba(16, 55, 92, 0.60); }
    .node-level-badge.level-3 { background: rgba(16, 55, 92, 0.05); color: rgba(16, 55, 92, 0.50); }

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
        width: 30px;
        height: 30px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #fff;
        border: 1px solid var(--border);
        border-radius: 4px;
        color: rgba(16, 55, 92, 0.55);
        cursor: pointer;
        transition: background 0.15s, color 0.15s, border-color 0.15s;
        box-shadow: 0 1px 2px rgba(16, 55, 92, 0.03);
    }

    .btn-action-sm:hover {
        color: var(--navy);
        background: var(--alice);
    }

    .btn-action-sm.del:hover {
        color: #b91c1c;
        background: #FEF2F2;
        border-color: #fca5a5;
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
    <!-- ══ LEFT PANEL: TREE VIEW ════════════════════════════════ -->
    <div class="cat-panel-left">
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
    </div>

    <!-- ══ RIGHT PANEL: EDIT/CREATE FORM ════════════════════════ -->
    <div class="cat-panel-right">
        <div class="panel-hdr">
            <div>
                <h3 class="panel-title" id="formPanelTitle">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z" />
                        <line x1="12" y1="11" x2="12" y2="17" />
                        <line x1="9" y1="14" x2="15" y2="14" />
                    </svg>
                    Bảng điều khiển danh mục
                </h3>
                <p class="panel-subtitle" id="formPanelSubtitle">
                    Vui lòng chọn hoặc click thêm mới ở danh mục bên trái để bắt đầu thiết lập.
                </p>
            </div>
        </div>
        <div id="formContainer"></div>
        <div id="feedbackBannerWrap"></div>
    </div>
</div>

<!-- ══ CREATE / EDIT / DELETE MODAL ════════════════════════════ -->
<div class="modal-overlay" id="categoryModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 id="modalTitle">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/>
                </svg>
                <span id="modalTitleText">Thêm danh mục mới</span>
            </h3>
            <button class="modal-close-btn" id="modalCloseBtn">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
        </div>
        <div class="modal-body">
            <form id="modalForm">
                <input type="hidden" id="modalCategoryId" name="categoryId" value="" />
                <input type="hidden" id="modalAction" name="action" value="" />

                <div class="form-group">
                    <label class="form-label" for="modalCategoryName">Tên danh mục (Category Name) *</label>
                    <input class="form-input" type="text" id="modalCategoryName" name="categoryName"
                           placeholder="VD: Đồ dùng học tập, Dụng cụ viết vẽ..." required />
                </div>

                <div class="form-group">
                    <label class="form-label" for="modalParentId">Thuộc danh mục cha</label>
                    <div class="select-wrap">
                        <select class="form-input" id="modalParentId" name="parentId">
                            <option value="">Không có (Cấp cao nhất)</option>
                        </select>
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
                    </div>
                </div>

                <div class="form-group" style="margin-bottom: 0;">
                    <label class="form-label" for="modalDescription">Mô tả</label>
                    <textarea class="form-input" id="modalDescription" name="description" rows="3"
                              placeholder="Mô tả ngắn về danh mục (tùy chọn)"></textarea>
                </div>
            </form>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn-modal-cancel" id="modalCancelBtn">HỦY BỎ</button>
            <button type="button" class="btn-modal-submit" id="modalSubmitBtn">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                <span id="modalSubmitText">LƯU DANH MỤC</span>
            </button>
        </div>
    </div>
</div>

<!-- ══ JAVASCRIPT STATE & LOGIC ═════════════════════════════ -->
<script>
(function () {
    'use strict';

    /* ─── Server-side data ─────────────────────────────────── */
    var serverCategories = [
        <c:forEach var="cat" items="${categories}" varStatus="st">
            {
                id: ${cat.categoryId},
                name: "${cat.categoryName.replace("\"", "\\\"")}",
                parentId: ${cat.parentId != null ? cat.parentId : 'null'},
                description: ${cat.description != null ? "\"" + cat.description.replace("\"", "\\\"") + "\"" : 'null'}
            }<c:if test="${!st.last}">,</c:if>
        </c:forEach>
    ];

    var categories = serverCategories.slice();

    var expandedNodes = {};

    var activeForm = {
        isEditing: false,
        selectedCategory: null,
        parentId: 'none'
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
        showToast("${categoryMessage}", "${categorySuccess == true ? 'success' : 'error'}");
    </c:if>

    /* ─── Modal system ──────────────────────────────────────── */
    var modal = document.getElementById('categoryModal');
    var modalForm = document.getElementById('modalForm');
    var modalTitleText = document.getElementById('modalTitleText');
    var modalCategoryId = document.getElementById('modalCategoryId');
    var modalCategoryName = document.getElementById('modalCategoryName');
    var modalParentId = document.getElementById('modalParentId');
    var modalDescription = document.getElementById('modalDescription');
    var modalAction = document.getElementById('modalAction');
    var modalSubmitBtn = document.getElementById('modalSubmitBtn');
    var modalSubmitText = document.getElementById('modalSubmitText');
    var modalCancelBtn = document.getElementById('modalCancelBtn');
    var modalCloseBtn = document.getElementById('modalCloseBtn');

    function populateParentDropdown(excludeId) {
        modalParentId.innerHTML = '<option value="">Không có (Cấp cao nhất)</option>';
        categories.forEach(function (c) {
            if (excludeId && c.id === excludeId) return;
            var opt = document.createElement('option');
            opt.value = c.id;
            opt.textContent = c.name;
            modalParentId.appendChild(opt);
        });
    }

    function openModal(mode, category) {
        mode = mode || 'create';
        modalForm.reset();
        modalAction.value = mode;

        if (mode === 'create') {
            modalTitleText.textContent = 'Thêm danh mục mới';
            modalCategoryId.value = '';
            modalCategoryName.value = '';
            modalDescription.value = '';
            modalSubmitText.textContent = 'TẠO MỚI';
            modalSubmitBtn.className = 'btn-modal-submit';
            populateParentDropdown(null);
            if (activeForm.parentId && activeForm.parentId !== 'none') {
                modalParentId.value = activeForm.parentId;
            } else {
                modalParentId.value = '';
            }
        } else if (mode === 'edit') {
            modalTitleText.textContent = 'Chỉnh sửa danh mục';
            modalCategoryId.value = category.id;
            modalCategoryName.value = category.name || '';
            modalDescription.value = category.description || '';
            modalSubmitText.textContent = 'CẬP NHẬT';
            modalSubmitBtn.className = 'btn-modal-submit';
            populateParentDropdown(category.id);
            modalParentId.value = category.parentId || '';
        } else if (mode === 'delete') {
            modalTitleText.textContent = 'Xác nhận xóa danh mục';
            modalCategoryId.value = category.id;
            modalCategoryName.value = category.name || '';
            modalDescription.value = '';
            modalSubmitText.textContent = 'XÓA DANH MỤC';
            modalSubmitBtn.className = 'btn-modal-submit danger';
            populateParentDropdown(category.id);
        }

        modal.classList.add('active');
        if (mode !== 'delete') {
            setTimeout(function () { modalCategoryName.focus(); }, 150);
        }
    }

    function closeModal() {
        modal.classList.remove('active');
    }

    if (modalCancelBtn) modalCancelBtn.addEventListener('click', closeModal);
    if (modalCloseBtn) modalCloseBtn.addEventListener('click', closeModal);
    if (modal) {
        modal.addEventListener('click', function (e) {
            if (e.target === modal) closeModal();
        });
    }

    if (modalSubmitBtn) {
        modalSubmitBtn.addEventListener('click', function () {
            var action = modalAction.value;

            if (action === 'create' || action === 'update') {
                var name = modalCategoryName.value.trim();
                if (!name) {
                    showToast('Vui lòng nhập tên danh mục!', 'error');
                    return;
                }
            }

            var formData = new FormData(modalForm);
            modalSubmitBtn.disabled = true;
            modalSubmitText.textContent = 'Đang xử lý...';

            fetch('${pageContext.request.contextPath}/business/categories', {
                method: 'POST',
                body: formData
            })
            .then(function (resp) {
                if (resp.redirected) {
                    window.location.href = resp.url;
                } else {
                    closeModal();
                    modalSubmitBtn.disabled = false;
                    modalSubmitText.textContent = action === 'create' ? 'TẠO MỚI' : 'CẬP NHẬT';
                    showToast('Đã xảy ra lỗi khi xử lý!', 'error');
                }
            })
            .catch(function () {
                closeModal();
                modalSubmitBtn.disabled = false;
                modalSubmitText.textContent = action === 'create' ? 'TẠO MỚI' : 'CẬP NHẬT';
                showToast('Đã xảy ra lỗi kết nối!', 'error');
            });
        });
    }

    /* ─── DOM Elements ───────────────────────────────────────── */
    var treeContainer = document.getElementById('treeContainer');
    var formPanelTitle = document.getElementById('formPanelTitle');
    var formPanelSubtitle = document.getElementById('formPanelSubtitle');
    var formContainer = document.getElementById('formContainer');
    var feedbackBanner = document.getElementById('feedbackBannerWrap');
    var btnAddRoot = document.getElementById('btnRootCategoryTrigger');

    /* ─── Handlers ───────────────────────────────────────────── */
    if (btnAddRoot) {
        btnAddRoot.addEventListener('click', function () {
            activeForm.parentId = 'none';
            openModal('create', null);
        });
    }

    function handleAddNew(parentId) {
        activeForm.isEditing = true;
        activeForm.selectedCategory = null;
        activeForm.parentId = parentId || 'none';
        renderForm();
    }

    function handleEdit(categoryId) {
        var cat = categories.find(function (c) { return c.id === categoryId; });
        if (!cat) return;
        openModal('edit', cat);
    }

    function handleDeleteClick(categoryId) {
        var cat = categories.find(function (c) { return c.id === categoryId; });
        if (!cat) return;
        if (confirm('Bạn có chắc chắn muốn xóa danh mục "' + cat.name + '"?')) {
            openModal('delete', cat);
        }
    }

    /* ─── UI Rendering ───────────────────────────────────────── */

    /* 1. Left Tree Column */
    function renderTree() {
        var roots = categories.filter(function (c) { return c.parentId === null; });

        if (roots.length === 0) {
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

        var html = roots.map(function (root) {
            return buildNodeHtml(root, 1);
        }).join('');

        treeContainer.innerHTML = html;
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

        var folderSvg = '<svg class="folder-icon level-' + (level > 2 ? '3' : level) + '" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>';

        var addSubBtn = '';
        if (level < 3) {
            addSubBtn = '<button class="btn-action-sm" onclick="WMS_ADD_SUB(' + node.id + ')" title="Thêm thể loại con">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>' +
                '</button>';
        }

        var rowClass = level === 1 ? 'tree-row root-row' : 'tree-row';
        var badgeClass = 'node-level-badge level-' + (level > 2 ? '3' : level);

        var childrenHtml = '';
        if (hasChildren && isExpanded) {
            childrenHtml = '<div class="tree-children-container">' +
                children.map(function (c) { return buildNodeHtml(c, level + 1); }).join('') +
                '</div>';
        }

        return '<div class="tree-node-wrapper">' +
            '<div class="' + rowClass + '">' +
            toggleBtn +
            folderSvg +
            '<div class="node-title-wrap">' +
            '<span class="node-name">' + escapeHtml(node.name) + '</span>' +
            '<span class="' + badgeClass + '">LV' + level + '</span>' +
            '</div>' +
            '<div class="node-actions">' +
            addSubBtn +
            '<button class="btn-action-sm" onclick="WMS_EDIT_NODE(' + node.id + ')" title="Chỉnh sửa">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>' +
            '</button>' +
            '<button class="btn-action-sm del" onclick="WMS_DEL_NODE(' + node.id + ')" title="Xóa danh mục">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>' +
            '</button>' +
            '</div>' +
            '</div>' +
            childrenHtml +
            '</div>';
    }

    /* 2. Right Form Column */
    function renderForm() {
        if (!activeForm.isEditing) {
            formPanelTitle.innerHTML =
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/><line x1="12" y1="11" x2="12" y2="17"/><line x1="9" y1="14" x2="15" y2="14"/></svg>' +
                'Bảng điều khiển danh mục';
            formPanelSubtitle.textContent = 'Vui lòng chọn hoặc click thêm mới ở danh mục bên trái để bắt đầu thiết lập.';

            formContainer.innerHTML =
                '<div class="empty-state-card">' +
                '<div class="empty-state-icon">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>' +
                '</div>' +
                '<h4 class="empty-state-title">Chưa có danh mục nào được chọn</h4>' +
                '<p class="empty-state-desc">Click biểu tượng sửa hoặc thêm mới ở cột trái để bắt đầu nhập liệu.</p>' +
                '<button class="btn-outline-sm mt-4" id="btnFormAddNewRoot">' +
                '<svg style="width:14px;height:14px;margin-right:6px" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>' +
                'Thêm danh mục mới' +
                '</button>' +
                '</div>';

            var btnInnerAdd = document.getElementById('btnFormAddNewRoot');
            if (btnInnerAdd) {
                btnInnerAdd.addEventListener('click', function () {
                    activeForm.parentId = 'none';
                    openModal('create', null);
                });
            }
            return;
        }

        var selected = activeForm.selectedCategory;
        formPanelTitle.innerHTML =
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/><line x1="12" y1="11" x2="12" y2="17"/><line x1="9" y1="14" x2="15" y2="14"/></svg>' +
            (selected ? 'Chỉnh sửa danh mục sản phẩm' : 'Thêm danh mục sản phẩm mới');
        formPanelSubtitle.textContent = 'Bổ sung hoặc sửa đổi các trường thuộc danh mục sản phẩm. Sử dụng form bên dưới hoặc nhấn nút "Thêm" trên cây phân cấp.';

        var parents = categories.filter(function (c) {
            if (selected && c.id === selected.id) return false;
            return true;
        });

        var parentOptions = '<option value="none">Không có (Cấp cao nhất)</option>';
        parents.forEach(function (p) {
            var sel = activeForm.parentId !== 'none' && activeForm.parentId == p.id ? 'selected' : '';
            parentOptions += '<option value="' + p.id + '" ' + sel + '>' + escapeHtml(p.name) + '</option>';
        });

        var nameVal = selected ? selected.name : '';

        formContainer.innerHTML =
            '<form id="categoryForm" class="space-y-4 animate-fadeIn">' +
            '<div class="form-group">' +
            '<label class="form-label" for="formName">Tên danh mục (Category Name) *</label>' +
            '<input class="form-input" type="text" id="formName" value="' + escapeHtml(nameVal) + '" placeholder="VD: Đồ dùng học tập..." required />' +
            '</div>' +

            '<div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; margin-bottom:16px;">' +
            '<div class="form-group" style="margin-bottom:0;">' +
            '<label class="form-label" for="formParentId">Thuộc danh mục cha</label>' +
            '<div class="select-wrap">' +
            '<select class="form-input" id="formParentId">' + parentOptions + '</select>' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>' +
            '</div>' +
            '</div>' +

            '<div class="form-group" style="margin-bottom:0;">' +
            '<label class="form-label">Mô tả</label>' +
            '<input class="form-input" type="text" id="formDescription" value="' + (selected ? escapeHtml(selected.description || '') : '') + '" placeholder="Mô tả ngắn..." />' +
            '</div>' +
            '</div>' +

            '<div class="form-actions">' +
            '<button type="button" class="btn-outline-sm" id="btnCancelForm">HỦY BỎ</button>' +
            '<button type="submit" class="btn-navy-action">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>' +
            'LƯU DANH MỤC' +
            '</button>' +
            '</div>' +
            '</form>';

        var categoryForm = document.getElementById('categoryForm');
        var btnCancel = document.getElementById('btnCancelForm');

        if (btnCancel) {
            btnCancel.addEventListener('click', function () {
                activeForm.isEditing = false;
                activeForm.selectedCategory = null;
                renderForm();
            });
        }

        if (categoryForm) {
            categoryForm.addEventListener('submit', function (e) {
                e.preventDefault();
                var name = document.getElementById('formName').value.trim();
                if (!name) {
                    showToast('Vui lòng nhập tên danh mục!', 'error');
                    return;
                }

                var parentVal = document.getElementById('formParentId').value;
                var description = document.getElementById('formDescription').value.trim();
                var formData = new FormData();
                formData.append('categoryName', name);

                if (parentVal && parentVal !== 'none') {
                    formData.append('parentId', parentVal);
                }

                if (description) {
                    formData.append('description', description);
                }

                if (selected) {
                    formData.append('action', 'update');
                    formData.append('categoryId', selected.id);
                } else {
                    formData.append('action', 'create');
                }

                var submitBtn = categoryForm.querySelector('button[type="submit"]');
                var originalText = submitBtn.innerHTML;
                submitBtn.disabled = true;
                submitBtn.innerHTML = 'Đang xử lý...';

                fetch('${pageContext.request.contextPath}/business/categories', {
                    method: 'POST',
                    body: formData
                })
                .then(function (resp) {
                    if (resp.redirected) {
                        window.location.href = resp.url;
                    } else {
                        submitBtn.disabled = false;
                        submitBtn.innerHTML = originalText;
                        showToast('Đã xảy ra lỗi khi xử lý!', 'error');
                    }
                })
                .catch(function () {
                    submitBtn.disabled = false;
                    submitBtn.innerHTML = originalText;
                    showToast('Đã xảy ra lỗi kết nối!', 'error');
                });
            });
        }
    }

    function showSuccessBanner() {
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
        renderTree();
    };

    window.WMS_ADD_SUB = function (parentId) {
        activeForm.isEditing = true;
        activeForm.selectedCategory = null;
        activeForm.parentId = parentId;
        renderForm();
    };

    window.WMS_EDIT_NODE = function (categoryId) {
        var cat = categories.find(function (c) { return c.id === categoryId; });
        if (!cat) return;
        openModal('edit', cat);
    };

    window.WMS_DEL_NODE = function (categoryId) {
        handleDeleteClick(categoryId);
    };

    /* ─── Bootstrap ─── */
    renderTree();
    renderForm();

})();
</script>
