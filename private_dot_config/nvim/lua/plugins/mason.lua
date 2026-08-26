return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      vim.list_extend(opts.ensure_installed, {
        "markdownlint",
      })

      if vim.g.lazyvim_python_lsp == "basedpyright" then
        table.insert(opts.ensure_installed, "basedpyright")
      end
    end,
  },
}
