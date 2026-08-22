# OCR text extraction from a screen region, ported from Omarchy.
{
  lib,
  writeShellApplication,
  grim,
  slurp,
  hyprpicker,
  tesseract,
  wl-clipboard,
  libnotify,
  coreutils,
}:
writeShellApplication {
  name = "omarchy-capture-text";

  runtimeInputs = [
    grim
    slurp
    hyprpicker
    tesseract
    wl-clipboard
    libnotify
    coreutils
  ];

  text = builtins.readFile ./capture-text.sh;

  meta = with lib; {
    description = "Extract text from a screen region with OCR (ported from Omarchy)";
    platforms = platforms.linux;
  };
}
