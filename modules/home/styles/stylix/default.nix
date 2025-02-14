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
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = true;
      polarity = "dark";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
      image = ../../../../wallpaper/no-mans-sky.jpg;
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
