/**
 * Copyright (c) 2009--2017 Red Hat, Inc.
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
package com.redhat.rhn.taskomatic.task.repomd;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.frontend.dto.PackageCapabilityDto;
import com.redhat.rhn.frontend.dto.PackageDto;
import com.redhat.rhn.manager.task.TaskManager;
import com.redhat.rhn.taskomatic.task.TaskConstants;

import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;

import java.io.BufferedWriter;
import java.io.Closeable;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Collection;
import java.util.zip.GZIPOutputStream;

/**
 *
 * @version $Rev $
 *
 */
public class DebPackageWriter implements Closeable {

    private static Logger log = Logger.getLogger(DebPackageWriter.class);
    private String filenamePackages = "";
    private String channelLabel = "";
    private BufferedWriter out;
    /**
     *
     * @param channel debian channel
     * @param prefix path to repository
     */
    public DebPackageWriter(Channel channel, String prefix) {
        log.debug("DebPackageWriter created");
        try {
            channelLabel = channel.getLabel();
            filenamePackages = prefix + "Packages";
            File f = new File(filenamePackages);
            if (f.exists()) {
                f.delete();
            }
            f.createNewFile();
        }
        catch (Exception e) {
            log.error("Create file Packages failed " + e.toString());
        }
    }

    /**
     * Begin writing Packages file
     * @param channel the channel
     * @throws IOException in case of IO errors
     */
    public void begin(Channel channel) throws IOException {
        out = new BufferedWriter(new FileWriter(
                filenamePackages, true));
    }

    /**
     * add package info to Packages file in repository
     *
     * @param pkgDto package object
     * @throws IOException in case of IO erro
     */
    public void addPackage(PackageDto pkgDto) throws IOException {
        String packageName = pkgDto.getName();
        out.write("Package: ");
        out.write(packageName);
        out.newLine();

        out.write("Version: ");
        String epoch = pkgDto.getEpoch();
        if (epoch != null && !epoch.equalsIgnoreCase("")) {
            out.write(epoch + ":");
        }
        out.write(pkgDto.getVersion());
        String release = pkgDto.getRelease();
        if (release != null && !release.equalsIgnoreCase("X")) {
            out.write("-" + release);
        }
        out.newLine();

        out.write("Architecture: ");
        out.write(pkgDto.getArchLabel().replace("-deb", ""));
        out.newLine();

        out.write("Maintainer: ");
        out.write(pkgDto.getVendor());
        out.newLine();

        Long packagePayloadSize = pkgDto.getPayloadSize();
        if (packagePayloadSize > 0) {
            out.write("Installed-Size: ");
            out.write(pkgDto.getPayloadSize().toString());
            out.newLine();
        }

        // dependencies
        addPackageDepData(
                out,
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_PROVIDES,
                pkgDto.getId(), "Provides");
        addPackageDepData(
                out,
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_REQUIRES,
                pkgDto.getId(), "Depends");
        addPackageDepData(
                out,
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_CONFLICTS,
                pkgDto.getId(), "Conflicts");
        addPackageDepData(
                out,
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_OBSOLETES,
                pkgDto.getId(), "Replaces");
        addPackageDepData(
                out,
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_SUGGESTS,
                pkgDto.getId(), "Suggests");
        addPackageDepData(
                out,
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_RECOMMENDS,
                pkgDto.getId(), "Recommends");
        addPackageDepData(
                out,
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_PREDEPENDS,
                pkgDto.getId(), "Pre-Depends");
        addPackageDepData(
                out,
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_BREAKS,
                pkgDto.getId(), "Breaks");

        out.write("Filename: " + channelLabel + "/getPackage/");
        out.write(pkgDto.getName() + "_");
        if (epoch != null && !epoch.equalsIgnoreCase("")) {
            out.write(epoch + ":");
        }
        out.write(pkgDto.getVersion() + "-" + pkgDto.getRelease());
        out.write("." + pkgDto.getArchLabel() + ".deb");
        out.newLine();

        // size of package, is checked by apt
        out.write("Size: ");
        out.write(pkgDto.getPackageSize().toString());
        out.newLine();

        // at least one checksum is required by apt
        if (pkgDto.getChecksumType().equalsIgnoreCase("md5")) {
            out.write("MD5sum: ");
            out.write(pkgDto.getChecksum());
            out.newLine();
        }

        if (pkgDto.getChecksumType().equalsIgnoreCase("sha1")) {
            out.write("SHA1: ");
            out.write(pkgDto.getChecksum());
            out.newLine();
        }

        if (pkgDto.getChecksumType().equalsIgnoreCase("sha256")) {
            out.write("SHA256: ");
            out.write(pkgDto.getChecksum());
            out.newLine();
        }

        out.write("Section: ");
        out.write(pkgDto.getPackageGroupName());
        out.newLine();

        if (pkgDto.getExtraTags() != null) {
            for (var entry : pkgDto.getExtraTags().entrySet()) {
                out.write(entry.getKey());
                out.write(": ");
                out.write(entry.getValue());
                out.newLine();
            }
        }

        out.write("Description: ");
        out.write(pkgDto.getDescription());
        out.newLine();

        // new line after package metadata
        out.newLine();
    }

