{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.cli.editors.neovim;
in {
  options.cli.editors.neovim = with types; {
    enable = mkBoolOpt false "enable zellij multiplexer";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      alejandra
      bash-language-server
      docker-compose-language-service
      gcc
      # TODO: need to install these manually for now:
      # https://github.com/0no-co/graphqlsp
      # https://github.com/0no-co/gql.tada
      hadolint
      lua-language-server
      markdownlint-cli2
      marksman
      neovim
      nixd
      prettierd
      shfmt
      # TODO: need to find a solution for this as its not available in nixpkgs
      # npm install @nomicfoundation/solidity-language-server -g
      sqls
      stylua
      taplo
      terraform-ls
      vim-language-server
      # For setting up rust DAP
      vscode-extensions.vadimcn.vscode-lldb
      # Includes vscode-json-language-server
      vscode-langservers-extracted
      yaml-language-server
    ];

    xdg.configFile.nvim = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/nvim";
      recursive = true;
    };
  };
}
