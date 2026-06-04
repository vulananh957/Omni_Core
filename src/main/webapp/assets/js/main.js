/**
 * main.js — WMS Hub client-side scripts
 * Vanilla JS only. No jQuery, no React.
 */

document.addEventListener('DOMContentLoaded', function () {

    // ── Password toggle ───────────────────────────────────────
    const toggleBtn = document.getElementById('togglePassword');
    if (toggleBtn) {
        toggleBtn.addEventListener('click', function () {
            const pwField = document.getElementById('password');
            if (!pwField) return;
            const isHidden = pwField.type === 'password';
            pwField.type = isHidden ? 'text' : 'password';
            toggleBtn.textContent = isHidden ? '🙈' : '👁';
        });
    }

    // ── Sidebar toggle (mobile / collapse) ───────────────────
    const sidebarToggle = document.getElementById('sidebarToggle');
    const sidebar = document.getElementById('sidebar');
    if (sidebarToggle && sidebar) {
        sidebarToggle.addEventListener('click', function () {
            sidebar.classList.toggle('sidebar--collapsed');
        });
    }

    // ── Auto-dismiss alerts after 4s ─────────────────────────
    document.querySelectorAll('.alert').forEach(function (alert) {
        setTimeout(function () {
            alert.style.transition = 'opacity 0.4s';
            alert.style.opacity = '0';
            setTimeout(function () { alert.remove(); }, 400);
        }, 4000);
    });

    // ── Confirm dangerous actions ─────────────────────────────
    document.querySelectorAll('[data-confirm]').forEach(function (el) {
        el.addEventListener('click', function (e) {
            const msg = el.getAttribute('data-confirm') || 'Bạn có chắc chắn?';
            if (!window.confirm(msg)) {
                e.preventDefault();
            }
        });
    });

    // ── Table row click-to-navigate ───────────────────────────
    document.querySelectorAll('tr[data-href]').forEach(function (row) {
        row.style.cursor = 'pointer';
        row.addEventListener('click', function () {
            window.location.href = row.getAttribute('data-href');
        });
    });

});
