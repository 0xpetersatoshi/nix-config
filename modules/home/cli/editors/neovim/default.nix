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
    home.packages = with pkgs;
      [
        alejandra
        bash-language-server
        docker-compose-language-service
        # TODO: need to install these manually for now:
        # https://github.com/0no-co/graphqlsp
        # https://github.com/0no-co/gql.tada
        hadolint
        lua-language-server
        markdownlint-cli2
        marksman
        neovim
        nixd
        tree-sitter
        prettier
        prettierd
        shfmt
        igloo.solhint
        igloo.solidity-language-server
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
      ]
      # On darwin, use Apple's clang (/usr/bin/cc from Xcode) so tree-sitter
      # parsers can link against libSystem. Nix's gcc on darwin doesn't know
      # the macOS SDK path and fails to link.
      ++ lib.optionals (!pkgs.stdenv.isDarwin) [gcc];

    xdg.configFile.nvim = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/nvim";
      recursive = true;
    };
  };
}
