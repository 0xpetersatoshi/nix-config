{
  config,
  lib,
  pkgs,
  inputs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.roles.desktop.addons.nautilus;

  # Vendor Omarchy's nautilus-python extensions straight from the upstream
  # source tree (pinned by the `omarchy` flake input). Run `nix flake update
  # omarchy` to pull upstream changes, including any new extensions they add.
  #
  # localsend.py works once `localsend` is on PATH. transcode.py shells out to
  # `omarchy-transcode` and
  # `omarchy-launch-floating-terminal-with-presentation`; we ship NixOS-native
  # equivalents of both below (see packages/omarchy-transcode and
  # packages/omarchy-launch-floating-terminal-with-presentation).
  omarchy-nautilus-extensions =
    pkgs.runCommandLocal "omarchy-nautilus-extensions" {} ''
      mkdir -p "$out/share/nautilus-python/extensions"
      cp ${inputs.omarchy}/default/nautilus-python/extensions/*.py \
        "$out/share/nautilus-python/extensions/"
    '';
in {
  options.roles.desktop.addons.nautilus = with types; {
    enable = mkBoolOpt false "Whether to enable the gnome file manager.";
  };

  config = mkIf cfg.enable {
    services.gvfs.enable = true;
    services.udisks2.enable = true;

    environment = {
      sessionVariables = {
        NAUTILUS_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";
        NAUTILUS_4_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";
        GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
          gst-plugins-good
          gst-plugins-bad
          gst-plugins-ugly
          gst-libav
        ]);
      };

      pathsToLink = [
        "/share/nautilus-python/extensions"
      ];

      systemPackages = with pkgs; [
        nautilus # gnome file manager
        ffmpegthumbnailer # thumbnails
        gst_all_1.gst-libav # thumbnails
        nautilus-open-any-terminal
        nautilus-python
        omarchy-nautilus-extensions # vendored Omarchy right-click actions
        # Commands the vendored transcode.py extension shells out to.
        pkgs.${namespace}.omarchy-transcode
        pkgs.${namespace}.omarchy-launch-floating-terminal-with-presentation
        # `localsend` alias so the vendored localsend.py extension resolves it.
        pkgs.${namespace}.localsend-cli-alias
      ];
    };

    snowfallorg.users.${config.user.name}.home.config = {
      dconf.settings = {
        "org/gnome/desktop/privacy" = {
          remember-recent-files = false;
        };
        "com/github/stunkymonkey/nautilus-open-any-terminal" = {
          terminal = "ghostty";
        };
      };
    };
  };
}
