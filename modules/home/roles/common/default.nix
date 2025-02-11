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
    # GUIs should be managed by homebrew on macOS
    programs.firefox.enable = pkgs.stdenv.isLinux;

    # TODO: find a better spot for this
    home.sessionVariables = {
      OBSIDIAN_VAULT_PATH = "$HOME/obsidian/vault";
      EDITOR = "nvim";
    };

    # system = {
    #   nix.enable = true;
    # };

    home.packages = with pkgs; [
      _1password-cli
    ];

    guis = {
      # NOTE: only enable on non-nixos linux systems
      security.enable = !pkgs.stdenv.isDarwin && (!lib.hasAttr "nixos" config);
      browsers.zen.enable = pkgs.stdenv.isLinux;
    };

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

    styles = {
      stylix.enable = true;
      theming.enable = pkgs.stdenv.isLinux;
    };
  };
}
