{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.roles.development;
in {
  options.roles.development = {
    enable = mkEnableOption "Enable development configuration";
  };

  config = mkIf cfg.enable {
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = [
      # Add any missing dynamic libraries for unpackaged programs

      # here, NOT in environment.systemPackages
    ];
  };
}
