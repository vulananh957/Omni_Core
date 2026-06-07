package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import com.wms.dao.ProductDAO;
import com.wms.dao.TransferDAO;
import com.wms.dao.WarehouseDAO;
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

    private final TransferDAO  transferDAO  = new TransferDAO();
    private final ProductDAO  productDAO   = new ProductDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Pull transfer records, products, and warehouses for the UI
        var transfers = transferDAO.findAll();
        var products = productDAO.findApproved();
        var warehouses = warehouseDAO.findAll();

        req.setAttribute("transfers", transfers);
        req.setAttribute("products", products);
        req.setAttribute("warehouses", warehouses);

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Điều Chuyển Kho (Transfer Inventory)");
        req.setAttribute("pageSubtitle", "Điều phối hàng hóa nội bộ hoặc phân phối sang khu hàng hỏng/khiếu nại");
        req.setAttribute("currentPage",  "wh-transfer");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/transfer/warehouse-transfer.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }
}
