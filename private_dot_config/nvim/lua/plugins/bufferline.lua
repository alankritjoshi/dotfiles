return {
  {
    "akinsho/bufferline.nvim",
    dependencies = {
      "ThePrimeagen/harpoon",
    },
    keys = {
      {
        "<leader>bp",
        "<Cmd>BufferLinePick<CR>",
        desc = "Pick Buffer",
      },
      {
        "<leader>ba",
        "<Cmd>BufferLineCloseOthers<CR><Cmd>bdelete<CR>",
        desc = "Delete Other Buffers",
      },
      {
        "<leader>bh",
        function()
          -- Select last Harpoon buffer
          local harpoon = require("harpoon")
          local marks = harpoon:list().items
          local l = #marks
          harpoon:list():select(l)

          -- Delete all buffers to the right of the last Harpoon buffer
          vim.cmd("BufferLineCloseRight")
        end,
        desc = "Delete Non-Harpoon Buffers",
      },
    },
    opts = {
      offsets = nil,
      options = {
        -- Show numbers only for Harpoon marks
        numbers = function(opts)
          local harpoon = require("harpoon")
          local marks = harpoon:list().items

          local bufname = vim.fn.bufname(opts.id)

          for i, mark in ipairs(marks) do
            if bufname == mark.value then
              return i
            end
          end

          return ""
        end,

        -- Always put sorted Harpoon marks to the beginning of all buffers
        sort_by = function(buffer_a, buffer_b)
          local harpoon = require("harpoon")
          local marks = harpoon:list().items

          -- Use large values for non-Harpoon buffers to show them last
          local a = 1000
          local b = 1000

          local buffer_a_name = vim.fn.bufname(buffer_a.id)
          local buffer_b_name = vim.fn.bufname(buffer_b.id)

          -- Use index of marks for sorting Harpoon buffers
          for index, mark in ipairs(marks) do
            if buffer_a_name == mark.value then
              a = index
              break
            end
            if buffer_b_name == mark.value then
              b = index
              break
            end
          end

          return a < b
        end,
      },
    },
  },
}
