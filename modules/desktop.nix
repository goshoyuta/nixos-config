{ config, pkgs, ... }:

{
  # --- Sway ---
  programs.sway.enable = true;

  # --- xremap (udev rules for input device access) ---
  hardware.uinput.enable = true;
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", MODE="0660"
  '';

  # --- Packages ---
  environment.systemPackages = with pkgs; [
    xsel xclip wl-clipboard libnotify
    swayidle swaylock
  ];

  # --- Fonts ---
  fonts.packages = with pkgs; [
    mplus-outline-fonts.githubRelease
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    font-awesome
    (callPackage ../packages/cica.nix {})
  ];

  fonts.fontconfig = {
    antialias = true;
    hinting = {
      enable = true;
      style = "slight";
    };
    subpixel = {
      rgba = "rgb";
      lcdfilter = "default";
    };
    defaultFonts = {
      sansSerif = [ "Noto Sans CJK JP" "Noto Sans" ];
      serif = [ "Noto Serif CJK JP" "Noto Serif" ];
      monospace = [ "Cica" "Noto Sans Mono CJK JP" ];
    };
  };
}
