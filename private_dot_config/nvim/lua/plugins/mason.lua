return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      vim.list_extend(opts.ensure_installed, {
        "goimports",
        "gofumpt",
        "gomodifytags",
        "impl",
        "delve",
      })

      if vim.g.lazyvim_python_lsp == "basedpyright" then
        table.insert(opts.ensure_installed, "basedpyright")
      end
    end,
  },
}
