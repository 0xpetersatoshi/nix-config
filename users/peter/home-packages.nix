{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Packages in each category are sorted alphabetically

    # CLI utils
    btop
    delta
    zellij

    # Programming
    uv
  ];

  programs = {
    btop.enable = true;
  };
}
