<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>

        <style>
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

            .folder-icon.level-2 {
                color: #EB8317;
            }

            .folder-icon.level-3 {
                color: rgba(16, 55, 92, 0.40);
            }

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

            .node-level-badge.level-1 {
                background: rgba(235, 131, 23, 0.10);
                color: var(--orange);
            }

            .node-level-badge.level-2 {
                background: rgba(16, 55, 92, 0.05);
                color: rgba(16, 55, 92, 0.60);
            }

            .node-level-badge.level-3 {
                background: rgba(16, 55, 92, 0.05);
                color: rgba(16, 55, 92, 0.50);
            }

            /* Action buttons on hover */
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

            .btn-primary-sm:hover {
                background: #174e80;
            }

            .btn-primary-sm svg {
                width: 16px;
                height: 16px;
            }

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

            .btn-outline-sm:hover {
                background: var(--alice);
            }

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

            .btn-navy-action:hover {
                background: #174e80;
            }

            .btn-navy-action svg {
                width: 16px;
                height: 16px;
            }

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
                from {
                    transform: translateY(8px);
                    opacity: 0;
                }

                to {
                    transform: translateY(0);
                    opacity: 1;
                }
            }

            .animate-fadeIn {
                animation: fadeIn 0.25s ease;
            }

            @keyframes fadeIn {
                from {
                    opacity: 0;
                }

                to {
                    opacity: 1;
                }
            }
        </style>

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

                <!-- Form container (populated dynamically) -->
                <div id="formContainer"></div>

                <!-- Feedback Notification Banner -->
                <div id="feedbackBannerWrap"></div>
            </div>
        </div>

        <!-- ══ JAVASCRIPT STATE & LOGIC ═════════════════════════════ -->
        <script>
            window.WMS_CATEGORY_DATA = []; // Starts empty (no hardcoded/seed data)

            (function () {
                'use strict';

                /* ─── State ──────────────────────────────────────────────── */
                var categories = window.WMS_CATEGORY_DATA;

                // Collapsed node mappings: { nodeId: boolean } (true = expanded)
                var expandedNodes = {};

                // Active editing state:
                // { isEditing: boolean, selectedCategory: Category|null, formParentId: string }
                var activeForm = {
                    isEditing: false,
                    selectedCategory: null,
                    parentId: 'none'
                };

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
                        handleAddNew(null);
                    });
                }

                function toggleNode(nodeId) {
                    expandedNodes[nodeId] = !expandedNodes[nodeId];
                    renderTree();
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
                    activeForm.isEditing = true;
                    activeForm.selectedCategory = cat;
                    activeForm.parentId = cat.parentId || 'none';
                    renderForm();
                }

                function handleDelete(categoryId) {
                    if (confirm('Bạn có chắc chắn muốn xóa danh mục này? Các danh mục con trực thuộc cũng sẽ bị xóa bỏ.')) {
                        // Collect all sub-category IDs recursively
                        var toDeleteIds = {};
                        toDeleteIds[categoryId] = true;

                        var searchActive = true;
                        while (searchActive) {
                            searchActive = false;
                            for (var i = 0; i < categories.length; i++) {
                                var c = categories[i];
                                if (c.parentId && toDeleteIds[c.parentId] && !toDeleteIds[c.id]) {
                                    toDeleteIds[c.id] = true;
                                    searchActive = true;
                                }
                            }
                        }

                        // Filter out deleted nodes
                        categories = categories.filter(function (c) {
                            return !toDeleteIds[c.id];
                        });
                        window.WMS_CATEGORY_DATA = categories;

                        // If currently editing a deleted node, reset the form
                        if (activeForm.isEditing && activeForm.selectedCategory && toDeleteIds[activeForm.selectedCategory.id]) {
                            activeForm.isEditing = false;
                            activeForm.selectedCategory = null;
                        }

                        renderTree();
                        renderForm();
                    }
                }

                function cascadeLevels() {
                    var changed = true;
                    while (changed) {
                        changed = false;
                        for (var i = 0; i < categories.length; i++) {
                            var node = categories[i];
                            if (node.parentId) {
                                var parent = categories.find(function (p) { return p.id === node.parentId; });
                                if (parent && node.level !== parent.level + 1) {
                                    node.level = parent.level + 1;
                                    changed = true;
                                }
                            } else if (node.level !== 1) {
                                node.level = 1;
                                changed = true;
                            }
                        }
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
                        return buildNodeHtml(root);
                    }).join('');

                    treeContainer.innerHTML = html;
                }

                function buildNodeHtml(node) {
                    var children = categories.filter(function (c) { return c.parentId === node.id; });
                    var hasChildren = children.length > 0;
                    var isExpanded = !!expandedNodes[node.id];

                    var toggleBtn = '';
                    if (hasChildren) {
                        var chevronSvg = isExpanded ?
                            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>' :
                            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>';
                        toggleBtn = '<button class="btn-toggle-chevron" onclick="window.WMS_TOGGLE_NODE(\'' + node.id + '\')">' + chevronSvg + '</button>';
                    } else {
                        toggleBtn = '<div class="bullet-dot"><span></span></div>';
                    }

                    var folderSvg = '<svg class="folder-icon level-' + (node.level > 2 ? '3' : node.level) + '" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>';

                    // Add sub-category button only if level < 3
                    var addSubBtn = '';
                    if (node.level < 3) {
                        addSubBtn = '<button class="btn-action-sm" onclick="window.WMS_ADD_SUB(\'' + node.id + '\')" title="Thêm thể loại con trực thuộc">' +
                            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>' +
                            '</button>';
                    }

                    var rowClass = node.level === 1 ? 'tree-row root-row' : 'tree-row';
                    var badgeClass = 'node-level-badge level-' + (node.level > 2 ? '3' : node.level);

                    var childrenHtml = '';
                    if (hasChildren && isExpanded) {
                        childrenHtml = '<div class="tree-children-container">' +
                            children.map(function (c) { return buildNodeHtml(c); }).join('') +
                            '</div>';
                    }

                    return '<div class="tree-node-wrapper">' +
                        '<div class="' + rowClass + '">' +
                        toggleBtn +
                        folderSvg +
                        '<div class="node-title-wrap">' +
                        '<span class="node-name">' + escapeHtml(node.name) + '</span>' +
                        '<span class="' + badgeClass + '">LV' + node.level + '</span>' +
                        '</div>' +
                        '<div class="node-actions">' +
                        addSubBtn +
                        '<button class="btn-action-sm" onclick="window.WMS_EDIT_NODE(\'' + node.id + '\')" title="Chỉnh sửa thể loại">' +
                        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>' +
                        '</button>' +
                        '<button class="btn-action-sm del" onclick="window.WMS_DEL_NODE(\'' + node.id + '\')" title="Xóa thể loại & Danh mục con">' +
                        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>' +
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
                            '<div class="empty-state-card py-12">' +
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
                                handleAddNew(null);
                            });
                        }
                        return;
                    }

                    var selected = activeForm.selectedCategory;
                    formPanelTitle.innerHTML =
                        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/><line x1="12" y1="11" x2="12" y2="17"/><line x1="9" y1="14" x2="15" y2="14"/></svg>' +
                        (selected ? 'Chỉnh sửa danh mục sản phẩm' : 'Thêm danh mục sản phẩm mới');
                    formPanelSubtitle.textContent = 'Bổ sung hoặc sửa đổi các trường thuộc danh mục sản phẩm';

                    // Parent options list (exclude Level 3 nodes, and if editing, exclude self)
                    var parents = categories.filter(function (c) {
                        if (c.level >= 3) return false;
                        if (selected && c.id === selected.id) return false;
                        return true;
                    });

                    var parentOptions = '<option value="none">Không có (Cấp cao nhất)</option>';
                    parents.forEach(function (p) {
                        var prefix = p.level === 1 ? '' : '— ';
                        var sel = activeForm.parentId === p.id ? 'selected' : '';
                        parentOptions += '<option value="' + p.id + '" ' + sel + '>' + prefix + p.name + ' (LV' + p.level + ')</option>';
                    });

                    var nameVal = selected ? selected.name : '';

                    // Calculate initial level
                    var currentLevel = 1;
                    if (activeForm.parentId !== 'none') {
                        var parent = categories.find(function (c) { return c.id === activeForm.parentId; });
                        if (parent) currentLevel = parent.level + 1;
                    }

                    formContainer.innerHTML =
                        '<form id="categoryForm" class="space-y-4 animate-fadeIn">' +
                        '<div class="form-group">' +
                        '<label class="form-label" for="formName">Tên danh mục (Category Name) *</label>' +
                        '<input class="form-input" type="text" id="formName" value="' + escapeHtml(nameVal) + '" placeholder="VD: Đồ dùng học tập, Dụng cụ viết vẽ..." required />' +
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
                        '<label class="form-label">Cấp độ (Level)</label>' +
                        '<div class="form-input level-preview" style="border-radius: calc(var(--radius-btn) - 2px)">' +
                        '<span class="level-dot"></span>' +
                        '<span id="levelLabel">Level ' + currentLevel + '</span> <span style="font-size: 10px; color: rgba(16, 55, 92, 0.4); font-weight: normal">(Tự động tính)</span>' +
                        '</div>' +
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

                    // Bind event listeners to new elements
                    var selectParent = document.getElementById('formParentId');
                    var levelLabel = document.getElementById('levelLabel');
                    var categoryForm = document.getElementById('categoryForm');
                    var btnCancel = document.getElementById('btnCancelForm');

                    if (selectParent) {
                        selectParent.addEventListener('change', function (e) {
                            activeForm.parentId = e.target.value;
                            var newLvl = 1;
                            if (activeForm.parentId !== 'none') {
                                var p = categories.find(function (c) { return c.id === activeForm.parentId; });
                                if (p) newLvl = p.level + 1;
                            }
                            if (levelLabel) levelLabel.textContent = 'Level ' + newLvl;
                        });
                    }

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
                            var nameVal = document.getElementById('formName').value.trim();
                            if (!nameVal) {
                                alert('Vui lòng nhập tên danh mục!');
                                return;
                            }

                            var pIdVal = activeForm.parentId === 'none' ? null : activeForm.parentId;

                            // Level calculation
                            var finalLevel = 1;
                            if (pIdVal) {
                                var parentNode = categories.find(function (c) { return c.id === pIdVal; });
                                if (parentNode) finalLevel = parentNode.level + 1;
                            }

                            if (selected) {
                                // Check cycle
                                if (pIdVal === selected.id) {
                                    alert('Danh mục cha không thể là chính nó!');
                                    return;
                                }

                                // Update
                                var idx = categories.findIndex(function (c) { return c.id === selected.id; });
                                if (idx > -1) {
                                    categories[idx].name = nameVal;
                                    categories[idx].parentId = pIdVal;
                                    categories[idx].level = finalLevel;
                                }
                            } else {
                                // Insert
                                var newId = 'cat-' + Date.now();
                                var newCat = {
                                    id: newId,
                                    name: nameVal,
                                    parentId: pIdVal,
                                    level: finalLevel
                                };
                                categories.push(newCat);
                                // Auto expand parent
                                if (pIdVal) {
                                    expandedNodes[pIdVal] = true;
                                }
                            }

                            // Cascade update level of all nodes to fix parent modifications
                            cascadeLevels();
                            window.WMS_CATEGORY_DATA = categories;

                            // Reset form
                            activeForm.isEditing = false;
                            activeForm.selectedCategory = null;

                            renderTree();
                            renderForm();
                            showSuccessBanner();
                        });
                    }
                }

                function showSuccessBanner() {
                    feedbackBanner.innerHTML =
                        '<div class="feedback-banner">' +
                        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 8 12 12 16 14"/></svg>' +
                        '<span>Đồng bộ thành công! Cây danh mục sản phẩm đã được ghi nhận và lưu trữ vào Cơ sở dữ liệu.</span>' +
                        '</div>';
                    setTimeout(function () {
                        feedbackBanner.innerHTML = '';
                    }, 3000);
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

                /* ─── Global Scope bindings for inline onclick events ─── */
                window.WMS_TOGGLE_NODE = toggleNode;
                window.WMS_ADD_SUB = handleAddNew;
                window.WMS_EDIT_NODE = handleEdit;
                window.WMS_DEL_NODE = handleDelete;

                /* ─── Bootstrap ─── */
                renderTree();
                renderForm();

            })();
        </script>