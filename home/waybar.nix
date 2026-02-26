{ config, pkgs, ... }:

{
  xdg.configFile = {
    "waybar/config".source = ../dotfiles/waybar/config;
    "waybar/style.css".source = ../dotfiles/waybar/style.css;
    "waybar/launch.sh" = {
      source = ../dotfiles/waybar/launch.sh;
      executable = true;
    };
    "waybar/modules" = {
      source = ../dotfiles/waybar/modules;
      recursive = true;
    };
  };
}
