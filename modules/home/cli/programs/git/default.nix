{
  pkgs,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.programs.git;
  sshProgramPath =
    if pkgs.stdenv.isDarwin
    then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else if (lib.hasAttr "nixos" config)
    then "${config.programs._1password-gui.package}/share/1password/op-ssh-sign"
    else "${config.guis.security._1password-gui.package}/share/1password/op-ssh-sign";
in {
  options.cli.programs.git = with types; {
    enable = mkBoolOpt false "Whether or not to enable git.";
    email = mkOpt (nullOr str) "dev@ngml.me" "The email to use with git.";
    username = mkOpt (nullOr str) "0xPeterSatoshi" "The username to use with git.";
    signingKey = mkOpt str "" "The public key used for signing commits";
  };

  config = mkIf cfg.enable {
    home.file.".ssh/allowed_signers".text = "* ${cfg.signingKey}";
    xdg.configFile."lazygit/config.yml".source = ./lazygit.config.yaml;

    home.packages = with pkgs; [
      git-lfs
      lazygit
    ];

    programs = {
      delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          navigate = true;
          light = false;
          line-numbers = true;
          side-by-side = true;
          options.syntax-theme = "catppuccin";
        };
      };

      git = {
        enable = true;
        ignores = [
          "*~"
          "*.swp"
          ".DS_Store"
        ];
        settings = {
          user = {
            name = cfg.username;
            email = cfg.email;
          };

          alias = {
            ci = "commit";
          };

          core = {
            editor = "nvim";
          };

          init.defaultBranch = "main";
          merge.conflictstyle = "diff3";
          diff.colorMoved = "default";
          url."git@github.com:".insteadOf = "https://github.com/";

          gpg = {
            format = "ssh";
            ssh = {
              program = sshProgramPath;
              allowedSignersFile = "~/.ssh/allowed_signers";
            };
          };
        };

        lfs.enable = true;
        signing = {
          key = cfg.signingKey;
          signByDefault = true;
        };
      };
    };
  };
}
