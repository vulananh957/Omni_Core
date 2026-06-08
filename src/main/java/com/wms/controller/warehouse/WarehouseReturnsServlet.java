package com.wms.controller.warehouse;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.controller.BaseController;
import com.wms.dao.ProductDAO;
import com.wms.dao.ReturnDAO;
import com.wms.model.ReturnItem;
import com.wms.model.ReturnOrder;
import com.wms.model.User;
import com.wms.util.AppConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * WarehouseReturnsServlet — Handles Returns, RMA & QC (Hàng hoàn & QC) for the Warehouse Staff.
 *
 * Maps to /warehouse/returns.
 */
public class WarehouseReturnsServlet extends BaseController {

    private static final Logger LOGGER = Logger.getLogger(WarehouseReturnsServlet.class.getName());
    private static final String CONTEXT_PATH = "/warehouse/returns";
    
    private final ProductDAO productDAO = new ProductDAO();
    private final ReturnDAO returnDAO = new ReturnDAO();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Pull flash error/success if any
        consumeFlash(req);

        // Pull approved products for the SKU select dropdown
        var products = productDAO.findApproved();
        req.setAttribute("products", products);

        // Fetch actual return orders from the database
        List<ReturnOrder> dbReturns = returnDAO.findAll();
        req.setAttribute("returns", dbReturns);

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Trung Tâm Tiếp Nhận Hàng Hoàn QC");
        req.setAttribute("pageSubtitle", "Phân loại hàng khách trả — nhập lại kho bán hoặc chuyển kho phế phẩm");
        req.setAttribute("currentPage",  "wh-returns");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/returns/warehouse-returns.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        User user = (User) getSessionAttr(req, AppConstants.SESSION_USER);
        int userId = (user != null) ? user.getUserId() : 1;
        int warehouseId = (user != null && user.getWarehouseId() > 0) ? user.getWarehouseId() : 1;

        if (isNullOrEmpty(action)) {
            setFlashError(req, "Hành động không hợp lệ.");
            redirect(resp, CONTEXT_PATH);
            return;
        }

        try {
            switch (action) {
                case "create": {
                    String soRef = req.getParameter("soRef");
                    String customer = req.getParameter("customer");
                    String phone = req.getParameter("phone");
                    String itemsJson = req.getParameter("itemsJson");

                    if (isNullOrEmpty(soRef) || isNullOrEmpty(customer) || isNullOrEmpty(phone) || isNullOrEmpty(itemsJson)) {
                        setFlashError(req, "Thiếu thông tin bắt đầu tạo phiếu hàng hoàn.");
                        break;
                    }

                    List<ReturnItem> items = objectMapper.readValue(itemsJson, new TypeReference<List<ReturnItem>>() {});
                    if (items == null || items.isEmpty()) {
                        setFlashError(req, "Danh sách sản phẩm hoàn trả trống.");
                        break;
                    }

                    ReturnOrder order = new ReturnOrder();
                    order.setOrderCode(soRef.trim());
                    order.setCustomerName(customer.trim());
                    order.setCustomerPhone(phone.trim());
                    order.setReason("Yêu cầu trả hàng hoàn tiền");
                    order.setWarehouseId(warehouseId);
                    order.setItems(items);

                    boolean success = returnDAO.insert(order);
                    if (success) {
                        setFlashSuccess(req, "Tạo phiếu hàng hoàn cho đơn hàng " + soRef + " thành công!");
                    } else {
                        setFlashError(req, "Không thể tạo phiếu hàng hoàn. Vui lòng kiểm tra mã SO gốc.");
                    }
                    break;
                }
                
                case "qc": {
                    String returnIdStr = req.getParameter("returnId");
                    String itemsJson = req.getParameter("itemsJson");

                    if (isNullOrEmpty(returnIdStr) || isNullOrEmpty(itemsJson)) {
                        setFlashError(req, "Thiếu thông tin kết quả kiểm QC.");
                        break;
                    }

                    int returnId = Integer.parseInt(returnIdStr.trim());
                    List<ReturnItem> items = objectMapper.readValue(itemsJson, new TypeReference<List<ReturnItem>>() {});

                    boolean success = returnDAO.saveQC(returnId, items, userId);
                    if (success) {
                        setFlashSuccess(req, "Cập nhật kết quả QC cho phiếu #" + returnId + " thành công.");
                    } else {
                        setFlashError(req, "Lưu kết quả QC thất bại.");
                    }
                    break;
                }

                case "apply": {
                    String returnIdStr = req.getParameter("returnId");
                    if (isNullOrEmpty(returnIdStr)) {
                        setFlashError(req, "Thiếu ID phiếu hàng hoàn.");
                        break;
                    }

                    int returnId = Integer.parseInt(returnIdStr.trim());
                    boolean success = returnDAO.applyRestock(returnId, userId);
                    if (success) {
                        setFlashSuccess(req, "Áp dụng kết quả hàng hoàn, cập nhật tồn kho thành công!");
                    } else {
                        setFlashError(req, "Áp dụng kết quả hàng hoàn thất bại.");
                    }
                    break;
                }

                default:
                    setFlashError(req, "Hành động không xác định: " + action);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "WarehouseReturnsServlet: Error processing POST", e);
            setFlashError(req, "Lỗi hệ thống: " + e.getMessage());
        }

        redirect(resp, CONTEXT_PATH);
    }
}
