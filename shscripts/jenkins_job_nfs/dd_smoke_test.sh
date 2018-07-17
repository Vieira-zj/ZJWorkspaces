#!/bin/bash
set -ex

error=`mount | grep nfs | wc -l`
if [ ${error} -eq 0 ]; then
  mount -t nfs -o vers=3,nolock,rsize=1048576,wsize=1048576 10.200.20.57:/data /mnt/zjnfstest/nfstest
fi

logfile=logfile
outfile=/mnt/zjnfstest/nfstest/test.file

starttime=`date +'%Y-%m-%d %H:%M:%S'`
startsec=$(date --date="$starttime" +%s)

# dd write
dd if=/dev/zero of=${outfile} bs=1M count=1024 oflag=direct > ${logfile} 2>&1 &

filesize=`ls -l ${logfile} | awk '{ print $5 }'`
while [ ${filesize} -eq 0 ]; do # check log file size
  # echo "log file size: ${filesize}"
  sleep 3
  filesize=`ls -l ${logfile} | awk '{ print $5 }'`

  endtime=`date +'%Y-%m-%d %H:%M:%S'`
  endsec=$(date --date="$endtime" +%s)
  duration=$((endsec-startsec))
  echo "run time: ${duration}s"
  if [ ${duration} -gt 300 ]; then
    echo "dd timeout."
    exit 99
  fi
done

filesize=`ls -l ${outfile} | awk '{ print $5 }'`
if [ ${filesize} -eq 1073741824 ]; then # check dd out file size = 1G
  echo "dd write test pass."
  exit 0
fi

echo "dd write test failed."
exit 99

set +ex
