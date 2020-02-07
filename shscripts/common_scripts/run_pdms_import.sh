#!/bin/bash
set -u

count=30
time_log="time.log"
pdms_log="pdms_import.log"

function pdms_import() {
  (time sh azkaban_pdms/execute-pdms-import.sh "PHApp_Recommend" "aie_phapp_recommend" "ph-lc-checkin_tmp_online_content_ai_20191021201855" "tmp_online_content_ai" "update_time" "+0" "tencent" "" >> $pdms_log) >> $time_log 2>&1
}


# clear
echo "" > $pdms_log
echo "" > $time_log

echo "pdms import Start."
for ((i=1; i<=${count}; i++)); do
  echo "----------------------------" >> $time_log
  echo "iterator $i" >> $time_log 
  pdms_import
  echo "" >> $time_log
  sleep 120
done
echo "pdms import Done."

set +u
