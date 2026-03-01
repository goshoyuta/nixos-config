{ config, pkgs, lib, ... }:

{
  xdg.configFile = {
    "espanso/config/default.yml".source = ../dotfiles/espanso/config/default.yml;
  };

  home.activation.espansoBase = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -f "$HOME/.ssh/id_ed25519" ]; then
      $DRY_RUN_CMD mkdir -p "$HOME/.config/espanso/match"
      $DRY_RUN_CMD ${pkgs.age}/bin/age -d -i "$HOME/.ssh/id_ed25519" \
        ${../secrets/espanso-base.age} \
        -o "$HOME/.config/espanso/match/base.yml"
    fi
  '';
}
