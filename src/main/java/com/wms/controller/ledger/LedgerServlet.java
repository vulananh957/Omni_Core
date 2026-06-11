package com.wms.controller.ledger;

import com.wms.controller.BaseController;
import com.wms.dao.LedgerDAO;
import com.wms.model.User;
import com.wms.service.ledger.LedgerService;
import com.wms.util.AppConstants;

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

        try {
            List<LedgerDAO.LedgerDocument> docs = ledgerService.findAllDocuments();
            req.setAttribute("documents", docs);
        } catch (Exception e) {
            req.setAttribute("documents", List.of());
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

        try {
            if ("approve".equals(action)) {
                String docType = req.getParameter("docType");
                String docId = req.getParameter("docId");
                ledgerService.approveDocument(docType, docId, userId);
            } else if ("reject".equals(action)) {
                String docType = req.getParameter("docType");
                String docId = req.getParameter("docId");
                String reason = req.getParameter("rejectReason");
                ledgerService.rejectDocument(docType, docId, reason, userId);
            }
        } catch (Exception e) {
            req.setAttribute("error", "Lỗi xử lý: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/business/ledger");
    }
}
