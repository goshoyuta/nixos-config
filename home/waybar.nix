{ config, pkgs, ... }:

let
  # Nix does not support \uXXXX Unicode escapes in strings.
  # Use builtins.fromJSON to convert Unicode codepoints to actual characters.
  u = code: builtins.fromJSON ''"\u${code}"'';

  # Font Awesome 5 Free icon shortcuts
  fa-terminal    = u "f120";
  fa-chrome      = u "f268";
  fa-gamepad     = u "f1b6";
  fa-microchip   = u "f2db";
  fa-memory      = u "f538";
  fa-thermo0     = u "f2cb";
  fa-thermo1     = u "f2c9";
  fa-thermo2     = u "f2c7";
  fa-thermo3     = u "f2c5";
  fa-thermo4     = u "f2c3";
  fa-degree      = u "00b0";
  fa-bat0        = u "f244";
  fa-bat1        = u "f243";
  fa-bat2        = u "f242";
  fa-bat3        = u "f241";
  fa-bat4        = u "f240";
  fa-bolt        = u "f0e7";
  fa-wifi        = u "f1eb";
  fa-globe       = u "f0ac";
  fa-warning     = u "26a0";
  fa-volume-off  = u "f026";
  fa-volume-down = u "f027";
  fa-volume-up   = u "f028";
  fa-volume-mute = u "f6a9";
  fa-sun         = u "f185";
  fa-power-off   = u "f011";
in
{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        # --- Layout ---
        layer = "top";
        position = "top";
        height = 40;
        modules-left = [ "sway/workspaces" "sway/mode" "sway/window" ];
        modules-center = [ "clock" ];
        modules-right = [
          "custom/recorder" "tray" "pulseaudio" "backlight"
          "temperature" "cpu" "memory" "battery" "network"
          "custom/powermenu"
        ];

        # --- Sway ---
        "sway/mode" = {
          format = " {}";
        };
        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = false;
          disable-markup = false;
          format = "{icon}";
          format-icons = {
            "1" = "1 <span font='Font Awesome 5 Free Solid 14'>${fa-terminal}</span>";
            "2" = "2 <span font='Font Awesome 5 Free Solid 14'>${fa-chrome}</span>";
            "3" = "3 <span font='Font Awesome 5 Free Solid 14'>${fa-gamepad}</span>";
            "4" = "4 <span font='Font Awesome 5 Free Solid 14'>${fa-gamepad}</span>";
            "5" = "5 <span font='Font Awesome 5 Free Solid 14'>${fa-gamepad}</span>";
            "6" = "6 <span font='Font Awesome 5 Free Solid 14'>${fa-gamepad}</span>";
            "7" = "7 <span font='Font Awesome 5 Free Solid 14'>${fa-gamepad}</span>";
            "8" = "8 <span font='Font Awesome 5 Free Solid 14'>${fa-gamepad}</span>";
            "9" = "9 <span font='Font Awesome 5 Free Solid 14'>${fa-gamepad}</span>";
            "10" = "0 <span font='Font Awesome 5 Free Solid 14'>${fa-gamepad}</span>";
          };
        };
        "sway/window" = {
          max-length = 60;
          tooltip = false;
        };

        # --- Info ---
        clock = {
          format = "{:%a %d %b - %H:%M}";
          tooltip = false;
        };
        tray = {
          icon-size = 20;
          spacing = 8;
        };
        cpu = {
          interval = 5;
          format = "${fa-microchip} {}%";
          max-length = 10;
        };
        memory = {
          interval = 15;
          format = "<span font='Font Awesome 5 Free Solid 9'>${fa-memory}</span> {used:0.1f}G/{total:0.1f}G";
          tooltip = false;
        };
        temperature = {
          hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
          critical-threshold = 75;
          interval = 5;
          format = "{icon} {temperatureC}${fa-degree}";
          tooltip = false;
          format-icons = [ fa-thermo0 fa-thermo1 fa-thermo2 fa-thermo3 fa-thermo4 ];
        };

        # --- Hardware ---
        battery = {
          format = "<span font='Font Awesome 5 Free Solid 11'>{icon}</span> {capacity}%{time}";
          format-icons = [ fa-bat0 fa-bat1 fa-bat2 fa-bat3 fa-bat4 ];
          format-time = " ({H}h{M}m)";
          format-charging = "<span font='Font Awesome 5 Free Solid'>${fa-bolt}</span>  <span font='Font Awesome 5 Free Solid 11'>{icon}</span>  {capacity}% - {time}";
          format-full = "<span font='Font Awesome 5 Free Solid'>${fa-bolt}</span>  <span font='Font Awesome 5 Free Solid 11'>{icon}</span>  Charged";
          interval = 15;
          states = {
            warning = 25;
            critical = 10;
          };
          tooltip = false;
        };
        network = {
          format = "{icon}";
          format-alt = "<span font='Font Awesome 5 Free Solid 10'>${fa-globe}</span> {ipaddr}/{cidr} {icon}";
          format-alt-click = "click-left";
          format-wifi = "<span font='Font Awesome 5 Free Solid 10'>${fa-wifi}</span> {essid} ({signalStrength}%)";
          format-ethernet = "<span font='Font Awesome 5 Free Solid 10'>${fa-globe}</span> {ifname}";
          format-disconnected = "${fa-warning} Disconnected";
          tooltip = false;
        };
        pulseaudio = {
          format = "<span font='Font Awesome 5 Free Solid 11'>{icon:2}</span>{volume}%";
          format-alt = "<span font='Font Awesome 5 Free Solid 11'>{icon:2}</span>{volume}%";
          format-alt-click = "click-right";
          format-muted = "<span font='Font Awesome 5 Free Solid 11'>${fa-volume-mute}</span>";
          format-icons = {
            phone = [ " ${fa-volume-off}" " ${fa-volume-down}" " ${fa-volume-up}" " ${fa-volume-up}" ];
            default = [ fa-volume-off fa-volume-down fa-volume-up fa-volume-up ];
          };
          scroll-step = 2;
          on-click = "pavucontrol";
          tooltip = false;
        };
        backlight = {
          format = "{icon} {percent}%";
          format-alt = "{icon}";
          format-alt-click = "click-left";
          format-icons = [ fa-sun fa-sun ];
          on-scroll-up = "light -A 1";
          on-scroll-down = "light -U 1";
        };

        # --- Custom ---
        "custom/powermenu" = {
          return-type = "json";
          exec = "~/.config/waybar/modules/powermenu.sh";
          format = "<span font='Font Awesome 5 Free Solid 9'>{icon}</span>  {}";
          format-icons = [ fa-power-off ];
          interval = 3600;
          escape = true;
          on-click = "~/.config/wofi/wofi-power.sh";
        };
        "custom/recorder" = {
          format = "!";
          return-type = "json";
          interval = 3;
          exec = "echo '{\"class\": \"recording\"}'";
          exec-if = "pgrep wf-recorder";
          tooltip = false;
          on-click = "killall -s SIGINT wf-recorder";
        };
      };
    };

    style = builtins.readFile ../dotfiles/waybar/style.css;
  };

  # powermenu script
  xdg.configFile."waybar/modules" = {
    source = ../dotfiles/waybar/modules;
    recursive = true;
  };
}
