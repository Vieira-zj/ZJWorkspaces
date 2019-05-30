#!/bin/bash
set -eu

# ex1-1, sub str
echo ""
echo "example1-1"

tmp_str="hello world"
echo "sub str: ${tmp_str:0:5}"
echo "length: ${#tmp_str}"


# ex1-2, str compare
echo ""
echo "example1-2"

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


# ex1-3, calculation
function calculate_test() {
  count=1000
  min=10
  cur=30
  count=$(($cur*$count/$min))
  echo "current count: $count"
}
calculate_test

# ex2, trim last char
echo ""
echo "example2"

func_trim_last_char() {
    input1=$1
    len=${#input1}
    end=$((len-1))
    echo ${input1:0:${end}}
}

ret=$(func_trim_last_char "testt")
echo "trim last char results: ${ret}"


# ex3, >&2
# ls -l ~/.bash_profile ~/not_exist.file > ${HOME}/Downloads/tmp_files/test.out 2>&1


# ex4, read file
echo ""
echo "example4"

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
echo ""
echo "example5"

for int_val in {1..5}; do
  echo -n "int_value=${int_val},"
done
echo ""

for seq_val in $(seq 5); do
  echo -n "seq_value=${seq_val},"
done
echo ""

for ((i=0;i<5;i++)); do
  echo -n "current_i=$i,"
done
echo ""

awk 'BEGIN{total=0; for(i=0;i<=10;i++){total+=i}; print "awk total: " total;}'


tmp_values="v1/k1 v2/k1 v1/k2 v1/k3"
for value in ${tmp_values}; do
  echo "value: $(echo $value | awk -F '/' '{print $2}')"
done

tmp_array1=("v1" "v2" "v3")
echo "array length: ${#tmp_array1[*]}"
for value in ${tmp_array1[*]}; do
  echo "array value: ${value}" 
done

tmp_array2=("val4" "val5" "val6")
echo "arrays values => "
for value in ${tmp_array1[*]} ${tmp_array2[*]}; do
    echo "array value: ${value}" 
done


for file in $(find $HOME/Downloads/tmp_files/ -name "*.zip" -type f); do
   echo "text file: ${file}"
   echo "file stat: $(stat ${file})"
done


# ex6-1, awk test
echo ""
echo "example6-1"

function awk_if_test() {
  test_file=${HOME}/Downloads/tmp_files/test.out
  echo '01|b6' > $test_file
  lines=('02|b6' '03|b7' '04|b6')
  for line in ${lines[*]}; do
    echo $line >> $test_file 
  done

  echo "grade b6:"
  cat ${test_file} | awk -F '|' '{if($2=="b6") {print "id: " $1}}'
}
#awk_if_test

function awk_script_test() {
    set -x
    test_file=${HOME}/Downloads/tmp_files/test.out
    echo '01|b6' > $test_file
    lines=('02|b6' '03|b7' '04|b6' '05|b7' '06|b8')
    for line in ${lines[*]}; do
      echo $line >> $test_file 
    done

    cat ${test_file} | awk -F '|' '{if ($2=="b6") c1++; if($2=="b7") c2++; if($2=="b8") c3++;} END{print "b6: " c1 "\nb7: " c2 "\nb8: " c3;}'
    set +x
}
awk_script_test


# ex6-2, awk test
echo ""
echo "example6-2"

# get total files size in dir
function awk_test_01() {
  input_path=$1
  ls -l $input_path | awk 'BEGIN{sum=0} !/^d/{sum+=$5} END{print "files total size is:",int(sum/1024),"KB"}'
}
#awk_test_01 $HOME/Downloads/tmp_files

# get files count for each user
function awk_test_02() {
  input_path=$1
  ls -l $input_path | awk 'NR!=1 && !/^d/{sum[$3]++} END{for (user in sum) printf "%-6s %-5s %-3s \n",user," ",sum[user]}'
}
awk_test_02 $HOME/Downloads/tmp_files


# ex7, default value
echo ""
echo "example7"

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


# ex8, alias check in sub-shell
echo ""
echo "example8"

alias_build() {
  shopt -s expand_aliases
  shopt expand_aliases
  alias jv='java -version'
  # jv  command not found
}
alias_build
alias
type jv
jv


# ex9-1, return int from func
echo ""
echo "example9-1"

is_process_exist() {
  pid=$(ps -ef | grep -i $1 | grep -v "grep" | awk '{print $2}' | head -n 1)
  if [ -z "$pid" ]; then
    pid="null"
    return 1
  else
    return 0
  fi
}

process_check() {
  is_process_exist $1
  if [[ $? == 0 ]]; then
    echo "process '$1' is running, pid=${pid}."
  else
    echo "process '$1' is not running, pid=${pid}."
  fi  
}
process_check 'sublime'


# ex9-2, return value from func
echo ""
echo "example9-2"

function my_prefix() {
  echo "custom_prefix_$1"
}

function ret_value_check() {
  prefix_val=$(my_prefix "shelltest")
  echo "prefix value: ${prefix_val}"
}
ret_value_check


# ex10-1, var scope
echo ""
echo "example10-1"

g_var="global_var"
local_var_scope() {
  fun_var="var_in_func"
  local l_var="local_var"

  echo "global var: $g_var"
  echo "function var: $fun_var"
  echo "local var: $l_var"

  for iter_i in {1..5}; do
    echo -n "i=$iter_i,"
  done
  echo ""
  echo "iter i: $iter_i"
}
# echo "main, function var: $fun_var"
local_var_scope


# ex10-2, readonly var
echo ""
echo "example10-2"
function readonly_var_fn() {
    readonly readonly_var="init"
    echo "read only var: $readonly_var"
    # readonly_var="changed"
}
readonly_var_fn


set +eu
