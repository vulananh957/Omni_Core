package com.wms.scheduler;

import com.wms.service.warehouse.RopCalculationService;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Timer;
import java.util.TimerTask;

/**
 * RopScheduler — Nightly background job that auto-computes the Reorder Point (ROP)
 * for every active SKU.
 *
 * <p>Formula:
 * <pre>
 *   SS  = (D_max × L_max) − (D_avg × L_avg)    [Safety Stock]
 *   ROP = (D_avg × L_avg) + SS                   [Reorder Point]
 * </pre>
 *
 * <p>Context parameters (web.xml):
 * <ul>
 *   <li>{@code rop.enabled} — "true" to enable (default: true)</li>
 *   <li>{@code rop.interval.minutes} — run interval in minutes (default: 1440 = once/day)</li>
 *   <li>{@code rop.lookback.days} — lookback window in days (default: 30)</li>
 * </ul>
 *
 * <p>Disabled by default — set {@code rop.enabled=true} in web.xml to activate.
 * When enabled, the timer fires every {@code rop.interval.minutes}.
 * A practical setup is 1440 min (daily at 02:00 AM) by scheduling the initial
 * delay to align with that hour.
 */
@WebListener
public class RopScheduler implements ServletContextListener {

    private static final Logger LOGGER = LoggerFactory.getLogger(RopScheduler.class);

    public static final String CTX_ENABLED  = "rop.enabled";
    public static final String CTX_INTERVAL  = "rop.interval.minutes";
    public static final String CTX_LOOKBACK = "rop.lookback.days";

    private Timer timer;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext ctx = sce.getServletContext();
        String enabledStr = ctx.getInitParameter(CTX_ENABLED);
        boolean enabled = "true".equalsIgnoreCase(enabledStr) || enabledStr == null; // default ON

        if (!enabled) {
            LOGGER.info("RopScheduler: disabled (set {} to enable)", CTX_ENABLED);
            return;
        }

        int intervalMin = parseInt(ctx.getInitParameter(CTX_INTERVAL), 1440);  // daily
        int lookback   = parseInt(ctx.getInitParameter(CTX_LOOKBACK), 30);

        LOGGER.info("RopScheduler: enabled, interval={} min, lookback={} days", intervalMin, lookback);

        timer = new Timer("RopSchedulerTimer", true);
        // First run: 2 minutes after startup so Tomcat finishes booting first.
        // Subsequent runs: every intervalMin minutes.
        timer.scheduleAtFixedRate(new RopTask(lookback), 120_000L, intervalMin * 60_000L);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (timer != null) {
            timer.cancel();
            LOGGER.info("RopScheduler: timer cancelled");
        }
    }

    private static class RopTask extends TimerTask {
        private final int lookbackDays;

        RopTask(int lookbackDays) {
            this.lookbackDays = lookbackDays;
        }

        @Override
        public void run() {
            LOGGER.info("RopScheduler: nightly run starting (lookback={} days)", lookbackDays);
            try {
                RopCalculationService.RopResult result =
                        new RopCalculationService().computeAndUpdateAllRop(lookbackDays, 0);
                LOGGER.info("RopScheduler: completed — {}", result.message);
            } catch (Exception e) {
                LOGGER.error("RopScheduler: run failed", e);
            }
        }
    }

    private static int parseInt(String s, int fallback) {
        if (s == null || s.trim().isEmpty()) return fallback;
        try { return Integer.parseInt(s.trim()); }
        catch (NumberFormatException e) { return fallback; }
    }
}
