{ config, pkgs, ... }:

{
  xdg.configFile = {
    "espanso/config/default.yml".source = ../dotfiles/espanso/config/default.yml;
    # match/base.yml は agenix で暗号化管理 → 復号先へシンボリックリンク
    "espanso/match/base.yml".source = /run/agenix/espanso-base;
  };
}
