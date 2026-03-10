{ config, lib, pkgs, isDesktop, ... }:

let
  # OSC 52 経由でクリップボードをローカル端末に送るスクリプト
  # mosh + tmux 環境でも動作するよう、tmux クライアントの tty に直接書き込む
  osc52Copy = pkgs.writeShellScript "osc52-copy" ''
    buf=$(cat)
    encoded=$(printf '%s' "$buf" | ${pkgs.coreutils}/bin/base64 | ${pkgs.coreutils}/bin/tr -d '\n')
    tty="$1"
    [ -n "$tty" ] && printf '\033]52;c;%s\a' "$encoded" > "$tty"
  '';
in

{
  programs.tmux = {
    enable = true;
    prefix = "C-s";
    mouse = true;
    keyMode = "vi";
    terminal = "tmux-256color";
    escapeTime = 0;
    historyLimit = 50000;
    baseIndex = 1;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      prefix-highlight
      {
        plugin = vim-tmux-navigator;
        extraConfig = ''
          set -g @vim_navigator_mapping_left "M-h"
          set -g @vim_navigator_mapping_down "M-j"
          set -g @vim_navigator_mapping_up "M-k"
          set -g @vim_navigator_mapping_right "M-l"
          set -g @vim_navigator_mapping_prev ""
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
      {
        plugin = fingers;
        extraConfig = ''
          set -g @fingers-key K
          set -g @fingers-ctrl-action "xdg-open {}"
        '';
      }
      {
        plugin = jump;
        extraConfig = ''
          set -g @jump-key j
        '';
      }
    ];

    extraConfig = ''
      # --- Environment ---
      set -g extended-keys always
      set -g detach-on-destroy off
      set -g update-environment "DISPLAY WAYLAND_DISPLAY SSH_AUTH_SOCK"
      set -as terminal-overrides ',*:U8=0'
      set -ga terminal-features "*:passthrough"
      set -ag terminal-overrides ",xterm-256color:RGB"

      # --- Clipboard (OSC 52 for SSH/mosh) ---
      set -g set-clipboard on
      set -as terminal-overrides ',xterm-256color:Ms=\E]52;c;%p2%s\007'

      # --- Keybindings ---

      # vim-tmux-navigator のデフォルト C-h/j/k/l バインドを解除（M-* にリマップ済み）
      unbind -n C-h
      unbind -n C-j
      unbind -n C-k
      unbind -n C-l

      # window
      bind -n M-c new-window -c "#{pane_current_path}"
      bind -n M-w kill-window
      bind -n M-p previous-window
      bind -n M-n next-window
      bind -n C-PageUP previous-window
      bind -n C-PageDOWN next-window
      bind -n C-S-Left swap-window -t -1
      bind -n C-S-Right swap-window -t +1
      bind c new-window -c '#{pane_current_path}'

      # session
      bind C command-prompt -p "New Session Name:" "new-session -s '%%'"
      bind m command-prompt -p "send window to session:" "move-window -t '%%':"
      bind -r -n M-[ run-shell "tmux switch-client -p 2>/dev/null || tmux switch-client -t $(tmux ls | tail -1 | cut -d: -f1)"
      bind -r -n M-] run-shell "tmux switch-client -n 2>/dev/null || tmux switch-client -t $(tmux ls | head -1 | cut -d: -f1)"
      bind -r -n C-S-h run-shell "tmux switch-client -p 2>/dev/null || tmux switch-client -t $(tmux ls | tail -1 | cut -d: -f1)"
      bind -r -n C-S-l run-shell "tmux switch-client -n 2>/dev/null || tmux switch-client -t $(tmux ls | head -1 | cut -d: -f1)"

      # pane split
      bind h split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"

      # pane resize
      bind -r C-h resize-pane -L 1
      bind -r C-j resize-pane -D 1
      bind -r C-k resize-pane -U 1
      bind -r C-l resize-pane -R 1

      # copy-mode with IME off (desktop only)
      ${if isDesktop then ''
      bind k run-shell "fcitx5-remote -c" \; copy-mode
      bind -n C-S-j run-shell "fcitx5-remote -c" \; copy-mode
      '' else ''
      bind k copy-mode
      bind -n C-S-j copy-mode
      ''}

      # --- Copy Mode (vi) ---
      bind -T copy-mode-vi Escape send -X cancel
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      ${if isDesktop then ''
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"
      bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "wl-copy"
      '' else ''
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "${osc52Copy} #{client_tty}"
      bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "${osc52Copy} #{client_tty}"
      ''}

      # --- Style ---
      set -g allow-rename on
      set -g renumber-windows on
      set -g status-position top

      ${if isDesktop then ''
      # --- Tokyo Night ---
      # pane border
      set -g pane-border-style "fg=#414868"
      set -g pane-active-border-style "fg=#7aa2f7"

      # focus (background color)
      setw -g window-active-style "bg=terminal"
      setw -g window-style "bg=#16161e"

      # status line - 2段表示: セッション(上) / ウィンドウ(下)
      set -g status 2
      set -g status-style "fg=#1a1b26,bg=#7aa2f7"

      # 上段: PREFIX (左・8文字) + セッション名 (中央・青背景で横いっぱい) + REMOTE (右・8文字)
      # 三項演算子内の #[...] にカンマを含めると tmux がカンマを区切り文字と誤認するため、属性は必ず分割する
      set -g status-format[0] "#[fill=#7aa2f7]#[bg=#7aa2f7]#[fg=#1a1b26]#{?client_prefix,#[bg=#f7768e]#[bold] PREFIX #[bg=#7aa2f7]#[fg=#1a1b26]#[nobold],        }#[align=centre]#[bold] #S #[align=right]#[nobold]#{?#{==:#{client_key_table},off},#[bg=#e0af68]#[bold] REMOTE #[bg=#7aa2f7]#[fg=#1a1b26]#[nobold],        }"

      # 下段: ウィンドウ一覧 (中央) - fill=#1a1b26 で暗色背景
      set -g status-format[1] "#[fill=#1a1b26]#[bg=#1a1b26]#[fg=#c0caf5]#[align=centre]#{W:#[fg=#565f89]#[bg=#1a1b26] #W ,#[fg=#7aa2f7]#[bg=#24283b]#[bold] #W #[default]#[bg=#1a1b26]}"
      '' else ''
      # --- Gruvbox Dark ---
      # pane border
      set -g pane-border-style "fg=#504945"
      set -g pane-active-border-style "fg=#d79921"

      # focus (background color)
      setw -g window-active-style "bg=terminal"
      setw -g window-style "bg=#1d2021"

      # status line - 2段表示: セッション(上) / ウィンドウ(下)
      set -g status 2
      set -g status-style "fg=#1d2021,bg=#d79921"

      # 上段: PREFIX + セッション名 + REMOTE
      set -g status-format[0] "#[fill=#d79921]#[bg=#d79921]#[fg=#1d2021]#{?client_prefix,#[bg=#cc241d]#[bold] PREFIX #[bg=#d79921]#[fg=#1d2021]#[nobold],        }#[align=centre]#[bold] #S #[align=right]#[nobold]#{?#{==:#{client_key_table},off},#[bg=#fe8019]#[bold] REMOTE #[bg=#d79921]#[fg=#1d2021]#[nobold],        }"

      # 下段: ウィンドウ一覧
      set -g status-format[1] "#[fill=#1d2021]#[bg=#1d2021]#[fg=#ebdbb2]#[align=centre]#{W:#[fg=#928374]#[bg=#1d2021] #W ,#[fg=#d79921]#[bg=#3c3836]#[bold] #W #[default]#[bg=#1d2021]}"
      ''}
    '';
  };

  # home-manager switch 後に tmux の設定を自動リロード
  home.activation.reloadTmux = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v tmux >/dev/null 2>&1 && tmux info >/dev/null 2>&1; then
      $DRY_RUN_CMD tmux source-file ~/.config/tmux/tmux.conf || true
    fi
  '';
}
