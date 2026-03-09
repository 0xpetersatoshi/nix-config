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
      cpufetch
      curlie
      doggo
      duf
      delta
      dust
      dysk
      entr
      erdtree
      fastfetch
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
      unzip
      viddy
      wget
      xcp
      yq-go
    ];
  };
}
