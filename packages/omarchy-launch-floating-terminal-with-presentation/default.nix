# NixOS-native equivalent of Omarchy's
# `omarchy-launch-floating-terminal-with-presentation`, provided under the same
# command name so Omarchy's vendored nautilus-python `transcode.py` extension
# can launch a job in a floating terminal.
#
# Takes a single command string, runs it in a floating ghostty window, then
# pauses so output stays visible. The `com.omarchy.transcode` app-id is matched
# by a Hyprland float rule (see modules/home/desktops/hyprland/windowrules.nix).
{
  lib,
  writeShellApplication,
  ghostty,
  util-linux, # setsid
}:
writeShellApplication {
  name = "omarchy-launch-floating-terminal-with-presentation";

  runtimeInputs = [ghostty util-linux];

  text = ''
    # transcode.py passes the whole job as one argument; tolerate extra args too.
    # Hand it to the spawned shell via the environment so nothing expands here.
    OMARCHY_PRESENT_CMD="$*"
    export OMARCHY_PRESENT_CMD

    # The body runs in the spawned terminal: run the job, then keep the window up
    # until dismissed (skip the pause on Ctrl-C, matching upstream's exit-130
    # check). shellcheck can't see the runtime expansion, so silence SC2016.
    # shellcheck disable=SC2016
    exec setsid -f ghostty \
      --class=com.omarchy.transcode \
      --title=Transcode \
      -e bash -c '
        eval "$OMARCHY_PRESENT_CMD"
        status=$?
        if [[ $status -ne 130 ]]; then
          printf "\n"
          read -r -p "Done. Press enter to close… " _
        fi
      '
  '';

  meta = with lib; {
    description = "Launch a floating ghostty terminal running a presented command (NixOS-native)";
    platforms = platforms.linux;
  };
}
