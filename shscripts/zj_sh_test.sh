#!/bin/bash
set -eu

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


# ex5, loop in shell 
for int_val in {1..10}; do
  echo "int value: ${int_val}"
done

for ((i=0;i<10;i++)); do
  echo "current value: $i"
done

tmp_values="v1/k1 v2/k1 v1/k2 v1/k3"
for value in ${tmp_values}; do
    echo "value: $(echo $value | awk -F '/' '{print $2}')"
done

tmp_array=(v1 v2 v3)
echo "array length: ${#tmp_array[*]}"
for value in ${tmp_array[*]}; do
    echo "array value: ${value}"
done

for file in $(find $HOME/Downloads/tmp_files/ -name "*.txt" -type f); do
   echo "text file: ${file}"
   echo "file stat: $(stat ${file})"
done


# ex6, awk test
awk_if_test() {
    set -x
    test_file=${HOME}/Downloads/tmp_files/test.out
    echo '01|b6' > $test_file 
    echo '02|b6' >> $test_file 
    echo '03|b7' >> $test_file 
    echo '04|b6' >> $test_file 

    echo "grade b6:"
    cat ${test_file} | awk -F '|' '{if($2=="b6") {print "id: " $1}}'
}

awk_if_test


set +exu
