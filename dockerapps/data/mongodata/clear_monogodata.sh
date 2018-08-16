#!/bin/bash
set -e

for dir in $(ls | grep -E "^mongo"); do
  echo "dir to be remove ${dir}"
  rm -rf ${dir}/*
done

set +e
