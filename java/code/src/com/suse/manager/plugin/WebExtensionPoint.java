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

import org.pf4j.ExtensionPoint;

import java.io.IOException;
import java.io.Reader;

import spark.template.jade.JadeTemplateEngine;


/**
 * Interface to implement to provide Web UI extensions
 */
public interface WebExtensionPoint extends ExtensionPoint {

    /**
     * Add routes to the Spark Application routing table.
     *
     * @param jade Jade template engine to use to render to pages
     */
    void addRoutes(JadeTemplateEngine jade);

    /**
     * @param name the template name to look for
     * @param encoding the encoding of the template
     *
     * @return the reader for the template or <code>null</code> if the extension
     *         doesn't provide such a jade template.
     *
     * @throws IOException if anything bad happens when reading the file
     */
    Reader getTemplate(String name, String encoding) throws IOException;
}
