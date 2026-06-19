package com.wms.controller.lazada;

import com.wms.dao.OrderDAO;
import com.wms.model.Order;
import com.wms.service.lazada.LazadaShipmentService;
import com.wms.service.lazada.LazadaShipmentService.ShipmentResult;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * LazadaRtsServlet — small endpoint that lets the warehouse UI trigger
 * {@code /order/package/rts} for a Lazada order. Lazada end-to-end (UC-B2C06).
 *
 * <p>URL: {@code POST /lazada/rts?orderCode=...}
 * <p>Response: JSON { success, trackingNo, packageId, errorMessage }
 */
@WebServlet(name = "LazadaRtsServlet", urlPatterns = {"/lazada/rts"})
public class LazadaRtsServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String orderCode = req.getParameter("orderCode");
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = resp.getWriter()) {
            if (orderCode == null || orderCode.isBlank()) {
                resp.setStatus(400);
                out.print("{\"success\":false,\"errorMessage\":\"orderCode required\"}");
                return;
            }
            Order o = new OrderDAO().findByOrderCode(orderCode.trim());
            if (o == null) {
                resp.setStatus(404);
                out.print("{\"success\":false,\"errorMessage\":\"Order not found\"}");
                return;
            }
            ShipmentResult r = new LazadaShipmentService().readyToShip(o);
            out.print("{\"success\":" + r.success
                    + ",\"trackingNo\":\"" + esc(r.trackingNo) + "\""
                    + ",\"packageId\":\"" + esc(r.packageId) + "\""
                    + ",\"errorMessage\":\"" + esc(r.errorMessage) + "\"}");
        }
    }

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", " ").replace("\r", " ");
    }
}
