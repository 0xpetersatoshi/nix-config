{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.programs.ssh;
  _1passwordAgentSocketPath =
    if pkgs.stdenv.isDarwin
    then "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else "~/.1password/agent.sock";
in {
  options.cli.programs.ssh = with types; {
    enable = mkBoolOpt false "Whether or not to enable ssh.";
  };

  config = mkIf cfg.enable {
    home.file.".ssh/config.d/personal.config".source = ./personal.config;
    home.file.".ssh/github.pub".source = ./github.pub;

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      extraConfig = ''
        IdentityAgent "${_1passwordAgentSocketPath}"
      '';

      includes = [
        "~/.ssh/1Password/config"
        "~/.ssh/config.d/personal.config"
      ];

      # 1Password agent holds many keys; git forges reject after 6 auth
      # attempts. Pin the right key per host so only it is offered.
      settings."github.com" = {
        IdentitiesOnly = true;
        IdentityFile = "~/.ssh/github.pub";
      };

      settings."gitlab.com" = {
        IdentitiesOnly = true;
        IdentityFile = "~/.ssh/gitlab.pub";
      };

      settings."*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    };
  };
}
