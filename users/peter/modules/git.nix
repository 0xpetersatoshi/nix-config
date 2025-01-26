{ pkgs, ... }@inputs:

{
  home.shellAliases = {
    g = "git";
    lg = "lazygit";
  };

  # https://nixos.asia/en/git
  programs = {
    git = {
      enable = true;
      userName = inputs.userSettings.gitUsername;
      userEmail = inputs.userSettings.userEmail;
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
      };

      lfs.enable = true;
      signing = {
        key = inputs.userSettings.gitSigningKey;
        signByDefault = true;
        gpgPath = "${pkgs.unstable._1password-gui}/op-ssh-sign";
      };

      delta = {
        enable = true;
        options = {
          navigate = true;
          light = false;
          line-numbers = true;
          side-by-side = true;
        };
      };
    };
    lazygit.enable = true;
  };

}
