# nixos-config

ThinkPad X1 Carbon (7th Gen) と Vultr VPS 向けの NixOS + Home Manager 設定。

## 構成

```
flake.nix              # エントリーポイント (nixpkgs, home-manager, nixos-hardware)
common/                # 共通設定 (ロケール, CLI ツール, ユーザー)
modules/
  desktop.nix          # デスクトップ向けパッケージ・フォント
  dev-tools.nix        # 開発ツール・Docker
hosts/
  laptop/              # ThinkPad X1 Carbon 7th Gen
  server/              # Vultr VPS
home/                  # Home Manager モジュール (fish, sway, nvim, tmux, git ...)
home.nix               # Home Manager エントリーポイント
dotfiles/              # xdg.configFile で配置する生ファイル
```

## Arch Linux からの移行準備

NixOS をインストールする前に、現在の Arch 環境からバックアップ・確認しておくこと。

### 設定ファイルの確認

このリポジトリに含まれない個人設定がないか確認:

```bash
# 現在のパッケージ一覧を保存
pacman -Qqe > ~/arch-packages.txt

# dotfiles で管理していない設定の確認
diff <(ls ~/.config/) <(ls dotfiles/)

# SSH 鍵・GPG 鍵のバックアップ
cp -r ~/.ssh ~/backup/
cp -r ~/.gnupg ~/backup/
```

### バックアップ対象

- `~/.ssh/` — SSH 鍵・config
- `~/.gnupg/` — GPG 鍵
- `~/ghq/` — ソースコード (Git リポジトリ)
- ブラウザのプロファイル・ブックマーク
- Espanso のユーザースニペット (`~/.config/espanso/match/packages/`)
- その他 `.gitignore` で除外しているファイル

### NixOS インストール USB の作成

```bash
# NixOS の最小 ISO をダウンロード (https://nixos.org/download)
# USB に書き込み
sudo dd if=nixos-minimal-*.iso of=/dev/sdX bs=4M status=progress
```

## インストール (ThinkPad X1 Carbon)

### 1. USB ブート & WiFi 接続

```bash
sudo systemctl start wpa_supplicant
wpa_cli
> add_network 0
> set_network 0 ssid "SSID名"
> set_network 0 psk "パスワード"
> enable_network 0
> quit
```

### 2. パーティション作成

```bash
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart root ext4 512MB 100%
parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB
parted /dev/nvme0n1 -- set 2 esp on

mkfs.ext4 -L nixos /dev/nvme0n1p1
mkfs.fat -F 32 -n boot /dev/nvme0n1p2

mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```

### 3. ハードウェア設定の生成

```bash
nixos-generate-config --root /mnt
# 生成された /mnt/etc/nixos/hardware-configuration.nix の内容を確認しておく
```

### 4. リポジトリをクローン & インストール

```bash
nix-env -iA nixos.git
git clone https://github.com/goshoyuta/nixos-config /mnt/etc/nixos

# Step 3 で生成された hardware-configuration.nix の fileSystems / swapDevices を
# hosts/laptop/hardware.nix に反映する
vim /mnt/etc/nixos/hosts/laptop/hardware.nix

nixos-install --flake /mnt/etc/nixos#x1carbon
reboot
```

### 5. 再起動後

```bash
# パスワード設定 (インストール時に設定していない場合)
sudo passwd yg

# 設定変更の適用
sudo nixos-rebuild switch --flake /etc/nixos#x1carbon
```

## 日常の使い方

```bash
# 設定を編集後に適用
sudo nixos-rebuild switch --flake /etc/nixos#x1carbon

# flake.lock の更新
nix flake update --flake /etc/nixos

# Home Manager だけ適用
home-manager switch --flake /etc/nixos
```

## nixos-hardware

[nixos-hardware](https://github.com/NixOS/nixos-hardware) で以下が自動設定されます:

- Intel CPU マイクロコード & GPU ドライバ
- TrackPoint 有効化
- TLP 電源管理
- throttled (CPU スロットリング対策)
- SSD TRIM
