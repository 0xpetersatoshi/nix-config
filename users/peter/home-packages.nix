{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Packages in each category are sorted alphabetically

    # CLI utils
    btop
    delta
    git
    google-cloud-sdk
    kubectl
    kubectx
    zellij

    # Programming
    uv
  ];

  programs = {
    btop.enable = true;
  };
}
