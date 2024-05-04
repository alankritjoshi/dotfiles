return {
  {
    "catppuccin/nvim",
    priority = 1000,
    name = "catppuccin",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      transparent_background = true,
      custom_highlights = function()
        return {
          DiffChange = { fg = "#BD93F9" },
          DiffDelete = { fg = "#FF5555" },
        }
      end,
      color_overrides = {
        mocha = {
          base = "#000000",
          mantle = "#000000",
          crust = "#000000",
        },
      },
    },
  },
}
