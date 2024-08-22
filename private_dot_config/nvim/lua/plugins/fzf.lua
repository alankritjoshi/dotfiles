return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- config = function()
    --   local fzf_lua = function()
    --     return require("fzf-lua")
    --   end
    --
    --   fzf_lua().setup({
    --     files = {
    --       fd_opts = [[--color=never --type file --type dir --hidden --follow --exclude .git]],
    --       actions = {
    --         ["ctrl-e"] = {
    --           -- filter by selected subdirectory
    --           function(selected, opts)
    --             local entry = fzf_lua().path.entry_to_file(selected[1])
    --             if not fzf_lua().path.is_absolute(entry.path) then
    --               entry.path = fzf_lua().path.join({ opts.cwd or vim.uv.cwd(), entry.path })
    --             end
    --
    --             -- if not directory, just refresh
    --             if not entry.path or vim.fn.isdirectory(entry.path) ~= 1 then
    --               entry.path = opts.cwd
    --             end
    --
    --             fzf_lua().files({ cwd = entry.path })
    --           end,
    --         },
    --         ["ctrl-r"] = {
    --           -- expand filter to parent directory
    --           function(_, opts)
    --             fzf_lua().files({
    --               cwd = vim.fn.fnamemodify(vim.fs.normalize(opts.cwd or vim.uv.cwd()), ":h"),
    --             })
    --           end,
    --         },
    --       },
    --     },
    --   })
    -- end,
  },
}
