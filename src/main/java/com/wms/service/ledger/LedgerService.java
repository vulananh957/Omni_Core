package com.wms.service.ledger;

import com.wms.dao.LedgerDAO;
import com.wms.service.common.NotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

public class LedgerService {

    private static final Logger log = LoggerFactory.getLogger(LedgerService.class);
    private final LedgerDAO ledgerDAO = new LedgerDAO();
    private final NotificationService notificationService = new NotificationService();

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
            // Notify warehouse staff who submitted this document
            String creatorStr = ledgerDAO.getDocumentCreatorUserId(docType, docId);
            if (creatorStr != null) {
                try {
                    int creatorId = Integer.parseInt(creatorStr);
                    long refId = Long.parseLong(docId);
                    notificationService.notifyGrnApproved(creatorId, refId, docType + "-" + docId);
                } catch (NumberFormatException ignored) {}
            }
        } else {
            log.error("Document approval failed: type={} id={}", docType, docId);
        }
        return ok;
    }

    public boolean rejectDocument(String docType, String docId, String reason, int rejectedBy) {
        boolean ok = ledgerDAO.rejectDocument(docId, docType, reason, rejectedBy);
        if (ok) {
            log.info("Document rejected: type={} id={} by={}", docType, docId, rejectedBy);
            // Notify warehouse staff who submitted this document
            String creatorStr = ledgerDAO.getDocumentCreatorUserId(docType, docId);
            if (creatorStr != null) {
                try {
                    int creatorId = Integer.parseInt(creatorStr);
                    long refId = Long.parseLong(docId);
                    notificationService.notifyUser(creatorId, "WAREHOUSE_STAFF", null,
                            com.wms.model.Notification.TYPE_APPROVAL,
                            "Phiếu " + docType + " bị từ chối",
                            "Phiếu " + docType + " số " + docId + " đã bị từ chối. Lý do: " + (reason != null ? reason : "Không có"),
                            docType, refId,
                            com.wms.model.Notification.PRIORITY_NORMAL);
                } catch (NumberFormatException ignored) {}
            }
        } else {
            log.error("Document rejection failed: type={} id={}", docType, docId);
        }
        return ok;
    }
}
