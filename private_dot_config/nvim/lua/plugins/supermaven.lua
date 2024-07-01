return {
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          clear_suggestion = "<S-Tab>",
          accept_word = "<C-l>",
        },
      })
    end,
  },
}
