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
      # Remove the 1px border and animation around the slurp region selection
      # used by the screenshot picker (matches Omarchy's screenshot-selection).
      layer_rule = [
        {
          match.namespace = "^(selection)$";
          no_anim = true;
        }
      ];

      window_rule = [
        {
          match.class = "^(firefox)$";
          idle_inhibit = "fullscreen";
        }

        {
          match.class = "^(zen)$";
          opacity = "0.95 0.95";
        }
        {
          match.initial_class = "^(com.mitchellh.ghostty)$";
          opacity = "0.95 0.95";
        }
        {
          match.class = "^(com.mitchellh.ghostty)$";
          opacity = "0.95 0.95";
        }

        # Fix pinentry losing focus
        {
          match.class = "(pinentry-)(.*)";
          stay_focused = true;
        }

        # Float the transcode job terminal (omarchy-transcode / transcode.py)
        {
          match.class = "^(com.omarchy.transcode)$";
          float = true;
          center = true;
        }
      ];
    };
  };
}
