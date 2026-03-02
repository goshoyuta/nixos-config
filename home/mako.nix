{ ... }:

{
  services.mako = {
    enable = true;
    defaultTimeout = 5000;
    extraConfig = ''
      [urgency=critical]
      background-color=#CC2200FF
      border-color=#FF4444FF
    '';
  };
}
