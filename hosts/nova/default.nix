{ inputs, pkgs, systemSettings, userSettings, ... }:

{
      nixpkgs.overlays = [
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

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs._1password-cli
          pkgs.nushell
          pkgs.direnv
          pkgs.nil
          pkgs.nixd
          pkgs.statix
          # touch ID support in tmux
          pkgs.pam-reattach
          pkgs.reattach-to-user-namespace
        ]

        ++

        [
          pkgs.unstable._1password-gui
        ];

      services.nix-daemon.enable = true;

      # User settings
      users.users.${userSettings.user} = {
        name = userSettings.user;
        home = userSettings.home;
      };

      # System preferences
      system.defaults = {
        dock = {
          autohide = true;
          orientation = "bottom";
        };
        finder = {
          AppleShowAllExtensions = true;
          FXRemoveOldTrashItems = true;
          _FXShowPosixPathInTitle = true;
        };
        # Add more system preferences
      };

      security.pam.enableSudoTouchIdAuth = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs = {
        config.allowUnfree = true;
        hostPlatform = "${systemSettings.system}";
      };
    }
