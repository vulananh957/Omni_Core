package com.wms.controller.warehouse;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.controller.BaseController;
import com.wms.model.Warehouse;
import com.wms.service.warehouse.WarehouseService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * WarehouseDocumentsServlet — Handles stock ledger / documents list (Sổ kho) for the Warehouse Staff.
 *
 * Maps to /warehouse/documents.
 */
public class WarehouseDocumentsServlet extends BaseController {

    private final WarehouseService warehouseService = new WarehouseService();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            List<Warehouse> warehouses = warehouseService.findAllActive();
            req.setAttribute("warehouses", warehouses);
            req.setAttribute("warehousesJson", objectMapper.writeValueAsString(warehouses));
        } catch (Exception e) {
            req.setAttribute("warehouses", List.<Warehouse>of());
            req.setAttribute("warehousesJson", "[]");
        }

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
