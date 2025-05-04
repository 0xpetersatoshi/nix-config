{...}: final: prev: {
  # Fix the SteamOS Manager package
  steamos-manager = prev.steamos-manager.overrideAttrs (old: {
    # Remove the problematic patch
    patches = builtins.filter (
      p:
        !(builtins.match ".*disable-ftrace.patch" p != null)
    ) (old.patches or []);

    # Or use a fixed version of the patch
    # patches = (old.patches or []) ++ [ ./fixed-disable-ftrace.patch ];
  });
}
