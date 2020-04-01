#!/bin/bash
set -e

openresty -t
echo "openresty test pass, and reload."
openresty -s reload
echo "openresty reload done."
