#!/bin/bash
set -x
# run from /Users/zhengjin/Workspaces/qbox/kodo

GOBIN="$(pwd)/bin"
source $QBOXROOT/kodo/env.sh
source $QBOXROOT/base/env.sh

# build all
#make

# build app
bin_dir="${HOME}/Downloads/tmp_files/bin"
bin_name="bucketmigrate"
bin_file="${bin_dir}/${bin_name}"

#GOOS=linux GOARCH=amd64 go build qiniu.com/kodo/io/app/qboxio
#GOOS=linux GOARCH=amd64 go build qiniu.com/kodo/kfile/app/qboxkfile

#GOOS=linux GOARCH=amd64 go build -o ${bin_file} qiniu.com/kodo/tools/bucketmigrate
go build -o ${bin_file} qiniu.com/kodo/tools/bucketmigrate

set +x

