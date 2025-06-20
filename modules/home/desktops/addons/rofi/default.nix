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
    package = mkPackageOpt pkgs.rofi-wayland "Package to use for rofi";
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
          #"@import" = "default";
          "*" = {
            bg-col = mkLiteral "#${colors.base00}";
            bg-col-light = mkLiteral "#${colors.base00}";
            border-col = mkLiteral "#${colors.base00}";
            selected-col = mkLiteral "#${colors.base00}";
            blue = mkLiteral "#${colors.base0D}";
            fg-col = mkLiteral "#${colors.base05}";
            fg-col2 = mkLiteral "#${colors.base08}";
            grey = mkLiteral "#737994";
            width = 600;
          };

          "element-text, element-icon , mode-switcher" = {
            background-color = mkLiteral "inherit";
            text-color = mkLiteral "inherit";
          };

          "window" = {
            height = mkLiteral "360px";
            border = mkLiteral "3px";
            border-color = mkLiteral "@border-col";
            background-color = mkLiteral "@bg-col";
          };

          "mainbox" = {
            background-color = mkLiteral "@bg-col";
          };

          "inputbar" = {
            children = mkLiteral "[prompt,entry]";
            background-color = mkLiteral "@bg-col";
            border-radius = mkLiteral "5px";
            padding = mkLiteral "2px";
          };

          "prompt" = {
            background-color = mkLiteral "@blue";
            padding = mkLiteral "6px";
            text-color = mkLiteral "@bg-col";
            border-radius = mkLiteral "3px";
            margin = mkLiteral "20px 0px 0px 20px";
          };

          "textbox-prompt-colon" = {
            expand = false;
            #str =  mkLiteral ":";
          };

          "entry" = {
            padding = mkLiteral "6px";
            margin = mkLiteral "20px 0px 0px 10px";
            text-color = mkLiteral "@fg-col";
            background-color = mkLiteral "@bg-col";
          };

          "listview" = {
            border = mkLiteral "0px 0px 0px";
            padding = mkLiteral "6px 0px 0px";
            margin = mkLiteral "10px 0px 0px 20px";
            columns = 2;
            lines = 5;
            background-color = mkLiteral "@bg-col";
          };

          "element" = {
            padding = mkLiteral "5px";
            background-color = mkLiteral "@bg-col";
            text-color = mkLiteral "@fg-col";
          };

          "element-icon" = {
            size = mkLiteral "25px";
          };

          "element selected" = {
            background-color = mkLiteral "@selected-col";
            text-color = mkLiteral "@fg-col2";
          };

          "mode-switcher" = {
            spacing = 0;
          };

          "button" = {
            padding = mkLiteral "10px";
            background-color = mkLiteral "@bg-col-light";
            text-color = mkLiteral "@grey";
            vertical-align = mkLiteral "0.5";
            horizontal-align = mkLiteral "0.5";
          };

          "button selected" = {
            background-color = mkLiteral "@bg-col";
            text-color = mkLiteral "@blue";
          };

          "message" = {
            background-color = mkLiteral "@bg-col-light";
            margin = mkLiteral "2px";
            padding = mkLiteral "2px";
            border-radius = mkLiteral "5px";
          };

          "textbox" = {
            padding = mkLiteral "6px";
            margin = mkLiteral "20px 0px 0px 20px";
            text-color = mkLiteral "@blue";
            background-color = mkLiteral "@bg-col-light";
          };
        };
    };
  };
}
