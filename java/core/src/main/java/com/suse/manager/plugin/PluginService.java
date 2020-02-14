package com.suse.manager.plugin;

import org.apache.log4j.Logger;
import org.pf4j.DefaultPluginManager;
import org.pf4j.PluginManager;

import java.io.File;
import java.util.stream.Collectors;

/**
 * Singleton class handling plugins
 */
public class PluginService {

    private static final Logger LOG = Logger.getLogger(PluginService.class);

    private static PluginManager pluginManager;

    /**
     * @return the plugin manager instance
     */
    public static PluginManager getPluginManager() {
        if (pluginManager == null) {
            // TODO Path should be configurable
            pluginManager = new DefaultPluginManager(new File("/usr/share/susemanager/extensions").toPath());
            pluginManager.loadPlugins();
            pluginManager.startPlugins();

            LOG.info("Loaded plugins: " + String.join(", ",
                    pluginManager.getPlugins().stream()
                        .map(plugin -> plugin.getPluginId())
                        .collect(Collectors.toList())));
        }
        return pluginManager;
    }

    private PluginService() {
    }
}
