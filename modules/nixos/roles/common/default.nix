{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:
with lib; let
  cfg = config.roles.common;
in {
  options.roles.common = {
    enable = mkEnableOption "Enable common configuration";
  };

  config = mkIf cfg.enable {
    environment.shells = with pkgs; [
      zsh
      nushell
    ];

    hardware = {
      networking.enable = true;
    };

    hardware.${namespace} = {
      firmware.enable = true;
    };

    security = {
      gnupg.enable = true;
      polkit.enable = true;
      tpm.enable = true;
    };

    system = {
      nix.enable = true;
      boot.enable = true;
      locale.enable = true;
      zram.enable = true;
    };

    user = {
      name = "peter";
    };
  };
}
