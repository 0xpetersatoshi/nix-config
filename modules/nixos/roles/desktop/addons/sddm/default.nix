{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.roles.desktop.addons.sddm;
in {
  options.roles.desktop.addons.sddm = with types; {
    enable = mkBoolOpt false "Enable or disable the SDDM display manager.";
  };

  config = mkIf cfg.enable {
    # NOTE: sddm looks for themes under /run/current-system/sw/share/sddm/themes,
    # which only gets populated when /share/themes is linked into the system path
    environment.pathsToLink = ["/share/themes"];

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;

      extraPackages = with pkgs; [
        kdePackages.qtmultimedia
      ];

      theme = "sddm-astronaut-theme";
      settings = {
        General = {
          GreeterEnvironment = "QT_WAYLAND_SHELL_INTEGRATION=layer-shell";
        };
        Theme = {
          ThemeDir = "/run/current-system/sw/share/sddm/themes";
        };
      };
    };

    # NOTE: lets the session inherit the kernel keyring the greeter unlocked,
    # which is what pam_kwallet_init needs to hand the wallet key to the session
    systemd.services.display-manager.serviceConfig.KeyringMode = "inherit";

    environment.systemPackages = with pkgs; [
      (sddm-astronaut.override {
        embeddedTheme = "pixel_sakura";
      })
    ];
  };
}
