{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs-darwin }:
  let
    systemSettings = {
        system = "aarch64-darwin";
        hostname = "nova";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."${systemSettings.hostname}" = nix-darwin.lib.darwinSystem {
      system = systemSettings.system;
      modules = [
          ./hosts/${systemSettings.hostname}/default.nix
      ];
      specialArgs = {
          inherit inputs;
          inherit systemSettings;
      };
    };
  };
}
