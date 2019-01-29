#!/bin/bash
set -exu

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
# ls -l ~/.bash_profile ~/not_exist.file >${HOME}/Downloads/tmp_files/test.out 2>&1


# ex4, read file
read_lines_fn1() {
    sum=1
    cat $1 | while read line; do
        echo "output line ${sum}: ${line}"
        sum=$((sum+1))
    done
}

read_lines_fn2() {
    file="$1"
    while IFS='=' read -r key value; do
        echo "${key}=${value}"
    done < "$file"
}

read_lines_fn3() {
    file="$1"
    cat "$file" | while IFS='=' read -r key value; do
        echo "${key}=${value}"
    done
}

file="${HOME}/Downloads/tmp_files/test.out"
if [ -f "$file" ]; then
    echo "$file found and read."
    read_lines_fn1 $file
    #read_lines_fn2 "$file"
    #read_lines_fn3 "$file"
else
    echo "$file not found."
fi


# ex5, iterator on array
tmp_array=(v1 v2 v3)
echo "array length: ${#tmp_array[*]}"
for value in ${tmp_array[*]}; do
    echo "array value: ${value}"
done

for file in $(find /Users/zhengjin/Downloads/tmp_files/ -name "*.txt" -type f); do
   echo "text file: ${file}"
   echo "file stat: $(stat ${file})"
done


set +exu
