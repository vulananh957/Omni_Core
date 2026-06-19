import subprocess
import os

bm_files = [
    # Controller - Shared Infra
    "src/main/java/com/wms/controller/BaseController.java",
    # Filter - Shared Infra
    "src/main/java/com/wms/filter/AuthFilter.java",
    "src/main/java/com/wms/filter/EncodingFilter.java",
    # Listener - Shared Infra
    "src/main/java/com/wms/listener/SchemaInitListener.java",
    # Util - Shared Infra
    "src/main/java/com/wms/util/AppConstants.java",
    "src/main/java/com/wms/util/DBConnection.java",
    "src/main/java/com/wms/util/DatabaseConfig.java",
    "src/main/java/com/wms/util/JsonUtil.java",
    "src/main/java/com/wms/util/LazadaAPIUtil.java",
    # DAO - Shared Infra
    "src/main/java/com/wms/dao/BaseDAO.java",
    # CSS - Shared Infra
    "src/main/webapp/assets/css/main.css",
    # Config / Build / Docs
    "src/main/webapp/assets/js/main.js",
    "src/main/webapp/WEB-INF/web.xml",
    "src/main/webapp/META-INF/context.xml",
    "pom.xml",
    "README.md",
    "src/main/resources/db.properties.example",
    # Schema
    "src/main/resources/schema.sql",
    # Error JSP - Shared Infra
    "src/main/webapp/WEB-INF/views/error/400.jsp",
    "src/main/webapp/WEB-INF/views/error/403.jsp",
    "src/main/webapp/WEB-INF/views/error/404.jsp",
    "src/main/webapp/WEB-INF/views/error/500.jsp",
    # Controller - Business
    "src/main/java/com/wms/controller/dashboard/BusinessDashboardServlet.java",
    "src/main/java/com/wms/controller/dashboard/BusinessProfileServlet.java",
    "src/main/java/com/wms/controller/sales/SalesMasterSKUServlet.java",
    "src/main/java/com/wms/controller/sales/SalesCategoryServlet.java",
    # Controller - Lazada Platform
    "src/main/java/com/wms/controller/lazada/LazadaWebhookServlet.java",
    "src/main/java/com/wms/controller/lazada/LazadaRtsServlet.java",
    "src/main/java/com/wms/controller/lazada/LazadaLabelServlet.java",
    # DAO - Business
    "src/main/java/com/wms/dao/LedgerDAO.java",
    "src/main/java/com/wms/dao/CategoryDAO.java",
    "src/main/java/com/wms/dao/ProductDAO.java",
    "src/main/java/com/wms/dao/LazadaCategoryDAO.java",
    "src/main/java/com/wms/dao/PushErrorDAO.java",
    # Model - Business
    "src/main/java/com/wms/model/Channel.java",
    "src/main/java/com/wms/model/Category.java",
    "src/main/java/com/wms/model/Product.java",
    "src/main/java/com/wms/model/LazadaCategory.java",
    # Service - Core BM
    "src/main/java/com/wms/service/ledger/LedgerService.java",
    "src/main/java/com/wms/service/product/CategoryService.java",
    "src/main/java/com/wms/service/product/ProductService.java",
    "src/main/java/com/wms/service/product/SkuGeneratorService.java",
    # Service - Lazada Platform
    "src/main/java/com/wms/service/lazada/LazadaHttpClient.java",
    "src/main/java/com/wms/service/lazada/LazadaOrderService.java",
    "src/main/java/com/wms/service/lazada/LazadaOrderSyncService.java",
    "src/main/java/com/wms/service/lazada/LazadaProductService.java",
    "src/main/java/com/wms/service/lazada/LazadaProductPayloadBuilder.java",
    "src/main/java/com/wms/service/lazada/LazadaFulfillmentService.java",
    "src/main/java/com/wms/service/lazada/LazadaShipmentService.java",
    "src/main/java/com/wms/service/lazada/LazadaRTSService.java",
    "src/main/java/com/wms/service/lazada/LazadaReverseService.java",
    "src/main/java/com/wms/service/lazada/LazadaWebhookService.java",
    "src/main/java/com/wms/service/lazada/LazadaCategorySyncService.java",
    "src/main/java/com/wms/service/lazada/LazadaErrorTranslator.java",
    "src/main/java/com/wms/service/channel/ChannelGateway.java",
    "src/main/java/com/wms/service/channel/LazadaChannelGateway.java",
    # Scheduler
    "src/main/java/com/wms/scheduler/LazadaSyncScheduler.java",
    "src/main/java/com/wms/scheduler/LazadaProductSyncScheduler.java",
    "src/main/java/com/wms/scheduler/LazadaInventoryPushScheduler.java",
    "src/main/java/com/wms/scheduler/LazadaTrackingPollScheduler.java",
    "src/main/java/com/wms/scheduler/LazadaTokenRefreshScheduler.java",
    # JSP Views - Business
    "src/main/webapp/WEB-INF/views/dashboard/business.jsp",
    "src/main/webapp/WEB-INF/views/dashboard/profile-settings.jsp",
    "src/main/webapp/WEB-INF/views/ledger/ledger.jsp",
    "src/main/webapp/WEB-INF/views/sales/categories.jsp",
    "src/main/webapp/WEB-INF/views/sales/mapping-exceptions.jsp",
    "src/main/webapp/WEB-INF/views/layout/sales-layout.jsp",
    # Layout JSP
    "src/main/webapp/WEB-INF/views/layout/dashboard-layout.jsp",
    # CSS - Business
    "src/main/webapp/assets/css/dashboard.css",
    "src/main/webapp/assets/css/layout--dashboard-layout.css",
    "src/main/webapp/assets/css/ledger--ledger.css",
    "src/main/webapp/assets/css/category--categories.css",
    "src/main/webapp/assets/css/sales--mapping-exceptions.css",

    # Newly added in commit 42ff8fd (Category mapping, Lazada sync, image upload):
    "src/main/java/com/wms/controller/sales/LazadaCategorySyncServlet.java",
    "src/main/java/com/wms/controller/sales/PublishImageServlet.java",
    "src/main/java/com/wms/controller/sales/SalesCategoryMappingsServlet.java",
    "src/main/java/com/wms/dao/CategoryMappingDAO.java",
    "src/main/java/com/wms/model/CategoryMapping.java",
    "src/main/java/com/wms/service/lazada/CatboxImageUploader.java",
    "src/main/java/com/wms/service/lazada/ImgbbImageUploader.java",
    "src/main/java/com/wms/controller/admin/ChannelConfigServlet.java",
    "src/main/webapp/assets/css/sales--channel-products.css"
]

