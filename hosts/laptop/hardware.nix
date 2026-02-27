# X1 Carbon 7th Gen ハードウェア設定
#
# Intel CPU/GPU、TrackPoint、SSD TRIM、TLP、throttled は
# nixos-hardware (flake.nix で指定) が自動設定します。
#
# 重要: インストール後、nixos-generate-config --show-hardware-config の出力で
# ファイルシステム部分 (fileSystems / swapDevices) を差し替えてください。
#
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # --- カーネル設定 ---
  boot.initrd.availableKernelModules = [
    "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  # --- ファイルシステム (nixos-generate-config の出力で差し替え) ---
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  # --- ファームウェア ---
  hardware.enableRedistributableFirmware = true;

  networking.useDHCP = lib.mkDefault true;
}
