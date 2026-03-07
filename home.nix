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
    ./home/ssh.nix
  ] ++ lib.optionals isDesktop [
    ./home/fcitx5.nix
    ./home/sway.nix
    ./home/waybar.nix
    ./home/foot.nix
    ./home/ghostty.nix
    ./home/xremap.nix
    ./home/wofi.nix
    ./home/copyq.nix
    ./home/espanso.nix
    ./home/swaylock.nix
    ./home/mako.nix
    ./home/brave.nix
  ];

  # --- User ---
  home.username = "yg";
  home.homeDirectory = "/home/yg";
  home.stateVersion = "24.11";

  # --- Packages ---
  home.packages = with pkgs; [
    eza fd duckdb trash-cli uv bun psmisc lsof
    (python3.withPackages (ps: with ps; [
      numpy
      sounddevice
      scipy
      openai
      typer
    ]))
  ] ++ lib.optionals isDesktop [
    google-chrome wl-clipboard wofi cliphist
    sway-contrib.grimshot grim slurp xsel
    font-manager wtype xorg.setxkbmap
    libreoffice
  ];

  programs.home-manager.enable = true;

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
    size = 24;
  };
}
