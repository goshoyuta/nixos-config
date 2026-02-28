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
# agenix でシークレットを作成 (初回のみ)
cd /etc/nixos
mkpasswd -m sha-512 | agenix -e secrets/user-password.age
agenix -e secrets/espanso-base.age

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

## シークレット管理 (agenix)

パスワードや個人スニペットなどの機密情報は [agenix](https://github.com/ryantm/agenix) で暗号化してリポジトリに保存しています。
復号には SSH 秘密鍵が必要で、`nixos-rebuild switch` 時に自動復号されます。

### 管理対象

| ファイル | 内容 | 対象ホスト |
|---------|------|-----------|
| `secrets/user-password.age` | yg ユーザーのパスワードハッシュ | 全ホスト |
| `secrets/espanso-base.age` | Espanso 個人スニペット (base.yml) | laptop のみ |

### 初期セットアップ

```bash
# 1. パスワードハッシュを生成して暗号化
mkpasswd -m sha-512 | agenix -e secrets/user-password.age

# 2. Espanso スニペットを暗号化
agenix -e secrets/espanso-base.age
# エディタが開くので base.yml の内容を貼り付けて保存
```

### シークレットの編集

```bash
# パスワード変更
agenix -e secrets/user-password.age

# Espanso スニペット編集
agenix -e secrets/espanso-base.age
```

### ホスト鍵の追加

新しいマシンでもシークレットを復号できるようにするには、そのマシンの SSH ホスト鍵を `secrets/secrets.nix` に追加します。

```bash
# マシン上でホスト鍵を取得
ssh-keyscan localhost 2>/dev/null | grep ed25519

# secrets/secrets.nix の publicKeys にホスト鍵を追加後、再暗号化
agenix --rekey
```

## nixos-hardware

[nixos-hardware](https://github.com/NixOS/nixos-hardware) で以下が自動設定されます:

- Intel CPU マイクロコード & GPU ドライバ
- TrackPoint 有効化
- TLP 電源管理
- throttled (CPU スロットリング対策)
- SSD TRIM
