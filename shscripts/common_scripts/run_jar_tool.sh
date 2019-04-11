#!/bin/bash

export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_144.jdk/Contents/Home"
export JRE_HOME=/$JAVA_HOME/jre
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin

export LOG4J_PATH="$HOME/Workspaces/mvn_repository/log4j/log4j/1.2.17/log4j-1.2.17.jar"

root_dir="$HOME/Downloads/tmp_files"
jar_file="maven-project-0.0.1-SNAPSHOT.jar"
java_main="com.zjmvn.demo.App"

if [[ $2 != "" ]]; then
    jar_file=$2
fi
if [[ $3 != "" ]]; then
    java_main=$3
fi

usage() {
    echo "Usage: sh test.sh [start|stop|restart|status] [jar_file] [main_func]"
    exit 0
}

is_exist() {
    pid=$(ps -ef | grep -i "${jar_file}" | grep -v "grep" | awk '{print $2}')
    if [ -z "${pid}" ]; then  # pid not exist
        pid="null"
        return 1
    else
        return 0
    fi
}

start() {
    is_exist
    if [[ $? == 0 ]]; then
        echo "${jar_file} is already running. pid=${pid}."
    else
        nohup java -cp "$root_dir/$jar_file:$LOG4J_PATH:$CLASSPATH" ${java_main} > test.out 2>&1 &
    fi
}

stop() {
    is_exist
    if [[ $? == "0" ]]; then
        kill $pid
    else
        echo "${jar_file} is not running."
    fi
}

status() {
    is_exist
    if [[ $? == "0" ]]; then
        echo "${jar_file} is running. Pid is ${pid}."
    else
        echo "${jar_file} is NOT running."
    fi
}

restart() {
    stop
    sleep 5
    start
}

case "$1" in
    "start")
        start
        ;;
    "stop")
        stop
        ;;
    "status")
        status
        ;;
    "restart")
        restart
        ;;
    *)
        usage
        ;;
esac

# end