    /**
     * @param outIn
     *
     * @param query
     *            query to get dependencies
     * @param pkgId
     *            package Id to set
     * @param dep
     *            dependency info
     */
    private void addPackageDepData(BufferedWriter outIn, String query,
            Long pkgId, String dep) {
        int count = 0;
        Collection<PackageCapabilityDto> capabilities = TaskManager
                .getPackageCapabilityDtos(pkgId, query);
        int icapcount = capabilities.size();
        String[] names = new String[icapcount];
        String[] versions = new String[icapcount];
        String[] senses = new String[icapcount];
        try {
            for (PackageCapabilityDto capability : capabilities) {
                if (count == 0) {
                    outIn.write(dep + ": ");
                }

                count++;
                int iordernumber = Integer.parseInt(capability.getName().substring(
                                                capability.getName().indexOf("_") + 1));
                names[iordernumber] = capability.getName().substring(
                                                0, capability.getName().indexOf("_"));
                versions[iordernumber] = capability.getVersion();
                senses[iordernumber] = getSenseAsString(capability.getSense());
            }

            for (int iIndex = 0; iIndex < names.length; iIndex++) {
                if (iIndex != 0) {
                    outIn.write(", ");
                }
                outIn.write(names[iIndex]);
                if (versions[iIndex] != null && !versions[iIndex].isEmpty()) {
                    outIn.write(" (");
                    if (senses[iIndex] != null) {
                        outIn.write(senses[iIndex] + " ");
                    }
                    outIn.write(versions[iIndex]);
                    outIn.write(")");
                }
            }
        }
        catch (Exception e) {
            log.error("failed to write DEB dependency " + dep + " " + e.toString());
        }
        try {
            if (count > 0) {
                outIn.newLine();
            }
        }
        catch (Exception e) {
            log.error("failed to write new line " + e.toString());
        }

    }

    /**
     * @param senseIn package sense
     * @return a human readable representation of the sense
     */
    private String getSenseAsString(long senseIn) {
        long sense = senseIn & 0xf;
        if (sense == 2) {
            return "<<";
        }
        else if (sense == 4) {
            return ">>";
        }
        else if (sense == 8) {
            return "=";
        }
        else if (sense == 10) {
            return "<=";
        }
        else if (sense == 12) {
            return ">=";
        }
        else { // 0
            return null;
        }
    }

    /**
     * Create Packages.gz from Packages
     */
    public void generatePackagesGz() {
        // Create the GZIP output stream
        String outFilename = filenamePackages + ".gz";
        try (GZIPOutputStream outGz = new GZIPOutputStream(new FileOutputStream(
                outFilename, false))) {

            // Open the input file
            FileInputStream in = new FileInputStream(filenamePackages);

            // Transfer bytes from the input file to the GZIP output stream
            byte[] buf = new byte[1024];
            int len;
            while ((len = in.read(buf)) > 0) {
                outGz.write(buf, 0, len);
            }
            in.close();

            // Complete the GZIP file
            outGz.finish();
        }
        catch (IOException e) {
            log.error("Failed to create Packages.gz " + e.toString());
        }
    }

    /**
     * Finish writing the Package file.
     */
    @Override
    public void close() {
        IOUtils.closeQuietly(out);
    }
}
