package com.wms.controller.sales;

import com.wms.controller.BaseController;
import com.wms.model.Order;
import com.wms.model.Warehouse;
import com.wms.service.sales.OrderService;
import com.wms.service.warehouse.WarehouseService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * SalesOrderProcessingServlet — Handles the "Xử lý đơn hàng" (Order Processing) page for Sales Staff.
 * Maps to /sales/order-processing.
 */
public class SalesOrderProcessingServlet extends BaseController {

    private final OrderService orderService = new OrderService();
    private final WarehouseService warehouseService = new WarehouseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            List<Order> list = orderService.findAllOrders();
            List<Warehouse> warehouses = warehouseService.findAllActive();
            req.setAttribute("orderList", list);
            req.setAttribute("warehouses", warehouses);
            setJsonAttr(req, "warehousesJson", warehouses);
        } catch (Exception e) {
            req.setAttribute("orderList", List.of());
            req.setAttribute("warehouses", List.<Warehouse>of());
            req.setAttribute("warehousesJson", "[]");
        }

        req.setAttribute("pageTitle",    "Xử Lý Đơn Hàng");
        req.setAttribute("pageSubtitle", "Sales Staff duyệt đơn, in tem vận chuyển hàng loạt, xác nhận RTS và xử lý khiếu nại RMA");
        req.setAttribute("currentPage",  "sales-processing");

        req.setAttribute("contentPage", "/WEB-INF/views/sales/order-processing.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/sales-layout.jsp")
           .forward(req, resp);
    }
}
