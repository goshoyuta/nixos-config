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

      # --- Colors (Nord) ---
      color = "2e3440ff";

      # inside
      inside-color = "2e3440ff";
      inside-clear-color = "81a1c1ff";
      inside-ver-color = "5e81acff";
      inside-wrong-color = "bf616aff";

      # ring
      ring-color = "3b4252ff";
      ring-clear-color = "88c0d0ff";
      ring-ver-color = "81a1c1ff";
      ring-wrong-color = "d08770ff";

      # text
      text-color = "eceff4ff";
      text-clear-color = "3b4252ff";
      text-ver-color = "3b4252ff";
      text-wrong-color = "3b4252ff";

      # key highlight
      key-hl-color = "a3be8cff";
      bs-hl-color = "b48eadff";
      caps-lock-bs-hl-color = "d08770ff";
      caps-lock-key-hl-color = "ebcb8bff";

      # misc
      layout-bg-color = "2e3440ff";
      separator-color = "3b4252ff";
    };
  };
}
