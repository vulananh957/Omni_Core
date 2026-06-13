package com.wms.controller;

import com.wms.util.AppConstants;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * BaseController — Abstract base class for ALL WMS Servlets.
 *
 * ┌─────────────────────────────────────────────────────────────────────┐
 * │  REACT → JSP MAPPING                                               │
 * │  React Component  →  Servlet + JSP pair                           │
 * │  useNavigate()    →  response.sendRedirect(...)                    │
 * │  useState()       →  request.setAttribute(...) [per-request]      │
 * │  useContext()     →  session.getAttribute(...) [cross-request]     │
 * │  props            →  request.getAttribute(...) passed to JSP       │
 * └─────────────────────────────────────────────────────────────────────┘
 */
public abstract class BaseController extends HttpServlet {

    // ── Navigation helpers (replaces React Router) ────────────

    /**
     * Forward to a JSP view inside WEB-INF/views/.
     * e.g., forward(req, res, "dashboard/index") →  /WEB-INF/views/dashboard/index.jsp
     */
    protected void forward(HttpServletRequest req, HttpServletResponse res, String viewPath)
            throws ServletException, IOException {
        String fullPath = AppConstants.VIEW_PREFIX + viewPath + AppConstants.VIEW_SUFFIX;
        req.getRequestDispatcher(fullPath).forward(req, res);
    }

    /**
     * Redirect to a servlet URL (POST-Redirect-GET pattern).
     * e.g., redirect(res, "dashboard")
     */
    protected void redirect(HttpServletResponse res, String servletPath) throws IOException {
        res.sendRedirect(res.encodeRedirectURL(
                res.encodeURL(servletPath)));
    }

    // ── Attribute helpers (replaces React state/props) ────────

    protected void setData(HttpServletRequest req, Object data) {
        req.setAttribute(AppConstants.ATTR_DATA, data);
    }

    protected void setList(HttpServletRequest req, Object list) {
        req.setAttribute(AppConstants.ATTR_LIST, list);
    }

    protected void setPageTitle(HttpServletRequest req, String title) {
        req.setAttribute(AppConstants.ATTR_PAGE, title);
    }

    protected void setError(HttpServletRequest req, String message) {
        req.setAttribute(AppConstants.ATTR_ERROR, message);
    }

    protected void setSuccess(HttpServletRequest req, String message) {
        req.setAttribute(AppConstants.ATTR_SUCCESS, message);
    }

    // ── Session-based flash messages (survive POST-Redirect-GET) ──

    /**
     * Store an error flash message in the session so it survives a redirect.
     * Call consumeFlash() in doGet to move it to request scope.
     */
    protected void setFlashError(HttpServletRequest req, String message) {
        HttpSession session = req.getSession(true);
        session.setAttribute(AppConstants.ATTR_ERROR, message);
    }

    /**
     * Store a success flash message in the session so it survives a redirect.
     * Call consumeFlash() in doGet to move it to request scope.
     */
    protected void setFlashSuccess(HttpServletRequest req, String message) {
        HttpSession session = req.getSession(true);
        session.setAttribute(AppConstants.ATTR_SUCCESS, message);
    }

    /**
     * Move any session flash messages into the request scope and remove them.
     * Call this at the start of every doGet that may follow a redirect.
     */
    protected void consumeFlash(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return;
        String err = (String) session.getAttribute(AppConstants.ATTR_ERROR);
        if (err != null) {
            req.setAttribute(AppConstants.ATTR_ERROR, err);
            session.removeAttribute(AppConstants.ATTR_ERROR);
        }
        String ok = (String) session.getAttribute(AppConstants.ATTR_SUCCESS);
        if (ok != null) {
            req.setAttribute(AppConstants.ATTR_SUCCESS, ok);
            session.removeAttribute(AppConstants.ATTR_SUCCESS);
        }
    }

    // ── Session helpers (replaces React Context) ───────────────

    protected Object getSessionAttr(HttpServletRequest req, String key) {
        HttpSession session = req.getSession(false);
        return (session != null) ? session.getAttribute(key) : null;
    }

    protected boolean isLoggedIn(HttpServletRequest req) {
        return getSessionAttr(req, AppConstants.SESSION_USER) != null;
    }

    // ── JSON response helper (for AJAX calls) ─────────────────

    protected void writeJson(HttpServletResponse res, String json) throws IOException {
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        try (PrintWriter out = res.getWriter()) {
            out.print(json);
        }
    }

    protected String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    // ── Input validation helpers ───────────────────────────────

    protected boolean isNullOrEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }

    protected int getPageNumber(HttpServletRequest req) {
        try {
            String p = req.getParameter("page");
            return (p != null) ? Math.max(1, Integer.parseInt(p)) : 1;
        } catch (NumberFormatException e) {
            return 1;
        }
    }
}
