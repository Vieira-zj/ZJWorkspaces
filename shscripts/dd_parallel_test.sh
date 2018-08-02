#!/bin/bash
set -ex

cur_path=$(pwd)
if [ -f $cur_path/logfile ]; then
  echo "" > $cur_path/logfile
fi

# print rw throughput
for (( i = 0; i < 10; i++ )); do
  if [ $1 == "write" ]; then
    dd if=/dev/zero of=1Gfile_write_4M_no$i bs=4M count=2 oflag=direct 2>&1 \
      | grep "MB/s" | awk -F "," '{print $3}' | sed 's/MB\/s//' >> logfile &
  fi

  if [ $1 == "read" ]; then
    dd if=1Gfile of=/dev/null bs=4M count=2 iflag=direct 2>&1 \
      | grep "MB/s" | awk -F "," '{print $3}' | sed 's/MB\/s//' >> logfile &
  fi 
done

# get total throughput for all rw
file_size=`ls -l logfile | awk '{print $5}'`
while [ $file_size -lt 500 ]; do
  sleep 5
  file_size=`ls -l logfile | awk '{print $5}'`
done

sleep 10
echo "total: " >> logfile
cat logfile | awk '{sum+=$1} END {print sum}' >> logfile

set +ex
