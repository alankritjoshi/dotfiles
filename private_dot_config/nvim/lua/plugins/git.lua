return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 0,
      },
    },
  },
  {
    -- <leader>gg = LazyVim default (lazygit). Neogit kept for small repos via :Neogit;
    -- its status buffer enumerates ALL unpulled commits (26k+ on stale monorepo trees).
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "ibhagwan/fzf-lua",
    },
    config = true,
    cmd = "Neogit",
  },
  {
    "linrongbin16/gitlinker.nvim",
    cmd = "GitLink",
    opts = {},
    keys = {
      { "<leader>gm", "<cmd>GitLink! default_branch<cr>", mode = { "n", "v" }, desc = "Open git link - main branch" },
      { "<leader>go", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open git link" },
    },
  },
}
