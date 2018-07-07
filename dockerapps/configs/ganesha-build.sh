#!/bin/bash
set -x -e

# build release
target="target_release"
cd /home/nfs-ganesha
git submodule update --init
mkdir $target && cd $target
cmake -DCMAKE_BUILD_TYPE=Release  -DBUILD_CONFIG=kfile_only ../src/
make
cd - && ./build/package.sh $target
mv ganesha.tar.gz ganesha.release.tar.gz

# build debug
target="target_debug"
cd /home/nfs-ganesha
mkdir $target && cd $target
cmake -DCMAKE_BUILD_TYPE=Debug  -DBUILD_CONFIG=kfile_only ../src/
make
cd - && ./build/package.sh $target
mv ganesha.tar.gz ganesha.debug.tar.gz

# build package
tar czvf ganesha.tar.gz ganesha.debug.tar.gz ganesha.release.tar.gz

set +x +e
