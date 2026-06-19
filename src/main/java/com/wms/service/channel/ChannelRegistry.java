package com.wms.service.channel;

import java.util.Locale;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * ChannelRegistry — Maps a {@code channels.platform} value to the
 * {@link ChannelGateway} implementation that knows how to talk to it.
 *
 * <p>Adding a new marketplace (Shopee, TikTok) means:
 * <ol>
 *   <li>Implement {@link ChannelGateway} for the new platform.</li>
 *   <li>Call {@link #register(String, ChannelGateway)} from a static
 *       initializer, a CDI producer, or this file's bottom.</li>
 * </ol>
 * Existing callers continue to work unchanged because they only see
 * the {@code ChannelGateway} interface.
 */
public final class ChannelRegistry {

    private static final Map<String, ChannelGateway> GATEWAYS = new ConcurrentHashMap<>();

    static {
        // Built-in gateways. Add new platforms here.
        register("Lazada",  new LazadaChannelGateway());
    }

    private ChannelRegistry() {
    }

    public static void register(String platform, ChannelGateway gateway) {
        if (platform == null || gateway == null) return;
        GATEWAYS.put(normalize(platform), gateway);
    }

    /**
     * Returns the gateway for the given platform, or {@code null} if
     * no implementation is registered.
     */
    public static ChannelGateway get(String platform) {
        if (platform == null) return null;
        return GATEWAYS.get(normalize(platform));
    }

    /** Convenience: returns true if we have a gateway for this platform. */
    public static boolean supports(String platform) {
        return get(platform) != null;
    }

    private static String normalize(String s) {
        return s.trim().toLowerCase(Locale.ROOT);
    }
}
