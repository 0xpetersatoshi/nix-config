{
  lib,
  pkgs,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    packages = {
      opencode = pkgs.callPackage ./default.nix { };
    };
  };
}