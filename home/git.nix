{ config, pkgs, ... }:

{
  home.packages = [ pkgs.delta ];

  programs.git = {
    enable = true;
    userName = "goshoyuta";
    userEmail = "goshoyuta@gmail.com";

    extraConfig = {
      core = {
        ignorecase = false;
        autocrlf = false;
        pager = "delta";
      };
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        light = false;
        side-by-side = true;
      };
      color.ui = true;
      merge = {
        conflictstyle = "diff3";
        tool = "nvimdiff";
      };
      mergetool.prompt = false;
      "credential \"https://github.com\"".helper = "!/run/current-system/sw/bin/gh auth git-credential";
      "credential \"https://gist.github.com\"".helper = "!/run/current-system/sw/bin/gh auth git-credential";
      pull.ff = "only";
      init.defaultBranch = "main";
    };
  };
}
