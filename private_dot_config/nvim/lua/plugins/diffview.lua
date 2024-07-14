return {
  {
    "sindrets/diffview.nvim",
    lazy = false,
    keys = {
      {
        "<leader>gd",
        "<cmd>DiffviewOpen<cr>",
        desc = "Diff View - Current File",
      },
      {
        "<leader>gf",
        ":'<,'>DiffviewFileHistory<cr>",
        mode = { "v" },
        desc = "Diff View - Current Line(s)",
      },
      {
        "<leader>gf",
        "<cmd>DiffviewFileHistory %<cr>",
        mode = { "n" },
        desc = "Diff View - File History",
      },
      {
        "<leader>gb",
        "<cmd>DiffviewFileHistory<cr>",
        desc = "Diff View - Branch History",
      },
    },
    opts = {
      -- enhanced_diff_hl = true,
      -- hooks = {
      --   view_opened = function(view)
      --     local actions = require("diffview.actions")
      --     -- view.panel.bufname in: "DiffviewFileHistoryPanel" | "DiffviewFilePanel"
      --     if view.panel.bufname == "DiffviewFilePanel" then
      --       actions.toggle_files() -- auto hide files
      --     end
      --   end,
      -- },
      view = {
        merge_tool = {
          layout = "diff4_mixed",
        },
      },
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
