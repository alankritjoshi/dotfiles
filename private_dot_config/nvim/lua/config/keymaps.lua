-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.del("n", "<C-H>")
vim.keymap.del("n", "<C-J>")
vim.keymap.del("n", "<C-K>")
vim.keymap.del("n", "<C-L>")

-- Yank relative file path
vim.keymap.set("n", "<leader>yr", function()
  local relative_path = vim.fn.expand("%:.")
  vim.fn.setreg("+", relative_path)
  print("Yanked: " .. relative_path)
end, { desc = "Yank Relative File Path" })

-- You might also want the absolute path
vim.keymap.set("n", "<leader>ya", function()
  local absolute_path = vim.fn.expand("%:p")
  vim.fn.setreg("+", absolute_path)
  print("Yanked: " .. absolute_path)
end, { desc = "Yank Absolute File Path" })
