{
  pkgs,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.languages.go;
in {
  options.cli.languages.go = with types; {
    enable = mkBoolOpt false "Whether or not to enable go";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      air
      delve
      go
      gofumpt
      go-task
      golangci-lint
      golangci-lint-langserver
      golines
      gomodifytags
      gopls
      gotest
      gotestsum
      (lib.meta.lowPrio gotools)
      impl
      sqlc
      templ
    ];
  };
}
