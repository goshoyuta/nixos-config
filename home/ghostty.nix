{ config, pkgs, pkgs-unstable, ... }:

{
  programs.ghostty = {
    enable = true;
    # GTK_IM_MODULE=fcitx (fcitx5 GTK4 モジュール/DBus経由) と
    # Sway/waylandim (Wayland プロトコル経由) が競合して日本語入力が2重になるため、
    # Ghostty 起動時に GTK_IM_MODULE をアンセットして Wayland ネイティブ経路のみ使う
    package = pkgs.symlinkJoin {
      name = "ghostty";
      paths = [ pkgs-unstable.ghostty ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/ghostty \
          --unset GTK_IM_MODULE
      '';
    };
    settings = {
      font-family = "Cica";
      font-size = 20;

      # --- Padding ---
      window-padding-x = 22;

      # --- Notifications ---
      desktop-notifications = false;

      # --- Window ---
      confirm-close-surface = false;

      # --- Keybindings ---
      keybind = [
        "ctrl+shift+j=csi:27;6;106~"
      ];

      # --- Colors (Catppuccin Mocha) ---
      background = "1e1e2e";
      foreground = "cdd6f4";
      palette = [
        "0=#45475a"
        "1=#f38ba8"
        "2=#a6e3a1"
        "3=#f9e2af"
        "4=#89b4fa"
        "5=#f5c2e7"
        "6=#94e2d5"
        "7=#bac2de"
        "8=#585b70"
        "9=#f38ba8"
        "10=#a6e3a1"
        "11=#f9e2af"
        "12=#89b4fa"
        "13=#f5c2e7"
        "14=#94e2d5"
        "15=#a6adc8"
      ];

    };
  };
}
