package com.suse.manager.webui;

import com.suse.manager.plugin.PluginService;
import com.suse.manager.plugin.WebExtensionPoint;

import org.pf4j.PluginManager;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.List;

import de.neuland.jade4j.template.TemplateLoader;


/**
 * Jade template loader looking for templates in the classpath first
 * and then in the registered plugins.
 */
public class PluggableTemplateLoader implements TemplateLoader {

    private final String ENCODING = "UTF-8";

    private String templateRoot;

    /**
     * Constructor
     *
     * @param templateRootIn template root path
     */
    public PluggableTemplateLoader(String templateRootIn) {
        if (!templateRootIn.endsWith(File.separator)) {
            templateRootIn += File.separator;
        }
        templateRoot = templateRootIn;
    }

    @Override
    public Reader getReader(String name) throws IOException {
        InputStream stream = Thread.currentThread().getContextClassLoader().getResourceAsStream(templateRoot + name);
        if (stream != null) {
            return new InputStreamReader(stream, ENCODING);
        }

        PluginManager pluginManager = PluginService.getPluginManager();
        List<WebExtensionPoint> webExtensions = pluginManager.getExtensions(WebExtensionPoint.class);
        for (WebExtensionPoint webExtensionPoint : webExtensions) {
            Reader reader = webExtensionPoint.getTemplate(name, ENCODING);
            if (reader != null) {
                return reader;
            }
        }
        return null;
    }

    @Override
    public long getLastModified(String name) throws IOException {
        return -1;
    }
}
