{ config, pkgs, lib, ... }:

{
  # 既存モジュールが必要とする引数を注入
  _module.args = {
    isDesktop = false;
    pkgs-unstable = pkgs;
  };

  imports = [
    ./fish.nix
    ./git.nix
    ./starship.nix
    ./nvim.nix
    ./tmux.nix
    ./ssh.nix
  ];

  # nix-on-droid のデフォルトユーザー設定
  home.username = "nix-on-droid";
  home.homeDirectory = "/data/data/com.termux.nix/files/home";
  home.stateVersion = "24.05";

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
  ];

  programs.home-manager.enable = true;
}
