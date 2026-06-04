package com.wms.filter;

import jakarta.servlet.*;
import java.io.IOException;

/**
 * EncodingFilter — Forces UTF-8 on every request/response.
 * Handles Vietnamese characters (ă, ơ, ê, etc.)
 */
public class EncodingFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
