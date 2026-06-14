package com.wms.controller.category;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.controller.BaseController;
import com.wms.model.Category;
import com.wms.service.product.CategoryService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * CategoryServlet — Handles requests for the Category Management page.
 *
 * Maps to /business/categories.
 *
 * Business rules:
 * - categoryCode: required on create, 3-4 chars, uppercase, permanently
 *   locked (immutable) the moment a category is created.
 * - Deactivate cascades to all descendants; reactivate is blocked while any
 *   ancestor is still inactive.
 * - Delete: hard delete if no products, soft delete (deactivate) if has
 *   products.
 */
public class CategoryServlet extends BaseController {

    private static final Logger LOGGER = Logger.getLogger(CategoryServlet.class.getName());
    private final CategoryService categoryService = new CategoryService();
    private final ObjectMapper objectMapper;

    public CategoryServlet() {
        objectMapper = new ObjectMapper();
        objectMapper.findAndRegisterModules();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            // Heal pre-existing inconsistent state where a descendant is active
            // while one of its ancestors is inactive. Safe to call repeatedly.
            int repaired = categoryService.ensureCascadeConsistency();
            if (repaired > 0) {
                LOGGER.info("CategoryServlet: Healed " + repaired
                    + " inconsistent active-descendant(s) under inactive ancestor(s).");
            }

            List<Category> categoryList = categoryService.findAll();
            req.setAttribute("categories", categoryList);
            // Create JSON manually to ensure UTF-8 encoding
            StringBuilder jsonBuilder = new StringBuilder("[");
            for (int i = 0; i < categoryList.size(); i++) {
                Category cat = categoryList.get(i);
                if (i > 0) jsonBuilder.append(",");
                jsonBuilder.append("{");
                jsonBuilder.append("\"id\":").append(cat.getCategoryId()).append(",");
                jsonBuilder.append("\"code\":\"").append(escapeJson(cat.getCategoryCode())).append("\",");
                jsonBuilder.append("\"name\":\"").append(escapeJson(cat.getCategoryName())).append("\",");
                jsonBuilder.append("\"parentId\":").append(cat.getParentId() == null ? "null" : cat.getParentId()).append(",");
                jsonBuilder.append("\"description\":\"").append(escapeJson(cat.getDescription() != null ? cat.getDescription() : "")).append("\",");
                jsonBuilder.append("\"immutable\":").append(cat.isImmutable()).append(",");
                jsonBuilder.append("\"active\":").append(cat.isActive());
                jsonBuilder.append("}");
            }
            jsonBuilder.append("]");
            req.setAttribute("categoriesJson", jsonBuilder.toString());
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "CategoryServlet: Failed to load categories", e);
        }

        req.setAttribute("pageTitle",    "Quản lý danh mục sản phẩm");
        req.setAttribute("pageSubtitle", "Xây dựng sơ đồ cây phân cấp danh mục sản phẩm và ánh xạ danh mục đa sàn");
        req.setAttribute("currentPage",  "categories");

        req.setAttribute("contentPage", "/WEB-INF/views/category/categories.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/dashboard-layout.jsp")
           .forward(req, resp);
    }



    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        boolean success = false;
        String message = "";

        try {
            if ("create".equals(action)) {
                success = handleCreate(req);
                message = success ? "Tao danh muc thanh cong!" : "Tao danh muc that bai.";
            } else if ("update".equals(action)) {
                success = handleUpdate(req);
                message = success ? "Cap nhat danh muc thanh cong!" : "Cap nhat danh muc that bai.";
            } else if ("delete".equals(action)) {
                success = handleDelete(req);
                message = success ? "Xoa danh muc thanh cong!" : "Xoa danh muc that bai.";
            } else if ("deactivate".equals(action)) {
                success = handleDeactivate(req);
                message = success ? "Ngung hoat dong danh muc thanh cong!" : "Ngung hoat dong that bai.";
            } else if ("reactivate".equals(action)) {
                success = handleReactivate(req);
                message = success ? "Kich hoat lai danh muc thanh cong!" : "Kich hoat lai that bai.";
            } else {
                message = "Hanh dong khong hop le.";
            }
        } catch (IllegalArgumentException e) {
            LOGGER.log(Level.WARNING, "CategoryServlet: Validation error: " + e.getMessage());
            message = e.getMessage();
            success = false;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "CategoryServlet: Error processing action " + action, e);
            message = "Da xay ra loi khi xu ly yeu cau.";
            success = false;
        }

        req.getSession().setAttribute("categoryMessage", message);
        req.getSession().setAttribute("categorySuccess", success);

        resp.sendRedirect(req.getContextPath() + "/business/categories");
    }

    private boolean handleCreate(HttpServletRequest req) throws Exception {
        String name = req.getParameter("categoryName");
        String code = req.getParameter("categoryCode");
        String parentIdStr = req.getParameter("parentId");

        if (isNullOrEmpty(name) || isNullOrEmpty(code)) {
            return false;
        }

        // Validate category code
        CategoryService.ValidationResult codeValidation = categoryService.validateCategoryCode(code);
        if (!codeValidation.isSuccess()) {
            throw new IllegalArgumentException(codeValidation.getMessage());
        }

        Integer parentId = null;
        if (!isNullOrEmpty(parentIdStr)) {
            try {
                parentId = Integer.parseInt(parentIdStr);
            } catch (NumberFormatException e) {
                LOGGER.log(Level.WARNING, "CategoryServlet: Invalid parentId: " + parentIdStr);
            }
        }

        return categoryService.createCategory(name, code, parentId);
    }

    private boolean handleUpdate(HttpServletRequest req) throws Exception {
        String categoryIdStr = req.getParameter("categoryId");
        String name = req.getParameter("categoryName");
        String parentIdStr = req.getParameter("parentId");

        if (isNullOrEmpty(categoryIdStr) || isNullOrEmpty(name)) {
            return false;
        }

        int categoryId = Integer.parseInt(categoryIdStr);
        Category existing = categoryService.findById(categoryId);
        if (existing == null) {
            return false;
        }

        // Ma dinh danh da bi khoa vinh vien ngay khi tao: update chi sua
        // name / description / parent. Khong can (va khong duoc) sua code.
        existing.setCategoryName(name.trim());
        existing.setDescription(req.getParameter("description"));
        existing.setParentId(parseParentId(parentIdStr));
        return categoryService.updateCategory(existing, null);
    }

    private boolean handleDelete(HttpServletRequest req) throws Exception {
        String categoryIdStr = req.getParameter("categoryId");
        if (isNullOrEmpty(categoryIdStr)) {
            return false;
        }
        try {
            int categoryId = Integer.parseInt(categoryIdStr);
            CategoryService.DeleteResult result = categoryService.deleteCategory(categoryId);
            // Store soft delete info in session for different message
            if (result.isWasSoftDelete()) {
                req.getSession().setAttribute("categoryMessage", result.getMessage());
                req.getSession().setAttribute("categorySuccess", result.isSuccess());
                req.getSession().setAttribute("categoryDeactivated", true);
            }
            return result.isSuccess();
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "CategoryServlet: Invalid categoryId for delete: " + categoryIdStr);
            return false;
        }
    }

    private boolean handleDeactivate(HttpServletRequest req) throws Exception {
        String categoryIdStr = req.getParameter("categoryId");
        if (isNullOrEmpty(categoryIdStr)) {
            return false;
        }
        try {
            int categoryId = Integer.parseInt(categoryIdStr);
            int affected = categoryService.deactivateCategory(categoryId);
            if (affected > 1) {
                req.getSession().setAttribute("categoryMessage",
                    "Da ngung hoat dong danh muc va " + (affected - 1) + " danh muc con (cascade).");
                req.getSession().setAttribute("categorySuccess", true);
                req.getSession().setAttribute("categoryDeactivated", true);
            }
            return affected > 0;
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "CategoryServlet: Invalid categoryId for deactivate: " + categoryIdStr);
            return false;
        }
    }

    private boolean handleReactivate(HttpServletRequest req) throws Exception {
        String categoryIdStr = req.getParameter("categoryId");
        if (isNullOrEmpty(categoryIdStr)) {
            return false;
        }
        try {
            int categoryId = Integer.parseInt(categoryIdStr);
            Category existing = categoryService.findById(categoryId);
            if (existing == null) {
                return false;
            }
            // Reactivation would break the cascade invariant if any ancestor
            // is still inactive. Delegate the ancestor check to the service.
            Category blockedBy = categoryService.findInactiveAncestor(categoryId);
            if (blockedBy != null) {
                throw new IllegalArgumentException(
                    "Khong the kich hoat lai: danh muc cha '" + blockedBy.getCategoryName()
                    + "' dang ngung hoat dong. Hay kich hoat danh muc cha truoc.");
            }
            return categoryService.reactivateCategory(categoryId);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "CategoryServlet: Invalid categoryId for reactivate: " + categoryIdStr);
            return false;
        }
    }

    private Integer parseParentId(String parentIdStr) {
        if (isNullOrEmpty(parentIdStr)) return null;
        try {
            return Integer.parseInt(parentIdStr);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
