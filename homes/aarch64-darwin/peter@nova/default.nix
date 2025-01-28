{pkgs, ...}: {
  home.packages = with pkgs; [
    google-cloud-sdk
    kubectl
    kubectx
    neofetch

    # Unstable
    unstable._1password-gui

    # touch ID support in tmux
    pam-reattach
    reattach-to-user-namespace
  ];

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
