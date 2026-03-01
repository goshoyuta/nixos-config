# nixos-config

ThinkPad X1 Carbon (7th Gen) と Vultr VPS 向けの NixOS + Home Manager 設定。

## 構成

```
flake.nix              # エントリーポイント (nixpkgs, home-manager, nixos-hardware, agenix)
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
secrets/               # agenix 暗号化シークレット (.age) と鍵定義
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

### シークレットの作成 (NixOS インストール前に実施)

NixOS の設定が `.age` ファイルを参照しているため、`nixos-install` の前に作成してコミットしておく必要がある。

#### 1. Arch 環境に nix をインストール

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

インストール後、**新しいターミナルを開く**か、fish の場合は以下を実行:

```fish
fish_add_path /nix/var/nix/profiles/default/bin
```

#### 2. agenix と mkpasswd を取得

`agenix` は nixpkgs には含まれていないので、GitHub の flake から直接取得する。
`mkpasswd` は nixpkgs の独立パッケージ。

```bash
nix shell github:ryantm/agenix nixpkgs#mkpasswd
```

#### 3. secrets/ ディレクトリ内で .age ファイルを作成

`agenix` は同じディレクトリの `secrets.nix` を読むので、**必ず `secrets/` に移動してから**実行する。

```bash
cd secrets

# --- user-password.age ---
# パスワードハッシュを生成して、パイプで agenix に渡す
mkpasswd -m sha-512 "実際のパスワード" | agenix -e user-password.age -i ~/.ssh/id_ed25519

# --- espanso-base.age ---
# 既存の base.yml をそのまま暗号化
cat ~/.config/espanso/match/base.yml | agenix -e espanso-base.age -i ~/.ssh/id_ed25519
```

> **ポイント**: `agenix -e` はそのままだとエディタが開くが、パイプで内容を渡せばエディタなしで作成できる。

#### 4. コミット

```bash
cd ..
git add secrets/*.age
git commit -m "Add encrypted secrets"
```

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

## シークレット管理 (agenix)

パスワードや個人スニペットなどの機密情報は [agenix](https://github.com/ryantm/agenix) で暗号化してリポジトリに保存している。
復号には SSH 秘密鍵が必要で、`nixos-rebuild switch` 時に `/run/agenix/` 以下に自動復号される。

### 仕組み

```
secrets/
  secrets.nix          # 「どの公開鍵で暗号化するか」の定義
  user-password.age    # 暗号化されたパスワードハッシュ
  espanso-base.age     # 暗号化された Espanso スニペット
```

- `secrets.nix` — 暗号化に使う公開鍵と、対象ファイルの対応を定義
- `.age` ファイル — `age` で暗号化されたデータ。Git にコミットしても安全
- 復号は NixOS 起動時に SSH 秘密鍵（ユーザー鍵 or ホスト鍵）を使って自動的に行われる

### 管理対象

| ファイル | 内容 | 復号先 | 対象ホスト |
|---------|------|--------|-----------|
| `secrets/user-password.age` | yg ユーザーのパスワードハッシュ | `/run/agenix/user-password` | 全ホスト |
| `secrets/espanso-base.age` | Espanso 個人スニペット (base.yml) | `/run/agenix/espanso-base` | laptop のみ |

### シークレットの編集

NixOS 上では `agenix` がシステムパッケージに入っているので直接使える。

```bash
cd /etc/nixos/secrets

# パスワード変更
mkpasswd -m sha-512 "新しいパスワード" | agenix -e user-password.age

# Espanso スニペット編集 (エディタが開く)
agenix -e espanso-base.age

# 反映
sudo nixos-rebuild switch --flake /etc/nixos#x1carbon
```

NixOS 以外の環境（Arch 等）から編集する場合:

```bash
nix shell github:ryantm/agenix
cd secrets
agenix -e user-password.age -i ~/.ssh/id_ed25519
```

### ホスト鍵の追加

新しいマシンでもシークレットを復号できるようにするには、そのマシンの SSH ホスト鍵を `secrets/secrets.nix` に追加する。

```bash
# 1. マシン上でホスト鍵を取得
ssh-keyscan localhost 2>/dev/null | grep ed25519

# 2. secrets/secrets.nix の publicKeys にホスト鍵を追加
vim secrets/secrets.nix

# 3. 新しい鍵で再暗号化
cd secrets
agenix --rekey -i ~/.ssh/id_ed25519
```

## nixos-hardware

[nixos-hardware](https://github.com/NixOS/nixos-hardware) で以下が自動設定されます:

- Intel CPU マイクロコード & GPU ドライバ
- TrackPoint 有効化
- TLP 電源管理
- throttled (CPU スロットリング対策)
- SSD TRIM
