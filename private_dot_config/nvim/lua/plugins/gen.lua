return {
  "David-Kunz/gen.nvim",
  commands = { "Gen" },
  keys = {
    { "<leader>cg", ":Gen<CR>", desc = "Ollama Generate", mode = { "n", "v" } },
  },
  config = function()
    require("gen").model = "codellama"
  end,
}
