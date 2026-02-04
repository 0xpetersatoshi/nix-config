return {
  -- LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        solidity = {
          cmd = { "nomicfoundation-solidity-language-server", "--stdio" },
          filetypes = { "solidity" },
          root_markers = { "foundry.toml", "hardhat.config.js", "hardhat.config.ts", ".git" },
          single_file_support = true,
        },
      },
    },
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        solidity = { "forge_fmt" },
      },
    },
  },

  -- Linting
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        solidity = { "solhint" },
      },
    },
  },

  -- Testing
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "llllvvuu/neotest-foundry",
    },
    opts = {
      adapters = {
        ["neotest-foundry"] = {},
      },
    },
  },
}
