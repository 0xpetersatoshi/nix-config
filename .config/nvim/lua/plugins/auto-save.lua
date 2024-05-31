return {
  "pocco81/auto-save.nvim",
  config = function()
    vim.api.nvim_create_autocmd({ "InsertLeave" }, {
      pattern = { "*" },
      command = "silent! wall",
      nested = true,
    })
  end,
}
