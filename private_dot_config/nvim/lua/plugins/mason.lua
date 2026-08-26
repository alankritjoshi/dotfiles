return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- These can't install via mason on vanik: tec's npm shim rejects npm
      -- installs (pnpm-only) and go isn't on the global PATH. Provided by
      -- home-manager (nix) instead; see modules/home/common.nix.
      local unmasonable = {
        "goimports",
        "gofumpt",
        "gomodifytags",
        "impl",
        "delve",
        "markdownlint",
        "markdownlint-cli2",
        "markdown-toc",
      }
      opts.ensure_installed = vim.tbl_filter(function(tool)
        return not vim.tbl_contains(unmasonable, tool)
      end, opts.ensure_installed or {})
    end,
  },
}
