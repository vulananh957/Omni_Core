<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>

        <div class="users-management-container"
            style="max-width: 76rem; margin: 0 auto; padding-bottom: 2rem; position: relative;">

            <style>
                @keyframes slideDown {
                    from {
                        opacity: 0;
                        transform: translateY(-15px);
                    }

                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }
            </style>

            <!-- Dynamic Toast Notification (Auto-hides) -->
            <div id="statusToast"
                style="position: fixed; top: 1.5rem; right: 1.5rem; display: none; align-items: center; gap: 0.75rem; padding: 1rem 1.25rem; background: white; border-radius: var(--radius-btn); box-shadow: 0 10px 25px rgba(16, 55, 92, 0.15); z-index: 1000; border: 1px solid #10b981; border-left: 4px solid #10b981; transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1); opacity: 0; transform: translateY(-20px);">
                <span
                    style="font-weight: bold; width: 1.5rem; height: 1.5rem; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; background: #10b981; font-size: 12px;">✓</span>
                <span id="statusToastMsg" style="color: var(--navy); font-size: 13px; font-weight: 600;">Thành
                    công!</span>
            </div>



            <!-- Actions & Filter Bar -->
            <div class="panel" style="padding: 1.25rem; margin-bottom: 1.5rem; border-radius: var(--radius-card);">
                <div
                    style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">

                    <!-- Filters Block -->
                    <div style="display: flex; gap: 0.75rem; flex-wrap: wrap; flex: 1; align-items: center;">
                        <!-- Search Input -->
                        <div class="search-box" style="position: relative; width: 16rem;">
                            <svg class="search-box__icon"
                                style="position: absolute; left: 0.75rem; top: 50%; transform: translateY(-50%); width: 15px; height: 15px; color: rgba(16, 55, 92, 0.35);"
                                xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="11" cy="11" r="8"></circle>
                                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                            </svg>
                            <input type="text" id="userSearch" placeholder="Tìm tên hoặc email..."
                                value="<c:out value='${param.search}'/>"
                                style="width: 100%; padding: 0.6rem 1rem 0.6rem 2.25rem; background: var(--alice); border: 1px solid var(--border); color: var(--navy); font-size: 13px; outline: none; border-radius: var(--radius-btn); transition: border-color 0.2s;" />
                        </div>

                        <!-- Role Filter Dropdown -->
                        <select id="roleFilter"
                            style="padding: 0.6rem 1.25rem 0.6rem 0.75rem; background: var(--white); border: 1px solid var(--border); color: var(--navy); font-size: 13px; outline: none; border-radius: var(--radius-btn); min-width: 9rem; cursor: pointer;">
                            <option value="">Tất cả Vai trò</option>
                            <c:forEach var="r" items="${rolesList}">
                                <option value="${r.roleName}" ${param.role == r.roleName ? 'selected' : ''}><c:out value="${r.roleName}"/></option>
                            </c:forEach>
                        </select>

                        <!-- Status Filter Dropdown -->
                        <select id="statusFilter"
                            style="padding: 0.6rem 1.25rem 0.6rem 0.75rem; background: var(--white); border: 1px solid var(--border); color: var(--navy); font-size: 13px; outline: none; border-radius: var(--radius-btn); min-width: 9rem; cursor: pointer;">
                            <option value="">Tất cả Trạng thái</option>
                            <option value="active" ${param.status=='active' ? 'selected' : '' }>Đang hoạt động</option>
                            <option value="inactive" ${param.status=='inactive' ? 'selected' : '' }>Đã khóa</option>
                        </select>
                    </div>

                    <!-- Create Button -->
                    <a href="${pageContext.request.contextPath}/admin/users/create" class="btn-navy"
                        style="text-decoration: none; padding: 0.6rem 1.25rem; font-size: 13px; font-weight: 700; border-radius: var(--radius-btn); display: inline-flex; align-items: center; gap: 0.5rem; box-shadow: 0 4px 12px rgba(16, 55, 92, 0.15);">
                        <svg style="width: 16px; height: 16px;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
                            fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"
                            stroke-linejoin="round">
                            <line x1="12" y1="5" x2="12" y2="19"></line>
                            <line x1="5" y1="12" x2="19" y2="12"></line>
                        </svg>
                        Thêm Người Dùng
                    </a>
                </div>
            </div>

            <!-- Users Table Card -->
            <div class="panel" style="padding: 0; overflow: hidden; border-radius: var(--radius-card);">
                <div class="table-scroll">
                    <table class="data-table" id="usersTable">
                        <thead>
                            <tr>
                                <th style="width: 4rem;">STT</th>
                                <th style="width: 8rem;">Tài khoản</th>
                                <th>Họ và Tên</th>
                                <th>Email / Điện thoại</th>
                                <th style="width: 8rem;">Vai trò</th>
                                <th style="width: 8rem;">Trạng thái</th>
                                <th style="width: 10rem; text-align: right; padding-right: 24px;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="user" items="${usersList}" varStatus="status">
                                <tr class="user-row" data-fullname="<c:out value='${user.fullName}'/>"
                                    data-email="<c:out value='${user.email}'/>"
                                    data-role="<c:out value='${user.role}'/>"
                                    data-status="${user.active ? 'active' : 'inactive'}">

                                    <!-- STT -->
                                    <td style="font-weight: 600; color: rgba(16, 55, 92, 0.60);">${status.index + 1}
                                    </td>

                                    <!-- Username -->
                                    <td>
                                        <div style="font-weight: 700; color: var(--navy);"><c:out value="${user.username}" /></div>
                                    </td>

                                    <!-- Full Name -->
                                    <td style="font-weight: 600; color: var(--navy);">
                                        <c:out value="${user.fullName}" />
                                    </td>

                                    <!-- Contact info -->
                                    <td>
                                        <div style="font-size: 13px; color: var(--navy); font-weight: 500;">
                                            <c:out value="${user.email}" />
                                        </div>
                                        <div style="font-size: 11px; color: rgba(16, 55, 92, 0.50); margin-top: 2px;">
                                            <c:choose>
                                                <c:when test="${not empty user.phone}">
                                                    📞
                                                    <c:out value="${user.phone}" />
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="font-style: italic;">Chưa cập nhật SĐT</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div style="font-size: 11px; color: rgba(16, 55, 92, 0.45); margin-top: 4px;">
                                            📅 Tạo: <c:out value="${user.formattedCreatedAt}" />
                                        </div>
                                    </td>

                                    <!-- Role Badge -->
                                    <td>
                                        <c:choose>
                                            <c:when test="${user.role == 'ADMIN'}">
                                                <span
                                                    style="background: rgba(139, 92, 246, 0.1); color: #8b5cf6; padding: 0.25rem 0.5rem; font-size: 10px; font-weight: 800; border-radius: 4px; border: 1px solid rgba(139, 92, 246, 0.2); letter-spacing: 0.02em;">
                                                    ADMIN
                                                </span>
                                            </c:when>
                                            <c:when test="${user.role == 'MANAGER'}">
                                                <span
                                                    style="background: rgba(245, 200, 66, 0.1); color: #b58d05; padding: 0.25rem 0.5rem; font-size: 10px; font-weight: 800; border-radius: 4px; border: 1px solid rgba(245, 200, 66, 0.2); letter-spacing: 0.02em;">
                                                    MANAGER
                                                </span>
                                            </c:when>
                                            <c:when test="${user.role == 'WAREHOUSE_STAFF'}">
                                                <span
                                                    style="background: rgba(16, 115, 230, 0.1); color: #1073e6; padding: 0.25rem 0.5rem; font-size: 10px; font-weight: 800; border-radius: 4px; border: 1px solid rgba(16, 115, 230, 0.2); letter-spacing: 0.02em;">
                                                    WAREHOUSE_STAFF
                                                </span>
                                            </c:when>
                                            <c:when test="${user.role == 'SALES_STAFF'}">
                                                <span
                                                    style="background: rgba(235, 131, 23, 0.1); color: var(--orange); padding: 0.25rem 0.5rem; font-size: 10px; font-weight: 800; border-radius: 4px; border: 1px solid rgba(235, 131, 23, 0.2); letter-spacing: 0.02em;">
                                                    SALES_STAFF
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span
                                                    style="background: rgba(16, 55, 92, 0.08); color: rgba(16, 55, 92, 0.60); padding: 0.25rem 0.5rem; font-size: 10px; font-weight: 800; border-radius: 4px; border: 1px solid rgba(16, 55, 92, 0.15); letter-spacing: 0.02em;">
                                                    <c:out value="${user.role}" />
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Status -->
                                    <td>
                                        <c:choose>
                                            <c:when test="${user.active}">
                                                <span
                                                    style="display: inline-flex; align-items: center; gap: 0.25rem; padding: 0.125rem 0.5rem; background: #e6f7ed; color: #10b981; font-size: 11px; font-weight: 700; border-radius: 20px; border: 1px solid rgba(16, 185, 129, 0.2);">
                                                    Hoạt động
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span
                                                    style="display: inline-flex; align-items: center; gap: 0.25rem; padding: 0.125rem 0.5rem; background: #fee2e2; color: #ef4444; font-size: 11px; font-weight: 700; border-radius: 20px; border: 1px solid rgba(239, 68, 68, 0.2);">
                                                    Đã khóa
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Actions -->
                                    <td style="text-align: right; padding-right: 24px; vertical-align: middle;">
                                        <div
                                            style="display: inline-flex; align-items: center; gap: 0.5rem; justify-content: flex-end;">
                                            <!-- Edit Link -->
                                            <c:choose>
                                                <c:when test="${user.userId == loggedInUser.userId}">
                                                    <a href="${pageContext.request.contextPath}/admin/profile"
                                                        class="btn-outline" title="Cài đặt tài khoản của chính bạn"
                                                        style="text-decoration: none; padding: 0.5rem; font-size: 11px; border-radius: 6px; display: inline-flex; align-items: center; justify-content: center; border: 1px solid var(--border); transition: all 0.15s ease; background: var(--alice);">
                                                        <svg style="width: 14px; height: 14px;"
                                                            xmlns="http://www.w3.org/2000/svg" fill="none"
                                                            viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                                            <path stroke-linecap="round" stroke-linejoin="round"
                                                                d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                                        </svg>
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${pageContext.request.contextPath}/admin/users/edit?id=${user.userId}"
                                                        class="btn-outline" title="Chỉnh sửa thông tin"
                                                        style="text-decoration: none; padding: 0.5rem; font-size: 11px; border-radius: 6px; display: inline-flex; align-items: center; justify-content: center; border: 1px solid var(--border); transition: all 0.15s ease;">
                                                        <svg style="width: 14px; height: 14px;"
                                                            xmlns="http://www.w3.org/2000/svg" fill="none"
                                                            viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                                            <path stroke-linecap="round" stroke-linejoin="round"
                                                                d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                                        </svg>
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>

                                            <!-- Toggle Status Link -->
                                            <c:choose>
                                                <c:when test="${user.userId == loggedInUser.userId}">
                                                    <span title="Không thể tự khóa tài khoản của chính bạn!"
                                                        style="padding: 0.5rem; font-size: 11px; border-radius: 6px; display: inline-flex; align-items: center; justify-content: center; background: #f3f5f8; color: rgba(16, 55, 92, 0.3); border: 1px solid var(--border); cursor: not-allowed;">
                                                        <svg style="width: 14px; height: 14px;"
                                                            xmlns="http://www.w3.org/2000/svg" fill="none"
                                                            viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                                                            <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                                                        </svg>
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:choose>
                                                        <c:when test="${user.active}">
                                                            <a href="${pageContext.request.contextPath}/admin/users/toggle?id=${user.userId}&active=false"
                                                                title="Vô hiệu hóa tài khoản"
                                                                style="text-decoration: none; padding: 0.5rem; font-size: 11px; border-radius: 6px; display: inline-flex; align-items: center; justify-content: center; background: #fee2e2; color: #ef4444; border: 1px solid rgba(239, 68, 68, 0.2); transition: all 0.15s ease;"
                                                                onclick="return confirm('Bạn có chắc chắn muốn vô hiệu hóa tài khoản này?');">
                                                                <svg style="width: 14px; height: 14px;"
                                                                    xmlns="http://www.w3.org/2000/svg" fill="none"
                                                                    viewBox="0 0 24 24" stroke="currentColor"
                                                                    stroke-width="2">
                                                                    <rect x="3" y="11" width="18" height="11" rx="2"
                                                                        ry="2" />
                                                                    <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                                                                </svg>
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <a href="${pageContext.request.contextPath}/admin/users/toggle?id=${user.userId}&active=true"
                                                                title="Kích hoạt tài khoản"
                                                                style="text-decoration: none; padding: 0.5rem; font-size: 11px; border-radius: 6px; display: inline-flex; align-items: center; justify-content: center; background: #e6f7ed; color: #10b981; border: 1px solid rgba(16, 185, 129, 0.2); transition: all 0.15s ease;">
                                                                <svg style="width: 14px; height: 14px;"
                                                                    xmlns="http://www.w3.org/2000/svg" fill="none"
                                                                    viewBox="0 0 24 24" stroke="currentColor"
                                                                    stroke-width="2">
                                                                    <rect x="3" y="11" width="18" height="11" rx="2"
                                                                        ry="2" />
                                                                    <path stroke-linecap="round" stroke-linejoin="round"
                                                                        d="M8 11V7a4 4 0 118 0m-4 4v2" />
                                                                </svg>
                                                            </a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty usersList}">
                                <tr>
                                    <td colspan="7"
                                        style="text-align: center; padding: 3rem; color: rgba(16, 55, 92, 0.5);">
                                        📁 Không tìm thấy người dùng nào trong cơ sở dữ liệu.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <script>
            (function () {
                // Handle URL Parameter to display and dismiss Toast dynamically!
                var urlParams = new URLSearchParams(window.location.search);
                var status = urlParams.get('status');

                if (status) {
                    var toast = document.getElementById('statusToast');
                    var toastMsg = document.getElementById('statusToastMsg');

                    if (toast && toastMsg) {
                        if (status === 'success') {
                            toastMsg.textContent = 'Lưu thông tin người dùng thành công!';
                        } else if (status === 'toggle_success') {
                            toastMsg.textContent = 'Thay đổi trạng thái tài khoản thành công!';
                        } else if (status === 'self_toggle_error') {
                            toastMsg.textContent = 'Lỗi bảo mật: Bạn không thể tự khóa tài khoản của chính mình!';
                            toast.style.borderColor = '#ef4444';
                            toast.style.borderLeftColor = '#ef4444';
                            var icon = toast.querySelector('span');
                            if (icon) {
                                icon.textContent = '!';
                                icon.style.background = '#ef4444';
                            }
                        }

                        // Show toast smoothly
                        toast.style.display = 'flex';
                        // Force redraw
                        toast.offsetHeight;
                        toast.style.opacity = '1';
                        toast.style.transform = 'translateY(0)';

                        // Fade out and hide cleanly after 3 seconds
                        setTimeout(function () {
                            toast.style.opacity = '0';
                            toast.style.transform = 'translateY(-20px)';
                            setTimeout(function () {
                                toast.style.display = 'none';
                            }, 400);
                        }, 3000);
                    }

                    // Clean URL to prevent showing toast again on page reload
                    var newUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
                    window.history.replaceState({ path: newUrl }, '', newUrl);
                }

                // Clientside dynamic filtering
                var searchInput = document.getElementById('userSearch');
                var roleFilter = document.getElementById('roleFilter');
                var statusFilter = document.getElementById('statusFilter');

                function applyFilters() {
                    var query = searchInput.value.toLowerCase().trim();
                    var selectedRole = roleFilter.value;
                    var selectedStatus = statusFilter.value;

                    var rows = document.querySelectorAll('.user-row');
                    rows.forEach(function (row) {
                        var fullname = row.getAttribute('data-fullname').toLowerCase();
                        var email = row.getAttribute('data-email').toLowerCase();
                        var role = row.getAttribute('data-role');
                        var status = row.getAttribute('data-status');

                        var matchesSearch = fullname.indexOf(query) !== -1 || email.indexOf(query) !== -1;
                        var matchesRole = !selectedRole || role === selectedRole;
                        var matchesStatus = !selectedStatus || status === selectedStatus;

                        if (matchesSearch && matchesRole && matchesStatus) {
                            row.style.display = '';
                        } else {
                            row.style.display = 'none';
                        }
                    });
                }

                // Gui yeu cau loc ve server-side
                function submitFilters() {
                    var query = searchInput ? searchInput.value.trim() : '';
                    var role = roleFilter ? roleFilter.value : '';
                    var status = statusFilter ? statusFilter.value : '';

                    var baseUrl = '${pageContext.request.contextPath}/admin/users';
                    var params = [];
                    if (query) params.push('search=' + encodeURIComponent(query));
                    if (role) params.push('role=' + encodeURIComponent(role));
                    if (status) params.push('status=' + encodeURIComponent(status));

                    if (params.length > 0) {
                        window.location.href = baseUrl + '?' + params.join('&');
                    } else {
                        window.location.href = baseUrl;
                    }
                }

                if (searchInput) {
                    searchInput.addEventListener('input', applyFilters);
                    searchInput.addEventListener('keypress', function (e) {
                        if (e.key === 'Enter') {
                            submitFilters();
                        }
                    });
                }
                if (roleFilter) roleFilter.addEventListener('change', submitFilters);
                if (statusFilter) statusFilter.addEventListener('change', submitFilters);

                // Run filters on initial page load
                applyFilters();
            })();
        </script>