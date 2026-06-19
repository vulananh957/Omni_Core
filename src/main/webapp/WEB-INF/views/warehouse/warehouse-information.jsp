<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/warehouse--warehouse-information.css"/>

<c:if test="${not empty successMessage}">
    <div style="margin-bottom:16px; padding:12px 16px; border-radius:10px; background:#ECFDF5; border:1px solid #A7F3D0; color:#047857; font-size:13px; font-weight:600;">
        <c:out value="${successMessage}"/>
    </div>
</c:if>
<c:if test="${not empty errorMessage}">
    <div style="margin-bottom:16px; padding:12px 16px; border-radius:10px; background:#FEF2F2; border:1px solid #FECACA; color:#b91c1c; font-size:13px; font-weight:600;">
        <c:out value="${errorMessage}"/>
    </div>
</c:if>

<c:choose>
    <c:when test="${empty warehouse}">
        <div class="whinfo-card" style="padding:48px; text-align:center; color:rgba(16,55,92,0.4);">
            Không tìm thấy thông tin kho được phân công.
        </div>
    </c:when>
    <c:otherwise>
        <div class="whinfo-grid">
            <div class="whinfo-field">
                <div class="whinfo-field__lbl">Mã kho</div>
                <div class="whinfo-field__val"><c:out value="${warehouse.warehouseCode}"/></div>
            </div>
            <div class="whinfo-field">
                <div class="whinfo-field__lbl">Tên kho</div>
                <div class="whinfo-field__val"><c:out value="${warehouse.warehouseName}"/></div>
            </div>
            <div class="whinfo-field">
                <div class="whinfo-field__lbl">Trạng thái</div>
                <div class="whinfo-field__val">
                    <c:choose>
                        <c:when test="${warehouse.active}">
                            <span class="whinfo-badge" style="background:#ECFDF5; color:#059669;">Đang hoạt động</span>
                        </c:when>
                        <c:otherwise>
                            <span class="whinfo-badge" style="background:#FEF2F2; color:#ef4444;">Ngừng hoạt động</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="whinfo-field" style="grid-column: span 2;">
                <div class="whinfo-field__lbl">Địa chỉ</div>
                <div class="whinfo-field__val"><c:out value="${not empty warehouse.address ? warehouse.address : '—'}"/></div>
            </div>
            <div class="whinfo-field">
                <div class="whinfo-field__lbl">Số điện thoại</div>
                <div class="whinfo-field__val"><c:out value="${not empty warehouse.phone ? warehouse.phone : '—'}"/></div>
            </div>
            <div class="whinfo-field">
                <div class="whinfo-field__lbl">Sức chứa (đơn vị)</div>
                <div class="whinfo-field__val">
                    <c:out value="${warehouse.capacity > 0 ? warehouse.capacity : '—'}"/>
                </div>
            </div>
        </div>

        <div class="whinfo-card">
            <div class="whinfo-card__hdr">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none"
                     stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/>
                    <rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/>
                </svg>
                <span>Phân khu lưu trữ (Zones) — <c:out value="${fn:length(warehouse.zones)}"/> khu</span>
                <button type="button" onclick="openCreateZone()"
                        style="margin-left:auto; display:inline-flex; align-items:center; gap:6px; padding:8px 14px; background:var(--navy,#10375c); color:#fff; border:none; border-radius:8px; font-size:13px; font-weight:600; cursor:pointer;">
                    + Thêm khu
                </button>
            </div>
            <table class="whinfo-table">
                <thead>
                    <tr>
                        <th style="width:120px;">Mã khu</th>
                        <th>Tên khu</th>
                        <th style="width:140px;">Loại</th>
                        <th>Mô tả</th>
                        <th style="width:120px;">Trạng thái</th>
                        <th style="width:150px; text-align:center;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty warehouse.zones}">
                            <tr><td colspan="6" style="text-align:center; padding:32px; color:rgba(16,55,92,0.4);">Chưa có phân khu nào.</td></tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="z" items="${warehouse.zones}">
                                <tr>
                                    <td style="font-family:monospace; font-weight:600;"><c:out value="${z.zoneCode}"/></td>
                                    <td style="font-weight:600;"><c:out value="${z.zoneName}"/></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${z.zoneType == 'NORMAL'}"><span class="whinfo-badge" style="background:#ECFDF5; color:#059669;">Khu thường</span></c:when>
                                            <c:when test="${z.zoneType == 'RETURN'}"><span class="whinfo-badge" style="background:#EFF6FF; color:#2563eb;">Khu trả hàng</span></c:when>
                                            <c:when test="${z.zoneType == 'DAMAGED'}"><span class="whinfo-badge" style="background:rgba(245,200,66,0.15); color:#d9a000;">Khu hỏng</span></c:when>
                                            <c:when test="${z.zoneType == 'DESTROY'}"><span class="whinfo-badge" style="background:#FEF2F2; color:#ef4444;">Khu tiêu hủy</span></c:when>
                                            <c:otherwise><span class="whinfo-badge" style="background:rgba(16,55,92,0.08); color:var(--navy,#10375c);"><c:out value="${z.zoneType}"/></span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="color:rgba(16,55,92,0.6);"><c:out value="${not empty z.description ? z.description : '—'}"/></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${z.active}"><span style="color:#059669; font-weight:600;">Hoạt động</span></c:when>
                                            <c:otherwise><span style="color:rgba(16,55,92,0.4);">Ngừng</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="text-align:center; white-space:nowrap;">
                                        <button type="button"
                                                data-id="${z.zoneId}" data-code="${fn:escapeXml(z.zoneCode)}"
                                                data-name="${fn:escapeXml(z.zoneName)}" data-type="${z.zoneType}"
                                                data-desc="${fn:escapeXml(z.description)}"
                                                onclick="openEditZone(this)"
                                                style="padding:5px 10px; margin-right:4px; background:rgba(16,55,92,0.06); color:var(--navy,#10375c); border:1px solid rgba(16,55,92,0.12); border-radius:6px; font-size:12px; font-weight:600; cursor:pointer;">Sửa</button>
                                        <c:choose>
                                            <c:when test="${not z['default']}">
                                                <form method="post" action="${pageContext.request.contextPath}/warehouse/information"
                                                      style="display:inline;" onsubmit="return confirm('Xóa khu này?');">
                                                    <input type="hidden" name="action" value="deleteZone"/>
                                                    <input type="hidden" name="zoneId" value="${z.zoneId}"/>
                                                    <button type="submit"
                                                            style="padding:5px 10px; background:#FEF2F2; color:#ef4444; border:1px solid #FECACA; border-radius:6px; font-size:12px; font-weight:600; cursor:pointer;">Xóa</button>
                                                </form>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="font-size:11px; color:rgba(16,55,92,0.35);">(mặc định)</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <div class="whinfo-note">
            Mã, tên, địa chỉ kho do Quản lý thiết lập. Nhân viên kho quản lý các phân khu lưu trữ tại đây.
            Khu mặc định của hệ thống không thể xóa.
        </div>

        <div id="zoneModalOverlay" onclick="if(event.target===this)closeZoneModal()"
             style="display:none; position:fixed; inset:0; background:rgba(16,55,92,0.45); z-index:1000; align-items:center; justify-content:center;">
            <div style="background:#fff; width:440px; max-width:92vw; border-radius:14px; overflow:hidden;">
                <div style="padding:16px 20px; border-bottom:1px solid var(--border,#e5eaf3); font-size:16px; font-weight:700; color:var(--navy,#10375c);">
                    <span id="zoneModalTitle">Thêm khu</span>
                </div>
                <form method="post" action="${pageContext.request.contextPath}/warehouse/information" style="padding:20px;">
                    <input type="hidden" name="action" id="zoneFormAction" value="createZone"/>
                    <input type="hidden" name="zoneId" id="zoneFormId"/>

                    <label style="display:block; font-size:12px; font-weight:600; color:rgba(16,55,92,0.6); margin-bottom:4px;">Mã khu</label>
                    <input type="text" name="zoneCode" id="zoneFormCode" required maxlength="50"
                           style="width:100%; padding:9px 12px; border:1px solid var(--border,#e5eaf3); border-radius:8px; margin-bottom:14px; font-size:13px; box-sizing:border-box;"/>

                    <label style="display:block; font-size:12px; font-weight:600; color:rgba(16,55,92,0.6); margin-bottom:4px;">Tên khu</label>
                    <input type="text" name="zoneName" id="zoneFormName" required maxlength="100"
                           style="width:100%; padding:9px 12px; border:1px solid var(--border,#e5eaf3); border-radius:8px; margin-bottom:14px; font-size:13px; box-sizing:border-box;"/>

                    <label style="display:block; font-size:12px; font-weight:600; color:rgba(16,55,92,0.6); margin-bottom:4px;">Loại khu</label>
                    <select name="zoneType" id="zoneFormType"
                            style="width:100%; padding:9px 12px; border:1px solid var(--border,#e5eaf3); border-radius:8px; margin-bottom:14px; font-size:13px; box-sizing:border-box;">
                        <option value="NORMAL">Khu thường</option>
                        <option value="RETURN">Khu trả hàng</option>
                        <option value="DAMAGED">Khu hỏng</option>
                        <option value="DESTROY">Khu tiêu hủy</option>
                    </select>

                    <label style="display:block; font-size:12px; font-weight:600; color:rgba(16,55,92,0.6); margin-bottom:4px;">Mô tả</label>
                    <textarea name="description" id="zoneFormDesc" rows="2"
                              style="width:100%; padding:9px 12px; border:1px solid var(--border,#e5eaf3); border-radius:8px; margin-bottom:18px; font-size:13px; resize:vertical; box-sizing:border-box;"></textarea>

                    <div style="display:flex; justify-content:flex-end; gap:10px;">
                        <button type="button" onclick="closeZoneModal()"
                                style="padding:9px 16px; background:#fff; color:var(--navy,#10375c); border:1px solid var(--border,#e5eaf3); border-radius:8px; font-size:13px; font-weight:600; cursor:pointer;">Hủy</button>
                        <button type="submit"
                                style="padding:9px 16px; background:var(--navy,#10375c); color:#fff; border:none; border-radius:8px; font-size:13px; font-weight:600; cursor:pointer;">Lưu</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            function openCreateZone() {
                document.getElementById('zoneModalTitle').textContent = 'Thêm khu';
                document.getElementById('zoneFormAction').value = 'createZone';
                document.getElementById('zoneFormId').value = '';
                var code = document.getElementById('zoneFormCode');
                code.value = ''; code.readOnly = false; code.style.background = '#fff';
                document.getElementById('zoneFormName').value = '';
                document.getElementById('zoneFormType').value = 'NORMAL';
                document.getElementById('zoneFormDesc').value = '';
                document.getElementById('zoneModalOverlay').style.display = 'flex';
            }
            function openEditZone(btn) {
                document.getElementById('zoneModalTitle').textContent = 'Sửa khu';
                document.getElementById('zoneFormAction').value = 'updateZone';
                document.getElementById('zoneFormId').value = btn.getAttribute('data-id');
                var code = document.getElementById('zoneFormCode');
                code.value = btn.getAttribute('data-code');
                code.readOnly = true; code.style.background = 'rgba(16,55,92,0.05)';
                document.getElementById('zoneFormName').value = btn.getAttribute('data-name');
                document.getElementById('zoneFormType').value = btn.getAttribute('data-type') || 'NORMAL';
                document.getElementById('zoneFormDesc').value = btn.getAttribute('data-desc') || '';
                document.getElementById('zoneModalOverlay').style.display = 'flex';
            }
            function closeZoneModal() {
                document.getElementById('zoneModalOverlay').style.display = 'none';
            }
        </script>
    </c:otherwise>
</c:choose>
