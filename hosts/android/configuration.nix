{ pkgs, ... }:

{
  home-manager = {
    config = ../../home/android.nix;
    backupFileExtension = "hm-bak";
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "24.05";
}
