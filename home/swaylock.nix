{ config, pkgs, ... }:

{
  xdg.configFile = {
    "swaylock/config".source = ../dotfiles/swaylock/config;
  };
}
