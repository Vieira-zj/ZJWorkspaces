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
  # args
  workspaceId="2"
  hiveDbname="aie"
  hiveTable="supply_product"
  targetPRN="testuser/hdfs_copy_zj_tbx1.table"

  main="com.yumc.kp.HiveWeakLoad"
  cmd="java -cp ${paths} ${main} $workspaceId $hiveDbname $hiveTable $targetPRN"
  echo "run cmd: ${cmd}"
  ${cmd}
}

function hdfs_weak_load() {
  # args
  workspaceId="1"
  url="hdfs://nameservice1/kpdev/ks/workspace/test/telamon/5/test/zj-tb-bank01_table/part-r-00001.gz.parquet"
  prn="test/hdfs_weak_copy_group01.table-group/hdfs_weak_copy_tb5.table"

  main="com.yumc.kp.HDFSWeakLoad"
  cmd="java -cp ${paths} ${main} $workspaceId $url $prn" 
  echo "run cmd: ${cmd}"
  ${cmd}
}

function hdfs_load() {
  # args
  workspaceId="67"
  url="/kp/ks/workspace/leap_kfcpreorder/kpt1-kafka-history/kfc-tradeup-logging_1585807300971-1585807543309_table/"
  prn="HyperCycle_ML/kpt2_sample-log_20200424111645.table-group/test-kfc-tradeup-logging_1585807300971-1585807543309.table"

  main="com.yumc.kp.HDFSLoad"
  cmd="java -cp ${paths} ${main} $workspaceId $url $prn"
  echo "run cmd: ${cmd}"
  ${cmd}
}

function batch_hdfs_load() {
  hdfs_dir="/kp/ks/workspace/leap_kfcpreorder/kpt1-kafka-history"
  # all_parquet_files=$(hdfs dfs -ls -R ${hdfs_dir} | grep parquet | awk '{print $8}')
  for hdfs_file in $(hdfs dfs -ls ${hdfs_dir} | awk '{print $8}'); do
    filename=$(echo "${hdfs_file}" | awk -F "/" '{print $7}')
    tbname=${filename/_table/.table}

    workspaceId="67"
    url=${hdfs_file}
    group="HyperCycle_ML/kpt1_sample-log_20200424104841.table-group"
    prn="${group}/test-${tbname}"

    echo "load file ${hdfs_file} to ${prn}"
    main="com.yumc.kp.HDFSLoad"
    cmd="java -cp ${paths} ${main} $workspaceId $url $prn"
    #echo $cmd
    ${cmd}

    if [[ $? -ne 0 ]]; then
      echo "hdfs load failed and reload"
      ${cmd}
    fi
    # break # for test
  done
}

if [[ $1 == "hive" ]]; then
  hive_weak_load
elif [[ $1 == "hdfs" ]]; then
  hdfs_load
  #hdfs_weak_load
else [[ $1 == "load" ]]
  batch_hdfs_load
fi

echo "run kp-sdk done."
