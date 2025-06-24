{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    types
    ;

  inherit (lib.${namespace}) mkOpt;

  cfg = config.${namespace}.theme.stylix;
in {
  options.${namespace}.theme.stylix = {
    enable = mkEnableOption "stylix theme for applications";
    theme = mkOpt types.str "tokyo-night-storm" "base16 theme file name";

    cursor = {
      name = mkOpt types.str "catppuccin-macchiato-blue-cursors" "The name of the cursor theme to apply.";
      package = mkOpt types.package (
        if pkgs.stdenv.hostPlatform.isLinux
        then pkgs.catppuccin-cursors.macchiatoBlue
        else pkgs.emptyDirectory
      ) "The package to use for the cursor theme.";
      size = mkOpt types.int 32 "The size of the cursor.";
    };

    icon = {
      name = mkOpt types.str "Papirus-Dark" "The name of the icon theme to apply.";
      package = mkOpt types.package (pkgs.catppuccin-papirus-folders.override {
        accent = "blue";
        flavor = "macchiato";
      }) "The package to use for the icon theme.";
    };
  };

  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.theme}.yaml";

      cursor = cfg.cursor;

      fonts = {
        sizes = {
          desktop = 12;
          applications = 12;
          terminal = 14;
          popups = 12;
        };

        serif = {
          package = pkgs.monaspace;
          name =
            if pkgs.stdenv.hostPlatform.isDarwin
            then "Monaspace Neon"
            else "MonaspaceNeon";
        };
        sansSerif = {
          package = pkgs.monaspace;
          name =
            if pkgs.stdenv.hostPlatform.isDarwin
            then "Monaspace Neon"
            else "MonaspaceNeon";
        };
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font Mono";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };

      iconTheme =
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux)
        {
          enable = true;
          inherit (cfg.icon) package;
          dark = cfg.icon.name;
          # TODO: support custom light
          light = cfg.icon.name;
        };

      polarity = "dark";

      opacity = {
        desktop = 1.0;
        applications = 0.90;
        terminal = 0.90;
        popups = 1.0;
      };

      targets = {
        hyprpaper.enable = lib.mkForce false;
      };
    };
  };
}
