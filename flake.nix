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

    configuration = { pkgs, systemSettings, ... }: rec {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.nushell
          pkgs.direnv
        ];

      security.pam.enableSudoTouchIdAuth = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "${systemSettings.system}";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."${systemSettings.hostname}" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
      specialArgs = { inherit systemSettings; };
    };
  };
}
