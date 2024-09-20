-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
-- Disable autoformat for lua files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "yaml" },
  callback = function()
    vim.b.autoformat = false
  end,
})

-- Open file under cursor in new buffer
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<leader>go", function()
      local file = vim.fn.expand("<cfile>")
      vim.cmd("edit " .. file)
    end, { buffer = true, desc = "Open file under cursor in new buffer" })
  end,
})

-- Open file under cursor in a vertical split to the right
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<leader>gv", function()
      local file = vim.fn.expand("<cfile>")
      vim.cmd("vsplit " .. file)
    end, { buffer = true, desc = "Open file under cursor in vertical split" })
  end,
})
