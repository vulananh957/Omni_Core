package com.wms.service.warehouse;

import com.wms.dao.ProductDAO;
import com.wms.dao.TransferDAO;
import com.wms.dao.WarehouseDAO;
import com.wms.model.Product;
import com.wms.model.Warehouse;

import java.sql.SQLException;
import java.util.List;

public class TransferService {

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
}
