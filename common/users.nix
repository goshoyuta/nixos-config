{ config, pkgs, ... }:

{
  users.users.yg = {
    isNormalUser = true;
    initialPassword = "gy";
    extraGroups = [ "wheel" "docker" "video" "networkmanager" "input" "uinput" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEusR5sczdEDKcoIaxcgzTwoZLGIxx0AAHylWIS10hPu"
    ];
  };
}
