{ config, pkgs, pkgs-unstable, lib, isDesktop, ... }:

{
  # --- Imports ---
  imports = [
    ./home/fish.nix
    ./home/git.nix
    ./home/starship.nix
    ./home/nvim.nix
    ./home/tmux.nix
    ./home/claude.nix
    ./home/neomutt.nix
  ] ++ lib.optionals isDesktop [
    ./home/sway.nix
    ./home/waybar.nix
    ./home/foot.nix
    ./home/xremap.nix
    ./home/wofi.nix
    ./home/copyq.nix
    ./home/espanso.nix
    ./home/swaylock.nix
  ];

  # --- User ---
  home.username = "yg";
  home.homeDirectory = "/home/yg";
  home.stateVersion = "24.11";

  # --- Packages ---
  home.packages = with pkgs; [
    eza fd duckdb trash-cli uv
  ] ++ lib.optionals isDesktop [
    brave wl-clipboard wofi
    sway-contrib.grimshot grim slurp xsel
    espanso-wayland font-manager
  ];

  programs.home-manager.enable = true;
}
