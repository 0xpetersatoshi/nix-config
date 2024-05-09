-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>cD", vim.lsp.buf.definition, { desc = "Code Definition" })
vim.keymap.set("n", "<leader>cR", vim.lsp.buf.references, { desc = "Code References" })
vim.keymap.set("n", "<leader>p", vim.lsp.buf.document_symbol, { desc = "Document Symbols" })
