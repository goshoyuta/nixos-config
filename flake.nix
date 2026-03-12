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
    claude-code-overlay.url = "github:ryoppippi/claude-code-overlay";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # --- Outputs ---
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, agenix, claude-code-overlay, ... }:
    let
      system = "x86_64-linux";
      mkHost = { hostDir, extraModules ? [ ], isDesktop, system ? "x86_64-linux", enableHomeManager ? false }:
        let
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
            overlays = [ claude-code-overlay.overlays.default ];
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit isDesktop agenix pkgs-unstable;
          };
          modules = [
            hostDir
            agenix.nixosModules.default
          ] ++ (if enableHomeManager then [
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit isDesktop pkgs-unstable;
              };
              home-manager.users.yg = import ./home.nix;
            }
          ] else [ ]) ++ extraModules;
        };
      androidSystem = "aarch64-linux";
    in
    {
      nixosConfigurations = {
        x1carbon = mkHost {
          hostDir = ./hosts/laptop/configuration.nix;
          isDesktop = true;
          enableHomeManager = true;
          extraModules = [
            nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
          ];
        };

        vultr-nixos = mkHost {
          hostDir = ./hosts/server/configuration.nix;
          isDesktop = false;
          enableHomeManager = true;
        };

        oci-nixos = mkHost {
          hostDir = ./hosts/oci/configuration.nix;
          isDesktop = false;
          system = "aarch64-linux";
        };
      };

      homeConfigurations = {
        # Pixel Linux terminal (Android Virtualization Framework)
        "user" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = androidSystem;
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            isDesktop = false;
            pkgs-unstable = import nixpkgs-unstable {
              system = androidSystem;
              config.allowUnfree = true;
              overlays = [ claude-code-overlay.overlays.default ];
            };
          };
          modules = [ ./home/android.nix ];
        };
      };
    };
}
