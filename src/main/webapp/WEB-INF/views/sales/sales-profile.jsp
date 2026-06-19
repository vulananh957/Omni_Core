<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="sales-prof max-w-3xl" style="max-width: 48rem; margin: 0 auto;">
    
    <!-- Status Toast Notification -->
    <div id="profToast" class="prof-toast hidden">
        <span class="prof-toast__icon">✓</span>
        <span id="profToastMsg" class="prof-toast__msg">Cập nhật thành công!</span>
    </div>

    <!-- Personal Info Form -->
    <form id="salesPersonalInfoForm" class="bg-white border border-[#E5EAF3] p-6 mb-4" style="border-radius: var(--radius-card); margin-bottom: 1.5rem; background: white; border: 1px solid #E5EAF3; padding: 1.5rem;">
        <div class="flex items-center gap-3 mb-5" style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 1.25rem;">
            <div class="w-10 h-10 bg-alice flex items-center justify-center" style="width: 2.5rem; height: 2.5rem; background: var(--alice); display: flex; align-items: center; justify-content: center; border-radius: var(--radius-btn);">
                <svg class="w-5 h-5 text-navy/60" style="width: 1.25rem; height: 1.25rem; color: rgba(16,55,92,0.60);" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                    <circle cx="12" cy="7" r="4"></circle>
                </svg>
            </div>
            <div>
                <h3 class="text-navy text-[15px] font-bold" style="color: var(--navy); font-size: 15px; font-weight: 700; margin: 0;">Thông tin cá nhân</h3>
                <p class="text-navy/45 text-[12px]" style="color: rgba(16,55,92,0.45); font-size: 12px; margin: 0.125rem 0 0 0;">Cập nhật thông tin tài khoản của bạn</p>
            </div>
        </div>

        <div class="space-y-4" style="display: flex; flex-direction: column; gap: 1rem;">
            <div>
                <label class="block text-navy/70 text-[12px] font-semibold mb-1.5" style="display: block; color: rgba(16,55,92,0.70); font-size: 12px; font-weight: 600; margin-bottom: 0.375rem;">Họ và tên</label>
                <input
                    type="text"
                    id="fullName"
                    name="fullName"
                    value="<c:out value='${loggedInUser.fullName}'/>"
                    required
                    class="w-full px-4 py-2.5 bg-alice border border-[#E5EAF3] text-navy text-[13px] outline-none focus:border-navy/30 transition"
                    style="width: 100%; padding: 0.625rem 1rem; background: var(--alice); border: 1px solid #E5EAF3; color: var(--navy); font-size: 13px; outline: none; border-radius: calc(var(--radius-btn) - 2px); transition: border-color 0.2s;"
                />
            </div>

            <div>
                <label class="block text-navy/70 text-[12px] font-semibold mb-1.5" style="display: block; color: rgba(16,55,92,0.70); font-size: 12px; font-weight: 600; margin-bottom: 0.375rem;">Email</label>
                <div class="relative" style="position: relative;">
                    <svg class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-navy/30" style="position: absolute; left: 0.75rem; top: 50%; transform: translateY(-50%); width: 1rem; height: 1rem; color: rgba(16,55,92,0.30);" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect width="20" height="16" x="2" y="4" rx="2"></rect>
                        <path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"></path>
                    </svg>
                    <input
                        type="email"
                        id="email"
                        name="email"
                        value="<c:out value='${loggedInUser.email}'/>"
                        required
                        class="w-full pl-10 pr-4 py-2.5 bg-alice border border-[#E5EAF3] text-navy text-[13px] outline-none focus:border-navy/30 transition"
                        style="width: 100%; padding: 0.625rem 1rem 0.625rem 2.5rem; background: var(--alice); border: 1px solid #E5EAF3; color: var(--navy); font-size: 13px; outline: none; border-radius: calc(var(--radius-btn) - 2px); transition: border-color 0.2s;"
                    />
                </div>
            </div>

            <div>
                <label class="block text-navy/70 text-[12px] font-semibold mb-1.5" style="display: block; color: rgba(16,55,92,0.70); font-size: 12px; font-weight: 600; margin-bottom: 0.375rem;">Số điện thoại</label>
                <div class="relative" style="position: relative;">
                    <svg class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-navy/30" style="position: absolute; left: 0.75rem; top: 50%; transform: translateY(-50%); width: 1rem; height: 1rem; color: rgba(16,55,92,0.30);" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
                    </svg>
                    <input
                        type="tel"
                        id="phone"
                        name="phone"
                        value="<c:out value='${loggedInUser.phone}'/>"
                        placeholder="Chưa cập nhật số điện thoại"
                        class="w-full pl-10 pr-4 py-2.5 bg-alice border border-[#E5EAF3] text-navy text-[13px] outline-none focus:border-navy/30 transition"
                        style="width: 100%; padding: 0.625rem 1rem 0.625rem 2.5rem; background: var(--alice); border: 1px solid #E5EAF3; color: var(--navy); font-size: 13px; outline: none; border-radius: calc(var(--radius-btn) - 2px); transition: border-color 0.2s;"
                    />
                </div>
            </div>

            <div>
                <label class="block text-navy/70 text-[12px] font-semibold mb-1.5" style="display: block; color: rgba(16,55,92,0.70); font-size: 12px; font-weight: 600; margin-bottom: 0.375rem;">Vai trò</label>
                <input
                    type="text"
                    value="Sales Staff"
                    disabled
                    class="w-full px-4 py-2.5 bg-[#F0F3FA] border border-[#E5EAF3] text-navy/40 text-[13px] cursor-not-allowed"
                    style="width: 100%; padding: 0.625rem 1rem; background: #F0F3FA; border: 1px solid #E5EAF3; color: rgba(16,55,92,0.40); font-size: 13px; cursor: not-allowed; border-radius: calc(var(--radius-btn) - 2px);"
                />
            </div>
        </div>
    </form>

    <!-- Change Password Form -->
    <form id="salesPasswordForm" class="bg-white border border-[#E5EAF3] p-6 mb-6" style="border-radius: var(--radius-card); margin-bottom: 1.5rem; background: white; border: 1px solid #E5EAF3; padding: 1.5rem;">
        <div class="flex items-center gap-3 mb-5" style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 1.25rem;">
            <div class="w-10 h-10 bg-alice flex items-center justify-center" style="width: 2.5rem; height: 2.5rem; background: var(--alice); display: flex; align-items: center; justify-content: center; border-radius: var(--radius-btn);">
                <svg class="w-5 h-5 text-navy/60" style="width: 1.25rem; height: 1.25rem; color: rgba(16,55,92,0.60);" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <rect width="18" height="11" x="3" y="11" rx="2" ry="2"></rect>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                </svg>
            </div>
            <div>
                <h3 class="text-navy text-[15px] font-bold" style="color: var(--navy); font-size: 15px; font-weight: 700; margin: 0;">Đổi mật khẩu</h3>
                <p class="text-navy/45 text-[12px]" style="color: rgba(16,55,92,0.45); font-size: 12px; margin: 0.125rem 0 0 0;">Cập nhật mật khẩu để bảo mật tài khoản</p>
            </div>
        </div>

        <div class="space-y-4" style="display: flex; flex-direction: column; gap: 1rem;">
            <div>
                <label class="block text-navy/70 text-[12px] font-semibold mb-1.5" style="display: block; color: rgba(16,55,92,0.70); font-size: 12px; font-weight: 600; margin-bottom: 0.375rem;">Mật khẩu hiện tại</label>
                <input
                    type="password"
                    id="currentPassword"
                    placeholder="••••••••"
                    class="w-full px-4 py-2.5 bg-alice border border-[#E5EAF3] text-navy text-[13px] outline-none focus:border-navy/30 transition"
                    style="width: 100%; padding: 0.625rem 1rem; background: var(--alice); border: 1px solid #E5EAF3; color: var(--navy); font-size: 13px; outline: none; border-radius: calc(var(--radius-btn) - 2px); transition: border-color 0.2s;"
                />
            </div>

            <div>
                <label class="block text-navy/70 text-[12px] font-semibold mb-1.5" style="display: block; color: rgba(16,55,92,0.70); font-size: 12px; font-weight: 600; margin-bottom: 0.375rem;">Mật khẩu mới</label>
                <input
                    type="password"
                    id="newPassword"
                    placeholder="••••••••"
                    class="w-full px-4 py-2.5 bg-alice border border-[#E5EAF3] text-navy text-[13px] outline-none focus:border-navy/30 transition"
                    style="width: 100%; padding: 0.625rem 1rem; background: var(--alice); border: 1px solid #E5EAF3; color: var(--navy); font-size: 13px; outline: none; border-radius: calc(var(--radius-btn) - 2px); transition: border-color 0.2s;"
                />
            </div>

            <div>
                <label class="block text-navy/70 text-[12px] font-semibold mb-1.5" style="display: block; color: rgba(16,55,92,0.70); font-size: 12px; font-weight: 600; margin-bottom: 0.375rem;">Xác nhận mật khẩu mới</label>
                <input
                    type="password"
                    id="confirmPassword"
                    placeholder="••••••••"
                    class="w-full px-4 py-2.5 bg-alice border border-[#E5EAF3] text-navy text-[13px] outline-none focus:border-navy/30 transition"
                    style="width: 100%; padding: 0.625rem 1rem; background: var(--alice); border: 1px solid #E5EAF3; color: var(--navy); font-size: 13px; outline: none; border-radius: calc(var(--radius-btn) - 2px); transition: border-color 0.2s;"
                />
            </div>
        </div>
    </form>

    <!-- Save Button -->
    <div class="flex justify-end" style="display: flex; justify-content: flex-end;">
        <button id="salesSaveAllBtn" type="button" class="flex items-center gap-2 px-5 py-2.5 bg-navy text-white text-[13px] font-semibold hover:bg-navy-700 transition" style="display: flex; align-items: center; gap: 0.5rem; padding: 0.625rem 1.25rem; background: var(--navy); color: white; border: none; font-size: 13px; font-weight: 600; border-radius: calc(var(--radius-btn) - 2px); cursor: pointer; transition: background 0.2s;">
            <svg style="width: 1rem; height: 1rem;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path>
                <polyline points="17 21 17 13 7 13 7 21"></polyline>
                <polyline points="7 3 7 8 15 8"></polyline>
            </svg>
            Lưu thay đổi
        </button>
    </div>
