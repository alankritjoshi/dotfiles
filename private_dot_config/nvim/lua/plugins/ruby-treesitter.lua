return {
  "RRethy/nvim-treesitter-endwise",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    -- Configure endwise and Ruby indent override
    -- This extends the base treesitter config
    local configs = require("nvim-treesitter.configs")

    configs.setup({
      endwise = {
        enable = true,
      },
      indent = {
        enable = true,
        disable = { "ruby" },  -- Use Vim's built-in Ruby indent instead
      },
    })
  end,
}
