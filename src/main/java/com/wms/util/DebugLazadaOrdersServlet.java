package com.wms.util;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.dao.LazadaOrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

public class DebugLazadaOrdersServlet extends HttpServlet {

    private final LazadaOrderDAO dao = new LazadaOrderDAO();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        try {
            List<Map<String, Object>> data = dao.findAllWithItemsAndStock();
            String json = mapper.writeValueAsString(data);
            resp.getWriter().write(json);
        } catch (Exception e) {
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
            e.printStackTrace();
        }
    }
}
