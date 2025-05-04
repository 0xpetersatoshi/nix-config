{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.services.${namespace}.ollama;
in {
  options.services.${namespace}.ollama = {
    enable = mkEnableOption "Enable the ollama service";
    accelerationType = lib.mkOption {
      type = lib.types.str;
      default = "rocm";
      description = "The interface to use for hardware acceleration";
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
        enable = true;
        user = config.user.name;
        openFirewall = true;
        loadModels = cfg.loadModels;
        acceleration = cfg.acceleration;
        rocmOverrideGfx = cfg.rocmOverrideGfx;
      };
    };

    environment.systemPackages = with pkgs; [
      ollamatray
    ];
  };
}
