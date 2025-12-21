return {
  -- Shadowenv.vim plugin for directory-based environment switching
  {
    "Shopify/shadowenv.vim",
    priority = 100, -- Load early
    lazy = false,   -- Load immediately
    config = function()
      -- Hook shadowenv on directory changes
      vim.api.nvim_create_autocmd({"DirChanged", "VimEnter"}, {
        callback = function()
          vim.cmd("silent! ShadowenvHook")
        end,
      })
    end,
  },
}
