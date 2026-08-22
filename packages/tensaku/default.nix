# Tensaku -- "Modern Screenshot Annotation", a GTK4/libadwaita fork of Satty and
# the annotation editor Omarchy opens from its screenshot notification.
#
# Upstream's flake only exposes a devShell, so this packages it directly; the
# build/install steps mirror upstream's AUR PKGBUILD, and the buildInputs come
# from the dependency list in that same flake's devShell.
{
  lib,
  fetchFromGitHub,
  rustPlatform,
  runtimeShell,
  pkg-config,
  wrapGAppsHook4,
  glib,
  gtk4,
  gtk4-layer-shell,
  libadwaita,
  libepoxy,
  libGL,
  fontconfig,
  libxkbcommon,
}: let
  version = "0.28.0";

  src = fetchFromGitHub {
    owner = "jondkinney";
    repo = "tensaku";
    rev = "v${version}";
    hash = "sha256-rkLDfzGFonNghDspDDH6sLikOC/5TZtUCvIPHWtdLXI=";
  };
in
  rustPlatform.buildRustPackage {
    pname = "tensaku";
    inherit version src;

    cargoLock.lockFile = "${src}/Cargo.lock";

    # Upstream ships the release build behind this feature flag.
    buildFeatures = ["ci-release"];

    nativeBuildInputs = [
      pkg-config
      wrapGAppsHook4
      glib
    ];

    buildInputs = [
      gtk4
      gtk4-layer-shell
      libadwaita
      libepoxy
      libGL
      fontconfig
      libxkbcommon
    ];

    # `tensaku` takes no positional filename, so upstream ships a small wrapper
    # that maps a bare image path onto the right flags. Omarchy's screenshot
    # scripts call it as `tensaku-edit`.
    postInstall = ''
      install -Dm755 assets/tensaku-edit "$out/bin/tensaku-edit"
      # The wrapper calls `tensaku` by bare name; point it at this build so it
      # works regardless of the caller's PATH. Must happen before
      # wrapGAppsHook4 wraps the script.
      substituteInPlace "$out/bin/tensaku-edit" \
        --replace-fail "exec tensaku " "exec $out/bin/tensaku "
      # Upstream's wrapper hardcodes #!/bin/bash, which does not exist on
      # NixOS; without this it fails silently with "No such file or directory".
      # wrapGAppsHook4 renames the script out from under the automatic
      # patchShebangs pass, so rewrite the interpreter explicitly.
      substituteInPlace "$out/bin/tensaku-edit" \
        --replace-fail "#!/bin/bash" "#!${runtimeShell}"
      install -Dm644 dev.tensaku.Tensaku.desktop \
        "$out/share/applications/dev.tensaku.Tensaku.desktop"
      install -Dm644 assets/tensaku.svg \
        "$out/share/icons/hicolor/scalable/apps/dev.tensaku.Tensaku.svg"

      # man pages and completions are generated during the build (clap_mangen),
      # so only install them when they actually got produced.
      [ -f man/tensaku.1 ] && install -Dm644 man/tensaku.1 "$out/share/man/man1/tensaku.1"
      [ -f completions/tensaku.bash ] && install -Dm644 completions/tensaku.bash \
        "$out/share/bash-completion/completions/tensaku"
      [ -f completions/tensaku.fish ] && install -Dm644 completions/tensaku.fish \
        "$out/share/fish/vendor_completions.d/tensaku.fish"
      [ -f completions/_tensaku ] && install -Dm644 completions/_tensaku \
        "$out/share/zsh/site-functions/_tensaku"
      true
    '';

    meta = with lib; {
      description = "Modern screenshot annotation (GTK4 fork of Satty)";
      homepage = "https://tensaku.dev";
      license = licenses.mpl20;
      mainProgram = "tensaku";
      platforms = platforms.linux;
    };
  }
