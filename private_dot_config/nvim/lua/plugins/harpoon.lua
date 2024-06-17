return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    opts = {
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
      },
      settings = {
        save_on_toggle = true,
      },
    },
    keys = function()
      local harpoon = require("harpoon")

      local function harpoonOpenAll()
        local marks = harpoon:list().items

        for i, _ in ipairs(marks) do
          harpoon:list():select(i)
        end

        if #marks == 0 then
          vim.notify("No Harpoon marks found!")
        else
          harpoon:list():select(#marks)
        end
      end

      local keys = {
        {
          "<leader>H",
          function()
            harpoon:list():add()
            harpoonOpenAll()
          end,
          desc = "Harpoon File",
        },
        {
          "<leader>h",
          function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
          end,
          desc = "Harpoon Quick Menu",
        },
        {
          "<leader>0",
          harpoonOpenAll,
          desc = "Harpoon open all",
        },
      }

      for i = 1, 5 do
        table.insert(keys, {
          "<leader>" .. i,
          function()
            harpoon:list():select(i)
          end,
          desc = "Harpoon to File " .. i,
        })
      end
      return keys
    end,
  },
}
