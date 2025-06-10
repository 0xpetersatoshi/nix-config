{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "opencode";
  version = "0.0.53";

  src = fetchFromGitHub {
    owner = "opencode-ai";
    repo = "opencode";
    rev = "v${finalAttrs.version}";
    hash = "sha256-s17LHvyQrw2lBtZwAZu4OsrTJd+xSJXiGdSuDppGYAs=";
  };

  vendorHash = "sha256-Kcwd8deHug7BPDzmbdFqEfoArpXJb1JtBKuk+drdohM=";

  checkFlags = let
    skippedTests = [
      # permission denied
      "TestBashTool_Run"
      "TestSourcegraphTool_Run"
      "TestLsTool_Run"
    ];
  in ["-skip=^${lib.concatStringsSep "$|^" skippedTests}$"];

  meta = {
    description = "Powerful terminal-based AI assistant providing intelligent coding assistance";
    homepage = "https://github.com/opencode-ai/opencode";
    mainProgram = "opencode";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      zestsystem
    ];
  };
})

