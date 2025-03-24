{
  description = "Peter's Nix/NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";

    stylix.url = "github:danth/stylix/release-24.11";

    catppuccin.url = "github:catppuccin/nix";

    zjstatus = {
      url = "github:dj95/zjstatus";
    };

    # Hyprland

    hypr-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprcursor = {
      url = "github:hyprwm/Hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyprland = {
      url = "github:hyprland-community/pyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = inputs: let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;

      snowfall = {
        metadata = "igloo";
        namespace = "igloo";
        meta = {
          name = "igloo";
          title = "Igloo";
        };
      };
    };
  in
    lib.mkFlake {
      channels-config = {
        allowUnfree = true;
      };

      home-manager = {
        backupFileExtension = "hm.bak";
      };

      overlays = with inputs; [
        hyprpanel.overlay
      ];

      # homes.modules = with inputs; [
      # ];

      systems.modules = {
        darwin = with inputs; [
          home-manager.darwinModules.home-manager
          sops-nix.darwinModules.sops
          # TODO: import here instead of in modules
          # stylix.darwinModules.stylix
        ];
        nixos = with inputs; [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          stylix.nixosModules.stylix
        ];
      };

      deploy = lib.mkDeploy {inherit (inputs) self;};
    };
}
