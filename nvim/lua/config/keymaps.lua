-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Map Option+Shift+H to decrease window width
vim.keymap.set("n", "<M-S-j>", ":resize -2<CR>", { noremap = true, silent = true })

-- Map Option+Shift+L to increase window width
vim.keymap.set("n", "<M-S-k>", ":resize +2<CR>", { noremap = true, silent = true })

-- Map Option+Shift+J to decrease window height
vim.keymap.set("n", "<M-S-h>", ":vertical resize +2<CR>", { noremap = true, silent = true })

-- Map Option+Shift+K to increase window height
vim.keymap.set("n", "<M-S-l>", ":vertical resize -2<CR>", { noremap = true, silent = true })

vim.keymap.set("i", "jj", "<Esc>", { noremap = false })

-- Map page up/down commands to center search results
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })

-- Keep copied text in register
-- vim.keymap.set("n", "<leader>p", '"_dP', { noremap = true, silent = true })

-- Obsidian
-- convert note to template and remove leading white space
vim.keymap.set("n", "<leader>on", ":ObsidianTemplate note<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>")
-- strip date from note title and replace dashes with spaces
-- must have cursor on title
vim.keymap.set("n", "<leader>of", ":s/\\(# \\)[^_]*_/\\1/ | s/-/ /g<cr>")

-- search for files in full vault
vim.keymap.set("n", "<leader>os", ':Telescope find_files search_dirs={"~/obsidian/vault"}<cr>')
vim.keymap.set("n", "<leader>oz", ':Telescope live_grep search_dirs={"~/obsidian/vault"}<cr>')

-- Todo
vim.keymap.set("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

-- list all todos in trouble
vim.keymap.set("n", "<leader>tt", ":Trouble todo<cr>", { desc = "Toggle todos" })

-- search through all project todos in telescope
vim.keymap.set("n", "<leader>tf", ":TodoTelescope<cr>", { desc = "Search todos" })
