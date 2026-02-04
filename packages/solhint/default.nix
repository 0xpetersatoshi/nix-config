{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "solhint";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "protofire";
    repo = "solhint";
    tag = "v${version}";
    hash = "sha256-hWf+4vSSqjSvN2SFC0z07QvnhQj1IWy3G1jh/E8Fuv8=";
  };

  npmDepsHash = "sha256-DbkjOZ/TtHHvmWPgQA8yuoTFLfXQg0LYwe9caZ0tCOc=";

  dontNpmBuild = true;

  meta = {
    description = "Solidity linter for code style and security";
    homepage = "https://github.com/protofire/solhint";
    license = lib.licenses.mit;
    mainProgram = "solhint";
  };
}
