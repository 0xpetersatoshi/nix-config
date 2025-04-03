{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.styles.stylix;
in {
  imports = with inputs; [
    stylix.homeManagerModules.stylix
  ];
  options.styles.stylix = {
    enable = lib.mkEnableOption "Enable stylix";
    wallpaperPath = lib.mkOption {
      type = lib.types.path;
      default = ../../../../wallpaper/ultrawide/winter_in_the_desert_illustration-wallpaper-5120x2160.jpg;
      description = "Path to the wallpaper image to use with stylix";
    };
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
      image = cfg.wallpaperPath;
      # targets = {
      #   kde = {
      #     enable = true;
      #   };
      # };

      # iconTheme = {
      #   enable = true;
      #   package = pkgs.catppuccin-papirus-folders.override {
      #     flavor = "mocha";
      #     accent = "lavender";
      #   };
      #   dark = "Papirus-Dark";
      # };

      fonts = {
        emoji = {
          name = "Noto Color Emoji";
          package = pkgs.noto-fonts-color-emoji;
        };
        monospace = {
          name = "JetBrains Mono";
          package = pkgs.unstable.nerd-fonts.jetbrains-mono;
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
