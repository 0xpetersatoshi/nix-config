{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Packages in each category are sorted alphabetically

    # CLI utils
    bat
    btop
    delta
    git
    google-cloud-sdk
    go-task
    kubectl
    kubectx
    neofetch
    zellij

    # Programming
    go
    uv

    # Unstable
    unstable._1password-gui

    # touch ID support in tmux
    pam-reattach
    reattach-to-user-namespace
  ];

  programs = {
    btop.enable = true;
  };
}
