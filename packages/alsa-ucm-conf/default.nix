{
  directoryListingUpdater,
  fetchurl,
  lib,
  stdenv,
  coreutils,
  kmod,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "alsa-ucm-conf";
  version = "1.2.13"; # Updated version

  src = fetchurl {
    url = "mirror://alsa/lib/alsa-ucm-conf-${finalAttrs.version}.tar.bz2";
    hash = "sha256-RIO245g8ygj9Mmpz+65Em1A25ET7GgfA3udLUEt6ta8=";
  };

  dontBuild = true;

  installPhase =
    ''
      runHook preInstall
      substituteInPlace ucm2/lib/card-init.conf \
        --replace-fail "/bin/rm" "${coreutils}/bin/rm" \
        --replace-fail "/bin/mkdir" "${coreutils}/bin/mkdir"
      files=(
          "ucm2/HDA/HDA.conf"
          "ucm2/codecs/rt715/init.conf"
          "ucm2/codecs/rt715-sdca/init.conf"
          "ucm2/Intel/cht-bsw-rt5672/cht-bsw-rt5672.conf"
          "ucm2/Intel/bytcr-rt5640/bytcr-rt5640.conf"
      )
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      for file in "''${files[@]}"; do
          # Check if file exists before substituting
          if [ -f "$file" ]; then
              substituteInPlace "$file" \
                  --replace-fail '/sbin/modprobe' '${kmod}/bin/modprobe'
          fi
      done
    ''
    + ''
      mkdir -p $out/share/alsa
      cp -r ucm ucm2 $out/share/alsa

      # Create symlinks at the root level for easier access via ALSA_CONFIG_UCM2
      mkdir -p $out/ucm2
      ln -s $out/share/alsa/ucm2/* $out/ucm2/

      runHook postInstall
    '';

  passthru.updateScript = directoryListingUpdater {
    url = "https://www.alsa-project.org/files/pub/lib/";
  };

  meta = {
    homepage = "https://www.alsa-project.org/";
    description = "ALSA Use Case Manager configuration (v1.2.13 for Lunar Lake support)";
    longDescription = ''
      The Advanced Linux Sound Architecture (ALSA) provides audio and
      MIDI functionality to the Linux-based operating system.
      This is version 1.2.13 which includes improved support for Intel Lunar Lake.
    '';
    license = lib.licenses.bsd3;
    maintainers = [lib.maintainers.roastiek];
    platforms = lib.platforms.linux ++ lib.platforms.freebsd;
  };
})
