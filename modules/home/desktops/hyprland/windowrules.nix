{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.desktops.hyprland;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      # windowrule = [
      #   "float, bitwarden"
      # ];

      windowrule = [
        "match:class ^(firefox)$, idle_inhibit fullscreen"

        "match:class ^(zen)$, opacity 0.95 0.95"
        "match:initial_class ^(com.mitchellh.ghostty)$, opacity 0.95 0.95"
        "match:class ^(com.mitchellh.ghostty)$, opacity 0.95 0.95"

        "match:class (pinentry-)(.*), stay_focused on" # Fix pinentry losing focus

        # Float the transcode job terminal (omarchy-transcode / transcode.py)
        "match:class ^(com.omarchy.transcode)$, float on"
        "match:class ^(com.omarchy.transcode)$, center on"
      ];
    };
  };
}
