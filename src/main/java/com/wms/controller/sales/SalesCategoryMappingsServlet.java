package com.wms.controller.sales;

import com.wms.controller.BaseController;
import com.wms.dao.CategoryMappingDAO;
import com.wms.dao.LazadaCategoryDAO;
import com.wms.model.CategoryMapping;
import com.wms.model.LazadaCategory;
import com.wms.model.User;
import com.wms.util.AppConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * SalesCategoryMappingsServlet — UC-B2C09: endpoints to CRUD the
 * WMS ↔ Lazada category mapping table. Drives the "Ánh xạ Lazada"
 * tab on the /sales/categories page.
 */
@WebServlet(name = "SalesCategoryMappingsServlet", urlPatterns = {"/sales/category-mappings"})
public class SalesCategoryMappingsServlet extends BaseController {

    private final CategoryMappingDAO mappingDao = new CategoryMappingDAO();
    private final LazadaCategoryDAO lazadaDao = new LazadaCategoryDAO();

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("load".equals(action)) {
            int channelId = parseInt(req.getParameter("channelId"), -1);
            int wmsCategoryId = parseInt(req.getParameter("wmsCategoryId"), -1);
            if (channelId < 0 || wmsCategoryId < 0) {
                writeJson(resp, "{\"success\":false,\"message\":\"missing channelId or wmsCategoryId\"}");
                return;
            }
            List<CategoryMapping> mappings = mappingDao.findByWmsCategory(channelId, wmsCategoryId);
            StringBuilder json = new StringBuilder("{\"success\":true,\"mappings\":[");
            for (int i = 0; i < mappings.size(); i++) {
                CategoryMapping m = mappings.get(i);
                if (i > 0) json.append(",");
                json.append("{")
                    .append("\"mappingId\":").append(m.getMappingId())
                    .append(",\"lazadaCategoryId\":").append(m.getLazadaCategoryId())
                    .append(",\"lazadaName\":\"").append(esc(m.getLazadaName())).append("\"")
                    .append(",\"isPrimary\":").append(m.isPrimary())
                    .append("}");
            }
            json.append("]}");
            writeJson(resp, json.toString());
        } else if ("searchLazadaLeaves".equals(action)) {
            int channelId = parseInt(req.getParameter("channelId"), -1);
            String q = req.getParameter("q");
            if (channelId < 0) {
                writeJson(resp, "{\"success\":false,\"message\":\"missing channelId\"}");
                return;
            }
            List<LazadaCategory> all = lazadaDao.findLeaves(channelId);
            StringBuilder json = new StringBuilder("{\"success\":true,\"leaves\":[");
            int added = 0;
            for (int i = 0; i < all.size(); i++) {
                LazadaCategory lc = all.get(i);
                String name = lc.getName() == null ? "" : lc.getName();
                if (q != null && !q.isBlank()
                        && !name.toLowerCase().contains(q.toLowerCase())) continue;
                if (added++ > 0) json.append(",");
                json.append("{\"lazadaCategoryId\":").append(lc.getLazadaCategoryId())
                    .append(",\"name\":\"").append(esc(name)).append("\"}");
                if (added >= 50) break; // cap results
            }
            json.append("],\"truncated\":").append(added >= 50).append("}");
            writeJson(resp, json.toString());
        } else {
            writeJson(resp, "{\"success\":false,\"message\":\"Unknown action\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            if ("add".equals(action)) {
                int channelId = parseInt(req.getParameter("channelId"), -1);
                int wmsCategoryId = parseInt(req.getParameter("wmsCategoryId"), -1);
                long lazadaCategoryId = Long.parseLong(req.getParameter("lazadaCategoryId").trim());
                String lazadaName = req.getParameter("lazadaName");
                boolean isPrimary = "1".equals(req.getParameter("isPrimary"));
                HttpSession session = req.getSession(false);
                Integer createdBy = null;
                if (session != null) {
                    User u = (User) session.getAttribute(AppConstants.SESSION_USER);
                    if (u != null) createdBy = u.getUserId();
                }
                CategoryMapping m = new CategoryMapping();
                m.setChannelId(channelId);
                m.setWmsCategoryId(wmsCategoryId);
                m.setLazadaCategoryId(lazadaCategoryId);
                m.setLazadaName(lazadaName == null ? "" : lazadaName);
                m.setPrimary(isPrimary);
                m.setCreatedBy(createdBy);
                boolean ok = mappingDao.insert(m);
                if (isPrimary && ok) {
                    // Find the new mapping_id to mark as primary
                    List<CategoryMapping> all = mappingDao.findByWmsCategory(channelId, wmsCategoryId);
                    for (CategoryMapping x : all) {
                        if (x.getLazadaCategoryId() == lazadaCategoryId) {
                            mappingDao.setPrimary(x.getMappingId(), channelId, wmsCategoryId);
                            break;
                        }
                    }
                }
                writeJson(resp, "{\"success\":" + ok + "}");
            } else if ("delete".equals(action)) {
                int mappingId = parseInt(req.getParameter("mappingId"), -1);
                boolean ok = mappingId > 0 && mappingDao.delete(mappingId);
                writeJson(resp, "{\"success\":" + ok + "}");
            } else if ("setPrimary".equals(action)) {
                int mappingId = parseInt(req.getParameter("mappingId"), -1);
                int channelId = parseInt(req.getParameter("channelId"), -1);
                int wmsCategoryId = parseInt(req.getParameter("wmsCategoryId"), -1);
                boolean ok = mappingId > 0
                        && mappingDao.setPrimary(mappingId, channelId, wmsCategoryId);
                writeJson(resp, "{\"success\":" + ok + "}");
            } else {
                writeJson(resp, "{\"success\":false,\"message\":\"Unknown action\"}");
            }
        } catch (Exception e) {
            writeJson(resp, "{\"success\":false,\"message\":\"" + esc(e.getMessage()) + "\"}");
        }
    }

    private static int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
}