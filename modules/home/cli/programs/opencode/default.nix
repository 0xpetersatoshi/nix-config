{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.programs.opencode;
in {
  options.cli.programs.opencode = with types; {
    enable = mkBoolOpt false "Whether or not to enable the opencode tui";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.opencode];

    xdg.configFile."opencode/config.json".source = ./config.json;
    xdg.configFile."opencode/tui.json".source = ./tui.json;

    sops.templates.opencode-auth = mkIf config.${namespace}.security.sops.enable {
      path = "${config.xdg.dataHome}/opencode/auth.json";
      mode = "0600";
      content = ''
        {
          "openai": {
            "type": "api",
            "key": "${config.sops.placeholder.openai-api-key}"
          },
          "opencode": {
            "type": "api",
            "key": "${config.sops.placeholder.opencode-zen-api-key}"
          },
          "synthetic": {
            "type": "api",
            "key": "${config.sops.placeholder.synthetic-api-key}"
          }
        }
      '';
    };
  };
}
