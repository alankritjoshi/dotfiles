return {
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup({
        transparent = true,
        italic_comments = true,
        hide_fillchars = true,
        borderless_telescope = true,
        terminal_colors = true,
      })
    end,
  },
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
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      custom_highlights = function()
        return {
          DiffChange = { fg = "#BD93F9" },
          DiffDelete = { fg = "#FF5555" },
        }
      end,
    },
  },
}
