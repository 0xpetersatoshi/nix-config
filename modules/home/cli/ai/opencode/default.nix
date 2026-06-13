{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.ai.opencode;
in {
  options.cli.ai.opencode = with types; {
    enable = mkBoolOpt false "Whether or not to enable the opencode tui";
  };

  config = mkIf cfg.enable {
    home.packages =
      [
        pkgs.opencode
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        pkgs.libnotify
        pkgs.sound-theme-freedesktop
        pkgs.pulseaudio
      ];

    xdg.configFile."opencode/opencode.jsonc".source = ./opencode.jsonc;
    xdg.configFile."opencode/tui.json".source = ./tui.json;
    xdg.configFile."opencode/opencode-notifier.json".source =
      if pkgs.stdenv.hostPlatform.isDarwin
      then ./opencode-notifier.darwin.json
      else ./opencode-notifier.linux.json;

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
