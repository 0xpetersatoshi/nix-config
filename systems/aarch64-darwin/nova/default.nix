{
  inputs,
  namespace,
  ...
}: {
  services.nix-daemon.enable = true;

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

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  environment.systemPath = ["/opt/homebrew/bin"];

  # Garbage collect the Nix store
  nix.gc = {
    automatic = true;
    # Change how often the garbage collector runs (default: weekly)
    # frequency = "monthly";
  };

  services.${namespace}.sketchybar.enable = true;

  roles = {
    common.enable = true;
    development.enable = true;
    security.enable = true;
    vpn.enable = true;
  };

  system.stateVersion = 5;
}