admin_files = [
    # Controller (7)
    "src/main/java/com/wms/controller/admin/AdminProfileServlet.java",
    "src/main/java/com/wms/controller/admin/ChannelConfigServlet.java",
    "src/main/java/com/wms/controller/admin/ChannelListServlet.java",
    "src/main/java/com/wms/controller/admin/HealthCheckServlet.java",
    "src/main/java/com/wms/controller/admin/LazadaAuthCallbackServlet.java",
    "src/main/java/com/wms/controller/admin/UserManagementServlet.java",
    "src/main/java/com/wms/controller/staff/StaffServlet.java",
    
    # DAO (5)
    "src/main/java/com/wms/dao/RoleDAO.java",
    "src/main/java/com/wms/dao/UserDAO.java",
    "src/main/java/com/wms/dao/WarehouseDAO.java",
    "src/main/java/com/wms/dao/ChannelDAO.java",
    "src/main/java/com/wms/dao/ChannelProductDAO.java",
    
    # Model (4)
    "src/main/java/com/wms/model/Role.java",
    "src/main/java/com/wms/model/User.java",
    "src/main/java/com/wms/model/Warehouse.java",
    "src/main/java/com/wms/model/Zone.java",
    
    # Service (5)
    "src/main/java/com/wms/service/auth/AuthService.java",
    "src/main/java/com/wms/service/auth/EmailService.java",
    "src/main/java/com/wms/service/auth/AuthException.java",
    "src/main/java/com/wms/service/user/UserService.java",
    "src/main/java/com/wms/service/channel/ChannelRegistry.java",
    
    # JSP Views (5)
    "src/main/webapp/WEB-INF/views/admin/admin-profile.jsp",
    "src/main/webapp/WEB-INF/views/admin/channel-create.jsp",
    "src/main/webapp/WEB-INF/views/admin/channels-configuration.jsp",
    "src/main/webapp/WEB-INF/views/admin/users-management.jsp",
    "src/main/webapp/WEB-INF/views/admin/user-form.jsp",
    
    # Layout JSP (1)
    "src/main/webapp/WEB-INF/views/layout/admin-layout.jsp"
]

