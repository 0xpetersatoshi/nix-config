return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        graphql = {
          cmd = { "graphql-lsp", "server", "-m", "stream" },
          filetypes = { "graphql", "gql", "graphqls", "typescriptreact" },
        },
      },
    },
  },
}
