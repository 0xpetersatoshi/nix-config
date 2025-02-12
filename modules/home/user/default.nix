{
  config,
  lib,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.igloo.user;
  homeDirRoot =
    if pkgs.stdenv.isDarwin
    then "Users"
    else "home";
in {
  options.igloo.user = {
    enable = mkOpt types.bool false "Whether to configure the user account.";
    home = mkOpt (types.nullOr types.str) "/${homeDirRoot}/${cfg.name}" "The user's home directory.";
    name = mkOpt (types.nullOr types.str) config.snowfallorg.user.name "The user account.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.name != null;
          message = "igloo.user.name must be set";
        }
      ];

      home = {
        homeDirectory = mkDefault cfg.home;
        username = mkDefault cfg.name;
        sessionVariables = {
          FLAKE = "$HOME/nix-config";
        };
      };
    }
  ]);
}
