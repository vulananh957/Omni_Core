<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Xác thực 2 lớp (2FA) — OmniCore WMS Hub</title>
    <meta name="description" content="Xác thực OTP 2 lớp bảo mật để hoàn tất đăng nhập hệ thống."/>
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous"/>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet"/>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth--otp.css"/>
</head>
<body data-resend-countdown="${resendCountdown}">

<div class="login-root">

    <!-- ══ LEFT PANE ════════════════════════════════════════════════════ -->
    <div class="left-pane">
        <img
            class="left-pane__bg"
            src="https://images.unsplash.com/photo-1684695749267-233af13276d0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixlib=rb-4.1.0&q=80&w=1080"
            alt="Hệ thống quản lý bán hàng đa kênh"
            loading="eager"
        />
        <div class="left-pane__overlay"></div>

        <div class="left-pane__content">
            <!-- Logo -->
            <div class="brand-logo">
                <div class="brand-logo__icon">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                         style="width:20px;height:20px;color:#fff">
                        <path d="M2.97 12.92A2 2 0 0 0 2 14.63v3.24a2 2 0 0 0 .97 1.71l3 1.8a2 2 0 0 0 2.06 0L12 19v-5.5l-5-3-4.03 2.42Z"/>
                        <path d="m7 16.5-4.74-2.85"/>
                        <path d="m7 16.5 5-3"/>
                        <path d="M7 16.5v5.17"/>
                        <path d="M12 13.5V19l3.97 2.38a2 2 0 0 0 2.06 0l3-1.8a2 2 0 0 0 .97-1.71v-3.24a2 2 0 0 0-.97-1.71L17 10.5l-5 3Z"/>
                        <path d="m17 16.5-5-3"/>
                        <path d="m17 16.5 4.74-2.85"/>
                        <path d="M17 16.5v5.17"/>
                        <path d="M7.97 4.42A2 2 0 0 0 7 6.13v4.37l5 3 5-3V6.13a2 2 0 0 0-.97-1.71l-3-1.8a2 2 0 0 0-2.06 0l-3 1.8Z"/>
                        <path d="M12 8 7.26 5.15"/>
                        <path d="m12 8 4.74-2.85"/>
                        <path d="M12 13.5V8"/>
                    </svg>
                </div>
                <span class="brand-logo__name">OmniCore</span>
            </div>

            <!-- Bottom hero text -->
            <div class="left-pane__bottom">
                <div class="badge">
                    Bảo mật tài khoản
                </div>
                <h2 class="left-pane__headline">
                    Bảo mật 2 lớp<br/>
                    Xác thực (2FA)
                </h2>
                <p class="left-pane__sub">
                    Hệ thống WMS Hub yêu cầu xác thực bảo mật 2 lớp bằng mã OTP dùng một lần nhằm bảo đảm an toàn dữ liệu chuỗi cung ứng của doanh nghiệp.
                </p>
            </div>
        </div>
    </div>

    <!-- ══ RIGHT PANE ═══════════════════════════════════════════════════ -->
    <div class="right-pane">

        <!-- Mobile logo (only visible on small screens) -->
        <div class="mobile-logo">
            <div class="mobile-logo__icon">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                     stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                     style="width:16px;height:16px;color:#fff">
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

        <!-- Center card -->
        <div class="right-pane__center">
            <div class="right-pane__inner">
                <div class="login-card">

                    <!-- Error message banner -->
                    <c:if test="${not empty errorMessage}">
                        <div class="alert-banner alert-banner--error">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
                                 fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/>
                                <line x1="12" y1="16" x2="12.01" y2="16"/>
                            </svg>
                            <span><c:out value="${errorMessage}"/></span>
                        </div>
                    </c:if>

                    <!-- Success message banner -->
                    <c:if test="${not empty successMessage}">
                        <div class="alert-banner alert-banner--success">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
                                 fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>
                            </svg>
                            <span><c:out value="${successMessage}"/></span>
                        </div>
                    </c:if>

                    <%-- OTP VERIFICATION FORM --%>
                    <div class="login-card__hdr">
                        <h1 class="login-card__title">Nhập mã xác thực</h1>
                        <p class="login-card__subtitle">Mã OTP bảo mật gồm 6 chữ số đã được gửi đến email của bạn.</p>
                    </div>

                    <div class="verification-details">
                        Mã xác thực được gửi đến:
                        <div class="verification-dest-line">
                            <span>✉️ Email:</span>
                            <span><c:out value="${otpDestination}"/></span>
                        </div>
                    </div>

                    <c:if test="${not empty otpAutoMessage}">
                        <div class="alert-banner alert-banner--success">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
                                 fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>
                            </svg>
                            <span><c:out value="${otpAutoMessage}"/></span>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/otp" method="POST" id="verifyForm" novalidate>
                        <div class="otp-input-container">
                            <input type="text"
                                   name="otp"
                                   id="otpInput"
                                   class="otp-input-control"
                                   placeholder="••••••"
                                   maxlength="6"
                                   inputmode="numeric"
                                   autocomplete="one-time-code"
                                   required />
                        </div>

                        <button type="submit" class="btn-submit" id="btnVerify">
                            Xác minh tài khoản
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>
                            </svg>
                        </button>
                    </form>

                            <div class="meta-footer">
                                <div>
                                    <form action="${pageContext.request.contextPath}/otp" method="POST" style="display:inline;" id="resendForm">
                                        <input type="hidden" name="action" value="resend" />
                                        <button type="submit" class="resend-btn" id="btnResend" <c:if test="${resendCountdown > 0}">disabled</c:if>>
                                            Gửi lại mã mới <span id="countdownSpan"><c:if test="${resendCountdown > 0}">(${resendCountdown}s)</c:if></span>
                                        </button>
                                    </form>
                                </div>

                                <a href="${pageContext.request.contextPath}/login" class="back-link">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                        <line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/>
                                    </svg>
                                    Quay lại đăng nhập
                                </a>
                            </div>

                    <!-- Footer note -->
                    <p class="card-footer-note">Hệ thống dành cho nhân viên nội bộ</p>

                </div><%-- /.login-card --%>
            </div>
        </div>
    </div>

</div><%-- /.login-root --%>

<script>
(function () {
    var otpInput = document.getElementById('otpInput');
    var verifyForm = document.getElementById('verifyForm');
    var btnVerify = document.getElementById('btnVerify');
    var btnResend = document.getElementById('btnResend');
    var countdownSpan = document.getElementById('countdownSpan');
    var resendCountdown = Number(document.body.getAttribute('data-resend-countdown') || '0');

    // Filter input for digits only
    if (otpInput) {
        otpInput.addEventListener('input', function (e) {
            var value = e.target.value.replace(/\D/g, '').slice(0, 6);
            e.target.value = value;
        });
        otpInput.focus();
    }

    // Submit loading transition
    if (verifyForm && btnVerify) {
        verifyForm.addEventListener('submit', function () {
            btnVerify.innerHTML = 'Đang xác minh...';
            btnVerify.disabled = true;
            btnVerify.style.opacity = '0.8';
        });
    }

    // Dynamic Client Countdown rate-limit timer
    if (btnResend && countdownSpan && resendCountdown > 0) {
        var timer = setInterval(function () {
            resendCountdown--;
            if (resendCountdown <= 0) {
                clearInterval(timer);
                btnResend.disabled = false;
                countdownSpan.textContent = '';
            } else {
                countdownSpan.textContent = '(' + resendCountdown + 's)';
            }
        }, 1000);
    }
})();
</script>

</body>
</html>
