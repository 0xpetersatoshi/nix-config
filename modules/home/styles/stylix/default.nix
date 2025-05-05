{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.styles.stylix;
in {
  options.styles.stylix = {
    enable = lib.mkEnableOption "Enable stylix";

    theme = lib.mkOption {
      type = lib.types.str;
      default = "catppuccin-macchiato";
      description = "Stylix theme to apply";
    };
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = true;
      polarity = "dark";
      # to view/list themes: `nix build nixpkgs#base16-schemes && cd result && tree .`
      # gallery also available here: https://tinted-theming.github.io/tinted-gallery/
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.theme}.yaml";

      targets = {
        gtk.enable = !config.desktops.addons.gtk.enable;
        qt.enable = !config.desktops.addons.qt.enable;
      };

      # iconTheme = {
      #   enable = true;
      #   package = pkgs.catppuccin-papirus-folders.override {
      #     flavor = "mocha";
      #     accent = "lavender";
      #   };
      #   dark = "Papirus-Dark";
      # };

      cursor = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 24;
      };

      fonts = {
        emoji = {
          name = "Noto Color Emoji";
          package = pkgs.noto-fonts-color-emoji;
        };
        monospace = {
          name = "JetBrains Mono";
          package = pkgs.nerd-fonts.jetbrains-mono;
        };
        sansSerif = {
          name = "Noto Sans";
          package = pkgs.noto-fonts;
        };
        serif = {
          name = "Noto Serif";
          package = pkgs.noto-fonts;
        };

        sizes = {
          terminal = 14;
          applications = 12;
        };
      };
    };
  };
}
