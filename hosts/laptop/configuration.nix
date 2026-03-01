{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../../common
    ../../modules/dev-tools.nix
    ../../modules/desktop.nix
  ];

  networking.hostName = "x1carbon";

  # --- Boot ---
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # --- Network ---
  networking.networkmanager.enable = true;

  # --- Keyboard (JIS) ---
  console.keyMap = "jp106";

  # --- Bluetooth ---
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # --- Sound (PipeWire) ---
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- Power ---
  # TLP は nixos-hardware が自動有効化。充電閾値のみ追加設定。
  services.tlp.settings = {
    START_CHARGE_THRESH_BAT0 = 75;
    STOP_CHARGE_THRESH_BAT0 = 80;
  };

  # --- Display / Wayland ---
  security.polkit.enable = true;
  programs.light.enable = true;

  # --- Fingerprint ---
  services.fprintd.enable = true;
  security.pam.services = {
    sudo.fprintAuth = true;
    swaylock.fprintAuth = true;
    login.fprintAuth = true;
  };

  # --- Firmware ---
  services.fwupd.enable = true;

  system.stateVersion = "24.11";
}
