package com.wms.service.warehouse;

import com.wms.dao.ProductDAO;
import com.wms.model.Product;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

/**
 * RopCalculationService — Auto ROP (Reorder Point) computation engine.
 *
 * <p>Computes the Reorder Point for every active product using historical data:
 *
 * <pre>
 *   SS   = (D_max × L_max) − (D_avg × L_avg)        [Safety Stock]
 *   ROP  = (D_avg × L_avg) + SS                       [Reorder Point]
 *
 *   D_avg = average daily shipped qty  (lookback 30 days)
 *   D_max = maximum daily shipped qty  (lookback 30 days)
 *   L_avg = average lead time in days  (PO created → GRN received)
 *   L_max = maximum lead time in days   (PO created → GRN received)
 * </pre>
 *
 * <p>Triggered by:
 * <ul>
 *   <li>RopScheduler — runs every night at 02:00 AM (context-param: rop.enabled, rop.interval.minutes)</li>
 *   <li>RopServlet (API) — manual trigger by Manager via UI button</li>
 * </ul>
 *
 * <p>Results are written to:
 * <ul>
 *   <li>products.d_avg / d_max / l_avg / l_max / safety_stock / rop_calculated</li>
 *   <li>product_rop_log — full audit trail of every run</li>
 * </ul>
 */
public class RopCalculationService {

    private static final Logger log = LoggerFactory.getLogger(RopCalculationService.class);

    /** Default lookback window in days for historical analysis. */
    public static final int DEFAULT_LOOKBACK_DAYS = 30;

    private final ProductDAO productDAO = new ProductDAO();

    /**
     * Full ROP computation for all active products.
     *
     * @param lookbackDays number of past days to analyse (recommended: 30)
     * @param triggeredBy  userId if manually triggered, 0 if scheduled
     * @return a summary of the run
     */
    public RopResult computeAndUpdateAllRop(int lookbackDays, int triggeredBy) {
        if (lookbackDays < 7) {
            lookbackDays = DEFAULT_LOOKBACK_DAYS;
        }

        log.info("ROP computation starting: lookbackDays={} triggeredBy={}", lookbackDays, triggeredBy);
        long start = System.currentTimeMillis();

        List<Product> products = productDAO.findAll();
        int processed = 0;
        int updated = 0;
        int noData = 0;
        int errors = 0;

        for (Product prod : products) {
            if (prod.getProductId() <= 0) continue;

            try {
                processed++;
                RopItemResult result = computeForProduct(prod.getProductId(), lookbackDays, triggeredBy);
                if (result != null) {
                    if (result.updated) updated++;
                    else noData++;
                } else {
                    errors++;
                }
            } catch (Exception e) {
                errors++;
                log.error("ROP computation error for productId={}: {}", prod.getProductId(), e.getMessage());
            }
        }

        long elapsed = System.currentTimeMillis() - start;
        String msg = String.format(
            "ROP computation done: processed=%d updated=%d noData=%d errors=%d elapsedMs=%d",
            processed, updated, noData, errors, elapsed);
        log.info(msg);

        return new RopResult(processed, updated, noData, errors, elapsed, msg);
    }

    /**
     * ROP computation for a single product.
     *
     * @param productId     the product ID
     * @param lookbackDays lookback window
     * @param triggeredBy   userId or 0
     * @return RopItemResult or null on error
     */
    public RopItemResult computeForProduct(int productId, int lookbackDays, int triggeredBy) {
        // 1. Read current rop_calculated before update
        BigDecimal ropBefore = productDAO.findById(productId) != null
                ? BigDecimal.valueOf(productDAO.findById(productId).getRopCalculated())
                : BigDecimal.ZERO;

        // 2. Demand metrics: D_avg, D_max from shipped outbound orders
        BigDecimal[] demand = productDAO.findDemandMetrics(productId, lookbackDays);
        BigDecimal dAvg = (demand != null && demand[0] != null) ? demand[0] : BigDecimal.ZERO;
        BigDecimal dMax = (demand != null && demand[1] != null) ? demand[1] : BigDecimal.ZERO;

        // 3. Lead-time metrics: L_avg, L_max from inbound PO → GRN
        BigDecimal[] leadTime = productDAO.findLeadTimeMetrics(productId, lookbackDays);
        BigDecimal lAvg = (leadTime != null && leadTime[0] != null) ? leadTime[0] : BigDecimal.ZERO;
        BigDecimal lMax = (leadTime != null && leadTime[1] != null) ? leadTime[1] : BigDecimal.ZERO;

        // 4. Compute Safety Stock: SS = (D_max × L_max) − (D_avg × L_avg)
        BigDecimal ss = dMax.multiply(lMax).subtract(dAvg.multiply(lAvg));
        if (ss.compareTo(BigDecimal.ZERO) < 0) ss = BigDecimal.ZERO; // floor at 0

        // 5. Compute ROP: ROP = (D_avg × L_avg) + SS
        BigDecimal ropAfter = dAvg.multiply(lAvg).add(ss)
                .setScale(3, RoundingMode.HALF_UP);

        boolean hasData = dAvg.signum() > 0 || dMax.signum() > 0
                || lAvg.signum() > 0 || lMax.signum() > 0;

        if (hasData) {
            // 6. Update product table
            boolean updated = productDAO.updateRopMetrics(
                    productId, dAvg, dMax, lAvg, lMax, ss, ropAfter);

            // 7. Log to audit trail
            productDAO.insertRopLog(productId, lookbackDays,
                    dAvg, dMax, lAvg, lMax, ss, ropBefore, ropAfter, triggeredBy);

            log.debug("ROP computed: productId={} dAvg={} dMax={} lAvg={} lMax={} SS={} ROP={}",
                    productId, dAvg, dMax, lAvg, lMax, ss, ropAfter);

            return new RopItemResult(productId, dAvg, dMax, lAvg, lMax, ss, ropBefore, ropAfter, updated);
        } else {
            log.debug("ROP skipped (no history): productId={}", productId);
            return new RopItemResult(productId, dAvg, dMax, lAvg, lMax, ss, ropBefore, ropAfter, false);
        }
    }

    // ── Result DTOs ────────────────────────────────────────────────────────

    public static class RopResult {
        public final int processed;
        public final int updated;
        public final int noData;
        public final int errors;
        public final long elapsedMs;
        public final String message;

        public RopResult(int processed, int updated, int noData, int errors, long elapsedMs, String message) {
            this.processed = processed;
            this.updated = updated;
            this.noData = noData;
            this.errors = errors;
            this.elapsedMs = elapsedMs;
            this.message = message;
        }
    }

    public static class RopItemResult {
        public final int productId;
        public final BigDecimal dAvg, dMax, lAvg, lMax, safetyStock;
        public final BigDecimal ropBefore, ropAfter;
        public final boolean updated;

        public RopItemResult(int productId, BigDecimal dAvg, BigDecimal dMax,
                             BigDecimal lAvg, BigDecimal lMax, BigDecimal safetyStock,
                             BigDecimal ropBefore, BigDecimal ropAfter, boolean updated) {
            this.productId = productId;
            this.dAvg = dAvg;
            this.dMax = dMax;
            this.lAvg = lAvg;
            this.lMax = lMax;
            this.safetyStock = safetyStock;
            this.ropBefore = ropBefore;
            this.ropAfter = ropAfter;
            this.updated = updated;
        }
    }
}
