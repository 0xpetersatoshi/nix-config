{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.cli.programs.git;
  sshProgramPath =
    if pkgs.stdenv.isDarwin
    then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else "${config.guis.security._1password.package}/share/1password/op-ssh-sign";
in {
  options.cli.programs.git = with types; {
    enable = mkBoolOpt false "Whether or not to enable git.";
    email = mkOpt (nullOr str) "dev@ngml.me" "The email to use with git.";
    username = mkOpt (nullOr str) "0xPeterSatoshi" "The username to use with git.";
    signingKey = mkOpt str "" "The public key used for signing commits";
  };

  config = mkIf cfg.enable {
    home.file.".ssh/allowed_signers".text = "* ${cfg.signingKey}";
    xdg.configFile."lazygit/config.yml".text = '''';

    home.packages = with pkgs; [
      git-lfs
      lazygit
    ];

    programs.git = {
      enable = true;
      userName = cfg.username;
      userEmail = cfg.email;
      ignores = [
        "*~"
        "*.swp"
        ".DS_Store"
      ];
      aliases = {
        ci = "commit";
      };
      extraConfig = {
        init.defaultBranch = "main";
        core = {
          editor = "nvim";
        };
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

      delta = {
        enable = true;
        options = {
          navigate = true;
          light = false;
          line-numbers = true;
          side-by-side = true;
          options.syntax-theme = "catppuccin";
        };
      };
    };
  };
}
