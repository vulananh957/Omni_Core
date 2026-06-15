<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>${pageTitle != null ? pageTitle : 'Dashboard'} — OmniCore</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css"/>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout--dashboard-layout.css"/>
</head>
<body>
<div class="app-shell">

    <!-- ══ SIDEBAR ════════════════════════════════════════════════ -->
    <aside class="sidebar" id="sidebar">

        <!-- Logo -->
        <div class="sidebar__logo">
            <div class="sidebar__logo-icon">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                     stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M2.97 12.92A2 2 0 0 0 2 14.63v3.24a2 2 0 0 0 .97 1.71l3 1.8a2 2 0 0 0 2.06 0L12 19v-5.5l-5-3-4.03 2.42Z"/>
                    <path d="m7 16.5-4.74-2.85"/><path d="m7 16.5 5-3"/><path d="M7 16.5v5.17"/>
                    <path d="M12 13.5V19l3.97 2.38a2 2 0 0 0 2.06 0l3-1.8a2 2 0 0 0 .97-1.71v-3.24a2 2 0 0 0-.97-1.71L17 10.5l-5 3Z"/>
                    <path d="m17 16.5-5-3"/><path d="m17 16.5 4.74-2.85"/><path d="M17 16.5v5.17"/>
                    <path d="M7.97 4.42A2 2 0 0 0 7 6.13v4.37l5 3 5-3V6.13a2 2 0 0 0-.97-1.71l-3-1.8a2 2 0 0 0-2.06 0l-3 1.8Z"/>
                    <path d="M12 8 7.26 5.15"/><path d="m12 8 4.74-2.85"/><path d="M12 13.5V8"/>
                </svg>
            </div>
            <span class="sidebar__logo-name">OmniCore</span>
        </div>

        <!-- Role badge -->
        <div class="sidebar__role">
            <div class="sidebar__role-inner">
                <div class="sidebar__role-dot"></div>
                <span class="sidebar__role-text">
                    <c:choose>
                        <c:when test="${loggedInUser.role == 'ADMIN'}">System Administrator</c:when>
                        <c:when test="${loggedInUser.role == 'MANAGER'}">Business Manager</c:when>
                        <c:when test="${loggedInUser.role == 'WAREHOUSE_STAFF'}">Warehouse Staff</c:when>
                        <c:when test="${loggedInUser.role == 'SALES_STAFF'}">Sales Staff</c:when>
                        <c:otherwise>${loggedInUser.role}</c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>

        <!-- Nav -->
        <nav class="sidebar__nav">
            <!-- TỔNG QUAN -->
            <div class="nav-group">
                <div class="nav-group__label">Tổng quan</div>
                <a href="${pageContext.request.contextPath}/business/dashboard"
                   class="nav-item ${currentPage == 'dashboard' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect width="7" height="9" x="3" y="3" rx="1"/><rect width="7" height="5" x="14" y="3" rx="1"/>
                        <rect width="7" height="9" x="14" y="12" rx="1"/><rect width="7" height="5" x="3" y="16" rx="1"/>
                    </svg>
                    <span>Dashboard</span>
                    <c:if test="${currentPage == 'dashboard'}">
                        <svg class="nav-item__chevron" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="m9 18 6-6-6-6"/>
                        </svg>
                    </c:if>
                </a>
            </div>

            <!-- QUẢN LÝ DANH MỤC -->
            <div class="nav-group">
                <div class="nav-group__label">Quản lý danh mục</div>
                <a href="${pageContext.request.contextPath}/business/master-sku"
                   class="nav-item ${currentPage == 'master-sku' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M11 21H4a2 2 0 0 1-2-2V5c0-1.1.9-2 2-2h5l2 3h9a2 2 0 0 1 2 2v2"/>
                        <path d="m15 20 3 3 5-5"/><path d="M9 17H7"/><path d="M9 13H7"/>
                    </svg>
                    <span>Master SKU</span>
                </a>
                <a href="${pageContext.request.contextPath}/business/categories"
                   class="nav-item ${currentPage == 'categories' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M12 2H2v10l9.29 9.29c.94.94 2.48.94 3.42 0l6.58-6.58c.94-.94.94-2.48 0-3.42L12 2Z"/>
                        <path d="M7 7h.01"/>
                    </svg>
                    <span>Danh mục sản phẩm</span>
                </a>
                <a href="${pageContext.request.contextPath}/business/warehouses"
                   class="nav-item ${currentPage == 'warehouses' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M22 8.35V20a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V8.35A2 2 0 0 1 3.26 6.5l8-3.2a2 2 0 0 1 1.48 0l8 3.2A2 2 0 0 1 22 8.35Z"/>
                        <path d="M6 18h12"/><path d="M6 14h12"/><rect width="4" height="6" x="10" y="18" rx="0"/>
                    </svg>
                    <span>Danh sách kho hàng</span>
                </a>
            </div>

            <!-- QUẢN LÝ TỒN KHO -->
            <div class="nav-group">
                <div class="nav-group__label">Quản lý tồn kho</div>
                <a href="${pageContext.request.contextPath}/business/inventory"
                   class="nav-item ${currentPage == 'inventory' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect width="20" height="5" x="2" y="3" rx="1" />
                        <path d="M4 8v11a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8" />
                        <line x1="10" x2="14" y1="12" y2="12" />
                    </svg>
                    <span>Tồn ở các kho</span>
                </a>
                <a href="${pageContext.request.contextPath}/business/ledger"
                   class="nav-item ${currentPage == 'ledger' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M3 3v5h5"/><path d="M3.05 13A9 9 0 1 0 6 5.3L3 8"/>
                        <path d="M12 7v5l4 2"/>
                    </svg>
                    <span>Sổ kho</span>
                </a>
            </div>

            <!-- QUẢN TRỊ NỘI BỘ -->
            <div class="nav-group">
                <div class="nav-group__label">Quản trị nội bộ</div>
                <a href="${pageContext.request.contextPath}/business/staff"
                   class="nav-item ${currentPage == 'staff' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/>
                        <circle cx="9" cy="7" r="4"/>
                        <path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                    </svg>
                    <span>Quản lý nhân sự</span>
                </a>
            </div>

            <!-- CÀI ĐẶT -->
            <div class="sidebar__settings-divider">
                <div class="nav-group__label sidebar__settings-label">Cài đặt</div>
                <a href="${pageContext.request.contextPath}/business/profile"
                   class="nav-item ${currentPage == 'profile' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="8" r="5"/><path d="M20 21a8 8 0 1 0-16 0"/>
                    </svg>
                    <span>Cài đặt tài khoản</span>
                </a>
            </div>
        </nav>

        <!-- Bottom user + logout -->
        <div class="sidebar__bottom">
            <button class="sidebar__user">
                <div class="sidebar__avatar">
                    <c:choose>
                        <c:when test="${loggedInUser.role == 'ADMIN'}">AD</c:when>
                        <c:when test="${loggedInUser.role == 'MANAGER'}">BM</c:when>
                        <c:when test="${loggedInUser.role == 'WAREHOUSE_STAFF'}">WS</c:when>
                        <c:when test="${loggedInUser.role == 'SALES_STAFF'}">SS</c:when>
                        <c:otherwise>US</c:otherwise>
                    </c:choose>
                </div>
                <div class="sidebar__user-info">
                    <div class="sidebar__user-name"><c:out value="${loggedInUser.fullName}"/></div>
                    <div class="sidebar__user-role">
                        <c:choose>
                            <c:when test="${loggedInUser.role == 'ADMIN'}">Administrator</c:when>
                            <c:when test="${loggedInUser.role == 'MANAGER'}">Business Manager</c:when>
                            <c:when test="${loggedInUser.role == 'WAREHOUSE_STAFF'}">Warehouse Staff</c:when>
                            <c:when test="${loggedInUser.role == 'SALES_STAFF'}">Sales Staff</c:when>
                            <c:otherwise>${loggedInUser.role}</c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </button>
            <a href="${pageContext.request.contextPath}/logout" class="sidebar__logout">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                     stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                    <polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/>
                </svg>
                <span>Đăng xuất</span>
            </a>
        </div>

        <!-- Collapse toggle -->
        <button class="sidebar__toggle" id="sidebarToggle" aria-label="Thu gọn sidebar">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="m15 18-6-6 6-6"/>
            </svg>
        </button>
    </aside>

    <!-- ══ MAIN ═══════════════════════════════════════════════════ -->
    <div class="main-area">

        <!-- Topbar -->
        <header class="topbar">
            <div>
                <div class="topbar__title">${pageTitle != null ? pageTitle : 'Dashboard'}</div>
                <c:if test="${pageSubtitle != null}">
                    <div class="topbar__subtitle">${pageSubtitle}</div>
                </c:if>
            </div>
            <div class="topbar__right">
                <div class="search-box">
                    <svg class="search-box__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
                         fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
                    </svg>
                    <input class="search-box__input" type="text" placeholder="Tìm kiếm..." id="searchInput"/>
                </div>
                <button class="notif-btn" aria-label="Thông báo">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
                        <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
                    </svg>
                    <span class="notif-btn__dot"></span>
                </button>
            </div>
        </header>

        <!-- Page body -->
        <main class="page-content" id="pageContent">
            <jsp:include page="${contentPage}"/>
        </main>
    </div>
</div>

<script>
(function () {
    /* ── Sidebar collapse ── */
    var sidebar = document.getElementById('sidebar');
    var toggle  = document.getElementById('sidebarToggle');
    if (toggle) {
        toggle.addEventListener('click', function () {
            sidebar.classList.toggle('collapsed');
            toggle.classList.toggle('collapsed');
        });
    }

    /* ── Dynamic Avatar Initial ── */
    var userNameEl = document.querySelector('.sidebar__user-name');
    var avatarEl   = document.querySelector('.sidebar__avatar');
    if (userNameEl && avatarEl) {
        var name = userNameEl.textContent.trim();
        if (name) {
            var parts = name.split(/\s+/);
            var lastName = parts[parts.length - 1];
            if (lastName) {
                avatarEl.textContent = lastName.charAt(0).toUpperCase();
            }
        }
    }
})();
</script>
</body>
</html>
