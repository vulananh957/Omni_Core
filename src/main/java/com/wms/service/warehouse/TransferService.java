package com.wms.service.warehouse;

import com.wms.dao.ProductDAO;
import com.wms.dao.TransferDAO;
import com.wms.dao.WarehouseDAO;
import com.wms.model.Product;
import com.wms.model.Warehouse;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

public class TransferService {

    private static final DateTimeFormatter CODE_FMT =
            DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss");

    private final TransferDAO transferDAO = new TransferDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();

    public List<TransferDAO.Transfer> findAll() throws SQLException {
        return transferDAO.findAll();
    }

    public TransferDAO.Transfer findById(int transferId) throws SQLException {
        return transferDAO.findById(transferId);
    }

    public List<TransferDAO.TransferItem> findItemsByTransferId(int transferId) throws SQLException {
        return transferDAO.findItemsByTransferId(transferId);
    }

    public List<Product> findApprovedProducts() throws SQLException {
        return productDAO.findApproved();
    }

    public List<Warehouse> findAllWarehouses() throws SQLException {
        return warehouseDAO.findAll();
    }

    /**
     * Creates a new transfer with its items atomically.
     *
     * @param fromWarehouseId source warehouse
     * @param toWarehouseId   destination warehouse
     * @param createdBy       user id of the creator
     * @param note            optional note
     * @param sku             SKU code of the product being transferred
     * @param qty             quantity to transfer
     * @return the created Transfer with transferId set; never null
     */
    public TransferDAO.Transfer createTransfer(int fromWarehouseId, int toWarehouseId,
            int createdBy, String note, String sku, BigDecimal qty) {

        String transferCode = "TRF-" + LocalDateTime.now().format(CODE_FMT);

        TransferDAO.Transfer t = new TransferDAO.Transfer();
        t.setTransferCode(transferCode);
        t.setFromWarehouseId(fromWarehouseId);
        t.setToWarehouseId(toWarehouseId);
        t.setCreatedBy(createdBy);
        t.setStatus(TransferDAO.Transfer.STATUS_DRAFT);
        t.setNote(note);

        try {
            int transferId = transferDAO.insert(t);
            t.setTransferId(transferId);

            Product product = productDAO.findBySkuCode(sku);
            if (product != null) {
                TransferDAO.TransferItem item = new TransferDAO.TransferItem();
                item.setTransferId(transferId);
                item.setProductId(product.getProductId());
                item.setSkuCode(sku);
                item.setProductName(product.getProductName());
                item.setShippedQty(qty);
                item.setReceivedQty(BigDecimal.ZERO);
                transferDAO.insertItem(item);
            }
            return t;
        } catch (SQLException e) {
            throw new RuntimeException("Không thể tạo phiếu chuyển kho: " + e.getMessage(), e);
        }
    }

    /**
     * Marks a transfer as received by updating its status in the database.
     */
    public void markReceived(int transferId) throws SQLException {
        TransferDAO.Transfer t = transferDAO.findById(transferId);
        if (t != null) {
            transferDAO.updateStatus(transferId, TransferDAO.Transfer.STATUS_RECEIVED);
        }
    }
}
