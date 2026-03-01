{ config, pkgs, pkgs-unstable, ... }:

{
  # --- Docker ---
  virtualisation.docker.enable = true;

  # --- Packages ---
  environment.systemPackages = with pkgs; [
    # dev core
    pkgs-unstable.claude-code
    binutils gnumake gcc autoconf automake libtool patch m4 bison flex pkg-config

    # languages & runtimes
    nodejs python3 go fnm rustup jdk21

    # dev CLI
    lazygit ghq

    # cloud & infra
    distrobox docker-compose
    google-cloud-sdk stripe-cli
  ];
}
