{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.desktops.addons.rofi;
  inherit (config.lib.stylix) colors;
in {
  options.desktops.addons.rofi = {
    enable = mkEnableOption "Enable rofi app manager";
    package = mkPackageOpt pkgs.rofi "Package to use for rofi";
  };

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      package = cfg.package;
      terminal = "${pkgs.foot}/bin/foot";
      extraConfig = {
        modi = "run,drun,window";
        show-icons = true;
        drun-display-format = "{icon} {name}";
        location = 0;
        disable-history = false;
        hide-scrollbar = true;
        display-drun = "   Apps ";
        display-run = "   Run ";
        display-window = " 﩯  Window";
        display-Network = " 󰤨  Network";
        sidebar-mode = true;
      };
      plugins = with pkgs; [
        rofi-calc
      ];
      theme = let
        inherit (config.lib.formats.rasi) mkLiteral;
      in
        lib.mkForce {
          "*" = {
            /*
            Color definitions matching waybar/swaync
            */
            bg-col = mkLiteral "#${colors.base01}";
            bg-col-light = mkLiteral "#${colors.base02}";
            border-col = mkLiteral "#${colors.base03}";
            selected-col = mkLiteral "#${colors.base00}";
            blue = mkLiteral "#${colors.base0D}";
            fg-col = mkLiteral "#${colors.base05}";
            fg-col2 = mkLiteral "#${colors.base07}";
            grey = mkLiteral "#${colors.base04}";
            red = mkLiteral "#${colors.base08}";
            width = 700;
            font = mkLiteral ''"JetBrainsMono Nerd Font 14"'';
          };

          "element-text, element-icon, mode-switcher" = {
            background-color = mkLiteral "inherit";
            text-color = mkLiteral "inherit";
          };

          "window" = {
            height = mkLiteral "500px";
            border = mkLiteral "1px";
            border-color = mkLiteral "@border-col";
            border-radius = mkLiteral "20px";
            background-color = mkLiteral "@bg-col";
            location = mkLiteral "center";
            anchor = mkLiteral "center";
          };

          "mainbox" = {
            background-color = mkLiteral "transparent";
            border-radius = mkLiteral "20px";
            padding = mkLiteral "20px";
          };

          "inputbar" = {
            children = mkLiteral "[prompt,entry]";
            background-color = mkLiteral "@selected-col";
            border-radius = mkLiteral "16px";
            padding = mkLiteral "8px";
            margin = mkLiteral "0px 0px 20px 0px";
          };

          "prompt" = {
            background-color = mkLiteral "@blue";
            padding = mkLiteral "8px 12px";
            text-color = mkLiteral "#${colors.base00}";
            border-radius = mkLiteral "12px";
            font = mkLiteral ''"JetBrainsMono Nerd Font Bold 14"'';
          };

          "entry" = {
            padding = mkLiteral "8px 12px";
            text-color = mkLiteral "@fg-col2";
            background-color = mkLiteral "transparent";
            placeholder = mkLiteral "\"Search...\"";
            placeholder-color = mkLiteral "@grey";
          };

          "listview" = {
            border = mkLiteral "0px";
            padding = mkLiteral "0px";
            margin = mkLiteral "0px";
            columns = 2;
            lines = 6;
            spacing = mkLiteral "12px";
            background-color = mkLiteral "transparent";
            fixed-height = mkLiteral "false";
            cycle = mkLiteral "true";
          };

          "element" = {
            padding = mkLiteral "12px 16px";
            background-color = mkLiteral "@selected-col";
            text-color = mkLiteral "@fg-col";
            border-radius = mkLiteral "12px";
            orientation = mkLiteral "horizontal";
            spacing = mkLiteral "12px";
          };

          "element-icon" = {
            size = mkLiteral "28px";
            background-color = mkLiteral "transparent";
          };

          "element-text" = {
            background-color = mkLiteral "transparent";
            text-color = mkLiteral "inherit";
            vertical-align = mkLiteral "0.5";
          };

          "element normal.normal" = {
            background-color = mkLiteral "@selected-col";
            text-color = mkLiteral "@fg-col";
          };

          "element selected.normal" = {
            background-color = mkLiteral "@blue";
            text-color = mkLiteral "@selected-col";
          };

          "element alternate.normal" = {
            background-color = mkLiteral "@selected-col";
            text-color = mkLiteral "@fg-col";
          };

          "mode-switcher" = {
            spacing = mkLiteral "0";
            background-color = mkLiteral "@selected-col";
            border-radius = mkLiteral "16px";
            padding = mkLiteral "4px";
            margin = mkLiteral "20px 0px 0px 0px";
          };

          "button" = {
            padding = mkLiteral "8px 16px";
            background-color = mkLiteral "transparent";
            text-color = mkLiteral "@grey";
            border-radius = mkLiteral "12px";
            font = mkLiteral ''"JetBrainsMono Nerd Font 12"'';
          };

          "button selected" = {
            background-color = mkLiteral "@border-col";
            text-color = mkLiteral "@fg-col2";
          };

          "message" = {
            background-color = mkLiteral "@selected-col";
            margin = mkLiteral "0px";
            padding = mkLiteral "12px";
            border-radius = mkLiteral "12px";
          };

          "textbox" = {
            padding = mkLiteral "8px";
            text-color = mkLiteral "@fg-col";
            background-color = mkLiteral "transparent";
          };

          "scrollbar" = {
            width = mkLiteral "4px";
            border = mkLiteral "0";
            handle-width = mkLiteral "8px";
            padding = mkLiteral "0";
            handle-color = mkLiteral "@grey";
            background-color = mkLiteral "transparent";
          };
        };
    };
  };
}
