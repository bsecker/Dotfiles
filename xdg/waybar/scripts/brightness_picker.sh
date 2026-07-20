#!/usr/bin/env bash

device="intel_backlight"
current=$(brightnessctl --device="$device" get)
max=$(brightnessctl --device="$device" max)
percent=$((current * 100 / max))

level=$(printf '%s\n' "$percent" | fuzzel --dmenu --prompt='Brightness (%): ')

case "$level" in
  ''|*[!0-9]*) exit 0 ;;
esac

if [ "$level" -le 100 ]; then
  brightnessctl --device="$device" set "${level}%"
fi
