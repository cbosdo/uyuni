/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */

package com.redhat.rhn.frontend.nav;

import com.suse.manager.plugin.NavMenuExtensionPoint;
import com.suse.manager.plugin.PluginService;

import org.apache.log4j.Logger;
import org.pf4j.PluginManager;

import java.net.URL;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * NavCache, a simple cache that will prevent us from reparsing the
 * same nav xml file over and over.  Operates 'dumbly' right now,
 * which is to basically cache a given lookup forever.
 *
 * @version $Rev$
 */

public class NavCache {
    private static final Logger LOG = Logger.getLogger(NavCache.class);

    // the cache itself; a nice, happy, synchronized map
    private static Map<URL, NavTree> cache = Collections
            .synchronizedMap(new HashMap<URL, NavTree>());

    /** Private constructor, this is a utility cass  */
    private NavCache() {
    }

    /**
     * Returns a tree for the given URL, constructing it if necessary.
     * @param url URL whose section of the tree is desired.
     * @return tree for the given URL
     * @throws Exception if an error occurs building the tree.
     */
    public static NavTree getTree(URL url) throws Exception {
        NavTree ret = cache.get(url);

        if (ret != null) {
            return ret;
        }

        ret = NavDigester.buildTree(url);

        PluginManager pluginManager = PluginService.getPluginManager();
        List<NavMenuExtensionPoint> extensions = pluginManager.getExtensions(NavMenuExtensionPoint.class);
        for (NavMenuExtensionPoint extension : extensions) {
            Map<String, List<NavNode>> nodes = extension.getNodes(ret.getLabel());
            for (Map.Entry<String, List<NavNode>> entry : nodes.entrySet()) {
                String key = entry.getKey();
                String[] parents = key != null && !key.isEmpty() ? key.split("/") : new String[0];

                NavTreeItem treeItem = ret;
                for (String parent : parents) {
                    NavNode node = treeItem.getNodes().stream()
                        .filter(child -> child.getName().equals(parent))
                        .findFirst()
                        .orElse(null);
                    if (node == null) {
                        LOG.error("Failed to add extension menu entries to " + entry.getKey());
                        treeItem = null;
                        break;
                    }
                    treeItem = node;
                }
                if (treeItem != null) {
                    for (NavNode toAdd : entry.getValue()) {
                        treeItem.addNode(toAdd);
                    }
                }
            };
        }

        cache.put(url, ret);

        return ret;
    }
}
