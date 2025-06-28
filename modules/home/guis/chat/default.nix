{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
with types; let
  cfg = config.guis.chat;

  # HACK: electron apps in hyprland need the `--password-store` explicitly set
  # as the XDG_CURRENT_DESKTOP env var is set to "Hyprland" which messes with
  # their decision logic on which storage backend to use.
  # see: https://www.electronjs.org/docs/latest/api/safe-storage#safestoragegetselectedstoragebackend-linux

  # Wrapper for element-desktop to use kwallet6
  element-desktop-wrapped = pkgs.symlinkJoin {
    name = "element-desktop";
    paths = [pkgs.element-desktop];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/element-desktop \
        --add-flags "--password-store=kwallet6"
    '';
  };
in {
  options.guis.chat = {
    enable = mkEnableOption "Enable chat guis";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      discord
      element-desktop-wrapped
      slack
      telegram-desktop
      whatsapp-for-linux
      signal-desktop
    ];
  };
}
