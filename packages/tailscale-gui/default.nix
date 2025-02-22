# pkgs/applications/tailscale-gui/default.nix
{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:
stdenv.mkDerivation rec {
  pname = "tailscale-gui";
  version = "1.80.2";

  src = fetchurl {
    url = "https://pkgs.tailscale.com/stable/Tailscale-${version}-macos.zip";
    sha256 = "sha256-K09GiWkMzMMcxF5upxHLK+ZQyKVBpNSAnQuXhOGdKkY=";
  };

  nativeBuildInputs = [unzip];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r Tailscale.app $out/Applications/
  '';

  meta = with lib; {
    description = "Tailscale GUI client for macOS";
    homepage = "https://tailscale.com";
    license = licenses.unfree;
    platforms = platforms.darwin;
  };
}
