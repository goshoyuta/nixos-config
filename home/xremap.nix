{ config, pkgs-unstable, ... }:

{
  xdg.configFile."xremap/config.yml".source = ../dotfiles/xremap/config.yml;

  home.packages = [ pkgs-unstable.xremap ];
}
