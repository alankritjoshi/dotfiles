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
        markdown = { "prettierd", "prettier", "markdownlint", "markdown-toc", stop_after_first = true },
        ["markdown.mdx"] = { "prettierd", "prettier", "markdownlint", "markdown-toc", stop_after_first = true },
        swift = { "swift_format" },
      },
      formatters = {
        shfmt = {
          prepend_args = { "-s", "-i", "2" },
        },
        sqlfluff = {
          command = "sqlfluff",
          args = {
            "format",
            "--nocolor",
            "--dialect",
            "ansi",
            "--disable-progress-bar",
            "-",
          },
          stdin = true,
        },
      },
    },
  },
}
