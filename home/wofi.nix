{ config, pkgs, ... }:

{
  xdg.configFile = {
    "wofi/config".source = ../dotfiles/wofi/config;
    "wofi/style.css".source = ../dotfiles/wofi/style.css;
    "wofi/vars.toml".source = ../dotfiles/wofi/vars.toml;
    "wofi/colors.rasi".source = ../dotfiles/wofi/colors.rasi;
    "wofi/launcher.rasi".source = ../dotfiles/wofi/launcher.rasi;
    "wofi/launcherSmoll.rasi".source = ../dotfiles/wofi/launcherSmoll.rasi;
    "wofi/launch.sh" = {
      source = ../dotfiles/wofi/launch.sh;
      executable = true;
    };
    "wofi/wofi-power.sh" = {
      source = ../dotfiles/wofi/wofi-power.sh;
      executable = true;
    };
  };
}
