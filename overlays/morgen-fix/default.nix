{...}: final: prev: {
  morgen = prev.morgen.overrideAttrs (oldAttrs: {
    # Morgen disables hardware acceleration on Linux which causes the Sentry
    # GPU context integration to throw an unhandled rejection, crashing the app.
    # Patch main.js inside the asar to remove the disableHardwareAcceleration call.
    installPhase = builtins.replaceStrings
      ["asar pack --unpack='{*.node,*.ftz,rect-overlay}' \"$TMP/work\" $out/opt/Morgen/resources/app.asar"]
      [''
        substituteInPlace $TMP/work/dist/main.js \
          --replace-fail "zj&&ee.app.disableHardwareAcceleration()" "void 0"
        asar pack --unpack='{*.node,*.ftz,rect-overlay}' "$TMP/work" $out/opt/Morgen/resources/app.asar
      '']
      oldAttrs.installPhase;
  });
}
