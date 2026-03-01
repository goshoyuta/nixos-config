{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # dotfiles からシンボリックリンク (lazy-lock.json は lazy.nvim が書き込むため管理外)
  xdg.configFile = {
    "nvim/init.lua".source = ../dotfiles/nvim/init.lua;
    "nvim/lua" = {
      source = ../dotfiles/nvim/lua;
      recursive = true;
    };
    "nvim/snippets" = {
      source = ../dotfiles/nvim/snippets;
      recursive = true;
    };
  };
}
