return {
  {
    "sindrets/diffview.nvim",
    keys = {
      {
        "<leader>gf",
        "<cmd>DiffviewOpen<cr>",
        desc = "Diff View - Current File",
      },
      {
        "<leader>gh",
        "<cmd>DiffviewFileHistory %<cr>",
        desc = "Diff View - File History",
      },
      {
        "<leader>ge",
        "<cmd>DiffviewFileHistory<cr>",
        desc = "Diff View - Branch History",
      },
    },
    opts = {
      -- enhanced_diff_hl = true,
      key_bindings = {
        view = {
          ["<C-c>"] = vim.cmd.DiffviewClose,
          ["q"] = vim.cmd.DiffviewClose,
        },
        file_panel = {
          ["<C-c>"] = vim.cmd.DiffviewClose,
          ["q"] = vim.cmd.DiffviewClose,
        },
        file_history_panel = {
          ["<C-c>"] = vim.cmd.DiffviewClose,
          ["q"] = vim.cmd.DiffviewClose,
        },
        option_panel = {
          ["<C-c>"] = vim.cmd.DiffviewClose,
          ["q"] = vim.cmd.DiffviewClose,
        },
      },
    },
  },
}
