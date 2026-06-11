package com.wms.controller.warehouse;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.service.product.SkuGeneratorService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

/**
 * GenerateSKUServlet — API endpoint for auto-generating next SKU.
 * 
 * GET /warehouse/sku/generate?categoryId={id}
 * Returns JSON: { "sku": "EYE-20250611-001" } or { "error": "..." }
 */
public class GenerateSKUServlet extends jakarta.servlet.http.HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(GenerateSKUServlet.class.getName());
    private static final ObjectMapper mapper = new ObjectMapper();

    private final SkuGeneratorService skuService = new SkuGeneratorService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Cache-Control", "no-store");

        String catIdStr = req.getParameter("categoryId");
        Map<String, Object> result = new HashMap<>();

        if (catIdStr == null || catIdStr.isEmpty()) {
            result.put("error", "Thieu tham so categoryId.");
            mapper.writeValue(resp.getWriter(), result);
            return;
        }

        try {
            int categoryId = Integer.parseInt(catIdStr);
            String sku = skuService.generateNextSku(categoryId);
            result.put("sku", sku);
        } catch (NumberFormatException e) {
            result.put("error", "categoryId khong hop le.");
        } catch (IllegalArgumentException e) {
            result.put("error", e.getMessage());
        } catch (IllegalStateException e) {
            result.put("error", e.getMessage());
        } catch (Exception e) {
            LOGGER.severe("Error generating SKU: " + e.getMessage());
            result.put("error", "Loi he thong khi tao SKU.");
        }

        mapper.writeValue(resp.getWriter(), result);
    }
}
