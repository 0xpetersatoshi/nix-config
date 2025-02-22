return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      nix = { "alejandra" },
      python = { "ruff_format", "ruff_fix", "ruff_organize_imports" }, -- This will run both formatting and fixing (including import sorting)
      typescript = { "prettierd" },
    },
  },
}
