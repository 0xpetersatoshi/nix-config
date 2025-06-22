{
  lib,
  stdenv,
  fetchurl,
  nodejs,
  makeWrapper,
}: let
  # Fetch the missing dependencies
  solidityAnalyzer = fetchurl {
    url = "https://registry.npmjs.org/@nomicfoundation/solidity-analyzer/-/solidity-analyzer-0.1.1.tgz";
    hash = "sha256-5UCEVrGnP7lbYDRDnPVmtCHlLZUu/D6KSxmNGAuuHZ0=";
  };

  solidityAnalyzerLinux = fetchurl {
    url = "https://registry.npmjs.org/@nomicfoundation/solidity-analyzer-linux-x64-gnu/-/solidity-analyzer-linux-x64-gnu-0.1.1.tgz";
    hash = "sha256-T0Xz8IU99HwfYxK4njpuMdzmGG/XpR/+zhKrErde/PY=";
  };

  slang = fetchurl {
    url = "https://registry.npmjs.org/@nomicfoundation/slang/-/slang-1.0.0.tgz";
    hash = "sha256-rVPEwtxWRPtZVb/0CvsZs7Yik40hJpFiDwiRNo8+bsM=";
  };

  preview2Shim = fetchurl {
    url = "https://registry.npmjs.org/@bytecodealliance/preview2-shim/-/preview2-shim-0.17.2.tgz";
    hash = "sha256-k8gh1HdeEA/yd44ZqiPr8nTEhj6y4r9L1XaSXAxBbU8=";
  };
in
  stdenv.mkDerivation rec {
    pname = "nomicfoundation-solidity-language-server";
    version = "0.8.20";

    src = fetchurl {
      url = "https://registry.npmjs.org/@nomicfoundation/solidity-language-server/-/solidity-language-server-${version}.tgz";
      hash = "sha256-YsBom0bNxplKlNdzeMQSaVejwI4zjcv4MFTYsN5DD6A=";
    };

    nativeBuildInputs = [makeWrapper];

    unpackPhase = ''
      tar -xzf $src
      cd package
    '';

    dontBuild = true;

    installPhase = ''
      # Install the main package
      mkdir -p $out/lib/node_modules/@nomicfoundation/solidity-language-server
      cp -r * $out/lib/node_modules/@nomicfoundation/solidity-language-server/

      # Install the missing dependencies
      mkdir -p $out/lib/node_modules/@nomicfoundation/solidity-language-server/node_modules/@nomicfoundation

      # Extract and install solidity-analyzer
      cd $out/lib/node_modules/@nomicfoundation/solidity-language-server/node_modules/@nomicfoundation
      tar -xzf ${solidityAnalyzer}
      mv package solidity-analyzer

      # Extract and install solidity-analyzer-linux-x64-gnu
      tar -xzf ${solidityAnalyzerLinux}
      mv package solidity-analyzer-linux-x64-gnu

      # Extract and install slang
      tar -xzf ${slang}
      mv package slang

      # Install @bytecodealliance/preview2-shim dependency
      mkdir -p $out/lib/node_modules/@nomicfoundation/solidity-language-server/node_modules/@bytecodealliance
      cd $out/lib/node_modules/@nomicfoundation/solidity-language-server/node_modules/@bytecodealliance
      tar -xzf ${preview2Shim}
      mv package preview2-shim

      # Create the binary wrapper
      mkdir -p $out/bin
      makeWrapper ${nodejs}/bin/node $out/bin/nomicfoundation-solidity-language-server \
        --add-flags "$out/lib/node_modules/@nomicfoundation/solidity-language-server/out/index.js"
    '';

    meta = with lib; {
      description = "Language server for Solidity";
      homepage = "https://github.com/NomicFoundation/hardhat-vscode";
      license = licenses.mit;
      mainProgram = "nomicfoundation-solidity-language-server";
    };
  }
