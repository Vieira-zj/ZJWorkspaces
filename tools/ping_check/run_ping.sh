#!/bin/bash
set -eu

count=30
output="ping.log"
ip="127.0.0.1"

cat /dev/null > ${output}
ping -c ${count} ${ip} | awk '{print $7}' | awk -F "=" '{print $2}' > ${output}

python ping_parse.py ${output}

echo "ping check done."
