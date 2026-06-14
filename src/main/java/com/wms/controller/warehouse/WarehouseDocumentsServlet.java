package com.wms.controller.warehouse;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.controller.BaseController;
import com.wms.dao.LedgerDAO;
import com.wms.model.User;
import com.wms.model.Warehouse;
import com.wms.service.ledger.LedgerService;
import com.wms.service.warehouse.WarehouseService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

/**
 * WarehouseDocumentsServlet — Handles stock ledger / documents list (Sổ kho) for the Warehouse Staff.
 *
 * Maps to /warehouse/documents.
 */
public class WarehouseDocumentsServlet extends BaseController {

    private final WarehouseService warehouseService = new WarehouseService();
    private final LedgerService ledgerService = new LedgerService();
    private final ObjectMapper objectMapper = com.wms.util.JsonUtil.getMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("loggedInUser") : null;
        boolean isManager = currentUser != null && "MANAGER".equalsIgnoreCase(currentUser.getRole());
        int userWarehouseId = currentUser != null ? currentUser.getWarehouseId() : 0;

        try {
            List<Warehouse> warehouses = warehouseService.findAllActive();
            req.setAttribute("warehouses", warehouses);
            req.setAttribute("warehousesJson", objectMapper.writeValueAsString(warehouses));
        } catch (Exception e) {
            req.setAttribute("warehouses", List.<Warehouse>of());
            req.setAttribute("warehousesJson", "[]");
        }

        try {
            List<LedgerDAO.LedgerDocument> allDocs = ledgerService.findAllDocuments();
            List<LedgerDAO.LedgerDocument> docs;
            if (isManager) {
                docs = allDocs;
            } else {
                docs = allDocs.stream()
                    .filter(d -> d.warehouseId == userWarehouseId)
                    .collect(Collectors.toList());
            }
            req.setAttribute("documents", docs);
            req.setAttribute("documentsJson", objectMapper.writeValueAsString(docs));
        } catch (Exception e) {
            req.setAttribute("documents", List.<LedgerDAO.LedgerDocument>of());
            req.setAttribute("documentsJson", "[]");
        }

        req.setAttribute("currentRole", isManager ? "MANAGER" : "STAFF");
        req.setAttribute("userWarehouseId", userWarehouseId);

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Sổ Kho");
        req.setAttribute("pageSubtitle", "Quản lý phiếu kho — lưu nhập, trình duyệt và xác nhận hoàn hàng");
        req.setAttribute("currentPage",  "wh-documents");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/warehouse/warehouse-documents.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }
}
