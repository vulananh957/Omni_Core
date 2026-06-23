package com.wms.service.ledger;

import com.wms.dao.LedgerDAO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

public class LedgerService {

    private static final Logger log = LoggerFactory.getLogger(LedgerService.class);
    private final LedgerDAO ledgerDAO = new LedgerDAO();

    public List<LedgerDAO.LedgerDocument> findAllDocuments() {
        return ledgerDAO.findAllDocuments();
    }

    /** Documents scoped to one warehouse (Warehouse Staff view). */
    public List<LedgerDAO.LedgerDocument> findAllDocuments(int warehouseId) {
        return ledgerDAO.findAllDocuments(warehouseId);
    }

    public List<LedgerDAO.GlobalLedgerEntry> findGlobalLedgerEntries() {
        return ledgerDAO.findGlobalLedgerEntries();
    }

    public List<java.util.Map<String, Object>> findDocumentItems(String docId, String docType) {
        return ledgerDAO.findDocumentItems(docId, docType);
    }

    public boolean verifyDocumentBelongsToWarehouse(String docId, String docType, int warehouseId) {
        return ledgerDAO.verifyDocumentBelongsToWarehouse(docId, docType, warehouseId);
    }

    public boolean approveDocument(String docType, String docId, int approvedBy) {
        boolean ok = ledgerDAO.approveDocument(docId, docType, approvedBy);
        if (ok) {
            log.info("Document approved: type={} id={} by={}", docType, docId, approvedBy);
        } else {
            log.error("Document approval failed: type={} id={}", docType, docId);
        }
        return ok;
    }

    public boolean rejectDocument(String docType, String docId, String reason, int rejectedBy) {
        boolean ok = ledgerDAO.rejectDocument(docId, docType, reason, rejectedBy);
        if (ok) {
            log.info("Document rejected: type={} id={} by={}", docType, docId, rejectedBy);
        } else {
            log.error("Document rejection failed: type={} id={}", docType, docId);
        }
        return ok;
    }
}
