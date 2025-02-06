{
  lib,
  pkgs,
  config,
  namespace,
  ...
}: let
  cfg = config.styles.stylix;
in {
  options.styles.stylix = {
    enable = lib.mkEnableOption "Enable stylix";
  };

  config = lib.mkIf cfg.enable {
    # fonts = {
    #   enableDefaultPackages = true;
    #   fontDir.enable = true;
    #   fontconfig = {
    #     enable = true;
    #     useEmbeddedBitmaps = true;
    #
    #     localConf = ''
    #       <?xml version="1.0"?>
    #       <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    #       <fontconfig>
    #         <!-- Add Symbols Nerd Font as a global fallback -->
    #         <match target="pattern">
    #           <test name="family" compare="not_eq">
    #             <string>Symbols Nerd Font</string>
    #           </test>
    #           <edit name="family" mode="append">
    #             <string>Symbols Nerd Font</string>
    #           </edit>
    #         </match>
    #       </fontconfig>
    #     '';
    #   };
    # };

    stylix = {
      enable = true;
      autoEnable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
      homeManagerIntegration.autoImport = false;
      homeManagerIntegration.followSystem = false;
      targets.nixvim.enable = false;

      # image = pkgs.${namespace}.wallpapers.windows-error;
      image = pkgs.fetchurl {
        url = "https://codeberg.org/lunik1/nixos-logo-gruvbox-wallpaper/media/branch/master/png/gruvbox-dark-blue.png";
        sha256 = "1jrmdhlcnmqkrdzylpq6kv9m3qsl317af3g66wf9lm3mz6xd6dzs";
      };

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
          popups = 12;
        };
      };
    };
  };
}
