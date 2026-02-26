{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "goshoyuta";
        email = "goshoyuta@gmail.com";
      };
      core = {
        ignorecase = false;
        autocrlf = false;
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

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      light = false;
      side-by-side = true;
    };
  };
}
