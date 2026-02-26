{ config, pkgs, lib, ... }:

{
  imports = [
    ./home/fish.nix
    ./home/git.nix
    ./home/starship.nix
    ./home/nvim.nix
    ./home/tmux.nix
    ./home/sway.nix
    ./home/waybar.nix
    ./home/foot.nix
    ./home/xremap.nix
    ./home/wofi.nix
    ./home/copyq.nix
    ./home/espanso.nix
    ./home/swaylock.nix
  ];

  home.username = "yg";
  home.homeDirectory = "/home/yg";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    eza
    fd
    trash-cli
    wl-clipboard
    grim
    slurp
    xsel
    uv
    espanso-wayland
    font-manager
  ];

  programs.home-manager.enable = true;
}
