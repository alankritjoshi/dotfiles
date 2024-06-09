return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        json = { "prettier" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        html = { "rustywind", "htmlbeautifier" },
        go = { "goimports", "gofumpt" },
        python = { "isort", "ruff_format", "ruff_fix" },
      },
      formatters = {
        shfmt = {
          prepend_args = { "-s", "-i", "2" },
        },
      },
    },
  },
}
