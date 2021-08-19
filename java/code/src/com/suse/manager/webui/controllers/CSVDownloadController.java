/**
 * Copyright (c) 2018 SUSE LLC
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

package com.suse.manager.webui.controllers;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.taglibs.list.CSVTag;
import com.suse.manager.reactor.utils.LocalDateTimeISOAdapter;
import com.suse.manager.reactor.utils.OptionalTypeAdapterFactory;
import com.suse.manager.webui.utils.gson.ResultJson;
import com.redhat.rhn.common.util.CSVWriter;
import com.redhat.rhn.frontend.action.CSVDownloadAction;
import java.util.Arrays;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import org.apache.log4j.Logger;
import org.cobbler.Network;

import spark.Request;
import spark.Response;

import java.io.*;
import java.net.*;
import javax.servlet.http.HttpSession;
import com.redhat.rhn.frontend.taglibs.IconTag;
import com.redhat.rhn.common.localization.LocalizationService;

import java.time.LocalDateTime;
import java.util.Date;

import static com.suse.manager.webui.utils.SparkApplicationHelper.json;
import static com.suse.manager.webui.utils.SparkApplicationHelper.withUser;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import static spark.Spark.get;
import static spark.Spark.post;
import com.redhat.rhn.common.db.datasource.Elaborator;

/**
 * Controller class providing backend code for CSV downloads.
 */
public class CSVDownloadController {

    public static final String CSV_DOWNLOAD_URI = "/rhn/CSVDownloadAction.do";

    /** Logger */
    private static final Logger LOG = Logger.getLogger(CSVDownloadController.class);

    private static final Gson GSON = new GsonBuilder()
            .registerTypeAdapter(LocalDateTime.class, new LocalDateTimeISOAdapter())
            .registerTypeAdapterFactory(new OptionalTypeAdapterFactory()).serializeNulls().create();

    private CSVDownloadController() {
    }

    /**
     * Invoked from Router. Initialize routes for CSV downloads
     */
    public static void initRoutes() {
        post("/manager/systems/CSV/virtualSystemsList", withUser(CSVDownloadController::virtualSystemsCSV));
    }

    /**
     * CSVRequest
     */
    static class CSVRequest {
        private final String columns;
        private final String pageData;

        CSVRequest(String columnsIn, String pageDataIn) {
            this.columns = columnsIn;
            this.pageData = pageDataIn;
        }

        public String getColumns() {
            return columns;
        }

        public String getPageData() {
            return pageData;
        }
    }

    /**
     * Download virtual systems list CSV
     *
     * @param request  the http request
     * @param response the http response
     * @param user     the user
     * @return the json response
     */
    public static String virtualSystemsCSV(Request request, Response response, User user) {
        // retrieving data from request
        CSVRequest csvRequest = GSON.fromJson(request.body(), CSVRequest.class);
        String columns = csvRequest.getColumns();
        String data = csvRequest.getPageData();
        String header = "virtual Systems List";

        // write data to csv file using csvWriter
        CSVWriter csvWriterObj = new CSVWriter(new StringWriter());
        csvWriterObj.setColumns(Arrays.asList(columns));
        csvWriterObj.setHeaderText(header);
        csvWriterObj.writeHeader();
        try {
            csvWriterObj.write(Arrays.asList(data));
        } catch (Exception e) {
            System.out.println("err" + e);
        }

        String uniqueNumber = TagHelper.generateUniqueName("virtualList");
        String page = (CSV_DOWNLOAD_URI + "?" + CSVDownloadAction.EXPORT_COLUMNS + "=" + columns + "_" + uniqueNumber
                + "&" + CSVDownloadAction.QUERY_DATA + "=query_" + uniqueNumber + "&" + CSVDownloadAction.UNIQUE_NAME
                + "=" + uniqueNumber);

        // send a request to url
        try {
            URL url = new URL(page);
            HttpURLConnection huc = (HttpURLConnection) url.openConnection();
            huc.disconnect();
        } catch (Exception e) {
            System.out.println(e);
        }

    return json(GSON, response, ResultJson.success());
    }
}
