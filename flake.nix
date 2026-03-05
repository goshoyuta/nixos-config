{
  description = "NixOS + Home Manager configuration";

  # --- Inputs ---
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
    };
  };

  # --- Outputs ---
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, agenix, nix-on-droid, ... }:
    let
      system = "x86_64-linux";
      mkHost = { hostDir, extraModules ? [ ], isDesktop }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit isDesktop agenix;
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            hostDir
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
          ] ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        x1carbon = mkHost {
          hostDir = ./hosts/laptop/configuration.nix;
          isDesktop = true;
          extraModules = [
            nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
          ];
        };

        vultr-nixos = mkHost {
          hostDir = ./hosts/server/configuration.nix;
          isDesktop = false;
        };
      };

      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        modules = [ ./hosts/android/configuration.nix ];
        home-manager-path = home-manager.outPath;
      };
    };
}
