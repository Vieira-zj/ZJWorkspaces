#!/bin/bash
set -ex

src_file="filex1G.test"
echo "" > logfile # clear log
dd if=/dev/zero of=${src_file} bs=4M count=256 oflag=direct 2>> logfile

out_file="file.test.out"
for ((i=0; i<3; i++));do
  echo "dd test at iterator $i"
  dd if=${src_file} of=${out_file}${i} bs=1M count=512 oflag=direct 2>> logfile
  cur_time=`date +"%Y-%m-%d,%H-%M-%S"`
  echo "${cur_time}: dd test done at iterator $i" > ${out_file}${i}
done

echo "dd test done."

set +ex
