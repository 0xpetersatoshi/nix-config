{ ... }@inputs:

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
      ignores = [ "*~" "*.swp" ];
      aliases = {
        ci = "commit";
      };
      extraConfig = {
        init.defaultBranch = "main";
        # pull.rebase = "false";
      };
    };
    lazygit.enable = true;
  };

}
