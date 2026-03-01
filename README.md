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

1. [NixOS 公式ダウンロードページ](https://nixos.org/download/) から Minimal ISO (x86_64) をダウンロード
2. USB メモリを差し込み、デバイス名を確認

```bash
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
# USB メモリのデバイス名を確認 (例: /dev/sda)
# ⚠️ 間違えるとデータが消えるので必ず確認すること
```

3. ISO を USB に書き込み

```bash
sudo dd if=nixos-minimal-*.iso of=/dev/sdX bs=4M status=progress conv=fsync
# /dev/sdX は実際のデバイス名に置き換える
sync
```

- `bs=4M` — 4MB 単位で書き込み (高速化)
- `status=progress` — 進捗表示
- `conv=fsync` — 書き込みをディスクに確実に反映

## インストール (ThinkPad X1 Carbon)

### 1. USB ブート & WiFi 接続

```bash
# nmtui (CUI の Wi-Fi 設定ツール) で接続する
nmtui
# 「Activate a connection」→ SSID 選択 → パスワード入力

# 接続確認
ping -c 3 google.com
```

### 2. パーティション作成

> ⚠️ ESP (boot) が p1、root が p2 になる順序で作成すること

```bash
parted /dev/nvme0n1 -- mklabel gpt
# 1. EFI System Partition (p1: boot)
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 -- set 1 esp on
# 2. Root partition (p2: nixos)
parted /dev/nvme0n1 -- mkpart root ext4 512MiB 100%

mkfs.fat -F 32 -n boot /dev/nvme0n1p1
mkfs.ext4 -L nixos /dev/nvme0n1p2

mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```

### 3. ハードウェア設定の生成

```bash
nixos-generate-config --root /mnt
# 生成された /mnt/etc/nixos/hardware-configuration.nix の
# fileSystems / swapDevices を次のステップで使う
```

### 4. リポジトリをクローン

```bash
# git は最初から入っていないので nix-shell で一時取得する
nix-shell -p git

sudo mkdir -p /mnt/etc/nixos
cd /mnt/etc/nixos
sudo git clone https://github.com/goshoyuta/nixos-config .

# Step 3 で生成された fileSystems / swapDevices を hosts/laptop/hardware.nix に反映する
# (UUID はこの PC 固有の値になるので必ず上書きする)
sudo vim /mnt/etc/nixos/hosts/laptop/hardware.nix

# Flakes はGit管理外のファイルを無視するので必ず add する
sudo git add .
```

### 5. インストール実行

```bash
cd /mnt/etc/nixos
sudo git add .

sudo nixos-install --flake .#x1carbon
reboot
```

### 6. 再起動後の設定

**root ユーザー**でログインして以下を実行する。

```bash
# 一般ユーザーのパスワードを設定
passwd yg
```

その後 `exit` して `yg` ユーザーでログインする。

## 日常の使い方

```bash
# 設定を編集後に適用
sudo nixos-rebuild switch --flake /etc/nixos#x1carbon

# flake.lock の更新
nix flake update --flake /etc/nixos

# Home Manager だけ適用
home-manager switch --flake /etc/nixos
```

## 指紋認証のセットアップ

指紋認証 (fprintd) はシステム設定で有効になっているが、**指紋データは手動で登録する必要がある**。
`sudo` を使わずに実行すること（sudo で実行すると root の指紋として登録されてしまう）。

```bash
# 指紋を登録する (右人差し指)
fprintd-enroll

# 別の指を登録したい場合
fprintd-enroll -f right-thumb   # 右親指
fprintd-enroll -f left-index-finger  # 左人差し指

# 登録済みの指紋を確認
fprintd-list yg

# 登録済みの指紋を削除してやり直す場合
fprintd-delete yg
```

> **注意**: `fprintd-enroll` で `PermissionDenied` エラーが出る場合は、`sudo nixos-rebuild switch` で設定を再適用してから試す。

登録後は以下の場面で指紋認証が使用可能になる:

- `sudo` 実行時
- swaylock（画面ロック）の解除時
- ログイン時

## nixos-hardware

[nixos-hardware](https://github.com/NixOS/nixos-hardware) で以下が自動設定されます:

- Intel CPU マイクロコード & GPU ドライバ
- TrackPoint 有効化
- TLP 電源管理
- throttled (CPU スロットリング対策)
- SSD TRIM
