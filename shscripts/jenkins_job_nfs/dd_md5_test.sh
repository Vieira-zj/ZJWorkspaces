#!/bin/bash
set -ex

if [ -f logfile ]; then
  echo "" > logfile
fi

src_file_name="file1G.test"
if [ ! -f $src_file_name ]; then
  echo "source file not exist and create: $src_file_name"
  dd if=/dev/zero of=${src_file_name} bs=4M count=8 oflag=direct 2>&1
fi
exp_md5_val=`cat ${src_file_name} | md5sum | awk '{print $1}'`

for (( i = 0; i < 2; i++ )); do
  echo "at iterator $i:" >> logfile
  file_name=1Gfile_write_4M_no$i
  # create file
  #dd if=/dev/zero of=$file_name bs=4M count=8 oflag=direct 2>&1 >> logfile
  # copy file
  cp $src_file_name $file_name

  # verify md5
  md5_val=`cat $file_name | md5sum | awk '{print $1}'`
  echo "md5 value: $md5_val" >> logfile
  if [ $md5_val == $exp_md5_val ]; then
    echo "verify results: Pass" >> logfile
  else
    echo "verify results: Failed" >> logfile
  fi
done

set +ex
