#!/system/bin/sh

MODDIR=/data/adb/modules/echwk

pkill ech-workers

$MODDIR/system/bin/ech-workers \
-f example.workers.dev:443 \
-l 127.0.0.1:1080 \
-routing global &
