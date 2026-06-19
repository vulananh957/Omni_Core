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

/**
 * LazadaLabelServlet — streams the Base64-decoded PDF shipping label
 * Lazada returned from /order/package/document/get.
 *
 * <p>URL: {@code GET /lazada/label?orderCode=...}
 */
@WebServlet(name = "LazadaLabelServlet", urlPatterns = {"/lazada/label"})
public class LazadaLabelServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String orderCode = req.getParameter("orderCode");
        if (orderCode == null || orderCode.isBlank()) {
            resp.sendError(400, "orderCode required");
            return;
        }
        Order o = new OrderDAO().findByOrderCode(orderCode.trim());
        if (o == null) {
            resp.sendError(404, "Order not found");
            return;
        }
        byte[] pdf = new LazadaShipmentService().getShippingLabel(o);
        if (pdf == null || pdf.length == 0) {
            resp.sendError(500, "Lazada did not return a label");
            return;
        }
        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition",
                "inline; filename=\"lazada-label-" + orderCode + ".pdf\"");
        resp.setContentLength(pdf.length);
        resp.getOutputStream().write(pdf);
        resp.getOutputStream().flush();
    }
}
