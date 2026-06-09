package com.wms.controller.sales;

import com.wms.controller.BaseController;
import com.wms.model.Order;
import com.wms.service.sales.OrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * OrderActionServlet — Handles POST requests for order lifecycle status
 * modifications.
 * Maps to /sales/order-action.
 */
public class OrderActionServlet extends BaseController {
    private static final Logger LOGGER = Logger.getLogger(OrderActionServlet.class.getName());

    private final OrderService orderService = new OrderService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String action = req.getParameter("action");
        String orderCode = req.getParameter("orderCode");
        if (action == null || orderCode == null) {
            out.write("{\"success\":false,\"message\":\"Missing action or orderCode\"}");
            return;
        }

        OrderService.ActionResult result = orderService.handleAction(
            action, orderCode,
            req.getParameter("warehouseName"),
            req.getParameter("note"),
            req.getParameter("trackingNo"),
            req.getParameter("video"),
            req.getParameter("rmaReason"),
            req.getParameter("rmaPhysicalStatus"),
            req.getParameter("rmaPlatformStatus"),
            req.getParameter("platformStatus"),
            req.getParameter("disputeNote")
        );

        if (result.isSuccess()) {
            out.write("{\"success\":true}");
        } else {
            out.write("{\"success\":false,\"message\":\"" + result.getMessage() + "\"}");
        }
    }
}
