{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.ai.claude-code;

  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  notifyStop =
    if isDarwin
    then ''
      input=$(cat)
      cwd=$(${pkgs.jq}/bin/jq -r '.cwd // ""' <<<"$input" | ${pkgs.coreutils}/bin/xargs -I{} ${pkgs.coreutils}/bin/basename {})
      /usr/bin/osascript -e "display notification \"Finished in ''${cwd:-session}\" with title \"Claude Code\" sound name \"Glass\""
    ''
    else ''
      input=$(cat)
      cwd=$(${pkgs.jq}/bin/jq -r '.cwd // ""' <<<"$input" | ${pkgs.coreutils}/bin/xargs -I{} ${pkgs.coreutils}/bin/basename {})
      ${pkgs.libnotify}/bin/notify-send -a "Claude Code" -u normal -i dialog-information "Claude Code" "Finished in ''${cwd:-session}"
      ${pkgs.pulseaudio}/bin/paplay ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/complete.oga >/dev/null 2>&1 &
    '';

  notifyEvent =
    if isDarwin
    then ''
      input=$(cat)
      ntype=$(${pkgs.jq}/bin/jq -r '.notification_type // "notification"' <<<"$input")
      msg=$(${pkgs.jq}/bin/jq -r '.message // "Claude needs your attention"' <<<"$input")
      /usr/bin/osascript -e "display notification \"$msg\" with title \"Claude Code: $ntype\" sound name \"Ping\""
    ''
    else ''
      input=$(cat)
      ntype=$(${pkgs.jq}/bin/jq -r '.notification_type // "notification"' <<<"$input")
      msg=$(${pkgs.jq}/bin/jq -r '.message // "Claude needs your attention"' <<<"$input")
      urgency=normal
      [ "$ntype" = "permission_prompt" ] && urgency=critical
      ${pkgs.libnotify}/bin/notify-send -a "Claude Code" -u "$urgency" -i dialog-question "Claude Code: $ntype" "$msg"
      ${pkgs.pulseaudio}/bin/paplay ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/message.oga >/dev/null 2>&1 &
    '';

  stopScript = pkgs.writeShellScript "claude-code-notify-stop" notifyStop;
  notificationScript = pkgs.writeShellScript "claude-code-notify-event" notifyEvent;

  settings = {
    hooks = {
      Stop = [
        {
          hooks = [
            {
              type = "command";
              command = "${stopScript}";
            }
          ];
        }
      ];
      Notification = [
        {
          hooks = [
            {
              type = "command";
              command = "${notificationScript}";
            }
          ];
        }
      ];
    };
  };
in {
  options.cli.ai.claude-code = with types; {
    enable = mkBoolOpt false "Whether or not to enable the claude-code tui";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.claude-code
      pkgs.libnotify
      pkgs.sound-theme-freedesktop
    ];

    home.file =
      {
        ".claude/settings.json".source =
          (pkgs.formats.json {}).generate "settings.json" settings;
      }
      // lib.mapAttrs' (name: _:
        lib.nameValuePair ".claude/skills/${lib.removeSuffix ".yaml" name}/SKILL.md" {
          source = ./skills + "/${name}";
        })
      (builtins.readDir ./skills);
  };
}
