{
  pkgs,
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.programs.podman;
in {
  options.cli.programs.podman = with types; {
    enable = mkBoolOpt false "Whether or not to manage podman";
  };
  config = mkIf cfg.enable {
    # NOTE: podman requires an additional mac-helper binary
    # for macos that is not available in the nixpkgs package.
    # When the platform is darwin, homebrew is used to install
    # podman.
    home.packages = with pkgs;
      [
        amazon-ecr-credential-helper
        arion
        docker-credential-gcr
      ]
      ++ (
        if pkgs.stdenv.isDarwin
        then []
        else [
          podman
          podman-compose
          podman-tui
        ]
      );

    home.shellAliases = {
      docker = "podman";
      "docker-compose" = "podman-compose";
    };
  };
}
