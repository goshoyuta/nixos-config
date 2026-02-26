{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../../common
    ../../modules/dev-tools.nix
    ../../modules/desktop.nix
    <home-manager/nixos>
  ];

  networking.hostName = "laptop";  # TODO: 変更する

  system.stateVersion = "24.11";  # TODO: 適切なバージョンに変更
}
