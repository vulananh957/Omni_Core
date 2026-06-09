package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import com.wms.dao.TransferDAO;
import com.wms.model.Product;
import com.wms.model.Warehouse;
import com.wms.service.warehouse.TransferService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * WarehouseTransferServlet — Handles Transfer Inventory (Điều chuyển kho) for the Warehouse Staff.
 *
 * Maps to /warehouse/transfer.
 */
public class WarehouseTransferServlet extends BaseController {

    private final TransferService transferService = new TransferService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            req.setAttribute("transfers", transferService.findAll());
            req.setAttribute("products", transferService.findApprovedProducts());
            req.setAttribute("warehouses", transferService.findAllWarehouses());
        } catch (Exception e) {
            req.setAttribute("transfers", java.util.List.<TransferDAO.Transfer>of());
            req.setAttribute("products", java.util.List.<Product>of());
            req.setAttribute("warehouses", java.util.List.<Warehouse>of());
        }

        req.setAttribute("pageTitle",    "Điều Chuyển Kho (Transfer Inventory)");
        req.setAttribute("pageSubtitle", "Điều phối hàng hóa nội bộ hoặc phân phối sang khu hàng hỏng/khiếu nại");
        req.setAttribute("currentPage",  "wh-transfer");

        req.setAttribute("contentPage", "/WEB-INF/views/transfer/warehouse-transfer.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }
}
