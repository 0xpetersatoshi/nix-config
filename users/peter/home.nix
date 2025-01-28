{...} @ inputs: {
  imports = [
    ./modules
    ./home-packages.nix
  ];

  home = {
    username = inputs.userSettings.user;
    stateVersion = inputs.userSettings.stateVersion;
  };
}
