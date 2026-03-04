{ config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      # --- General ---
      env = {
        TERM = "xterm-256color";
      };

      # --- Font ---
      font = {
        normal = { family = "Cica"; };
        size = 18.0;
      };

      # --- Padding (foot: pad = "30x10" → horizontal=30, vertical=10) ---
      window = {
        padding = { x = 30; y = 10; };
      };

      # --- Colors (Tokyo Night) ---
      colors = {
        primary = {
          background = "#1a1b26";
          foreground = "#c0caf5";
        };
        normal = {
          black   = "#15161E";
          red     = "#f7768e";
          green   = "#9ece6a";
          yellow  = "#e0af68";
          blue    = "#7aa2f7";
          magenta = "#bb9af7";
          cyan    = "#7dcfff";
          white   = "#a9b1d6";
        };
        bright = {
          black   = "#414868";
          red     = "#f7768e";
          green   = "#9ece6a";
          yellow  = "#e0af68";
          blue    = "#7aa2f7";
          magenta = "#bb9af7";
          cyan    = "#7dcfff";
          white   = "#c0caf5";
        };
      };

      # --- URL hints (foot: show-urls-launch = Control+Shift+K) ---
      hints.enabled = [
        {
          hyperlinks = true;
          command = "xdg-open";
          binding = { key = "K"; mods = "Control|Shift"; };
        }
      ];

      # --- Keybindings ---
      # スクロール無効 (foot: scrollback-up-page/half-page/line = none)
      # 検索無効 (foot: search-start = none)
      keyboard.bindings = [
        { key = "PageUp";   mods = "Shift";         action = "ReceiveChar"; }
        { key = "PageDown"; mods = "Shift";         action = "ReceiveChar"; }
        { key = "Up";       mods = "Shift";         action = "ReceiveChar"; }
        { key = "F";        mods = "Control|Shift"; action = "ReceiveChar"; }
      ];
    };
  };
}
