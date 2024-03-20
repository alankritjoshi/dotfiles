return {
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
