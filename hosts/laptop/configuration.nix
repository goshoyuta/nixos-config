{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../../common
    ../../modules/dev-tools.nix
    ../../modules/desktop.nix
  ];

  networking.hostName = "x1carbon";

  # --- ブートローダー ---
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # --- ネットワーク ---
  networking.networkmanager.enable = true;

  # --- キーボード (JIS配列) ---
  console.keyMap = "jp106";

  # --- Bluetooth ---
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # --- サウンド (PipeWire) ---
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- 電源管理 ---
  # TLP は nixos-hardware が自動有効化。充電閾値のみ追加設定。
  services.tlp.settings = {
    START_CHARGE_THRESH_BAT0 = 75;
    STOP_CHARGE_THRESH_BAT0 = 80;
  };

  # --- ディスプレイ / Wayland ---
  security.polkit.enable = true;
  programs.light.enable = true;

  # --- 指紋認証 (搭載モデルの場合コメントを外す) ---
  services.fprintd.enable = true;

  # --- ファームウェアアップデート ---
  services.fwupd.enable = true;

  system.stateVersion = "24.11";
}
