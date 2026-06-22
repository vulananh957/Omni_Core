package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import com.wms.model.User;
import com.wms.model.Warehouse;
import com.wms.service.warehouse.WarehouseService;
import com.wms.util.AppConstants;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * WarehouseInfoServlet — Warehouse information for the Warehouse Staff.
 *
 * Maps to /warehouse/information. Shows the staff's own warehouse (read-only master data)
 * and provides CRUD over its storage zones. Warehouse master data (code/name/address) stays
 * with the Manager screen (/business/warehouses).
 */
public class WarehouseInfoServlet extends BaseController {

    private static final String CONTEXT_PATH = "/warehouse/information";
    private final WarehouseService warehouseService = new WarehouseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        consumeFlash(req);

        int warehouseId = currentWarehouseId(req);
        try {
            Warehouse warehouse = warehouseService.findById(warehouseId);
            req.setAttribute("warehouse", warehouse);

            // Dashboard KPIs
            req.setAttribute("dashboardMetrics", warehouseService.getDashboardMetrics(warehouseId));
        } catch (Exception e) {
            req.setAttribute("warehouse", null);
            req.setAttribute("dashboardMetrics",
                new com.wms.model.DashboardMetrics(0, 0, 0));
        }

        req.setAttribute("pageTitle",    "Thông Tin Kho");
        req.setAttribute("pageSubtitle", "Thông tin kho bạn phụ trách và quản lý các phân khu lưu trữ");
        req.setAttribute("currentPage",  "wh-information");
        req.setAttribute("contentPage",  "/WEB-INF/views/warehouse/warehouse-information.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        int warehouseId = currentWarehouseId(req);
        String action = req.getParameter("action");

        WarehouseService.SaveResult result;
        try {
            if ("createZone".equals(action)) {
                result = warehouseService.createZone(warehouseId,
                        null, req.getParameter("zoneName"),
                        req.getParameter("zoneType"), req.getParameter("description"));
            } else if ("updateZone".equals(action)) {
                int zoneId = Integer.parseInt(req.getParameter("zoneId").trim());
                result = warehouseService.updateZone(zoneId, warehouseId,
                        req.getParameter("zoneName"), req.getParameter("zoneType"),
                        req.getParameter("description"));
            } else if ("deleteZone".equals(action)) {
                int zoneId = Integer.parseInt(req.getParameter("zoneId").trim());
                result = warehouseService.deleteZone(zoneId, warehouseId);
            } else {
                result = WarehouseService.SaveResult.failure("Hành động không hợp lệ.");
            }
        } catch (Exception e) {
            result = WarehouseService.SaveResult.failure("Dữ liệu không hợp lệ: " + e.getMessage());
        }

        if (result.isSuccess()) {
            setFlashSuccess(req, "Cập nhật phân khu thành công.");
        } else {
            setFlashError(req, result.getMessage());
        }
        redirect(resp, req.getContextPath() + CONTEXT_PATH);
    }

    private int currentWarehouseId(HttpServletRequest req) {
        Object u = req.getSession().getAttribute(AppConstants.SESSION_USER);
        if (u instanceof User && ((User) u).getWarehouseId() > 0) {
            return ((User) u).getWarehouseId();
        }
        return 1;
    }
}
