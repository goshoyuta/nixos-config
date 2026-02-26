{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];

  nixpkgs.config.allowUnfree = true;

  # --- 1. システム基本設定 ---
  services.logrotate.checkConfig = false;
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "vultr-nixos";
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  # 日本語入力 (fcitx5)
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-mozc ];
  };

  # --- 2. SSH & ネットワーク ---
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
    };
  };

  # --- 3. 仮想化 & サービス ---
  virtualisation.docker.enable = true;

  # --- 4. システムパッケージ ---
  environment.systemPackages = with pkgs; [
    # 開発コア
    claude-code binutils gnumake gcc autoconf automake libtool patch m4 bison flex pkg-config

    # 言語 & ランタイム
    python3 fnm go rustup jdk21 nodejs

    # エディタ & ターミナル (neovim, tmux は Home Manager 管理)
    vim bash foot wezterm

    # CLI ツール (delta, starship, eza は Home Manager 管理)
    git github-cli lazygit ghq
    curl wget aria2 rsync rclone htop bottom procs duf dust gdu
    fzf ripgrep fd bat jq tealdeer glow pandoc
    xsel xclip wl-clipboard libnotify nnn xplr unzip zip

    # ネットワーク & クラウド
    google-cloud-sdk stripe-cli speedtest-cli doggo

    # システム & ユーティリティ
    distrobox docker-compose pciutils usbutils lsof
    which nkf tree fdupes plocate
  ];

  # bash が env 等を見つけられるよう PATH を設定
  environment.shellInit = ''
    export PATH="/run/wrappers/bin:/run/current-system/sw/bin:$PATH"
  '';

  # --- 5. フォント ---
  fonts.packages = with pkgs; [
    mplus-outline-fonts.githubRelease
  ];

  # --- 6. Fish シェル ---
  programs.fish.enable = true;

  # --- 7. Home Manager ---
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    users.yg = import ./home.nix;
  };

  # --- 8. ユーザー設定 (yg) ---
  users.users.yg = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "video" "networkmanager" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEusR5sczdEDKcoIaxcgzTwoZLGIxx0AAHylWIS10hPu goshoyuta@archlinux"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEusR5sczdEDKcoIaxcgzTwoZLGIxx0AAHylWIS10hPu goshoyuta@archlinux"
  ];

  system.stateVersion = "23.11";
}
