{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.ai.pi;
in {
  options.cli.ai.pi = with types; {
    enable = mkBoolOpt false "Whether or not to enable pi coding agent";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.pi-coding-agent];

    sops.templates.pi-auth = mkIf config.${namespace}.security.sops.enable {
      path = "${config.home.homeDirectory}/.pi/agent/auth.json";
      mode = "0600";
      content = ''
        {
          "openrouter": {
            "type": "api-key",
            "key": "${config.sops.placeholder.openrouter-api-key}"
          }
        }
      '';
    };
  };
}
