{ config, pkgs, ... }:

{
  xdg.configFile = {
    "wofi/config".source = ../dotfiles/wofi/config;
    "wofi/style.css".source = ../dotfiles/wofi/style.css;

    # power menu script
    "wofi/wofi-power.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        entries="Shutdown\nReboot\nLogout\nSuspend\nHibernate\nCancel"
        selected=$(echo -e "$entries" | wofi --show dmenu -G -p "Power Menu")
        case "$selected" in
          Shutdown)  systemctl poweroff ;;
          Reboot)    systemctl reboot ;;
          Logout)    swaymsg exit ;;
          Suspend)   systemctl suspend ;;
          Hibernate) systemctl hibernate ;;
          *)         ;; # Cancel or empty
        esac
      '';
    };
  };
}
