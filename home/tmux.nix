{ config, pkgs, ... }:

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
    ];

    extraConfig = ''
      # --- Environment ---
      set-option -g update-environment "DISPLAY WAYLAND_DISPLAY SSH_AUTH_SOCK"
      set -as terminal-overrides ',*:U8=0'
      set -ga terminal-features "*:passthrough"
      set -ag terminal-overrides ",xterm-256color:RGB"

      # --- Off-mode (F12 toggle for nested tmux) ---
      bind -T root F12 \
        set prefix None \;\
        set key-table off \;\
        set status-style "fg=colour245,bg=colour238" \;\
        set status-left "#[fg=black,bg=yellow,bold] REMOTE #[default] " \;\
        refresh-client -S

      bind -T off F12 \
        set -u prefix \;\
        set -u key-table \;\
        set -u status-style \;\
        set -u status-left \;\
        refresh-client -S

      # --- Keybindings ---
      bind -n M-c new-window -c "#{pane_current_path}"
      bind -n M-w kill-window
      bind -n M-p previous-window
      bind -n M-n next-window
      bind -n C-PageUP previous-window
      bind -n C-PageDOWN next-window

      bind-key m command-prompt -p "send window to session:" "move-window -t '%%':"

      # IME (fcitx5)
      bind -n M-[ run-shell "fcitx5-remote -c" \; copy-mode
      bind [ run-shell "fcitx5-remote -c" \; copy-mode

      # Pane splits
      bind h split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"

      # Pane navigation (Alt+hjkl)
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # Pane resize
      bind -r C-h resize-pane -L 1
      bind -r C-j resize-pane -D 1
      bind -r C-k resize-pane -U 1
      bind -r C-l resize-pane -R 1

      # Window swap & creation
      bind-key -n C-S-Left swap-window -t -1
      bind-key -n C-S-Right swap-window -t +1
      bind c new-window -c '#{pane_current_path}'
      bind-key C command-prompt -p "New Session Name:" "new-session -s '%%'"

      # --- Style ---
      set -g allow-rename on
      set-option -g status-position top
      set-option -g status-justify "centre"
      set -g renumber-windows on

      # Pane borders (unified color)
      set -g pane-border-style fg=colour240
      set -g pane-active-border-style fg=colour240

      # Focus indication via background
      setw -g window-active-style bg=terminal
      setw -g window-style bg=colour234

      # Status line
      set -g status-left '#{prefix_highlight}'
      set -g status-right ""
      setw -g window-status-format "#W"
      setw -g window-status-current-format "#W"
      set-option -g status-style fg=white,bg=colour235
      set -g window-status-style fg=colour242
      set -g window-status-current-style fg=white

      # --- Copy mode (vi) ---
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xsel -bi"
      bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xsel -bi"
    '';
  };
}
