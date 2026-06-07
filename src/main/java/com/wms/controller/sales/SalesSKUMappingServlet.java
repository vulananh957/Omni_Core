package com.wms.controller.sales;

import com.wms.controller.BaseController;
import com.wms.dao.ChannelDAO;
import com.wms.dao.ChannelProductDAO;
import com.wms.dao.SkuMappingDAO;
import com.wms.model.Channel;
import com.wms.model.SkuMapping;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * SalesSKUMappingServlet — Handles the "Ánh xạ SKU" (SKU Mapping Center) page for Sales Staff.
 *
 * Maps to /sales/sku-mapping.
 * Mirrors the React SKUMapping component.
 */
public class SalesSKUMappingServlet extends BaseController {

    private final SkuMappingDAO skuMappingDAO = new SkuMappingDAO();
    private final ChannelProductDAO channelProductDAO = new ChannelProductDAO();
    private final ChannelDAO channelDAO = new ChannelDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<SkuMapping> skuMappings = skuMappingDAO.findAll();
        req.setAttribute("skuMappings", skuMappings);

        List<Channel> channels = channelDAO.findAll();
        req.setAttribute("channels", channels);

        req.setAttribute("pageTitle",    "Trung Tâm Ánh Xạ SKU Đa Sàn");
        req.setAttribute("pageSubtitle", "Kết nối Master SKU nội bộ kho hàng với Channel SKU trên các sàn TMĐT");
        req.setAttribute("currentPage",  "sales-sku-mapping");

        req.setAttribute("contentPage", "/WEB-INF/views/sales/sku-mapping.jsp");

        req.getRequestDispatcher("/WEB-INF/views/layout/sales-layout.jsp")
           .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        boolean success = false;
        String message = "";

        try {
            if ("create".equals(action)) {
                SkuMapping mapping = new SkuMapping();
                mapping.setSkuId(Integer.parseInt(req.getParameter("productId")));
                mapping.setChannelId(Integer.parseInt(req.getParameter("channelId")));
                mapping.setExternalSku(req.getParameter("channelSku"));
                mapping.setSellerSku(req.getParameter("sellerSku"));
                mapping.setSyncStatus("PENDING");
                mapping.setLastSyncAt(LocalDateTime.now());

                success = skuMappingDAO.insert(mapping);
                message = success ? "Tạo ánh xạ SKU thành công!" : "Tạo ánh xạ SKU thất bại.";

            } else if ("update".equals(action)) {
                SkuMapping mapping = new SkuMapping();
                mapping.setMappingId(Integer.parseInt(req.getParameter("mappingId")));
                mapping.setSkuId(Integer.parseInt(req.getParameter("productId")));
                mapping.setChannelId(Integer.parseInt(req.getParameter("channelId")));
                mapping.setExternalSku(req.getParameter("channelSku"));
                mapping.setSellerSku(req.getParameter("sellerSku"));
                mapping.setSyncStatus(req.getParameter("syncStatus"));
                mapping.setLastSyncAt(LocalDateTime.now());

                success = skuMappingDAO.update(mapping);
                message = success ? "Cập nhật ánh xạ SKU thành công!" : "Cập nhật ánh xạ SKU thất bại.";

            } else if ("delete".equals(action)) {
                int mappingId = Integer.parseInt(req.getParameter("mappingId"));
                success = skuMappingDAO.delete(mappingId);
                message = success ? "Xóa ánh xạ SKU thành công!" : "Xóa ánh xạ SKU thất bại.";

            } else if ("sync".equals(action)) {
                int channelProductId = Integer.parseInt(req.getParameter("channelProductId"));
                String priceStr = req.getParameter("price");
                String stockStr = req.getParameter("stock");

                if (priceStr != null && !priceStr.isEmpty()) {
                    BigDecimal newPrice = new BigDecimal(priceStr);
                    success = channelProductDAO.syncPrice(channelProductId, newPrice);
                }
                if (stockStr != null && !stockStr.isEmpty()) {
                    BigDecimal newStock = new BigDecimal(stockStr);
                    success = channelProductDAO.syncStock(channelProductId, newStock);
                }

                channelProductDAO.updateLastSynced(channelProductId);
                message = success ? "Đồng bộ thông tin sản phẩm thành công!" : "Đồng bộ thông tin sản phẩm thất bại.";

            } else if ("syncAll".equals(action)) {
                List<SkuMapping> allMappings = skuMappingDAO.findAll();
                int synced = 0;
                for (SkuMapping m : allMappings) {
                    if ("PENDING".equals(m.getSyncStatus()) || "ERROR".equals(m.getSyncStatus())) {
                        skuMappingDAO.updateSyncStatus(m.getMappingId(), "SYNCED");
                        synced++;
                    }
                }
                success = true;
                message = "Đã đồng bộ " + synced + " ánh xạ SKU.";
            }
        } catch (NumberFormatException e) {
            message = "Dữ liệu không hợp lệ: " + e.getMessage();
        } catch (Exception e) {
            message = "Lỗi xử lý: " + e.getMessage();
        }

        req.getSession().setAttribute("toastMessage", message);
        req.getSession().setAttribute("toastSuccess", success);

        resp.sendRedirect(req.getContextPath() + "/sales/sku-mapping");
    }
}
