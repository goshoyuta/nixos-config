{ config, pkgs, lib, ... }:

let
  mod = "Mod4";
  menu = "wofi -G --show drun insensitive=true width=70% height=70% | xargs swaymsg exec --";
  footConfig = pkgs.writeText "foot-stt-config" ''
    [colors]
    alpha=0.0
  '';
  cavaConfig = pkgs.writeText "cava-stt-config" ''
    [general]
    bars = 9
    sleep_timer = 0

    [output]
    method = ncurses
    orientation = bottom
    bar_width = 2
    bar_spacing = 1
    bar_height = 7

    [input]
    method = pulse
    source = @DEFAULT_SOURCE@

    [color]
gradient = 1
    gradient_count = 3
    gradient_color_1 = '#cba6f7'
    gradient_color_2 = '#89b4fa'
    gradient_color_3 = '#94e2d5'
  '';
  sttStart = pkgs.writeShellScript "stt-start" ''
    SINK=$(pactl get-default-sink)
    if pactl get-sink-mute "$SINK" | grep -q "yes"; then
      echo "yes" > /tmp/stt_mute_before
    else
      echo "no" > /tmp/stt_mute_before
    fi
    pactl set-sink-mute "$SINK" 1
    echo "$SINK" > /tmp/stt_mute_sink
    swaymsg '[app_id="stt-overlay"] kill' 2>/dev/null || true
    ${pkgs.foot}/bin/foot --app-id=stt-overlay --config=${footConfig} ${pkgs.cava}/bin/cava -p ${cavaConfig} &
    pgrep -f "speech-to-text.*--ptt" || /home/yg/ghq/github.com/yg/speech-to-text/target/release/speech-to-text --language ja --ptt
  '';
  sttStop = pkgs.writeShellScript "stt-stop" ''
    kill -USR1 $(cat /tmp/stt.pid) 2>/dev/null || true
    swaymsg '[app_id="stt-overlay"] kill' 2>/dev/null || true
    SINK=$(cat /tmp/stt_mute_sink 2>/dev/null)
    WAS_MUTED=$(cat /tmp/stt_mute_before 2>/dev/null)
    if [ -n "$SINK" ] && [ "$WAS_MUTED" = "no" ]; then
      pactl set-sink-mute "$SINK" 0
    fi
  '';
  imgToVultr = pkgs.writeShellScript "img-to-vultr" ''
    REMOTE_PATH="/tmp/clipboard_$(date +%Y%m%d%H%M%S).png"
    if ${pkgs.wl-clipboard}/bin/wl-paste --type image/png 2>/dev/null | ssh vultr "cat > $REMOTE_PATH"; then
      echo -n "$REMOTE_PATH" | ${pkgs.wl-clipboard}/bin/wl-copy
      ${pkgs.libnotify}/bin/notify-send -a img-to-vultr "Image transferred" "$REMOTE_PATH"
    else
      ${pkgs.libnotify}/bin/notify-send -a img-to-vultr -u critical "img-to-vultr failed" "No PNG in clipboard?"
    fi
  '';
  wallpaper = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/forrest.png";
    sha256 = "00qx3h60s92hmf09ik1s3984jym6li270201qqzs5x4yks7q6flc";
  };
  toggleDim = pkgs.writeShellScript "toggle-dim" ''
    STATE="/tmp/.display_dim"
    if [ -f "$STATE" ]; then
      SAVED=$(cat "$STATE")
      rm "$STATE"
      ${pkgs.brightnessctl}/bin/brightnessctl set "$SAVED"
    else
      CURRENT=$(${pkgs.brightnessctl}/bin/brightnessctl get)
      echo "$CURRENT" > "$STATE"
      ${pkgs.brightnessctl}/bin/brightnessctl set 1
    fi
  '';
