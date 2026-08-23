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

      # Both of these used to come from services.desktopManager.plasma6, which set
      # `package = kdePackages.sddm` and `wayland = { enable; compositor = "kwin"; }`.
      # They are greeter-only -- neither pulls in the plasma desktop.
      package = pkgs.kdePackages.sddm;

      wayland = {
        enable = true;
        # Must stay "kwin": the sddm module only adds layer-shell-qt to the
        # greeter when the compositor is kwin, and GreeterEnvironment below
        # asks Qt for the layer-shell integration. Under the "weston" default
        # the greeter aborts with "Could not load the Qt platform plugin".
        compositor = "kwin";
      };

      extraPackages = with pkgs; [
        kdePackages.qtmultimedia
      ];

      theme = "sddm-astronaut-theme";

      # NOTE: GreeterEnvironment (QT_WAYLAND_SHELL_INTEGRATION=layer-shell) and
      # Theme.ThemeDir are not set here on purpose -- the nixos module already
      # sets both, and it only sets the layer-shell one when the compositor is
      # kwin. Hand-setting it is what broke the greeter when the compositor
      # silently fell back to weston.
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
