<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%-- Warehouse — Danh sách đơn PICKING chờ cấp mã vận đơn (concept-aligned redesign) --%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/warehouse--pending-tracking.css"/>

<c:set var="pendingList" value="${pendingList != null ? pendingList : []}"/>
<c:set var="pendingCount" value="${pendingCount != null ? pendingCount : 0}"/>

<div class="pt-page">

    <!-- ══ KPI CARDS ═════════════════════════════════════════════ -->
    <div class="pt-stats-grid-4">
        <div class="pt-kpi-card tone-blue">
            <div class="pt-kpi-card__icon-box">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                    <path d="M14 2v6h6"/>
                    <path d="M9 14h6"/>
                    <path d="M9 18h4"/>
                </svg>
            </div>
            <div class="pt-kpi-card__info">
                <div class="pt-kpi-card__val">${pendingCount}</div>
                <div class="pt-kpi-card__lbl">Đơn chờ cấp tracking</div>
            </div>
        </div>

        <div class="pt-kpi-card tone-orange">
            <div class="pt-kpi-card__icon-box">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"/>
                    <polyline points="12 6 12 12 16 14"/>
                </svg>
            </div>
            <div class="pt-kpi-card__info">
                <div class="pt-kpi-card__val" id="pt-stat-oldest">—</div>
                <div class="pt-kpi-card__lbl">Đơn chờ lâu nhất</div>
            </div>
        </div>

        <div class="pt-kpi-card tone-emerald">
            <div class="pt-kpi-card__icon-box">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                    <polyline points="22 4 12 14.01 9 11.01"/>
                </svg>
            </div>
            <div class="pt-kpi-card__info">
                <div class="pt-kpi-card__val" id="pt-stat-courier">—</div>
                <div class="pt-kpi-card__lbl">ĐVVC phổ biến</div>
            </div>
        </div>

        <div class="pt-kpi-card tone-violet">
            <div class="pt-kpi-card__icon-box">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M2.97 12.92A2 2 0 0 0 2 14.63v3.24a2 2 0 0 0 .97 1.71l3 1.8a2 2 0 0 0 2.06 0L12 19v-5.5l-5-3-4.03 2.42Z"/>
                    <path d="M7 16.5 4.74 16.5"/><path d="M7 16.5 12 13.5"/><path d="M7 16.5 7 21.67"/>
                    <path d="M12 13.5 19 19l3.97 2.38a2 2 0 0 0 2.06 0l3-1.8a2 2 0 0 0 .97-1.71v-3.24a2 2 0 0 0-.97-1.71L17 10.5l-5 3Z"/>
                </svg>
            </div>
            <div class="pt-kpi-card__info">
                <div class="pt-kpi-card__val" id="pt-stat-warehouse">—</div>
                <div class="pt-kpi-card__lbl">Kho đang xử lý</div>
            </div>
        </div>
    </div>

    <!-- ══ TOOLBAR ═══════════════════════════════════════════════ -->
    <div class="pt-toolbar">
        <div class="pt-search-wrap">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="11" cy="11" r="8"/>
                <line x1="21" y1="21" x2="16.65" y2="16.65"/>
            </svg>
            <input type="text" id="ptSearchInput" placeholder="Tìm theo mã đơn, mã ĐVVC, tên khách, SĐT..."/>
        </div>
        <div class="pt-toolbar__right">
            <select class="pt-select" id="ptFilterCourier">
                <option value="">Tất cả ĐVVC</option>
            </select>
            <select class="pt-select" id="ptFilterChannel">
                <option value="">Tất cả kênh</option>
            </select>
        </div>
    </div>

    <!-- ══ QUY TRÌNH (compact info bar) ═══════════════════════════ -->
    <div class="pt-info-bar">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"/>
            <line x1="12" y1="16" x2="12" y2="12"/>
            <line x1="12" y1="8" x2="12.01" y2="8"/>
        </svg>
        <span>
            <strong>Quy trình:</strong>
            Sales duyệt (PICKING) → Đơn xuất hiện ở đây theo kho của bạn → Bấm <em>"Cấp mã vận đơn"</em> để sinh tracking &amp; chuyển PACKED.
        </span>
    </div>

    <!-- ══ TABLE / EMPTY ═════════════════════════════════════════ -->
    <c:choose>
        <c:when test="${empty pendingList}">
            <div class="pt-empty">
                <div class="pt-empty__icon">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                        <polyline points="22 4 12 14.01 9 11.01"/>
                    </svg>
                </div>
                <h3>Không có đơn nào đang chờ cấp tracking</h3>
                <p>Toàn bộ đơn PICKING của kho này đã được cấp mã vận đơn.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="pt-card">
                <table class="pt-table">
                    <thead>
                        <tr>
                            <th style="width:48px;">STT</th>
                            <th>Mã đơn hàng</th>
                            <th>Kênh bán</th>
                            <th>Khách hàng</th>
                            <th>ĐVVC</th>
                            <th>Kho xử lý</th>
                            <th>Trạng thái</th>
                            <th style="width:200px; text-align:right;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody id="ptTbody">
                        <c:forEach var="row" items="${pendingList}" varStatus="st">
                            <tr id="row-${row.orderId}"
                                class="pt-row"
                                data-order-code="<c:out value='${row.orderCode}'/>"
                                data-courier="<c:out value='${row.courierName}'/>"
                                data-channel="<c:out value='${row.platform != null ? row.platform : row.channel}'/>"
                                data-customer="<c:out value='${row.customerName}'/>"
                                data-phone="<c:out value='${row.customerPhone}'/>"
                                data-waybill="<c:out value='${row.waybillCode}'/>">
                                <td><span class="pt-stt">${st.count}</span></td>
                                <td>
                                    <span class="pt-order-code">
                                        <c:out value="${row.orderCode}"/>
                                    </span>
                                </td>
                                <td>
                                    <c:set var="platformLower" value="${row.platform != null ? row.platform.toLowerCase() : (row.channel != null ? row.channel.toLowerCase() : '')}"/>
                                    <span class="pt-platform
                                        ${platformLower == 'lazada' ? 'pt-platform-lazada' : ''}
                                        ${platformLower == 'shopee' ? 'pt-platform-shopee' : ''}
                                        ${platformLower == 'tiktok' ? 'pt-platform-tiktok' : ''}
                                        ${(platformLower != 'lazada' && platformLower != 'shopee' && platformLower != 'tiktok') ? 'pt-platform-other' : ''}">
                                        <c:out value="${row.channelName != null ? row.channelName : (row.channel != null ? row.channel : 'N/A')}"/>
                                    </span>
                                </td>
                                <td>
                                    <div class="pt-customer">
                                        <c:out value="${row.customerName != null ? row.customerName : 'Khách hàng'}"/>
                                    </div>
                                    <div class="pt-customer-phone">
                                        <c:out value="${row.customerPhone != null ? row.customerPhone : ''}"/>
                                    </div>
                                    <div class="pt-address" title="<c:out value='${row.shippingAddress}'/>">
                                        <c:out value="${row.shippingAddress}"/>
                                    </div>
                                </td>
                                <td>
                                    <span class="pt-courier">
                                        <c:out value="${row.courierName != null ? row.courierName : 'Chưa chọn'}"/>
                                    </span>
                                </td>
                                <td>
                                    <span class="pt-warehouse">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <path d="M2.97 12.92A2 2 0 0 0 2 14.63v3.24a2 2 0 0 0 .97 1.71l3 1.8a2 2 0 0 0 2.06 0L12 19v-5.5l-5-3-4.03 2.42Z"/>
                                        </svg>
                                        <c:out value="${row.warehouseName != null ? row.warehouseName : '(chưa gán)'}"/>
                                    </span>
                                </td>
                                <td>
                                    <span class="pt-status-pill">
                                        <span class="pt-status-pill__dot"></span>
                                        PICKING
                                    </span>
                                </td>
                                <td style="text-align:right;">
                                    <c:choose>
                                        <c:when test="${row.channel == 'Lazada' && row.trackingNo != null && !empty row.trackingNo}">
                                            <button class="pt-btn-assign pt-btn-lazada-label" style="background:#0F146D;color:#fff;margin-right:6px"
                                                    data-order-code="<c:out value='${row.orderCode}'/>">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
                                                In tem Lazada
                                            </button>
                                            <button class="pt-btn-assign pt-btn-lazada-rts" style="background:#16a34a;color:#fff;margin-right:6px"
                                                    data-order-code="<c:out value='${row.orderCode}'/>">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 7h11v8H3z"/><path d="M14 10h4l3 3v2h-7z"/><circle cx="7" cy="17" r="2"/><circle cx="17" cy="17" r="2"/></svg>
                                                Kích hoạt RTS
                                            </button>
                                        </c:when>
                                    </c:choose>
                                    <button class="pt-btn-assign"
                                            data-order-code="<c:out value='${row.orderCode}'/>"
                                            data-row-id="row-${row.orderId}">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <path d="M20.59 13.41 13.42 20.58a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/>
                                            <line x1="7" y1="7" x2="7.01" y2="7"/>
                                        </svg>
                                        Cấp mã vận đơn
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:otherwise>
    </c:choose>

