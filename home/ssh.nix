{ ... }:

{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "vultr" = {
        hostname = "202.182.126.60";
        user = "yg";
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          SetEnv = "TERM=xterm-256color";
        };
      };
      "*" = {
        forwardAgent = true;
      };
    };
  };
}
