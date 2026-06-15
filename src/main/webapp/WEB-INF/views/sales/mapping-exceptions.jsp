<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Sales Staff — Trang Quản Lý SKU Chưa Ánh Xạ (Bài 2) --%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sales--mapping-exceptions.css"/>

<div class="me-page">

    <div class="me-header">
        <h2>
            <span>SKU Chưa Ánh Xạ (Mapping Exceptions)</span>
            <span class="me-badge ${unresolvedCount == 0 ? 'zero' : ''}">
                ${unresolvedCount} chưa xử lý
            </span>
        </h2>
        <p>Scheduler (Lazada/Shopee/TikTok) tự động ghi log vào đây khi đơn từ sàn
           chứa SKU không tìm thấy ánh xạ Master SKU nội bộ.</p>
    </div>

    <div class="me-alert">
        <strong>Quy trình xử lý:</strong>
        (1) Vào <a href="${pageContext.request.contextPath}/sales/sku-mapping">SKU Mapping</a>
        để tạo ánh xạ cho SKU lạ →
        (2) Quay lại trang này bấm <strong>"Đã xử lý"</strong> để đánh dấu.
    </div>

    <c:choose>
        <c:when test="${empty exceptions}">
            <div class="me-empty">
                <div class="me-empty-icon">✓</div>
                <h3>Không có SKU lạ nào cần xử lý</h3>
                <p>Toàn bộ SKU từ sàn đã được ánh xạ với Master SKU nội bộ.</p>
            </div>
        </c:when>
        <c:otherwise>
            <table class="me-table">
                <thead>
                    <tr>
                        <th>Kênh</th>
                        <th>Mã SKU từ sàn</th>
                        <th>Mã đơn hàng</th>
                        <th>Lý do</th>
                        <th>Thời gian ghi nhận</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="ex" items="${exceptions}">
                        <tr>
                            <td>
                                <c:set var="platformLower" value="${ex.platform != null ? ex.platform.toLowerCase() : ''}"/>
                                <span class="me-platform
                                    ${platformLower == 'lazada' ? 'me-platform-lazada' : ''}
                                    ${platformLower == 'shopee' ? 'me-platform-shopee' : ''}
                                    ${platformLower == 'tiktok' ? 'me-platform-tiktok' : ''}
                                    ${(platformLower != 'lazada' && platformLower != 'shopee' && platformLower != 'tiktok') ? 'me-platform-other' : ''}">
                                    <c:out value="${ex.channelName != null ? ex.channelName : 'N/A'}"/>
                                </span>
                            </td>
                            <td><span class="me-sku"><c:out value="${ex.externalSku}"/></span></td>
                            <td><c:out value="${ex.orderCode != null ? ex.orderCode : '(không có)'}"/></td>
                            <td><c:out value="${ex.reason != null ? ex.reason : ''}"/></td>
                            <td><c:out value="${ex.createdAt}"/></td>
                            <td>
                                <form method="post" action="${pageContext.request.contextPath}/sales/mapping-exceptions"
                                      style="display:inline">
                                    <input type="hidden" name="action" value="resolve">
                                    <input type="hidden" name="exceptionId" value="${ex.exceptionId}">
                                    <button type="submit" class="me-btn-resolve">Đã xử lý</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:otherwise>
    </c:choose>

</div>
