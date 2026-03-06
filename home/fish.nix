{ config, pkgs, lib, ... }:

{
  programs.fish = {
    enable = true;

    # --- Abbreviations ---
    shellAbbrs = {
      # cd
      ".." = "cd ..";
      "..2" = "cd ../..";
      "..3" = "cd ../../..";

      # ls (eza)
      ls = "eza --icons";
      ll = "eza -l --icons";
      la = "eza -la --icons";
      lT = "eza -T --icons";
      llT = "eza -lT --icons";
      laT = "eza -laT --icons";
      llto = "eza -lsold --icons";
      lltn = "eza -lsnew --icons";
      latn = "eza -lasnew --icons";
      lato = "eza -lasold --icons";

      # git
      g = "git";
      ga = "git add";
      gd = "git diff";
      gs = "git status";
      gp = "git pull";
      gP = "git push";
      gb = "git branch";
      gba = "git branch -avv";
      gbd = "git branch -d";
      gbD = "git branch -D";
      gstt = "git status";
      gsts = "git stash";
      gco = "git checkout";
      gf = "git fetch";
      gc = "git commit";
      gcp = "git cherry-pick";
      gsw = "git switch";
      gl = "git log";

      # claude
      cc = "claude --dangerously-skip-permissions";
      ccr = "claude -r --dangerously-skip-permissions";

      # config editing
      ".fi" = "cd (ghq root)/github.com/goshoyuta/nixos-config/home && nvim fish.nix";
      ".v" = "cd (ghq root)/github.com/goshoyuta/nixos-config/home && nvim nvim.nix";
      ".c" = "cd (ghq root)/github.com/goshoyuta/nixos-config";
      ".g" = "nvim (ghq root)/github.com/goshoyuta/nixos-config/home/ghostty.nix";
      ".t" = "nvim (ghq root)/github.com/goshoyuta/nixos-config/home/tmux.nix";
      ".s" = "nvim (ghq root)/github.com/goshoyuta/nixos-config/home/sway.nix";

      # misc
      v = "nvim";
      rg = "rg -i";
      mutt = "neomutt";
      tp = "trash-put";
      tl = "trash-list";
      tr = "trash-restore";

      # nb
      nba = "nb a";
      nbe = "nb e";
      nbt = "nb t";
      nbd = "nb d";
      nbb = "nb b";
      nbq = "nb q";
      nbta = "nb todo add";

      # open vultr in a new Ghostty window (avoids tmux nesting)
      "ssh vultr" = "vultr";

      # other
      mu = "neomutt";
      lg = "lazygit";
      so = "source";
      sofi = "source ~/.config/fish/config.fish && clear";
      ki = "kilo";
    };

    # --- Login Shell ---
    loginShellInit = ''
      if test -f ~/.config/stt/api_key
          set -x OPENAI_API_KEY (cat ~/.config/stt/api_key)
      end
      if test -z "$DISPLAY" -a (tty) = "/dev/tty1"
          exec sway
      end
    '';

    # --- Interactive Shell ---
    interactiveShellInit = ''
      # greeting
      set fish_greeting

      # locale
      set -x LANG en_US.UTF-8
      set -x LC_ALL en_US.UTF-8

      # claude
      set -x CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS 1

      # PATH
      fish_add_path $HOME/.local/bin $HOME/.cargo/bin $HOME/go/bin
      set -gx PATH $HOME/.npm-global/bin $PATH

      # FZF
      set -x FZF_LEGACY_KEYBINDINGS 0
      set -x FZF_DEFAULT_COMMAND 'rg --hidden -l ""'
      set -x FZF_DEFAULT_OPTS "--layout=reverse --border --height 100%"

      # keybindings
      bind \ck kill-line
      bind \cw backward-kill-word
      bind \cg __ghq_repository_search
      bind \eo tm-switch

      # tmux auto-start
      if not set -q TMUX
          if command -v tmux >/dev/null 2>&1
              if tmux has-session 2>/dev/null
                  tmux attach-session
              else
                  # 仮セッションを detached で作成し continuum の自動復元フックを起動
                  tmux new-session -d -s _init_
                  # 最大3秒ポーリングして復元セッションが現れるのを待つ
                  for i in (seq 30)
                      sleep 0.1
                      set -l sessions (tmux list-sessions -F "#{session_name}" 2>/dev/null)
                      if test (count $sessions) -gt 1
                          break
                      end
                  end
                  # 復元セッションがあれば仮セッションを削除、なければ main にリネーム
                  set -l all_sessions (tmux list-sessions -F "#{session_name}" 2>/dev/null)
                  if test (count $all_sessions) -gt 1
                      tmux kill-session -t _init_ 2>/dev/null
                  else
                      tmux rename-session -t _init_ main 2>/dev/null
                  end
                  tmux attach-session
              end
          end
      end
    '';

    # --- Functions ---
    functions = {
      __ghq_repository_search = {
        description = "Repository Search";
        body = ''
          ghq list | fzf --border --layout=reverse | read select
          set root (ghq root)
          builtin cd "$root/$select"
          commandline -f repaint
        '';
      };

      tm-switch = {
        description = "Switch tmux sessions: direct if <=2, popup fzf if >=3";
        body = ''
          set -l sessions (tmux list-sessions -F "#{session_name}" 2>/dev/null)
          set -l count (count $sessions)
          set -l current (tmux display-message -p "#{session_name}" 2>/dev/null)

          if test $count -le 1
              tmux display-message "No other sessions to switch to."
          else if test $count -eq 2
              for s in $sessions
                  if test "$s" != "$current"
                      tmux switch-client -t "$s"
                      break
                  end
              end
          else
              tmux display-popup -w 80% -h 60% -E "fish -c _tm_fzf_switch"
          end
        '';
      };

      _tm_fzf_switch = {
        description = "fzf session switcher (called inside tmux popup)";
        body = ''
          set -l session (tmux list-sessions -F "#{session_name}" | \
              fzf --exit-0 --select-1 \
                  --preview 'tmux list-windows -t {}' \
                  --bind 'change:first' \
                  --bind 'result:transform:[ $FZF_MATCH_COUNT -eq 1 ] && echo accept')
          if test -n "$session"
              tmux switch-client -t "$session"
          end
        '';
      };

      vultr = {
        description = "Open ghostty terminal connected to vultr server";
        body = ''
          setsid ghostty -e env TERM=xterm-256color ssh vultr >/dev/null 2>&1 &
        '';
      };
    };

    # --- Plugins ---
    plugins = [
      {
        name = "fzf.fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "ddeb28a7b6a1f0ec6dae40c636e5ca4908ad160a";
          hash = "sha256-0LftxkN2c52p/sRW0lUZ4lZHLPbt4/jXHhhcnZs+sTA=";
        };
      }
    ];
  };
}
