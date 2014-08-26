#!/bin/bash
adb push libavcodec-55.so /mnt/sdcard/libavcodec-55.so
adb push libavformat-55.so /mnt/sdcard/libavformat-55.so
adb push libavutil-52.so /mnt/sdcard/libavutil-52.so
adb push libswresample-0.so /mnt/sdcard/libswresample-0.so
adb push libswscale-2.so /mnt/sdcard/libswscale-2.so

adb shell "su -c 'rm /system/lib/libavcodec-55.so'"
adb shell "su -c 'rm /system/lib/libavformat-55.so'"
adb shell "su -c 'rm /system/lib/libavutil-52.so'"
adb shell "su -c 'rm /system/lib/libswresample-0.so'"
adb shell "su -c 'rm /system/lib/libswscale-2.so'"

adb shell "su -c 'cat /mnt/sdcard/libavcodec-55.so > /system/lib/libavcodec-55.so'"
adb shell "su -c 'cat /mnt/sdcard/libavformat-55.so > /system/lib/libavformat-55.so'"
adb shell "su -c 'cat /mnt/sdcard/libavutil-52.so > /system/lib/libavutil-52.so'"
adb shell "su -c 'cat /mnt/sdcard/libswresample-0.so > /system/lib/libswresample-0.so'"
adb shell "su -c 'cat /mnt/sdcard/libswscale-2.so > /system/lib/libswscale-2.so'"