# Screen recording toggle, ported from Omarchy. See
# capture-screenrecording.sh (no webcam overlay, no Omarchy shell indicator).
{
  lib,
  writeShellApplication,
  gpu-screen-recorder,
  ffmpeg,
  mpv,
  libnotify,
  hyprland,
  jq,
  coreutils,
  procps,
  gnugrep,
  util-linux,
  pkgs,
  namespace,
}:
writeShellApplication {
  name = "omarchy-capture-screenrecording";

  runtimeInputs = [
    gpu-screen-recorder
    ffmpeg # ffmpeg + ffprobe
    mpv # playback from the saved notification
    libnotify
    hyprland # hyprctl
    jq
    coreutils
    procps # pgrep/pkill
    gnugrep
    util-linux # setsid
    pkgs.${namespace}.omarchy-capture-region
  ];

  text = builtins.readFile ./capture-screenrecording.sh;

  meta = with lib; {
    description = "Start or stop a screen recording (ported from Omarchy)";
    platforms = platforms.linux;
  };
}
