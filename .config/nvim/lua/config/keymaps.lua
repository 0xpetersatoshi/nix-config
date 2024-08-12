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
