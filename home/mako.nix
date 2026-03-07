{ ... }:

{
  services.mako = {
    enable = true;
    font = "Noto Sans CJK JP 14";
    backgroundColor = "#1e1e2eee";
    textColor = "#cdd6f4ff";
    borderColor = "#89b4faff";
    borderSize = 2;
    borderRadius = 12;
    padding = "14";
    margin = "8";
    width = 380;
    defaultTimeout = 5000;
    anchor = "bottom-right";
    extraConfig = ''
      [urgency=critical]
      background-color=#CC2200FF
      border-color=#FF4444FF

      [app-name=nixos-rebuild]
      default-timeout=0

      [summary=Recording...]
      invisible=1
    '';
  };
}
