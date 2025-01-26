{ pkgs, ... }: {
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
    zellij

    # Programming
    go
    uv
  ];

  programs = {
    btop.enable = true;
  };
}
