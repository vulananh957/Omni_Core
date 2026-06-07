package com.wms.controller.warehouse;

import com.wms.controller.BaseController;
import com.wms.dao.InboundDAO;
import com.wms.dao.InventoryDAO;
import com.wms.model.InboundOrder;
import com.wms.model.ReceiptNote;
import com.wms.model.User;
import com.wms.util.AppConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * WarehouseInboundServlet — Handles Inbound Receipts (Nhập kho) for the Warehouse Staff.
 *
 * Maps to /warehouse/inbound.
 */
public class WarehouseInboundServlet extends BaseController {

    private final InboundDAO  inboundDAO  = new InboundDAO();
    private final InventoryDAO inventoryDAO = new InventoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<InboundOrder> inboundList = inboundDAO.findAll();
        req.setAttribute("inboundList", inboundList);

        // Page metadata for the layout shell
        req.setAttribute("pageTitle",    "Quản Lý Phiếu Nhập Kho");
        req.setAttribute("pageSubtitle", "Xử lý hàng từ nhà cung cấp — ghi nhận tồn kho và tạo ledger entry khi xác nhận");
        req.setAttribute("currentPage",  "wh-inbound");

        // Set the body content page fragment
        req.setAttribute("contentPage", "/WEB-INF/views/inbound/warehouse-inbound.jsp");

        // Forward to the layout shell
        req.getRequestDispatcher("/WEB-INF/views/layout/warehouse-layout.jsp")
           .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        User currentUser = (User) getSessionAttr(req, AppConstants.SESSION_USER);
        int createdBy = (currentUser != null) ? currentUser.getUserId() : 1;

        if ("create".equals(action) || action == null) {
            // ── Create new inbound PO ──────────────────────────────
            String supplierName = req.getParameter("supplierName");
            String warehouseIdStr = req.getParameter("warehouseId");
            String expectedDateStr = req.getParameter("expectedDate");
            String notes = req.getParameter("notes");

            if (isNullOrEmpty(supplierName) || isNullOrEmpty(warehouseIdStr)) {
                setError(req, "Vui lòng nhập đầy đủ thông tin bắt buộc.");
                doGet(req, resp);
                return;
            }

            try {
                int warehouseId = Integer.parseInt(warehouseIdStr);
                InboundOrder order = new InboundOrder();
                order.setSupplierName(supplierName.trim());
                order.setWarehouseId(warehouseId);
                order.setStatus(InboundOrder.STATUS_PENDING);
                order.setCreatedBy(createdBy);
                order.setNotes(isNullOrEmpty(notes) ? null : notes.trim());

                if (!isNullOrEmpty(expectedDateStr)) {
                    order.setExpectedDate(LocalDate.parse(expectedDateStr));
                }

                int inboundId = inboundDAO.insert(order);
                if (inboundId > 0) {
                    setSuccess(req, "Tạo phiếu nhập " + order.getInboundCode() + " thành công!");
                } else {
                    setError(req, "Không thể tạo phiếu nhập. Vui lòng thử lại.");
                }
            } catch (NumberFormatException e) {
                setError(req, "ID kho không hợp lệ.");
            }

        } else if ("confirm".equals(action)) {
            // ── Confirm inbound PO (PENDING → IN_PROGRESS) ─────────────
            // Note: DB schema uses IN_PROGRESS; mapped from CONFIRMED workflow
            String inboundIdStr = req.getParameter("inboundId");
            if (!isNullOrEmpty(inboundIdStr)) {
                try {
                    int inboundId = Integer.parseInt(inboundIdStr);
                    InboundOrder existing = inboundDAO.findById(inboundId);
                    if (existing != null && InboundOrder.STATUS_PENDING.equals(existing.getStatus())) {
                        boolean updated = inboundDAO.updateStatus(inboundId, InboundOrder.STATUS_IN_PROGRESS);
                        if (updated) {
                            setSuccess(req, "Xác nhận phiếu " + existing.getInboundCode() + " thành công!");
                        } else {
                            setError(req, "Không thể xác nhận phiếu nhập.");
                        }
                    } else {
                        setError(req, "Phiếu nhập không tồn tại hoặc không ở trạng thái chờ xác nhận.");
                    }
                } catch (NumberFormatException e) {
                    setError(req, "ID phiếu nhập không hợp lệ.");
                }
            }

        } else if ("receive".equals(action)) {
            // ── Receive goods (IN_PROGRESS → RECEIVED) ─────────────────
            String inboundIdStr = req.getParameter("inboundId");
            String[] productIds    = req.getParameterValues("productId");
            String[] receivedQtys  = req.getParameterValues("receivedQty");

            if (!isNullOrEmpty(inboundIdStr)) {
                try {
                    int inboundId = Integer.parseInt(inboundIdStr);
                    InboundOrder existing = inboundDAO.findById(inboundId);

                    if (existing == null) {
                        setError(req, "Phiếu nhập không tồn tại.");
                        doGet(req, resp);
                        return;
                    }

                    if (!InboundOrder.STATUS_IN_PROGRESS.equals(existing.getStatus())) {
                        setError(req, "Chỉ phiếu đã xác nhận mới có thể nhập kho.");
                        doGet(req, resp);
                        return;
                    }

                    LocalDateTime now = LocalDateTime.now();
                    boolean allOk = true;

                    if (productIds != null && receivedQtys != null) {
                        for (int i = 0; i < productIds.length; i++) {
                            try {
                                int productId = Integer.parseInt(productIds[i]);
                                BigDecimal receivedQty = new BigDecimal(receivedQtys[i]);
                                if (receivedQty.compareTo(BigDecimal.ZERO) <= 0) continue;

                                ReceiptNote receipt = new ReceiptNote();
                                receipt.setInboundId(inboundId);
                                receipt.setProductId(productId);
                                receipt.setExpectedQty(BigDecimal.ZERO);
                                receipt.setReceivedQty(receivedQty);
                                receipt.setAcceptedQty(receivedQty);
                                receipt.setRejectedQty(BigDecimal.ZERO);
                                receipt.setReceivedAt(now);

                                inboundDAO.insertReceipt(receipt);
                                inventoryDAO.addInventory(productId, existing.getWarehouseId(), receivedQty);
                            } catch (NumberFormatException e) {
                                allOk = false;
                            }
                        }
                    }

                    inboundDAO.updateStatus(inboundId, InboundOrder.STATUS_RECEIVED);

                    if (allOk) {
                        setSuccess(req, "Nhập kho phiếu " + existing.getInboundCode() + " thành công! Tồn kho đã được cập nhật.");
                    } else {
                        setSuccess(req, "Nhập kho phiếu " + existing.getInboundCode() + " hoàn tất (một số dòng có lỗi).");
                    }
                } catch (NumberFormatException e) {
                    setError(req, "Dữ liệu không hợp lệ.");
                }
            }
        }

        // POST-Redirect-GET
        redirect(resp, "/warehouse/inbound");
    }
}
