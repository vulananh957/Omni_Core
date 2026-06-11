package com.wms.controller.category;

import com.wms.controller.BaseController;
import com.wms.model.Category;
import com.wms.service.product.CategoryService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * CategoryServlet — Handles requests for the Category Management page.
 *
 * Maps to /business/categories.
 * 
 * Business rules:
 * - categoryCode: required on create, 3-4 chars, uppercase, immutable after save
 * - Delete: hard delete if no products, deactivate if has products
 */
public class CategoryServlet extends BaseController {

    private static final Logger LOGGER = Logger.getLogger(CategoryServlet.class.getName());
    private final CategoryService categoryService = new CategoryService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            req.setAttribute("categories", categoryService.findAll());
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "CategoryServlet: Failed to load categories", e);
        }

        req.setAttribute("pageTitle",    "Quan Ly Danh Muc San Pham");
        req.setAttribute("pageSubtitle", "Xay dung so do cay phan cap danh muc san pham va anh xa danh muc da san");
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
        String code = req.getParameter("categoryCode");
        String parentIdStr = req.getParameter("parentId");

        if (isNullOrEmpty(categoryIdStr) || isNullOrEmpty(name)) {
            return false;
        }

        int categoryId = Integer.parseInt(categoryIdStr);
        Category category = categoryService.findById(categoryId);
        if (category == null) {
            return false;
        }

        // Validate category code if provided
        if (!isNullOrEmpty(code)) {
            CategoryService.ValidationResult codeValidation = categoryService.validateCategoryCode(code);
            if (!codeValidation.isSuccess()) {
                throw new IllegalArgumentException(codeValidation.getMessage());
            }
        }

        // Get existing category to check immutability
        Category existing = categoryService.findById(categoryId);
        if (existing == null) {
            return false;
        }

        // If code is immutable, don't allow update
        if (existing.isImmutable()) {
            // Category code is locked, update without code
            category.setCategoryName(name.trim());
            category.setDescription(req.getParameter("description"));
            category.setParentId(parseParentId(parentIdStr));
            return categoryService.updateCategory(category, null);
        } else {
            // Code not locked yet, allow update with new code
            category.setCategoryName(name.trim());
            category.setDescription(req.getParameter("description"));
            category.setParentId(parseParentId(parentIdStr));
            category.setImmutable(true); // Lock after first update
            return categoryService.updateCategory(category, code);
        }
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
            return categoryService.deactivateCategory(categoryId);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "CategoryServlet: Invalid categoryId for deactivate: " + categoryIdStr);
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
