{ config, pkgs, pkgs-unstable, lib, isDesktop, agenix, ... }:

{
  imports = [ ./users.nix ];

  nixpkgs.config.allowUnfree = true;

  # --- System ---
  boot.tmp.cleanOnBoot = true;
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
    priority = 100;
  };
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  # --- Japanese Input (desktop only) ---
  i18n.inputMethod = lib.mkIf isDesktop {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-mozc ];
  };

  # --- Sudo ---
  security.sudo.extraRules = [
    {
      users = [ "yg" ];
      commands = [
        { command = "ALL"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

  # --- Shell ---
  programs.fish.enable = true;

  # --- Packages ---
  environment.systemPackages = with pkgs; [
    vim bash git github-cli
    age
    agenix.packages.${pkgs.system}.default
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
