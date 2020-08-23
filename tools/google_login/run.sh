# Create at 20200823
# 1. Start chrome with remote debug port
# 2. Attach webdriver to existing chrome instance by debug port
#
# Refer to:
# https://superuser.com/questions/157484/start-google-chrome-on-mac-with-command-line-switches
# https://medium.com/@harith.sankalpa/connect-selenium-driver-to-an-existing-chrome-browser-instance-41435b67affd
#
# run example:
# sh run.sh "https://confluence.shopee.io/pages/viewpage.action?pageId=183808563" "17890"

#!/bin/bash
set -eu

url=$1
port=$2

chrome_path="/Applications/Google Chrome.app/Contents/MacOS/"
if [[ ! -d ${chrome_path} ]]; then
    echo "chrome app not found at ${chrome_path}!"
    exit 99
fi

cd "${chrome_path}"
./Google\ Chrome --remote-debugging-port=${port} &
sleep 1 # wait for chrome start

cd -
python ./login_and_get_cookies.py ${url} ${port}
echo "Done"
