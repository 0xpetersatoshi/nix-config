{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cloud.google;
  gdk = pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
  ]);
in {
  options.cloud.google = with types; {
    enable = mkBoolOpt false "Whether or not to enable google cloud sdk";
  };

  config = mkIf cfg.enable {
    home.packages = [
      gdk
  ];
  };
}
