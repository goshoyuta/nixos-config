{ config, pkgs, ... }:

{
  xdg.configFile = {
    "foot/foot.ini".source = ../dotfiles/foot/foot.ini;
  };
}
