-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

vim.keymap.set("n", "<C-Left>", "<C-h>", { desc = "Go to Left Window", remap = true })
vim.keymap.set("n", "<C-Down>", "<C-j>", { desc = "Go to Lower Window", remap = true })
vim.keymap.set("n", "<C-Up>", "<C-k>", { desc = "Go to Upper Window", remap = true })
vim.keymap.set("n", "<C-Right>", "<C-l>", { desc = "Go to Right Window", remap = true })
