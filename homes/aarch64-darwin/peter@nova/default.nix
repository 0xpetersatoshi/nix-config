{pkgs, ...}: {

  home.packages = with pkgs; [
    google-cloud-sdk
    kubectl
    kubectx
    neofetch

    # touch ID support in tmux
    pam-reattach
    reattach-to-user-namespace
  ];

  cli.programs.git.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFjoHku2U1i34uJWA6kODHU44QJCpQE7LHxYQgk382h";

  roles = {
    common.enable = true;
    development.enable = true;
  };

  igloo.user = {
    enable = true;
    name = "peter";
  };

  home.stateVersion = "24.11";
}
