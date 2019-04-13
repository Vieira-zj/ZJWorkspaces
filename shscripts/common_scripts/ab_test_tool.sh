#!/bin/bash
set -u

# 执行3轮，每轮请求次数为1000, 并发数为3
# cmd: ./ab_test_tool.sh -U "http://localhost:17891/index" -N 1000 -C 3 -R 3
# 并发数每次递增10, 从10递增到50, 同时请求数按比例递增
# cmd: ./ab_test_tool.sh -U "http://localhost:17891/index" -N 1000 -R 1 -I 10 -X 50 -J 10

function show_headers() {
  echo '*===================================================*'
  echo '| 本脚本工具基于ab(Apache benchmark), 请先安装好ab, awk |'
  echo '| 注意： |' 
  echo '| shell默认最大客户端数为1024 |'
  echo '| 如超出此限制，请执行以下命令： |'
  echo '| ulimit -n 655350 |'
  echo '*===================================================*'
}
show_headers

function usage() {
  echo ' 命令格式：'
  echo ' ab-test.sh'
  echo ' -N: count 总请求数，缺省：5w'
  echo ' -C: clients 并发数，缺省：100'
  echo ' -R: rounds 测试次数，缺省：10次'
  echo ' -S: sleeptime 间隔时间，缺省：10秒'
  echo ' -I: min 最小并发数，缺省：0'
  echo ' -X: max 最大并发数，缺省：0'
  echo ' -J: step 次递增并发数'
  echo ' -T: runtime 总体运行时间，设置此项时最大请求数为5w'
  echo ' -P: postfile post数据文件路径'
  echo ' -U: url 测试地址'
  echo ''
  echo ' 测试输出结果*.out文件'
  exit 0
}

# 定义默认参数量
# 测试地址
url=''
# 总请求数
count=10000
# 并发数
clients=3
# 测试限制时间
runtime=''
# 传输数据
postfile=''
# 测试轮数
rounds=1
# 间隔时间
sleeptime=1
# 最小并发数
min=0
# 最大数发数
max=0
# 并发递增数
step=0

# 入参处理
ARGS=`getopt N:C:R:S:I:X:J:U:T:P:h "$*"`
if [ $? -ne 0 ]; then
  usage
fi

set -- ${ARGS}
for i; do
  case "$1" in
    -N)
      count="$2"
      shift 2;;
    -C)
      clients="$2"
      shift 2;;
    -R)
      rounds="$2"
      shift 2;;
    -S)
      sleeptime="$2"
      shift 2;;
    -I)
      min="$2"
      shift 2;;
    -X)
      max="$2"
      shift 2;;
    -J)
      step="$2"
      shift 2;;
    -U)
      url="$2"
      shift 2;;
    -T)
      runtime="$2"
      shift 2;;
    -P)
      postfile="$2"
      shift 2;;
    -h)
      usage
      shift 2;;
    --)
      shift; break;;
  esac
done

# 参数检查
if [ -z $url ]; then
  echo '请输入测试url, 非文件/以为结束'
  exit 1
fi

function show_args() {
  echo '-----------------------------'
  echo '测试参数'
  echo " 测试地址：$url"
  echo " 总请求数：$count"
  echo " 并发数：$clients"
  echo " 重复次数：$rounds 次"
  echo " 间隔时间：$sleeptime 秒"
  if [ $min != 0 ];then
    echo " 最小并发数：$min"
  fi
  if [ $max != 0 ];then
    echo " 最大并发数：$max"
  fi
  if [ $step != 0 ];then
    echo " 每轮并发递增：$step"
  fi
}
show_args

# 指定输出文件名
datestr=`date +%Y%m%d%H%I%S`
outfile="ab_test_out_$datestr.log"

# 生成ab命令
cmd="ab -k -r"
# -k : Enable the HTTP KeepAlive feature, perform multiple requests within one HTTP session.
# -r : Don't exit on socket receive errors.

function build_ab_cmd() {
  if [[ $runtime != "" && $runtime > 0 ]]; then
    cmd="$cmd -t $runtime"
  fi
  if [[ $postfile != "" ]]; then
    cmd="$cmd -p $postfile"
  fi
}
build_ab_cmd

