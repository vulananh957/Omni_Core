package com.wms.service.warehouse;

import com.wms.dao.ProductDAO;
import com.wms.dao.TransferDAO;
import com.wms.dao.WarehouseDAO;
import com.wms.model.Warehouse;
import com.wms.model.Zone;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.SQLException;
import java.util.List;

public class WarehouseService {

    private static final Logger log = LoggerFactory.getLogger(WarehouseService.class);

    private final WarehouseDAO warehouseDAO = new WarehouseDAO();

    public List<Warehouse> findAll() throws SQLException {
        return warehouseDAO.findAll();
    }

    public List<Warehouse> findAllActive() throws SQLException {
        List<Warehouse> all = warehouseDAO.findAll();
        return all.stream()
                .filter(Warehouse::isActive)
                .collect(java.util.stream.Collectors.toList());
    }

    public List<Zone> findAllZones() throws SQLException {
        List<Warehouse> warehouses = warehouseDAO.findAll();
        return warehouses.stream()
                .flatMap(w -> w.getZones() != null ? w.getZones().stream() : java.util.stream.Stream.empty())
                .collect(java.util.stream.Collectors.toList());
    }

    public List<Zone> findZonesByWarehouseId(int warehouseId) throws SQLException {
        Warehouse w = warehouseDAO.findById(warehouseId);
        if (w != null && w.getZones() != null) {
            return w.getZones();
        }
        return java.util.Collections.emptyList();
    }
    public Warehouse findById(int warehouseId) throws SQLException {
        return warehouseDAO.findById(warehouseId);
    }

    public SaveResult saveWarehouse(Warehouse warehouse) {
        try {
            if (warehouse == null
                || warehouse.getWarehouseCode() == null || warehouse.getWarehouseCode().trim().isEmpty()
                || warehouse.getWarehouseName() == null || warehouse.getWarehouseName().trim().isEmpty()) {
                return SaveResult.failure("Thiếu thông tin bắt buộc (mã kho, tên kho).");
            }

            warehouse.setWarehouseCode(warehouse.getWarehouseCode().trim().toUpperCase());
            warehouse.setWarehouseName(warehouse.getWarehouseName().trim());
            warehouse.setAddress(warehouse.getAddress() != null ? warehouse.getAddress().trim() : "");
            warehouse.setPhone(warehouse.getPhone() != null ? warehouse.getPhone().trim() : "");

            List<Zone> zones = warehouse.getZones();
            if (zones != null) {
                for (Zone z : zones) {
                    if (z.getZoneCode() == null || z.getZoneCode().trim().isEmpty()) {
                        z.setZoneCode(warehouse.getWarehouseCode()
                            + "-" + z.getZoneType().substring(0, Math.min(4, z.getZoneType().length())).toUpperCase());
                    } else {
                        z.setZoneCode(z.getZoneCode().trim().toUpperCase());
                    }
                    z.setZoneName(z.getZoneName() != null ? z.getZoneName().trim() : "");
                    z.setActive(true);
                }
            }

            boolean success;
            if (warehouse.getWarehouseId() > 0) {
                success = warehouseDAO.update(warehouse, zones);
            } else {
                success = warehouseDAO.insert(warehouse, zones);
            }

            if (!success) {
                return SaveResult.failure("Không thể lưu thông tin kho. Vui lòng kiểm tra trùng mã kho.");
            }
            return SaveResult.success();
        } catch (Exception e) {
            log.error("Error saving warehouse", e);
            return SaveResult.failure("Lỗi định dạng dữ liệu: " + e.getMessage());
        }
    }

    public boolean toggleStatus(int warehouseId, boolean active) throws SQLException {
        return warehouseDAO.toggleStatus(warehouseId, active);
    }

    public static class SaveResult {
        private final boolean success;
        private final String message;

        private SaveResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public static SaveResult success() {
            return new SaveResult(true, null);
        }

        public static SaveResult failure(String message) {
            return new SaveResult(false, message);
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }
}
