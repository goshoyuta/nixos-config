{ config, pkgs, ... }:

{
  home.packages = [ pkgs.delta ];

  programs.git = {
    enable = true;
    userName = "goshoyuta";
    userEmail = "goshoyuta@gmail.com";

    aliases = {
      aicommit = "!f() { COMMITMSG=$(claude --no-session-persistence --print 'Generate ONLY a one-line Git commit message in English using imperative mood. The message should summarize what was changed and why, based strictly on the contents of `git diff --cached`. DO NOT add an explanation or a body. Output ONLY the commit summary line.'); git commit -m \"$COMMITMSG\" -e; }; f";
    };

    extraConfig = {
      # --- Core ---
      core = {
        editor = "nvim";
        ignorecase = false;
        autocrlf = false;
        pager = "delta";
      };

      # --- Delta ---
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        light = false;
        side-by-side = true;
      };

      # --- Merge ---
      color.ui = true;
      merge = {
        conflictstyle = "diff3";
        tool = "nvimdiff";
      };
      mergetool.prompt = false;

      # --- GitHub ---
      "credential \"https://github.com\"".helper = "!/run/current-system/sw/bin/gh auth git-credential";
      "credential \"https://gist.github.com\"".helper = "!/run/current-system/sw/bin/gh auth git-credential";

      # --- Defaults ---
      pull.ff = "only";
      init.defaultBranch = "main";
    };
  };
}
