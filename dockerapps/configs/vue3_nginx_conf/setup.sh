#!/bin/bash
set -ue

cp ./*.conf /etc/nginx/conf.d/
openresty -t
openresty -s reload

echo "nginx setup done."