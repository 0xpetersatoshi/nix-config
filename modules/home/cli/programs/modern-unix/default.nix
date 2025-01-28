{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.cli.programs.modern-unix;
in {
  options.cli.programs.modern-unix = with types; {
    enable = mkBoolOpt false "Whether or not to enable modern unix tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      choose
      curlie
      dogdns
      doggo
      duf
      delta
      du-dust
      dysk
      entr
      erdtree
      fd
      gdu
      gping
      grex
      gtrash
      hyperfine
      hexyl
      jqp
      jnv
      ouch
      procs
      ripgrep
      sd
      silver-searcher
      tokei
      trash-cli
      tailspin
      viddy
      xcp
      yq-go

      # go
      go
      golangci-lint
      air
      templ
      sqlc
      golines
      gotools
      go-task

      # python
      uv
      poetry
    ];
  };
}
