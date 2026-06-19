package com.wms.scheduler;

import com.wms.dao.ChannelDAO;
import com.wms.model.Channel;
import com.wms.service.sales.ChannelService;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LazadaTokenRefreshScheduler — Background timer that proactively refreshes Lazada
 * access tokens before they expire.
 *
 * <p>Lazada access tokens have a typical lifetime of 86400 seconds (24 hours).
 * Rather than waiting for API calls to fail with 401 Unauthorized, this scheduler
 * runs on a configurable interval and refreshes tokens that are:
 * <ul>
 *   <li>Expired already, or</li>
 *   <li>Scheduled to expire within {@code bufferMinutes} (default: 1440 = 24 hours).</li>
 * </ul>
 *
 * <p>This ensures zero-downtime token rotation and eliminates manual re-authorization.
 *
 * <p>Configuration (via web.xml context-params):
 * <ul>
 *   <li>{@code lazada.tokenRefresh.enabled}  — "true" (default) or "false"</li>
 *   <li>{@code lazada.tokenRefresh.interval.minutes} — check interval (default: 60)</li>
 *   <li>{@code lazada.tokenRefresh.bufferMinutes} — refresh tokens expiring within N minutes (default: 1440)</li>
 * </ul>
 */
@WebListener
public class LazadaTokenRefreshScheduler implements ServletContextListener {

    private static final Logger LOGGER =
            Logger.getLogger(LazadaTokenRefreshScheduler.class.getName());

    private Timer timer;
    private ServletContext servletContext;

    public static final String CTX_ENABLED        = "lazada.tokenRefresh.enabled";
    public static final String CTX_INTERVAL_MIN    = "lazada.tokenRefresh.interval.minutes";
    public static final String CTX_BUFFER_MIN      = "lazada.tokenRefresh.bufferMinutes";

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        servletContext = sce.getServletContext();

        String enabled = servletContext.getInitParameter(CTX_ENABLED);
        if (!"true".equalsIgnoreCase(enabled)) {
            LOGGER.info("LazadaTokenRefreshScheduler: Disabled by configuration. Skipping startup.");
            return;
        }

        int intervalMinutes  = parseInt(CTX_INTERVAL_MIN, 60);
        int bufferMinutes   = parseInt(CTX_BUFFER_MIN,   1440);

        LOGGER.info("LazadaTokenRefreshScheduler: Starting. "
                + "interval=" + intervalMinutes + "min, buffer=" + bufferMinutes + "min.");

        timer = new Timer("LazadaTokenRefreshTimer", true);
        // First run after 30 seconds, then repeat at the configured interval
        timer.scheduleAtFixedRate(
                new RefreshTask(bufferMinutes),
                30_000L,
                intervalMinutes * 60_000L);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (timer != null) {
            LOGGER.info("LazadaTokenRefreshScheduler: Cancelling timer...");
            timer.cancel();
            timer = null;
        }
    }

    private static int parseInt(String prop, int defaultVal) {
        try {
            int val = Integer.parseInt(prop);
            return val > 0 ? val : defaultVal;
        } catch (Exception e) {
            return defaultVal;
        }
    }

    // ───────────────────────────────────────────────────────────
    // Refresh task
    // ───────────────────────────────────────────────────────────

    private static class RefreshTask extends TimerTask {

        private final ChannelService channelService = new ChannelService();
        private final ChannelDAO     channelDAO    = new ChannelDAO();
        private final int            bufferMinutes;

        RefreshTask(int bufferMinutes) {
            this.bufferMinutes = bufferMinutes;
        }

        @Override
        public void run() {
            LOGGER.info("LazadaTokenRefreshScheduler: Refresh cycle started.");
            int refreshed = 0;
            int failed    = 0;

            try {
                List<Channel> channels = channelDAO.findChannelsNeedingTokenRefresh(bufferMinutes);

                if (channels.isEmpty()) {
                    LOGGER.info("LazadaTokenRefreshScheduler: No channels need token refresh at this time.");
                    return;
                }

                LOGGER.info("LazadaTokenRefreshScheduler: Found " + channels.size()
                        + " channel(s) needing token refresh.");

                for (Channel channel : channels) {
                    try {
                        boolean ok = channelService.refreshLazadaToken(channel);
                        if (ok) {
                            refreshed++;
                        } else {
                            failed++;
                        }
                    } catch (Exception e) {
                        LOGGER.log(Level.WARNING,
                                "LazadaTokenRefreshScheduler: Failed to refresh token for channel '"
                                        + channel.getChannelName() + "': " + e.getMessage(), e);
                        failed++;
                    }
                }

            } catch (Exception e) {
                LOGGER.log(Level.SEVERE,
                        "LazadaTokenRefreshScheduler: Refresh cycle failed: " + e.getMessage(), e);
            }

            LOGGER.info("LazadaTokenRefreshScheduler: Refresh cycle completed. "
                    + "refreshed=" + refreshed + " failed=" + failed);
        }
    }
}
