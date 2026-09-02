{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.services.virtualisation.docker;
in {
  options.services.virtualisation.docker = {
    enable = mkEnableOption "Enable docker";
  };

  config = mkIf cfg.enable {
    virtualisation = {
      docker = {
        enable = true;
        daemon.settings = {
          # Keep Docker out of common RFC1918 ranges. A compose bridge on
          # 172.20.0.0/16 shadowed a hotel network's 172.20.0.1 gateway,
          # blackholing all traffic (captive portal unreachable). Existing
          # networks keep their old subnets until recreated (compose down/up
          # or docker network prune).
          bip = "10.212.0.1/24";
          default-address-pools = [
            {
              base = "10.213.0.0/16";
              size = 24;
            }
          ];
        };
      };
    };

    environment.shellAliases = {
      DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/docker.sock";
    };
  };
}
