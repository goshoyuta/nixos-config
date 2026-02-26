#!/bin/sh

Shutdown_command="systemctl poweroff"
Reboot_command="systemctl reboot"
Logout_command="swaymsg exit"
Hibernate_command="systemctl hibernate"
Suspend_command="systemctl suspend"
Back_command=""

rofi_command="rofi -theme ~/.config/wofi/launcherSmoll.rasi"
options=$'Back\nShutdown\nLogout\nReboot\nHibernate\nSuspend'

eval \$"$(echo "$options" | $rofi_command -dmenu -p "")_command"
