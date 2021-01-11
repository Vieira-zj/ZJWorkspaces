#!/bin/bash

download_dir="${HOME}/Downloads"
rm ${download_dir}/window_*

set -e

screencap_path="/sdcard/window_capture.png"
viewtree_path="/sdcard/window_dump.xml"

adb shell screencap -p ${screencap_path}
adb pull ${screencap_path} ${download_dir}
adb shell rm ${screencap_path}

adb shell uiautomator dump
adb pull ${viewtree_path} ${download_dir}/window_dump.uix
adb shell rm ${viewtree_path}

echo "Android dump ui done."
