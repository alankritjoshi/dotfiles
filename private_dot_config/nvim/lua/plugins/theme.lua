return {
  {
    "EdenEast/nightfox.nvim",
    lazy = true,
    name = "carbonfox",
    config = function()
      require("nightfox").setup({
        transparent = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
      })
    end,
  },
  -- {
  --   "catppuccin/nvim",
  --   lazy = true,
  --   name = "catppuccin",
  --   opts = {
  --     transparent = true,
  --     styles = {
  --       sidebars = "transparent",
  --       floats = "transparent",
  --     },
  --     custom_highlights = function()
  --       return {
  --         DiffChange = { fg = "#BD93F9" },
  --         DiffDelete = { fg = "#FF5555" },
  --       }
  --     end,
  --   },
  -- },
}
