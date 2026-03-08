{ config, pkgs, pkgs-unstable, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../../common
  ];

  networking.hostName = "oci-nixos";

  # --- SSH ---
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # --- Docker ---
  virtualisation.docker.enable = true;

  # --- Packages ---
  environment.systemPackages = with pkgs; [
    pkgs-unstable.claude-code
    binutils gnumake gcc autoconf automake libtool patch m4 bison flex pkg-config
    nodejs nodePackages.pm2 python3 go fnm rustup
    lazygit ghq
    docker-compose
  ];

  system.stateVersion = "25.11";
}
