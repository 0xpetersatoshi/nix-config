-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
-- Disable autoformat for yaml files
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
    vim.keymap.set("n", "<leader>ou", function()
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

-- Disable ruff hover in favor of Pyright
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      return
    end
    if client.name == "ruff" then
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
    end
  end,
  desc = "LSP: Disable hover capability from Ruff",
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
