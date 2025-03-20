return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        solidity = {
          cmd = { "nomicfoundation-solidity-language-server", "--stdio" },
          filetypes = { "solidity" },
          single_file_support = true,
        },
      },
    },
  },
}
