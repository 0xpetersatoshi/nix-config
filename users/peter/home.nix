{ inputs, userSettings, ... }: {
  imports = [
    # ./modules
    ./home-packages.nix
  ];

  home = {
    username = userSettings.user;
    stateVersion = userSettings.stateVersion;
  };
}
