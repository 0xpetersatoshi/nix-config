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
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

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
          package = pkgs.jetbrains-mono;
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
          terminal = 13;
          applications = 12;
        };
      };

      image = pkgs.fetchurl {
        url = "https://codeberg.org/lunik1/nixos-logo-gruvbox-wallpaper/media/branch/master/png/gruvbox-dark-blue.png";
        sha256 = "1jrmdhlcnmqkrdzylpq6kv9m3qsl317af3g66wf9lm3mz6xd6dzs";
      };
    };
  };
}
