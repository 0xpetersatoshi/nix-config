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

        format = "$username$hostname$localip$shlvl$singularity$directory$vcsh$fossil_branch$git_branch$git_commit$git_state$git_metrics$git_status$hg_branch$pijul_channel$docker_context$package$c$cmake$cobol$daml$dart$deno$dotnet$elixir$elm$erlang$fennel$golang$guix_shell$haskell$haxe$helm$java$julia$kotlin$gradle$lua$nim$nodejs$ocaml$opa$perl$php$pulumi$purescript$python$raku$rlang$red$ruby$rust$scala$solidity$swift$terraform$vlang$vagrant$zig$buf$nix_shell$conda$meson$spack$memory_usage$aws$gcloud$openstack$azure$env_var$crystal$custom$sudo$kubernetes$time$cmd_duration$line_break$jobs$battery$status$os$container$shell$character";

        character = {
          success_symbol = "[❯](bold green)";
        };

        time = {
          disabled = false;
          time_format = "%r";
          style = "bg:#1d2230";
          format = "[[  $time ](bg:#1C3A5E fg:#8DFBD2)]($style)";
        };

        cmd_duration = {
          format = "last command: [$duration](bold yellow)";
        };

        package = {
          disabled = true;
        };

        kubernetes = {
          disabled = false;
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

        aws.symbol = " ";
        c.symbol = " ";
        conda.symbol = " ";
        docker_context.symbol = " ";
        git_branch.symbol = " ";
        golang.symbol = " ";

        gcloud = {
          symbol = "󱇶 ";
          format = "on [$symbol$account(@$domain)(\\($project\\))]($style) ";
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
