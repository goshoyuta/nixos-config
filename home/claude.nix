{ config, pkgs, ... }:

{
  home.file.".claude/CLAUDE.md".source = ../dotfiles/claude/CLAUDE.md;
}
