{ config, pkgs, lib, ... }:

{
  services.espanso.enable = true;

  xdg.configFile = {
    "espanso/config/default.yml".source = lib.mkForce ../dotfiles/espanso/config/default.yml;
  };

  home.activation.espansoBase = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -f "$HOME/.ssh/id_ed25519" ]; then
      $DRY_RUN_CMD mkdir -p "$HOME/.config/espanso/match"
      $DRY_RUN_CMD ${pkgs.age}/bin/age -d -i "$HOME/.ssh/id_ed25519" \
        -o "$HOME/.config/espanso/match/base.yml" \
        ${../secrets/espanso-base.age}
    fi
  '';
}
