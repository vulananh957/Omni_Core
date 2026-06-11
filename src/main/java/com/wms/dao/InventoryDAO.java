package com.wms.dao;

import com.wms.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
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
}
