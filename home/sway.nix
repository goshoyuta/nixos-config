{ config, pkgs, ... }:

{
  xdg.configFile = {
    "sway/config".source = ../dotfiles/sway/config;
  };
}
