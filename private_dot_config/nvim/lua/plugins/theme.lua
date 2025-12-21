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
          -- Blink.cmp with distinct menu vs docs
          BlinkCmpMenu = { bg = "#11111b" },
          BlinkCmpMenuBorder = { fg = "#585b70", bg = "#11111b" },
          BlinkCmpMenuSelection = { bg = "#313244", fg = "#cdd6f4", bold = true },
          BlinkCmpDoc = { bg = "#181825" },
          BlinkCmpDocBorder = { fg = "#6c7086", bg = "#181825" },
          BlinkCmpSignatureHelp = { bg = "#181825" },
          BlinkCmpSignatureHelpBorder = { fg = "#6c7086", bg = "#181825" },
        }
      end,
      color_overrides = {
        mocha = {
          base = "#181825",
          mantle = "#181825",
          crust = "#11111b",
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
