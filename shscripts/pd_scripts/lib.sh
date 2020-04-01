#!/usr/bin/env bash

# set to project root dir
PWD=$(cd `dirname $0`; pwd)
CWD="$PWD/.."
bindir="$CWD/tools"

source "${CWD}/bin/load_configs.sh"

function detectSwap() {
    local host=$1
    local user=$2
    echo "detectSwap $host"

    local swapline=($($ssh ${user}@${host} 'grep -i swaptotal /proc/meminfo'))
    if [[ "${swapline[1]}" -gt "0" ]]; then
        $ssh ${user}@${host} 'swapoff -a'
        $ssh ${user}@${host} 'chmod +x /etc/rc.local'
        $ssh ${user}@${host} 'echo "swapoff -a" >> /etc/rc.local'
    fi
}

function detectForward() {
    local host=$1
    local user=$2
    local key
    local operator
    local value
    local sysline=($($ssh ${user}@${host} "sysctl -a 2>/dev/null | grep '^net.ipv4.ip_forward\s'"))

    echo "detectForward $host"
    if [[ "${sysline[2]}" -ne "1" ]]; then
        $ssh ${user}@${host} 'echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf'
        $ssh ${user}@${host} 'echo "net.ipv4.tcp_tw_recycle = 0" >> /etc/sysctl.conf'
        $ssh ${user}@${host} 'sysctl -p 1>/dev/null 2>&1' || :
    fi
    $ssh ${user}@${host} "sysctl -a 2>/dev/null | grep ipv4 | grep '\.forwarding'" | while read key operator value
    do
        if [[ "${value}" -ne "1" ]]; then
            $ssh ${user}@${host} -n "echo ${key} = 1 >> /etc/sysctl.conf"
            $ssh ${user}@${host} -n 'sysctl -p 1>/dev/null 2>&1' || :
        fi
    done
}

function preCheckDockerEnv() {
    local currentDir=$(pwd)
    local scriptDir=$( cd "$(dirname "$0")" ; pwd -P )

    local host=$1
    local user=$2
    local pass="yes"

    echo "preCheckDockerEnv $host"
    librarys=("libltdl.so.7" "libseccomp.so.2")
    rarToRpm=("libtool-ltdl" "libseccomp")
    rm -f .ld.so.cache
    $ssh ${user}@${host} 'ldconfig'
    $ssh ${user}@${host} 'ldconfig -p' > .ld.so.cache

    # check library
    for ((i=0;i<${#librarys[*]};i++)); do
        grep ${librarys[$i]} -q .ld.so.cache || pass="no"

        if [[ ${pass:-} == "no" ]]; then
            $scp ${bindir}/rpm/${rarToRpm[$i]}*.rpm ${user}@${host}:/tmp
            $ssh ${user}@${host} "rpm -i /tmp/${rarToRpm[$i]}*.rpm"
            pass="yes"
        fi
    done
}

function stopFirewalldSelinux() {
    local host=$1
    local user=$2
    echo "stopFirewalldSelinux $host"
    echo "systemctl stop firewalld" | $ssh ${user}@${host} || :
    echo "systemctl disable firewalld" | $ssh ${user}@${host} || :
    $ssh ${user}@${host} 'sestatus' | grep -q disabled || $ssh ${user}@${host} 'setenforce 0; echo setenfoce 0 >> /etc/rc.local; chmod +x /etc/rc.local' || :

}

function otherDirectChange() {
    echo "otherDirectChange $host"
    echo "echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled"|$ssh ${user}@${host}
    $ssh ${user}@${host} 'grep -v ^[[:blank:]]*# /etc/rc.local | grep -q 4paradigm_never_hugepage_enabled || printf "echo \047never\047 > /sys/kernel/mm/transparent_hugepage/enabled #4paradigm_never_hugepage_enabled\n" >> /etc/rc.local'
    echo "echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag"|$ssh ${user}@${host}
    $ssh ${user}@${host} 'grep -v ^[[:blank:]]*# /etc/rc.local | grep -q 4paradigm_never_hugepage_defrag || printf "echo \047never\047 > /sys/kernel/mm/transparent_hugepage/defrag #4paradigm_never_hugepage_defrag\n" >> /etc/rc.local'

    $ssh ${user}@${host} "sysctl -a 2>/dev/null | grep fs.inotify.max_user_instances" | while read key operator value
    do
        if [[ "${value}" -lt "8192" ]]; then
            $ssh -n ${user}@${host} "echo ${key} = 8192 >> /etc/sysctl.conf"
            $ssh -n ${user}@${host} 'sysctl -p 1>/dev/null 2>&1' || :
        fi
    done

    $ssh ${user}@${host} "sysctl -a 2>/dev/null | grep fs.inotify.max_user_watches" | while read key operator value
    do
        if [[ "${value}" -lt "1048576" ]]; then
            $ssh -n ${user}@${host} "echo ${key} = 1048576 >> /etc/sysctl.conf"
            $ssh -n ${user}@${host} 'sysctl -p 1>/dev/null 2>&1' || :
        fi
    done
}

function init_config_arp() {
    local host=$1
    local user=$2

    $ssh ${user}@${host} "echo 1024 > /proc/sys/net/ipv4/neigh/default/gc_thresh1 " || :
    $ssh ${user}@${host} "echo 2048 > /proc/sys/net/ipv4/neigh/default/gc_thresh2 " || :
    $ssh ${user}@${host} "echo 4096 > /proc/sys/net/ipv4/neigh/default/gc_thresh3 " || :

    [[ `cat /etc/sysctl.conf | grep gc_thresh1 | wc -l` -eq 0 ]] && echo "net.ipv4.neigh.default.gc_thresh1=1024" >> /etc/sysctl.conf || :
    [[ `cat /etc/sysctl.conf | grep gc_thresh2 | wc -l` -eq 0 ]] && echo "net.ipv4.neigh.default.gc_thresh2=2048" >> /etc/sysctl.conf || :
    [[ `cat /etc/sysctl.conf | grep gc_thresh3 | wc -l` -eq 0 ]] && echo "net.ipv4.neigh.default.gc_thresh3=4096" >> /etc/sysctl.conf || :
}

function detectPortRange() {
    local host=$1
    local user=$2
    echo "detectPortRange $host"
    local sysline=($($ssh ${user}@${host} "sysctl -a 2>/dev/null | grep '^net.ipv4.ip_local_port_range\s'"))
    if [[ "${sysline[2]}" -ne "32768" ]] || [[ "${sysline[3]}" -ne "60999" ]]; then
        $ssh ${user}@${host} 'echo "net.ipv4.ip_local_port_range = 32768 60999"  >> /etc/sysctl.conf'
        $ssh ${user}@${host} 'sysctl -p 1>/dev/null 2>&1' || :
    fi
}
