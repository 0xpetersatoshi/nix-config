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
    vim.keymap.set("n", "<leader>fo", function()
      local file = vim.fn.expand("<cfile>")
      local dir = vim.fn.expand("%:p:h")
      vim.cmd("edit " .. vim.fn.fnameescape(dir .. "/" .. file))
    end, { buffer = true, desc = "Open file under cursor in new buffer" })
  end,
})

-- Open file under cursor in a vertical split to the right
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<leader>fv", function()
      local file = vim.fn.expand("<cfile>")
      local dir = vim.fn.expand("%:p:h")
      vim.cmd("vsplit " .. vim.fn.fnameescape(dir .. "/" .. file))
    end, { buffer = true, desc = "Open file under cursor in vertical split" })
  end,
})

-- Mapping to create a new empty buffer
vim.keymap.set("n", "<leader>fn", ":enew<CR>", { desc = "Create new file" })

-- Mapping to save to a specific path
vim.keymap.set("n", "<leader>fs", function()
  local path = vim.fn.input("Save as: ", vim.fn.expand("%:p:h") .. "/", "file")
  if path ~= "" then
    vim.cmd("write! " .. vim.fn.fnameescape(path))
    print("File saved to " .. path)
  else
    print("Save canceled.")
  end
end, { desc = "Save file to specific path" })

-- Mapping to open URL under cursor
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<leader>fu", function()
      local url = vim.fn.expand("<cfile>")
      if url:match("^https?://") then
        local open_cmd = vim.fn.has("mac") == 1 and "open" or "xdg-open" -- Detects macOS or defaults to Linux
        vim.fn.jobstart({ open_cmd, url }, { detach = true })
      else
        print("No valid URL under cursor")
      end
    end, { buffer = true, desc = "Open URL under cursor in browser" })
  end,
})

-- Run PyrightOrganizeImports on save
local python = vim.api.nvim_create_augroup("PythonFormatting", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  group = python,
  callback = function()
    -- Save current cursor position
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- Run PyrightOrganizeImports
    vim.cmd("PyrightOrganizeImports")

    -- Restore cursor position (in case the imports reorganization moved it)
    vim.api.nvim_win_set_cursor(0, { row, col })
  end,
})
