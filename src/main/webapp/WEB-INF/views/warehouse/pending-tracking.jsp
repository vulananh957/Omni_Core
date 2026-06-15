<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Warehouse — Danh sách đơn PICKING chờ cấp mã vận đơn --%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/warehouse--pending-tracking.css"/>

<div class="pt-page">

    <div class="pt-header">
        <div>
            <h2>📦 Đơn Chờ Cấp Mã Vận Đơn</h2>
            <p>Đơn đã được Sales duyệt (PICKING) — bạn cấp mã vận đơn &amp; in tem để đóng gói bàn giao ĐVVC.</p>
        </div>
        <span class="pt-badge ${pendingCount == 0 ? 'zero' : ''}">
            ${pendingCount} đơn
        </span>
    </div>

    <div class="pt-alert">
        <strong>Quy trình:</strong>
        Sales duyệt đơn (status = PICKING) → đơn xuất hiện ở đây theo kho của bạn →
        Bấm <strong>"Cấp mã vận đơn"</strong> → hệ thống tự sinh tracking_no (idempotent) &amp; chuyển PACKED.
    </div>

    <c:choose>
        <c:when test="${empty pendingList}">
            <div class="pt-empty">
                <div class="pt-empty-icon">✓</div>
                <h3>Không có đơn nào đang chờ cấp tracking</h3>
                <p>Toàn bộ đơn PICKING của kho này đã được cấp mã vận đơn.</p>
            </div>
        </c:when>
        <c:otherwise>
            <table class="pt-table">
                <thead>
                    <tr>
                        <th>STT</th>
                        <th>Mã đơn hàng</th>
                        <th>Kênh bán</th>
                        <th>Khách hàng</th>
                        <th>ĐVVC</th>
                        <th>Kho xử lý</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="row" items="${pendingList}" varStatus="st">
                        <tr id="row-${row.orderId}">
                            <td>${st.count}</td>
                            <td><span class="pt-order-code"><c:out value="${row.orderCode}"/></span></td>
                            <td>
                                <c:set var="platformLower" value="${row.platform != null ? row.platform.toLowerCase() : ''}"/>
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
                                    <c:out value="${row.courierName != null ? row.courierName : 'Chưa chọn ĐVVC'}"/>
                                </span>
                            </td>
                            <td>
                                <c:out value="${row.warehouseName != null ? row.warehouseName : '(chưa gán)'}"/>
                            </td>
                            <td>
                                <span class="pt-platform pt-platform-other">PICKING</span>
                            </td>
                            <td>
                                <button class="pt-btn-assign"
                                        data-order-code="<c:out value='${row.orderCode}'/>"
                                        data-row-id="row-${row.orderId}">
                                    🏷️ Cấp mã vận đơn
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
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

    document.querySelectorAll('.pt-btn-assign').forEach(btn => {
        btn.addEventListener('click', function() {
            const orderCode = this.dataset.orderCode;
            const rowId = this.dataset.rowId;
            const row = document.getElementById(rowId);
            const button = this;

            if (!confirm('Cấp mã vận đơn cho đơn ' + orderCode + '?\n\nHệ thống sẽ sinh tracking và chuyển đơn sang PACKED.')) {
                return;
            }

            button.disabled = true;
            button.textContent = 'Đang xử lý...';
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
                    // Xóa row sau 1.5s để user thấy toast
                    setTimeout(() => row.remove(), 1500);
                } else {
                    button.disabled = false;
                    button.textContent = '🏷️ Cấp mã vận đơn';
                    row.classList.remove('pt-row-processing');
                }
            })
            .catch(err => {
                showToast(false, 'Lỗi kết nối: ' + err.message);
                button.disabled = false;
                button.textContent = '🏷️ Cấp mã vận đơn';
                row.classList.remove('pt-row-processing');
            });
        });
    });
})();
</script>
