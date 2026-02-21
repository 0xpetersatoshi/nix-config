{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.desktops.addons.walker;
in {
  options.desktops.addons.walker = {
    enable = mkEnableOption "Enable walker application launcher";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.walker pkgs.elephant];

    systemd.user.services.elephant = {
      Unit = {
        Description = "Elephant backend service for Walker";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.elephant}/bin/elephant";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    systemd.user.services.walker = {
      Unit = {
        Description = "Walker application launcher service";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target" "elephant.service"];
        Requires = ["elephant.service"];
      };
      Service = {
        ExecStart = "${pkgs.walker}/bin/walker --gapplication-service";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
