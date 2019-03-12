#!/bin/bash
set -eu

# ex1-1, sub str
tmp_str="hello world"
echo "sub str: ${tmp_str:0:5}"
echo "length: ${#tmp_str}"


# ex1-2, str compare
value1="zhengjin.test"
value2="zhengjin.test1"
if [ "$value1" = "$value2" ]; then
    echo "values equal."
else
    echo "values not equal."
fi

if [[ "$value1" == "$value2" ]]; then
    echo "values equal."
else
    echo "values not equal."
fi


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

for file in $(find $HOME/Downloads/tmp_files/ -name "*.zip" -type f); do
   echo "text file: ${file}"
   echo "file stat: $(stat ${file})"
done


# ex6, awk test
awk_if_test() {
    test_file=${HOME}/Downloads/tmp_files/test.out
    echo '01|b6' > $test_file 
    echo '02|b6' >> $test_file 
    echo '03|b7' >> $test_file 
    echo '04|b6' >> $test_file 

    echo "grade b6:"
    cat ${test_file} | awk -F '|' '{if($2=="b6") {print "id: " $1}}'
}
#awk_if_test

awk_script_test() {
    set -x
    test_file=${HOME}/Downloads/tmp_files/test.out
    echo '01|b6' > $test_file 
    echo '02|b6' >> $test_file 
    echo '03|b7' >> $test_file 
    echo '04|b6' >> $test_file 
    echo '05|b7' >> $test_file 
    echo '06|b8' >> $test_file

    cat ${test_file} | awk -F '|' '{if ($2=="b6") c1++; if($2=="b7") c2++; if($2=="b8") c3++;} END{print "b6: " c1 "\nb7: " c2 "\nb8: " c3;}'
}
awk_script_test


# ex7, default value
set_arg_default() {
  set +u

  input1=$1
  echo "var input1 with default: ${input1:=default}"
  echo "var input1 changed to: ${input1}"

  input2=$2
  echo "var input2 with default: ${input2:-default}"
  echo "var input2 unchanged: ${input2}"

  set -u
}
set_arg_default test
set_arg_default


set +exu
