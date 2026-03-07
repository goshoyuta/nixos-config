{ config, pkgs, ... }:

{
  programs.swaylock = {
    enable = true;
    settings = {
      # --- General ---
      font = "Fira Sans Light";
      show-failed-attempts = true;
      show-keyboard-layout = true;
      indicator-radius = 100;
      indicator-thickness = 10;
      line-uses-ring = true;

      # --- Colors (Catppuccin Mocha) ---
      color = "1e1e2eff";

      # inside
      inside-color = "1e1e2eff";
      inside-clear-color = "89dcebff";
      inside-ver-color = "89b4faff";
      inside-wrong-color = "f38ba8ff";

      # ring
      ring-color = "313244ff";
      ring-clear-color = "94e2d5ff";
      ring-ver-color = "89b4faff";
      ring-wrong-color = "eba0acff";

      # text
      text-color = "cdd6f4ff";
      text-clear-color = "cdd6f4ff";
      text-ver-color = "cdd6f4ff";
      text-wrong-color = "cdd6f4ff";

      # key highlight
      key-hl-color = "a6e3a1ff";
      bs-hl-color = "f38ba8ff";
      caps-lock-bs-hl-color = "eba0acff";
      caps-lock-key-hl-color = "f9e2afff";

      # misc
      layout-bg-color = "1e1e2eff";
      separator-color = "313244ff";
    };
  };
}
