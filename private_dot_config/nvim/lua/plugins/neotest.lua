return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-python",
    },
    opts = {
      adapters = {
        ["neotest-go"] = {
          -- Here we can set options for neotest-go, e.g.
          -- args = { "-tags=integration" }
        },
        ["neotest-python"] = {
          -- Here we can set options for neotest-go, e.g.
          -- args = { "-tags=integration" }
        },
      },
    },
  },
}
