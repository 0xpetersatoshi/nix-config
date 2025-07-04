{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.roles.gaming;
in {
  options.roles.gaming = with types; {
    enable = mkBoolOpt false "Whether or not to manage gaming configuration";
  };

  config = mkIf cfg.enable {
    programs.mangohud = {
      enable = true;
      enableSessionWide = true;
      settings = {
        cpu_load_change = true;
        blacklist = "foliate,trayscale";
      };
    };

    home.packages = with pkgs; [
      lutris
      bottles
      heroic
      gfn-electron
    ];
  };
}
