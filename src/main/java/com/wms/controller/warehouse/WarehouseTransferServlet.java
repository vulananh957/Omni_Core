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

        // 1. Get status filter, page, and search query parameters
        String status = req.getParameter("status");
        if (status == null || status.trim().isEmpty() || "all".equalsIgnoreCase(status)) {
            status = "all";
        }

        String pageStr = req.getParameter("page");
        int currentPageNum = 1;
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                currentPageNum = Integer.parseInt(pageStr);
                if (currentPageNum < 1) currentPageNum = 1;
            } catch (NumberFormatException e) {
                currentPageNum = 1;
            }
        }

        String search = req.getParameter("search");
        if (search == null) {
            search = "";
        }

        int limit = 5; // page size: 5 transfers per page for demo pagination
        int offset = (currentPageNum - 1) * limit;

        // 2. Fetch data from DAO
        var transfers = transferDAO.findTransfers(status, search, offset, limit);
        int totalTransfers = transferDAO.countTransfers(status, search);
        var statusCounts = transferDAO.getStatusCounts();

        int totalPages = (int) Math.ceil((double) totalTransfers / limit);
        if (totalPages < 1) totalPages = 1;

        int startRecord = totalTransfers == 0 ? 0 : offset + 1;
        int endRecord = Math.min(currentPageNum * limit, totalTransfers);

        var products = productDAO.findApproved();
        var warehouses = warehouseDAO.findAll();

        // 3. Set attributes for JSP
        req.setAttribute("transfers", transfers);
        req.setAttribute("products", products);
        req.setAttribute("warehouses", warehouses);
        req.setAttribute("currentPageNum", currentPageNum);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalTransfers", totalTransfers);
        req.setAttribute("startRecord", startRecord);
        req.setAttribute("endRecord", endRecord);
        req.setAttribute("currentStatus", status);
        req.setAttribute("statusCounts", statusCounts);
        req.setAttribute("search", search);

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
