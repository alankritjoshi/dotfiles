return {
  {
    "catppuccin/nvim",
    priority = 1000,
    name = "catppuccin",
    config = function()
      require("catppuccin").setup({
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
          -- Fix float transparency
          NormalFloat = { bg = "NONE" },
          FloatBorder = { bg = "NONE" },
          -- Fix Snacks picker transparency
          SnacksNormal = { bg = "NONE" },
          SnacksWin = { bg = "NONE" },
          SnacksBackdrop = { bg = "NONE" },
          SnacksNormalNC = { bg = "NONE" },
          SnacksPickerNormal = { bg = "NONE" },
          SnacksPickerBorder = { bg = "NONE" },
          SnacksPickerTitle = { bg = "NONE" },
          SnacksPickerFooter = { bg = "NONE" },
          SnacksPickerHeader = { bg = "NONE" },
          SnacksPickerSelection = { bg = "#45475a", fg = "#cdd6f4" },
          SnacksPickerMatch = { fg = "#f38ba8", bold = true },
        }
      end,
      color_overrides = {
        mocha = {
          base = "#000000",
          mantle = "#000000",
          crust = "#000000",
        },
      },
      })
      
      -- Apply colorscheme
      vim.cmd.colorscheme("catppuccin")
      
      -- Force transparency for floating windows after everything loads
      vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter", "WinEnter", "BufWinEnter" }, {
        callback = function()
          vim.cmd([[
            hi NormalFloat guibg=NONE ctermbg=NONE
            hi FloatBorder guibg=NONE ctermbg=NONE
            hi SnacksNormal guibg=NONE ctermbg=NONE
            hi SnacksWin guibg=NONE ctermbg=NONE
            hi SnacksBackdrop guibg=NONE ctermbg=NONE
          ]])
        end,
      })
    end,
  },
}
