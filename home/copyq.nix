{ config, pkgs, ... }:

{
  xdg.configFile = {
    "copyq/copyq.conf".source = ../dotfiles/copyq/copyq.conf;
    "copyq/copyq-commands.ini".source = ../dotfiles/copyq/copyq-commands.ini;
  };
}
