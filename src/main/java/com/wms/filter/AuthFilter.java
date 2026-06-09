package com.wms.filter;

import com.wms.util.AppConstants;
import com.wms.dao.UserDAO;
import com.wms.model.User;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.Optional;

/**
 * AuthFilter — Session-based authentication guard.
 *
 * React equivalent: PrivateRoute / AuthGuard wrapper component.
 *
 * Allows unauthenticated access to public paths (login, assets, etc.)
 * All other requests require a valid session with SESSION_USER set.
 */
public class AuthFilter implements Filter {

    /** Paths accessible WITHOUT login (React: public routes) */
    private static final Set<String> PUBLIC_PATHS = new HashSet<>(Arrays.asList(
            "/login",
            "/logout",
            "/otp",
            "/otp-verify",
            "/password-change-otp",
            "/forgot-password",
            "/reset-password"
    ));

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse res  = (HttpServletResponse) response;

        String contextPath = req.getContextPath();
        String requestURI  = req.getRequestURI();
        String path        = requestURI.substring(contextPath.length());


        // Always allow static assets and public pages
        if (isPublicPath(path)) {
            chain.doFilter(request, response);
            return;
        }

        // Check session
        HttpSession session = req.getSession(false);
        boolean loggedIn    = (session != null)
                && (session.getAttribute(AppConstants.SESSION_USER) != null);

        if (loggedIn) {
            User userInSession = (User) session.getAttribute(AppConstants.SESSION_USER);
            try {
                UserDAO userDAO = new UserDAO();
                Optional<User> uOpt = userDAO.findById(userInSession.getUserId());
                
                if (uOpt.isPresent() && uOpt.get().isActive()) {
                    User currentUser = uOpt.get();
                    // Sync changed role to current session immediately
                    if (!currentUser.getRole().equals(userInSession.getRole())) {
                        session.setAttribute(AppConstants.SESSION_USER, currentUser);
                        session.setAttribute(AppConstants.SESSION_ROLE, currentUser.getRole());
                    }
                    if (currentUser.getWarehouseId() != userInSession.getWarehouseId()) {
                        session.setAttribute(AppConstants.SESSION_USER, currentUser);
                        session.setAttribute(AppConstants.SESSION_WAREHOUSE, currentUser.getWarehouseId());
                    }
                    chain.doFilter(request, response);
                } else {
                    // Account was deactivated or deleted: force logout
                    session.invalidate();
                    res.sendRedirect(contextPath + "/login?status=locked");
                }
            } catch (Exception e) {
                // In case of transient DB issues, fall back to allow session
                chain.doFilter(request, response);
            }
        } else {
            res.sendRedirect(contextPath + "/login");
        }
    }

    private boolean isPublicPath(String path) {
        // Allow static assets
        if (path.startsWith("/assets/")) return true;
        // Allow favicon
        if (path.equals("/favicon.ico")) return true;
        // Allow declared public paths
        return PUBLIC_PATHS.contains(path);
    }

    @Override
    public void destroy() {}
}
