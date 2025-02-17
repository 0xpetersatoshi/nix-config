{
  inputs,
  namespace,
  ...
}: {
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

  # Nix darwin options not compatible with determinate systems nix daemon
  nix.enable = false;

  programs.guis.productivity.addons = {
    linear.enable = true;
    tableplus.enable = true;
  };

  services.${namespace} = {
    kanata.enable = true;
    sketchybar.enable = true;
  };

  roles = {
    browsers.enable = true;
    common.enable = true;
    development.enable = true;
    disk-utilities.enable = true;
    gaming.enable = true;
    music.enable = true;
    productivity.enable = true;
    security.enable = true;
    social.enable = true;
    vpn.enable = true;
  };

  system.stateVersion = 5;
}
