{ config, pkgs, ... }:

{
  xdg.configFile = {
    "espanso/config/default.yml".source = ../dotfiles/espanso/config/default.yml;
    "espanso/match/base.yml".source = ../dotfiles/espanso/match/base.yml;
  };
}
