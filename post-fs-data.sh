#!/system/bin/sh
# HyperCore v3.0 — Vendor Config Overrides (bind-mount)
MODDIR=${0%/*}

# ALL MANUAL BIND MOUNTS HAVE BEEN REMOVED TO PREVENT ROOT DETECTION!
# KernelSU and Magisk automatically "magic mount" files placed inside the 
# $MODDIR/system/ directory. 
# 
# Manual mount --bind leaves traces in /proc/mounts (e.g., /data/adb/ksu/modules/...)
# which are visible to banking apps and Play Integrity.
# By letting KernelSU handle it natively, the mounts are hidden from apps without root access.
