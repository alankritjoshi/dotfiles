return {
  {
    "otavioschwanck/arrow.nvim",
    lazy = false,
    dependencies = {
      { "echasnovski/mini.icons" },
    },
    opts = {
      leader_key = ",", -- Recommended to be a single key
      buffer_leader_key = "m", -- Per Buffer Mappings
      always_show_path = true,
      window = {
        border = "rounded",
      },
    },
  },
}
