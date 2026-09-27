#!/usr/bin/env bash

if ! command -v bluetoothctl >/dev/null 2>&1; then
    printf '\n'
    exit 0
fi

status=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')
if [ "$status" == "yes" ]; then
    echo ""
else
    echo ""
fi
