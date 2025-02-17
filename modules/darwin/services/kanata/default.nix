{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.services.${namespace}.kanata;
  user = config.${namespace}.user.name;
in {
  options.services.${namespace}.kanata = with types; {
    enable = mkBoolOpt false "Whether or not to enable kanata.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.${namespace}.karabiner-driverkit
      pkgs.${namespace}.kanata
    ];

    system.activationScripts.preActivation.text = ''
      ${pkgs.${namespace}.karabiner-driverkit}/bin/install-karabiner-driverkit
    '';

    # Launch daemon for the Virtual HID Device
    launchd.daemons.karabiner-virtualhid = {
      serviceConfig = {
        Label = "org.pqrs.Karabiner-DriverKit-VirtualHIDDevice";
        UserName = "root";
        GroupName = "wheel";
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/var/log/karabiner-virtualhid.log";
        StandardErrorPath = "/var/log/karabiner-virtualhid-error.log";
        Program = "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon";
      };
    };

    # Launch daemon for Kanata
    launchd.daemons.kanata = {
      serviceConfig = {
        Label = "org.nixos.kanata";
        UserName = "root";
        GroupName = "wheel";
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/var/log/kanata.log";
        StandardErrorPath = "/var/log/kanata-error.log";
        ProgramArguments = [
          "${pkgs.${namespace}.kanata}/bin/kanata"
          "--cfg"
          "/Users/${user}/.config/kanata/config.kbd"
        ];
      };
    };
  };
}
