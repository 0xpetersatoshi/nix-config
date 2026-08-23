{
  lib,
  config,
  pkgs,
  inputs,
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
      buf
      codex
      devcontainer
      doppler
      gh
      jq
      markdown-toc
      openssl
      pulumi
      pulumiPackages.pulumi-go
      sqlite
    ];

    cloud = {
      google.enable = true;
    };

    # Scratch dirs per experiment; upstream's module also wires the shell
    # `try init` hook so `try <name>` cds into the new directory.
    programs.try = {
      enable = true;
      # `try init` emits a shell function that calls $out/bin/.try-wrapped --
      # the inner script -- which skips the makeBinaryWrapper that puts ruby on
      # PATH, so every invocation died with "env: 'ruby': No such file". Give
      # the inner script an absolute ruby shebang so it stands alone.
      package = inputs.try.packages."${pkgs.system}".default.overrideAttrs (old: {
        postFixup =
          (old.postFixup or "")
          + ''
            substituteInPlace "$out/bin/.try-wrapped" \
              --replace-fail "#!/usr/bin/env ruby" "#!${pkgs.ruby_3_3}/bin/ruby"
          '';
      });
    };

    cli = {
      databases.postgres.enable = true;

      editors = {
        neovim.enable = true;
        sql.enable = true;
      };

      multiplexers = {
        zellij.enable = true;
        tmux.enable = true;
        herdr.enable = true;
      };

      ai = {
        claude-code.enable = true;
        opencode.enable = true;
        pi.enable = true;
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
