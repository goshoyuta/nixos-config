{
  description = "NixOS + Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      system = "x86_64-linux";
      mkHost = { hostDir, extraModules ? [ ], isDesktop }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit isDesktop;
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            hostDir
            home-manager.nixosModules.home-manager
          ] ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        laptop = mkHost {
          hostDir = ./hosts/laptop/configuration.nix;
          isDesktop = true;
        };

        vultr-nixos = mkHost {
          hostDir = ./hosts/server/configuration.nix;
          isDesktop = false;
        };
      };
    };
}