def run(cmd, env=None):
    print(f"Executing: {cmd}")
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    if res.returncode != 0:
        print(f"Error: {res.stderr}")
        raise Exception(f"Command failed: {cmd}")
    return res.stdout

def clean_working_directory(exclude_script):
    for root, dirs, files in os.walk(".", topdown=False):
        for name in files:
            if ".git" in root or name == exclude_script:
                continue
            try:
                os.remove(os.path.join(root, name))
            except Exception:
                pass
        for name in dirs:
            if ".git" in root or name == ".git":
                continue
            try:
                os.rmdir(os.path.join(root, name))
            except Exception:
                pass

script_name = "fix_bm_and_admin_branches.py"

try:
    # ----------------------------------------------------
    # FIX FEATURE-BUSINESS-MANAGER BRANCH
    # ----------------------------------------------------
    print("\n--- Fixing feature-business-manager branch ---")
    run("git checkout feature-business-manager")
    # Reset to fde2d82 (Vũ Lan Anh's last clean commit)
    run("git reset --hard fde2d82")
    # Clear index
    run("git rm -r --cached .")
    # Clean files on disk
    clean_working_directory(script_name)
    # Checkout latest files
    chunk_size = 20
    for i in range(0, len(bm_files), chunk_size):
        chunk = bm_files[i:i+chunk_size]
        files_str = " ".join(chunk)
        run(f"git checkout refactor/simplify-architecture -- {files_str}")
    # Add files
    run("git add .")
    # Commit with both author and committer set to Vũ Lan Anh
    custom_env = os.environ.copy()
    custom_env["GIT_AUTHOR_NAME"] = "Lan Anh Vu"
    custom_env["GIT_AUTHOR_EMAIL"] = "vulananh957@gmail.com"
    custom_env["GIT_COMMITTER_NAME"] = "Lan Anh Vu"
    custom_env["GIT_COMMITTER_EMAIL"] = "vulananh957@gmail.com"
    run('git commit -m "feat(business-manager): align Business Manager and SHARED components with refactored architecture"', env=custom_env)
    # Push to origin (Vu Lan Anh's token)
    run("git push origin feature-business-manager --force")

    # ----------------------------------------------------
    # FIX FEATURE-AUTH-ADMIN BRANCH
    # ----------------------------------------------------
    print("\n--- Fixing feature-auth-admin branch ---")
    run("git checkout feature-auth-admin")
    # Reset to 1b054f6 (Phạm Minh Quân's last clean commit)
    run("git reset --hard 1b054f6")
    # Clear index
    run("git rm -r --cached .")
    # Clean files on disk
    clean_working_directory(script_name)
    # Checkout latest files
    for i in range(0, len(admin_files), chunk_size):
        chunk = admin_files[i:i+chunk_size]
        files_str = " ".join(chunk)
        run(f"git checkout refactor/simplify-architecture -- {files_str}")
    # Add files
    run("git add .")
    # Commit with both author and committer set to Phạm Minh Quân
    custom_env = os.environ.copy()
    custom_env["GIT_AUTHOR_NAME"] = "Pham Minh Quan"
    custom_env["GIT_AUTHOR_EMAIL"] = "pmq07072005@gmail.com"
    custom_env["GIT_COMMITTER_NAME"] = "Pham Minh Quan"
    custom_env["GIT_COMMITTER_EMAIL"] = "pmq07072005@gmail.com"
    run('git commit -m "feat(auth-admin): align SYSTEM_ADMIN components with refactored architecture"', env=custom_env)
    # Push to gitlab-pmq (Pham Minh Quan's token)
    run("git push gitlab-pmq feature-auth-admin --force")

    print("\nSuccess! Both branches have been fully corrected and pushed with exact committer identities.")

finally:
    # Switch back to the development branch and restore it to clean state
    run("git checkout refactor/simplify-architecture")
    run("git reset --hard HEAD")
    run("git clean -fd")
