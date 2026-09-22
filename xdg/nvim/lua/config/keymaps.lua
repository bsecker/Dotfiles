-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

vim.keymap.set("n", "<C-Left>", "<C-h>", { desc = "Go to Left Window", remap = true })
vim.keymap.set("n", "<C-Down>", "<C-j>", { desc = "Go to Lower Window", remap = true })
vim.keymap.set("n", "<C-Up>", "<C-k>", { desc = "Go to Upper Window", remap = true })
vim.keymap.set("n", "<C-Right>", "<C-l>", { desc = "Go to Right Window", remap = true })

vim.keymap.set("n", "<leader>gH", require("config.github").copy_permalink, { desc = "Copy GitHub permalink" })

vim.keymap.set("n", "<leader>wY", function()
  local path = vim.fn.expand("%:p")
  if path == "" then
    vim.notify("Current buffer has no file", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", path)
  vim.notify("Copied " .. path)
end, { desc = "Copy absolute file path" })
