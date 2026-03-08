{ ... }:

{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github-fiveinc" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_fiveinc";
      };
      "oci" = {
        hostname = "137.131.13.67";
        user = "yg";
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          SetEnv = "TERM=xterm-256color";
        };
      };
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