</div>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sales--sales-profile.css"/>

<script>
document.addEventListener("DOMContentLoaded", function () {
    const username = "<c:out value='${loggedInUser.username}'/>" || "default_user";
    const storageKey = "wms_profile_" + username;

    // Save Action
    document.getElementById("salesSaveAllBtn").addEventListener("click", function () {
        const fullName = document.getElementById("fullName").value.trim();
        const email = document.getElementById("email").value.trim();
        const phone = document.getElementById("phone").value.trim();
        
        // Passwords
        const curPass = document.getElementById("currentPassword").value;
        const newPass = document.getElementById("newPassword").value;
        const confPass = document.getElementById("confirmPassword").value;

        // Validations
        if (!fullName || !email) {
            showToast("Vui lòng điền Họ và tên và Email", true);
            return;
        }

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            showToast("Định dạng Email không hợp lệ", true);
            return;
        }

        const updateProfile = () => {
            const params = new URLSearchParams();
            params.append("action", "updateProfile");
            params.append("fullName", fullName);
            params.append("email", email);
            params.append("phone", phone);

            return fetch("${pageContext.request.contextPath}/sales/profile", {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded"
                },
                body: params.toString()
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    // Update LocalStorage cache for interop
                    const profileObj = { fullName, email, phone };
                    localStorage.setItem(storageKey, JSON.stringify(profileObj));

                    const sidebarNameElement = document.querySelector(".sidebar__user-name");
                    if (sidebarNameElement) {
                        sidebarNameElement.textContent = fullName;
                    }
                    showToast(data.message, false);
                } else {
                    showToast(data.message, true);
                }
            });
        };

        // Password change handling
        if (curPass || newPass || confPass) {
            if (!curPass) {
                showToast("Vui lòng nhập mật khẩu hiện tại", true);
                return;
            }
            if (newPass.length < 8) {
                showToast("Mật khẩu mới phải có ít nhất 8 ký tự", true);
                return;
            }
            if (newPass !== confPass) {
                showToast("Mật khẩu mới và xác nhận mật khẩu không khớp", true);
                return;
            }

            const pwdParams = new URLSearchParams();
            pwdParams.append("action", "updatePassword");
            pwdParams.append("currentPassword", curPass);
            pwdParams.append("newPassword", newPass);

            fetch("${pageContext.request.contextPath}/sales/profile", {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded"
                },
                body: pwdParams.toString()
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    localStorage.setItem("wms_pwd_" + username, newPass);
                    document.getElementById("currentPassword").value = "";
                    document.getElementById("newPassword").value = "";
                    document.getElementById("confirmPassword").value = "";

                    // Proceed to update profile info
                    updateProfile();
                } else {
                    showToast(data.message, true);
                }
            })
            .catch(() => {
                showToast("Lỗi kết nối máy chủ khi đổi mật khẩu", true);
            });
        } else {
            updateProfile().catch(() => {
                showToast("Lỗi kết nối máy chủ", true);
            });
        }
    });

    function showToast(message, isError) {
        const toast = document.getElementById("profToast");
        const msgSpan = document.getElementById("profToastMsg");
        const iconSpan = toast.querySelector(".prof-toast__icon");

        msgSpan.textContent = message;
        toast.className = "prof-toast show";
        if (isError) {
            toast.classList.add("error");
            iconSpan.textContent = "✕";
        } else {
            iconSpan.textContent = "✓";
        }

        toast.style.display = "flex";

        setTimeout(() => {
            toast.classList.remove("show");
            setTimeout(() => {
                toast.style.display = "none";
            }, 300);
        }, 3000);
    }
});
</script>
