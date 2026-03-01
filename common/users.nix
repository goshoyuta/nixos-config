{ config, pkgs, ... }:

{
  users.users.yg = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$example$placeholder";  # TODO: set actual hashed password
    extraGroups = [ "wheel" "docker" "video" "networkmanager" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEusR5sczdEDKcoIaxcgzTwoZLGIxx0AAHylWIS10hPu"
    ];
  };
}
