return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        protols = {
          cmd = { "protols" },
          filetypes = { "proto" },
          root_markers = { ".git" },
        },
      },
    },
  },
}
