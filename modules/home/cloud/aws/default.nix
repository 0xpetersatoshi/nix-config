{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cloud.aws;
in {
  options.cloud.aws = with types; {
    enable = mkBoolOpt false "Whether or not to enable aws cloud sdk";

    secretsFile = lib.mkOption {
      type = lib.types.path;
      description = "sops-encrypted YAML holding aws_account_id and aws_start_url.";
    };

    ssoRegion = lib.mkOption {
      type = lib.types.str;
      default = "us-west-2";
    };

    region = lib.mkOption {
      type = lib.types.str;
      default = "us-west-2";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.awscli2]; # drop if awscli is installed elsewhere

    sops.secrets.aws_account_id.sopsFile = cfg.secretsFile;
    sops.secrets.aws_start_url.sopsFile = cfg.secretsFile;

    # Rendered at activation; store only ever sees the placeholders, not the values.
    sops.templates."aws-config" = {
      path = "${config.home.homeDirectory}/.aws/config";
      content = ''
        [sso-session personal]
        sso_start_url = ${config.sops.placeholder.aws_start_url}
        sso_region = ${cfg.ssoRegion}
        sso_registration_scopes = sso:account:access

        [profile admin]
        sso_session = personal
        sso_account_id = ${config.sops.placeholder.aws_account_id}
        sso_role_name = AdministratorAccess
        region = ${cfg.region}

        [profile readonly]
        sso_session = personal
        sso_account_id = ${config.sops.placeholder.aws_account_id}
        sso_role_name = ReadOnlyAccess
        region = ${cfg.region}
      '';
    };
  };
}
