{channels, ...}: final: prev: {
  unstable = import channels.nixpkgs-unstable {
    system = prev.system;
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
  };
}
