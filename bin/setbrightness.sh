#!/bin/bash
echo "echo $1 > /sys/class/backlight/nv_backlight/brightness" | sudo bash
