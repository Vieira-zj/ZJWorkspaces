#!/bin/bash
set -u

if [[ $1 == "jar" ]]; then
  mvn clean package -Dmaven.test.skip=true
  exit 0
fi

paths=""
for jar in $(ls lib); do
  paths="${paths}:lib/${jar}"
done
paths="target/kp-0.0.1-SNAPSHOT-jar-with-dependencies.jar${paths}"


function hive_weak_load() {
  local workspaceId="2"
  local hiveDbname="aie"
  local hiveTable="supply_product"
  local targetPRN="testuser/hdfs_copy_zj_tbx1.table"

  local main="com.yumc.kp.HiveWeakLoad"
  local cmd="java -cp ${paths} ${main} $workspaceId $hiveDbname $hiveTable $targetPRN"
  echo "run cmd: ${cmd}"
  ${cmd}
}


function hdfs_weak_load() {
  local workspaceId="1"
  local url="hdfs://nameservice1/kpdev/ks/workspace/test/telamon/5/test/zj-tb-bank01_table/part-r-00001.gz.parquet"
  local prn="test/hdfs_weak_copy_group01.table-group/hdfs_weak_copy_tb5.table"

  local main="com.yumc.kp.HDFSWeakLoad"
  local cmd="java -cp ${paths} ${main} $workspaceId $url $prn" 
  echo "run cmd: ${cmd}"
  ${cmd}
}


function hdfs_load() {
  local workspaceId="67"
  local url="/kp/ks/workspace/leap_kfcpreorder/kpt1-kafka-history/kfc-tradeup-logging_1585807300971-1585807543309_table/"
  local prn="HyperCycle_ML/kpt2_sample-log_20200424111645.table-group/test-kfc-tradeup-logging_1585807300971-1585807543309.table"

  local main="com.yumc.kp.HDFSLoad"
  local cmd="java -cp ${paths} ${main} $workspaceId $url $prn"
  echo "run cmd: ${cmd}"
  ${cmd}
}


function batch_hdfs_load() {
  local hdfs_dir="/kp/ks/workspace/leap_kfcpreorder/kpt1-kafka-history"
  # all_parquet_files=$(hdfs dfs -ls -R ${hdfs_dir} | grep parquet | awk '{print $8}')
  for hdfs_file in $(hdfs dfs -ls ${hdfs_dir} | awk '{print $8}'); do
    local filename=$(echo "${hdfs_file}" | awk -F "/" '{print $7}')
    local tbname=${filename/_table/.table}

    local workspaceId="67"
    local url=${hdfs_file}
    local group="HyperCycle_ML/kpt1_sample-log_20200424104841.table-group"
    local prn="${group}/test-${tbname}"

    echo "load file ${hdfs_file} to ${prn}"
    local main="com.yumc.kp.HDFSLoad"
    local cmd="java -cp ${paths} ${main} $workspaceId $url $prn"
    #echo $cmd
    ${cmd}

    if [[ $? -ne 0 ]]; then
      echo "hdfs load failed and reload"
      sleep 3
      ${cmd}
    fi
    # break # for test
  done
}


is_test="0"
loadTablesFile="./load_tables.txt"

function prepare() {
  #hdfs_dir="/kp/ks/workspace/leap_kfcpreorder/kfc-hive-tmpdata/kfc_recsys_tradeup_city_recall_daily"
  local hdfs_dir=$1
  hdfs dfs -ls ${hdfs_dir} | awk '{print $8}' > ${loadTablesFile}
  if [[ ${is_test} == "1" ]]; then
    hdfs dfs -ls ${hdfs_dir} | awk '{print $8}' | head -n 2 > ${loadTablesFile}
  fi
}


function batch_hdfs_load2() {
  local workspaceId="67"
  #groupPrn="kfc-hive/kfc_recsys_tradeup_city_recall_daily.table-group"
  local groupPrn=$1
  local thread_num=$2

  local main="com.yumc.kp.HDFSBatchLoad"
  local cmd="java -cp ${paths} ${main} $workspaceId $groupPrn $loadTablesFile $thread_num"
  #echo "run cmd: ${cmd}"
  ${cmd}
}

function hdfs_load_all() {
  local tbs_str="flat_tld_header_tmp|kfc_recsys_tradeup_stats_daily_tmp|kfc_recsys_tradeup_city_recall_daily_tmp|kfc_recsys_tradeup_user_recall_daily_tmp|recsys_fusion_tradeup_product_parquet_tmp|recsys_fusion_recommend_filter_list_parquet_tmp|recsys_fusion_recommend_filter_parquet_tmp|recsys_fusion_store_product_linkids_parquet_tmp"
  local sp_tb_str="recsys_fusion_proxylog_tradeup_shoppingcart_itemlinkids_parquet_tmp"

  local hdfs_paths=$(hdfs dfs -ls /kp/ks/workspace/leap_kfcpreorder/kfc-hive-tmpdata/ | grep -v 'Found' | awk '{print $NF}')
  if [[ ${is_test} == "1" ]]; then
    hdfs_paths=$(hdfs dfs -ls /kp/ks/workspace/leap_kfcpreorder/kfc-hive-tmpdata/ | head -n 2 | grep -v 'Found' | awk '{print $NF}')
  fi

  for hdfs_p in $hdfs_paths; do
    prepare $hdfs_p
    local table=$(echo $hdfs_p | awk -F '/' '{print $NF}')
    if [[ $tbs =~ $table ]]; then
      table=${table/_tmp/}
      table=${table/_parquet/}
    fi
    if [[ $table == "$sp_tb_str" ]]; then
      table=${table/_parquet/}
    fi
    for ((i=1; i>=3; i--)); do
      echo "batch hdfs load: kfc-hive/${table}.table-group $i"
      batch_hdfs_load2 kfc-hive/${table}.table-group $i
      sleep 3
    done
  done
}


if [[ $1 == "hive" ]]; then
  hive_weak_load
elif [[ $1 == "hdfs" ]]; then
  hdfs_load
  #hdfs_weak_load
elif [[ $1 == "pre" ]]; then
  prepare
elif [[ $1 == "batch" ]]; then
  batch_hdfs_load
else [[ $1 == "all" ]]
  hdfs_load_all
fi

echo "run kp-sdk done."
