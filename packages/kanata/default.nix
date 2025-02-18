{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "kanata";
  version = "1.8.0";

  src = fetchurl {
    url = "https://github.com/jtroo/kanata/releases/download/v${version}/kanata_macos_arm64";
    hash = "sha256-oHIpb1Hvi3gJUYnYJWXGs1QPoHerdWCA1+bHjG4QAQ4=";
  };

  # Skip unnecessary phases
  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/kanata
    chmod +x $out/bin/kanata
  '';

  meta = with lib; {
    description = "Multi-layer keyboard remapper";
    homepage = "https://github.com/jtroo/kanata";
    license = licenses.lgpl3Only;
    platforms = platforms.darwin;
    mainProgram = "kanata";
  };
}
