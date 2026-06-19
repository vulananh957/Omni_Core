package com.wms.scheduler;

import com.wms.dao.ChannelDAO;
import com.wms.model.Channel;
import com.wms.service.channel.ChannelSyncAudit;
import com.wms.service.lazada.LazadaProductService;
import com.wms.service.lazada.LazadaProductService.PullResult;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LazadaProductSyncScheduler — Background timer that pulls Lazada's
 * product list at a configurable interval and upserts each item into
 * channel_products (UC-B2C01).
 *
 * Companion to LazadaSyncScheduler (which pulls orders). Running on
 * a separate schedule keeps the heavy product sync from competing
 * with time-critical order syncs.
 *
 * Disabled by default — set {@code lazada.product.sync.enabled=true} in
 * web.xml to turn it on.
 */
@WebListener
public class LazadaProductSyncScheduler implements ServletContextListener {

    private static final Logger LOGGER = Logger.getLogger(LazadaProductSyncScheduler.class.getName());

    public static final String CTX_PARAM_ENABLED  = "lazada.product.sync.enabled";
    public static final String CTX_PARAM_INTERVAL = "lazada.product.sync.interval.minutes";

    private Timer timer;
    private ServletContext ctx;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        this.ctx = sce.getServletContext();
        String enabled = ctx.getInitParameter(CTX_PARAM_ENABLED);
        if (!"true".equalsIgnoreCase(enabled)) {
            LOGGER.info("LazadaProductSyncScheduler: disabled by config (set "
                    + CTX_PARAM_ENABLED + "=true to enable).");
            return;
        }
        int minutes = parseInterval(ctx.getInitParameter(CTX_PARAM_INTERVAL));
        LOGGER.info("LazadaProductSyncScheduler: enabled, interval=" + minutes + " min");
        timer = new Timer("LazadaProductSyncTimer", true);
        timer.scheduleAtFixedRate(new SyncTask(), 30_000L, minutes * 60_000L);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (timer != null) {
            timer.cancel();
            timer = null;
        }
    }

    private int parseInterval(String v) {
        try {
            int n = Integer.parseInt(v);
            return n > 0 ? n : 60;
        } catch (Exception e) {
            return 60;
        }
    }

    // ── Sync task ─────────────────────────────────────────────

    private class SyncTask extends TimerTask {

        private final ChannelDAO channelDAO = new ChannelDAO();
        private final LazadaProductService productService = new LazadaProductService();

        @Override
        public void run() {
            LOGGER.info("LazadaProductSyncScheduler: cycle started");
            try {
                List<Channel> channels = channelDAO.findAll();
                for (Channel ch : channels) {
                    if (!ch.isActive() || !"Lazada".equalsIgnoreCase(ch.getPlatform())) continue;
                    if (ch.getAccessToken() == null || ch.getAccessToken().isEmpty()) continue;
                    try {
                        PullResult r = productService.pullProducts(ch);
                        LOGGER.info("LazadaProductSyncScheduler: channel "
                                + ch.getChannelName() + " ok=" + r.ok
                                + " pulled=" + r.pulled + " upserted=" + r.upserted
                                + " unmapped=" + r.unmapped);
                        updateLastProductSync(ch.getChannelId());
                    } catch (Exception e) {
                        LOGGER.log(Level.WARNING,
                                "LazadaProductSyncScheduler: failed channel "
                                        + ch.getChannelName() + ": " + e.getMessage(), e);
                        ChannelSyncAudit.logFailure(ch.getChannelId(),
                                "PRODUCT_PULL", null, null, null, e.getMessage());
                    }
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE,
                        "LazadaProductSyncScheduler: cycle crashed", e);
            }
        }

        private void updateLastProductSync(int channelId) {
            String sql = "UPDATE channels SET last_product_sync_at = CURRENT_TIMESTAMP "
                       + "WHERE channel_id = ?";
            try (Connection conn = com.wms.util.DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, channelId);
                ps.executeUpdate();
            } catch (Exception e) {
                LOGGER.log(Level.WARNING,
                        "LazadaProductSyncScheduler: updateLastProductSync failed", e);
            }
        }
    }
}
