{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
          _1password-cli
          direnv
          gnupg
          htop
          nil
          nixd
          statix
          # touch ID support in tmux
          pam-reattach
          reattach-to-user-namespace

          # Unstable
          unstable._1password-gui
        ];
}
