<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Đặt lại mật khẩu — OmniCore WMS Hub</title>
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous"/>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet"/>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth--reset-password.css"/>
</head>
<body>

<div class="rp-root">

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
                <div class="badge">Đặt lại mật khẩu</div>
                <h2 class="left-pane__headline">Xác minh và<br/>đặt mật khẩu mới</h2>
                <p class="left-pane__sub">
                    Nhập mã OTP đã được gửi đến Email của bạn, sau đó đặt mật khẩu mới để hoàn tất quá trình khôi phục.
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
                <div class="rp-card">

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

                    <h1 class="rp-card__title">Đặt lại mật khẩu</h1>
                    <p class="rp-card__subtitle">Nhập mã OTP và mật khẩu mới để hoàn tất.</p>

                    <div class="verification-info">
                        Mã xác thực đã được gửi đến <strong><c:out value="${emailDestination}"/></strong>
                    </div>

                    <form class="rp-form" action="${pageContext.request.contextPath}/reset-password" method="POST" id="rpForm" novalidate>
                        <input type="hidden" name="action" value="verify" />

                        <div class="form-group">
                            <label class="form-label" for="otp">Mã xác thực (OTP)</label>
                            <input
                                class="form-input otp-input"
                                type="text"
                                id="otp"
                                name="otp"
                                placeholder="••••••"
                                maxlength="6"
                                inputmode="numeric"
                                autocomplete="one-time-code"
                                required
                            />
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="newPassword">Mật khẩu mới</label>
                            <div class="password-wrap">
                                <input
                                    class="form-input"
                                    type="password"
                                    id="newPassword"
                                    name="newPassword"
                                    placeholder="••••••••"
                                    autocomplete="new-password"
                                    required
                                />
                                <button type="button" class="password-toggle" id="toggleNewPwd" aria-label="Hiện/ẩn mật khẩu">
                                    <svg id="iconEyeNew" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/>
                                    </svg>
                                    <svg id="iconEyeOffNew" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="display:none">
                                        <path d="M9.88 9.88a3 3 0 1 0 4.24 4.24"/><path d="M10.73 5.08A10.43 10.43 0 0 1 12 5c7 0 10 7 10 7a13.16 13.16 0 0 1-1.67 2.68"/><path d="M6.61 6.61A13.526 13.526 0 0 0 2 12s3 7 10 7a9.74 9.74 0 0 0 5.39-1.61"/><line x1="2" y1="2" x2="22" y2="22"/>
                                    </svg>
                                </button>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="confirmPassword">Xác nhận mật khẩu mới</label>
                            <div class="password-wrap">
                                <input
                                    class="form-input"
                                    type="password"
                                    id="confirmPassword"
                                    name="confirmPassword"
                                    placeholder="••••••••"
                                    autocomplete="new-password"
                                    required
                                />
                                <button type="button" class="password-toggle" id="toggleConfPwd" aria-label="Hiện/ẩn mật khẩu">
                                    <svg id="iconEyeConf" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/>
                                    </svg>
                                    <svg id="iconEyeOffConf" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="display:none">
                                        <path d="M9.88 9.88a3 3 0 1 0 4.24 4.24"/><path d="M10.73 5.08A10.43 10.43 0 0 1 12 5c7 0 10 7 10 7a13.16 13.16 0 0 1-1.67 2.68"/><path d="M6.61 6.61A13.526 13.526 0 0 0 2 12s3 7 10 7a9.74 9.74 0 0 0 5.39-1.61"/><line x1="2" y1="2" x2="22" y2="22"/>
                                    </svg>
                                </button>
                            </div>
                        </div>

                        <button type="submit" class="btn-submit" id="btnSubmit">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                            </svg>
                            Đặt lại mật khẩu
                        </button>

                        <div class="resend-row">
                            <span>Không nhận được mã?</span>
                            <form action="${pageContext.request.contextPath}/reset-password" method="POST" style="display:inline;">
                                <input type="hidden" name="action" value="resend" />
                                <button type="submit" class="resend-btn">Gửi lại mã</button>
                            </form>
                        </div>
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
    var otpInput = document.getElementById('otp');
    if (otpInput) {
        otpInput.addEventListener('input', function (e) {
            e.target.value = e.target.value.replace(/\D/g, '').slice(0, 6);
        });
        otpInput.focus();
    }

    function setupPwdToggle(toggleId, inputId, eyeId, eyeOffId) {
        var toggle = document.getElementById(toggleId);
        var input = document.getElementById(inputId);
        var eye = document.getElementById(eyeId);
        var eyeOff = document.getElementById(eyeOffId);
        if (!toggle || !input) return;
        var shown = false;
        toggle.addEventListener('click', function () {
            shown = !shown;
            input.type = shown ? 'text' : 'password';
            eye.style.display = shown ? 'none' : '';
            eyeOff.style.display = shown ? '' : 'none';
        });
    }

    setupPwdToggle('toggleNewPwd', 'newPassword', 'iconEyeNew', 'iconEyeOffNew');
    setupPwdToggle('toggleConfPwd', 'confirmPassword', 'iconEyeConf', 'iconEyeOffConf');

    var form = document.getElementById('rpForm');
    var btn = document.getElementById('btnSubmit');
    if (form && btn) {
        form.addEventListener('submit', function () {
            btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="spin"><line x1="12" y1="2" x2="12" y2="6"/><line x1="12" y1="18" x2="12" y2="22"/><line x1="4.93" y1="4.93" x2="7.76" y2="7.76"/><line x1="16.24" y1="16.24" x2="19.07" y2="19.07"/><line x1="2" y1="12" x2="6" y2="12"/><line x1="18" y1="12" x2="22" y2="12"/><line x1="4.93" y1="19.07" x2="7.76" y2="16.24"/><line x1="16.24" y1="7.76" x2="19.07" y2="4.93"/></svg> Đang xử lý...';
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
