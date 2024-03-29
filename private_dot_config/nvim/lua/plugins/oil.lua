return {
  {
    "stevearc/oil.nvim",
    event = { "VimEnter */*,.*", "BufNew */*,.*" },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Oil open parent directory" },
      { "<leader>e", "<cmd>lua require('oil').toggle_float()<cr>", desc = "Oil open float window for current file" },
      { "<leader>E", "<cmd>lua require('oil').toggle_float('.')<cr>", desc = "Oil open float window in cwd" },
      { "<leader>~", "<cmd>lua require('oil').toggle_float('~')<cr>", desc = "Oil open float window in ~" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      use_default_keymaps = false,
      skip_confirm_for_simple_edits = true,
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-\\>"] = "actions.select_split",
        ["<C-enter>"] = "actions.select_vsplit", -- this is used to navigate left
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
      },
      view_options = {
        show_hidden = true,
      },
      float = {
        -- Padding around the floating window
        padding = 10,
        max_width = 300,
        -- border = "rounded",
      },
    },
  },
}
