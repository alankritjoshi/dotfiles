return {
  {
    "akinsho/bufferline.nvim",
    dependencies = {
      "ThePrimeagen/harpoon",
    },
    keys = {
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
          local a = 1
          local b = 1

          local harpoon = require("harpoon")
          local marks = harpoon:list().items
          for _, mark in ipairs(marks) do
            if vim.fn.bufname(buffer_a.id) == mark.value then
              a = 0
              break
            elseif vim.fn.bufname(buffer_b.id) == mark.value then
              b = 0
              break
            end
          end
          return a < b
        end,
      },
    },
  },
}
