return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-python",
      "zidhuss/neotest-minitest",
      "olimorris/neotest-rspec",
    },
    opts = {
      adapters = {
        ["neotest-python"] = {
          args = { "-vv", "-s" },
        },
        ["neotest-minitest"] = {},
        ["neotest-rspec"] = {},
      },
    },
  },
}
