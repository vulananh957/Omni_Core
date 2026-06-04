package com.wms.dao;

import com.wms.util.DBConnection;

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
}
