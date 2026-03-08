{ config, pkgs, pkgs-unstable, ... }:

{
  # --- Docker ---
  virtualisation.docker.enable = true;

  # --- Packages ---
  environment.systemPackages = with pkgs; [
    # dev core
    pkgs-unstable.claude-code
    (callPackage ../packages/kilocode-cli.nix {})
    binutils gnumake gcc autoconf automake libtool patch m4 bison flex pkg-config

    # languages & runtimes
    nodejs nodePackages.pm2 python3 go fnm rustup jdk21

    # dev CLI
    lazygit ghq playwright

    # cloud & infra
    distrobox docker-compose
    google-cloud-sdk stripe-cli

    # network tools
    sshping mosh
  ];
}
