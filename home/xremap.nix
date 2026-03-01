{ config, pkgs, ... }:

{
  xdg.configFile."xremap/config.yml".source = ../dotfiles/xremap/config.yml;
}