in
{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    config = {
      # --- General ---
      modifier = mod;
      terminal = "ghostty";
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

      # --- Colors (Catppuccin Mocha) ---
      colors = {
        focused = {
          border = "#89b4fa";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#cba6f7";
          childBorder = "#89b4fa";
        };
        focusedInactive = {
          border = "#313244";
          background = "#1e1e2e";
          text = "#bac2de";
          indicator = "#313244";
          childBorder = "#313244";
        };
        unfocused = {
          border = "#181825";
          background = "#1e1e2e";
          text = "#6c7086";
          indicator = "#181825";
          childBorder = "#181825";
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
        "*" = {
          hide_cursor = "1000";
          xcursor_theme = "Vanilla-DMZ 24";
        };
      };

      # --- Keybindings ---
      keybindings = lib.mkOptionDefault {
        # remove default binding to use for STT
        "${mod}+space" = null;

        # nixos rebuild
        "${mod}+n" = "exec sh -c 'notify-send -a nixos-rebuild \"nixos-rebuild\" \"Build started...\"; OUTPUT=$(sudo nixos-rebuild switch --fast --flake $(ghq root)/github.com/goshoyuta/nixos-config 2>&1); if [ $? -ne 0 ]; then echo \"$OUTPUT\" | wl-copy; notify-send -a nixos-rebuild -u critical \"nixos-rebuild failed\" \"Error copied to clipboard\"; else notify-send -a nixos-rebuild \"nixos-rebuild succeeded\"; fi'";
        "${mod}+Shift+n" = "exec makoctl dismiss";
        # app launch
        "${mod}+Return" = "exec ghostty";
        "${mod}+p" = "exec ${menu}";

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
        "${mod}+d" = "exec ${toggleDim}";
        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioNext" = "exec playerctl next";
        "XF86AudioPrev" = "exec playerctl previous";
        "XF86Search" = "exec ${menu}";

        # screenshot (grimshot)
        "${mod}+Shift+s" = ''exec grimshot --notify copy area'';
        "${mod}+Shift+w" = ''exec grimshot --notify save area ~/Downloads/screenshot_$(date "+%y%m%d%H%M%S").png'';
        "${mod}+Shift+f" = "exec grimshot --notify copy screen";

        # clipboard (cliphist)
        "${mod}+v" = "exec sh -c 'cliphist list | wofi --show dmenu -G insensitive=true | cliphist decode | wl-copy'";
        "${mod}+Shift+v" = "exec ${imgToVultr}";

        # IME
        "Henkan_Mode" = "exec fcitx5-remote -o";
        "Muhenkan" = "exec fcitx5-remote -c";

        # lock
        "${mod}+Shift+x" = "exec swaylock -f";

        # system
        "${mod}+Shift+q" = "exec swaynag -t warning -m 'Shutdown?' -b 'Yes' 'shutdown -h now'";
        "${mod}+Shift+b" = "exec bluetoothctl connect 70:5A:6F:62:A9:D1";
        "${mod}+Shift+i" = ''exec sh -c 'OUTPUT=$(nmcli connection up "Pixel_6859" 2>/dev/null || nmcli device wifi connect "Pixel_6859" password "jn95vj7qt386czp" 2>&1); notify-send "WiFi" "$OUTPUT"' '';
        "${mod}+Shift+9" = "exec swaymsg 'seat seat0 hide_cursor 0'";
        "${mod}+Shift+0" = "exec swaymsg 'seat seat0 hide_cursor 1000'";
      };

      # --- Assigns ---
      assigns = {
        "number 3" = [ { app_id = "google-chrome"; } ];
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
        { command = "${pkgs.swaybg}/bin/swaybg -i ${wallpaper} -m fill"; always = true; }
        { command = "mako"; }
        { command = "fcitx5"; }
        { command = "sh -c 'pgrep xremap || xremap ${config.xdg.configHome}/xremap/config.yml'"; }
        { command = "wl-paste --watch cliphist store"; }
        { command = ''swaymsg "workspace 2; exec brave --ozone-platform=wayland;"''; }
        { command = ''swaymsg "workspace 1; exec ghostty;"''; }
        { command = ''swayidle -w timeout 3 "fcitx5-remote -c" timeout 300 "swaylock -f" timeout 600 "swaymsg 'output * dpms off'" resume "swaymsg 'output * dpms on'" before-sleep "swaylock -f"''; }
      ];
    };

  };

  wayland.windowManager.sway.extraConfig = ''
      for_window [app_id="com.mitchellh.ghostty"] opacity 0.9
      title_align center
      no_focus [title="^Peek preview$"]
      no_focus [app_id="stt-overlay"]
      for_window [app_id="stt-overlay"] floating enable, resize set 320 180, move position center, border none
      exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      bindsym --no-repeat ${mod}+space exec ${sttStart}
      bindsym --release ${mod}+space exec ${sttStop}
    '';
}
