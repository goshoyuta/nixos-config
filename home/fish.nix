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

      # config editing
      ".fi" = "cd (ghq root)/github.com/goshoyuta/nixos-config/home && nvim fish.nix";
      ".v" = "cd (ghq root)/github.com/goshoyuta/nixos-config/home && nvim nvim.nix";
      ".c" = "cd (ghq root)/github.com/goshoyuta/nixos-config";
      ".fo" = "nvim (ghq root)/github.com/goshoyuta/nixos-config/home/foot.nix";
      ".t" = "nvim (ghq root)/github.com/goshoyuta/nixos-config/home/tmux.nix";
      ".s" = "nvim (ghq root)/github.com/goshoyuta/nixos-config/home/sway.nix";

      # misc
      v = "nvim";
      rg = "rg -i";
      du = "dust -r";
      df = "gdu";
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

      # other
      mu = "neomutt";
      lg = "lazygit";
      so = "source";
      sofi = "source ~/.config/fish/config.fish && clear";
      ki = "kilo";
    };

    # --- Login Shell ---
    loginShellInit = ''
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

      # PATH
      fish_add_path $HOME/.local/bin $HOME/.cargo/bin $HOME/go/bin
      set -gx PATH $HOME/.npm-global/bin $PATH

      # FZF
      set -x FZF_LEGACY_KEYBINDINGS 0
      set -x FZF_DEFAULT_COMMAND 'rg --hidden -l ""'
      set -x FZF_DEFAULT_OPTS "--layout=reverse --border"

      # keybindings
      bind \cw backward-kill-word
      bind \cg __ghq_repository_search

      # tmux auto-start
      if not set -q TMUX
          if command -v tmux >/dev/null 2>&1
              if tmux has-session 2>/dev/null
                  tmux attach-session
              else
                  tmux new-session -s default
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

      fs = {
        description = "Switch tmux session";
        body = ''
          tmux list-sessions -F "#{session_name}" | fzf --border --layout=reverse | read -l result; and tmux switch-client -t "$result"
        '';
      };

      sd = {
        body = ''
          set dir (fd . -H -td $HOME | fzf --border --layout=reverse); or return
          builtin cd "$dir"
        '';
      };

      sv = {
        body = ''
          set file (fd . -H -tf $HOME | fzf --border --layout=reverse); or return
          nvim "$file"
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
