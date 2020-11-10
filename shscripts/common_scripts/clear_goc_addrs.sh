#!/bin/bash
set -eu

server_name='is-topup-server'
center_addr='http://goccenter.airpay-qa-testdev.i.test.airpay.in.th'

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

# goc_list_addrs
goc_remove_addrs

echo "done"