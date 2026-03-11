#!/system/bin/sh

MODDIR=${0%/*}

mkdir -p /data/adb/echwk

sleep 10

sh $MODDIR/start.sh
