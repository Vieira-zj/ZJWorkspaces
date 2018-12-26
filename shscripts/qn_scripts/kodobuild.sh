#!/bin/bash
set -x
# run from /Users/zhengjin/Workspaces/qbox/kodo

GOBIN="$(pwd)/bin"
source $QBOXROOT/kodo/env.sh
source $QBOXROOT/base/env.sh

# build all
#make

# build app
#bin_dir="${HOME}/Downloads/tmp_files/bin"
#bin_name="bucketmigrate"
#bin_path="${bin_dir}/${bin_name}"

#GOOS=linux GOARCH=amd64 go build qiniu.com/kodo/io/app/qboxio
#GOOS=linux GOARCH=amd64 go build qiniu.com/kodo/kfile/app/qboxkfile

#GOOS=linux GOARCH=amd64 go build -o $GOBIN/regionstat qiniu.com/kodo/rs2/roll/app/regionstat 
#GOOS=linux GOARCH=amd64 go build -o $GOBIN/qboxftp qiniu.com/kodo/kfile/app/qboxftp

#GOOS=linux GOARCH=amd64 go build -o ${bin_path} qiniu.com/kodo/tools/${bin_name}
go build -o ${bin_path} qiniu.com/kodo/tools/${bin_name}

set +x

