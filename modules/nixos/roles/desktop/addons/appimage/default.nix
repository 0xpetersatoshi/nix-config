{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.roles.desktop.addons.appimage;
in {
  options.roles.desktop.addons.appimage = with types; {
    enable = mkBoolOpt false "Enable or disable the appimage DE.";
  };

  config = mkIf cfg.enable {
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
  };
}
