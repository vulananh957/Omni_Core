<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="admin-prof max-w-3xl" style="max-width: 48rem; margin: 0 auto;">
    
    <!-- Status Toast Notification -->
    <div id="profToast" class="prof-toast hidden">
        <span class="prof-toast__icon">✓</span>
        <span id="profToastMsg" class="prof-toast__msg">Cập nhật thành công!</span>
    </div>

    <!-- Personal Info Card -->
    <div class="bg-white border border-[#E5EAF3] p-6 mb-4" style="border-radius: var(--radius-card); margin-bottom: 1rem; background: white; border: 1px solid #E5EAF3; padding: 1.5rem;">
        <div class="flex items-center gap-3 mb-5" style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 1.25rem;">
            <div class="w-10 h-10 bg-alice flex items-center justify-center" style="width: 2.5rem; height: 2.5rem; background: var(--alice); display: flex; align-items: center; justify-content: center; border-radius: var(--radius-btn);">
                <svg class="text-navy/60" style="width: 20px; height: 20px; color: rgba(16,55,92,0.60);" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                    <circle cx="12" cy="7" r="4"></circle>
                </svg>
            </div>
            <div>
                <h3 class="text-navy text-[15px] font-bold" style="color: var(--navy); font-size: 15px; font-weight: 700; margin: 0;">Thông tin cá nhân</h3>
                <p class="text-navy/45 text-[12px]" style="color: rgba(16,55,92,0.45); font-size: 12px; margin: 0.125rem 0 0 0;">Thông tin tài khoản System Admin</p>
            </div>
        </div>

        <!-- Avatar Banner -->
        <div class="flex items-center gap-4 mb-5 p-4 bg-alice" style="display: flex; align-items: center; gap: 1rem; padding: 1rem; background: var(--alice); border-radius: calc(var(--radius-btn) - 2px); margin-bottom: 1.25rem;">
            <div id="avatarInitial" class="w-14 h-14 rounded-full bg-gradient-to-br from-violet-400 to-violet-700 flex items-center justify-center text-white text-[20px] font-bold flex-shrink-0" style="width: 3.5rem; height: 3.5rem; border-radius: 50%; background: linear-gradient(135deg, #a78bfa, #7c3aed); display: flex; align-items: center; justify-content: center; color: white; font-size: 20px; font-weight: 700; flex-shrink: 0;">
            </div>
            <div class="flex-1" style="flex: 1;">
                <div class="flex items-center gap-2" style="display: flex; align-items: center; gap: 0.5rem;">
                    <div id="avatarName" class="text-navy text-[14px] font-bold" style="color: var(--navy); font-size: 14px; font-weight: 700;"><c:out value="${loggedInUser.fullName}"/></div>
                    <span class="flex items-center gap-1 px-2 py-0.5 bg-violet-50 text-violet-700 text-[10px] font-semibold" style="display: inline-flex; align-items: center; gap: 0.25rem; padding: 0.125rem 0.5rem; background: #f5f3ff; color: #6d28d9; font-size: 10px; font-weight: 600; border-radius: 20px; border: 1px solid rgba(109,40,217,0.1);">
                        <svg style="width: 10px; height: 10px;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                        </svg>
                        System Admin
                    </span>
                </div>
                <div class="text-navy/50 text-[12px]" style="color: rgba(16,55,92,0.50); font-size: 12px; margin-top: 0.125rem;">Toàn quyền hệ thống</div>
            </div>
        </div>
 
        <form id="adminPersonalInfoForm" class="space-y-4" style="display: flex; flex-direction: column; gap: 1rem;">
            <div>
                <label class="block text-navy/70 text-[12px] font-semibold mb-1.5" style="display: block; color: rgba(16,55,92,0.70); font-size: 12px; font-weight: 600; margin-bottom: 0.375rem;">Username</label>
                <div class="relative" style="position: relative;">
                    <svg class="absolute left-3 top-1/2 -translate-y-1/2 text-navy/30" style="position: absolute; left: 0.75rem; top: 50%; transform: translateY(-50%); width: 16px; height: 16px; color: rgba(16,55,92,0.30);" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                        <circle cx="12" cy="7" r="4"></circle>
                    </svg>
                    <input
                        type="text"
                        id="username"
                        name="username"
                        value="<c:out value='${loggedInUser.username}'/>"
                        required
                        class="w-full pl-10 pr-4 py-2.5 bg-alice border border-[#E5EAF3] text-navy text-[13px] outline-none focus:border-navy/30 transition"
                        style="width: 100%; padding: 0.625rem 1rem 0.625rem 2.5rem; background: var(--alice); border: 1px solid #E5EAF3; color: var(--navy); font-size: 13px; outline: none; border-radius: calc(var(--radius-btn) - 2px); transition: border-color 0.2s;"
                    />
                </div>
                <p class="text-navy/40 text-[11px] mt-1" style="color: rgba(16,55,92,0.40); font-size: 11px; margin-top: 0.25rem;">Chỉ gồm chữ, số và dấu gạch dưới (_). 3-30 ký tự.</p>
            </div>

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
                    <svg class="absolute left-3 top-1/2 -translate-y-1/2 text-navy/30" style="position: absolute; left: 0.75rem; top: 50%; transform: translateY(-50%); width: 16px; height: 16px; color: rgba(16,55,92,0.30);" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
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
                    <svg class="absolute left-3 top-1/2 -translate-y-1/2 text-navy/30" style="position: absolute; left: 0.75rem; top: 50%; transform: translateY(-50%); width: 16px; height: 16px; color: rgba(16,55,92,0.30);" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
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

            <div class="flex justify-end pt-2" style="display: flex; justify-content: flex-end; padding-top: 0.5rem;">
                <button
                    id="saveProfileBtn"
                    type="button"
                    class="flex items-center gap-2 px-5 py-2.5 bg-orange text-white text-[13px] font-semibold hover:bg-orange-600 transition"
                    style="display: flex; align-items: center; gap: 0.5rem; padding: 0.625rem 1.25rem; background: var(--orange); color: white; border: none; font-size: 13px; font-weight: 600; border-radius: calc(var(--radius-btn) - 2px); cursor: pointer; transition: background 0.2s; box-shadow: 0 4px 12px rgba(235,131,23,0.20);"
                >
                    <svg style="width: 14px; height: 14px;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path>
                        <polyline points="17 21 17 13 7 13 7 21"></polyline>
                        <polyline points="7 3 7 8 15 8"></polyline>
                    </svg>
                    Lưu thay đổi
                </button>
            </div>
        </form>
    </div>

    <!-- Change Password Card -->
    <div class="bg-white border border-[#E5EAF3] p-6 mb-4" style="border-radius: var(--radius-card); background: white; border: 1px solid #E5EAF3; padding: 1.5rem; margin-bottom: 1rem;">
        <div class="flex items-center gap-3 mb-5" style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 1.25rem;">
            <div class="w-10 h-10 bg-alice flex items-center justify-center" style="width: 2.5rem; height: 2.5rem; background: var(--alice); display: flex; align-items: center; justify-content: center; border-radius: var(--radius-btn);">
                <svg class="text-navy/60" style="width: 20px; height: 20px; color: rgba(16,55,92,0.60);" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <rect width="18" height="11" x="3" y="11" rx="2" ry="2"></rect>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                </svg>
            </div>
            <div>
                <h3 class="text-navy text-[15px] font-bold" style="color: var(--navy); font-size: 15px; font-weight: 700; margin: 0;">Đổi mật khẩu</h3>
                <p class="text-navy/45 text-[12px]" style="color: rgba(16,55,92,0.45); font-size: 12px; margin: 0.125rem 0 0 0;">Mật khẩu mạnh là lớp bảo vệ đầu tiên của hệ thống</p>
            </div>
        </div>

        <form id="adminPasswordForm" class="space-y-4" style="display: flex; flex-direction: column; gap: 1rem;">
            <div class="grid grid-cols-2 gap-4" style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 1rem;">
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

            <!-- Admin Password Tips -->
            <div class="p-3 bg-alice" style="padding: 0.75rem; background: var(--alice); border-radius: calc(var(--radius-btn) - 2px);">
                <p class="text-navy/50 text-[11px] font-semibold mb-1" style="color: rgba(16,55,92,0.50); font-size: 11px; font-weight: 600; margin: 0 0 0.25rem 0;">Yêu cầu mật khẩu Admin:</p>
                <ul class="space-y-0.5" style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 0.125rem;">
                    <li class="text-navy/40 text-[11px] flex items-center gap-1.5" style="color: rgba(16,55,92,0.40); font-size: 11px; display: flex; align-items: center; gap: 0.375rem;">
                        <span class="w-1 h-1 rounded-full bg-navy/30 flex-shrink-0" style="width: 4px; height: 4px; border-radius: 50%; background: rgba(16,55,92,0.30); display: inline-block; flex-shrink: 0;"></span>
                        Ít nhất 8 ký tự
                    </li>
                    <li class="text-navy/40 text-[11px] flex items-center gap-1.5" style="color: rgba(16,55,92,0.40); font-size: 11px; display: flex; align-items: center; gap: 0.375rem;">
                        <span class="w-1 h-1 rounded-full bg-navy/30 flex-shrink-0" style="width: 4px; height: 4px; border-radius: 50%; background: rgba(16,55,92,0.30); display: inline-block; flex-shrink: 0;"></span>
                        Có chữ hoa, chữ thường và số
                    </li>
                    <li class="text-navy/40 text-[11px] flex items-center gap-1.5" style="color: rgba(16,55,92,0.40); font-size: 11px; display: flex; align-items: center; gap: 0.375rem;">
                        <span class="w-1 h-1 rounded-full bg-navy/30 flex-shrink-0" style="width: 4px; height: 4px; border-radius: 50%; background: rgba(16,55,92,0.30); display: inline-block; flex-shrink: 0;"></span>
                        Có ít nhất 1 ký tự đặc biệt (!@#$%)
                    </li>
                    <li class="text-navy/40 text-[11px] flex items-center gap-1.5" style="color: rgba(16,55,92,0.40); font-size: 11px; display: flex; align-items: center; gap: 0.375rem;">
                        <span class="w-1 h-1 rounded-full bg-navy/30 flex-shrink-0" style="width: 4px; height: 4px; border-radius: 50%; background: rgba(16,55,92,0.30); display: inline-block; flex-shrink: 0;"></span>
                        Không trùng với mật khẩu gần nhất
                    </li>
                </ul>
            </div>

            <div class="flex justify-end pt-2" style="display: flex; justify-content: flex-end; padding-top: 0.5rem;">
                <button
                    id="savePasswordBtn"
                    type="button"
                    class="flex items-center gap-2 px-5 py-2.5 bg-navy text-white text-[13px] font-semibold hover:bg-navy-700 transition"
                    style="display: flex; align-items: center; gap: 0.5rem; padding: 0.625rem 1.25rem; background: var(--navy); color: white; border: none; font-size: 13px; font-weight: 600; border-radius: calc(var(--radius-btn) - 2px); cursor: pointer; transition: background 0.2s;"
                >
                    <svg style="width: 14px; height: 14px;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect width="18" height="11" x="3" y="11" rx="2" ry="2"></rect>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                    </svg>
                    Cập nhật mật khẩu
                </button>
            </div>
        </form>
    </div>



</div>

<style>
/* Toast Notification CSS */
.prof-toast {
    position: fixed;
    top: 24px;
    right: 24px;
    background: #0F2C59;
    color: #fff;
    padding: 12px 20px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 13px;
    font-weight: 600;
    box-shadow: 0 10px 25px rgba(0,0,0,0.15);
    z-index: 9999;
    opacity: 0;
    transform: translateY(-20px);
    transition: opacity 0.3s, transform 0.3s;
}
.prof-toast.show {
    opacity: 1;
    transform: translateY(0);
}
.prof-toast.error {
    background: #DC2626;
}
.prof-toast__icon {
    font-size: 16px;
}
.prof-toast.hidden {
    display: none;
}
</style>

<script>
document.addEventListener("DOMContentLoaded", function () {
    const username = "<c:out value='${loggedInUser.username}'/>" || "default_user";
    const storageKey = "wms_profile_" + username;

    <c:choose>
    <c:when test="${not empty successMessage}">
        showToast("<c:out value='${successMessage}'/>", false);
    </c:when>
    <c:when test="${not empty errorMessage}">
        showToast("<c:out value='${errorMessage}'/>", true);
    </c:when>
    </c:choose>

    function getAvatarInitial(name) {
        if (!name) return "";
        const parts = name.trim().split(/\s+/);
        const lastName = parts[parts.length - 1];
        return lastName ? lastName.charAt(0).toUpperCase() : "";
    }

    // Set initial avatar text
    const initialNameVal = document.getElementById("avatarName").textContent;
    document.getElementById("avatarInitial").textContent = getAvatarInitial(initialNameVal);

    // Load initial values from localStorage (as fallback and interop)
    const savedData = localStorage.getItem(storageKey);
    if (savedData) {
        try {
            const data = JSON.parse(savedData);
            if (data.fullName && !document.getElementById("fullName").value) {
                document.getElementById("fullName").value = data.fullName;
                document.getElementById("avatarName").textContent = data.fullName;
            }
            if (data.email && !document.getElementById("email").value) {
                document.getElementById("email").value = data.email;
            }
            if (data.phone && !document.getElementById("phone").value) {
                document.getElementById("phone").value = data.phone;
            }
        } catch (e) {
            console.error("Error parsing saved profile data:", e);
        }
    }

    // Save Personal Info
    document.getElementById("saveProfileBtn").addEventListener("click", function () {
        const username = document.getElementById("username").value.trim();
        const fullName = document.getElementById("fullName").value.trim();
        const email = document.getElementById("email").value.trim();
        const phone = document.getElementById("phone").value.trim();

        if (!username) {
            showToast("Username không được để trống", true);
            return;
        }

        if (username.length < 3 || username.length > 30) {
            showToast("Username phải từ 3 đến 30 ký tự", true);
            return;
        }

        if (!/^[a-zA-Z0-9_]+$/.test(username)) {
            showToast("Username chỉ được chứa chữ, số và dấu gạch dưới", true);
            return;
        }

        if (!fullName || !email) {
            showToast("Vui lòng điền Họ và tên và Email", true);
            return;
        }

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            showToast("Định dạng Email không hợp lệ", true);
            return;
        }

        // Perform backend POST call to update profile details
        const params = new URLSearchParams();
        params.append("action", "updateProfile");
        params.append("username", username);
        params.append("fullName", fullName);
        params.append("email", email);
        params.append("phone", phone);

        fetch("${pageContext.request.contextPath}/admin/profile", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: params.toString()
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                // Update LocalStorage for cross-component cache
                const profileObj = { fullName, email, phone };
                localStorage.setItem(storageKey, JSON.stringify(profileObj));

                // Update UI elements
                document.getElementById("avatarName").textContent = fullName;
                document.getElementById("avatarInitial").textContent = getAvatarInitial(fullName);
                
                const sidebarNameElement = document.querySelector(".sidebar__user-name");
                if (sidebarNameElement) {
                    sidebarNameElement.textContent = fullName;
                }

                showToast(data.message, false);
            } else {
                showToast(data.message, true);
            }
        })
        .catch(err => {
            showToast("Lỗi kết nối máy chủ", true);
        });
    });

    // Save Password - Requires OTP verification
    document.getElementById("savePasswordBtn").addEventListener("click", function () {
        const newPass = document.getElementById("newPassword").value;
        const confPass = document.getElementById("confirmPassword").value;

        if (!newPass || !confPass) {
            showToast("Vui lòng điền đầy đủ mật khẩu mới và xác nhận", true);
            return;
        }

        if (newPass.length < 8) {
            showToast("Mật khẩu Admin mới phải có ít nhất 8 ký tự", true);
            return;
        }

        const hasUpper = /[A-Z]/.test(newPass);
        const hasLower = /[a-z]/.test(newPass);
        const hasDigit = /[0-9]/.test(newPass);
        const hasSpec  = /[!@#\$%\^&\*\(\)_\+\-\=\[\]\{\};':",\.\/<>\?~\\|]/.test(newPass);

        if (!hasUpper || !hasLower || !hasDigit || !hasSpec) {
            showToast("Mật khẩu không đáp ứng đầy đủ yêu cầu bảo mật nghiêm ngặt của Admin", true);
            return;
        }

        if (newPass !== confPass) {
            showToast("Mật khẩu mới và xác nhận mật khẩu không khớp", true);
            return;
        }

        // Store password in session and redirect to OTP verification
        fetch("${pageContext.request.contextPath}/admin/profile", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: new URLSearchParams({
                action: "initPasswordChange",
                newPassword: newPass
            })
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                // OTP will be sent and user will be redirected
                window.location.href = "${pageContext.request.contextPath}/password-change-otp";
            } else {
                showToast(data.message, true);
            }
        })
        .catch(err => {
            showToast("Lỗi kết nối máy chủ", true);
        });
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
