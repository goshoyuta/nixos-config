{ config, pkgs, ... }:

{
  # --- Sway ---
  programs.sway.enable = true;

  # --- Packages ---
  environment.systemPackages = with pkgs; [
    foot
    xsel xclip wl-clipboard libnotify
  ];

  # --- Fonts ---
  fonts.packages = with pkgs; [
    mplus-outline-fonts.githubRelease
  ];
}
