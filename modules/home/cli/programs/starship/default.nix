{
  config,
  lib,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.cli.programs.starship;
in {
  options.cli.programs.starship = with types; {
    enable = mkBoolOpt false "Whether or not to enable starship";
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
      settings = {
        "$schema" = "https://starship.rs/config-schema.json";
        add_newline = true;
        command_timeout = 1000;

        format = "$all$time$line_break$character";
        right_format = "$cmd_duration";

        character = {
          success_symbol = "[❯](bold green)";
        };

        time = {
          disabled = false;
          time_format = "%r";
          style = "bg:#1d2230";
          format = "[[$time](bg:#1C3A5E fg:#8DFBD2)]($style)";
        };

        cmd_duration = {
          format = "took: [$duration](bold yellow)";
        };

        package = {
          disabled = false;
        };

        direnv = {};
        docker_context = {};

        kubernetes = {
          disabled = true;
          contexts = [
            {
              context_pattern = "kubernetes-admin-homelab-k8s@homelab-k8s";
              context_alias = "homelab-k8s";
              style = "bold green";
            }
            {
              context_pattern = "gke_(?P<env>tally-(?:stage))_.*";
              context_alias = "gke-$env";
            }
            {
              context_pattern = "gke_tally-live_us-east4-a_us-east4-a";
              user_pattern = "gke_tally-live_us-east4-a_us-east4-a";
              style = "bold red";
              context_alias = "gke-tally-live";
            }
          ];
        };

        nix_shell = {
          disabled = false;
        };

        c.symbol = " ";
        conda.symbol = " ";
        docker_context.symbol = " ";
        git_branch.symbol = " ";
        golang.symbol = " ";

        aws = {};

        gcloud = {
          format = "(on [󱇶 $account(@$domain)(\\($project\\))]($style) )";
          style = "bold yellow";
        };

        java.symbol = " ";
        lua.symbol = " ";
        nodejs.symbol = " ";
        pijul_channel.symbol = " ";

        python = {
          symbol = " ";
          pyenv_version_name = true;
          python_binary = "python3";
        };

        ruby.symbol = " ";
        rust.symbol = " ";
      };
    };
  };
}
