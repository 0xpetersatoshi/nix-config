{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
          _1password-cli
          curl
          direnv
          fd
          fzf
          gnupg
          htop
          inetutils
          iperf3
          jq
          neovim
          nmap
          nil
          nixd
          ripgrep
          statix
          tmux
          tree
          wget
        ];
}
