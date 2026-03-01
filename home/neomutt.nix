{ pkgs, ... }:

{
  programs.neomutt = {
    enable = true;
  };

  xdg.configFile = {
    "neomutt/neomuttrc".source = ../dotfiles/neomutt/neomuttrc;
    "neomutt/colors".source = ../dotfiles/neomutt/colors;
    "neomutt/keymaps".source = ../dotfiles/neomutt/keymaps;
    "neomutt/mailboxes".source = ../dotfiles/neomutt/mailboxes;
    "neomutt/mailcap".source = ../dotfiles/neomutt/mailcap;
    "neomutt/scripts" = {
      source = ../dotfiles/neomutt/scripts;
      recursive = true;
    };
  };
}
