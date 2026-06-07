<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>${pageTitle != null ? pageTitle : 'Warehouse'} — OmniCore</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css"/>
</head>
<body>
<div class="app-shell">

    <!-- ══ SIDEBAR ════════════════════════════════════════════════ -->
    <aside class="sidebar" id="sidebar">

        <!-- Logo -->
        <div class="sidebar__logo">
            <div class="sidebar__logo-icon">
                <!-- Boxes icon (warehouse) -->
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

        <!-- Role badge — cyan for WH Staff -->
        <div class="sidebar__role">
            <div class="sidebar__role-inner" style="border-color: rgba(34,211,238,0.20);">
                <div class="sidebar__role-dot" style="background: #22d3ee;"></div>
                <span class="sidebar__role-text" style="color: #22d3ee;">Warehouse Staff</span>
            </div>
        </div>

        <!-- Nav -->
        <nav class="sidebar__nav">

            <!-- SẢN PHẨM & DANH MỤC -->
            <div class="nav-group">
                <div class="nav-group__label">Sản Phẩm &amp; Danh Mục</div>
                <a href="${pageContext.request.contextPath}/warehouse/master-sku"
                   class="nav-item ${currentPage == 'wh-master-sku' ? 'active' : ''}">
                    <!-- Package icon -->
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M16.5 9.4 7.55 4.24"/>
                        <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/>
                        <polyline points="3.29 7 12 12 20.71 7"/>
                        <line x1="12" x2="12" y1="22" y2="12"/>
                    </svg>
                    <span>Master SKU</span>
                    <c:if test="${currentPage == 'wh-master-sku'}">
                        <svg class="nav-item__chevron" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="m9 18 6-6-6-6"/>
                        </svg>
                    </c:if>
                </a>
            </div>

            <!-- VẬN HÀNH KHO -->
            <div class="nav-group">
                <div class="nav-group__label">Vận Hành Kho</div>

                <!-- Nhập kho -->
                <a href="${pageContext.request.contextPath}/warehouse/inbound"
                   class="nav-item ${currentPage == 'wh-inbound' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M12 17V3"/>
                        <path d="m6 11 6 6 6-6"/>
                        <path d="M19 21H5"/>
                    </svg>
                    <span>Nhập kho</span>
                    <c:if test="${currentPage == 'wh-inbound'}">
                        <svg class="nav-item__chevron" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="m9 18 6-6-6-6"/>
                        </svg>
                    </c:if>
                </a>

                <!-- Xuất kho -->
                <a href="${pageContext.request.contextPath}/warehouse/outbound"
                   class="nav-item ${currentPage == 'wh-outbound' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="m18 9-6-6-6 6"/>
                        <path d="M12 3v14"/>
                        <path d="M5 21h14"/>
                    </svg>
                    <span>Xuất kho</span>
                    <c:if test="${currentPage == 'wh-outbound'}">
                        <svg class="nav-item__chevron" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="m9 18 6-6-6-6"/>
                        </svg>
                    </c:if>
                </a>

                <!-- Điều chuyển kho -->
                <a href="${pageContext.request.contextPath}/warehouse/transfer"
                   class="nav-item ${currentPage == 'wh-transfer' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M8 3 4 7l4 4"/><path d="M4 7h16"/>
                        <path d="m16 21 4-4-4-4"/><path d="M20 17H4"/>
                    </svg>
                    <span>Điều chuyển kho</span>
                    <c:if test="${currentPage == 'wh-transfer'}">
                        <svg class="nav-item__chevron" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="m9 18 6-6-6-6"/>
                        </svg>
                    </c:if>
                </a>

                <!-- Kiểm kê -->
                <a href="${pageContext.request.contextPath}/warehouse/inventory-check"
                   class="nav-item ${currentPage == 'wh-inventory-check' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect width="8" height="4" x="8" y="2" rx="1" ry="1"/>
                        <path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/>
                        <path d="m9 14 2 2 4-4"/>
                    </svg>
                    <span>Kiểm kê</span>
                    <c:if test="${currentPage == 'wh-inventory-check'}">
                        <svg class="nav-item__chevron" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="m9 18 6-6-6-6"/>
                        </svg>
                    </c:if>
                </a>

                <!-- Hàng hoàn & QC -->
                <a href="${pageContext.request.contextPath}/warehouse/returns"
                   class="nav-item ${currentPage == 'wh-returns' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/>
                        <path d="M3 3v5h5"/>
                    </svg>
                    <span>Hàng hoàn &amp; QC</span>
                    <c:if test="${currentPage == 'wh-returns'}">
                        <svg class="nav-item__chevron" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="m9 18 6-6-6-6"/>
                        </svg>
                    </c:if>
                </a>

                <!-- Sổ kho -->
                <a href="${pageContext.request.contextPath}/warehouse/documents"
                   class="nav-item ${currentPage == 'wh-documents' ? 'active' : ''}">
                    <svg class="nav-item__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                        <polyline points="14 2 14 8 20 8"/>
                        <line x1="16" y1="13" x2="8" y2="13"/>
                        <line x1="16" y1="17" x2="8" y2="17"/>
                        <polyline points="10 9 9 9 8 9"/>
                    </svg>
                    <span>Sổ kho</span>
                    <c:if test="${currentPage == 'wh-documents'}">
                        <svg class="nav-item__chevron" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="m9 18 6-6-6-6"/>
                        </svg>
                    </c:if>
                </a>
            </div>

            <!-- CÀI ĐẶT -->
            <div class="sidebar__settings-divider">
                <div class="nav-group__label sidebar__settings-label">Cài Đặt Tài Khoản</div>
                <a href="${pageContext.request.contextPath}/warehouse/profile"
                   class="nav-item ${currentPage == 'wh-profile' ? 'active' : ''}">
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
                <div class="sidebar__avatar" style="background: linear-gradient(135deg, #22d3ee, #0891b2);">WS</div>
                <div class="sidebar__user-info">
                    <div class="sidebar__user-name"><c:out value="${loggedInUser.fullName}"/></div>
                    <div class="sidebar__user-role">Warehouse Staff</div>
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
                <div class="topbar__title">${pageTitle != null ? pageTitle : 'Warehouse'}</div>
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
