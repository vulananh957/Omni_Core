<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="user-form-container" style="max-width: 48rem; margin: 0 auto; padding-bottom: 3rem;">

    <!-- Page Header (Back Arrow + Breadcrumb) -->
    <div style="display: flex; align-items: center; gap: 0.5rem; margin-bottom: 1.25rem;">
        <a href="${pageContext.request.contextPath}/admin/users" 
           style="width: 2rem; height: 2rem; background: var(--white); border: 1px solid var(--border); border-radius: var(--radius-btn); color: var(--navy); text-decoration: none; display: flex; align-items: center; justify-content: center; transition: background 0.15s;">
            <svg style="width: 16px; height: 16px;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <line x1="19" y1="12" x2="5" y2="12"></line>
                <polyline points="12 19 5 12 12 5"></polyline>
            </svg>
        </a>
        <span style="color: rgba(16, 55, 92, 0.45); font-size: 12px; font-weight: 600;">Quay lại Danh sách người dùng</span>
    </div>

    <!-- Error Alert Banner -->
    <c:if test="${not empty errorMessage}">
        <div style="padding: 1rem 1.25rem; background: #fee2e2; border: 1px solid rgba(239, 68, 68, 0.2); border-left: 4px solid #ef4444; border-radius: var(--radius-btn); margin-bottom: 1.25rem; display: flex; align-items: center; gap: 0.75rem;">
            <span style="font-weight: bold; width: 1.5rem; height: 1.5rem; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; background: #ef4444; font-size: 11px;">!</span>
            <span style="color: #b91c1c; font-size: 13px; font-weight: 600;"><c:out value="${errorMessage}"/></span>
        </div>
    </c:if>

    <!-- Main Form -->
    <form action="${actionUrl}" method="POST" id="userForm">
        <!-- Keep track of user ID for updates -->
        <input type="hidden" name="userId" value="${user != null ? user.userId : ''}" />

        <!-- ══ BLOCK 1: THÔNG TIN CÁ NHÂN ════════════════════════ -->
        <div style="border-radius: var(--radius-card); background: white; border: 1px solid var(--border); padding: 1.5rem; margin-bottom: 1.25rem;">
            <div style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 1.25rem;">
                <div style="width: 2.5rem; height: 2.5rem; background: var(--alice); display: flex; align-items: center; justify-content: center; border-radius: var(--radius-btn);">
                    <svg style="width: 20px; height: 20px; color: rgba(16, 55, 92, 0.60);" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                        <circle cx="12" cy="7" r="4"></circle>
                    </svg>
                </div>
                <div>
                    <h3 style="color: var(--navy); font-size: 15px; font-weight: 700; margin: 0;">Thông tin cá nhân (Personal Profile)</h3>
                    <p style="color: rgba(16, 55, 92, 0.45); font-size: 12px; margin: 0.125rem 0 0 0;">Cung cấp tên tài khoản đăng nhập và thông tin liên hệ của nhân viên</p>
                </div>
            </div>

            <div style="display: flex; flex-direction: column; gap: 1rem;">
                <!-- Row 1: Username & Full Name -->
                <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 1rem;">
                    <div>
                        <label style="display: block; color: rgba(16, 55, 92, 0.70); font-size: 12px; font-weight: 600; margin-bottom: 0.375rem;">Tên đăng nhập (Username) <span style="color:#ef4444;">*</span></label>
                        <input type="text" name="username" required placeholder="VD: anhnv99" value="<c:out value='${user != null ? user.username : ""}'/>"
                               ${user != null ? 'readonly style="width: 100%; padding: 0.625rem 1rem; background: #f3f5f8; border: 1px solid var(--border); color: rgba(16, 55, 92, 0.50); font-size: 13px; outline: none; border-radius: calc(var(--radius-btn) - 2px); cursor: not-allowed;"' : 'style="width: 100%; padding: 0.625rem 1rem; background: var(--alice); border: 1px solid var(--border); color: var(--navy); font-size: 13px; outline: none; border-radius: calc(var(--radius-btn) - 2px); transition: border-color 0.2s;"'} />
                    </div>

                    <div>
                        <label style="display: block; color: rgba(16, 55, 92, 0.70); font-size: 12px; font-weight: 600; margin-bottom: 0.375rem;">Họ và tên (Full Name) <span style="color:#ef4444;">*</span></label>
                        <input type="text" name="fullName" required placeholder="VD: Nguyễn Văn Anh" value="<c:out value='${user != null ? user.fullName : ""}'/>"
                               style="width: 100%; padding: 0.625rem 1rem; background: var(--alice); border: 1px solid var(--border); color: var(--navy); font-size: 13px; outline: none; border-radius: calc(var(--radius-btn) - 2px); transition: border-color 0.2s;" />
                    </div>
                </div>

                <!-- Row 2: Email & Phone Number -->
                <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 1rem;">
                    <div>
                        <label style="display: block; color: rgba(16, 55, 92, 0.70); font-size: 12px; font-weight: 600; margin-bottom: 0.375rem;">Địa chỉ Email <span style="color:#ef4444;">*</span></label>
                        <input type="email" name="email" required placeholder="VD: anhnv@company.com" value="<c:out value='${user != null ? user.email : ""}'/>"
                               style="width: 100%; padding: 0.625rem 1rem; background: var(--alice); border: 1px solid var(--border); color: var(--navy); font-size: 13px; outline: none; border-radius: calc(var(--radius-btn) - 2px); transition: border-color 0.2s;" />
                    </div>

                    <div>
                        <label style="display: block; color: rgba(16, 55, 92, 0.70); font-size: 12px; font-weight: 600; margin-bottom: 0.375rem;">Số điện thoại</label>
                        <input type="text" name="phone" placeholder="VD: 0912345678" value="<c:out value='${user != null ? user.phone : ""}'/>"
                               style="width: 100%; padding: 0.625rem 1rem; background: var(--alice); border: 1px solid var(--border); color: var(--navy); font-size: 13px; outline: none; border-radius: calc(var(--radius-btn) - 2px); transition: border-color 0.2s;" />
                    </div>
                </div>
            </div>
        </div>

        <!-- ══ BLOCK 2: PHÂN QUYỀN & TRẠNG THÁI ════════════════ -->
        <div style="border-radius: var(--radius-card); background: white; border: 1px solid var(--border); padding: 1.5rem; margin-bottom: 1.5rem;">
            <div style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 1.25rem;">
                <div style="width: 2.5rem; height: 2.5rem; background: var(--alice); display: flex; align-items: center; justify-content: center; border-radius: var(--radius-btn);">
                    <svg style="width: 20px; height: 20px; color: rgba(16, 55, 92, 0.60);" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                    </svg>
                </div>
                <div>
                    <h3 style="color: var(--navy); font-size: 15px; font-weight: 700; margin: 0;">Vai trò &amp; Quyền hạn (Roles &amp; Status)</h3>
                    <p style="color: rgba(16, 55, 92, 0.45); font-size: 12px; margin: 0.125rem 0 0 0;">Thiết lập mức phân quyền truy cập hệ thống và kiểm soát trạng thái tài khoản</p>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 1rem;">
                <!-- Role selection -->
                <div>
                    <label style="display: block; color: rgba(16, 55, 92, 0.70); font-size: 12px; font-weight: 600; margin-bottom: 0.375rem;">Vai trò (Role Access) <span style="color:#ef4444;">*</span></label>
                    <select name="roleId" required
                            style="width: 100%; padding: 0.625rem 1rem; background: var(--alice); border: 1px solid var(--border); color: var(--navy); font-size: 13px; outline: none; border-radius: calc(var(--radius-btn) - 2px); transition: border-color 0.2s; cursor: pointer;">
                        <c:forEach var="role" items="${roles}">
                            <option value="${role.roleId}" ${user != null && user.roleId == role.roleId ? 'selected' : ''}>
                                <c:out value="${role.roleName}"/> — <c:out value="${role.description}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Status configuration -->
                <div>
                    <label style="display: block; color: rgba(16, 55, 92, 0.70); font-size: 12px; font-weight: 600; margin-bottom: 0.75rem;">Trạng thái hoạt động (Status)</label>
                    <div style="display: flex; gap: 1.5rem; align-items: center; margin-top: 0.25rem;">
                        <label style="display: inline-flex; align-items: center; gap: 0.5rem; font-size: 13px; font-weight: 600; color: var(--navy); cursor: pointer;">
                            <input type="radio" name="active" value="true" ${user == null || user.active ? 'checked' : ''} 
                                   style="width: 1rem; height: 1rem; accent-color: var(--navy); cursor: pointer;" />
                            Đang hoạt động (Active)
                        </label>
                        <label style="display: inline-flex; align-items: center; gap: 0.5rem; font-size: 13px; font-weight: 600; color: #ef4444; cursor: pointer;">
                            <input type="radio" name="active" value="false" ${user != null && !user.active ? 'checked' : ''} 
                                   style="width: 1rem; height: 1rem; accent-color: #ef4444; cursor: pointer;" />
                            Đang khóa (Locked/Inactive)
                        </label>
                    </div>
                </div>
            </div>
        </div>

        <!-- ══ FORM ACTIONS ════════════════════════════════════ -->
        <div style="display: flex; justify-content: flex-end; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 1.5rem;">
            <a href="${pageContext.request.contextPath}/admin/users" class="btn-outline" 
               style="text-decoration: none; padding: 0.625rem 1.25rem; border-radius: var(--radius-btn); display: inline-flex; align-items: center; justify-content: center; font-size: 13px; font-weight: 600;">
                Hủy bỏ
            </a>
            <button type="submit" class="btn-navy" 
                    style="padding: 0.625rem 1.5rem; border-radius: var(--radius-btn); font-size: 13px; font-weight: 700; border: none; cursor: pointer; box-shadow: 0 4px 12px rgba(16, 55, 92, 0.15);">
                Lưu thông tin
            </button>
        </div>

    </form>
</div>

<script>
(function() {
    var form = document.getElementById('userForm');
    if (!form) return;
})();
</script>
