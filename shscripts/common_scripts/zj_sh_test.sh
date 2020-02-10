#!/bin/bash
set -eu

# ex1-1, sub str
function sub_str_test() {
  local tmp_str="hello world"
  echo "sub str: ${tmp_str:0:5}"
  echo "length: ${#tmp_str}"  
}


# ex1-2, str compare
function str_compare_test() {
  local value1="zhengjin.test"
  local value2="zhengjin.test1"
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
}


# ex1-3, calculation
function calculate_test() {
  local count=1000
  local min=10
  local cur=30
  local count=$(($cur*$count/$min))
  echo "current count: $count"
}


# ex2, trim last char
func_trim_last_char() {
    local input1=$1
    local len=${#input1}
    local end=$((len-1))
    echo ${input1:0:${end}}
}


# ex3, >&2
# ls -l ~/.bash_profile ~/not_exist.file > ${HOME}/Downloads/tmp_files/test.out 2>&1


# ex4, read file
read_lines_fn1() {
    local sum=1
    cat $1 | while read line; do
        echo "output line ${sum}: ${line}"
        sum=$((sum+1))
    done
}

read_lines_fn2() {
    local file="$1"
    while IFS='=' read -r key value; do
        echo "${key}=${value}"
    done < "$file"
}

read_lines_fn3() {
    local file="$1"
    cat "$file" | while IFS='=' read -r key value; do
        echo "${key}=${value}"
    done
}


# ex5, loop in shell
function loop_test() {
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
}


function iterator_test() {
  local tmp_values="v1/k1 v2/k1 v1/k2 v1/k3"
  for value in ${tmp_values}; do
    echo "value: $(echo $value | awk -F '/' '{print $2}')"
  done

  local tmp_array1=("v1" "v2" "v3")
  echo "array length: ${#tmp_array1[*]}"
  for value in ${tmp_array1[*]}; do
    echo "array value: ${value}" 
  done

  local tmp_array2=("val4" "val5" "val6")
  echo "arrays values => "
  for value in ${tmp_array1[*]} ${tmp_array2[*]}; do
      echo "array value: ${value}" 
  done

  for file in $(find $HOME/Downloads/tmp_files/ -name "*.zip" -type f); do
    echo "text file: ${file}"
    echo "file stat: $(stat ${file})"
  done
}


# ex6-1, awk test
function awk_if_test() {
  local test_file=${HOME}/Downloads/tmp_files/test.out
  echo '01|b6' > $test_file
  local lines=('02|b6' '03|b7' '04|b6')
  for line in ${lines[*]}; do
    echo $line >> $test_file 
  done

  echo "grade b6:"
  cat ${test_file} | awk -F '|' '{if($2=="b6") {print "id: " $1}}'
}

function awk_script_test() {
    set -x
    local test_file=${HOME}/Downloads/tmp_files/test.out
    echo '01|b6' > $test_file
    local lines=('02|b6' '03|b7' '04|b6' '05|b7' '06|b8')
    for line in ${lines[*]}; do
      echo $line >> $test_file 
    done

    cat ${test_file} | awk -F '|' '{if ($2=="b6") c1++; if($2=="b7") c2++; if($2=="b8") c3++;} END{print "b6: " c1 "\nb7: " c2 "\nb8: " c3;}'
    set +x
}


# ex6-2, awk test
# get total files size in dir
function awk_test_01() {
  local input_path=$1
  ls -l $input_path | awk 'BEGIN{sum=0} !/^d/{sum+=$5} END{print "files total size is:",int(sum/1024),"KB"}'
}

# get files count for each user
function awk_test_02() {
  local input_path=$1
  ls -l $input_path | awk 'NR!=1 && !/^d/{sum[$3]++} END{for (user in sum) printf "%-6s %-5s %-3s \n",user," ",sum[user]}'
}


# ex7, default value
set_arg_default() {
  set +u

  local input1=$1
  echo "var input1 with default: ${input1:=default}"
  echo "var input1 changed to: ${input1}"

  local input2=$2
  echo "var input2 with default: ${input2:-default}"
  echo "var input2 unchanged: ${input2}"

  set -u
}


# ex8, alias check in sub-shell
alias_build() {
  shopt -s expand_aliases
  shopt expand_aliases
  alias jv='java -version'
  # jv  command not found
}


# ex9-1, return int from func
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


# ex9-2, return value from func
function my_prefix() {
  echo "custom_prefix_$1"
}

function ret_value_check() {
  local prefix_val=$(my_prefix "shelltest")
  echo "prefix value: ${prefix_val}"
}


# ex10-1, var scope
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
function readonly_var_fn() {
  readonly readonly_var="init"
  echo "read only var: $readonly_var"
  # readonly_var="changed"
}


# ex11, file not exist
function is_file_not_exist() {
  local path=$1
  echo "check path: ${path}"
  if [[ ! -f $path ]]; then
    echo "path (${path}) not exist!"
  fi
}


# ex12, while loop for number
function while_loop_test() {
  local num=$1
  while [[ $num -ne 0 ]]; do
    echo "number: ${num}"
    ((num = num - 1))
    sleep 1
  done
  echo "while loop done."
}


# main
function main() {
  echo ""
  echo "main process:"

  # calculate_test

  # ret=$(func_trim_last_char "testt")
  # echo "trim last char results: ${ret}"

  # file="${HOME}/Downloads/tmp_files/test.out"
  # if [ -f "$file" ]; then
  #     echo "$file found and read."
  #     read_lines_fn1 $file
  #     #read_lines_fn2 "$file"
  #     #read_lines_fn3 "$file"
  # else
  #     echo "$file not found."
  # fi

  # awk_if_test
  # awk_script_test

  # awk_test_01 $HOME/Downloads/tmp_files
  # awk_test_02 $HOME/Downloads/tmp_files

  # set_arg_default test
  # set_arg_default

  # alias_build
  # alias
  # type jv
  # jv

  #process_check 'sublime'

  # ret_value_check
  # readonly_var_fn
  #is_file_not_exist /tmp/target_jar
  while_loop_test 3
}
main

set +eu
