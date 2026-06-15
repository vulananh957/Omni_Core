package com.wms.service.warehouse;

import com.wms.dao.LedgerDAO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.function.Consumer;

/**
 * InventoryCommandBus — Simple in-process event bus for inventory change
 * events. Automatically writes a ledger entry for each event.
 *
 * <h3>Why it exists</h3>
 * <p>Previously each service (Inbound, Outbound, Transfer, Return) had to
 * call {@code LedgerDAO.insertLedgerEntry()} manually — easy to forget, easy
 * to misalign, easy to double-count. With the Command Bus, services just
 * publish events; the bus writes the ledger through a single, shared path,
 * keeping all flows consistent.</p>
 *
 * <h3>Usage</h3>
 * <pre>{@code
 *   InventoryEvent event = new InventoryEvent(
 *       productId, warehouseId, InventoryEvent.Type.OUTBOUND, qty, userId, "Outbound SOUT-001");
 *   InventoryCommandBus.get().publish(event);
 * }</pre>
 *
 * <h3>Default listener</h3>
 * <p>The bus auto-registers one internal listener that calls
 * {@code LedgerDAO.upsertInventory()} + {@code LedgerDAO.insertLedgerEntry()}.
 * Other services may register additional listeners (e.g. notifications,
 * cache refresh, audit log).</p>
 */
public class InventoryCommandBus {

    private static final Logger log = LoggerFactory.getLogger(InventoryCommandBus.class);

    private static final InventoryCommandBus INSTANCE = new InventoryCommandBus();

    private final List<Consumer<InventoryEvent>> listeners = new CopyOnWriteArrayList<>();

    private InventoryCommandBus() {
        // Đăng ký listener mặc định ghi ledger
        register(this::writeToLedger);
    }

    public static InventoryCommandBus get() {
        return INSTANCE;
    }

    /** Registers an extra listener (e.g. for notifications, audit). */
    public void register(Consumer<InventoryEvent> listener) {
        if (listener != null) {
            listeners.add(listener);
        }
    }

    /** Publish event cho tất cả listeners. Không throw nếu listener lỗi. */
    public void publish(InventoryEvent event) {
        if (event == null) return;
        for (Consumer<InventoryEvent> l : listeners) {
            try {
                l.accept(event);
            } catch (Exception e) {
                log.error("InventoryCommandBus listener failed for event {}", event, e);
            }
        }
    }

    // ── Default listener: ghi ledger entry ─────────────────────────────

    private void writeToLedger(InventoryEvent event) {
        try {
            LedgerDAO dao = new LedgerDAO();
            int inventoryId = dao.getInventoryIdForUpdate(
                event.getProductId(), event.getWarehouseId());
            if (inventoryId <= 0) {
                log.warn("InventoryCommandBus: no inventory row for productId={} warehouseId={}",
                    event.getProductId(), event.getWarehouseId());
                return;
            }
            Map<String, Object> ledgerEntry = new HashMap<>();
            ledgerEntry.put("inventoryId", inventoryId);
            ledgerEntry.put("productId", event.getProductId());
            ledgerEntry.put("warehouseId", event.getWarehouseId());
            ledgerEntry.put("type", event.getType().name());
            ledgerEntry.put("qtyChange", event.getQtyChange());
            ledgerEntry.put("availChange", event.getAvailChange());
            ledgerEntry.put("userId", event.getUserId());
            ledgerEntry.put("note", event.getNote());
            dao.insertSimpleLedgerEntry(ledgerEntry);
        } catch (Exception e) {
            log.error("InventoryCommandBus.writeToLedger failed", e);
        }
    }

    /**
     * Event describing a single inventory change.
     * Explicit DTO with clear field names for readability.
     */
    public static class InventoryEvent {
        public enum Type { INBOUND, OUTBOUND, ADJUSTMENT, TRANSFER_IN, TRANSFER_OUT, RESTOCK }

        private final int productId;
        private final int warehouseId;
        private final Type type;
        private final BigDecimal qtyChange;
        private final BigDecimal availChange;
        private final int userId;
        private final String note;

        public InventoryEvent(int productId, int warehouseId, Type type,
                             BigDecimal qtyChange, BigDecimal availChange,
                             int userId, String note) {
            this.productId = productId;
            this.warehouseId = warehouseId;
            this.type = type;
            this.qtyChange = qtyChange;
            this.availChange = availChange;
            this.userId = userId;
            this.note = note;
        }

        public int getProductId() { return productId; }
        public int getWarehouseId() { return warehouseId; }
        public Type getType() { return type; }
        public BigDecimal getQtyChange() { return qtyChange; }
        public BigDecimal getAvailChange() { return availChange; }
        public int getUserId() { return userId; }
        public String getNote() { return note; }

        @Override
        public String toString() {
            return "InventoryEvent{type=" + type + ", productId=" + productId
                + ", warehouseId=" + warehouseId + ", qty=" + qtyChange
                + ", avail=" + availChange + "}";
        }
    }
}
