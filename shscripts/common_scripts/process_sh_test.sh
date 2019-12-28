#!/bin/bash
set -u

function run_with_series() {
  start=$(date "+%s")  

  for ((i=1; i<=4; i++)); do
    echo "success";sleep 2
  done  

  end=$(date "+%s")
  echo "TIME: $(expr ${end} - ${start})"
}
# run_with_series

function run_with_parallel() {
  start=$(date "+%s")  

  for ((i=1; i<=4; i++)); do
  	{
      echo "success";sleep 2
  	} &
  done  

  wait
  end=$(date "+%s")
  echo "TIME: $(expr ${end} - ${start})"
}
run_with_parallel
