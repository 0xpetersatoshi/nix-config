{pkgs, ...}: {
  home.packages = with pkgs; [
    kubectl
    kubectx

    # touch ID support in tmux
    pam-reattach
    reattach-to-user-namespace
  ];

  xdg.configFile."kanata/config.kbd".source = ../../../dotfiles/kanata/config.kbd;

  cli.programs.git.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFjoHku2U1i34uJWA6kODHU44QJCpQE7LHxYQgk382h";

  desktops.addons.darwin = {
    aerospace.enable = true;
    sketchybar.enable = true;
  };

  roles = {
    common.enable = true;
    development.enable = true;
    desktop.enable = true;
  };

  styles.stylix.theme = "tokyo-night-storm";

  igloo.user = {
    enable = true;
    name = "peter";
  };

  home.stateVersion = "24.11";
}
