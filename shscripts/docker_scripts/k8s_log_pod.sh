#!/bin/bash
# Usage：logpod service-name
# Example: logpod up
# qtest库的env.sh会设置DEBUG=true, 此时kubectl会输出调试信息，所以需要关闭
set -x -e

export DEBUG=
pod=$(kubectl get pod -a -n spock-public | grep -w $1 | awk '{print $1}')
kubectl logs -f $pod -c $1 -n spock-public

set +x +e

