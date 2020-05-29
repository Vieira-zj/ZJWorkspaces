#!/bin/bash
set -eu

table="flat_tld_header"
output_f="output.txt"
token="1b1f0216-0828-4da0-9c43-14262b8d4f9c"

list_tables() {
  local limit=200
  curl -v -H "X-Prophet-Workspace-Id: 67" --cookie "User-Token=${token}" \
    "http://172.25.203.34:40121/telamon/v1/tableGroups/tables?prn=kfc-hive%2F${table}.table-group&offset=0&limit=${limit}" | \
    jq . | grep prn | grep _20205 | awk -F '"' '{print $4}' | \
    awk -F '/' '{print $NF}' | uniq | sort > ${output_f}
}


delete_table() {
  while read line; do
    echo "delete table: $line"
    curl -v -XDELETE -H "X-Prophet-Workspace-Id: 67" --cookie "User-Token=${token}" \
      "http://172.25.203.34:40121/telamon/v1/tables?prn=kfc-hive%2F${table}.table-group%2F${line}"
  done < $output_f
}


if [[ $1 == 'list' ]]; then
  list_tables
fi

if [[ $1 == 'del' ]]; then
  delete_table
fi

echo "done."