function is_run_by_steps() {
  if [ $min != 0 -a $max != 0 ]; then 
    if [ $max -lt $min ]; then
      echo '最大并发数不能小于最小并发数'
      return 1
    fi
    if [ $step -lt 0 ]; then
      echo '并发递增步长不能<0'
      return 1
    fi
    return 0
  fi
  return 1
}

# run_ab_test $cmd $outfile $rounds $sleeptime
function run_ab_test() {
  run_cmd=$1
  run_outfile=$2
  run_rounds=$3
  run_sleep=$4

  # 输出命令
  echo "";
  echo ' 当前执行命令：'
  echo " $run_cmd"
  echo '------------------------------'

  # 开始执行测试
  cnt=1
  while [ $cnt -le $run_rounds ]; do
    echo "第 $cnt 轮 开始"
    $cmd >> $run_outfile
    echo "" >> $run_outfile
    echo "第 $cnt 轮 结束"
    echo '----------------------------'
    cnt=$(($cnt+1))
    echo "等待 $sleeptime 秒"
    sleep $sleeptime
  done
}

function run_test() {
  is_run_by_steps
  if [[ $? == 0 ]]; then
    temp=$cmd;
    cur=$min
    base=$(($count/$min))
    while [ $cur -le $max ]; do
      count=$(($cur*$base))
      cmd="$temp -n $count -c $cur $url"
      run_ab_test "$cmd" "$outfile" "$rounds" "$sleeptime"
      cur=$(($cur+$step))
    done
  else
    cmd="$cmd -n $count -c $clients $url"
    run_ab_test "$cmd" "$outfile" "$rounds" "$sleeptime"
  fi  
}
run_test

# 分析结果
function results_parse() {
  if [ -f $outfile ]; then
    echo '本次测试结果如下：'
    echo '+------+----------+----------+------------+-----------+--------------+-----------------+--------------+---------------+-------------+'
    echo '| 序号 | 总请求数 | 并发数   | 失败请求数 | 吞吐量(s) | 响应时间(ms) | 90%响应时间(ms) | 处理时间(ms) | 流量 (k/sec) | 传输总量 (k) |'
    echo '+------+----------+----------+------------+-----------+--------------+-----------------+--------------+---------------+-------------+'
    comp=(`awk '/Complete requests/ {print $NF}' $outfile`) 
    concur=(`awk '/Concurrency Level/ {print $NF}' $outfile`)
    fail=(`awk '/Failed requests/ {print $NF}' $outfile`)
    qps=(`awk '/Requests per second/ {print $4F}' $outfile`)
    tpr=(`awk '/Time per request.*\(mean\)/ {print $4F}' $outfile`)
    tpr_90=(`awk '/90%/ {print $2F}' $outfile`)
    tpr_c=(`awk '/Time per request.*\(mean,/ {print $4F}' $outfile`)
    trate=(`awk '/Transfer rate/ {print $3F}' $outfile`)
    tbytes=(`awk '/Total transferred/ {print int($3/1024)}' $outfile`)

    for ((i=0; i<${#comp[@]}; i++)); do
      echo -n "|"
      printf '%6s' $(($i+1)) 
      printf "|"
      printf '%10s' ${comp[i]}
      printf '|'
      printf '%10s' ${concur[i]}
      printf '|'
      printf '%12s' ${fail[i]}
      printf '|'
      printf '%11s' ${qps[i]}
      printf '|'
      printf '%14s' ${tpr[i]}
      printf '|'
      printf '%17s' ${tpr_90[i]}
      printf '|'
      printf '%14s' ${tpr_c[i]}
      printf '|'
      printf '%15s' ${trate[i]}
      printf '|'
      printf '%13s' ${tbytes[i]}
      printf '|'
      echo '';
      echo '+------+----------+----------+------------+-----------+--------------+-----------------+--------------+---------------+-------------+'
    done
    echo ''
  fi
}
results_parse

set +u