{ config, pkgs, pkgs-unstable, lib, isDesktop, ... }:

{
  imports = [ ./users.nix ];

  nixpkgs.config.allowUnfree = true;

  # --- System ---
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  # --- Japanese Input (desktop only) ---
  i18n.inputMethod = lib.mkIf isDesktop {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-mozc ];
  };

  # --- Shell ---
  programs.fish.enable = true;

  # --- Packages ---
  environment.systemPackages = with pkgs; [
    vim bash git github-cli
    curl wget aria2 rsync rclone
    htop bottom procs duf dust gdu
    fzf ripgrep fd bat jq tealdeer glow pandoc
    unzip zip pciutils usbutils which nkf tree fdupes plocate
  ];

  # --- Home Manager ---
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit isDesktop pkgs-unstable; };
    users.yg = import ../home.nix;
  };
}
