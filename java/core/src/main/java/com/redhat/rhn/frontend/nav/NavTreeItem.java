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
package com.redhat.rhn.frontend.nav;

import java.util.List;

public interface NavTreeItem {

    /**
     * Adds a node to the tree
     *
     * @param n node added to tree
    */
    public void addNode(NavNode n);

    /**
     * Gets the top-level nodes associated with the tree
     * @return List of the nodes
     */
    public List<NavNode> getNodes();

    /**
     * Gets the current value of label
     * @return String the current value
     */
    public String getLabel();

    /**
     * Sets the value of label to new value
     * @param labelIn New value for label
     */
    public void setLabel(String labelIn);
}
