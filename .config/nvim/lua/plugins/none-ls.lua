return {
  "nvimtools/none-ls",
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.shfmt,
        null_ls.builtins.formatting.shellcheck,
        null_ls.builtins.formatting.flake8,
      },
    })
  end,
}
