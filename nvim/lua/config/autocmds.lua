-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Open file under cursor in new buffer
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<leader>fo", function()
      local file = vim.fn.expand "<cfile>"
      local dir = vim.fn.expand "%:p:h"
      vim.cmd("edit " .. vim.fn.fnameescape(dir .. "/" .. file))
    end, { buffer = true, desc = "Open file under cursor in new buffer" })
  end,
})

-- Open file under cursor in a vertical split to the right
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<leader>fv", function()
      local file = vim.fn.expand "<cfile>"
      local dir = vim.fn.expand "%:p:h"
      vim.cmd("vsplit " .. vim.fn.fnameescape(dir .. "/" .. file))
    end, { buffer = true, desc = "Open file under cursor in vertical split" })
  end,
})

-- Mapping to open URL under cursor
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<leader>ou", function()
      local url = vim.fn.expand "<cfile>"
      if url:match "^https?://" then
        local open_cmd = vim.fn.has "mac" == 1 and "open" or "xdg-open" -- Detects macOS or defaults to Linux
        vim.fn.jobstart({ open_cmd, url }, { detach = true })
      else
        print "No valid URL under cursor"
      end
    end, { buffer = true, desc = "Open URL under cursor in browser" })
  end,
})

-- Set filetypes for specific file extensions

-- gitconfig
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = ".gitconfig*",
  callback = function()
    vim.bo.filetype = "gitconfig"
  end,
})

-- .env
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = ".env*",
  callback = function()
    vim.bo.filetype = "sh"
    -- Disable diagnostics for .env
    vim.diagnostic.enable(false)
  end,
})

-- graphqlrc
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.graphqlrc",
  callback = function()
    vim.bo.filetype = "yaml"
  end,
})
