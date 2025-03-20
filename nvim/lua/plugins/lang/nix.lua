return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nixd = {
          cmd = { "nixd" },
          filetypes = { "nix" },
          settings = {
            nixd = {
              nixpkgs = {
                expr = "import <nixpkgs> { }",
              },
              formatting = {
                command = { "alejandra" }, -- or nixfmt or nixpkgs-fmt
              },
            },
          },
        },
      },
    },
  },
}
