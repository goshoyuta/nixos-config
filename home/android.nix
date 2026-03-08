{ config, pkgs, lib, isDesktop, pkgs-unstable, ... }:

{
  imports = [
    ./fish.nix
    ./git.nix
    ./starship.nix
    ./nvim.nix
    ./tmux.nix
    ./ssh.nix
  ];

  # Pixel Linux terminal のデフォルトユーザー
  home.username = "user";
  home.homeDirectory = "/home/user";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    eza
    fd
    git
    gh
    uv
    nodejs
    go
    ripgrep
    fzf
    ghq
    lazygit
    mosh
  ];

  programs.home-manager.enable = true;
}
