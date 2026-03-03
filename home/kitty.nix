{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "Cica";
      size = 18;
    };
    settings = {
      # --- Padding (foot: pad = "30x10" → horizontal=30, vertical=10) ---
      window_padding_width = "10 30";

      # --- Colors (Tokyo Night) ---
      background = "#1a1b26";
      foreground = "#c0caf5";
      color0  = "#15161E";
      color1  = "#f7768e";
      color2  = "#9ece6a";
      color3  = "#e0af68";
      color4  = "#7aa2f7";
      color5  = "#bb9af7";
      color6  = "#7dcfff";
      color7  = "#a9b1d6";
      color8  = "#414868";
      color9  = "#f7768e";
      color10 = "#9ece6a";
      color11 = "#e0af68";
      color12 = "#7aa2f7";
      color13 = "#bb9af7";
      color14 = "#7dcfff";
      color15 = "#c0caf5";
    };

    # --- Keybindings ---
    keybindings = {
      # URL表示 (foot: show-urls-launch = Control+Shift+K)
      "ctrl+shift+k" = "open_url_with_hints";
      # スクロールバック無効 (foot: scrollback-up-page/half-page/line = none)
      "shift+page_up"   = "no_op";
      "shift+page_down" = "no_op";
      "shift+up"        = "no_op";
      # 検索無効 (foot: search-start = none)
      "ctrl+shift+f" = "no_op";
    };
  };
}
