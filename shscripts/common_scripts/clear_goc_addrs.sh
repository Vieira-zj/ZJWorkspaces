#!/bin/bash
set -eu

server_name='is-topup-server'
center_addr='http://goccenter.airpay-qa-testdev.i.test.airpay.in.th'
# goc='/home/ld-sgdev/jin_zheng/bins/goc'

function goc_list_addrs {
    goc list --center=${center_addr} | jq .
}

function goc_remove_addrs {
    local tmp_file='output.txt'

    # note: jq cannot parse char "-"
    local target=$(echo ${server_name} | sed 's/-//g')
    goc list --center=${center_addr} | jq . | tee ${tmp_file}
    local addrs=$(sed 's/-//g' ${tmp_file} | jq ".${target}" | grep http)

    echo -e '\n\nStart remove addr:'
    for addr in ${addrs}; do
        local l_addr=$(echo ${addr} | sed 's/,//g')
        local cmd="goc remove --center=${center_addr} --address=${l_addr}"
        echo "${cmd}"
        # ${cmd}
    done
    rm ${tmp_file}
}

function clear_unused_addrs {
    local items=$(goc list --center=${center_addr} |sed 's/{//g' |sed 's/}//g' |awk -F ',' '{for (i=1; i <= NF; i++) print $i;}')
    for item in ${items}; do
        name=$(echo $item |awk -F ':' '{print $1}' |sed 's/"//g')
        echo "check service ${name}"
        count=$(kubectl get pods -A |grep ${name} |wc -l)
        if [[ ${count} -eq 0 ]]; then
            echo "remove service ${name} from goccenter"
            goc remove --center=${center_addr} --service=${name}
        fi
    done
}

goc_list_addrs
# goc_remove_addrs
# clear_unused_addrs

echo "Done"