return {
  {
    "sindrets/diffview.nvim",
    keys = {
      {
        "<leader>gdf",
        "<cmd>DiffviewOpen<cr>",
        desc = "Diff View - Current File",
      },
      {
        "<leader>gdh",
        "<cmd>DiffviewFileHistory %<cr>",
        desc = "Diff View - File History",
      },
      {
        "<leader>gdb",
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
