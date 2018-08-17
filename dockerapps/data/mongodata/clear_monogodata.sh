#!/bin/bash
set -e

for dir in $(ls | grep -E "^mongo"); do
  echo "mongo data dir be clear ${dir}"
  rm -rf ${dir}/*
done

set +e
