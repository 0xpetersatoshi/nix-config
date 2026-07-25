# pi 0.82.1 is not yet in nixpkgs (latest there is 0.80.10), and building
# from GitHub source no longer works offline: upstream now generates model
# data at build time by hitting models.dev + provider APIs (network, which the
# nix sandbox forbids). The published npm tarball already ships a prebuilt
# dist/ with that data baked in, so we install that instead of building.
{...}: final: prev: {
  pi-coding-agent = prev.buildNpmPackage rec {
    pname = "pi-coding-agent";
    version = "0.82.1";

    src = prev.fetchurl {
      url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
      hash = "sha256-g0OrlcurV2by9dSIRN+NsT53Lq0uKXYWbLuCCinay30=";
    };

    npmDepsHash = "sha256-0PFNMxIyLgV6kKyXFaeNsv/MlgzCBjyHgwMKRtKy3lw=";
    npmDepsFetcherVersion = 2;

    # The published tarball's npm-shrinkwrap.json is out of sync with its
    # package.json in two ways that break an offline `npm ci`:
    #  1. It omits `integrity` for the 3 sibling packages (they were workspace
    #     symlinks at publish time), which makes prefetch-npm-deps panic.
    #  2. package.json declares devDependencies (e.g. @types/cross-spawn) that
    #     are absent from the lockfile, so npm tries to fetch them live.
    # dist/ is already built, so drop devDependencies entirely and backfill the
    # sibling integrity hashes from the registry.
    postPatch = ''
      ${prev.jq}/bin/jq 'del(.devDependencies)' package.json > package.json.tmp
      mv package.json.tmp package.json
      ${prev.jq}/bin/jq '
        del(.packages[""].devDependencies)
        | .packages["node_modules/@earendil-works/pi-ai"].integrity = "sha512-3WFYRhEp3lQB3444EhPMBcM7zSaEUE3eJgHOR7s4081NLqbw/FsWilIKWXSua0Gv3sRr7m9xMidR3pPDE7jI/A=="
        | .packages["node_modules/@earendil-works/pi-agent-core"].integrity = "sha512-Z3kloziJIE2dmrisRckZX8zDca/gIv9/YdFAzeoqpHiLV2wsni6bL4hInNSjVKLbqT+4kqLIkph2JQLKvSepjg=="
        | .packages["node_modules/@earendil-works/pi-tui"].integrity = "sha512-9yN8hALfKaxZq7n54EMxqhFCWnMi6LHkraMJ/1YjHiATq75XrI6XDMVppn9EDtiK7Fks8hUe1SDXUTrIvwRWfQ=="
      ' npm-shrinkwrap.json > npm-shrinkwrap.json.tmp
      mv npm-shrinkwrap.json.tmp npm-shrinkwrap.json
    '';

    # dist/ is already built and shipped in the tarball.
    dontNpmBuild = true;
    npmFlags = [ "--ignore-scripts" "--omit=dev" ];

    nativeBuildInputs = [ prev.makeBinaryWrapper ];

    postFixup = ''
      wrapProgram $out/bin/pi --prefix PATH : ${prev.lib.makeBinPath [ prev.ripgrep prev.fd ]}
    '';

    meta = prev.pi-coding-agent.meta;
  };
}
