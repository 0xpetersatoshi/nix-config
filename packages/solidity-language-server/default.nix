{
  lib,
  stdenv,
  fetchurl,
  nodejs,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  pname = "solidity-language-server";
  version = "0.8.11";

  src = fetchurl {
    url = "https://registry.npmjs.org/@nomicfoundation/solidity-language-server/-/solidity-language-server-${version}.tgz";
    sha256 = "sha256-/msgESBXMERTpUeUJj1GUDLIhH1rLUzA3hfHCe6fuDE=";
  };

  nativeBuildInputs = [makeWrapper];

  # Use a custom path to avoid collisions
  unpackPhase = ''
    mkdir -p $out/share/solidity-language-server
    tar -xzf $src -C $out/share/solidity-language-server --strip-components=1
  '';

  dontBuild = true;

  installPhase = ''
    # Create a bin wrapper that points to our custom location
    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/solidity-language-server \
      --add-flags "$out/share/solidity-language-server/out/server.js"
  '';

  meta = with lib; {
    description = "Language server for Solidity";
    homepage = "https://github.com/NomicFoundation/hardhat-vscode";
    license = licenses.mit;
    mainProgram = "solidity-language-server";
  };
}
