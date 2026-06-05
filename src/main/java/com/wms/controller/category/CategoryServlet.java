package com.wms.controller.category;

import com.wms.controller.BaseController;
import com.wms.dao.CategoryDAO;
import com.wms.model.Category;
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
 */
public class CategoryServlet extends BaseController {

    private static final Logger LOGGER = Logger.getLogger(CategoryServlet.class.getName());
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setAttribute("pageTitle",    "Quản Lý Danh Mục Sản Phẩm");
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
                message = success ? "Tạo danh mục thành công!" : "Tạo danh mục thất bại.";
            } else if ("update".equals(action)) {
                success = handleUpdate(req);
                message = success ? "Cập nhật danh mục thành công!" : "Cập nhật danh mục thất bại.";
            } else if ("delete".equals(action)) {
                success = handleDelete(req);
                message = success ? "Xóa danh mục thành công!" : "Xóa danh mục thất bại.";
            } else {
                message = "Hành động không hợp lệ.";
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "CategoryServlet: Error processing action " + action, e);
            message = "Đã xảy ra lỗi khi xử lý yêu cầu.";
            success = false;
        }

        req.getSession().setAttribute("categoryMessage", message);
        req.getSession().setAttribute("categorySuccess", success);

        resp.sendRedirect(req.getContextPath() + "/business/categories");
    }

    private boolean handleCreate(HttpServletRequest req) {
        String name = req.getParameter("categoryName");
        String parentIdStr = req.getParameter("parentId");

        if (isNullOrEmpty(name)) {
            return false;
        }

        Category category = new Category();
        category.setCategoryName(name.trim());
        category.setDescription(req.getParameter("description"));

        if (!isNullOrEmpty(parentIdStr)) {
            try {
                category.setParentId(Integer.parseInt(parentIdStr));
            } catch (NumberFormatException e) {
                LOGGER.log(Level.WARNING, "CategoryServlet: Invalid parentId: " + parentIdStr);
            }
        }

        return categoryDAO.insert(category);
    }

    private boolean handleUpdate(HttpServletRequest req) {
        String categoryIdStr = req.getParameter("categoryId");
        String name = req.getParameter("categoryName");
        String parentIdStr = req.getParameter("parentId");

        if (isNullOrEmpty(categoryIdStr) || isNullOrEmpty(name)) {
            return false;
        }

        try {
            int categoryId = Integer.parseInt(categoryIdStr);
            Category category = categoryDAO.findById(categoryId);
            if (category == null) {
                return false;
            }

            category.setCategoryName(name.trim());
            category.setDescription(req.getParameter("description"));

            if (!isNullOrEmpty(parentIdStr)) {
                try {
                    int parentId = Integer.parseInt(parentIdStr);
                    if (parentId != categoryId) {
                        category.setParentId(parentId);
                    } else {
                        category.setParentId(null);
                    }
                } catch (NumberFormatException e) {
                    category.setParentId(null);
                }
            } else {
                category.setParentId(null);
            }

            return categoryDAO.update(category);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "CategoryServlet: Invalid categoryId: " + categoryIdStr);
            return false;
        }
    }

    private boolean handleDelete(HttpServletRequest req) {
        String categoryIdStr = req.getParameter("categoryId");

        if (isNullOrEmpty(categoryIdStr)) {
            return false;
        }

        try {
            int categoryId = Integer.parseInt(categoryIdStr);
            return categoryDAO.delete(categoryId);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "CategoryServlet: Invalid categoryId for delete: " + categoryIdStr);
            return false;
        }
    }
}
