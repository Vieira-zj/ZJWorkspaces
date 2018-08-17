#!/bin/bash
set -x -e

# GINKGO
# ginkgo <FLAGS> <PACKAGES> -- <PASS-THROUGHS>
# Run the tests in the passed in <PACKAGES> (or the package in the current directory if left blank).
# Any arguments after -- will be passed to the test.

# -p, Run in parallel with auto-detected number of nodes.
# -r, Find and run test suites under the current directory recursively.
# -keepGoing, When true, failures from earlier test suites do not prevent later test suites from running.
# -pkgdir string, install and load all packages from the given dir instead of the usual locations.
# -skipPackage string, A comma-separated list of package names to be skipped. If any part of the package's path matches, that package is ignored.

# ginkgo build <FLAGS> <PACKAGES>
# Build the passed in <PACKAGES> (or the package in the current directory if left blank).

# -a, Force rebuilding of packages that are already up-to-date.


# COMPILE TEST BIN
# build bin for package
# testbin="io"
# GOOS=linux GOARCH=amd64 ginkgo build biz/${testbin} # err: permission denied
# cd biz/zj/;GOOS=linux go test -c -o ${testbin}.test

# Calling package.test directly will run the tests in series. 
# To run the tests in parallel you'll need the ginkgo cli to orchestrate the parallel nodes. You can run:
# ginkgo -p path/to/package.test


# BUILD FULL QTEST BIN
# => /qbox/qtest/qtestbin/README.md
# local
# export TESTCONFINFO="product.z0.conf"
# export TESTGOOS="linux"
# bash qtestbin/mkqtestbin.sh

# tar -zcvf qtestbin.tar.gz qtestbin
# scp -r qtestbin.tar.gz qboxserver@10.200.20.21:~/zhengjin/

# remote
# tar -zxvf qtestbin.tar.gz
# cd qtest && source env.sh
# export TEST_ENV=product
# export TEST_ZONE=z0
# cd biz/init; ./init.test -ginkgo.v
# cd biz/io; ./io.test -ginkgo.v -ginkgo.skip="admin|memcached|!z2"|tee io.txt
# cd biz/io; ./zj.test -ginkgo.v -ginkgo.focus="xxxxx"


# RUN TEST CASE, $./runtests.sh smoke
run_cmd="-focus=xxxxx biz/zj"
if [ $1 ]; then
    run_cmd="-focus=xxxxx biz/$1"
    if [[ ($1 =~ "smoke") ]]; then
        run_cmd="-focus=smoke biz/zj"
    fi
    if [[ ($1 =~ "bucket") ]]; then
        run_cmd="-focus=xxxxx biz/bucket/$2"
    fi
    if [[ ($1 =~ "ui") ]]; then
        run_cmd="-focus=xxxxx portalv4"
    fi
fi
ginkgo -v ${run_cmd}

# ginkgo -v -focus="xxxxx" biz/init
# ginkgo -v -focus="xxxxx" biz/up
# ginkgo -v -focus="xxxxx" biz/io
# ginkgo -v -focus="xxxxx" biz/qiniuproxy
# ginkgo -v -focus="xxxxx" biz/rs
# ginkgo -v -focus="xxxxx" biz/rsf
# ginkgo -v -focus="xxxxx" biz/bucket/uc
# ginkgo -v -focus="xxxxx" biz/bucket/tblmgr
# ginkgo -v -focus="xxxxx" biz/bucket/domain
# ginkgo -v -focus="xxxxx" biz/kmq
# ginkgo -v -focus="xxxxx" biz/confg
# ginkgo -v -focus="xxxxx" biz/pfd
# ginkgo -v -focus="xxxxx" biz/ebd
# ginkgo -v -focus="xxxxx" biz/bdlocker
# ginkgo -v -focus="xxxxx" biz/ufop
# ginkgo -v -focus="xxxxx" biz/nuproxy
# ginkgo -v -focus="xxxxx" biz/acc
# ginkgo -v -focus="xxxxx" biz/blob
# ginkgo -v -focus="xxxxx" biz/rocksdb
# ginkgo -v -focus="xxxxx" biz/specalfunc

# spock
# ginkgo -v -focus="NewSpockSetUp" src/qiniu.com/qtest/manual
# ginkgo -v -focus="xxxxx" src/qiniu.com/qtest/manual

# zj test
# ginkgo -v -focus="xxxxx" biz/zj


set +x +e # set config x off
