{ config, pkgs, ... }:

{
  # espanso の設定ファイルを配置
  # match/base.yml は個人情報を含むため gitignore 対象。
  # 手動で ~/.config/espanso/match/base.yml を配置すること。
  xdg.configFile = {
    "espanso/config/default.yml".source = ../dotfiles/espanso/config/default.yml;
  };
}
