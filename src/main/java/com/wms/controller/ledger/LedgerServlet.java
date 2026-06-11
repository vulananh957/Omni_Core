package com.wms.controller.ledger;

import com.wms.controller.BaseController;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * LedgerServlet — Handles requests for the Stock Ledger page.
 * 
 * Maps to /business/ledger.
 */
public class LedgerServlet extends BaseController {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

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
}
