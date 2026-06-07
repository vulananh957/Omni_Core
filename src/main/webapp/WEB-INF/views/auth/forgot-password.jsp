<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Quên mật khẩu — OmniCore WMS Hub</title>
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous"/>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet"/>

    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --navy:   #10375C;
            --orange: #EB8317;
            --orange-hover: #d4751a;
            --alice:  #F0F4FA;
            --yellow: #F5C842;
            --radius-btn:  8px;
            --radius-card: 16px;
        }

        html, body {
            height: 100%;
            font-family: 'Inter', sans-serif;
            -webkit-font-smoothing: antialiased;
        }

        .fp-root {
            min-height: 100vh;
            display: flex;
        }

        .left-pane {
            display: none;
            width: 50%;
            flex-direction: column;
            position: relative;
            overflow: hidden;
        }

        @media (min-width: 1024px) { .left-pane { display: flex; } }

        .left-pane__bg {
            position: absolute;
            inset: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .left-pane__overlay {
            position: absolute;
            inset: 0;
            background: linear-gradient(
                to bottom,
                rgba(16,55,92,0.55) 0%,
                rgba(16,55,92,0.30) 35%,
                rgba(16,55,92,1.00) 100%
            );
        }

        .left-pane__content {
            position: relative;
            display: flex;
            flex-direction: column;
            height: 100%;
            padding: 40px 48px;
        }

        .brand-logo {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .brand-logo__icon {
            width: 36px;
            height: 36px;
            background: var(--orange);
            border-radius: var(--radius-btn);
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 16px rgba(235,131,23,0.40);
            flex-shrink: 0;
        }

        .brand-logo__icon svg { width: 20px; height: 20px; color: #fff; }

        .brand-logo__name {
            color: #fff;
            font-size: 20px;
            font-weight: 800;
            letter-spacing: -0.03em;
            line-height: 1;
        }

        .left-pane__bottom { margin-top: auto; }

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 4px 12px;
            border-radius: 9999px;
            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.20);
            color: var(--yellow);
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            margin-bottom: 20px;
        }

        .left-pane__headline {
            color: #fff;
            font-size: 38px;
            line-height: 1.1;
            font-weight: 800;
            letter-spacing: -0.025em;
            margin-bottom: 16px;
        }

        .left-pane__sub {
            color: rgba(255,255,255,0.70);
            font-size: 15px;
            line-height: 1.7;
            max-width: 380px;
        }

        .right-pane {
            width: 100%;
            background: var(--alice);
            display: flex;
            flex-direction: column;
            overflow-y: auto;
        }

        @media (min-width: 1024px) { .right-pane { width: 50%; } }

        .mobile-logo {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 20px 32px;
        }
        @media (min-width: 1024px) { .mobile-logo { display: none; } }

        .mobile-logo__icon {
            width: 32px;
            height: 32px;
            background: var(--orange);
            border-radius: calc(var(--radius-btn) - 2px);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .mobile-logo__icon svg { width: 16px; height: 16px; color: #fff; }

        .mobile-logo__name {
            color: var(--navy);
            font-size: 18px;
            font-weight: 800;
            letter-spacing: -0.03em;
        }

        .right-pane__center {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 48px 24px;
        }

        .right-pane__inner { width: 100%; max-width: 520px; }

        .fp-card {
            background: #fff;
            box-shadow: 0 4px 40px rgba(16,55,92,0.10);
            border-radius: var(--radius-card);
            padding: 40px 32px;
            animation: slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1) both;
        }

        .fp-card__title {
            color: var(--navy);
            font-size: 26px;
            font-weight: 800;
            letter-spacing: -0.02em;
            margin-bottom: 8px;
            line-height: 1.2;
        }

        .fp-card__subtitle {
            color: rgba(16,55,92,0.50);
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 28px;
        }

        .alert-banner {
            border-radius: var(--radius-btn);
            padding: 12px 16px;
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
            line-height: 1.5;
        }

        .alert-banner--error {
            background: #FEF2F2;
            border: 1px solid #FECACA;
            color: #DC2626;
        }

        .alert-banner--success {
            background: #f0fdf4;
            border: 1px solid #dcfce7;
            color: #15803d;
        }

        .alert-banner svg { flex-shrink: 0; }

        .fp-form { display: flex; flex-direction: column; gap: 20px; }

        .form-group { display: flex; flex-direction: column; gap: 6px; }

        .form-label {
            color: rgba(16,55,92,0.80);
            font-size: 13px;
            font-weight: 600;
        }

        .form-input {
            width: 100%;
            background: #fff;
            border: 1px solid #D8DFF0;
            border-radius: calc(var(--radius-btn) - 2px);
            padding: 12px 16px;
            font-size: 14px;
            font-family: inherit;
            color: var(--navy);
            outline: none;
            transition: border-color 0.15s, box-shadow 0.15s;
        }

        .form-input::placeholder { color: rgba(16,55,92,0.35); }

        .form-input:focus {
            border-color: var(--navy);
            box-shadow: 0 0 0 3px rgba(16,55,92,0.10);
        }

        .btn-submit {
            width: 100%;
            background: var(--orange);
            color: #fff;
            font-family: inherit;
            font-size: 15px;
            font-weight: 700;
            padding: 14px;
            border: none;
            border-radius: var(--radius-btn);
            cursor: pointer;
            transition: background 0.15s, transform 0.1s, box-shadow 0.15s;
            box-shadow: 0 8px 24px rgba(235,131,23,0.32);
            margin-top: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-submit:hover { background: var(--orange-hover); }
        .btn-submit:active { transform: scale(0.99); }

        .btn-back {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            color: rgba(16,55,92,0.45);
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            transition: color 0.15s;
            margin-top: 16px;
        }

        .btn-back:hover { color: var(--navy); }

        .card-footer-note {
            text-align: center;
            color: rgba(16,55,92,0.40);
            font-size: 12px;
            margin-top: 24px;
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(16px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>

<div class="fp-root">

    <!-- LEFT PANE -->
    <div class="left-pane">
        <img class="left-pane__bg"
             src="https://images.unsplash.com/photo-1684695749267-233af13276d0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixlib=rb-4.1.0&q=80&w=1080"
             alt="Background"
             loading="eager"/>
        <div class="left-pane__overlay"></div>
        <div class="left-pane__content">
            <div class="brand-logo">
                <div class="brand-logo__icon">
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
                <span class="brand-logo__name">OmniCore</span>
            </div>
            <div class="left-pane__bottom">
                <div class="badge">Khôi phục tài khoản</div>
                <h2 class="left-pane__headline">Quên mật khẩu?<br/>Không sao cả.</h2>
                <p class="left-pane__sub">
                    Nhập Email hoặc Username của bạn để nhận mã xác thực và đặt lại mật khẩu mới.
                </p>
            </div>
        </div>
    </div>

    <!-- RIGHT PANE -->
    <div class="right-pane">
        <div class="mobile-logo">
            <div class="mobile-logo__icon">
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
            <span class="mobile-logo__name">OmniCore</span>
        </div>

        <div class="right-pane__center">
            <div class="right-pane__inner">
                <div class="fp-card">

                    <c:if test="${not empty errorMessage}">
                        <div class="alert-banner alert-banner--error">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/>
                                <line x1="12" y1="16" x2="12.01" y2="16"/>
                            </svg>
                            <span><c:out value="${errorMessage}"/></span>
                        </div>
                    </c:if>

                    <c:if test="${not empty successMessage}">
                        <div class="alert-banner alert-banner--success">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>
                            </svg>
                            <span><c:out value="${successMessage}"/></span>
                        </div>
                    </c:if>

                    <div class="fp-card__hdr">
                        <h1 class="fp-card__title">Khôi phục mật khẩu</h1>
                        <p class="fp-card__subtitle">Nhập Email hoặc Username đã đăng ký để nhận mã xác thực.</p>
                    </div>

                    <form class="fp-form" action="${pageContext.request.contextPath}/forgot-password" method="POST" id="fpForm" novalidate>
                        <input type="hidden" name="action" value="request" />

                        <div class="form-group">
                            <label class="form-label" for="identifier">Email hoặc Username</label>
                            <input
                                class="form-input"
                                type="text"
                                id="identifier"
                                name="identifier"
                                placeholder="Nhập email hoặc username"
                                autocomplete="username"
                                required
                            />
                        </div>

                        <button type="submit" class="btn-submit" id="btnSubmit">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M22 2L11 13"/><path d="M22 2L15 22 11 13 2 9 22 2Z"/>
                            </svg>
                            Gửi mã xác thực
                        </button>
                    </form>

                    <a href="${pageContext.request.contextPath}/login" class="btn-back">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/>
                        </svg>
                        Quay lại đăng nhập
                    </a>

                    <p class="card-footer-note">Hệ thống dành cho nhân viên nội bộ</p>

                </div>
            </div>
        </div>
    </div>

</div>

<script>
(function () {
    var form = document.getElementById('fpForm');
    var btn = document.getElementById('btnSubmit');
    if (form && btn) {
        form.addEventListener('submit', function () {
            btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="spin"><line x1="12" y1="2" x2="12" y2="6"/><line x1="12" y1="18" x2="12" y2="22"/><line x1="4.93" y1="4.93" x2="7.76" y2="7.76"/><line x1="16.24" y1="16.24" x2="19.07" y2="19.07"/><line x1="2" y1="12" x2="6" y2="12"/><line x1="18" y1="12" x2="22" y2="12"/><line x1="4.93" y1="19.07" x2="7.76" y2="16.24"/><line x1="16.24" y1="7.76" x2="19.07" y2="4.93"/></svg> Đang gửi...';
            btn.disabled = true;
            btn.style.opacity = '0.8';
        });
    }
})();
</script>

<style>
@keyframes spin { to { transform: rotate(360deg); } }
.spin { animation: spin 1s linear infinite; }
</style>

</body>
</html>
