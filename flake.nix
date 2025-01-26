{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ ... }:
  let
    systemSettings = {
        system = "aarch64-darwin";
        hostname = "nova";
    };

    userSettings = rec {
        user = "peter";
        home = /Users/${user};

        gitUsername = "0xPeterSatoshi";
        userEmail = "dev@ngml.me";
        gitSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFjoHku2U1i34uJWA6kODHU44QJCpQE7LHxYQgk382h";

        stateVersion = "24.11";
    };

    overlays = [
      (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = prev.system;
          config = {
            allowUnfree = true;
            allowBroken = true;
          };
        };
      })
    ];

  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."${systemSettings.hostname}" = inputs.nix-darwin.lib.darwinSystem {
      system = systemSettings.system;
      modules = [
          ({ ... }: {
            nixpkgs.overlays = overlays;
          })

          ./hosts/${systemSettings.hostname}

          inputs.home-manager.darwinModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = ".bak";
              users.${userSettings.user} = import ./users/${userSettings.user}/home.nix;
              extraSpecialArgs = {
                  inherit inputs;
                  inherit userSettings;
              };
            };
          }
      ];
      specialArgs = {
          inherit inputs;
          inherit systemSettings;
          inherit userSettings;
      };
    };
  };
}
