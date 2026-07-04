#!/bin/sh
# ===================================================
#  Power menu for waybar  ·  wofi dmenu (Tokyo Night)
# ===================================================
# Triggered by the custom/power module in the waybar config.

lock="  Lock"
reboot="  Reboot"
shutdown="  Shotdown"

chosen=$(printf '%s\n' "$lock" "$reboot" "$shutdown" |
  wofi --dmenu --prompt "System" --width 240 --height 200 --lines 3 --location center)

case "$chosen" in
"$lock") swaylock ;;
"$reboot") systemctl reboot ;;
"$shutdown") systemctl poweroff ;;
esac
