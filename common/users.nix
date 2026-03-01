{ config, pkgs, ... }:

{
  users.users.yg = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.user-password.path;
    extraGroups = [ "wheel" "docker" "video" "networkmanager" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEusR5sczdEDKcoIaxcgzTwoZLGIxx0AAHylWIS10hPu"
    ];
  };
}
