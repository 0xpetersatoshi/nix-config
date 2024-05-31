-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Map Option+Shift+H to decrease window width
vim.api.nvim_set_keymap("n", "<M-S-j>", ":resize -2<CR>", { noremap = true, silent = true })

-- Map Option+Shift+L to increase window width
vim.api.nvim_set_keymap("n", "<M-S-k>", ":resize +2<CR>", { noremap = true, silent = true })

-- Map Option+Shift+J to decrease window height
vim.api.nvim_set_keymap("n", "<M-S-h>", ":vertical resize -2<CR>", { noremap = true, silent = true })

-- Map Option+Shift+K to increase window height
vim.api.nvim_set_keymap("n", "<M-S-l>", ":vertical resize +2<CR>", { noremap = true, silent = true })
