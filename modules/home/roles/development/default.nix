{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:
with lib; let
  cfg = config.roles.development;
in {
  options.roles.development = {
    enable = mkEnableOption "Enable development configuration";
  };

  config = mkIf cfg.enable {
    sops.templates.opencode-auth = mkIf config.${namespace}.security.sops.enable {
      path = "${config.xdg.dataHome}/opencode/auth.json";
      mode = "0600";
      content = ''
        {
          "openai": {
            "type": "api",
            "key": "${config.sops.placeholder.openai-api-key}"
          },
          "synthetic": {
            "type": "api",
            "key": "${config.sops.placeholder.synthetic-api-key}"
          }
        }
      '';
    };

    home.packages = with pkgs; [
      claude-code
      doppler
      opencode
      openssl
      sqlite
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
        web3.enable = true;
        worktrunk.enable = true;
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
