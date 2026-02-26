{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # ターミナル
    foot wezterm

    # クリップボード & 通知
    xsel xclip wl-clipboard libnotify

    # ファイルマネージャ
    nnn xplr
  ];

  # フォント
  fonts.packages = with pkgs; [
    mplus-outline-fonts.githubRelease
  ];
}
