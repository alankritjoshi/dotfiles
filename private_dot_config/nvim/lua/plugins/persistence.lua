return {
  {
    "folke/persistence.nvim",
    dependencies = {
      "ThePrimeagen/harpoon",
    },
    opts = {
      post_load = function()
        local harpoon = require("harpoon")
        local marks = harpoon:list().items

        for i, _ in ipairs(marks) do
          harpoon:list():select(i)
        end

        if #marks ~= 0 then
          harpoon:list():select(1)
        end
      end,
    },
  },
}
