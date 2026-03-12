{ config, pkgs, pkgs-unstable, lib, isDesktop, agenix, ... }:

{
  imports = [ ./users.nix ];

  nixpkgs.config.allowUnfree = true;

  # --- Nix ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = "auto";
    cores = 0;
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

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

  # --- Tailscale ---
  services.tailscale.enable = true;

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

}
