#!/system/bin/sh

read DATA

echo $DATA > /data/adb/echwk/config.json

echo "Content-Type: text/plain"
echo
echo ok
