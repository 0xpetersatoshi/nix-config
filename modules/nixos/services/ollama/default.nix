{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.services.${namespace}.ollama;
in {
  options.services.${namespace}.ollama = {
    enable = mkEnableOption "Enable the ollama service";
    # `services.ollama.acceleration` was removed upstream; the acceleration
    # backend is now chosen by picking the matching package.
    package = lib.mkPackageOption pkgs "ollama" {
      example = "pkgs.ollama-rocm";
    };
    rocmOverrideGfx = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The value for HSA_OVERRIDE_GFX_VERSION";
    };
    loadModels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of default models to download";
      example = ["deepseek-r1:32b"];
    };
  };

  config = mkIf cfg.enable {
    services = {
      ollama = {
        # Left on the upstream defaults: DynamicUser + /var/lib/ollama.
        # Running the daemon as a login user forces it to be a system user
        # (upstream asserts on it) — the CLI talks to it over HTTP anyway.
        enable = true;
        openFirewall = true;
        package = cfg.package;
        loadModels = cfg.loadModels;
        rocmOverrideGfx = cfg.rocmOverrideGfx;
      };
    };
  };
}
