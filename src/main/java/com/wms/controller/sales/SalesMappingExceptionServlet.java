package com.wms.controller.sales;

import com.wms.controller.BaseController;
import com.wms.dao.SkuMappingExceptionDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * SalesMappingExceptionServlet — Trang quản lý SKU từ sàn chưa có ánh xạ.
 * URL: /sales/mapping-exceptions (mapping trong web.xml)
 */
public class SalesMappingExceptionServlet extends BaseController {

    private static final Logger LOGGER = Logger.getLogger(SalesMappingExceptionServlet.class.getName());
    private static final long serialVersionUID = 1L;

    private final SkuMappingExceptionDAO exceptionDAO = new SkuMappingExceptionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        List<Map<String, Object>> exceptions = exceptionDAO.findUnresolved();
        req.setAttribute("exceptions", exceptions);
        req.setAttribute("unresolvedCount", exceptions.size());

        req.setAttribute("pageTitle",    "SKU Chưa Ánh Xạ");
        req.setAttribute("pageSubtitle", "Danh sách SKU từ sàn chưa tìm thấy ánh xạ với Master SKU nội bộ");
        req.setAttribute("currentPage",  "sales-mapping-exceptions");
        req.setAttribute("contentPage",  "/WEB-INF/views/sales/mapping-exceptions.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/sales-layout.jsp")
           .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if ("resolve".equals(action)) {
            try {
                int exceptionId = Integer.parseInt(req.getParameter("exceptionId"));
                boolean ok = exceptionDAO.markResolved(exceptionId);
                if (ok) {
                    LOGGER.log(Level.INFO, "Marked mapping exception {0} as resolved", exceptionId);
                }
            } catch (NumberFormatException e) {
                LOGGER.warning("Invalid exceptionId parameter");
            }
        }

        resp.sendRedirect(req.getContextPath() + "/sales/mapping-exceptions");
    }
}
