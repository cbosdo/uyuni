/**
 * Copyright (c) 2020 SUSE LLC
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
package com.suse.manager.plugin;

import com.redhat.rhn.frontend.nav.NavNode;

import org.pf4j.ExtensionPoint;

import java.util.List;
import java.util.Map;


/**
 * Interface to implement to add custom entries in the navigation menus.
 */
public interface NavMenuExtensionPoint extends ExtensionPoint {

    /**
     * Get the list of entries to add to a navigation menu.
     *
     * The returned tree nodes are mapped using the parent tree item path. This means
     * that:
     * <ul>
     *   <li>to add a top tab the key will need to be the empty string</li>
     *   <li>to add an entry in "Tab One" > "Subtab One", the key will need to be
     *       <code>Level One/Subtab One</code></li>
     * </ul>
     * @param menu the menu tree label
     *
     * @return the map of nodes for the requested menu
     */
    public Map<String, List<NavNode>> getNodes(String menu);
}
