<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:if test="${not empty documents}">
<script type="application/json" id="ledger-docs-data">${documentsJson}</script>
</c:if>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/ledger--ledger.css"/>

<!-- Alert banner for pending count -->
<div class="alert-banner" id="pendingAlertBanner" style="display: none;">
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
        <path d="m9 12 2 2 4-4"/>
    </svg>
    <span>
        Có <strong id="bannerCountText">0 phiếu</strong> đang chờ phê duyệt từ Warehouse Staff. Vui lòng kiểm tra và xử lý.
    </span>
</div>

<!-- Tabs Bar -->
<div class="tabs-bar" id="tabsBar">
    <button class="tab-btn active tab-all" data-tab="all">
        Tất cả <span class="tab-badge" id="badge-all">0</span>
    </button>
    <button class="tab-btn tab-grn" data-tab="Phiếu Nhập Kho">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 17V3"/><path d="m6 11 6 6 6-6"/><path d="M19 21H5"/></svg>
        Nhập Kho <span class="tab-badge" id="badge-grn">0</span>
    </button>
    <button class="tab-btn tab-gi" data-tab="Phiếu Xuất Kho">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3v14"/><path d="m18 10-6 7-6-7"/><path d="M5 21h14"/></svg>
        Xuất Kho <span class="tab-badge" id="badge-gi">0</span>
    </button>
    <button class="tab-btn tab-kk" data-tab="Phiếu Kiểm Kê">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="18" x="3" y="4" rx="2" ry="2"/><line x1="16" x2="16" y1="2" y2="6"/><line x1="8" x2="8" y1="2" y2="6"/><line x1="3" x2="21" y1="10" y2="10"/><path d="m9 16 2 2 4-4"/></svg>
        Kiểm Kê <span class="tab-badge" id="badge-kk">0</span>
    </button>
    <button class="tab-btn tab-tr" data-tab="Phiếu Chuyển Kho">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 3h5v5"/><path d="M8 3H3v5"/><path d="M12 21v-6"/><path d="M12 12a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z"/><path d="m20 12-5 5-5-5"/></svg>
        Chuyển Kho <span class="tab-badge" id="badge-tr">0</span>
    </button>
    <button class="tab-btn tab-rma" data-tab="Phiếu Hoàn Hàng">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/><path d="M3 3v5h5"/></svg>
        Hoàn Hàng <span class="tab-badge" id="badge-rma">0</span>
    </button>
</div>

<!-- Toolbar -->
<div class="action-bar">
    <div class="search-input-wrap">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="11" cy="11" r="8"/>
            <path d="m21 21-4.3-4.3"/>
        </svg>
        <input class="search-input" type="text" id="ledgerSearch" placeholder="Tìm theo mã phiếu, loại hoặc người tạo..."/>
    </div>
    
    <!-- Test generator button removed -->
</div>

<!-- Table Card wrapper -->
<div class="table-card">
    <div class="table-responsive">
        <table class="wms-table">
            <thead>
                <tr>
                    <th style="width: 170px; padding-left: 20px;">Mã Phiếu</th>
                    <th style="width: 140px;">Loại Chứng Từ</th>
                    <th>Khu Vực / Kho</th>
                    <th style="width: 150px;">Người Tạo</th>
                    <th style="width: 150px;">Ngày Tạo</th>
                    <th style="width: 120px; text-align: right;">Số Mặt Hàng</th>
                    <th style="width: 150px; text-align: center;">Trạng Thái</th>
                    <th style="width: 155px; text-align: center; padding-right: 20px;">Thao Tác</th>
                </tr>
            </thead>
            <tbody id="ledgerTableBody">
                <!-- Dynamically populated -->
            </tbody>
        </table>
    </div>
    <div class="table-footer">
        <span id="showingCountEl">Hiển thị 0 / 0 chứng từ</span>
    </div>
</div>

<!-- ════════════════════════════════════════════════════
    CONFIRM DUYỆT MODAL (Xác nhận duyệt)
    ════════════════════════════════════════════════════ -->
<div class="modal-overlay" id="approveModalOverlay">
    <div class="modal-box modal-sm">
        <div class="modal-body" style="padding: 24px;">
            <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 16px;">
                <div class="type-icon-wrapper theme-grn" style="width: 40px; height: 40px;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="m9 12 2 2 4-4"/></svg>
                </div>
                <div>
                    <h3 class="modal-title" style="font-size: 15px;">Xác nhận phê duyệt</h3>
                    <p class="modal-subtitle">Thao tác này không thể hoàn tác</p>
                </div>
            </div>
            
            <div class="doc-callout" style="margin-bottom: 16px;">
                <div class="doc-callout-lbl">Phiếu cần duyệt</div>
                <div class="doc-callout-val" id="approveDocId">GRN-2026-0001</div>
                <div class="info-block-desc" id="approveDocSubtext" style="font-size: 12px; color: rgba(16, 55, 92, 0.6); margin-top: 3px;">Phiếu Nhập Kho — 120 mặt hàng</div>
            </div>

            <p style="font-size: 13px; color: rgba(16, 55, 92, 0.70); line-height: 1.5; margin-bottom: 24px;" id="approveExplanationText">
                Sau khi phê duyệt, hệ thống sẽ chính thức cộng số lượng tồn kho vật lý.
            </p>

            <div style="display: flex; gap: 8px;">
                <button class="btn-modal-cancel" style="flex: 1;" id="btnApproveCancel">Hủy</button>
                <button class="btn-modal-save bg-emerald" style="flex: 1;" id="btnApproveConfirm">Xác nhận duyệt</button>
            </div>
        </div>
    </div>
</div>

<!-- ════════════════════════════════════════════════════
    CONFIRM TỪ CHỐI MODAL
    ════════════════════════════════════════════════════ -->
<div class="modal-overlay" id="rejectModalOverlay">
    <div class="modal-box modal-sm">
        <div class="modal-body" style="padding: 24px;">
            <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 16px;">
                <div class="type-icon-wrapper theme-rma" style="width: 40px; height: 40px;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" x2="12" y1="8" y2="12"/><line x1="12" x2="12.01" y1="16" y2="16"/></svg>
                </div>
                <div>
                    <h3 class="modal-title" style="font-size: 15px;">Từ chối phiếu</h3>
                    <p class="modal-subtitle">Warehouse Staff sẽ cần chỉnh sửa lại</p>
                </div>
            </div>
            
            <div class="doc-callout" style="margin-bottom: 12px;">
                <div class="doc-callout-lbl">Phiếu bị từ chối</div>
                <div class="doc-callout-val" id="rejectDocId">GRN-2026-0001</div>
                <div class="info-block-desc" id="rejectDocSubtext" style="font-size: 12px; color: rgba(16, 55, 92, 0.6); margin-top: 3px;">Phiếu Nhập Kho — 120 mặt hàng</div>
            </div>

            <div class="form-group" style="margin-bottom: 24px;">
                <label class="form-label" style="font-size: 11.5px; font-weight: 700; color: rgba(16, 55, 92, 0.6);">Lý do từ chối</label>
                <textarea class="form-input" id="rejectReasonText" rows="3" placeholder="Nhập lý do từ chối để WH Staff biết cần điều chỉnh..." style="resize: none;"></textarea>
            </div>

            <div style="display: flex; gap: 8px;">
                <button class="btn-modal-cancel" style="flex: 1;" id="btnRejectCancel">Hủy</button>
                <button class="btn-modal-save bg-red" style="flex: 1;" id="btnRejectConfirm">Xác nhận từ chối</button>
            </div>
        </div>
    </div>
</div>

<!-- ════════════════════════════════════════════════════
    DEVELOPER TEST GENERATOR MODAL
    ════════════════════════════════════════════════════ -->
<!-- Developer test generator modal removed -->

<!-- ════════════════════════════════════════════════════
    DOCUMENT DETAILS VIEW MODAL (PDF-like preview)
    ════════════════════════════════════════════════════ -->
<div class="modal-overlay" id="detailModalOverlay">
    <div class="modal-box modal-lg" style="border-radius: var(--radius-card); overflow: hidden;">
        <!-- Header actions -->
        <div class="modal-hdr" style="background: rgba(240, 244, 250, 0.30); border-bottom: 1px solid var(--border); padding: 16px 24px; display: flex; align-items: center; justify-content: space-between;">
            <div id="detailModalTitleArea" style="display: flex; align-items: center; gap: 12px;">
                <h3 class="modal-title" id="detailModalTitle" style="font-size: 16px; font-weight: 700; color: var(--navy);">Chi tiết Phiếu Kho</h3>
            </div>
            <div class="pdf-header-actions">
                <button class="btn-pdf-action" onclick="alert('Đang kết nối máy in để in chứng từ PDF...');">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="6 9 6 2 18 2 18 9 6 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect width="12" height="8" x="6" y="14"/></svg>
                    In PDF
                </button>
                <button class="btn-pdf-action" onclick="alert('Đang trích xuất dữ liệu chứng từ Excel...');">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" x2="12" y1="15" y2="3"/></svg>
                    Xuất Excel
                </button>
                <button class="modal-close" id="btnDetailClose">&times;</button>
            </div>
        </div>
        
        <!-- Document Content -->
        <div class="modal-body" style="padding: 0; background: #fff; overflow-y: auto; flex: 1;" id="detailModalBody">
             <!-- Dynamically populated PDF area -->
        </div>
        
        <!-- Footer actions inside modal (not printed) -->
        <div class="modal-ftr" style="background: rgba(240, 244, 250, 0.30); border-top: 1px solid var(--border); padding: 16px 24px; display: flex; justify-content: flex-end;">
            <button class="btn-modal-cancel" id="btnDetailCloseFooter">Đóng cửa sổ</button>
        </div>
    </div>
</div>

<!-- ════════════════════════════════════════════════════
    JAVASCRIPT STATE & LOGIC
    ════════════════════════════════════════════════════ -->
