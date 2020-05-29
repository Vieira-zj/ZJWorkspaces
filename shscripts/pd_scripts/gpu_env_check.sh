#!/bin/bash
set -eu

TARGET_DIR="/usr/cuda_files"
# rm -rf ${TARGET_DIR} || :
# mkdir -p ${TARGET_DIR}
echo "Try install cuda dependent libraries to $TARGET_DIR"

copy_cuda_files() {
    local INFRASTRUCTURE="x86-64"
    local LIBCUDA_PATH=$(ldconfig -p | grep libcuda | grep ${INFRASTRUCTURE} | awk '{print $4}' | tail -n 1)
    if [[ $LIBCUDA_PATH == "" ]]; then
        echo "Cannot find libcuda.so in your environment"
        exit 1
    else
        echo "Find libcuda at $LIBCUDA_PATH"
    fi

    LIBCUDA_DIR=$(dirname $LIBCUDA_PATH)
    echo "Copy library libcuda* from $LIBCUDA_DIR to $TARGET_DIR..."
    cp -v $LIBCUDA_DIR/libcuda* $TARGET_DIR
    echo "Copy library libnvidia* from $LIBCUDA_DIR to $TARGET_DIR..."
    cp -v $LIBCUDA_DIR/libnvidia* $TARGET_DIR
}


# 查看gpu设备
# ll /dev | grep nvidia
# nvidia-smi


gpu_container_validate() {
    echo "Validate by run basic tensorflow docker image"
    DOCKER_IMAGE="docker02:35000/operator-repository/train-tensorflow-gpu:release-3.1.2"
    DEV_MOUNT="--device /dev/nvidiactl:/dev/nvidiactl  --device /dev/nvidia-uvm:/dev/nvidia-uvm  --device /dev/nvidia0:/dev/nvidia0  -v $TARGET_DIR:/usr/cuda_files"
    TEST_COMMAND="import tensorflow; tensorflow.Session()"

    docker pull $DOCKER_IMAGE
    if [ $? -ne 0 ]; then
        echo "Fail to pull image $DOCKER_IMAGE, maybe need to login (docker02: user=testuser passwd=testpassword)"
        exit 1
    fi

    docker run --rm -it $DEV_MOUNT $DOCKER_IMAGE python -c "$TEST_COMMAND"
    if [ $? -eq 0 ]; then
        echo "Test docker image success"
    else
        echo "Test docker image failed!"
        exit 1
    fi
}

echo "Done."