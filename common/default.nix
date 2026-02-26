{ config, pkgs, lib, ... }:

{
  imports = [
    ./users.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # --- システム基本設定 ---
  services.logrotate.checkConfig = false;
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  # 日本語入力 (fcitx5)
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-mozc ];
  };

  # bash が env 等を見つけられるよう PATH を設定
  environment.shellInit = ''
    export PATH="/run/wrappers/bin:/run/current-system/sw/bin:$PATH"
  '';

  # Fish シェル
  programs.fish.enable = true;

  # 共通パッケージ
  environment.systemPackages = with pkgs; [
    vim bash
    git github-cli
    curl wget aria2 rsync rclone
    htop bottom procs duf dust gdu
    fzf ripgrep fd bat jq tealdeer glow pandoc
    unzip zip
    speedtest-cli doggo
    pciutils usbutils lsof
    which nkf tree fdupes plocate
  ];

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    users.yg = import ../home.nix;
  };
}
