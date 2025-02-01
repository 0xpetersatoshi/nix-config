{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.roles.common;
in {
  options.roles.common = {
    enable = lib.mkEnableOption "Enable common configuration";
  };

  config = lib.mkIf cfg.enable {
    # browsers.firefox.enable = true;

    # system = {
    #   nix.enable = true;
    # };

    cli = {
      terminals.ghostty.enable = true;
      terminals.kitty.enable = true;
      terminals.wezterm.enable = true;
      shells.zsh.enable = true;
      shells.nushell.enable = true;
    };

    # programs = {
    #   guis.enable = true;
    # };

    # security = {
    #   sops.enable = true;
    # };

    styles.stylix.enable = true;
  };
}
