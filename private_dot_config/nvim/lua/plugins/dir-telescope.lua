return {
  "princejoogie/dir-telescope.nvim",
  event = "VeryLazy",
  dependencies = {
    {
      "nvim-telescope/telescope.nvim",
    },
  },
  keys = {
    { "<leader>sfd", "<cmd>Telescope dir live_grep<CR>", desc = "Telescope dir grep" },
    { "<leader>sfg", "<cmd>Telescope dir find_files<CR>", desc = "Telescope dir search" },
  },
  config = function()
    require("dir-telescope").setup({
      hidden = true,
      no_ignore = true,
      show_preview = true,
      -- find_command = function()
      --   return { "fd", "--type", "d", "--color", "never", "-E", ".git" }
      -- end,
    })
    require("telescope").load_extension("dir")
  end,
}
