# Omarchy's nautilus-python `localsend.py` extension resolves the CLI with
# `shutil.which("localsend")`, but nixpkgs installs the binary as
# `localsend_app`. This shim exposes a `localsend` command that execs the real
# binary, so the "Send via LocalSend" right-click action resolves on NixOS.
{
  lib,
  writeShellScriptBin,
  localsend,
}:
writeShellScriptBin "localsend" ''
  exec ${localsend}/bin/localsend_app "$@"
''
// {
  meta = {
    description = "`localsend` -> `localsend_app` command alias for Omarchy's nautilus extension";
    platforms = lib.platforms.linux;
  };
}
