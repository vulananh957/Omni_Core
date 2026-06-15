package com.wms.dao;

import com.wms.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * InventoryDAO — Data Access Object for database operations on inventory levels.
 *
 * Implements core inventory business rules (e.g., Soft-Allocation / Giữ chỗ tồn kho).
 */
public class InventoryDAO {

    private static final Logger LOGGER = Logger.getLogger(InventoryDAO.class.getName());

    private static final String SQL_UPDATE_SOFT_ALLOCATE =
        "UPDATE inventory SET qty_available = qty_available - ? "
        + "WHERE product_id = ? AND warehouse_id = ? AND qty_available >= ?";

    /**
     * Executes soft-allocation to hold inventory for an order (Rule BR-04).
     * Deducts from qty_available.
     *
     * @param productId    The ID of the product.
     * @param warehouseId The ID of the warehouse.
     * @param quantityToHold The quantity to reserve.
     * @return true if soft-allocation succeeded (sufficient stock was available), false otherwise.
     */
    public boolean softAllocateInventory(int productId, int warehouseId, int quantityToHold) {
        if (quantityToHold <= 0) {
            throw new IllegalArgumentException("Quantity to hold must be greater than zero.");
        }

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            ps = conn.prepareStatement(SQL_UPDATE_SOFT_ALLOCATE);
            ps.setDouble(1, quantityToHold);
            ps.setInt(2, productId);
            ps.setInt(3, warehouseId);
            ps.setDouble(4, quantityToHold);

            int rowsAffected = ps.executeUpdate();

            if (rowsAffected > 0) {
                conn.commit();
                LOGGER.info("Soft-allocated " + quantityToHold + " units of product ID " + productId
                        + " at warehouse ID " + warehouseId);
                return true;
            } else {
                conn.rollback();
                LOGGER.warning("Soft-allocation failed: insufficient qty_available for product ID "
                        + productId + " at warehouse ID " + warehouseId);
                return false;
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error during soft-allocation. Initiating rollback...", e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    LOGGER.log(Level.SEVERE, "Failed to rollback transaction", rollbackEx);
                }
            }
            return false;
        } finally {
            if (ps != null) {
                try {
                    ps.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "Failed to close PreparedStatement", e);
                }
            }
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "Failed to close Connection", e);
                }
            }
        }
    }

    /**
     * Returns the currently-available (un-allocated) stock for a given
     * product/warehouse pair. Returns 0 if no inventory row exists.
     *
     * <p>Used by Sales order approval to validate that the chosen warehouse
     * has enough stock for the requested quantities BEFORE performing the
     * soft-allocate call. This prevents the bug where Sales could approve
     * an order against an out-of-stock warehouse.
     *
     * @param productId    Product primary key
     * @param warehouseId  Warehouse primary key
     * @return qty_available (0 if no inventory row exists or on error)
     */
    public int getAvailableStock(int productId, int warehouseId) {
        String sql = "SELECT qty_available FROM inventory WHERE product_id = ? AND warehouse_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, warehouseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING,
                "getAvailableStock failed productId=" + productId + " warehouseId=" + warehouseId, e);
        }
        return 0;
    }

    /**
     * Adds quantity to inventory (for inbound receives).
     * Increases qty_on_hand and qty_available by the given amount.
     * Creates the inventory ledger entry for INBOUND transaction.
     *
     * @param productId    The ID of the product.
     * @param warehouseId The ID of the warehouse.
     * @param quantity    The quantity to add (must be > 0).
     * @param userId      The ID of the user performing the operation.
     * @return true if the inventory was updated successfully, false otherwise.
     */
    public boolean addInventory(int productId, int warehouseId, BigDecimal quantity, int userId) {
        if (quantity == null || quantity.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Quantity to add must be greater than zero.");
        }

        Connection conn = null;
        PreparedStatement psUpdate = null;
        PreparedStatement psLedger = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Upsert inventory row
            String sqlUpsert =
                "INSERT INTO inventory (product_id, warehouse_id, qty_on_hand, holding, qty_available) " +
                "VALUES (?, ?, ?, 0, ?) " +
                "ON DUPLICATE KEY UPDATE " +
                "qty_on_hand = qty_on_hand + ?, qty_available = qty_available + ?";

            psUpdate = conn.prepareStatement(sqlUpsert);
            psUpdate.setInt(1, productId);
            psUpdate.setInt(2, warehouseId);
            psUpdate.setBigDecimal(3, quantity);
            psUpdate.setBigDecimal(4, quantity);
            psUpdate.setBigDecimal(5, quantity);
            psUpdate.setBigDecimal(6, quantity);
            psUpdate.executeUpdate();
            psUpdate.close();

            // Get the inventory_id for the ledger entry
            String sqlGetInvId = "SELECT inventory_id FROM inventory WHERE product_id = ? AND warehouse_id = ?";
            int inventoryId = -1;
            try (PreparedStatement psGet = conn.prepareStatement(sqlGetInvId)) {
                psGet.setInt(1, productId);
                psGet.setInt(2, warehouseId);
                try (java.sql.ResultSet rs = psGet.executeQuery()) {
                    if (rs.next()) {
                        inventoryId = rs.getInt("inventory_id");
                    }
                }
            }

            // Insert ledger entry
            String sqlLedger =
                "INSERT INTO inventory_ledger (inventory_id, product_id, warehouse_id, transaction_type, " +
                "qty_change, avail_change, created_by, note) " +
                "VALUES (?, ?, ?, 'INBOUND', ?, ?, ?, 'Nhập kho Inbound')";

            psLedger = conn.prepareStatement(sqlLedger);
            psLedger.setInt(1, inventoryId > 0 ? inventoryId : 0);
            psLedger.setInt(2, productId);
            psLedger.setInt(3, warehouseId);
            psLedger.setBigDecimal(4, quantity);
            psLedger.setBigDecimal(5, quantity);
            psLedger.setInt(6, userId);
            psLedger.executeUpdate();

            conn.commit();
            LOGGER.info("addInventory: added " + quantity + " units of product ID " + productId
                    + " at warehouse ID " + warehouseId);
            return true;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error during addInventory. Initiating rollback...", e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    LOGGER.log(Level.SEVERE, "Failed to rollback transaction", rollbackEx);
                }
            }
            return false;
        } finally {
            DBConnection.closeQuietly(psUpdate, psLedger);
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "Failed to close Connection", e);
                }
            }
        }
    }

    /**
     * Load current inventory across all warehouses (joined with product + warehouse).
     * Returns List<Map<String,Object>> for easy JSP/Jackson consumption.
     */
    public List<java.util.Map<String, Object>> findAllInventorySummary() {
        List<java.util.Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT inv.inventory_id, inv.product_id, p.sku_code, p.product_name, "
                   + "inv.warehouse_id, w.warehouse_name, "
                   + "inv.qty_on_hand, inv.holding, inv.qty_available, "
                   + "inv.updated_at "
                   + "FROM inventory inv "
                   + "LEFT JOIN products p ON inv.product_id = p.product_id "
                   + "LEFT JOIN warehouses w ON inv.warehouse_id = w.warehouse_id "
                   + "ORDER BY p.sku_code, w.warehouse_name "
                   + "LIMIT 500";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String, Object> row = new java.util.HashMap<>();
                row.put("inventoryId", rs.getInt("inventory_id"));
                row.put("productId", rs.getInt("product_id"));
                row.put("skuCode", rs.getString("sku_code"));
                row.put("productName", rs.getString("product_name"));
                row.put("warehouseId", rs.getInt("warehouse_id"));
                row.put("warehouseName", rs.getString("warehouse_name"));
                row.put("qtyOnHand", rs.getBigDecimal("qty_on_hand"));
                row.put("holding", rs.getBigDecimal("holding"));
                row.put("qtyAvailable", rs.getBigDecimal("qty_available"));
                java.sql.Timestamp updated = rs.getTimestamp("updated_at");
                row.put("updatedAt", updated != null ? updated.toLocalDateTime().toString() : "");
                result.add(row);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "findAllInventorySummary failed", e);
        }
        return result;
    }

    // ── Release Soft-Allocation (used when an order is cancelled) ──
    //
    // softAllocateInventory() only decrements qty_available. Without a release
    // counterpart, qty_available keeps dropping over time even though the goods
    // are still in the warehouse. The two methods below close the loop:
    // cancel → restore available; SHIPPED → decrement on_hand.
    // ──────────────────────────────────────────────────────────────

    /**
     * Releases a previously soft-allocated quantity (used on cancel).
     * Adds back to qty_available. Guards against negative values.
     *
     * @param productId    Product to release
     * @param warehouseId  Warehouse
     * @param quantity     Quantity to return
     * @return true if release succeeded, false otherwise
     */
    public boolean releaseSoftAllocateInventory(int productId, int warehouseId, BigDecimal quantity) {
        if (quantity == null || quantity.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Quantity to release must be greater than zero.");
        }

        String sql = "UPDATE inventory "
                   + "SET qty_available = qty_available + ? "
                   + "WHERE product_id = ? AND warehouse_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setBigDecimal(1, quantity);
            ps.setInt(2, productId);
            ps.setInt(3, warehouseId);

            int rows = ps.executeUpdate();
            boolean ok = rows > 0;

            if (ok) {
                LOGGER.info("releaseSoftAllocateInventory: released " + quantity
                        + " units of productId=" + productId
                        + " at warehouseId=" + warehouseId);
            } else {
                LOGGER.warning("releaseSoftAllocateInventory: no inventory row found for productId="
                        + productId + " warehouseId=" + warehouseId);
            }
            return ok;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "releaseSoftAllocateInventory: SQL error", e);
            return false;
        }
    }

    /**
     * Decrements on-hand stock when an order is successfully shipped.
     * Reduces both qty_on_hand and qty_available. Guards against over-deduction.
     *
     * @param productId    Product
     * @param warehouseId  Warehouse
     * @param quantity     Quantity to deduct
     * @return true if deducted, false if stock is insufficient
     */
    public boolean deductShippedInventory(int productId, int warehouseId, BigDecimal quantity) {
        if (quantity == null || quantity.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Quantity to deduct must be greater than zero.");
        }

        String sql = "UPDATE inventory "
                   + "SET qty_on_hand = qty_on_hand - ?, "
                   + "    qty_available = qty_available - ? "
                   + "WHERE product_id = ? AND warehouse_id = ? "
                   + "  AND qty_on_hand >= ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setBigDecimal(1, quantity);
            ps.setBigDecimal(2, quantity);
            ps.setInt(3, productId);
            ps.setInt(4, warehouseId);
            ps.setBigDecimal(5, quantity);

            int rows = ps.executeUpdate();
            boolean ok = rows > 0;

            if (ok) {
                LOGGER.info("deductShippedInventory: deducted " + quantity
                        + " units of productId=" + productId
                        + " at warehouseId=" + warehouseId);
            } else {
                LOGGER.warning("deductShippedInventory: insufficient qty_on_hand for productId="
                        + productId + " warehouseId=" + warehouseId);
            }
            return ok;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "deductShippedInventory: SQL error", e);
            return false;
        }
    }
}
