import * as React from "react";
import { useState, useEffect } from "react";
import Network from "utils/network";
import * as Systems from "components/systems";
import { Utils } from "utils/functions";
import { Table } from "components/table/Table";
import { Column } from "components/table/Column";
import { IconTag } from "components/icontag";
import { SearchField } from "components/table/SearchField";

// See java/code/src/com/suse/manager/webui/templates/systems/virtual-list.jade
type Props = {
  /** Locale of the help links */
  docsLocale: string;
  isAdmin: boolean;
};

export function VirtualSystems(props: Props) {
  const [selectedSystems, setSelectedSystems] = useState([]);
  const [selectedSystemsCount, setCount] = useState(0);

  const handleSelectedSystems = (data) => {
    setSelectedSystems(data);
  };

  useEffect(()=> {
    setCount(selectedSystems.length);
    document.getElementById("header_selcount").innerHTML =
      "<span id='spacewalk-set-system_list-counter' class='badge'>" +
      selectedSystemsCount.toString() +
      "</span>" +
      (selectedSystemsCount === 1 ? "system selected" : "systems selected");
  }, [handleSelectedSystems]);

  const addToSSM = () => Network.post("/rhn/manager/systems/addToSsm", selectedSystems);

  const searchData = (datum, criteria) => {
    if (criteria) {
      return datum.name.toLocaleLowerCase().includes(criteria.toLocaleLowerCase());
    }
    return true;
  };

  return (
    <>
      <h1>
        <IconTag type="header-system" />
        {t("Virtual Systems")}
        <a
          href={`/docs/${props.docsLocale}/reference/systems/systems-list.html`}
          target="_blank"
          rel="noopener noreferrer"
        >
          <IconTag type="header-help" />
        </a>
      </h1>

      <div>
        <button className="btn btn-default" onClick={addToSSM}>
          {t("Add Selected to SSM")}
        </button>
      </div>

      <Table
        data="/rhn/manager/api/systems/list/virtual"
        identifier={(item) => item.uuid}
        initialSortColumnKey="hostServerName"
        selectable={(item) => item.hasOwnProperty("virtualSystemId")}
        selectedItems={selectedSystems}
        onSelect={handleSelectedSystems}
        initialItemsPerPage={window.userPrefPageSize}
        searchField={<SearchField filter={searchData} placeholder={t("Filter by name")} />}
        emptyText={t("No Virtual Systems.")}
      >
        <Column
          columnKey="hostServerName"
          comparator={Utils.sortByText}
          header={t("Virtual Host")}
          cell={(item) => {
            return <a href={`/rhn/systems/details/Overview.do?sid=${item.hostSystemId}`}>{item.hostServerName}</a>;
          }}
        />
        <Column
          columnKey="name"
          comparator={Utils.sortByText}
          header={t("Virtual System")}
          cell={(item) => {
            if (item.systemId != null) {
              return <a href={`/rhn/systems/details/Overview.do?sid=${item.systemId}`}>{item.name}</a>;
            }
            return item.name;
          }}
        />
        <Column
          columnKey="stateName"
          comparator={Utils.sortByText}
          header={t("Status")}
          cell={(item) => item.stateName}
        />
        <Column
          columnKey="statusType"
          comparator={Utils.sortByText}
          header={t("Updates")}
          cell={(item) => {
            if (item.statusType == null) {
              return "";
            }
            return Systems.statusDisplay(item, props.isAdmin);
          }}
        />
        <Column
          columnKey="channelLabels"
          comparator={Utils.sortByText}
          header={t("Base Software Channel")}
          cell={(item) => {
            if (item.channelId != null) {
              return <a href={`/rhn/channels/ChannelDetail.do?cid=${item.channelId}`}>{item.channelLabels}</a>;
            }
            return item.channelLabels;
          }}
        />
      </Table>

      <div className="spacewalk-csv-download">
        <a href="/rhn/manager/systems/csv/virtualSystems" className="btn btn-link" data-senna-off="true">
          <IconTag type="item-download-csv" />
          Download CSV
        </a>
      </div>
    </>
  );
}