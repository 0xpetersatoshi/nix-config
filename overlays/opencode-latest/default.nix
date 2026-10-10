{inputs, ...}: final: prev: {
  opencode = inputs.nixpkgs-opencode.legacyPackages.${prev.stdenv.hostPlatform.system}.opencode;
}
