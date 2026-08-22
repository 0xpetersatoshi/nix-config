# Region picker shared by the screenshot and OCR commands. See
# capture-region.sh for behaviour and for how this differs from Omarchy's
# original (hyprlang instead of Lua event hooks).
{
  lib,
  writeShellApplication,
  slurp,
  hyprpicker,
  hyprland,
  jq,
  coreutils,
  procps,
}:
writeShellApplication {
  name = "omarchy-capture-region";

  runtimeInputs = [
    slurp
    hyprpicker
    hyprland # hyprctl
    jq
    coreutils
    procps # pgrep/pkill
  ];

  text = builtins.readFile ./capture-region.sh;

  meta = with lib; {
    description = "Pick a screen region over frozen screen content (ported from Omarchy)";
    platforms = platforms.linux;
  };
}
