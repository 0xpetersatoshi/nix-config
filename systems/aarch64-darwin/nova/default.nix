{
  config,
  inputs,
  namespace,
  ...
}: {
  # System preferences
  system.defaults = {
    dock = {
      autohide = true;
      orientation = "bottom";

      # Hot corners
      # Possible values:
      #  0: no-op
      #  2: Mission Control
      #  3: Show application windows
      #  4: Desktop
      #  5: Start screen saver
      #  6: Disable screen saver
      #  7: Dashboard
      # 10: Put display to sleep
      # 11: Launchpad
      # 12: Notification Center
      # 13: Lock Screen
      # 14: Quick Notes
      wvous-bl-corner = 14;
      wvous-br-corner = 4;
    };
    finder = {
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      CreateDesktop = false;
      FXPreferredViewStyle = "Nlsv";
      FXRemoveOldTrashItems = true;
      QuitMenuItem = true;
      ShowExternalHardDrivesOnDesktop = false;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowPathbar = true;
      ShowRemovableMediaOnDesktop = false;
      ShowStatusBar = true;
    };
    NSGlobalDomain = {
      _HIHideMenuBar = true;
      InitialKeyRepeat = 10;
      KeyRepeat = 2;
    };
    screencapture = {
      disable-shadow = true;
      location = "/Users/${config.${namespace}.user.name}/Pictures/screenshots/";
      type = "png";
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
