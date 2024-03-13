return {
  "olimorris/persisted.nvim",
  lazy = false,
  keys = {
    { "<leader>qf", "<cmd>Telescope persisted<cr>", desc = "Search the current sessions" },
    { "<leader>qt", "<cmd>SessionToggle<cr>", desc = "Determines whether to load, start or stop a session" },
    { "<leader>qs", "<cmd>SessionSave<cr>", desc = "Save the current session" },
    { "<leader>qd", "<cmd>SessionDelete<cr>", desc = "Delete the current session" },
  },
  config = function()
    require("persisted").setup({
      autosave = true, -- automatically save session files when exiting Neovim
      should_autosave = function()
        local excluded_filetypes = {
          "alpha",
          "oil",
          "lazy",
          "",
        }

        for _, filetype in ipairs(excluded_filetypes) do
          if vim.bo.filetype == filetype then
            return false
          end
        end

        return true
      end,
      autoload = true, -- automatically load the session for the cwd on Neovim startup
      on_autoload_no_session = function()
        vim.notify("No existing session to load.")
      end,
      use_git_branch = false,
      ignored_dirs = {
        { "~/", exact = true },
        { "/", exact = true },
        { "/tmp", exact = true },
        { "/dev", exact = true },
        { "/Downloads", exact = true },
        { "/Documents", exact = true },
      },
      telescope = {
        mappings = { -- table of mappings for the Telescope extension
          copy_session = "<C-s>",
        },
      },
    })
  end,
}
