{ config, pkgs, lib, ... }:

let
  mod = "Mod4";
  menu = "wofi -G --show drun insensitive=true width=70% height=70% | xargs swaymsg exec --";
in
{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    config = {
      # --- General ---
      modifier = mod;
      terminal = "foot";
      menu = menu;
      fonts = {
        names = [ "Noto Sans CJK JP" ];
        size = 14.0;
      };
      workspaceLayout = "default";
      defaultWorkspace = "workspace number 1";

      # --- Window ---
      window = {
        titlebar = false;
        border = 0;
        hideEdgeBorders = "smart";
      };
      floating.titlebar = false;
      floating.border = 0;

      # --- Colors ---
      colors = {
        focused = {
          border = "#36363a";
          background = "#36363a";
          text = "#d4d4d4";
          indicator = "#1e1e1e";
          childBorder = "#36363a";
        };
        focusedInactive = {
          border = "#1e1e1e";
          background = "#1e1e1e";
          text = "#d4d4d4";
          indicator = "#1e1e1e";
          childBorder = "#1e1e1e";
        };
        unfocused = {
          border = "#1e1e1e";
          background = "#1e1e1e";
          text = "#d4d4d4";
          indicator = "#1e1e1e";
          childBorder = "#1e1e1e";
        };
      };

      # --- Bar ---
      bars = [{
        command = "waybar";
      }];

      # --- Input ---
      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          repeat_delay = "175";
          repeat_rate = "55";
        };
        "type:touchpad" = {
          tap = "enabled";
          dwt = "enabled";
          natural_scroll = "enabled";
          pointer_accel = "0.25";
        };
        "1739:52619:SYNA8004:00_06CB:CD8B_Touchpad" = {
          tap = "enabled";
          dwt = "disabled";
          drag = "enabled";
          drag_lock = "disabled";
          middle_emulation = "disabled";
          natural_scroll = "enabled";
        };
      };

      seat = {
        "*" = { hide_cursor = "1000"; };
      };

      # --- Keybindings ---
      keybindings = lib.mkOptionDefault {
        # app launch
        "${mod}+Return" = "exec foot";
        "${mod}+space" = "exec ${menu}";

        # window
        "${mod}+Shift+d" = "kill";
        "${mod}+Shift+a" = "focus parent,kill";
        "${mod}+Shift+c" = "reload";

        # focus (hjkl)
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";

        # move (Shift+hjkl)
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        # layout
        "${mod}+f" = "fullscreen";
        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";
        "${mod}+r" = "mode resize";

        # workspace
        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+u" = "workspace number 1";
        "${mod}+i" = "workspace number 2";
        "${mod}+o" = "workspace number 3";
        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";

        # media
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioNext" = "exec playerctl next";
        "XF86AudioPrev" = "exec playerctl previous";
        "XF86Search" = "exec ${menu}";

        # screenshot (grimshot)
        "${mod}+Shift+s" = ''exec grimshot --notify copy area'';
        "${mod}+Shift+w" = ''exec grimshot --notify save area ~/Downloads/screenshot_$(date "+%y%m%d%H%M%S").png'';
        "${mod}+Shift+f" = "exec grimshot --notify copy screen";

        # clipboard (cliphist)
        "${mod}+v" = "exec cliphist list | wofi --show dmenu -G insensitive=true | cliphist decode | wl-copy";

        # IME
        "Henkan_Mode" = "exec fcitx5-remote -o";
        "Muhenkan" = "exec fcitx5-remote -c";

        # lock
        "${mod}+Shift+x" = "exec swaylock -f";

        # system
        "${mod}+Shift+q" = "exec shutdown -h now";
        "${mod}+Shift+b" = "exec bluetoothctl connect 70:5A:6F:62:A9:D1";
        "${mod}+Shift+n" = ''exec nmcli device wifi connect "Pixel_6859" password "jn95vj7qt386czp"'';
        "${mod}+Shift+9" = "exec swaymsg 'seat seat0 hide_cursor 0'";
        "${mod}+Shift+0" = "exec swaymsg 'seat seat0 hide_cursor 1000'";
      };

      # --- Modes ---
      modes = {
        resize = {
          "h" = "resize shrink width 10 px or 10 ppt";
          "j" = "resize grow height 10 px or 10 ppt";
          "k" = "resize shrink height 10 px or 10 ppt";
          "l" = "resize grow width 10 px or 10 ppt";
          "Return" = "mode default";
          "Escape" = "mode default";
          "${mod}+r" = "mode default";
        };
      };

      # --- Startup ---
      startup = [
        { command = "mako"; }
        { command = "fcitx5"; }
        { command = "xremap ${config.xdg.configHome}/xremap/config.yml"; }
        { command = "wl-paste --watch cliphist store"; }
        { command = ''swaymsg "workspace 1; exec foot;"''; }
        { command = ''swaymsg "workspace 2; exec brave;"''; }
        { command = ''swayidle -w timeout 300 "swaylock -f" timeout 600 "swaymsg 'output * dpms off'" resume "swaymsg 'output * dpms on'" before-sleep "swaylock -f"''; }
      ];
    };

    extraConfig = ''
      title_align center
      for_window [class="^.*"] border none
      no_focus [title="^Peek preview$"]
      exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
    '';
  };
}
