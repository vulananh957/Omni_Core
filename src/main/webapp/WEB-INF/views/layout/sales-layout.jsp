<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>${pageTitle != null ? pageTitle : 'Sales Staff'} — OmniCore</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css"/>
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
                    <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/>
                    <polyline points="3.29 7 12 12 20.71 7"/>
                    <line x1="12" x2="12" y1="22" y2="12"/>
                </svg>
            </div>
            <span class="sidebar__logo-name">OmniCore</span>
        </div>

        <!-- Role badge — emerald green for Sales Staff -->
        <div class="sidebar__role">
            <div class="sidebar__role-inner" style="border-color: rgba(52,211,153,0.20);">
                <div class="sidebar__role-dot" style="background: #34d399;"></div>
                <span class="sidebar__role-text" style="color: #34d399;">Sales Staff</span>
            </div>
        </div>

        <!-- Nav -->
        <nav class="sidebar__nav">

            <!-- XỬ LÝ ĐƠN HÀNG -->
            <div class="nav-group">
                <div class="nav-group__label">Xử Lý Đơn Hàng</div>
                <a href="${pageContext.request.contextPath}/sales/orders"
                   class="nav-item ${currentPage == 'sales-orders' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="8" cy="21" r="1"/><circle cx="19" cy="21" r="1"/>
                        <path d="M2.05 2.05h2l2.66 12.42a2 2 0 0 0 2 1.58h9.78a2 2 0 0 0 1.95-1.57l1.65-7.43H5.12"/>
                    </svg>
                    <span>Tất cả đơn hàng</span>
                </a>
                <a href="${pageContext.request.contextPath}/sales/order-processing"
                   class="nav-item ${currentPage == 'sales-processing' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect width="8" height="4" x="8" y="2" rx="1" ry="1"/>
                        <path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/>
                        <path d="M9 9h6"/>
                        <path d="M9 13h6"/>
                        <path d="M9 17h6"/>
                    </svg>
                    <span>Xử lý đơn hàng</span>
                </a>
            </div>

            <!-- KÊNH BÁN & SẢN PHẨM -->
            <div class="nav-group">
                <div class="nav-group__label">Kênh Bán &amp; Sản Phẩm</div>
                <a href="${pageContext.request.contextPath}/sales/sku-mapping"
                   class="nav-item ${currentPage == 'sales-sku-mapping' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/>
                        <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/>
                    </svg>
                    <span>Ánh xạ SKU</span>
                </a>
                <a href="${pageContext.request.contextPath}/sales/channel-products"
                   class="nav-item ${currentPage == 'sales-channel-products' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="m6 14 1.45-2.9A2 2 0 0 1 9.24 10H20a2 2 0 0 1 1.94 2.5l-1.55 6a2 2 0 0 1-1.94 1.5H4a2 2 0 0 1-2-2V5c0-1.1.9-2 2-2h3.93a2 2 0 0 1 1.66.9l.82 1.2a2 2 0 0 0 1.66.9H18a2 2 0 0 1 2 2v2"/>
                    </svg>
                    <span>Sản phẩm kênh</span>
                </a>
            </div>

            <!-- CÀI ĐẶT -->
            <div class="sidebar__settings-divider">
                <div class="nav-group__label sidebar__settings-label">Cài Đặt</div>
                <a href="${pageContext.request.contextPath}/sales/profile"
                   class="nav-item ${currentPage == 'sales-profile' ? 'active' : ''}">
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
                <div class="sidebar__avatar" style="background: linear-gradient(135deg, #34d399, #059669);">SS</div>
                <div class="sidebar__user-info">
                    <div class="sidebar__user-name"><c:out value="${loggedInUser.fullName}"/></div>
                    <div class="sidebar__user-role">Sales Staff</div>
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
                <div class="topbar__title">${pageTitle != null ? pageTitle : 'Sales Staff'}</div>
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
