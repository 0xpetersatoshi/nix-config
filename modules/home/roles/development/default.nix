{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
with lib; let
  cfg = config.roles.development;
in {
  options.roles.development = {
    enable = mkEnableOption "Enable development configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      claude-code
      pkgs.${namespace}.opencode
    ];

    cloud.google.enable = true;

    cli = {
      editors = {
        neovim.enable = true;
        sql.enable = true;
      };

      multiplexers = {
        zellij.enable = true;
        tmux.enable = true;
      };

      programs = {
        bat.enable = true;
        btop.enable = true;
        build.enable = true;
        direnv.enable = true;
        eza.enable = true;
        fzf.enable = true;
        git.enable = true;
        gpg.enable = true;
        hardware.enable = true;
        kubernetes.enable = true;
        modern-unix.enable = true;
        network-tools.enable = true;
        nh.enable = true;
        podman.enable = true;
        ssh.enable = true;
        starship.enable = true;
        zoxide.enable = true;
      };

      languages = {
        go.enable = true;
        python.enable = true;
        rust.enable = true;
        typescript.enable = true;
      };
    };

    guis = {
      appimage = {
        tableplus.enable = pkgs.stdenv.isLinux;
      };

      development.enable = pkgs.stdenv.isLinux;
    };
  };
}
