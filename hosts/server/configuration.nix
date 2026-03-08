{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../../common
    ../../modules/dev-tools.nix
  ];

  networking.hostName = "vultr-nixos";

  # --- Firewall ---
  networking.firewall.allowedUDPPortRanges = [
    { from = 60000; to = 61000; } # Mosh
  ];

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
