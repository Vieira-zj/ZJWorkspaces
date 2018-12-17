#!/bin/bash
set -ex

# ex1, sub str
tmp_str="hello world"
echo "sub str: ${tmp_str:0:5}"
echo "length: ${#tmp_str}"


# ex2, trim last char
func_trim_last_char() {
    input1=$1
    len=${#input1}
    end=$((len-1))
    echo ${input1:0:${end}}
}

ret=$(func_trim_last_char "testt")
echo "trim last char results: ${ret}"


# ex3, >&2
ls -l ~/.bash_profile ~/not_exist.file >${HOME}/Downloads/tmp_files/test.out 2>&1


set +ex
