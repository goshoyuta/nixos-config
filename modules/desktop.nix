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
    foot
    xsel xclip wl-clipboard libnotify
    swayidle swaylock
  ];

  # --- Fonts ---
  fonts.packages = with pkgs; [
    mplus-outline-fonts.githubRelease
    noto-fonts-cjk-sans
    font-awesome
    (callPackage ../packages/hackgen.nix {})
  ];
}
