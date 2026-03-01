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
    ];

    extraConfig = ''
      # --- Environment ---
      set -g detach-on-destroy off
      set -g update-environment "DISPLAY WAYLAND_DISPLAY SSH_AUTH_SOCK"
      set -as terminal-overrides ',*:U8=0'
      set -ga terminal-features "*:passthrough"
      set -ag terminal-overrides ",xterm-256color:RGB"

      # --- Remote Mode (F12 toggle) ---
      bind -T root F12 \
        set key-table off \;\
        set status-style "fg=colour245,bg=colour238" \;\
        set status-left "#[fg=black,bg=yellow,bold] REMOTE #[default] " \;\
        refresh-client -S

      bind -T off F12 \
        set -u key-table \;\
        set -u status-style \;\
        set -u status-left \;\
        refresh-client -S

      # --- Keybindings ---

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
      bind -r ( switch-client -p
      bind -r ) switch-client -n

      # pane split
      bind h split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"

      # pane navigation (Alt+hjkl)
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # pane resize
      bind -r C-h resize-pane -L 1
      bind -r C-j resize-pane -D 1
      bind -r C-k resize-pane -U 1
      bind -r C-l resize-pane -R 1

      # IME off before copy mode (fcitx5)
      bind -n M-k run-shell "fcitx5-remote -c" \; copy-mode
      bind [ run-shell "fcitx5-remote -c" \; copy-mode

      # --- Copy Mode (vi) ---
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"
      bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "wl-copy"

      # --- Style ---
      set -g allow-rename on
      set -g renumber-windows on
      set -g status-position top
      set -g status-justify absolute-centre

      # pane border
      set -g pane-border-style fg=colour240
      set -g pane-active-border-style fg=colour240

      # focus (background color)
      setw -g window-active-style bg=terminal
      setw -g window-style bg=colour234

      # status line
      set -g status-style fg=white,bg=colour235
      set -g status-left '#{prefix_highlight}#[fg=white,bold] #S '
      set -g status-left-length 40
      set -g status-right ""
      setw -g window-status-format "#W"
      setw -g window-status-current-format "#W"
      set -g window-status-style fg=colour242
      set -g window-status-current-style fg=white
    '';
  };
}