</div>

<div id="ptToast" class="pt-toast"></div>

<script>
(function() {
    const ctx = '${pageContext.request.contextPath}';
    const toast = document.getElementById('ptToast');

    function showToast(success, message) {
        toast.className = 'pt-toast ' + (success ? 'success' : 'error');
        toast.textContent = (success ? '✓ ' : '✗ ') + message;
        setTimeout(() => { toast.className = 'pt-toast'; }, 4000);
    }

    // ── Populate filter dropdowns from current rows ──
    function populateFilters() {
        const rows = document.querySelectorAll('#ptTbody .pt-row');
        const couriers = new Set();
        const channels = new Set();
        rows.forEach(r => {
            if (r.dataset.courier)  couriers.add(r.dataset.courier);
            if (r.dataset.channel)  channels.add(r.dataset.channel);
        });

        const courierSel = document.getElementById('ptFilterCourier');
        Array.from(couriers).sort().forEach(c => {
            const opt = document.createElement('option');
            opt.value = c; opt.textContent = c;
            courierSel.appendChild(opt);
        });
        const channelSel = document.getElementById('ptFilterChannel');
        Array.from(channels).sort().forEach(c => {
            const opt = document.createElement('option');
            opt.value = c;
            opt.textContent = c.charAt(0).toUpperCase() + c.slice(1);
            channelSel.appendChild(opt);
        });
    }

    // ── Compute KPI stats from current rows ──
    function computeStats() {
        const rows = Array.from(document.querySelectorAll('#ptTbody .pt-row'));
        if (rows.length === 0) return;

        // ĐVVC phổ biến
        const courierCount = {};
        const warehouseCount = {};
        rows.forEach(r => {
            const c = r.dataset.courier || 'Chưa chọn';
            courierCount[c] = (courierCount[c] || 0) + 1;
            const w = (r.querySelector('.pt-warehouse') || {}).textContent || '';
            const wTrim = w.trim() || 'Chưa gán';
            warehouseCount[wTrim] = (warehouseCount[wTrim] || 0) + 1;
        });
        const topCourier = Object.entries(courierCount).sort((a,b) => b[1] - a[1])[0];
        const topWh      = Object.entries(warehouseCount).sort((a,b) => b[1] - a[1])[0];
        if (topCourier) {
            document.getElementById('pt-stat-courier').textContent = topCourier[0];
        }
        if (topWh) {
            document.getElementById('pt-stat-warehouse').textContent = topWh[0];
        }
        document.getElementById('pt-stat-oldest').textContent = rows.length + ' đơn';
    }

    // ── Client-side search + filter ──
    function applyFilters() {
        const q = (document.getElementById('ptSearchInput').value || '').toLowerCase().trim();
        const courier = document.getElementById('ptFilterCourier').value;
        const channel = document.getElementById('ptFilterChannel').value;
        const rows = document.querySelectorAll('#ptTbody .pt-row');
        rows.forEach(r => {
            const hay = (r.dataset.orderCode + ' ' + r.dataset.courier + ' ' +
                         r.dataset.customer + ' ' + r.dataset.phone + ' ' +
                         r.dataset.waybill).toLowerCase();
            const matchQ       = !q       || hay.indexOf(q) > -1;
            const matchCourier = !courier || r.dataset.courier === courier;
            const matchChannel = !channel || r.dataset.channel === channel;
            r.style.display = (matchQ && matchCourier && matchChannel) ? '' : 'none';
        });
    }

    // ── Assign tracking ──
    document.querySelectorAll('.pt-btn-assign').forEach(btn => {
        btn.addEventListener('click', function() {
            const orderCode = this.dataset.orderCode;
            const rowId = this.dataset.rowId;
            const row = document.getElementById(rowId);
            const button = this;

            if (!confirm('Cấp mã vận đơn cho đơn ' + orderCode + '?\n\nHệ thống sẽ sinh tracking và tạo phiếu xuất kho.')) {
                return;
            }

            button.disabled = true;
            button.classList.add('is-loading');
            const originalHtml = button.innerHTML;
            button.innerHTML = '<span class="pt-spinner"></span>Đang xử lý...';
            row.classList.add('pt-row-processing');

            fetch(ctx + '/warehouse/pending-tracking', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'action=assign&orderCode=' + encodeURIComponent(orderCode)
            })
            .then(r => r.json())
            .then(data => {
                showToast(data.success, data.message);
                if (data.success) {
                    setTimeout(() => {
                        row.style.transition = 'opacity .3s, transform .3s';
                        row.style.opacity = '0';
                        row.style.transform = 'translateX(20px)';
                        setTimeout(() => {
                            row.remove();
                            // Re-compute stats + update count
                            const remaining = document.querySelectorAll('#ptTbody .pt-row').length;
                            const kpiVal = document.querySelector('.pt-kpi-card .pt-kpi-card__val');
                            if (kpiVal) kpiVal.textContent = remaining;
                        }, 320);
                    }, 1500);
                } else {
                    button.disabled = false;
                    button.classList.remove('is-loading');
                    button.innerHTML = originalHtml;
                    row.classList.remove('pt-row-processing');
                }
            })
            .catch(err => {
                showToast(false, 'Lỗi kết nối: ' + err.message);
                button.disabled = false;
                button.classList.remove('is-loading');
                button.innerHTML = originalHtml;
                row.classList.remove('pt-row-processing');
            });
        });
    });

    // ── Lazada end-to-end actions ──
    function printLazadaLabel(orderCode) {
        window.open(ctx + '/lazada/label?orderCode=' + encodeURIComponent(orderCode),
                    '_blank');
    }
    function triggerLazadaRts(orderCode) {
        if (!confirm('Kích hoạt RTS cho đơn Lazada ' + orderCode + '?\nSau khi gọi, đơn sẽ chuyển sang SHIPPED và Lazada sẽ cử ĐVVC đến lấy hàng.')) {
            return;
        }
        fetch(ctx + '/lazada/rts', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'orderCode=' + encodeURIComponent(orderCode)
        })
        .then(r => r.json())
        .then(data => {
            showToast(data.success,
                data.success
                    ? ('RTS OK. Tracking=' + data.trackingNo + ' package=' + data.packageId)
                    : ('RTS thất bại: ' + data.errorMessage));
            if (data.success) setTimeout(() => location.reload(), 1500);
        })
        .catch(err => showToast(false, 'Lỗi: ' + err.message));
    }

    // Wire Lazada buttons (use data-* attributes; cleaner than inline onclick)
    document.querySelectorAll('.pt-btn-lazada-label').forEach(btn => {
        btn.addEventListener('click', function () {
            const code = this.getAttribute('data-order-code');
            if (code) printLazadaLabel(code);
        });
    });
    document.querySelectorAll('.pt-btn-lazada-rts').forEach(btn => {
        btn.addEventListener('click', function () {
            const code = this.getAttribute('data-order-code');
            if (code) triggerLazadaRts(code);
        });
    });

    // ── Wire up filters ──
    document.getElementById('ptSearchInput').addEventListener('input', applyFilters);
    document.getElementById('ptFilterCourier').addEventListener('change', applyFilters);
    document.getElementById('ptFilterChannel').addEventListener('change', applyFilters);

    // ── Init ──
    populateFilters();
    computeStats();
})();
</script>
