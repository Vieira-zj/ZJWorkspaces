#!/bin/bash
set -eu

cp /tmp/nginx/cicd-mockserver.conf /etc/nginx/conf.d
nginx -t
nginx -s reload

echo "nginx init DONE."
