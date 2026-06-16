package com.wms.service.channel;

import com.wms.model.Channel;

import java.util.List;
import java.util.Map;

/**
 * ChannelGateway — Channel-agnostic abstraction over a marketplace
 * (Lazada, Shopee, TikTok, ...). The runtime resolves a concrete
 * implementation through {@link ChannelRegistry}.
 *
 * <p>Every method returns the raw JSON response from the platform,
 * leaving the caller to parse what it needs. Higher-level domain
 * services (LazadaOrderService, LazadaProductService, ...) parse
 * Lazada-specific responses; new platforms implement this interface
 * with their own JSON shape.
 */
public interface ChannelGateway {

    /** Lazada, Shopee, TikTok — matches {@code channels.platform}. */
    String platformName();

    // ── Catalog ──────────────────────────────────────────────

    /** Fetches the platform's product list (paginated). */
    String listProducts(Channel channel, int pageNumber, int pageSize);

    /** Creates a product on the channel. */
    String createProduct(Channel channel, Map<String, String> payload);

    /** Updates an existing channel product. */
    String updateProduct(Channel channel, String channelItemId,
                         Map<String, String> payload);

    // ── Stock & Price sync (BR-02 buffer stock rule) ────────

    /** Pushes the sellable stock for a single SKU. */
    String updateProductStock(Channel channel, String sellerSku, int qty);

    /** Pushes the sellable stock for many SKUs at once. */
    String updateProductStockBatch(Channel channel, List<StockUpdate> updates);

    // ── Orders ───────────────────────────────────────────────

    /** Lists orders in the given status, updated since the given epoch seconds. */
    String listOrders(Channel channel, String status, Long updatedAfterEpochSec);

    /** Returns the order detail (full payload). */
    String getOrder(Channel channel, String orderId);

    /** Returns the order items. */
    String getOrderItems(Channel channel, String orderId);

    // ── Fulfillment ──────────────────────────────────────────

    /**
     * 1. /order/fulfill/pack — Lazada returns tracking number + package id.
     * payload: order_item_list, delivery_type
     */
    String packOrder(Channel channel, String orderId, String deliveryType);

    /** 2. /order/package/document/get — returns base64 PDF label. */
    String getShippingLabel(Channel channel, String packageId);

    /** 3. /order/package/rts — Ready-To-Ship notification. */
    String readyToShip(Channel channel, String packageId);

    // ── Tracking ─────────────────────────────────────────────

    /** /logistic/order/trace — returns tracking events array. */
    String getTrackingTrace(Channel channel, String orderNumber);

    // ── RMA / Reverse ────────────────────────────────────────

    /** GET /reverse/getreverseordersforseller */
    String listReverseOrders(Channel channel, Long createdAfterEpochSec);

    /**
     * GET /order/reverse/return/update — confirms / refuses a return.
     * action: "acceptReturn" | "refuseReturn" | "refuseRefund"
     */
    String updateReverseOrder(Channel channel, String reverseOrderId, String action,
                              Map<String, String> payload);

    // ── DTOs ─────────────────────────────────────────────────

    final class StockUpdate {
        public final String sellerSku;
        public final int qty;
        public StockUpdate(String sellerSku, int qty) {
            this.sellerSku = sellerSku;
            this.qty = qty;
        }
    }
}
