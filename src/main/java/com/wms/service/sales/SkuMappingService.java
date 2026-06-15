package com.wms.service.sales;

import com.wms.dao.ChannelDAO;
import com.wms.dao.ChannelProductDAO;
import com.wms.dao.SkuMappingDAO;
import com.wms.model.Channel;
import com.wms.model.Product;
import com.wms.model.SkuMapping;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class SkuMappingService {

    private final SkuMappingDAO skuMappingDAO = new SkuMappingDAO();
    private final ChannelProductDAO channelProductDAO = new ChannelProductDAO();
    private final ChannelDAO channelDAO = new ChannelDAO();

    public List<SkuMapping> findAllMappings() {
        return skuMappingDAO.findAll();
    }

    public List<Channel> findAllChannels() {
        return channelDAO.findAll();
    }

    public List<Product> findAllSkus() {
        return skuMappingDAO.findAllSkus();
    }

    public boolean createMapping(int skuId, int channelId, String externalSku,
                                  String sellerSku, LocalDateTime now) {
        SkuMapping mapping = new SkuMapping();
        mapping.setSkuId(skuId);
        mapping.setChannelId(channelId);
        mapping.setExternalSku(externalSku);
        mapping.setSellerSku(sellerSku);
        mapping.setSyncStatus("PENDING");
        mapping.setLastSyncAt(now);
        return skuMappingDAO.insert(mapping);
    }

    public boolean updateMapping(int mappingId, int skuId, int channelId, String externalSku,
                                  String sellerSku, String syncStatus, LocalDateTime now) {
        SkuMapping mapping = new SkuMapping();
        mapping.setMappingId(mappingId);
        mapping.setSkuId(skuId);
        mapping.setChannelId(channelId);
        mapping.setExternalSku(externalSku);
        mapping.setSellerSku(sellerSku);
        mapping.setSyncStatus(syncStatus);
        mapping.setLastSyncAt(now);
        return skuMappingDAO.update(mapping);
    }

    public boolean deleteMapping(int mappingId) {
        return skuMappingDAO.delete(mappingId);
    }

    public SyncResult syncChannelProduct(int channelProductId, BigDecimal price,
                                          BigDecimal stock, LocalDateTime now) {
        boolean success = false;
        if (price != null) {
            success = channelProductDAO.syncPrice(channelProductId, price);
        }
        if (stock != null) {
            success = channelProductDAO.syncStock(channelProductId, stock) || success;
        }
        if (success) {
            channelProductDAO.updateLastSynced(channelProductId);
        }
        return success ? SyncResult.success("Đồng bộ thông tin sản phẩm thành công!")
                       : SyncResult.failure("Đồng bộ thông tin sản phẩm thất bại.");
    }

    public int syncAllMappings(List<SkuMapping> mappings) {
        int synced = 0;
        for (SkuMapping m : mappings) {
            if ("PENDING".equals(m.getSyncStatus()) || "ERROR".equals(m.getSyncStatus())) {
                boolean ok = skuMappingDAO.updateSyncStatus(m.getMappingId(), "SYNCED");
                if (ok) synced++;
            }
        }
        return synced;
    }

    public static class SyncResult {
        private final boolean success;
        private final String message;

        private SyncResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public static SyncResult success(String message) {
            return new SyncResult(true, message);
        }

        public static SyncResult failure(String message) {
            return new SyncResult(false, message);
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }
}
