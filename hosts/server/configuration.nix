{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../../common
    ../../modules/dev-tools.nix
  ];

  networking.hostName = "vultr-nixos";

  # --- SSH ---
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
    };
  };

  system.stateVersion = "23.11";
}
