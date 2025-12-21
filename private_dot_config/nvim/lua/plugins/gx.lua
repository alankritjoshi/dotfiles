return {
  "chrishrb/gx.nvim",
  keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" }, desc = "Open in browser" } },
  cmd = { "Browse" },
  init = function()
    vim.g.netrw_nogx = 1
  end,
  opts = {},
}
