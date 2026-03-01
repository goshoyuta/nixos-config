{ config, pkgs, ... }:

{
  xdg.configFile = {
    "espanso/config/default.yml".source = ../dotfiles/espanso/config/default.yml;
  };
}
