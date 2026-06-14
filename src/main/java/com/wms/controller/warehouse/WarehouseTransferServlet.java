package com.wms.controller.warehouse;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.controller.BaseController;
import com.wms.dao.TransferDAO;
import com.wms.model.Product;
import com.wms.model.User;
import com.wms.model.Warehouse;
import com.wms.service.warehouse.TransferService;
import com.wms.util.AppConstants;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * WarehouseTransferServlet — Handles Transfer Inventory (Điều chuyển kho) for the Warehouse Staff.
 *
 * Maps to /warehouse/transfer.
 */
public class WarehouseTransferServlet extends BaseController {

    private final TransferService transferService = new TransferService();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            List<TransferDAO.Transfer> transfers = transferService.findAll();
            req.setAttribute("transfers", transfers);

            Map<Integer, List<TransferDAO.TransferItem>> transferItemsMap = new HashMap<>();
            for (TransferDAO.Transfer t : transfers) {
                List<TransferDAO.TransferItem> items = transferService.findItemsByTransferId(t.getTransferId());
                transferItemsMap.put(t.getTransferId(), items);
            }
            req.setAttribute("transferItemsMap", transferItemsMap);

            req.setAttribute("products", transferService.findApprovedProducts());
            req.setAttribute("warehouses", transferService.findAllWarehouses());
        } catch (Exception e) {
            req.setAttribute("transfers", java.util.List.<TransferDAO.Transfer>of());
            req.setAttribute("transferItemsMap", new HashMap<Integer, List<TransferDAO.TransferItem>>());
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

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        try {
            var body = objectMapper.readTree(req.getInputStream());
            String action = body.has("action") ? body.get("action").asText() : "";

            if ("create".equals(action)) {
                int fromWarehouseId = body.get("fromWarehouseId").asInt();
                int toWarehouseId   = body.get("toWarehouseId").asInt();
                String sku  = body.get("sku").asText();
                int qty     = body.get("qty").asInt();
                String note = body.has("note") ? body.get("note").asText() : "";

                User currentUser = (User) req.getSession().getAttribute(AppConstants.SESSION_USER);
                int creatorId = currentUser != null ? currentUser.getUserId() : 1;

                TransferDAO.Transfer created =
                    transferService.createTransfer(fromWarehouseId, toWarehouseId,
                            creatorId, note, sku, BigDecimal.valueOf(qty));

                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("transferId", created.getTransferId());
                result.put("transferCode", created.getTransferCode());
                resp.getWriter().write(objectMapper.writeValueAsString(result));

            } else if ("receive".equals(action)) {
                int transferId = body.get("transferId").asInt();
                transferService.markReceived(transferId);
                resp.getWriter().write("{\"success\":true}");

            } else {
                resp.getWriter().write("{\"success\":false,\"message\":\"Hành động không hợp lệ.\"}");
            }
        } catch (Exception e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + e.getMessage() + "\"}");
        }
    }
}
