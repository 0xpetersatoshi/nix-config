{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.cli.languages.typescript;
in {
  options.cli.languages.typescript = with types; {
    enable = mkBoolOpt false "Whether or not to enable typescript";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bun
      deno
      eslint
      stable.nodejs_24
      graphql-language-service-cli
      pnpm
      typescript
      typescript-language-server
      vscode-js-debug
      vtsls
      yarn
    ];
  };
}
