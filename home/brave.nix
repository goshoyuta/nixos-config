{ pkgs, ... }:
let
  resetExitType = pkgs.writeShellScript "brave-reset-exit-type" ''
    PREFS="$HOME/.config/BraveSoftware/Brave-Browser/Default/Preferences"
    if [ -f "$PREFS" ]; then
      tmp=$(mktemp)
      ${pkgs.jq}/bin/jq '.profile.exit_type = "Normal"' "$PREFS" > "$tmp" && mv "$tmp" "$PREFS"
    fi
  '';
in
{
  home.packages = [
    (pkgs.symlinkJoin {
      name = "brave";
      paths = [ pkgs.brave ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/brave \
          --run ${resetExitType}
      '';
    })
  ];
}
