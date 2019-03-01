#!/bin/bash
set -eu

dir_path="${HOME}/Downloads/tmp_files"
if [ -z $dir_path ]; then
  echo "dir path is empty!"
  exit 99
fi

file_size=1 # M
if [ -z $file_size ]; then
  echo "file size is empty!"
  exit 99
fi

total_size=0
files=($(find ${dir_path} ! -type d -a -size +${file_size}M))
for file in ${files[@]}; do
  echo "file szie > 1M: $(ls -lh ${file} | awk '{print $9 "\t" $5}')"
  cur_size=$(du -k ${file} | awk '{print $1}')
  ((total_size=total_size+cur_size))
done

echo -e "file size > ${file_size}M count: ${#files[@]}, total file size: $((total_size/1024))M"

set +eu
