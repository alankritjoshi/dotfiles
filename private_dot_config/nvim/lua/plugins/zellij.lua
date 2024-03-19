return {
  {
    "Lilja/zellij.nvim",
    enabled = false,
    event = "VeryLazy",
    config = function()
      require("zellij").setup({})
    end,
  },
}
