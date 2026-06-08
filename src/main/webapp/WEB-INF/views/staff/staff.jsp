<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>

        <style>
            /* ─── Stats Cards ─── */
            .staff-stats-grid {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 16px;
                margin-bottom: 24px;
            }

            @media (max-width: 768px) {
                .staff-stats-grid {
                    grid-template-columns: 1fr;
                }
            }

            .staff-stat-card {
                background: #fff;
                border: 1px solid var(--border);
                padding: 16px 20px;
                border-radius: var(--radius-card);
                display: flex;
                align-items: center;
                gap: 16px;
                box-shadow: 0 1px 3px rgba(16, 55, 92, 0.06);
            }

            .staff-stat-icon {
                width: 40px;
                height: 40px;
                border-radius: var(--radius-btn);
                display: flex;
                align-items: center;
                justify-content: center;
                flex-shrink: 0;
            }

            .staff-stat-icon svg {
                width: 18px;
                height: 18px;
            }

            .staff-stat-val {
                font-size: 20px;
                font-weight: 800;
                color: var(--navy);
                letter-spacing: -0.03em;
                line-height: 1.1;
            }

            .staff-stat-lbl {
                font-size: 11px;
                font-weight: 600;
                color: rgba(16, 55, 92, 0.50);
                text-transform: uppercase;
                letter-spacing: 0.05em;
                margin-top: 2px;
            }

            .icon-navy {
                background: rgba(16, 55, 92, 0.08);
                color: var(--navy);
            }

            .icon-green {
                background: #ECFDF5;
                color: #059669;
            }

            .icon-red {
                background: #FEF2F2;
                color: #DC2626;
            }

            /* ─── Toolbar Card ─── */
            .staff-toolbar {
                background: #fff;
                border: 1px solid var(--border);
                padding: 16px;
                margin-bottom: 24px;
                border-radius: var(--radius-card);
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 16px;
                flex-wrap: wrap;
                box-shadow: 0 1px 3px rgba(16, 55, 92, 0.06);
            }

            .staff-toolbar-left {
                display: flex;
                align-items: center;
                gap: 12px;
                flex: 1;
                min-width: 280px;
                flex-wrap: wrap;
            }

            .search-wrap {
                position: relative;
                flex: 1;
            }

            .search-wrap svg {
                position: absolute;
                left: 14px;
                top: 50%;
                transform: translateY(-50%);
                width: 16px;
                height: 16px;
                color: rgba(16, 55, 92, 0.30);
                pointer-events: none;
            }

            .staff-search {
                width: 100%;
                padding: 10px 16px 10px 42px;
                background: var(--alice);
                border: 1px solid var(--border);
                font-size: 13px;
                color: var(--navy);
                outline: none;
                transition: border-color 0.15s;
                border-radius: calc(var(--radius-btn) - 2px);
            }

            .staff-search::placeholder {
                color: rgba(16, 55, 92, 0.30);
            }

            .staff-search:focus {
                border-color: rgba(16, 55, 92, 0.40);
            }

            .toolbar-select-wrap {
                position: relative;
            }

            .toolbar-select-wrap svg {
                position: absolute;
                right: 14px;
                top: 50%;
                transform: translateY(-50%);
                width: 14px;
                height: 14px;
                color: rgba(16, 55, 92, 0.40);
                pointer-events: none;
            }

            .staff-select {
                appearance: none;
                padding: 10px 36px 10px 16px;
                background: var(--alice);
                border: 1px solid var(--border);
                font-size: 13px;
                color: var(--navy);
                outline: none;
                cursor: pointer;
                transition: border-color 0.15s;
                border-radius: calc(var(--radius-btn) - 2px);
            }

            .staff-select:focus {
                border-color: rgba(16, 55, 92, 0.40);
            }

            .maker-badge {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 8px 16px;
                background: #F0F5FF;
                border: 1px solid #D0E0FF;
                font-size: 12px;
                font-weight: 500;
                color: #3B5FA0;
                border-radius: calc(var(--radius-btn) - 2px);
                white-space: nowrap;
            }

            .maker-badge svg {
                width: 14px;
                height: 14px;
                flex-shrink: 0;
            }

            /* ─── Table Card ─── */
            .staff-table-card {
                background: #fff;
                border: 1px solid var(--border);
                border-radius: var(--radius-card);
                overflow: hidden;
                box-shadow: 0 1px 3px rgba(16, 55, 92, 0.06);
            }

            .staff-table-scroll {
                width: 100%;
                overflow-x: auto;
            }

            .staff-table {
                width: 100%;
                border-collapse: collapse;
            }

            .staff-table th {
                background: var(--alice);
                padding: 16px 24px;
                font-size: 11px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.07em;
                color: rgba(16, 55, 92, 0.50);
                border-bottom: 1px solid var(--border);
                white-space: nowrap;
                text-align: left;
            }

            .staff-table td {
                padding: 16px 24px;
                border-bottom: 1px solid #F0F3FA;
                vertical-align: middle;
            }

            .staff-table tbody tr {
                transition: background 0.15s;
            }

            .staff-table tbody tr:hover {
                background: rgba(240, 244, 250, 0.40);
            }

            /* Cells */
            .username-chip {
                font-family: monospace;
                font-size: 13px;
                font-weight: 600;
                color: rgba(16, 55, 92, 0.80);
                background: var(--alice);
                padding: 4px 8px;
                border-radius: 4px;
            }

            .name-cell {
                display: flex;
                align-items: center;
                gap: 12px;
            }

            .avatar-circle {
                width: 32px;
                height: 32px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 11px;
                font-weight: 700;
                color: #fff;
                flex-shrink: 0;
            }

            .fullname-text {
                font-size: 13px;
                font-weight: 700;
                color: var(--navy);
            }

            .contact-cell {
                display: flex;
                flex-direction: column;
                gap: 2px;
            }

            .contact-line {
                display: flex;
                align-items: center;
                gap: 6px;
                font-size: 12px;
                color: rgba(16, 55, 92, 0.70);
            }

            .contact-line svg {
                width: 12px;
                height: 12px;
                color: rgba(16, 55, 92, 0.30);
                flex-shrink: 0;
            }

            /* Role badge — pill */
            .role-pill {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 4px 10px;
                font-size: 11px;
                font-weight: 600;
                border-radius: 20px;
            }

            .role-pill-dot {
                width: 6px;
                height: 6px;
                border-radius: 50%;
                flex-shrink: 0;
            }

            .role-bm {
                background: #FFFBEB;
                color: #92400E;
            }

            .role-bm .role-pill-dot {
                background: #F59E0B;
            }

            .role-ss {
                background: #ECFDF5;
                color: #065F46;
            }

            .role-ss .role-pill-dot {
                background: #10B981;
            }

            .role-wh {
                background: #ECFEFF;
                color: #164E63;
            }

            .role-wh .role-pill-dot {
                background: #06B6D4;
            }

            /* Status badge — pill */
            .status-pill {
                display: inline-flex;
                align-items: center;
                padding: 2px 10px;
                font-size: 11px;
                font-weight: 600;
                border-radius: 20px;
            }

            .status-active {
                background: #ECFDF5;
                color: #065F46;
                border: 1px solid #6EE7B7;
            }

            .status-inactive {
                background: #FEF2F2;
                color: #991B1B;
                border: 1px solid #FCA5A5;
            }

            /* Branch */
            .branch-text {
                font-size: 12px;
                color: rgba(16, 55, 92, 0.60);
            }

            /* Action button */
            .btn-edit-staff {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 6px 12px;
                border: 1px solid var(--border);
                background: #fff;
                font-size: 12px;
                font-weight: 700;
                color: rgba(16, 55, 92, 0.70);
                cursor: pointer;
                transition: color 0.15s, border-color 0.15s, background 0.15s;
                border-radius: calc(var(--radius-btn) - 3px);
            }

            .btn-edit-staff:hover {
                color: var(--orange);
                border-color: var(--orange);
                background: rgba(var(--orange-rgb, 234, 100, 28), 0.05);
            }

            .btn-edit-staff svg {
                width: 12px;
                height: 12px;
            }

            /* Empty state */
            .empty-state {
                padding: 48px 24px;
                text-align: center;
            }

            .empty-state-inner {
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: 8px;
                color: rgba(16, 55, 92, 0.30);
            }

            .empty-state-inner svg {
                width: 40px;
                height: 40px;
            }

            .empty-state-inner span {
                font-size: 13px;
                font-weight: 600;
            }

            /* Footer */
            .staff-table-footer {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 16px 24px;
                border-top: 1px solid #F0F3FA;
                background: rgba(240, 244, 250, 0.20);
            }

            .footer-count {
                font-size: 12px;
                color: rgba(16, 55, 92, 0.40);
            }

            .pagination-btns {
                display: flex;
                align-items: center;
                gap: 4px;
            }

            .page-btn {
                width: 32px;
                height: 32px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 12px;
                font-weight: 700;
                cursor: pointer;
                border: none;
                border-radius: calc(var(--radius-btn) - 4px);
            }

            .page-btn.active {
                background: var(--navy);
                color: #fff;
                box-shadow: 0 1px 4px rgba(16, 55, 92, 0.2);
            }

            /* ─── SIDEBAR PANEL ─── */
            .staff-overlay {
                position: fixed;
                inset: 0;
                z-index: 50;
                display: flex;
                justify-content: flex-end;
                transition: opacity 0.25s;
            }

            .staff-overlay.hidden-panel {
                opacity: 0;
                pointer-events: none;
            }

            .staff-backdrop {
                position: absolute;
                inset: 0;
                background: rgba(16, 55, 92, 0.50);
                backdrop-filter: blur(4px);
                cursor: pointer;
            }

            .staff-sidebar {
                position: relative;
                z-index: 10;
                width: 100%;
                max-width: 448px;
                background: #fff;
                display: flex;
                flex-direction: column;
                height: 100%;
                box-shadow: -8px 0 32px rgba(16, 55, 92, 0.15);
                transition: transform 0.3s ease;
            }

            .staff-overlay.hidden-panel .staff-sidebar {
                transform: translateX(100%);
            }

            .panel-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 20px 24px;
                border-bottom: 1px solid var(--border);
                flex-shrink: 0;
            }

            .panel-title {
                font-size: 16px;
                font-weight: 800;
                color: var(--navy);
            }

            .panel-username {
                font-family: monospace;
                font-size: 12px;
                color: rgba(16, 55, 92, 0.40);
                margin-top: 2px;
            }

            .panel-close {
                background: none;
                border: none;
                cursor: pointer;
                color: rgba(16, 55, 92, 0.40);
                padding: 4px;
                transition: color 0.15s;
            }

            .panel-close:hover {
                color: var(--navy);
            }

            .panel-close svg {
                width: 20px;
                height: 20px;
            }

            .panel-body {
                flex: 1;
                overflow-y: auto;
                padding: 24px;
                display: flex;
                flex-direction: column;
                gap: 24px;
            }

            .section-label-row {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 16px;
            }

            .section-label {
                font-size: 11px;
                font-weight: 700;
                color: rgba(16, 55, 92, 0.50);
                text-transform: uppercase;
                letter-spacing: 0.07em;
            }

            .admin-badge {
                display: flex;
                align-items: center;
                gap: 4px;
                font-size: 10px;
                font-weight: 600;
                color: rgba(16, 55, 92, 0.40);
                background: var(--alice);
                padding: 2px 8px;
                border-radius: 4px;
            }

            .admin-badge svg {
                width: 10px;
                height: 10px;
            }

            .readonly-block {
                background: rgba(240, 244, 250, 0.50);
                border: 1px solid var(--border);
                padding: 16px;
                border-radius: var(--radius-card);
                display: flex;
                flex-direction: column;
                gap: 14px;
            }

            .field-lbl {
                font-size: 10px;
                font-weight: 700;
                color: rgba(16, 55, 92, 0.40);
                text-transform: uppercase;
                letter-spacing: 0.07em;
                margin-bottom: 4px;
            }

            .field-val {
                font-size: 13px;
                font-weight: 700;
                color: var(--navy);
            }

            .field-val.sm {
                font-size: 12px;
                font-weight: 500;
                word-break: break-all;
            }

            .grid-2 {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 16px;
                border-top: 1px solid rgba(229, 234, 243, 0.80);
                padding-top: 12px;
            }

            .info-note {
                display: flex;
                align-items: flex-start;
                gap: 6px;
                font-size: 11px;
                color: rgba(16, 55, 92, 0.40);
                padding: 0 4px;
            }

            .info-note svg {
                width: 14px;
                height: 14px;
                color: rgba(16, 55, 92, 0.30);
                flex-shrink: 0;
                margin-top: 1px;
            }

            .section-divider {
                border: none;
                border-top: 1px solid var(--border);
            }

            .form-label {
                display: block;
                font-size: 12px;
                font-weight: 700;
                color: rgba(16, 55, 92, 0.80);
                margin-bottom: 8px;
            }

            .role-select-wrap {
                position: relative;
            }

            .role-select-wrap svg {
                position: absolute;
                right: 14px;
                top: 50%;
                transform: translateY(-50%);
                width: 16px;
                height: 16px;
                color: rgba(16, 55, 92, 0.40);
                pointer-events: none;
            }

            .role-select {
                width: 100%;
                appearance: none;
                padding: 12px 40px 12px 14px;
                border: 1px solid var(--border);
                background: #fff;
                font-size: 13px;
                font-weight: 600;
                color: var(--navy);
                outline: none;
                cursor: pointer;
                transition: border-color 0.15s;
                border-radius: var(--radius-btn);
            }

            .role-select:focus {
                border-color: var(--navy);
            }

             .status-toggle-row {
                 display: flex;
                 align-items: center;
                 justify-content: space-between;
                 padding: 14px;
                 border: 1px solid var(--border);
                 border-radius: var(--radius-card);
                 background: rgba(240, 244, 250, 0.20);
                 box-sizing: border-box;
             }
 
             .toggle-info-val {
                 font-size: 13px;
                 font-weight: 700;
                 color: var(--navy);
             }
 
             .toggle-info-sub {
                 font-size: 11px;
                 color: rgba(16, 55, 92, 0.50);
                 margin-top: 2px;
             }
 
             .toggle-btn {
                 position: relative;
                 width: 48px;
                 height: 26px;
                 border-radius: 13px;
                 border: none;
                 padding: 0;
                 margin: 0;
                 cursor: pointer;
                 transition: background-color 0.2s;
                 flex-shrink: 0;
                 outline: none;
                 box-sizing: border-box;
             }
 
             .toggle-btn.on {
                 background: #10B981;
             }
 
             .toggle-btn.off {
                 background: #EF4444;
             }
 
             .toggle-knob {
                 position: absolute;
                 top: 3px;
                 left: 0;
                 width: 20px;
                 height: 20px;
                 border-radius: 50%;
                 background: #fff;
                 box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
                 transition: transform 0.2s;
                 box-sizing: border-box;
             }
 
             .toggle-btn.on .toggle-knob {
                 transform: translateX(25px);
             }
 
             .toggle-btn.off .toggle-knob {
                 transform: translateX(3px);
             }

            .warn-block {
                padding: 14px;
                background: #FFFBEB;
                border: 1px solid #FDE68A;
                color: #92400E;
                border-radius: var(--radius-card);
                display: flex;
                align-items: flex-start;
                gap: 10px;
            }

            .warn-block svg {
                width: 16px;
                height: 16px;
                color: #D97706;
                flex-shrink: 0;
                margin-top: 1px;
            }

            .warn-block p {
                font-size: 11px;
                line-height: 1.6;
            }

            .panel-footer {
                padding: 16px 24px;
                border-top: 1px solid var(--border);
                background: rgba(240, 244, 250, 0.30);
                display: flex;
                align-items: center;
                justify-content: flex-end;
                gap: 12px;
                flex-shrink: 0;
            }

            .btn-cancel-panel {
                padding: 10px 20px;
                background: #fff;
                border: 1px solid var(--border);
                font-size: 13px;
                font-weight: 700;
                color: rgba(16, 55, 92, 0.70);
                cursor: pointer;
                transition: color 0.15s, background 0.15s;
                border-radius: var(--radius-btn);
            }

            .btn-cancel-panel:hover {
                color: var(--navy);
                background: var(--alice);
            }

            .btn-save-panel {
                padding: 10px 24px;
                background: var(--orange);
                border: none;
                font-size: 13px;
                font-weight: 800;
                color: #fff;
                cursor: pointer;
                transition: background 0.15s;
                border-radius: var(--radius-btn);
                box-shadow: 0 1px 4px rgba(234, 100, 28, 0.30);
            }

            .btn-save-panel:hover {
                background: #d4591a;
            }

            /* ─── TOAST ─── */
            .staff-toast {
                position: fixed;
                bottom: 20px;
                right: 20px;
                z-index: 60;
                display: flex;
                align-items: center;
                gap: 12px;
                padding: 12px 16px;
                background: var(--navy);
                color: #fff;
                border-radius: var(--radius-btn);
                box-shadow: 0 8px 32px rgba(16, 55, 92, 0.25);
                font-size: 13px;
                font-weight: 600;
                transform: translateY(80px);
                opacity: 0;
                transition: transform 0.3s ease, opacity 0.3s ease;
            }

            .staff-toast.show {
                transform: translateY(0);
                opacity: 1;
            }

            .toast-dot {
                width: 20px;
                height: 20px;
                border-radius: 50%;
                background: #10B981;
                display: flex;
                align-items: center;
                justify-content: center;
                flex-shrink: 0;
            }

            .toast-dot svg {
                width: 12px;
                height: 12px;
            }
        </style>

        <!-- ═══ Toast ═══ -->
        <div class="staff-toast" id="staffToast">
            <div class="toast-dot">
                <svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round"
                    stroke-linejoin="round">
                    <polyline points="20 6 9 17 4 12" />
                </svg>
            </div>
            <span id="toastMsg"></span>
        </div>

        <!-- ═══ Stats Cards ═══ -->
        <div class="staff-stats-grid">
            <div class="staff-stat-card">
                <div class="staff-stat-icon icon-navy">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                        stroke-linejoin="round">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                        <circle cx="9" cy="7" r="4" />
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                        <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                    </svg>
                </div>
                <div>
                    <div class="staff-stat-val" id="totalCountEl">0</div>
                    <div class="staff-stat-lbl">Tổng nhân sự giám sát</div>
                </div>
            </div>
            <div class="staff-stat-card">
                <div class="staff-stat-icon icon-green">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"
                        stroke-linejoin="round">
                        <polyline points="20 6 9 17 4 12" />
                    </svg>
                </div>
                <div>
                    <div class="staff-stat-val" id="activeCountEl">0</div>
                    <div class="staff-stat-lbl">Đang hoạt động</div>
                </div>
            </div>
            <div class="staff-stat-card">
                <div class="staff-stat-icon icon-red">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"
                        stroke-linejoin="round">
                        <line x1="18" y1="6" x2="6" y2="18" />
                        <line x1="6" y1="6" x2="18" y2="18" />
                    </svg>
                </div>
                <div>
                    <div class="staff-stat-val" id="inactiveCountEl">0</div>
                    <div class="staff-stat-lbl">Vô hiệu hóa</div>
                </div>
            </div>
        </div>

        <!-- ═══ Toolbar ═══ -->
        <div class="staff-toolbar">
            <div class="staff-toolbar-left">
                <!-- Search -->
                <div class="search-wrap" style="flex: 1;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                        stroke-linejoin="round">
                        <circle cx="11" cy="11" r="8" />
                        <path d="m21 21-4.3-4.3" />
                    </svg>
                    <input class="staff-search" id="staffSearch" type="text"
                        placeholder="Tìm theo Username, Họ tên, Email hoặc SĐT..." />
                </div>

                <!-- Role filter -->
                <div class="toolbar-select-wrap">
                    <select class="staff-select" id="roleFilter">
                        <option value="all">Tất cả vai trò</option>
                        <option value="business_manager">Business Manager</option>
                        <option value="sales_staff">Sales Staff</option>
                        <option value="warehouse_staff">Warehouse Staff</option>
                    </select>
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                        stroke-linejoin="round">
                        <polyline points="6 9 12 15 18 9" />
                    </svg>
                </div>

                <!-- Status filter -->
                <div class="toolbar-select-wrap">
                    <select class="staff-select" id="statusFilter">
                        <option value="all">Tất cả trạng thái</option>
                        <option value="active">Đang hoạt động</option>
                        <option value="inactive">Vô hiệu hóa</option>
                    </select>
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                        stroke-linejoin="round">
                        <polyline points="6 9 12 15 18 9" />
                    </svg>
                </div>
            </div>

        </div>

        <!-- ═══ Table ═══ -->
        <div class="staff-table-card">
            <div class="staff-table-scroll">
                <table class="staff-table">
                    <thead>
                        <tr>
                            <th>Username</th>
                            <th>Họ và tên</th>
                            <th>Liên hệ (Email/SĐT)</th>
                            <th>Vai trò (Role)</th>
                            <th>Chi nhánh</th>
                            <th>Trạng thái</th>
                            <th style="text-align: right;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody id="staffTableBody">
                        <!-- JS populated -->
                    </tbody>
                </table>
            </div>
            <div class="staff-table-footer">
                <span class="footer-count" id="footerCount">Đang hiển thị 0 / 0 nhân sự nội bộ</span>
                <div class="pagination-btns">
                    <button class="page-btn active">1</button>
                </div>
            </div>
        </div>

        <!-- ═══ Sidebar Panel ═══ -->
        <div class="staff-overlay hidden-panel" id="staffOverlay">
            <div class="staff-backdrop" id="staffBackdrop"></div>
            <div class="staff-sidebar" id="staffSidebar">
                <!-- Header -->
                <div class="panel-header">
                    <div>
                        <div class="panel-title">Cập Nhật Tài Khoản</div>
                        <div class="panel-username" id="panelUsername"></div>
                    </div>
                    <button class="panel-close" id="panelClose">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                            stroke-linecap="round" stroke-linejoin="round">
                            <line x1="18" y1="6" x2="6" y2="18" />
                            <line x1="6" y1="6" x2="18" y2="18" />
                        </svg>
                    </button>
                </div>

                <!-- Body -->
                <div class="panel-body">
                    <!-- Section 1: Read-only info -->
                    <div>
                        <div class="section-label-row">
                            <span class="section-label">Phần 1: Thông tin nhân sự (Read-only)</span>
                            <span class="admin-badge">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                    stroke-linecap="round" stroke-linejoin="round">
                                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                                    <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                                </svg>
                                Admin Cấp
                            </span>
                        </div>
                        <div class="readonly-block">
                            <div>
                                <div class="field-lbl">Họ và tên</div>
                                <div class="field-val" id="panelFullName"></div>
                            </div>
                            <div class="grid-2">
                                <div>
                                    <div class="field-lbl">Email</div>
                                    <div class="field-val sm" id="panelEmail"></div>
                                </div>
                                <div>
                                    <div class="field-lbl">Số điện thoại</div>
                                    <div class="field-val sm" id="panelPhone"></div>
                                </div>
                            </div>
                        </div>
                        <p class="info-note" style="margin-top: 10px;">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="12" cy="12" r="10" />
                                <line x1="12" y1="16" x2="12" y2="12" />
                                <line x1="12" y1="8" x2="12.01" y2="8" />
                            </svg>
                            Business Manager không được phép sửa đổi thông tin cá nhân do Admin khởi tạo để bảo đảm tính
                            thống nhất thông tin (Maker-Checker).
                        </p>
                    </div>

                    <hr class="section-divider" />

                    <!-- Section 2: Actionable -->
                    <div style="display: flex; flex-direction: column; gap: 16px;">
                        <div class="section-label">Phần 2: Quản trị Quyền hạn (Actionable)</div>

                        <!-- Role update -->
                        <div>
                            <label class="form-label">1. Luân chuyển chức vụ (Update Role)</label>
                            <div class="role-select-wrap">
                                <select class="role-select" id="panelRoleSelect">
                                    <option value="warehouse_staff">Warehouse Staff (Nhân viên kho)</option>
                                    <option value="sales_staff">Sales Staff (Nhân viên bán hàng)</option>
                                    <option value="business_manager">Business Manager (Quản lý kinh doanh)</option>
                                </select>
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                    stroke-linecap="round" stroke-linejoin="round">
                                    <polyline points="6 9 12 15 18 9" />
                                </svg>
                            </div>
                        </div>

                        <!-- Warehouse assignment (Only for Warehouse Staff) -->
                        <div id="warehouseSelectContainer" style="display: none;">
                            <label class="form-label">Chi nhánh làm việc (Warehouse Assignment)</label>
                            <c:choose>
                                <c:when test="${not empty warehouses}">
                                    <div class="role-select-wrap">
                                        <select class="role-select" id="panelWarehouseSelect">
                                            <option value="0">-- Chưa gán kho --</option>
                                            <c:forEach var="w" items="${warehouses}">
                                                <option value="${w.warehouseId}">${w.warehouseName}</option>
                                            </c:forEach>
                                        </select>
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                            stroke-linecap="round" stroke-linejoin="round">
                                            <polyline points="6 9 12 15 18 9" />
                                        </svg>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div style="font-size: 13px; color: #DC2626; font-weight: 600; padding: 10px; background: #FEF2F2; border: 1px solid #FCA5A5; border-radius: var(--radius-btn);">
                                        Chưa có kho nào được khởi tạo
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Status toggle -->
                        <div>
                            <label class="form-label">2. Trạng thái tài khoản (Deactivate)</label>
                            <div class="status-toggle-row">
                                <div>
                                    <div class="toggle-info-val" id="toggleStatusLabel">Đang hoạt động</div>
                                    <div class="toggle-info-sub" id="toggleStatusSub">Cho phép đăng nhập &amp; thao tác
                                        trên hệ thống.</div>
                                </div>
                                <button class="toggle-btn on" id="statusToggleBtn" onclick="toggleStatus()">
                                    <span class="toggle-knob"></span>
                                </button>
                            </div>
                        </div>


                    </div>
                </div>

                <!-- Footer -->
                <div class="panel-footer">
                    <button class="btn-cancel-panel" id="panelCancelBtn">HỦY BỎ</button>
                    <button class="btn-save-panel" id="panelSaveBtn">LƯU CẬP NHẬT</button>
                </div>
            </div>
        </div>

        <!-- ═══ DATA HOLDER ═══ -->
        <div id="staff-data" data-list='${staffListJson != null ? staffListJson : "[]"}' style="display:none;"></div>

        <!-- ═══ JAVASCRIPT ═══ -->
        <script>
            (function () {
                'use strict';

                // ─── Data ───
                var staffList = JSON.parse(document.getElementById('staff-data').getAttribute('data-list') || '[]');

            // ─── State ───
            var searchText = '';
            var roleFilter = 'all';
            var statusFilter = 'all';
            var selectedStaff = null;
            var panelEditRole = 'sales_staff';
            var panelEditStatus = 'active';
            var panelOpen = false;

            // ─── Role / Status configs ───
            var ROLE_CONFIG = {
                business_manager: { label: 'Business Manager', cls: 'role-bm', avatarGrad: 'linear-gradient(135deg,#f59e0b,#f3c623)' },
                sales_staff: { label: 'Sales Staff', cls: 'role-ss', avatarGrad: 'linear-gradient(135deg,#10b981,#34d399)' },
                warehouse_staff: { label: 'Warehouse Staff', cls: 'role-wh', avatarGrad: 'linear-gradient(135deg,#06b6d4,#22d3ee)' },
            };
            var STATUS_CONFIG = {
                active: { label: 'Đang hoạt động', cls: 'status-active' },
                inactive: { label: 'Vô hiệu hóa', cls: 'status-inactive' },
            };

            // ─── DOM refs ───
            var totalCountEl = document.getElementById('totalCountEl');
            var activeCountEl = document.getElementById('activeCountEl');
            var inactiveCountEl = document.getElementById('inactiveCountEl');
            var staffSearch = document.getElementById('staffSearch');
            var roleFilterEl = document.getElementById('roleFilter');
            var statusFilterEl = document.getElementById('statusFilter');
            var tableBody = document.getElementById('staffTableBody');
            var footerCount = document.getElementById('footerCount');

            var overlay = document.getElementById('staffOverlay');
            var backdrop = document.getElementById('staffBackdrop');
            var panelClose = document.getElementById('panelClose');
            var panelCancelBtn = document.getElementById('panelCancelBtn');
            var panelSaveBtn = document.getElementById('panelSaveBtn');
            var panelUsername = document.getElementById('panelUsername');
            var panelFullName = document.getElementById('panelFullName');
            var panelEmail = document.getElementById('panelEmail');
            var panelPhone = document.getElementById('panelPhone');
            var panelRoleSelect = document.getElementById('panelRoleSelect');
            var statusToggleBtn = document.getElementById('statusToggleBtn');
            var toggleStatusLabel = document.getElementById('toggleStatusLabel');
            var toggleStatusSub = document.getElementById('toggleStatusSub');
            var toastEl = document.getElementById('staffToast');
            var toastMsg = document.getElementById('toastMsg');

            // ─── Events ───
            staffSearch.addEventListener('input', function (e) { searchText = e.target.value; render(); });
            roleFilterEl.addEventListener('change', function (e) { roleFilter = e.target.value; render(); });
            statusFilterEl.addEventListener('change', function (e) { statusFilter = e.target.value; render(); });
            backdrop.addEventListener('click', closePanel);
            panelClose.addEventListener('click', closePanel);
            panelCancelBtn.addEventListener('click', closePanel);
            panelSaveBtn.addEventListener('click', savePanel);

            // Toggle warehouse selection container based on role
            panelRoleSelect.addEventListener('change', function (e) {
                var role = e.target.value;
                var whContainer = document.getElementById('warehouseSelectContainer');
                if (role === 'warehouse_staff') {
                    whContainer.style.display = 'block';
                } else {
                    whContainer.style.display = 'none';
                }
            });

            // ─── Render ───
            function render() {
                var filtered = staffList.filter(function (s) {
                    var q = searchText.toLowerCase();
                    var matchSearch = s.username.toLowerCase().indexOf(q) !== -1 ||
                        s.fullName.toLowerCase().indexOf(q) !== -1 ||
                        s.email.toLowerCase().indexOf(q) !== -1 ||
                        s.phone.indexOf(searchText) !== -1;
                    var matchRole = roleFilter === 'all' || s.role === roleFilter;
                    var matchStatus = statusFilter === 'all' || s.status === statusFilter;
                    return matchSearch && matchRole && matchStatus;
                });

                // KPIs
                var tc = staffList.length;
                var ac = staffList.filter(function (s) { return s.status === 'active'; }).length;
                var ic = staffList.filter(function (s) { return s.status === 'inactive'; }).length;
                totalCountEl.textContent = tc;
                activeCountEl.textContent = ac;
                inactiveCountEl.textContent = ic;
                footerCount.textContent = 'Đang hiển thị ' + filtered.length + ' / ' + tc + ' nhân sự nội bộ';

                // Build rows
                tableBody.innerHTML = '';
                if (filtered.length === 0) {
                    var tr = document.createElement('tr');
                    tr.innerHTML = '<td colspan="7" class="empty-state"><div class="empty-state-inner">' +
                        '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">' +
                        '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/>' +
                        '<path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>' +
                        '</svg><span>Không tìm thấy nhân sự phù hợp với bộ lọc</span></div></td>';
                    tableBody.appendChild(tr);
                    return;
                }

                filtered.forEach(function (staff, idx) {
                    var rc = ROLE_CONFIG[staff.role] || { label: staff.role, cls: 'role-wh', avatarGrad: '#aaa' };
                    var sc = STATUS_CONFIG[staff.status] || { label: staff.status, cls: 'status-active' };
                    var isInactive = staff.status === 'inactive';

                    var tr = document.createElement('tr');
                    if (isInactive) tr.style.background = 'rgba(254,242,242,0.10)';
                    else if (idx % 2 === 1) tr.style.background = 'rgba(240,244,250,0.10)';

                    // Username
                    var td1 = document.createElement('td');
                    td1.innerHTML = '<span class="username-chip">@' + esc(staff.username) + '</span>';
                    tr.appendChild(td1);

                    // Full Name
                    var td2 = document.createElement('td');
                    td2.innerHTML = '<span class="fullname-text">' + esc(staff.fullName) + '</span>';
                    tr.appendChild(td2);

                    // Contact
                    var td3 = document.createElement('td');
                    td3.innerHTML = '<div class="contact-cell">' +
                        '<span class="contact-line"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>' + esc(staff.email) + '</span>' +
                        '<span class="contact-line"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.6 3.42 2 2 0 0 1 3.58 1h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.46a16 16 0 0 0 6.63 6.63l.98-2.84a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 14.92z"/></svg>' + esc(staff.phone) + '</span>' +
                        '</div>';
                    tr.appendChild(td3);

                    // Role
                    var td4 = document.createElement('td');
                    td4.innerHTML = '<span class="role-pill ' + rc.cls + '">' +
                        '<span class="role-pill-dot"></span>' + esc(rc.label) + '</span>';
                    tr.appendChild(td4);

                    // Branch
                    var td5 = document.createElement('td');
                    td5.innerHTML = '<span class="branch-text">' + (staff.branch ? esc(staff.branch) : '—') + '</span>';
                    tr.appendChild(td5);

                    // Status
                    var td6 = document.createElement('td');
                    td6.innerHTML = '<span class="status-pill ' + sc.cls + '">' + esc(sc.label) + '</span>';
                    tr.appendChild(td6);

                    // Action
                    var td7 = document.createElement('td');
                    td7.style.textAlign = 'right';
                    var editBtn = document.createElement('button');
                    editBtn.className = 'btn-edit-staff';
                    editBtn.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg> Sửa';
                    editBtn.addEventListener('click', (function (s) {
                        return function () { openPanel(s); };
                    })(staff));
                    td7.appendChild(editBtn);
                    tr.appendChild(td7);

                    tableBody.appendChild(tr);
                });
            }

            // ─── Panel ───
            function openPanel(staff) {
                selectedStaff = staff;
                panelEditRole = staff.role;
                panelEditStatus = staff.status;

                panelUsername.textContent = '@' + staff.username;
                panelFullName.textContent = staff.fullName;
                panelEmail.textContent = staff.email;
                panelPhone.textContent = staff.phone;
                panelRoleSelect.value = staff.role;
                updateToggleUI(panelEditStatus);

                var whContainer = document.getElementById('warehouseSelectContainer');
                var whSelect = document.getElementById('panelWarehouseSelect');
                if (staff.role === 'warehouse_staff') {
                    whContainer.style.display = 'block';
                    if (whSelect) {
                        whSelect.value = staff.warehouseId || '0';
                    }
                } else {
                    whContainer.style.display = 'none';
                }

                overlay.classList.remove('hidden-panel');
                document.body.style.overflow = 'hidden';
                panelOpen = true;
            }

            function closePanel() {
                overlay.classList.add('hidden-panel');
                document.body.style.overflow = '';
                panelOpen = false;
                setTimeout(function () { selectedStaff = null; }, 300);
            }

            window.toggleStatus = function () {
                panelEditStatus = (panelEditStatus === 'active') ? 'inactive' : 'active';
                updateToggleUI(panelEditStatus);
            };

            function updateToggleUI(status) {
                var btn = statusToggleBtn;
                if (status === 'active') {
                    btn.className = 'toggle-btn on';
                    toggleStatusLabel.textContent = 'Đang hoạt động';
                    toggleStatusSub.textContent = 'Cho phép đăng nhập & thao tác trên hệ thống.';
                } else {
                    btn.className = 'toggle-btn off';
                    toggleStatusLabel.textContent = 'Tài khoản vô hiệu hóa';
                    toggleStatusSub.textContent = 'Khóa quyền đăng nhập và dừng toàn bộ phiên làm việc.';
                }
            }

            function savePanel() {
                if (!selectedStaff) return;
                var newRole = panelRoleSelect.value;
                var newStatus = panelEditStatus;
                var username = selectedStaff.username;
                var userId = selectedStaff.userId;

                var whSelect = document.getElementById('panelWarehouseSelect');
                var warehouseId = whSelect ? whSelect.value : '';

                // Disable save button to prevent double-click
                var saveBtn = document.getElementById('panelSaveBtn');
                saveBtn.disabled = true;
                saveBtn.textContent = 'ĐANG LƯU...';

                var params = new URLSearchParams();
                params.append('userId', userId);
                params.append('role', newRole);
                params.append('active', (newStatus === 'active') ? 'true' : 'false');
                if (newRole === 'warehouse_staff') {
                    params.append('warehouseId', warehouseId);
                }

                fetch('${pageContext.request.contextPath}/business/staff', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: params
                })
                .then(function (res) { return res.json(); })
                .then(function (data) {
                    saveBtn.disabled = false;
                    saveBtn.textContent = 'LƯU CẬP NHẬT';

                    if (data.success) {
                        var branchName = '';
                        if (newRole === 'warehouse_staff') {
                            if (warehouseId === '0') {
                                branchName = 'Chưa gán kho';
                            } else {
                                branchName = (whSelect && whSelect.options[whSelect.selectedIndex]) ? whSelect.options[whSelect.selectedIndex].text : 'Chưa gán kho';
                            }
                        }

                        // Update in-memory list
                        staffList = staffList.map(function (s) {
                            if (s.username === username) {
                                return Object.assign({}, s, { 
                                    role: newRole, 
                                    status: newStatus,
                                    warehouseId: newRole === 'warehouse_staff' ? parseInt(warehouseId) : 0,
                                    branch: newRole === 'warehouse_staff' ? branchName : ''
                                });
                            }
                            return s;
                        });
                        closePanel();
                        showToast('Đã cập nhật quyền hạn và trạng thái cho @' + username + ' thành công!');
                        render();
                    } else {
                        alert(data.message || 'Có lỗi xảy ra khi lưu thay đổi.');
                    }
                })
                .catch(function (err) {
                    saveBtn.disabled = false;
                    saveBtn.textContent = 'LƯU CẬP NHẬT';
                    console.error(err);
                    alert('Lỗi kết nối hệ thống.');
                });
            }

            // ─── Toast ───
            var toastTimer = null;
            function showToast(msg) {
                toastMsg.textContent = msg;
                toastEl.classList.add('show');
                if (toastTimer) clearTimeout(toastTimer);
                toastTimer = setTimeout(function () { toastEl.classList.remove('show'); }, 3000);
            }

            // ─── Utility ───
            function esc(text) {
                if (text == null) return '';
                return text.toString()
                    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;').replace(/"/g, '&quot;')
                    .replace(/'/g, '&#039;');
            }

            // ─── Init ───
            render();
            })();
        </script>