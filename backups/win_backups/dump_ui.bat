@echo off

set screencap_path=/sdcard/window_capture.png
set dump_path=/sdcard/window_dump.xml
set userhome=C:\Users\zhengjin\Desktop\

adb shell screencap -p %screencap_path%
adb pull %screencap_path% %userhome%
adb shell rm %screencap_path%

adb shell uiautomator dump
adb pull %dump_path% %userhome%window_dump.uix
adb shell rm %dump_path%

echo "dump ui done."
