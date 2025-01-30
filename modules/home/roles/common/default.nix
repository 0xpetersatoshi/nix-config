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
      # NOTE: ghostty is currently broken for darwin
      # terminals.ghostty.enable = true;
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

    # TODO: move this to a separate module
    home.packages = with pkgs; [
      # keymapp
    ];
  };
}
