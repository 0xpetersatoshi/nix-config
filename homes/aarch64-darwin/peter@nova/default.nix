{pkgs, ...}: {
  home.packages = with pkgs; [
    awscli2
    buildkite-cli
    crane
    doppler
    graphite-cli
    gws

    kubectl
    kubectx

    # touch ID support in tmux
    pam-reattach
    pscale
    railway
    reattach-to-user-namespace
  ];

  xdg.configFile."kanata/config.kbd".source = ../../../dotfiles/kanata/config.kbd;

  cli.ai.cursor.enable = true;


  desktops.addons.darwin = {
    aerospace.enable = true;
    sketchybar.enable = true;
  };

  roles = {
    common.enable = true;
    development.enable = true;
    desktop.enable = true;
  };

  igloo = {
    user = {
      enable = true;
      name = "peter";
    };

    security.sops.enable = true;
  };

  home.stateVersion = "24.11";
}
