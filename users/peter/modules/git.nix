{ pkgs, ... }@inputs:

let
  gpgSSHPath = if pkgs.stdenv.isDarwin
                    then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
                    else "${pkgs.unstable._1password-gui}/op-ssh-sign";
in

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
        url."git@github.com:".insteadOf = "https://github.com/";
        gpg.format = "ssh";
        gpg."ssh".program = gpgSSHPath;
      };

      lfs.enable = true;
      signing = {
        key = inputs.userSettings.gitSigningKey;
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
    lazygit.enable = true;
  };

}
