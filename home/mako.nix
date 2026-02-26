{ config, pkgs, ... }:

{
  xdg.configFile = {
    "mako/config".source = ../dotfiles/mako/config;
  };
}
