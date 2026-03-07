{ ... }:

{
  services.mako = {
    enable = true;
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
