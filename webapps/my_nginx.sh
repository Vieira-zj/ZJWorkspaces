#!/bin/bash
set -x -e

file_conf="${HOME}/Workspaces/ZJWorkspaces/webapps/nginx_c.conf"

if [[ ($1 =~ "reload") ]]; then
    nginx -s reload
    exit 0
fi

if [[ ($1 =~ "stop") ]]; then
    nginx -s stop
    exit 0
fi

# note: "test" cannot use for customized conf.
if [[ ($1 =~ "test") ]]; then
    nginx -t ${file_conf}
    exit 0
fi

nginx -v 
nginx -c ${file_conf}

set +x +e
