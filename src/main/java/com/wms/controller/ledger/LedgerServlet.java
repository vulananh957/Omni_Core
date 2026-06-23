package com.wms.controller.ledger;

import com.wms.controller.BaseController;
import com.wms.dao.LedgerDAO;
import com.wms.model.User;
import com.wms.service.ledger.LedgerService;
import com.wms.util.AppConstants;
import com.wms.util.JsonUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * LedgerServlet — Handles requests for the Stock Ledger page.
 * 
 * Maps to /business/ledger.
 */
public class LedgerServlet extends BaseController {

    private final LedgerService ledgerService = new LedgerService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        consumeFlash(req);
        // AJAX: return the line items of one document as JSON (for the detail modal)
        if ("items".equals(req.getParameter("ajax"))) {
            resp.setContentType("application/json;charset=UTF-8");
            String docId = req.getParameter("docId");
            String docType = req.getParameter("docType");
            try {
                List<java.util.Map<String, Object>> items = ledgerService.findDocumentItems(docId, docType);
                resp.getWriter().write(JsonUtil.toJson(items));
            } catch (Exception e) {
                resp.getWriter().write("[]");
            }
            return;
        }

        try {
            List<LedgerDAO.LedgerDocument> docs = ledgerService.findAllDocuments();
            req.setAttribute("documents", docs);
            setJsonAttr(req, "documentsJson", docs);
        } catch (Exception e) {
            req.setAttribute("documents", List.of());
            req.setAttribute("documentsJson", "[]");
        }

        try {
            List<LedgerDAO.GlobalLedgerEntry> entries = ledgerService.findGlobalLedgerEntries();
            req.setAttribute("ledgerEntries", entries);
        } catch (Exception e) {
            req.setAttribute("ledgerEntries", List.of());
        }

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Sổ Kho");
        req.setAttribute("pageSubtitle", "Phê duyệt phiếu kho (Maker-Checker) và xem toàn bộ chứng từ");
        req.setAttribute("currentPage",  "ledger");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/ledger/ledger.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/dashboard-layout.jsp")
           .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        User currentUser = (User) req.getSession().getAttribute(AppConstants.SESSION_USER);
        int userId = currentUser != null ? currentUser.getUserId() : 1;

        if (currentUser == null || !"MANAGER".equals(currentUser.getRole())) {
            setFlashError(req, "Chỉ cấp quản lý (Manager) mới có quyền thực hiện thao tác duyệt/từ chối phiếu.");
            resp.sendRedirect(req.getContextPath() + "/business/ledger");
            return;
        }

        try {
            if ("approve".equals(action)) {
                String docType = req.getParameter("docType");
                String docId = req.getParameter("docId");
                boolean ok = ledgerService.approveDocument(docType, docId, userId);
                if (ok) {
                    setFlashSuccess(req, "Phê duyệt phiếu " + docId + " thành công!");
                } else {
                    setFlashError(req, "Phê duyệt phiếu " + docId + " thất bại.");
                }
            } else if ("reject".equals(action)) {
                String docType = req.getParameter("docType");
                String docId = req.getParameter("docId");
                String reason = req.getParameter("rejectReason");
                boolean ok = ledgerService.rejectDocument(docType, docId, reason, userId);
                if (ok) {
                    setFlashSuccess(req, "Đã từ chối phiếu " + docId + ".");
                } else {
                    setFlashError(req, "Từ chối phiếu " + docId + " thất bại.");
                }
            }
        } catch (Exception e) {
            setFlashError(req, "Lỗi xử lý: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/business/ledger");
    }
}
