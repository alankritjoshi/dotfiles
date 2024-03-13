-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local group = vim.api.nvim_create_augroup("PersistedHooks", {})

vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "PersistedLoadPre",
  group = group,
  callback = function(session)
    vim.notify("Session loaded: " .. session.data.name)
  end,
})

vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "PersistedTelescopeLoadPre",
  group = group,
  callback = function()
    -- Save the currently loaded session using a global variable

    require("persisted").save({ session = vim.g.persisted_loaded_session })
    -- vim.api.nvim_input("<ESC>:BufferCloseAllButPinned<CR>")

    -- Clear all of the open buffers
    vim.api.nvim_input("silent <ESC>:%bd!<CR>")

    require("persisted").stop()
  end,
})

vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "PersistedTelescopeLoadPost",
  group = group,
  callback = function(session)
    -- checkout the branch in git
    if session.data.branch then
      vim.notify("Checking out branch: " .. session.data.branch)
      vim.api.nvim_input("<ESC>:!git checkout " .. session.data.branch .. "<CR>")
    end
  end,
})
