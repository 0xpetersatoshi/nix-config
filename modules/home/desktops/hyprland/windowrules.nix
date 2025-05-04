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

      windowrulev2 = [
        "idleinhibit fullscreen, class:^(firefox)$"

        "opacity 0.95 0.95, class:^(zen)$"
        "opacity 0.95 0.95, class:^(com.mitchellh.ghostty)$, initialClass:^(com.mitchellh.ghostty)$"

        # hide xwaylandvideobridge
        "opacity 0.0 override, class:^(xwaylandvideobridge)$"
        "noanim, class:^(xwaylandvideobridge)$"
        "noinitialfocus, class:^(xwaylandvideobridge)$"
        "maxsize 1 1, class:^(xwaylandvideobridge)$"
        "noblur, class:^(xwaylandvideobridge)$"
        "nofocus, class:^(xwaylandvideobridge)$"
      ];
    };
  };
}
