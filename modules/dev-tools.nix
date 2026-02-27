{ config, pkgs, pkgs-unstable, ... }:

{
  # Docker
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    # 開発コア
    pkgs-unstable.claude-code
    binutils gnumake gcc autoconf automake libtool patch m4 bison flex pkg-config

    # 言語 & ランタイム
    python3 fnm go rustup jdk21 nodejs

    # 開発 CLI
    lazygit ghq

    # クラウド & インフラ
    google-cloud-sdk stripe-cli
    distrobox docker-compose
  ];
}
