-- Ruby formatter extension for conform.nvim
-- This extends the base conform configuration with Ruby support
return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    -- Extend existing formatters_by_ft
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters_by_ft.ruby = { "rubocop" }

    -- Add rubocop formatter configuration
    opts.formatters = opts.formatters or {}
    opts.formatters.rubocop = {
      command = vim.fn.expand("~/.config/nvim/rubocop-formatter-wrapper.sh"),
      args = { "--auto-correct-all", "--format", "quiet", "--stderr", "--stdin", "$FILENAME" },
      stdin = true,
      cwd = require("conform.util").root_file({ "dev.yml", ".shadowenv.d", ".rubocop.yml", "Gemfile" }),
    }

    return opts
  end,
}
