# Screenshot entry point, ported from Omarchy. See capture-screenshot.sh.
{
  lib,
  writeShellApplication,
  grim,
  wl-clipboard,
  libnotify,
  hyprland,
  jq,
  coreutils,
  procps,
  util-linux,
  pkgs,
  namespace,
}:
writeShellApplication {
  name = "omarchy-capture-screenshot";

  runtimeInputs = [
    grim
    wl-clipboard
    libnotify
    hyprland # hyprctl
    jq
    coreutils
    procps # pkill
    util-linux # setsid
    pkgs.${namespace}.omarchy-capture-region
    pkgs.${namespace}.tensaku # default $SCREENSHOT_EDITOR (tensaku-edit)
  ];

  text = builtins.readFile ./capture-screenshot.sh;

  meta = with lib; {
    description = "Take a screenshot with a frozen, window-snapping picker (ported from Omarchy)";
    platforms = platforms.linux;
  };
}
