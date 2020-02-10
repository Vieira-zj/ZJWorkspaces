#!/bin/bash
set -u

count=3
time_log="time.log"
pdms_log="pdms_import.log"

function pdms_import() {
  local group=$1
  local table=$2
  echo "import for $group:$table" >> $time_log
  (time sh azkaban_pdms/execute-pdms-import.sh "PHApp_Recommend" "aie_phapp_recommend" $group $table  "update_time" "+0" "tencent" "" >> $pdms_log) >> $time_log 2>&1
  echo "" >> $time_log
}

function pdms_import_all() {
  for line in $(cat ./group_tables.txt | grep -v "#"); do
    group=$(echo $line | awk -F ',' '{print $1}')
    table=$(echo $line | awk -F ',' '{print $2}')
    pdms_import $group $table &
  done

  local num=1
  while [[ $num -ne 0 ]]; do
    num=$(ps -ef | grep "pdms-import" | grep -v "grep" | wc -l)
    echo "wait for all pdms imports($num) done."
    sleep 30
  done
}


# clear
echo "" > $pdms_log
echo "" > $time_log

echo "pdms import Start."
for ((i=1; i<=${count}; i++)); do
  echo "----------------------------" >> $time_log
  echo "iterator $i" >> $time_log
  pdms_import_all
  sleep 300
done
echo "pdms imports Done."

set +u