<script>
    // Load ledger docs from server via embedded JSON script tag
    function safeJsonParse(raw, fallback) {
        if (!raw || typeof raw !== 'string') return fallback;
        try { return JSON.parse(raw); } catch (e) { return fallback; }
    }
    var rawData = document.getElementById('ledger-docs-data');
    var savedDocs = rawData ? safeJsonParse(rawData.textContent, []) : [];
    window.WMS_LEDGER_DATA = Array.isArray(savedDocs) ? savedDocs : [];

    (function() {
        'use strict';

        // DOM elements
        var pendingAlertBanner = document.getElementById('pendingAlertBanner');
        var bannerCountText = document.getElementById('bannerCountText');
        var ledgerTableBody = document.getElementById('ledgerTableBody');
        var showingCountEl = document.getElementById('showingCountEl');
        var ledgerSearch = document.getElementById('ledgerSearch');
        
        // Tab elements
        var tabBtns = document.querySelectorAll('.tab-btn');
        var badgeAll = document.getElementById('badge-all');
        var badgeGrn = document.getElementById('badge-grn');
        var badgeGi = document.getElementById('badge-gi');
        var badgeKk = document.getElementById('badge-kk');
        var badgeTr = document.getElementById('badge-tr');
        var badgeRma = document.getElementById('badge-rma');

        // Confirm modals DOM
        var approveOverlay = document.getElementById('approveModalOverlay');
        var approveDocId = document.getElementById('approveDocId');
        var approveDocSubtext = document.getElementById('approveDocSubtext');
        var approveExplanationText = document.getElementById('approveExplanationText');
        var btnApproveCancel = document.getElementById('btnApproveCancel');
        var btnApproveConfirm = document.getElementById('btnApproveConfirm');

        var rejectOverlay = document.getElementById('rejectModalOverlay');
        var rejectDocId = document.getElementById('rejectDocId');
        var rejectDocSubtext = document.getElementById('rejectDocSubtext');
        var rejectReasonText = document.getElementById('rejectReasonText');
        var btnRejectCancel = document.getElementById('btnRejectCancel');
        var btnRejectConfirm = document.getElementById('btnRejectConfirm');

        // Developer modal DOM removed

                // Detail Modal DOM
        var detailOverlay = document.getElementById('detailModalOverlay');
        var btnDetailClose = document.getElementById('btnDetailClose');
        var btnDetailCloseFooter = document.getElementById('btnDetailCloseFooter');
        var detailModalTitleArea = document.getElementById('detailModalTitleArea');
        var detailModalBody = document.getElementById('detailModalBody');

        // States
        var activeTab = "all";
        var searchQuery = "";
        var selectedConfirmDoc = null; // DocRecord
        var viewDetailDoc = null; // DocRecord

        // List of document type configurations matching React
        var TYPE_CONFIGS = {
            "Phiếu Nhập Kho": { colorClass: "theme-grn", badgeClass: "type-badge-grn", shortName: "Nhập kho", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 17V3"/><path d="m6 11 6 6 6-6"/><path d="M19 21H5"/></svg>' },
            "Phiếu Xuất Kho": { colorClass: "theme-gi", badgeClass: "type-badge-gi", shortName: "Xuất kho", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3v14"/><path d="m18 10-6 7-6-7"/><path d="M5 21h14"/></svg>' },
            "Phiếu Kiểm Kê": { colorClass: "theme-kk", badgeClass: "type-badge-kk", shortName: "Kiểm kê", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="18" x="3" y="4" rx="2" ry="2"/><line x1="16" x2="16" y1="2" y2="6"/><line x1="8" x2="8" y1="2" y2="6"/><line x1="3" x2="21" y1="10" y2="10"/><path d="m9 16 2 2 4-4"/></svg>' },
            "Phiếu Chuyển Kho": { colorClass: "theme-tr", badgeClass: "type-badge-tr", shortName: "Chuyển kho", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 3h5v5"/><path d="M8 3H3v5"/><path d="M12 21v-6"/><path d="M12 12a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z"/><path d="m20 12-5 5-5-5"/></svg>' },
            "Phiếu Hoàn Hàng": { colorClass: "theme-rma", badgeClass: "type-badge-rma", shortName: "Hoàn hàng", icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/><path d="M3 3v5h5"/></svg>' }
        };

        var PENDING_STATUSES = ["Đang xét QC", "Đang xử lý", "Đang giao", "Chờ duyệt", "Trình duyệt"];

        // Init tab clicks
        tabBtns.forEach(function(btn) {
            btn.addEventListener('click', function() {
                tabBtns.forEach(function(b) { b.classList.remove('active'); });
                btn.classList.add('active');
                activeTab = btn.getAttribute('data-tab');
                renderLedger();
            });
        });

        // Search listener
        ledgerSearch.addEventListener('input', function(e) {
            searchQuery = e.target.value;
            renderLedger();
        });

        // Dev mock triggers removed

        // Approve Confirm listeners
        btnApproveCancel.addEventListener('click', function() { approveOverlay.classList.remove('active'); });
        btnApproveConfirm.addEventListener('click', performApproval);

        // Reject Confirm listeners
        btnRejectCancel.addEventListener('click', function() { rejectOverlay.classList.remove('active'); });
        btnRejectConfirm.addEventListener('click', performRejection);

        // Detail Modal listeners
        btnDetailClose.addEventListener('click', closeDetailModal);
        btnDetailCloseFooter.addEventListener('click', closeDetailModal);
        function closeDetailModal() {
            detailOverlay.classList.remove('active');
            viewDetailDoc = null;
        }

        // Backdrop Dismissals for all overlays
        approveOverlay.addEventListener('click', function(e) {
            if (e.target === approveOverlay) {
                approveOverlay.classList.remove('active');
                selectedConfirmDoc = null;
            }
        });
        rejectOverlay.addEventListener('click', function(e) {
            if (e.target === rejectOverlay) {
                rejectOverlay.classList.remove('active');
                selectedConfirmDoc = null;
            }
        });
        detailOverlay.addEventListener('click', function(e) {
            if (e.target === detailOverlay) {
                closeDetailModal();
            }
        });

        function needsApproval(doc) {
            if (doc.type === "Phiếu Hoàn Hàng") return false;
            return PENDING_STATUSES.indexOf(doc.status) !== -1;
        }

        // Approve execution
        function performApproval() {
            if (!selectedConfirmDoc) return;
            var newStatus = (selectedConfirmDoc.type === "Phiếu Kiểm Kê") ? "Hoàn thành" : "Đã duyệt";
            
            window.WMS_LEDGER_DATA = window.WMS_LEDGER_DATA.map(function(d) {
                if (d.id === selectedConfirmDoc.id) {
                    d.status = newStatus;
                    d.statusColor = "#059669"; // Green
                }
                return d;
            });

            localStorage.setItem('wms_ledger_docs', JSON.stringify(window.WMS_LEDGER_DATA));
            approveOverlay.classList.remove('active');
            renderLedger();
        }

        // Reject execution
        function performRejection() {
            if (!selectedConfirmDoc) return;
            var reason = rejectReasonText.value.trim() || "Thông tin hàng hóa chưa chính xác";

            window.WMS_LEDGER_DATA = window.WMS_LEDGER_DATA.map(function(d) {
                if (d.id === selectedConfirmDoc.id) {
                    d.status = "Từ chối";
                    d.statusColor = "#dc2626"; // Red
                    d.remarks = "Lý do từ chối: " + reason;
                }
                return d;
            });

            localStorage.setItem('wms_ledger_docs', JSON.stringify(window.WMS_LEDGER_DATA));
            rejectOverlay.classList.remove('active');
            renderLedger();
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

        // Open detailed PDF viewer
        // Open detailed PDF viewer
        function openDetailModal(doc) {
            viewDetailDoc = doc;

            // Parse date details
            var dateStr = doc.date || "";
            var day = "28", month = "05", year = "2026", timeStr = "14:30";
            if (dateStr) {
                var spaceParts = dateStr.split(" ");
                if (spaceParts.length > 1) {
                    timeStr = spaceParts[1];
                }
                var datePart = spaceParts[0];
                if (datePart.indexOf("/") !== -1) {
                    var parts = datePart.split("/");
                    if (parts.length === 3) {
                        day = parts[0];
                        month = parts[1];
                        year = parts[2];
                    }
                } else if (datePart.indexOf("-") !== -1) {
                    var parts = datePart.split("-");
                    if (parts.length === 3) {
                        year = parts[0];
                        month = parts[1];
                        day = parts[2];
                    }
                }
            }

            if (doc.type === "Phiếu Nhập Kho") {
                // Render GRN Title
                detailModalTitleArea.innerHTML = '<h3 class="modal-title" style="font-size: 16px; font-weight: 700; color: var(--navy);">Chi tiết Phiếu Nhập Kho (GRN)</h3>';

                var itemsCount = doc.items || 120;
                var item1Qty = Math.max(1, Math.ceil(itemsCount * 0.65));
                var item2Qty = Math.max(0, itemsCount - item1Qty);

                var items = [];
                items.push({
                    stt: 1,
                    sku: "978-0545162074",
                    name: "Gương soi cầm tay mini",
                    uom: "Cái",
                    lot: "LOT-2026-05-20",
                    hsd: "31/12/2026",
                    ordered: item1Qty,
                    received: item1Qty,
                    accepted: item1Qty,
                    rejected: 0,
                    remarks: "",
                    price: 150000
                });
                if (item2Qty > 0) {
                    items.push({
                        stt: 2,
                        sku: "978-8935235670891",
                        name: "Lược chải tóc gỡ rối",
                        uom: "Cái",
                        lot: "LOT-2026-05-21",
                        hsd: "30/06/2027",
                        ordered: item2Qty,
                        received: item2Qty,
                        accepted: item2Qty,
                        rejected: 0,
                        remarks: "",
                        price: 95000
                    });
                }

                var totalOrdered = 0;
                var totalReceived = 0;
                var totalAccepted = 0;
                var totalRejected = 0;
                var totalValue = 0;
                var rowsHtml = "";

                for (var i = 0; i < items.length; i++) {
                    var it = items[i];
                    totalOrdered += it.ordered;
                    totalReceived += it.received;
                    totalAccepted += it.accepted;
                    totalRejected += it.rejected;
                    totalValue += it.accepted * it.price;

                    rowsHtml += '<tr style="line-height: 2.0;">' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; text-align: center;">' + it.stt + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; font-family: monospace; color: rgba(16, 55, 92, 0.70);">' + it.sku + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; font-weight: 600; color: var(--navy);">' + it.name + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 12px; text-align: center;">' + it.uom + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; text-align: center; color: rgba(16, 55, 92, 0.70);">' +
                            '<div style="font-family: monospace;">' + it.lot + '</div>' +
                            '<div style="color: rgba(16, 55, 92, 0.5);">HSD: ' + it.hsd + '</div>' +
                        '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; text-align: center; color: rgba(16, 55, 92, 0.60);">' + it.ordered + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 14px; font-weight: 600; text-align: center;">' + it.received + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 15px; font-weight: 800; text-align: center; background: rgba(16, 185, 129, 0.05); color: #059669;">' + it.accepted + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; text-align: center; background: rgba(239, 68, 68, 0.05); color: ' + (it.rejected > 0 ? '#dc2626' : 'rgba(16, 55, 92, 0.3)') + ';">' + (it.rejected > 0 ? it.rejected : '—') + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 12px; color: rgba(16, 55, 92, 0.70);">' + (it.remarks ? it.remarks : '<div style="border-bottom: 1px dashed rgba(16, 55, 92, 0.2); pb: 4px;"></div>') + '</td>' +
                    '</tr>';
                }

                var grnStatusText = (doc.status === "completed" || doc.status === "Đã duyệt" || doc.status === "Hoàn thành") ? "Hoàn tất nhập kho" : doc.status;
                var supplierText = doc.supplier || "Công ty Cổ phần Văn phòng phẩm Hồng Hà";

                detailModalBody.innerHTML = 
                    '<div class="pdf-print-area" style="padding: 32px; background: #fff; font-family: \'Inter\', sans-serif;">' +
                        '<!-- HEADER SECTION -->' +
                        '<div class="pdf-title-block" style="margin-bottom: 24px;">' +
                            '<h1 class="pdf-title-main" style="margin: 0 0 2px; font-size: 24px; font-weight: 850; color: var(--navy); letter-spacing: -0.02em;">PHIẾU NHẬP KHO</h1>' +
                            '<div class="pdf-title-sub" style="font-size: 13.5px; font-weight: 500; color: rgba(16, 55, 92, 0.50); text-transform: uppercase; letter-spacing: 0.05em;">GOODS RECEIPT NOTE (GRN)</div>' +
                        '</div>' +

                        '<div style="display: flex; align-items: center; gap: 16px; margin-bottom: 24px;">' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Mã Phiếu Nhập (GRN No.)</label>' +
                                '<span style="font-size: 18px; font-weight: 700; color: var(--navy);">' + escapeHtml(doc.id) + '</span>' +
                            '</div>' +
                            '<div class="pdf-barcode-box" style="border: 1px solid var(--border); border-radius: var(--radius-btn); padding: 8px 16px; background: #fff; display: flex; flex-direction: column; align-items: center;">' +
                                '<div style="height: 48px; width: 180px; background: rgba(16, 55, 92, 0.05); display: flex; align-items: center; justify-content: center; font-family: monospace; font-size: 10px; color: rgba(16, 55, 92, 0.35); margin-top: 4px;">||||| ' + escapeHtml(doc.id) + ' |||||</div>' +
                            '</div>' +
                        '</div>' +

                        '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px; border-bottom: 1px solid var(--border); padding-bottom: 24px;">' +
                            '<div style="display: flex; flex-direction: column; gap: 16px;">' +
                                '<div>' +
                                    '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Nhà Cung Cấp (Supplier)</label>' +
                                    '<div style="font-size: 14px; font-weight: 600; color: var(--navy);">' + escapeHtml(supplierText) + '</div>' +
                                    '<div style="font-size: 12px; color: rgba(16, 55, 92, 0.60); margin-top: 2px;">Địa chỉ: 123 Đường ABC, Quận 1, TP.HCM</div>' +
                                    '<div style="font-size: 12px; color: rgba(16, 55, 92, 0.60); margin-top: 2px;">SĐT: 028 1234 5678</div>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Mã Đơn Đặt Hàng (PO Ref.) <span style="color: #ef4444;">*</span></label>' +
                                    '<div style="font-size: 16px; font-weight: 700; color: var(--navy);">PO-2026-05-089</div>' +
                                '</div>' +
                            '</div>' +
                            '<div style="display: flex; flex-direction: column; gap: 16px;">' +
                                '<div>' +
                                    '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Ngày Nhập Kho (GRN Date)</label>' +
                                    '<div style="font-size: 14px; color: var(--navy);">' + day + '/' + month + '/' + year + ' - ' + timeStr + '</div>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Trạng Thái (Status)</label>' +
                                    '<span style="display: inline-block; padding: 4px 10px; font-size: 12px; font-weight: 700; color: #047857; background: #ECFDF5; border: 1px solid #A7F3D0; border-radius: var(--radius-btn);">' + grnStatusText + '</span>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 4px;">Giá Trị Lô Hàng (Document Value)</label>' +
                                    '<div style="font-size: 15px; font-weight: 700; color: var(--navy);">' + totalValue.toLocaleString('vi-VN') + ' VNĐ</div>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +

                        '<!-- LINE ITEMS -->' +
                        '<div style="margin-bottom: 24px;">' +
                            '<h2 style="font-size: 15px; font-weight: 700; color: var(--navy); margin-bottom: 16px;">Chi Tiết Hàng Hóa Nhập Kho (Phân Cấp Chất Lượng)</h2>' +
                            '<table class="pdf-table" style="width: 100%; border-collapse: collapse; border: 2px solid rgba(16, 55, 92, 0.15); margin-bottom: 24px;">' +
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
                                '<tbody>' +
                                    rowsHtml +
                                    '<tr style="background: rgba(240, 244, 250, 0.35); font-weight: 700; border-top: 2px solid rgba(16, 55, 92, 0.30);">' +
                                        '<td colspan="5" style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: right; font-size: 13px; color: var(--navy);">TỔNG CỘNG:</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 14px; color: rgba(16, 55, 92, 0.6);">' + totalOrdered + '</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 14px; color: var(--navy);">' + totalReceived + '</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 14px; background: rgba(16, 185, 129, 0.05); color: #059669;">' + totalAccepted + '</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 14px; background: rgba(239, 68, 68, 0.05); color: #dc2626;">' + totalRejected + '</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px;"></td>' +
                                    '</tr>' +
                                '</tbody>' +
                            '</table>' +

                            '<div style="margin-top: 16px; display: flex; align-items: center; gap: 24px;">' +
                                '<div style="border: 1px solid rgba(16, 55, 92, 0.2); padding: 8px 16px; border-radius: var(--radius-btn); display: inline-block;">' +
                                    '<span style="font-size: 11px; font-weight: 600; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em;">Tổng Số Bao Kiện/Pallet: </span>' +
                                    '<span style="font-size: 14px; font-weight: 700; color: var(--navy);">' + Math.ceil(totalAccepted / 100) + ' Pallet, ' + Math.ceil(totalAccepted / 20) + ' Thùng lớn</span>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +

                        '<!-- FOOTER -->' +
                        '<div style="display: flex; flex-direction: column; gap: 24px;">' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 8px;">Nhận Xét Chất Lượng / Tình Trạng Hàng Hóa</label>' +
                                '<div style="border: 1px solid #E5EAF3; padding: 16px; min-height: 100px; border-radius: var(--radius-btn);">' +
                                    '<div style="display: flex; flex-direction: column; gap: 12px;">' +
                                        '<div style="border-bottom: 1px dashed rgba(16, 55, 92, 0.1); padding-bottom: 4px;"></div>' +
                                        '<div style="border-bottom: 1px dashed rgba(16, 55, 92, 0.1); padding-bottom: 4px;"></div>' +
                                        '<div style="border-bottom: 1px dashed rgba(16, 55, 92, 0.1); padding-bottom: 4px;"></div>' +
                                        '<div style="border-bottom: 1px dashed rgba(16, 55, 92, 0.1); padding-bottom: 4px;"></div>' +
                                    '</div>' +
                                '</div>' +
                            '</div>' +

                            '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; padding-top: 16px; text-align: center;">' +
                                '<div>' +
                                    '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 4px;">Đại Diện Giao Hàng</label>' +
                                    '<div style="font-size: 10px; color: rgba(16, 55, 92, 0.50); margin-bottom: 8px;">(Supplier/Driver)</div>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 40px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 4px;">Nhân Viên QA/QC</label>' +
                                    '<div style="font-size: 10px; color: rgba(16, 55, 92, 0.50); margin-bottom: 8px;">(Quality Inspector)</div>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 40px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 4px;">Quản Đốc Kho</label>' +
                                    '<div style="font-size: 10px; color: rgba(16, 55, 92, 0.50); margin-bottom: 8px;">(Warehouse Manager)</div>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 40px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                    '</div>';

            } else if (doc.type === "Phiếu Xuất Kho") {
                // Render GI Title
                detailModalTitleArea.innerHTML = '<h3 class="modal-title" style="font-size: 16px; font-weight: 700; color: var(--navy);">Chi tiết Phiếu Xuất Kho</h3>';

                var itemsCount = doc.items || 85;
                var item1Qty = Math.max(1, Math.ceil(itemsCount * 0.7));
                var item2Qty = Math.max(0, itemsCount - item1Qty);

                var items = [];
                items.push({
                    stt: 1,
                    sku: "978-0545162074",
                    name: "Gương soi cầm tay mini",
                    uom: "Cái",
                    lot: "LOT-2026-05-01",
                    hsd: "31/12/2026",
                    qtyRequest: item1Qty,
                    qtyIssued: item1Qty,
                    price: 35000
                });
                if (item2Qty > 0) {
                    items.push({
                        stt: 2,
                        sku: "978-8935235670891",
                        name: "Lược chải tóc gỡ rối",
                        uom: "Cái",
                        lot: "LOT-2026-04-15",
                        hsd: "30/06/2027",
                        qtyRequest: item2Qty,
                        qtyIssued: item2Qty,
                        price: 15000
                    });
                }

                var totalQtyRequest = 0;
                var totalQtyIssued = 0;
                var totalAmount = 0;
                var rowsHtml = "";

                for (var i = 0; i < items.length; i++) {
                    var it = items[i];
                    totalQtyRequest += it.qtyRequest;
                    totalQtyIssued += it.qtyIssued;
                    totalAmount += it.qtyIssued * it.price;

                    rowsHtml += '<tr style="line-height: 1.8;">' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; text-align: center;">' + it.stt + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; font-weight: 600; color: var(--navy);">' + it.name + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 12px; font-family: monospace; color: rgba(16, 55, 92, 0.70);">' + it.sku + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; text-align: center;">' + it.uom + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; text-align: center; color: rgba(16, 55, 92, 0.70);">' +
                            '<div style="font-family: monospace;">' + it.lot + '</div>' +
                            '<div style="color: rgba(16, 55, 92, 0.5);">HSD: ' + it.hsd + '</div>' +
                        '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; text-align: center; color: rgba(16, 55, 92, 0.60);">' + it.qtyRequest + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 15px; font-weight: 800; text-align: center; background: rgba(16, 55, 92, 0.05);">' + it.qtyIssued + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; text-align: right; color: rgba(16, 55, 92, 0.70);">' + it.price.toLocaleString('vi-VN') + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; font-weight: 600; text-align: right; color: var(--navy);">' + (it.qtyIssued * it.price).toLocaleString('vi-VN') + '</td>' +
                    '</tr>';
                }
                var totalAmountWords = numberToVietnameseWords(totalAmount);

                detailModalBody.innerHTML = 
                    '<div class="pdf-print-area" style="padding: 32px; background: #fff; font-family: \'Inter\', sans-serif;">' +
                        '<!-- HEADER SECTION -->' +
                        '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 32px; margin-bottom: 24px;">' +
                            '<div>' +
                                '<div style="font-size: 11px; font-weight: 500; color: var(--navy);">Đơn vị: <span style="font-weight: 700; font-size: 12px;">Hệ thống Bán hàng Đa kênh ABC</span></div>' +
                                '<div style="font-size: 11px; color: rgba(16, 55, 92, 0.60);">Bộ phận: Kho Trung Tâm</div>' +
                            '</div>' +
                            '<div style="text-align: right;">' +
                                '<div style="font-size: 10px; color: rgba(16, 55, 92, 0.60);">Mẫu số 02-VT</div>' +
                                '<div style="font-size: 10px; color: rgba(16, 55, 92, 0.60);">(Ban hành theo Thông tư số 200/2014/TT-BTC)</div>' +
                            '</div>' +
                        '</div>' +

                        '<div style="text-align: center; margin-bottom: 8px;">' +
                            '<h1 style="margin: 0; font-size: 20px; font-weight: 700; color: var(--navy); letter-spacing: -0.01em;">PHIẾU XUẤT KHO</h1>' +
                            '<div style="font-size: 13px; font-weight: 500; color: rgba(16, 55, 92, 0.60); margin-top: 2px;">GOODS ISSUE NOTE</div>' +
                        '</div>' +

                        '<div style="text-align: center; margin-bottom: 24px; font-size: 12px; color: rgba(16, 55, 92, 0.60);">' +
                            'Ngày <span style="border-bottom: 1px dashed rgba(16, 55, 92, 0.3); padding: 0 8px;">' + day + '</span> tháng ' +
                            '<span style="border-bottom: 1px dashed rgba(16, 55, 92, 0.3); padding: 0 8px;">' + month + '</span> năm ' +
                            '<span style="border-bottom: 1px dashed rgba(16, 55, 92, 0.3); padding: 0 8px;">' + year + '</span>' +
                        '</div>' +

                        '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 24px;">' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Số Phiếu (No.)</label>' +
                                '<div style="display: flex; align-items: center; gap: 12px;">' +
                                    '<span style="font-size: 16px; font-weight: 700; color: var(--navy);">' + escapeHtml(doc.id) + '</span>' +
                                    '<div style="border: 1px solid var(--border); border-radius: var(--radius-btn); padding: 4px 8px; background: #fff;">' +
                                        '<div style="height: 40px; width: 112px; background: rgba(16, 55, 92, 0.05); display: flex; align-items: center; justify-content: center; font-family: monospace; font-size: 9px; color: rgba(16, 55, 92, 0.40);">||||| ' + escapeHtml(doc.id) + ' |||||</div>' +
                                    '</div>' +
                                '</div>' +
                            '</div>' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Nợ (Debit)</label>' +
                                '<div style="border-bottom: 2px dashed rgba(16, 55, 92, 0.2); padding-bottom: 8px;">' +
                                    '<span style="font-size: 12px; font-weight: 700; color: var(--navy);">TK 632</span>' +
                                '</div>' +
                            '</div>' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Có (Credit)</label>' +
                                '<div style="border-bottom: 2px dashed rgba(16, 55, 92, 0.2); padding-bottom: 8px;">' +
                                    '<span style="font-size: 12px; font-weight: 700; color: var(--navy);">TK 156</span>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +

                        '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px;">' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Họ Tên Người Nhận Hàng</label>' +
                                '<div style="border-bottom: 1px solid rgba(16, 55, 92, 0.2); padding-bottom: 4px;">' +
                                    '<span style="font-size: 14px; font-weight: 500; color: var(--navy);">' + escapeHtml(doc.createdBy) + '</span>' +
                                '</div>' +
                            '</div>' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Địa Chỉ / Đơn Vị Người Nhận</label>' +
                                '<div style="border-bottom: 1px solid rgba(16, 55, 92, 0.2); padding-bottom: 4px;">' +
                                    '<span style="font-size: 13px; color: var(--navy);" class="truncate block">Hệ thống B2C</span>' +
                                '</div>' +
                            '</div>' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Lý Do Xuất Kho</label>' +
                                '<div style="border-bottom: 1px solid rgba(16, 55, 92, 0.2); padding-bottom: 4px;">' +
                                    '<span style="font-size: 14px; font-weight: 500; color: var(--navy);">Xuất bán hàng theo đơn hàng SO-2026-05-11024</span>' +
                                '</div>' +
                            '</div>' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Xuất Tại Kho</label>' +
                                '<div style="border-bottom: 1px solid rgba(16, 55, 92, 0.2); padding-bottom: 4px;">' +
                                    '<span style="font-size: 14px; color: var(--navy);">' + escapeHtml(doc.warehouse) + '</span>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +

                        '<!-- LINE ITEMS -->' +
                        '<div style="margin-bottom: 24px;">' +
                            '<table class="pdf-table" style="width: 100%; border-collapse: collapse; border: 2px solid rgba(16, 55, 92, 0.15); margin-bottom: 24px;">' +
                                '<thead>' +
                                    '<tr style="background: var(--alice); border-bottom: 2px solid rgba(16, 55, 92, 0.15);">' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; width: 40px;">STT</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Tên/Quy Cách Vật Tư</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Mã Số (SKU)</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">ĐVT</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">Số Lô / HSD</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">SL Yêu Cầu</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; background: rgba(16, 55, 92, 0.05);">SL Thực Xuất</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: right;">Đơn Giá</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: right;">Thành Tiền</th>' +
                                    '</tr>' +
                                '</thead>' +
                                '<tbody>' +
                                    rowsHtml +
                                    '<tr style="background: rgba(240, 244, 250, 0.35); font-weight: 700; border-top: 2px solid rgba(16, 55, 92, 0.30);">' +
                                        '<td colspan="5" style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: right; font-size: 13px; color: var(--navy);">CỘNG:</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 14px; color: rgba(16, 55, 92, 0.6);">' + totalQtyRequest + '</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 14px; background: rgba(16, 55, 92, 0.05); color: var(--navy);">' + totalQtyIssued + '</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px;"></td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: right; font-size: 14px; color: var(--navy);">' + totalAmount.toLocaleString('vi-VN') + '</td>' +
                                    '</tr>' +
                                '</tbody>' +
                            '</table>' +

                            '<div style="margin-top: 16px; border: 1px solid rgba(16, 55, 92, 0.2); padding: 12px 16px; border-radius: var(--radius-btn);">' +
                                '<span style="font-size: 11px; font-weight: 600; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em;">Tổng Số Tiền (Viết bằng chữ): </span>' +
                                '<span style="font-size: 13px; font-weight: 700; color: var(--navy);">' + totalAmountWords + '</span>' +
                            '</div>' +
                        '</div>' +

                        '<!-- FOOTER -->' +
                        '<div style="display: flex; flex-direction: column; gap: 24px;">' +
                            '<div style="display: grid; grid-template-columns: repeat(5, 1fr); gap: 12px; padding-top: 16px; text-align: center;">' +
                                '<div>' +
                                    '<label style="display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 12px;">Người Lập Phiếu</label>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 32px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 12px;">Người Nhận Hàng</label>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 32px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 12px;">Thủ Kho</label>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 32px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 12px;">Kế Toán Trưởng</label>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 32px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 12px;">Giám Đốc</label>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 32px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                    '</div>';

            } else if (doc.type === "Phiếu Kiểm Kê") {
                // Render KK Title
                detailModalTitleArea.innerHTML = '<h3 class="modal-title" style="font-size: 16px; font-weight: 700; color: var(--navy);">Chi tiết Phiếu Kiểm Kê</h3>';

                var totalItems = doc.items || 150;
                var item1Book = Math.max(1, Math.ceil(totalItems * 0.55));
                var item1Actual = item1Book - 2;
                var item1Diff = item1Actual - item1Book;

                var item2Book = Math.max(0, totalItems - item1Book);
                var item2Actual = item2Book;
                var item2Diff = 0;

                var items = [];
                items.push({ stt: 1, sku: "978-0545162074", name: "Gương soi cầm tay mini", uom: "Cái", book: item1Book, actual: item1Actual, diff: item1Diff, remark: "Hư hỏng 2 cái (vỡ kính)" });
                if (item2Book > 0) {
                    items.push({ stt: 2, sku: "978-8935235670891", name: "Lược chải tóc gỡ rối", uom: "Cái", book: item2Book, actual: item2Actual, diff: item2Diff, remark: "" });
                }
                // Add some other mock items to look complete
                items.push({ stt: items.length + 1, sku: "978-0316769174", name: "Vở kẻ ngang 120 trang", uom: "Cái", book: 150, actual: 148, diff: -2, remark: "Mất mát không xác định" });
                items.push({ stt: items.length + 1, sku: "978-0061120084", name: "Bút bi xanh cao cấp", uom: "Cái", book: 300, actual: 302, diff: 2, remark: "Nhập thừa lô GRN-2024-049" });

                var totalBook = 0;
                var totalActual = 0;
                var totalDiff = 0;
                
                var rowsHtml = "";
                for (var i = 0; i < items.length; i++) {
                    var it = items[i];
                    totalBook += it.book;
                    totalActual += it.actual;
                    totalDiff += it.diff;

                    var diffText = "±0";
                    var diffColor = "#059669";
                    var diffWeight = "700";
                    if (it.diff > 0) {
                        diffText = "+" + it.diff;
                        diffColor = "#059669";
                        diffWeight = "800";
                    } else if (it.diff < 0) {
                        diffText = it.diff;
                        diffColor = "#ef4444";
                        diffWeight = "800";
                    }

                    rowsHtml += '<tr style="line-height: 2.0;">' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; text-align: center;">' + it.stt + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; font-family: monospace; color: rgba(16, 55, 92, 0.70);">' + it.sku + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; color: var(--navy);">' + it.name + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 12px; text-align: center;">' + it.uom + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 14px; font-weight: 600; text-align: center; background: #eff6ff; color: #1d4ed8;">' + it.book.toLocaleString('vi-VN') + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 16px; font-weight: 800; text-align: center; background: rgba(235, 131, 23, 0.05); color: var(--navy);">' + it.actual.toLocaleString('vi-VN') + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 14px; font-weight: ' + diffWeight + '; text-align: center; color: ' + diffColor + ';">' + diffText + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; color: rgba(16, 55, 92, 0.70);">' + 
                            (it.remark ? it.remark : '<div style="border-bottom: 1px dashed rgba(16, 55, 92, 0.2); padding-bottom: 4px;"></div>') + 
                        '</td>' +
                    '</tr>';
                }

                var totalDiffText = "±0";
                var totalDiffColor = "#059669";
                if (totalDiff > 0) {
                    totalDiffText = "+" + totalDiff;
                    totalDiffColor = "#059669";
                } else if (totalDiff < 0) {
                    totalDiffText = totalDiff;
                    totalDiffColor = "#ef4444";
                }

                detailModalBody.innerHTML = 
                    '<div class="pdf-print-area" style="padding: 32px; background: #fff; font-family: \'Inter\', sans-serif;">' +
                        '<!-- HEADER SECTION -->' +
                        '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 32px; margin-bottom: 16px;">' +
                            '<div>' +
                                '<div style="font-size: 11px; font-weight: 500; color: var(--navy);">Đơn vị: <span style="font-weight: 700; font-size: 12px;">Công ty TNHH Thương Mại ABC</span></div>' +
                                '<div style="font-size: 11px; color: rgba(16, 55, 92, 0.60);">Bộ phận: Kho Trung Tâm</div>' +
                            '</div>' +
                            '<div style="text-align: right;">' +
                                '<div style="font-size: 10px; color: rgba(16, 55, 92, 0.60);">Mẫu số 08-VT</div>' +
                                '<div style="font-size: 10px; color: rgba(16, 55, 92, 0.60);">(Ban hành theo Thông tư số 200/2014/TT-BTC)</div>' +
                            '</div>' +
                        '</div>' +

                        '<div style="text-align: center; margin-bottom: 8px;">' +
                            '<h1 style="margin: 0; font-size: 22px; font-weight: 700; color: var(--navy); letter-spacing: -0.01em;">PHIẾU KIỂM KÊ KHO</h1>' +
                            '<div style="font-size: 13px; font-weight: 500; color: rgba(16, 55, 92, 0.60); margin-top: 2px;">PHYSICAL INVENTORY COUNT SHEET</div>' +
                        '</div>' +

                        '<div style="text-align: center; margin-bottom: 24px; font-size: 12px; color: rgba(16, 55, 92, 0.60);">' +
                            'Ngày <span style="border-bottom: 1px dashed rgba(16, 55, 92, 0.3); padding: 0 8px;">' + day + '</span> tháng ' +
                            '<span style="border-bottom: 1px dashed rgba(16, 55, 92, 0.3); padding: 0 8px;">' + month + '</span> năm ' +
                            '<span style="border-bottom: 1px dashed rgba(16, 55, 92, 0.3); padding: 0 8px;">' + year + '</span>' +
                        '</div>' +

                        '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 24px;">' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Số Phiếu Kiểm Kê</label>' +
                                '<div style="display: flex; align-items: center; gap: 12px;">' +
                                    '<span style="font-size: 16px; font-weight: 700; color: var(--navy);">' + escapeHtml(doc.id) + '</span>' +
                                    '<div style="border: 1px solid var(--border); border-radius: var(--radius-btn); padding: 4px 8px; background: #fff;">' +
                                        '<div style="height: 40px; width: 112px; background: rgba(16, 55, 92, 0.05); display: flex; align-items: center; justify-content: center; font-family: monospace; font-size: 9px; color: rgba(16, 55, 92, 0.40);">||||| ' + escapeHtml(doc.id) + ' |||||</div>' +
                                    '</div>' +
                                '</div>' +
                            '</div>' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Khu Vực Kiểm Kê</label>' +
                                '<div style="font-size: 14px; font-weight: 600; color: var(--navy);">' + escapeHtml(doc.warehouse) + '</div>' +
                            '</div>' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Trạng Thái</label>' +
                                '<span style="display: inline-block; padding: 4px 10px; font-size: 12px; font-weight: 700; color: #1d4ed8; background: #eff6ff; border: 1px solid #bfdbfe; border-radius: var(--radius-btn);">' + escapeHtml(doc.status) + '</span>' +
                            '</div>' +
                        '</div>' +

                        '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px;">' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Người Phụ Trách Kiểm Kê</label>' +
                                '<div style="border-bottom: 1px solid rgba(16, 55, 92, 0.2); padding-bottom: 4px;">' +
                                    '<span style="font-size: 14px; color: var(--navy);">' + escapeHtml(doc.createdBy) + '</span>' +
                                '</div>' +
                            '</div>' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Phương Pháp Kiểm Kê</label>' +
                                '<div style="border-bottom: 1px solid rgba(16, 55, 92, 0.2); padding-bottom: 4px;">' +
                                    '<span style="font-size: 14px; font-weight: 600; color: var(--navy);">Kiểm kê định kỳ toàn bộ</span>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +

                        '<!-- LINE ITEMS -->' +
                        '<div style="margin-bottom: 24px;">' +
                            '<h2 style="font-size: 15px; font-weight: 700; color: var(--navy); margin-bottom: 16px;">Bảng Kiểm Kê Hàng Hóa (Phân Tích Chênh Lệch)</h2>' +
                            '<table class="pdf-table" style="width: 100%; border-collapse: collapse; border: 2px solid rgba(16, 55, 92, 0.15); margin-bottom: 24px;">' +
                                '<thead>' +
                                    '<tr style="background: var(--alice); border-bottom: 2px solid rgba(16, 55, 92, 0.15);">' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; width: 35px;">STT</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Mã SKU</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Tên Sản Phẩm</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">ĐVT</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; background: #eff6ff; color: #1d4ed8;">SL Sổ Sách</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; background: rgba(235, 131, 23, 0.05);">SL Thực Tế</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">Chênh Lệch</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Ghi Chú / Nguyên Nhân</th>' +
                                    '</tr>' +
                                '</thead>' +
                                '<tbody>' +
                                    rowsHtml +
                                    '<tr style="background: rgba(240, 244, 250, 0.35); font-weight: 700; border-top: 2px solid rgba(16, 55, 92, 0.30);">' +
                                        '<td colspan="4" style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: right; font-size: 13px; color: var(--navy);">TỔNG CỘNG:</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 15px; background: #eff6ff; color: #1d4ed8;">' + totalBook.toLocaleString('vi-VN') + '</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 15px; background: rgba(235, 131, 23, 0.05); color: var(--navy);">' + totalActual.toLocaleString('vi-VN') + '</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 15px; color: ' + totalDiffColor + ';">' + totalDiffText + '</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px;"></td>' +
                                    '</tr>' +
                                '</tbody>' +
                            '</table>' +
                        '</div>' +

                        '<!-- FOOTER -->' +
                        '<div style="display: flex; flex-direction: column; gap: 24px;">' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 8px;">Kết Luận Sau Kiểm Kê / Đề Xuất Xử Lý</label>' +
                                '<div style="border: 1px solid #E5EAF3; padding: 16px; min-height: 80px; border-radius: var(--radius-btn);">' +
                                    '<div style="display: flex; flex-direction: column; gap: 8px;">' +
                                        '<div style="border-bottom: 1px dashed rgba(16, 55, 92, 0.1); padding-bottom: 4px;"></div>' +
                                        '<div style="border-bottom: 1px dashed rgba(16, 55, 92, 0.1); padding-bottom: 4px;"></div>' +
                                        '<div style="border-bottom: 1px dashed rgba(16, 55, 92, 0.1); padding-bottom: 4px;"></div>' +
                                    '</div>' +
                                '</div>' +
                            '</div>' +

                            '<div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; padding-top: 16px; text-align: center;">' +
                                '<div>' +
                                    '<label style="display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 12px;">Người Kiểm Kê</label>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 40px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 12px;">Thủ Kho</label>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 40px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 12px;">Kế Toán Kho</label>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 40px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 12px;">Quản Lý Kho</label>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 40px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                    '</div>';

            } else if (doc.type === "Phiếu Chuyển Kho") {
                // Render TR Title
                detailModalTitleArea.innerHTML = '<h3 class="modal-title" style="font-size: 16px; font-weight: 700; color: var(--navy);">Chi tiết Phiếu Chuyển Kho</h3>';

                var totalItems = doc.items || 8;
                var item1Qty = Math.max(1, Math.ceil(totalItems * 0.65));
                var item2Qty = Math.max(0, totalItems - item1Qty);

                var items = [];
                items.push({
                    stt: 1,
                    sku: "978-0545162074",
                    name: "Gương soi cầm tay mini",
                    uom: "Cái",
                    lot: "LOT-2024-05-20",
                    requested: item1Qty,
                    transferred: item1Qty,
                    remark: ""
                });
                if (item2Qty > 0) {
                    items.push({
                        stt: 2,
                        sku: "978-8935235670891",
                        name: "Lược chải tóc gỡ rối",
                        uom: "Cái",
                        lot: "LOT-2024-04-15",
                        requested: item2Qty,
                        transferred: item2Qty,
                        remark: ""
                    });
                }

                var totalRequested = 0;
                var totalTransferred = 0;
                var rowsHtml = "";

                for (var i = 0; i < items.length; i++) {
                    var it = items[i];
                    totalRequested += it.requested;
                    totalTransferred += it.transferred;

                    rowsHtml += '<tr style="line-height: 2.0;">' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; text-align: center;">' + it.stt + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; font-family: monospace; color: rgba(16, 55, 92, 0.70);">' + it.sku + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; color: var(--navy);">' + it.name + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 12px; text-align: center;">' + it.uom + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; text-align: center; font-family: monospace; color: rgba(16, 55, 92, 0.70);">' + it.lot + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 14px; font-weight: 600; text-align: center; background: #eff6ff; color: #1d4ed8;">' + it.requested + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 16px; font-weight: 800; text-align: center; background: #ecfdf5; color: #047857;">' + it.transferred + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 12px; color: rgba(16, 55, 92, 0.70);">' + (it.remark ? it.remark : '<div style="border-bottom: 1px dashed rgba(16, 55, 92, 0.2); padding-bottom: 4px;"></div>') + '</td>' +
                    '</tr>';
                }

                var fromWh = "Kho HCM - Quận 1";
                var fromWhCode = "WH-HCM-01";
                var toWh = "Kho HCM - Quận 7";
                var toWhCode = "WH-HCM-07";

                var whText = doc.warehouse || "";
                if (whText.indexOf(" → ") !== -1) {
                    var whParts = whText.split(" → ");
                    var srcPart = whParts[0];
                    var dstPart = whParts[1];

                    if (srcPart.indexOf("HN") !== -1) {
                        fromWh = "Kho Hà Nội";
                        fromWhCode = "WH-HN-01";
                    } else if (srcPart.indexOf("HCM-01") !== -1) {
                        fromWh = "Kho HCM - Quận 1";
                        fromWhCode = "WH-HCM-01";
                    } else {
                        fromWh = srcPart;
                        fromWhCode = "WH-SRC";
                    }

                    if (dstPart.indexOf("HCM-07") !== -1) {
                        toWh = "Kho HCM - Quận 7";
                        toWhCode = "WH-HCM-07";
                    } else if (dstPart.indexOf("HCM-01") !== -1) {
                        toWh = "Kho HCM - Quận 1";
                        toWhCode = "WH-HCM-01";
                    } else {
                        toWh = dstPart;
                        toWhCode = "WH-DST";
                    }
                }

                detailModalBody.innerHTML = 
                    '<div class="pdf-print-area" style="padding: 32px; background: #fff; font-family: \'Inter\', sans-serif;">' +
                        '<!-- HEADER SECTION -->' +
                        '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 32px; margin-bottom: 16px;">' +
                            '<div>' +
                                '<div style="font-size: 11px; font-weight: 500; color: var(--navy);">Đơn vị: <span style="font-weight: 700; font-size: 12px;">Hệ thống Bán hàng ABC</span></div>' +
                                '<div style="font-size: 11px; color: rgba(16, 55, 92, 0.60);">Bộ phận: Vận Hành Kho</div>' +
                            '</div>' +
                            '<div style="text-align: right;">' +
                                '<div style="font-size: 10px; color: rgba(16, 55, 92, 0.60);">Mẫu số TR-WMS</div>' +
                                '<div style="font-size: 10px; color: rgba(16, 55, 92, 0.60);">Internal Transfer Note</div>' +
                            '</div>' +
                        '</div>' +

                        '<div style="text-align: center; margin-bottom: 8px;">' +
                            '<h1 style="margin: 0; font-size: 22px; font-weight: 700; color: var(--navy); letter-spacing: -0.01em;">PHIẾU CHUYỂN KHO</h1>' +
                            '<div style="font-size: 13px; font-weight: 500; color: rgba(16, 55, 92, 0.60); margin-top: 2px;">INTERNAL STOCK TRANSFER NOTE (STN)</div>' +
                        '</div>' +

                        '<div style="text-align: center; margin-bottom: 24px; font-size: 12px; color: rgba(16, 55, 92, 0.60);">' +
                            'Ngày <span style="border-bottom: 1px dashed rgba(16, 55, 92, 0.3); padding: 0 8px;">' + day + '</span> tháng ' +
                            '<span style="border-bottom: 1px dashed rgba(16, 55, 92, 0.3); padding: 0 8px;">' + month + '</span> năm ' +
                            '<span style="border-bottom: 1px dashed rgba(16, 55, 92, 0.3); padding: 0 8px;">' + year + '</span>' +
                        '</div>' +

                        '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 24px;">' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Số Phiếu Chuyển Kho</label>' +
                                '<div style="display: flex; align-items: center; gap: 12px;">' +
                                    '<span style="font-size: 16px; font-weight: 700; color: var(--navy);">' + escapeHtml(doc.id) + '</span>' +
                                    '<div style="border: 1px solid var(--border); border-radius: var(--radius-btn); padding: 4px 8px; background: #fff;">' +
                                        '<div style="height: 40px; width: 112px; background: rgba(16, 55, 92, 0.05); display: flex; align-items: center; justify-content: center; font-family: monospace; font-size: 9px; color: rgba(16, 55, 92, 0.40);">||||| ' + escapeHtml(doc.id) + ' |||||</div>' +
                                    '</div>' +
                                '</div>' +
                            '</div>' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Trạng Thái</label>' +
                                '<span style="display: inline-block; padding: 4px 10px; font-size: 12px; font-weight: 700; color: var(--orange); background: rgba(235, 131, 23, 0.08); border: 1px solid rgba(235, 131, 23, 0.20); border-radius: var(--radius-btn);">' + escapeHtml(doc.status) + '</span>' +
                            '</div>' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Ngày Yêu Cầu Hoàn Thành</label>' +
                                '<div style="font-size: 14px; font-weight: 600; color: var(--navy);">25/05/2026</div>' +
                            '</div>' +
                        '</div>' +

                        '<!-- Kho nguồn & kho đích - highlight đặc biệt -->' +
                        '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px;">' +
                            '<div style="background: #eff6ff; border: 1px solid #bfdbfe; padding: 16px; border-radius: var(--radius-btn);">' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: #1d4ed8; letter-spacing: 0.05em; margin-bottom: 8px;">🏭 KHO NGUỒN (From)</label>' +
                                '<div style="font-size: 16px; font-weight: 700; color: var(--navy);">' + escapeHtml(fromWh) + '</div>' +
                                '<div style="font-size: 11px; font-family: monospace; color: rgba(16, 55, 92, 0.60); margin-top: 2px;">' + escapeHtml(fromWhCode) + '</div>' +
                                '<div style="font-size: 12px; color: rgba(16, 55, 92, 0.50); margin-top: 4px;">Khu A - Hàng Thường</div>' +
                            '</div>' +
                            '<div style="background: #ecfdf5; border: 1px solid #a7f3d0; padding: 16px; border-radius: var(--radius-btn);">' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: #047857; letter-spacing: 0.05em; margin-bottom: 8px;">🎯 KHO ĐÍCH (To)</label>' +
                                '<div style="font-size: 16px; font-weight: 700; color: var(--navy);">' + escapeHtml(toWh) + '</div>' +
                                '<div style="font-size: 11px; font-family: monospace; color: rgba(16, 55, 92, 0.60); margin-top: 2px;">' + escapeHtml(toWhCode) + '</div>' +
                                '<div style="font-size: 12px; color: rgba(16, 55, 92, 0.50); margin-top: 4px;">Khu A - Hàng Thường</div>' +
                            '</div>' +
                        '</div>' +

                        '<div style="margin-bottom: 24px;">' +
                            '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Lý Do / Ghi Chú Điều Chuyển</label>' +
                            '<div style="border-bottom: 1px solid rgba(16, 55, 92, 0.2); padding-bottom: 4px;">' +
                                '<span style="font-size: 14px; font-weight: 500; color: var(--navy);">Cân bằng tồn kho giữa các chi nhánh — Bổ sung hàng thiếu tại ' + escapeHtml(toWh) + '</span>' +
                            '</div>' +
                        '</div>' +

                        '<!-- LINE ITEMS -->' +
                        '<div style="margin-bottom: 24px;">' +
                            '<h2 style="font-size: 15px; font-weight: 700; color: var(--navy); margin-bottom: 16px;">Danh Sách Hàng Hóa Điều Chuyển</h2>' +
                            '<table class="pdf-table" style="width: 100%; border-collapse: collapse; border: 2px solid rgba(16, 55, 92, 0.15); margin-bottom: 24px;">' +
                                '<thead>' +
                                    '<tr style="background: var(--alice); border-bottom: 2px solid rgba(16, 55, 92, 0.15);">' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; width: 35px;">STT</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Mã SKU</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Tên Sản Phẩm</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">ĐVT</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">Số Lô</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; background: #eff6ff; color: #1d4ed8;">SL Yêu Cầu</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; background: #ecfdf5; color: #047857;">SL Thực Chuyển</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Ghi Chú</th>' +
                                    '</tr>' +
                                '</thead>' +
                                '<tbody>' +
                                    rowsHtml +
                                    '<tr style="background: rgba(240, 244, 250, 0.35); font-weight: 700; border-top: 2px solid rgba(16, 55, 92, 0.30);">' +
                                        '<td colspan="5" style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: right; font-size: 13px; color: var(--navy);">TỔNG CỘNG:</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 15px; background: #eff6ff; color: #1d4ed8;">' + totalRequested + '</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 15px; background: #ecfdf5; color: #047857;">' + totalTransferred + '</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px;"></td>' +
                                    '</tr>' +
                                '</tbody>' +
                            '</table>' +
                        '</div>' +

                        '<!-- FOOTER -->' +
                        '<div style="display: flex; flex-direction: column; gap: 24px;">' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 8px;">Phương Tiện Vận Chuyển / Đơn Vị Vận Chuyển</label>' +
                                '<div style="border: 1px solid #E5EAF3; padding: 16px; min-height: 60px; border-radius: var(--radius-btn);">' +
                                    '<div style="display: flex; flex-direction: column; gap: 8px;">' +
                                        '<div style="border-bottom: 1px dashed rgba(16, 55, 92, 0.1); padding-bottom: 4px;"></div>' +
                                        '<div style="border-bottom: 1px dashed rgba(16, 55, 92, 0.1); padding-bottom: 4px;"></div>' +
                                    '</div>' +
                                '</div>' +
                            '</div>' +

                            '<div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; padding-top: 16px; text-align: center;">' +
                                '<div>' +
                                    '<label style="display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 12px;">Người Lập Phiếu</label>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 40px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 12px;">Thủ Kho Xuất</label>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 40px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 12px;">Thủ Kho Nhận</label>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 40px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 12px;">Quản Lý Duyệt</label>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 40px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                    '</div>';

            } else if (doc.type === "Phiếu Hoàn Hàng") {
                // Render RMA Title with QC Needed badge
                detailModalTitleArea.innerHTML = 
                    '<div style="display: flex; align-items: center; gap: 12px;">' +
                        '<h3 class="modal-title" style="font-size: 16px; font-weight: 700; color: var(--navy);">Chi tiết Phiếu Nhận Hàng Hoàn / RMA</h3>' +
                        '<span class="inline-flex items-center gap-1 px-2.5 py-1 bg-red-50 text-red-600 font-semibold" style="border-radius: var(--radius-btn); font-size: 11px;">' +
                            '<svg style="width:12px;height:12px" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" x2="12.01" y1="17" y2="17"/></svg>' +
                            'Cần xử lý QC' +
                        '</span>' +
                    '</div>';

                var totalItems = doc.items || 5;
                var combReturned = Math.max(0, Math.floor(totalItems * 0.4));
                var mirrorReturned = Math.max(1, totalItems - combReturned);

                var items = [];
                items.push({
                    stt: 1,
                    sku: "978-0545162074",
                    name: "Gương soi cầm tay mini",
                    uom: "Cái",
                    returned: mirrorReturned,
                    reuse: 0,
                    destroy: mirrorReturned,
                    price: 150000,
                    remark: "Bề mặt nứt vỡ, không bán được"
                });
                if (combReturned > 0) {
                    items.push({
                        stt: 2,
                        sku: "978-8935235670891",
                        name: "Lược chải tóc gỡ rối",
                        uom: "Cái",
                        returned: combReturned,
                        reuse: combReturned,
                        destroy: 0,
                        price: 95000,
                        remark: "Khách đổi ý, hàng còn mới"
                    });
                }

                var totalReturned = 0;
                var totalReuse = 0;
                var totalDestroy = 0;
                var totalValue = 0;
                var rowsHtml = "";

                for (var i = 0; i < items.length; i++) {
                    var it = items[i];
                    totalReturned += it.returned;
                    totalReuse += it.reuse;
                    totalDestroy += it.destroy;
                    var itemVal = it.returned * it.price;
                    totalValue += itemVal;

                    rowsHtml += '<tr style="line-height: 2.0;">' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; text-align: center;">' + it.stt + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; font-family: monospace; color: rgba(16, 55, 92, 0.70);">' + it.sku + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; color: var(--navy); font-weight: 600;">' + it.name + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 12px; text-align: center;">' + it.uom + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 14px; font-weight: 800; text-align: center; color: var(--navy);">' + it.returned + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 14px; font-weight: 800; text-align: center; background: #ecfdf5; color: #047857;">' + it.reuse + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 14px; font-weight: 800; text-align: center; background: #fef2f2; color: #dc2626;">' + 
                            (it.destroy > 0 ? it.destroy : '<span style="color: rgba(16, 55, 92, 0.3);">—</span>') + 
                        '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 13px; font-weight: 600; text-align: right; color: var(--navy);">' + itemVal.toLocaleString("vi-VN") + '</td>' +
                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 11px; color: rgba(16, 55, 92, 0.70);">' + it.remark + '</td>' +
                    '</tr>';
                }

                var totalValueWords = numberToVietnameseWords(totalValue);

                detailModalBody.innerHTML = 
                    '<div class="pdf-print-area" style="padding: 32px; background: #fff; font-family: \'Inter\', sans-serif;">' +
                        '<!-- HEADER SECTION -->' +
                        '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 32px; margin-bottom: 16px;">' +
                            '<div>' +
                                '<div style="font-size: 11px; font-weight: 500; color: var(--navy);">Đơn vị: <span style="font-weight: 700; font-size: 12px;">Công ty TNHH Thương Mại ABC</span></div>' +
                                '<div style="font-size: 11px; color: rgba(16, 55, 92, 0.60);">Bộ phận: Kho / Dịch Vụ Khách Hàng</div>' +
                            '</div>' +
                            '<div style="text-align: right;">' +
                                '<div style="font-size: 10px; color: rgba(16, 55, 92, 0.60);">Mẫu số RMA-VN</div>' +
                                '<div style="font-size: 10px; color: rgba(16, 55, 92, 0.60);">Return Merchandise Authorization</div>' +
                            '</div>' +
                        '</div>' +

                        '<div style="text-align: center; margin-bottom: 8px;">' +
                            '<h1 style="margin: 0; font-size: 22px; font-weight: 700; color: var(--navy); letter-spacing: -0.01em;">PHIẾU NHẬN HÀNG HOÀN / YÊU CẦU RMA</h1>' +
                            '<div style="font-size: 13px; font-weight: 500; color: rgba(16, 55, 92, 0.60); margin-top: 2px;">RETURN MERCHANDISE AUTHORIZATION (RMA)</div>' +
                        '</div>' +

                        '<div style="text-align: center; margin-bottom: 24px; font-size: 12px; color: rgba(16, 55, 92, 0.60);">' +
                            'Ngày <span style="border-bottom: 1px dashed rgba(16, 55, 92, 0.3); padding: 0 8px;">' + day + '</span> tháng ' +
                            '<span style="border-bottom: 1px dashed rgba(16, 55, 92, 0.3); padding: 0 8px;">' + month + '</span> năm ' +
                            '<span style="border-bottom: 1px dashed rgba(16, 55, 92, 0.3); padding: 0 8px;">' + year + '</span>' +
                        '</div>' +

                        '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 24px;">' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Số Phiếu RMA</label>' +
                                '<div style="display: flex; align-items: center; gap: 12px;">' +
                                    '<span style="font-size: 16px; font-weight: 700; color: var(--navy);">' + escapeHtml(doc.id) + '</span>' +
                                    '<div style="border: 1px solid var(--border); border-radius: var(--radius-btn); padding: 4px 8px; background: #fff;">' +
                                        '<div style="height: 40px; width: 112px; background: rgba(16, 55, 92, 0.05); display: flex; align-items: center; justify-content: center; font-family: monospace; font-size: 9px; color: rgba(16, 55, 92, 0.40);">||||| ' + escapeHtml(doc.id) + ' |||||</div>' +
                                    '</div>' +
                                '</div>' +
                            '</div>' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Mã Đơn Hàng Gốc (SO Ref.)</label>' +
                                '<span style="font-size: 16px; font-weight: 700; color: var(--navy);">SO-2026-001234</span>' +
                            '</div>' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Trạng Thái</label>' +
                                '<span style="display: inline-block; padding: 4px 10px; font-size: 12px; font-weight: 700; color: var(--orange); background: rgba(235, 131, 23, 0.08); border: 1px solid rgba(235, 131, 23, 0.20); border-radius: var(--radius-btn);">' + escapeHtml(doc.status) + '</span>' +
                            '</div>' +
                        '</div>' +

                        '<!-- Thông tin khách hàng -->' +
                        '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px;">' +
                            '<div style="background: #fef2f2; border: 1px solid #fca5a5; padding: 16px; border-radius: var(--radius-btn);">' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: #b91c1c; letter-spacing: 0.05em; margin-bottom: 8px;">👤 KHÁCH HÀNG HOÀN TRẢ</label>' +
                                '<div style="font-size: 16px; font-weight: 700; color: var(--navy);">Nguyễn Văn An</div>' +
                                '<div style="font-size: 12px; color: rgba(16, 55, 92, 0.60); margin-top: 2px;">SĐT: 0901 234 567</div>' +
                                '<div style="font-size: 11px; color: rgba(16, 55, 92, 0.50); margin-top: 2px;">Email: an.nguyen@email.com</div>' +
                            '</div>' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 6px;">Lý Do Hoàn Trả (Return Reason)</label>' +
                                '<div style="font-size: 14px; font-weight: 500; color: var(--navy);">Sản phẩm bị lỗi — nứt vỡ vỏ nhựa, mối nối lỏng</div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-top: 12px; margin-bottom: 6px;">Hướng Xử Lý</label>' +
                                '<span style="display: inline-block; padding: 4px 10px; font-size: 12px; font-weight: 700; color: var(--orange); background: rgba(235, 131, 23, 0.08); border: 1px solid rgba(235, 131, 23, 0.20); border-radius: var(--radius-btn);">Hoàn tiền + Tiêu hủy hàng lỗi</span>' +
                            '</div>' +
                        '</div>' +

                        '<!-- LINE ITEMS -->' +
                        '<div style="margin-bottom: 24px;">' +
                            '<h2 style="font-size: 15px; font-weight: 700; color: var(--navy); margin-bottom: 16px;">Danh Sách Hàng Hóa Hoàn Trả (Phân Cấp QC)</h2>' +
                            '<table class="pdf-table" style="width: 100%; border-collapse: collapse; border: 2px solid rgba(16, 55, 92, 0.15); margin-bottom: 24px;">' +
                                '<thead>' +
                                    '<tr style="background: var(--alice); border-bottom: 2px solid rgba(16, 55, 92, 0.15);">' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; width: 35px;">STT</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Mã SKU</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Tên Sản Phẩm</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">ĐVT</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center;">SL Hoàn</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; background: #ecfdf5; color: #047857;">SL Dùng Lại</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: center; background: #fef2f2; color: #dc2626;">SL Tiêu Hủy</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: right;">Giá Trị Hoàn</th>' +
                                        '<th style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); text-align: left;">Lý Do / Mã Lỗi</th>' +
                                    '</tr>' +
                                '</thead>' +
                                '<tbody>' +
                                    rowsHtml +
                                    '<tr style="background: rgba(240, 244, 250, 0.35); font-weight: 700; border-top: 2px solid rgba(16, 55, 92, 0.30);">' +
                                        '<td colspan="4" style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: right; font-size: 13px; color: var(--navy);">TỔNG CỘNG:</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 15px; color: var(--navy);">' + totalReturned + '</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 15px; background: #ecfdf5; color: #047857;">' + totalReuse + '</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: center; font-size: 15px; background: #fef2f2; color: #dc2626;">' + totalDestroy + '</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px; text-align: right; font-size: 14px; color: var(--navy);">' + totalValue.toLocaleString("vi-VN") + '</td>' +
                                        '<td style="border: 1px solid rgba(16, 55, 92, 0.15); padding: 10px 12px;"></td>' +
                                    '</tr>' +
                                '</tbody>' +
                            '</table>' +

                            '<div style="margin-top: 16px; border: 1px solid rgba(16, 55, 92, 0.2); padding: 12px 16px; border-radius: var(--radius-btn);">' +
                                '<span style="font-size: 11px; font-weight: 600; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em;">Tổng Giá Trị Hoàn Trả (Viết bằng chữ): </span>' +
                                '<span style="font-size: 13px; font-weight: 700; color: var(--navy);">' + totalValueWords + '</span>' +
                            '</div>' +
                        '</div>' +

                        '<!-- FOOTER -->' +
                        '<div style="display: flex; flex-direction: column; gap: 24px;">' +
                            '<div>' +
                                '<label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.50); letter-spacing: 0.05em; margin-bottom: 8px;">Nhận Xét Tình Trạng Hàng / Hướng Xử Lý Chi Tiết</label>' +
                                '<div style="border: 1px solid #E5EAF3; padding: 16px; min-height: 80px; border-radius: var(--radius-btn);">' +
                                    '<div style="display: flex; flex-direction: column; gap: 8px;">' +
                                        '<div style="border-bottom: 1px dashed rgba(16, 55, 92, 0.1); padding-bottom: 4px;"></div>' +
                                        '<div style="border-bottom: 1px dashed rgba(16, 55, 92, 0.1); padding-bottom: 4px;"></div>' +
                                        '<div style="border-bottom: 1px dashed rgba(16, 55, 92, 0.1); padding-bottom: 4px;"></div>' +
                                    '</div>' +
                                '</div>' +
                            '</div>' +

                            '<div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; padding-top: 16px; text-align: center;">' +
                                '<div>' +
                                    '<label style="display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 12px;">Khách Hàng Ký Nhận</label>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 40px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 12px;">Nhân Viên Tiếp Nhận</label>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 40px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 12px;">QC Kiểm Duyệt</label>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 40px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                                '<div>' +
                                    '<label style="display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; color: rgba(16, 55, 92, 0.60); letter-spacing: 0.05em; margin-bottom: 12px;">Kế Toán Xác Nhận</label>' +
                                    '<div style="border-bottom: 2px solid rgba(16, 55, 92, 0.1); padding-bottom: 40px; margin-bottom: 8px;"></div>' +
                                    '<span style="font-size: 10px; color: rgba(16, 55, 92, 0.40); font-style: italic;">(Ký, họ tên)</span>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                    '</div>';
            }

            detailOverlay.classList.add('active');
        }

        // Render Table and Badges
        function renderLedger() {
            var list = window.WMS_LEDGER_DATA;

            // 1. Filter
            var filtered = list.filter(function(doc) {
                var matchTab = activeTab === "all" || doc.type === activeTab;
                var matchSearch = searchQuery.trim() === "" || 
                                  doc.id.toLowerCase().indexOf(searchQuery.toLowerCase()) !== -1 ||
                                  doc.type.toLowerCase().indexOf(searchQuery.toLowerCase()) !== -1 ||
                                  doc.createdBy.toLowerCase().indexOf(searchQuery.toLowerCase()) !== -1;
                return matchTab && matchSearch;
            });

            // 2. Count metrics
            var pendingCount = list.filter(function(d) { return needsApproval(d); }).length;
            
            // Tab badges counts
            badgeAll.textContent = list.length;
            badgeGrn.textContent = list.filter(function(d) { return d.type === "Phiếu Nhập Kho"; }).length;
            badgeGi.textContent = list.filter(function(d) { return d.type === "Phiếu Xuất Kho"; }).length;
            badgeKk.textContent = list.filter(function(d) { return d.type === "Phiếu Kiểm Kê"; }).length;
            badgeTr.textContent = list.filter(function(d) { return d.type === "Phiếu Chuyển Kho"; }).length;
            badgeRma.textContent = list.filter(function(d) { return d.type === "Phiếu Hoàn Hàng"; }).length;

            // Inactive tabs pending counters
            tabBtns.forEach(function(btn) {
                var tabId = btn.getAttribute('data-tab');
                var isBtnActive = btn.classList.contains('active');
                
                // Remove existing dot
                var existingDot = btn.querySelector('.tab-pending-dot');
                if (existingDot) existingDot.remove();

                if (!isBtnActive) {
                    var tabPendingCount = 0;
                    if (tabId === "all") {
                        tabPendingCount = pendingCount;
                    } else {
                        tabPendingCount = list.filter(function(d) { return d.type === tabId && needsApproval(d); }).length;
                    }

                    if (tabPendingCount > 0) {
                        var dot = document.createElement('span');
                        dot.className = "tab-pending-dot";
                        dot.textContent = tabPendingCount;
                        btn.appendChild(dot);
                    }
                }
            });

            // Pending banner toggle
            if (pendingCount > 0) {
                bannerCountText.textContent = pendingCount + " phiếu";
                pendingAlertBanner.style.display = "flex";
            } else {
                pendingAlertBanner.style.display = "none";
            }

            showingCountEl.innerHTML = 'Hiển thị <strong class="text-navy">' + filtered.length + '</strong> / ' + list.length + ' chứng từ';

            // Clear table
            ledgerTableBody.innerHTML = "";

            if (filtered.length === 0) {
                var tr = document.createElement('tr');
                var td = document.createElement('td');
                td.colSpan = 8;
                td.style.padding = "0";

                 var empty = document.createElement('div');
                empty.className = "empty-wrapper";
                empty.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/><polyline points="14 2 14 8 20 8"/></svg>' +
                                  '<div class="empty-wrapper-title">' + (searchQuery ? 'Không tìm thấy phiếu phù hợp' : 'Chưa có phiếu nào') + '</div>' +
                                  '<div class="empty-wrapper-desc">Chưa có chứng từ kho nào trong hệ thống.</div>';
                
                td.appendChild(empty);
                tr.appendChild(td);
                ledgerTableBody.appendChild(tr);
                return;
            }

            // Populate rows
            filtered.forEach(function(doc) {
                var tr = document.createElement('tr');
                
                var isPend = needsApproval(doc);
                var isRej = (doc.status === "Từ chối");
                if (isPend) tr.className = "row-pending";
                if (isRej) tr.className = "row-rejected";

                tr.addEventListener('click', function() {
                    openDetailModal(doc);
                });

                var cfg = TYPE_CONFIGS[doc.type] || { colorClass: "theme-grn", badgeClass: "type-badge-grn", shortName: doc.type, icon: "" };

                // Col 1: Mã Phiếu
                var tdCode = document.createElement('td');
                tdCode.style.paddingLeft = "20px";
                tdCode.innerHTML = '<div class="code-cell">' +
                                     '<div class="type-icon-wrapper ' + cfg.colorClass + '">' + cfg.icon + '</div>' +
                                     '<span class="doc-id">' + escapeHtml(doc.id) + '</span>' +
                                   '</div>';
                tr.appendChild(tdCode);

                // Col 2: Loại chứng từ
                var tdType = document.createElement('td');
                tdType.innerHTML = '<span class="type-badge ' + cfg.badgeClass + '">' + escapeHtml(cfg.shortName) + '</span>';
                tr.appendChild(tdType);

                // Col 3: Khu vực / Kho
                var tdWarehouse = document.createElement('td');
                tdWarehouse.innerHTML = '<div class="area-cell">' +
                                           '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m22 8-6 4H4.6A2.6 2.6 0 0 1 2 9.4V4.6A2.6 2.6 0 0 1 4.6 2h14.8A2.6 2.6 0 0 1 22 4.6Z"/><path d="M2 8V20a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V8"/><path d="M12 11h4"/></svg>' +
                                           '<span class="area-text" title="' + escapeHtml(doc.warehouse) + '">' + escapeHtml(doc.warehouse) + '</span>' +
                                         '</div>';
                tr.appendChild(tdWarehouse);

                // Col 4: Người tạo
                var tdCreator = document.createElement('td');
                tdCreator.textContent = doc.createdBy;
                tr.appendChild(tdCreator);

                // Col 5: Ngày tạo
                var tdDate = document.createElement('td');
                tdDate.innerHTML = '<div class="date-cell">' +
                                      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="18" x="3" y="4" rx="2" ry="2"/><line x1="16" x2="16" y1="2" y2="6"/><line x1="8" x2="8" y1="2" y2="6"/><line x1="3" x2="21" y1="10" y2="10"/></svg>' +
                                      '<span>' + doc.date + '</span>' +
                                    '</div>';
                tr.appendChild(tdDate);

                // Col 6: Số mặt hàng
                var tdItems = document.createElement('td');
                tdItems.style.textAlign = "right";
                tdItems.innerHTML = '<span class="items-count">' + doc.items + '</span>';
                tr.appendChild(tdItems);

                // Col 7: Trạng thái
                var tdStatus = document.createElement('td');
                tdStatus.style.textAlign = "center";
                tdStatus.innerHTML = '<span class="status-badge" style="background: color-mix(in srgb, ' + doc.statusColor + ' 12%, transparent); color: ' + doc.statusColor + ';">' +
                                       '<div class="status-badge-dot" style="background: ' + doc.statusColor + ';"></div>' +
                                       escapeHtml(doc.status) +
                                     '</span>';
                tr.appendChild(tdStatus);

                // Col 8: Thao tác
                var tdAction = document.createElement('td');
                tdAction.style.textAlign = "center";
                tdAction.style.paddingRight = "20px";
                tdAction.addEventListener('click', function(e) {
                    e.stopPropagation(); // prevent row click opening details
                });

                var actionsDiv = document.createElement('div');
                actionsDiv.className = "actions-wrap";

                // Eye/View details button always present
                var viewBtn = document.createElement('button');
                viewBtn.className = "btn-action-icon btn-action-eye";
                viewBtn.title = "Xem chứng từ chi tiết";
                viewBtn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0z"/><circle cx="12" cy="12" r="3"/></svg>';
                viewBtn.addEventListener('click', function() {
                    openDetailModal(doc);
                });
                actionsDiv.appendChild(viewBtn);

                if (isPend) {
                    // Approve check button
                    var approveBtn = document.createElement('button');
                    approveBtn.className = "btn-action-icon btn-action-approve";
                    approveBtn.title = "Phê duyệt phiếu";
                    approveBtn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';
                    approveBtn.addEventListener('click', function() {
                        selectedConfirmDoc = doc;
                        approveDocId.textContent = doc.id;
                        approveDocSubtext.textContent = doc.type + " — " + doc.items + " mặt hàng";
                        
                        var explanation = "Sau khi phê duyệt, hệ thống sẽ chính thức ";
                        if (doc.type === "Phiếu Nhập Kho") {
                            explanation += "cộng số lượng tồn kho vật lý.";
                        } else if (doc.type === "Phiếu Xuất Kho") {
                            explanation += "trừ số lượng tồn kho vật lý.";
                        } else if (doc.type === "Phiếu Kiểm Kê") {
                            explanation += "sinh phiếu bù/hủy để cân bằng tồn kho.";
                        } else {
                            explanation += "cập nhật vị trí tồn kho vật lý.";
                        }
                        approveExplanationText.textContent = explanation;

                        approveOverlay.classList.add('active');
                    });
                    actionsDiv.appendChild(approveBtn);

                    // Reject cross button
                    var rejectBtn = document.createElement('button');
                    rejectBtn.className = "btn-action-icon btn-action-reject";
                    rejectBtn.title = "Từ chối phiếu";
                    rejectBtn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>';
                    rejectBtn.addEventListener('click', function() {
                        selectedConfirmDoc = doc;
                        rejectDocId.textContent = doc.id;
                        rejectDocSubtext.textContent = doc.type + " — " + doc.items + " mặt hàng";
                        rejectReasonText.value = "";
                        rejectOverlay.classList.add('active');
                    });
                    actionsDiv.appendChild(rejectBtn);
                } else if (isRej) {
                    var statusIcon = document.createElement('span');
                    statusIcon.style.color = "#dc2626";
                    statusIcon.title = "Đã từ chối";
                    statusIcon.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>';
                    actionsDiv.appendChild(statusIcon);
                }

                tdAction.appendChild(actionsDiv);
                tr.appendChild(tdAction);
                ledgerTableBody.appendChild(tr);
            });
        }

        function padZero(num) {
            return (num < 10 ? '0' : '') + num;
        }

        function escapeHtml(text) {
            if (!text) return "";
            return text.toString()
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#039;");
        }

        // Init table render
        renderLedger();
    })();
</script>
