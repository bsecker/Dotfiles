#!/usr/bin/env bash

choice=$(printf '%s\n' 'Lock' 'Logout' 'Suspend' 'Reboot' 'Shutdown' | fuzzel --dmenu --prompt='Power: ')

case "$choice" in
  Lock) swaylock ;;
  Logout) niri msg action quit ;;
  Suspend) systemctl suspend ;;
  Reboot) systemctl reboot ;;
  Shutdown) systemctl poweroff ;;
esac
