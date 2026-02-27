{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # ターミナル
    foot

    # クリップボード & 通知
    xsel xclip wl-clipboard libnotify
  ];

  # フォント
  fonts.packages = with pkgs; [
    mplus-outline-fonts.githubRelease
  ];
}
